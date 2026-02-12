"""Parser for config.yaml project configuration."""
from __future__ import annotations

import yaml
from domain.entities import ProjectConfig


def parse_config(content: str) -> ProjectConfig:
    try:
        data = yaml.safe_load(content) or {}
    except yaml.YAMLError:
        return ProjectConfig()

    project = data.get("project", {})
    backend = data.get("backend", {})
    workflow = data.get("workflow", {})
    git = data.get("git", {})

    return ProjectConfig(
        name=project.get("name", ""),
        project_type=project.get("type", ""),
        description=project.get("description", ""),
        backend_framework=backend.get("framework", ""),
        backend_language=backend.get("language", ""),
        backend_architecture=backend.get("architecture", ""),
        default_workflow=workflow.get("default", ""),
        git_main_branch=git.get("main_branch", ""),
        commit_style=git.get("commit_style", ""),
    )
