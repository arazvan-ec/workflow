"""Parser for Claude Code session JSONL log files."""
from __future__ import annotations

import json
from pathlib import Path
from domain.entities import Session, ToolCallSummary


def parse_session_file(path: Path) -> Session | None:
    session_id = path.stem
    session = Session(session_id=session_id)

    timestamps = []
    tool_counts: dict[str, int] = {}
    first_user_msg = None

    try:
        with open(path, "r", encoding="utf-8", errors="replace") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    entry = json.loads(line)
                except json.JSONDecodeError:
                    continue

                entry_type = entry.get("type", "")

                if entry_type == "user":
                    session.user_message_count += 1
                    session.message_count += 1

                    if first_user_msg is None:
                        first_user_msg = entry

                    if not session.session_id or session.session_id == path.stem:
                        sid = entry.get("sessionId", "")
                        if sid:
                            session.session_id = sid

                    session.slug = entry.get("slug", session.slug) or session.slug
                    session.git_branch = entry.get("gitBranch", session.git_branch) or session.git_branch
                    session.cwd = entry.get("cwd", session.cwd) or session.cwd
                    session.permission_mode = entry.get("permissionMode", session.permission_mode) or session.permission_mode

                    ts = entry.get("timestamp")
                    if ts:
                        timestamps.append(ts)

                elif entry_type == "assistant":
                    session.assistant_message_count += 1
                    session.message_count += 1

                    msg = entry.get("message", {})
                    session.model = msg.get("model", session.model) or session.model

                    usage = msg.get("usage", {})
                    session.total_input_tokens += usage.get("input_tokens", 0)
                    session.total_output_tokens += usage.get("output_tokens", 0)

                    # Count tool calls
                    for block in msg.get("content", []):
                        if isinstance(block, dict) and block.get("type") == "tool_use":
                            tool_name = block.get("name", "unknown")
                            tool_counts[tool_name] = tool_counts.get(tool_name, 0) + 1

    except (OSError, PermissionError):
        return None

    if timestamps:
        timestamps.sort()
        session.started_at = timestamps[0]
        session.last_activity_at = timestamps[-1]

        # Compute duration
        try:
            from datetime import datetime
            start = datetime.fromisoformat(timestamps[0].replace("Z", "+00:00"))
            end = datetime.fromisoformat(timestamps[-1].replace("Z", "+00:00"))
            session.duration_seconds = int((end - start).total_seconds())
        except (ValueError, TypeError):
            pass

    session.tool_calls = [
        ToolCallSummary(tool=name, count=count)
        for name, count in sorted(tool_counts.items(), key=lambda x: -x[1])
    ]

    if session.message_count == 0:
        return None

    return session
