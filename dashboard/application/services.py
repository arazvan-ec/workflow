"""Application services that orchestrate domain logic."""
from __future__ import annotations

from dataclasses import dataclass, field, asdict
from infrastructure.repositories import (
    FeatureRepository, SessionRepository, GitRepository,
    PluginRepository, ConfigRepository, SnapshotRepository,
)


def _entity_to_dict(obj) -> dict:
    """Convert a dataclass to dict, handling enums."""
    if hasattr(obj, "__dataclass_fields__"):
        result = {}
        for k, v in asdict(obj).items():
            result[k] = v
        return result
    return obj


class FeatureService:
    def __init__(self, repo: FeatureRepository):
        self.repo = repo

    def list_features(self) -> list[dict]:
        features = self.repo.list_features()
        return [self._feature_summary(f) for f in features]

    def get_feature(self, feature_id: str) -> dict | None:
        f = self.repo.get_feature(feature_id)
        if not f:
            return None
        return self._feature_detail(f)

    def get_tasks(self, feature_id: str) -> list[dict]:
        tasks = self.repo.get_tasks(feature_id)
        return [_entity_to_dict(t) for t in tasks]

    def _feature_summary(self, f) -> dict:
        roles_summary = {}
        for role_key, rp in f.roles.items():
            roles_summary[role_key] = {
                "status": rp.status.value,
                "progress_pct": rp.progress_pct,
                "checkpoints_done": rp.checkpoints_done,
                "checkpoints_total": rp.checkpoints_total,
            }
        return {
            "id": f.id,
            "name": f.name,
            "workflow": f.workflow,
            "created": f.created,
            "overall_status": f.overall_status,
            "overall_progress_pct": f.overall_progress_pct,
            "roles": roles_summary,
            "blockers_count": len(f.blockers),
            "artifacts_count": len(f.artifacts),
        }

    def _feature_detail(self, f) -> dict:
        roles_detail = {}
        for role_key, rp in f.roles.items():
            roles_detail[role_key] = {
                "role": rp.role,
                "status": rp.status.value,
                "progress_pct": rp.progress_pct,
                "completion_signal": rp.completion_signal,
                "started": rp.started,
                "completed": rp.completed,
                "depends_on": rp.depends_on,
                "checkpoints_done": rp.checkpoints_done,
                "checkpoints_total": rp.checkpoints_total,
                "current_task": rp.current_task,
                "notes": rp.notes,
                "blockers": rp.blockers,
                "artifacts": rp.artifacts,
                "completed_tasks": rp.completed_tasks,
                "coverage_lines": rp.coverage_lines,
                "coverage_branches": rp.coverage_branches,
            }

        phases = [
            {
                "name": p.name,
                "status": p.status,
                "tasks_done": p.tasks_done,
                "tasks_total": p.tasks_total,
                "progress_pct": p.progress_pct,
            }
            for p in f.phases
        ]

        decisions = [
            {"date": d.date, "decision": d.decision, "rationale": d.rationale}
            for d in f.decisions
        ]

        return {
            "id": f.id,
            "name": f.name,
            "workflow": f.workflow,
            "created": f.created,
            "last_updated": f.last_updated,
            "overall_status": f.overall_status,
            "overall_progress_pct": f.overall_progress_pct,
            "roles": roles_detail,
            "phases": phases,
            "blockers": f.blockers,
            "decisions": decisions,
            "artifacts": f.artifacts,
        }


class SessionService:
    def __init__(self, repo: SessionRepository):
        self.repo = repo

    def list_sessions(self) -> list[dict]:
        sessions = self.repo.list_sessions()
        return [self._session_to_dict(s) for s in sessions]

    def get_session(self, session_id: str) -> dict | None:
        s = self.repo.get_session(session_id)
        if not s:
            return None
        return self._session_to_dict(s)

    def _session_to_dict(self, s) -> dict:
        return {
            "session_id": s.session_id,
            "slug": s.slug,
            "git_branch": s.git_branch,
            "started_at": s.started_at,
            "last_activity_at": s.last_activity_at,
            "duration_seconds": s.duration_seconds,
            "message_count": s.message_count,
            "user_message_count": s.user_message_count,
            "assistant_message_count": s.assistant_message_count,
            "tool_calls": [{"tool": tc.tool, "count": tc.count} for tc in s.tool_calls],
            "model": s.model,
            "permission_mode": s.permission_mode,
            "cwd": s.cwd,
            "total_input_tokens": s.total_input_tokens,
            "total_output_tokens": s.total_output_tokens,
        }


class OverviewService:
    def __init__(
        self,
        feature_svc: FeatureService,
        session_svc: SessionService,
        plugin_repo: PluginRepository,
        git_repo: GitRepository,
        config_repo: ConfigRepository,
    ):
        self.feature_svc = feature_svc
        self.session_svc = session_svc
        self.plugin_repo = plugin_repo
        self.git_repo = git_repo
        self.config_repo = config_repo

    def get_overview(self) -> dict:
        features = self.feature_svc.list_features()
        config = self.config_repo.get_config()
        plugin_info = self.plugin_repo.get_plugin_info()
        commits = self.git_repo.get_commits(limit=5)
        sessions = self.session_svc.list_sessions()[:5]

        total = len(features)
        completed = sum(1 for f in features if f["overall_status"] == "COMPLETED")
        in_progress = sum(1 for f in features if f["overall_status"] == "IN_PROGRESS")
        blocked = sum(1 for f in features if f["overall_status"] == "BLOCKED")
        pending = total - completed - in_progress - blocked

        avg_progress = sum(f["overall_progress_pct"] for f in features) / total if total > 0 else 0

        return {
            "project": {
                "name": config.name,
                "type": config.project_type,
                "description": config.description,
                "plugin_version": plugin_info.get("version", "unknown"),
            },
            "features_summary": {
                "total": total,
                "completed": completed,
                "in_progress": in_progress,
                "blocked": blocked,
                "pending": pending,
                "overall_progress_pct": round(avg_progress, 1),
            },
            "features": features,
            "recent_commits": [_entity_to_dict(c) for c in commits],
            "recent_sessions": sessions,
            "plugin_stats": {
                "agents": len(self.plugin_repo.list_agents()),
                "skills": len(self.plugin_repo.list_skills()),
                "commands": len(self.plugin_repo.list_commands()),
            },
        }


class PluginService:
    def __init__(self, repo: PluginRepository):
        self.repo = repo

    def get_agents(self) -> list[dict]:
        return [_entity_to_dict(a) for a in self.repo.list_agents()]

    def get_skills(self) -> list[dict]:
        return [_entity_to_dict(s) for s in self.repo.list_skills()]

    def get_commands(self) -> list[dict]:
        return [_entity_to_dict(c) for c in self.repo.list_commands()]

    def get_info(self) -> dict:
        return self.repo.get_plugin_info()


class QualityService:
    def __init__(self, feature_repo: FeatureRepository):
        self.feature_repo = feature_repo

    def get_quality_overview(self) -> dict:
        features = self.feature_repo.list_features()
        quality_data = []

        for f in features:
            feature_quality = {
                "feature_id": f.id,
                "feature_name": f.name,
                "roles": {},
            }
            for role_key, rp in f.roles.items():
                feature_quality["roles"][role_key] = {
                    "coverage_lines": rp.coverage_lines,
                    "coverage_branches": rp.coverage_branches,
                    "blockers": rp.blockers,
                    "completed_pct": rp.progress_pct,
                }
            quality_data.append(feature_quality)

        return {"features": quality_data}
