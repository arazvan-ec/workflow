"""Parser for plugin.json and agent/skill/command markdown files."""
from __future__ import annotations

import json
import re
from pathlib import Path
from domain.entities import Agent, Skill, Command


def parse_plugin_json(content: str) -> dict:
    try:
        return json.loads(content)
    except json.JSONDecodeError:
        return {}


def parse_agent_file(path: Path) -> Agent:
    content = path.read_text(encoding="utf-8", errors="replace")
    name = path.stem
    category = path.parent.name

    desc = ""
    # Try frontmatter
    if content.startswith("---"):
        end = content.find("---", 3)
        if end > 0:
            frontmatter = content[3:end]
            m = re.search(r"description:\s*(.+)", frontmatter)
            if m:
                desc = m.group(1).strip().strip('"').strip("'")

    # Fallback: first paragraph after heading
    if not desc:
        m = re.search(r"^#\s+.+\n+(.+?)(?:\n\n|\n#)", content, re.MULTILINE)
        if m:
            desc = m.group(1).strip()

    return Agent(name=name, category=category, description=desc, file_path=str(path))


def parse_skill_file(path: Path) -> Skill:
    content = path.read_text(encoding="utf-8", errors="replace")
    name = path.parent.name if path.name == "SKILL.md" else path.stem

    desc = ""
    if content.startswith("---"):
        end = content.find("---", 3)
        if end > 0:
            frontmatter = content[3:end]
            m = re.search(r"description:\s*(.+)", frontmatter)
            if m:
                desc = m.group(1).strip().strip('"').strip("'")

    if not desc:
        m = re.search(r"^#\s+.+\n+(.+?)(?:\n\n|\n#)", content, re.MULTILINE)
        if m:
            desc = m.group(1).strip()

    return Skill(name=name, description=desc, file_path=str(path))


def parse_command_file(path: Path) -> Command:
    content = path.read_text(encoding="utf-8", errors="replace")
    name = path.stem

    desc = ""
    arg_hint = None

    if content.startswith("---"):
        end = content.find("---", 3)
        if end > 0:
            frontmatter = content[3:end]
            m = re.search(r"description:\s*(.+)", frontmatter)
            if m:
                desc = m.group(1).strip().strip('"').strip("'")
            m = re.search(r"argument_hint:\s*(.+)", frontmatter)
            if m:
                arg_hint = m.group(1).strip().strip('"').strip("'")

    if not desc:
        m = re.search(r"^#\s+.+\n+(.+?)(?:\n\n|\n#)", content, re.MULTILINE)
        if m:
            desc = m.group(1).strip()

    return Command(name=name, description=desc, argument_hint=arg_hint, file_path=str(path))
