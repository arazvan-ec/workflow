"""Parser for 30_tasks_*.md task files."""
from __future__ import annotations

import re
from domain.entities import Task


def parse_task_file(content: str, feature_id: str) -> list[Task]:
    tasks = []

    # Pattern 1: "### Task X.Y: Title" or "## TX: Title" with checkbox items
    task_heading_pattern = r"(?:^#{2,3}\s+(?:Task\s+)?([A-Z]{2,3}-?\d+(?:\.\d+)?):?\s+(.+))$"

    for match in re.finditer(task_heading_pattern, content, re.MULTILINE):
        task_id = match.group(1).strip()
        title = match.group(2).strip()

        # Look at status after heading
        start = match.end()
        next_heading = re.search(r"^#{2,3}\s+", content[start:], re.MULTILINE)
        section_end = start + next_heading.start() if next_heading else len(content)
        section = content[start:section_end]

        done = False
        status_match = re.search(r"\*\*Status\*\*:\s*(\w+)", section)
        if status_match:
            done = status_match.group(1).upper() == "COMPLETED"

        priority = None
        prio_match = re.search(r"\*\*Priority\*\*:\s*(\w+)", section)
        if prio_match:
            priority = prio_match.group(1)

        deps = []
        dep_match = re.search(r"\*\*Depends on\*\*:\s*(.+)", section)
        if dep_match:
            dep_val = dep_match.group(1).strip()
            if dep_val.lower() != "none":
                deps = [d.strip() for d in dep_val.split(",")]

        tasks.append(Task(
            id=task_id,
            title=title,
            done=done,
            priority=priority,
            depends_on=deps,
            feature_id=feature_id,
        ))

    # Pattern 2: Checkbox tasks "- [x] BE-001: Title"
    if not tasks:
        checkbox_pattern = r"- \[([ x])\]\s*((?:[A-Z]{2,3}-\d+):?\s*.+)"
        for match in re.finditer(checkbox_pattern, content, re.IGNORECASE):
            is_done = match.group(1).lower() == "x"
            text = match.group(2).strip()

            id_match = re.match(r"([A-Z]{2,3}-\d+):?\s*(.*)", text)
            if id_match:
                task_id = id_match.group(1)
                title = id_match.group(2).strip()
            else:
                task_id = f"T-{len(tasks) + 1:03d}"
                title = text

            tasks.append(Task(
                id=task_id,
                title=title,
                done=is_done,
                feature_id=feature_id,
            ))

    return tasks
