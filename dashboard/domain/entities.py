from __future__ import annotations
from dataclasses import dataclass, field
from datetime import datetime
from enum import Enum
from typing import Optional


class RoleStatus(str, Enum):
    PENDING = "PENDING"
    IN_PROGRESS = "IN_PROGRESS"
    BLOCKED = "BLOCKED"
    WAITING_API = "WAITING_API"
    COMPLETED = "COMPLETED"
    APPROVED = "APPROVED"
    REJECTED = "REJECTED"
    READY_FOR_REVIEW = "READY_FOR_REVIEW"
    UNKNOWN = "UNKNOWN"

    @classmethod
    def from_str(cls, value: str) -> RoleStatus:
        clean = value.strip().strip("`").upper().replace(" ", "_")
        try:
            return cls(clean)
        except ValueError:
            return cls.UNKNOWN


@dataclass
class RoleProgress:
    role: str
    status: RoleStatus = RoleStatus.PENDING
    completion_signal: Optional[bool] = None
    started: Optional[str] = None
    completed: Optional[str] = None
    depends_on: list[str] = field(default_factory=list)
    checkpoints_done: int = 0
    checkpoints_total: int = 0
    progress_pct: float = 0.0
    current_task: Optional[str] = None
    notes: list[str] = field(default_factory=list)
    blockers: list[str] = field(default_factory=list)
    artifacts: list[str] = field(default_factory=list)
    completed_tasks: list[str] = field(default_factory=list)
    coverage_lines: Optional[str] = None
    coverage_branches: Optional[str] = None

    def compute_progress(self):
        if self.status == RoleStatus.COMPLETED:
            self.progress_pct = 100.0
        elif self.checkpoints_total > 0:
            self.progress_pct = round((self.checkpoints_done / self.checkpoints_total) * 100, 1)


@dataclass
class PhaseProgress:
    name: str
    status: str = "PENDING"
    tasks_done: int = 0
    tasks_total: int = 0
    progress_pct: float = 0.0

    def compute_progress(self):
        if self.tasks_total > 0:
            self.progress_pct = round((self.tasks_done / self.tasks_total) * 100, 1)


@dataclass
class Decision:
    date: str
    decision: str
    rationale: str = ""


@dataclass
class Feature:
    id: str
    name: str
    workflow: str = "default"
    created: Optional[str] = None
    last_updated: Optional[str] = None
    overall_status: str = "PENDING"
    overall_progress_pct: float = 0.0
    roles: dict[str, RoleProgress] = field(default_factory=dict)
    phases: list[PhaseProgress] = field(default_factory=list)
    blockers: list[str] = field(default_factory=list)
    decisions: list[Decision] = field(default_factory=list)
    artifacts: list[str] = field(default_factory=list)

    def compute_overall_progress(self):
        if not self.roles:
            return
        total = sum(r.progress_pct for r in self.roles.values())
        self.overall_progress_pct = round(total / len(self.roles), 1)

        statuses = [r.status for r in self.roles.values()]
        active_statuses = {RoleStatus.IN_PROGRESS, RoleStatus.READY_FOR_REVIEW, RoleStatus.WAITING_API}
        if all(s in (RoleStatus.COMPLETED, RoleStatus.APPROVED) for s in statuses):
            self.overall_status = "COMPLETED"
        elif any(s == RoleStatus.BLOCKED for s in statuses):
            self.overall_status = "BLOCKED"
        elif any(s in active_statuses for s in statuses):
            self.overall_status = "IN_PROGRESS"
        elif self.overall_progress_pct > 0:
            self.overall_status = "IN_PROGRESS"
        else:
            self.overall_status = "PENDING"


@dataclass
class Task:
    id: str
    title: str
    done: bool = False
    phase: Optional[str] = None
    priority: Optional[str] = None
    depends_on: list[str] = field(default_factory=list)
    feature_id: str = ""


@dataclass
class ToolCallSummary:
    tool: str
    count: int = 0


@dataclass
class Session:
    session_id: str
    slug: str = ""
    git_branch: Optional[str] = None
    started_at: Optional[str] = None
    last_activity_at: Optional[str] = None
    duration_seconds: int = 0
    message_count: int = 0
    user_message_count: int = 0
    assistant_message_count: int = 0
    tool_calls: list[ToolCallSummary] = field(default_factory=list)
    model: Optional[str] = None
    permission_mode: Optional[str] = None
    cwd: str = ""
    total_input_tokens: int = 0
    total_output_tokens: int = 0


@dataclass
class Commit:
    hash: str
    short_hash: str
    message: str
    author: str
    date: str
    files_changed: int = 0
    insertions: int = 0
    deletions: int = 0


@dataclass
class Agent:
    name: str
    category: str
    description: str = ""
    file_path: str = ""


@dataclass
class Skill:
    name: str
    description: str = ""
    file_path: str = ""


@dataclass
class Command:
    name: str
    description: str = ""
    argument_hint: Optional[str] = None
    file_path: str = ""


@dataclass
class Snapshot:
    timestamp: str
    session_id: str = ""
    feature: str = ""
    stop_reason: str = ""
    directory: str = ""


@dataclass
class ProjectConfig:
    name: str = ""
    project_type: str = ""
    description: str = ""
    backend_framework: str = ""
    backend_language: str = ""
    backend_architecture: str = ""
    default_workflow: str = ""
    git_main_branch: str = ""
    commit_style: str = ""
