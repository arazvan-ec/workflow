from dataclasses import dataclass, field
from pathlib import Path


@dataclass
class Settings:
    project_root: Path = field(default_factory=lambda: Path("/home/user/workflow"))
    ai_dir: Path = field(default_factory=lambda: Path("/home/user/workflow/.ai"))
    plugin_dir: Path = field(default_factory=lambda: Path("/home/user/workflow/plugins/multi-agent-workflow"))
    features_dir: Path = field(default_factory=lambda: Path("/home/user/workflow/.ai/project/features"))
    config_path: Path = field(default_factory=lambda: Path("/home/user/workflow/.ai/project/config.yaml"))
    context_path: Path = field(default_factory=lambda: Path("/home/user/workflow/.ai/project/context.md"))
    session_logs_dir: Path = field(default_factory=lambda: Path("/root/.claude/projects/-home-user-workflow"))
    snapshots_dir: Path = field(default_factory=lambda: Path("/home/user/workflow/.ai/snapshots"))
    plugin_json_path: Path = field(
        default_factory=lambda: Path("/home/user/workflow/plugins/multi-agent-workflow/.claude-plugin/plugin.json")
    )
    agents_dir: Path = field(
        default_factory=lambda: Path("/home/user/workflow/plugins/multi-agent-workflow/agents")
    )
    skills_dir: Path = field(
        default_factory=lambda: Path("/home/user/workflow/plugins/multi-agent-workflow/skills")
    )
    commands_dir: Path = field(
        default_factory=lambda: Path("/home/user/workflow/plugins/multi-agent-workflow/commands/workflows")
    )
    host: str = "127.0.0.1"
    port: int = 8420
    debounce_ms: int = 500
