"""Parser for 50_state.md files - handles both Format A (table) and Format B (bold fields)."""
from __future__ import annotations

import re
from domain.entities import (
    Feature, RoleProgress, RoleStatus, PhaseProgress, Decision,
)

ROLE_NAMES_MAP = {
    "planner": "planner",
    "planner / architect": "planner",
    "backend": "backend",
    "backend engineer": "backend",
    "frontend": "frontend",
    "frontend engineer": "frontend",
    "qa": "qa",
    "qa / reviewer": "qa",
}


def parse_state_file(content: str, feature_id: str) -> Feature:
    feature = Feature(id=feature_id, name=feature_id.replace("-", " ").title())

    _parse_overview(content, feature)

    role_sections = _split_role_sections(content)
    for raw_name, section_text in role_sections.items():
        role_key = ROLE_NAMES_MAP.get(raw_name.lower().strip(), raw_name.lower().strip())
        if role_key not in ("planner", "backend", "frontend", "qa"):
            continue
        rp = _parse_role_section(section_text, role_key)
        feature.roles[role_key] = rp

    feature.phases = _parse_phases(content)
    feature.decisions = _parse_decisions(content)
    feature.artifacts = _detect_artifacts(content)
    feature.blockers = _parse_blockers(content)

    # Override role progress from ASCII progress bars if available
    _apply_ascii_progress(content, feature)

    feature.compute_overall_progress()
    return feature


def _parse_overview(content: str, feature: Feature):
    m = re.search(r"\*\*Feature\*\*:\s*(.+)", content)
    if m:
        feature.name = m.group(1).strip()

    m = re.search(r"\*\*Workflow\*\*:\s*(.+)", content)
    if m:
        feature.workflow = m.group(1).strip().split("(")[0].strip()

    m = re.search(r"\*\*Created\*\*:\s*(.+)", content)
    if m:
        feature.created = m.group(1).strip()

    m = re.search(r"\*\*Last Updated\*\*:\s*(.+)", content)
    if m:
        feature.last_updated = m.group(1).strip()

    m = re.search(r"^(?:#[^#].*\n+)?\*\*Status\*\*:\s*(.+)", content, re.MULTILINE)
    if m:
        feature.overall_status = m.group(1).strip()


def _split_role_sections(content: str) -> dict[str, str]:
    pattern = r"^##\s+(.+?)$"
    matches = list(re.finditer(pattern, content, re.MULTILINE))
    sections = {}
    for i, match in enumerate(matches):
        heading = match.group(1).strip()
        start = match.end()
        end = matches[i + 1].start() if i + 1 < len(matches) else len(content)
        normalized = heading.lower().strip()
        if any(k in normalized for k in ("planner", "backend", "frontend", "qa")):
            sections[heading] = content[start:end]
    return sections


def _parse_role_section(text: str, role_key: str) -> RoleProgress:
    rp = RoleProgress(role=role_key)

    # Format A: table-based status
    table_status = re.search(r"\|\s*\*\*Status\*\*\s*\|\s*`?([A-Z_]+)`?\s*\|", text)
    # Format B: bold-based status
    bold_status = re.search(r"\*\*Status\*\*:\s*`?([A-Z_]+)`?", text)

    if table_status:
        rp.status = RoleStatus.from_str(table_status.group(1))
    elif bold_status:
        rp.status = RoleStatus.from_str(bold_status.group(1))

    # Completion signal
    cs = re.search(r"\*\*Completion Signal\*\*.*?`(true|false)`", text)
    if cs:
        rp.completion_signal = cs.group(1) == "true"

    # Started/Completed dates
    started = re.search(r"\*\*Started\*\*.*?\|\s*(.+?)\s*\|", text)
    if started and started.group(1).strip() != "-":
        rp.started = started.group(1).strip()

    completed = re.search(r"\*\*Completed\*\*.*?\|\s*(.+?)\s*\|", text)
    if completed and completed.group(1).strip() != "-":
        rp.completed = completed.group(1).strip()

    # Last Updated (Format B)
    updated = re.search(r"\*\*Last Updated\*\*:\s*(.+)", text)
    if updated:
        rp.started = updated.group(1).strip()

    # Depends on
    dep = re.search(r"\*\*Depends On\*\*.*?\|\s*(.+?)\s*\|", text)
    if dep and dep.group(1).strip() != "-":
        rp.depends_on = [d.strip() for d in dep.group(1).split(",")]

    # Current task (Format B)
    ct = re.search(r"\*\*Current Task\*\*:\s*(.+)", text)
    if ct:
        val = ct.group(1).strip()
        if val.lower() != "none" and "pending" not in val.lower():
            rp.current_task = val

    # Checkboxes - count completed vs total
    checked = len(re.findall(r"- \[x\]", text, re.IGNORECASE))
    unchecked = len(re.findall(r"- \[ \]", text))
    rp.checkpoints_done = checked
    rp.checkpoints_total = checked + unchecked

    # Completed tasks list (Format B)
    task_matches = re.findall(r"- \[x\]\s*((?:BE|FE|QA)-\d+):", text, re.IGNORECASE)
    rp.completed_tasks = task_matches

    # Notes
    notes_match = re.search(r"\*\*Notes\*\*:\s*\n((?:- .+\n)*)", text)
    if notes_match:
        rp.notes = [line.strip("- ").strip() for line in notes_match.group(1).strip().split("\n") if line.strip()]
    else:
        notes_section = re.search(r"### Notes\n(.+?)(?=\n###|\n---|\Z)", text, re.DOTALL)
        if notes_section:
            note_text = notes_section.group(1).strip()
            if note_text and "<!--" not in note_text:
                rp.notes = [note_text]

    # Blockers
    blockers_section = re.search(r"### Blockers\n(.+?)(?=\n###|\n---|\Z)", text, re.DOTALL)
    if blockers_section:
        blocker_text = blockers_section.group(1).strip()
        if blocker_text and "<!--" not in blocker_text:
            rp.blockers = [blocker_text]

    # Coverage
    cov_lines = re.search(r"\*\*Lines\*\*:\s*(.+)", text)
    if cov_lines:
        rp.coverage_lines = cov_lines.group(1).strip()
    cov_branches = re.search(r"\*\*Branches\*\*:\s*(.+)", text)
    if cov_branches:
        rp.coverage_branches = cov_branches.group(1).strip()

    # Artifacts
    artifacts_section = re.search(r"(?:### Artifacts Created|### Deliverables)\n((?:- .+\n)*)", text)
    if artifacts_section:
        rp.artifacts = [
            re.sub(r"- \[.\]\s*", "", line).strip()
            for line in artifacts_section.group(1).strip().split("\n")
            if line.strip() and "<!--" not in line
        ]

    rp.compute_progress()
    return rp


def _parse_phases(content: str) -> list[PhaseProgress]:
    phases = []
    # Look for Phase Progress table
    phase_pattern = r"\|\s*(.+?)\s*\|\s*(.+?)\s*\|\s*(.+?)\s*\|\s*(.+?)\s*\|"
    phase_section = re.search(r"(?:### Phase Progress|Phase Progress)(.*?)(?=\n---|\n##[^#]|\Z)", content, re.DOTALL)
    if not phase_section:
        return phases

    for match in re.finditer(phase_pattern, phase_section.group(1)):
        name = match.group(1).strip()
        if name in ("Phase", "---", "") or name.startswith("-"):
            continue
        status_or_desc = match.group(2).strip()
        col3 = match.group(3).strip()
        col4 = match.group(4).strip()

        phase = PhaseProgress(name=name)

        # Check for "Progress" column (format with Description | Status | Progress)
        pct_match = re.search(r"(\d+)%", col4)
        if pct_match:
            phase.progress_pct = float(pct_match.group(1))
            phase.status = col3.strip()
        else:
            phase.status = status_or_desc
            # Try to extract tasks done/total from "2/4" format or task range
            parts = col3.replace(" ", "")
            if "/" in parts:
                try:
                    done, total = parts.split("/")
                    phase.tasks_done = int(done)
                    phase.tasks_total = int(total)
                    phase.compute_progress()
                except ValueError:
                    pass

        phases.append(phase)

    return phases


def _parse_decisions(content: str) -> list[Decision]:
    decisions = []
    decision_section = re.search(r"## Decisions Made(.*?)(?=\n---|\n##[^#]|\Z)", content, re.DOTALL)
    if not decision_section:
        return decisions

    row_pattern = r"\|\s*(\d{4}-\d{2}-\d{2})\s*\|\s*(.+?)\s*\|\s*(.+?)\s*\|"
    for match in re.finditer(row_pattern, decision_section.group(1)):
        decisions.append(Decision(
            date=match.group(1),
            decision=match.group(2).strip(),
            rationale=match.group(3).strip(),
        ))
    return decisions


def _detect_artifacts(content: str) -> list[str]:
    artifacts = []
    doc_patterns = [
        "00_requirements_analysis.md",
        "10_architecture.md",
        "15_data_model.md",
        "20_api_contracts.md",
        "30_tasks_backend.md",
        "31_tasks_frontend.md",
        "32_tasks_qa.md",
        "35_dependencies.md",
    ]
    for doc in doc_patterns:
        if doc in content:
            artifacts.append(doc)
    return artifacts


def _apply_ascii_progress(content: str, feature: Feature):
    """Extract progress from ASCII progress bars like 'Backend:      [########  ]  80%'"""
    role_map = {
        "planning": "planner",
        "planner": "planner",
        "backend": "backend",
        "frontend": "frontend",
        "qa": "qa",
    }
    for match in re.finditer(r"(\w+):\s*\[.+?\]\s*(\d+)%", content):
        label = match.group(1).strip().lower()
        pct = float(match.group(2))
        role_key = role_map.get(label)
        if role_key and role_key in feature.roles:
            feature.roles[role_key].progress_pct = pct


def _parse_blockers(content: str) -> list[str]:
    blockers = []
    blocker_section = re.search(r"## Blockers\n+\*\*Current Blockers\*\*:\s*(.+)", content)
    if blocker_section:
        val = blocker_section.group(1).strip()
        if val.lower() != "none":
            blockers.append(val)
    return blockers
