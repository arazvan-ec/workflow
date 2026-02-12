"""Concrete repository implementations that read from the filesystem."""
from __future__ import annotations

import subprocess
from pathlib import Path
from domain.entities import (
    Feature, Task, Session, Commit, Agent, Skill, Command, Snapshot, ProjectConfig,
)
from infrastructure.config import Settings
from infrastructure.parsers.state_parser import parse_state_file
from infrastructure.parsers.task_parser import parse_task_file
from infrastructure.parsers.config_parser import parse_config
from infrastructure.parsers.plugin_parser import (
    parse_plugin_json, parse_agent_file, parse_skill_file, parse_command_file,
)
from infrastructure.parsers.session_parser import parse_session_file


class FeatureRepository:
    def __init__(self, settings: Settings):
        self.settings = settings
        self._cache: dict[str, Feature] = {}

    def list_features(self) -> list[Feature]:
        features = []
        features_dir = self.settings.features_dir
        if not features_dir.exists():
            return features
        for feature_dir in sorted(features_dir.iterdir()):
            if not feature_dir.is_dir():
                continue
            state_file = feature_dir / "50_state.md"
            if state_file.exists():
                feature = self._load_feature(feature_dir.name, state_file)
                features.append(feature)
        return features

    def get_feature(self, feature_id: str) -> Feature | None:
        state_file = self.settings.features_dir / feature_id / "50_state.md"
        if not state_file.exists():
            return None
        return self._load_feature(feature_id, state_file)

    def get_tasks(self, feature_id: str) -> list[Task]:
        feature_dir = self.settings.features_dir / feature_id
        if not feature_dir.exists():
            return []
        tasks = []
        for pattern in ["30_tasks*.md"]:
            for task_file in feature_dir.glob(pattern):
                content = task_file.read_text(encoding="utf-8", errors="replace")
                tasks.extend(parse_task_file(content, feature_id))
        return tasks

    def get_artifact_list(self, feature_id: str) -> list[str]:
        feature_dir = self.settings.features_dir / feature_id
        if not feature_dir.exists():
            return []
        return [f.name for f in sorted(feature_dir.iterdir()) if f.is_file() and f.suffix == ".md"]

    def get_artifact_content(self, feature_id: str, filename: str) -> str | None:
        path = self.settings.features_dir / feature_id / filename
        if not path.exists() or not path.is_file():
            return None
        return path.read_text(encoding="utf-8", errors="replace")

    def _load_feature(self, feature_id: str, state_file: Path) -> Feature:
        content = state_file.read_text(encoding="utf-8", errors="replace")
        feature = parse_state_file(content, feature_id)
        feature.artifacts = self.get_artifact_list(feature_id)
        self._cache[feature_id] = feature
        return feature

    def invalidate(self, feature_id: str | None = None):
        if feature_id:
            self._cache.pop(feature_id, None)
        else:
            self._cache.clear()


class SessionRepository:
    def __init__(self, settings: Settings):
        self.settings = settings

    def list_sessions(self) -> list[Session]:
        sessions = []
        log_dir = self.settings.session_logs_dir
        if not log_dir.exists():
            return sessions
        for jsonl_file in sorted(log_dir.glob("*.jsonl"), key=lambda p: p.stat().st_mtime, reverse=True):
            session = parse_session_file(jsonl_file)
            if session:
                sessions.append(session)
        return sessions[:50]  # Limit to last 50

    def get_session(self, session_id: str) -> Session | None:
        log_dir = self.settings.session_logs_dir
        if not log_dir.exists():
            return None
        path = log_dir / f"{session_id}.jsonl"
        if path.exists():
            return parse_session_file(path)
        # Search by session ID in filenames
        for jsonl_file in log_dir.glob("*.jsonl"):
            if session_id in jsonl_file.stem:
                return parse_session_file(jsonl_file)
        return None


class GitRepository:
    def __init__(self, settings: Settings):
        self.settings = settings

    def get_commits(self, limit: int = 50, feature: str | None = None) -> list[Commit]:
        cmd = [
            "git", "log",
            f"--max-count={limit}",
            "--format=%H|%h|%s|%an|%aI|%+",
            "--shortstat",
        ]
        if feature:
            cmd.append(f"--grep={feature}")

        try:
            result = subprocess.run(
                cmd, capture_output=True, text=True, timeout=10,
                cwd=str(self.settings.project_root),
            )
            if result.returncode != 0:
                return []
        except (subprocess.TimeoutExpired, FileNotFoundError):
            return []

        return self._parse_git_log(result.stdout)

    def get_branches(self) -> list[str]:
        try:
            result = subprocess.run(
                ["git", "branch", "--all", "--format=%(refname:short)"],
                capture_output=True, text=True, timeout=5,
                cwd=str(self.settings.project_root),
            )
            return [b.strip() for b in result.stdout.strip().split("\n") if b.strip()]
        except (subprocess.TimeoutExpired, FileNotFoundError):
            return []

    def _parse_git_log(self, output: str) -> list[Commit]:
        commits = []
        lines = output.strip().split("\n")
        i = 0
        while i < len(lines):
            line = lines[i].strip()
            if not line or "|" not in line:
                i += 1
                continue
            parts = line.split("|", 5)
            if len(parts) < 5:
                i += 1
                continue

            commit = Commit(
                hash=parts[0],
                short_hash=parts[1],
                message=parts[2],
                author=parts[3],
                date=parts[4],
            )

            # Look for shortstat line
            if i + 1 < len(lines):
                stat_line = lines[i + 1].strip()
                import re
                files_m = re.search(r"(\d+) files? changed", stat_line)
                ins_m = re.search(r"(\d+) insertions?", stat_line)
                del_m = re.search(r"(\d+) deletions?", stat_line)
                if files_m:
                    commit.files_changed = int(files_m.group(1))
                if ins_m:
                    commit.insertions = int(ins_m.group(1))
                if del_m:
                    commit.deletions = int(del_m.group(1))
                if files_m or ins_m or del_m:
                    i += 1

            commits.append(commit)
            i += 1

        return commits


class PluginRepository:
    def __init__(self, settings: Settings):
        self.settings = settings

    def get_plugin_info(self) -> dict:
        path = self.settings.plugin_json_path
        if not path.exists():
            return {}
        content = path.read_text(encoding="utf-8", errors="replace")
        return parse_plugin_json(content)

    def list_agents(self) -> list[Agent]:
        agents = []
        agents_dir = self.settings.agents_dir
        if not agents_dir.exists():
            return agents
        for md_file in sorted(agents_dir.rglob("*.md")):
            try:
                agents.append(parse_agent_file(md_file))
            except Exception:
                continue
        return agents

    def list_skills(self) -> list[Skill]:
        skills = []
        skills_dir = self.settings.skills_dir
        if not skills_dir.exists():
            return skills
        for skill_file in sorted(skills_dir.rglob("SKILL.md")):
            try:
                skills.append(parse_skill_file(skill_file))
            except Exception:
                continue
        # Also check top-level .md files in skills dir
        for md_file in sorted(skills_dir.glob("*.md")):
            try:
                skills.append(parse_skill_file(md_file))
            except Exception:
                continue
        return skills

    def list_commands(self) -> list[Command]:
        commands = []
        cmd_dir = self.settings.commands_dir
        if not cmd_dir.exists():
            return commands
        for md_file in sorted(cmd_dir.glob("*.md")):
            try:
                commands.append(parse_command_file(md_file))
            except Exception:
                continue
        return commands


class ConfigRepository:
    def __init__(self, settings: Settings):
        self.settings = settings

    def get_config(self) -> ProjectConfig:
        path = self.settings.config_path
        if not path.exists():
            return ProjectConfig()
        content = path.read_text(encoding="utf-8", errors="replace")
        return parse_config(content)


class SnapshotRepository:
    def __init__(self, settings: Settings):
        self.settings = settings

    def list_snapshots(self) -> list[Snapshot]:
        snapshots = []
        snap_dir = self.settings.snapshots_dir
        if not snap_dir.exists():
            return snapshots
        import json
        for meta_file in sorted(snap_dir.rglob("checkpoint_meta.json"), reverse=True):
            try:
                data = json.loads(meta_file.read_text(encoding="utf-8"))
                snapshots.append(Snapshot(
                    timestamp=data.get("timestamp", ""),
                    session_id=data.get("session_id", ""),
                    feature=data.get("feature", ""),
                    stop_reason=data.get("stop_reason", ""),
                    directory=str(meta_file.parent),
                ))
            except (json.JSONDecodeError, OSError):
                continue
        return snapshots
