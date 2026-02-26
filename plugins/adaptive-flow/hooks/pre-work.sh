#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────
# Hook: pre-work — Verifies plan exists before implementation starts
# ─────────────────────────────────────────────────────────────────────
# Event: SubagentStart (matcher: "af-implementer")
# Registered in: settings.json (not in agent frontmatter — SubagentStart
#                is an external event, not an agent lifecycle event)
#
# SubagentStart hooks CANNOT block. Instead, they inject additionalContext
# into the subagent via JSON output on stdout.
#
# If no plan exists, the injected context tells the implementer to stop.
# ─────────────────────────────────────────────────────────────────────

set -euo pipefail

# ── Read hook input from stdin ─────────────────────────────────────
INPUT=$(cat /dev/stdin 2>/dev/null || echo '{}')
CWD=$(echo "$INPUT" | jq -r '.cwd // "."' 2>/dev/null || echo ".")
cd "$CWD"

CHANGES_DIR="openspec/changes"

# ── Check for plan existence ───────────────────────────────────────
if [ ! -d "$CHANGES_DIR" ]; then
  echo '{"hookSpecificOutput":{"hookEventName":"SubagentStart","additionalContext":"CRITICAL: No openspec/changes/ directory found. You MUST stop immediately and report that planning is required before implementation. Do not write any code."}}'
  exit 0
fi

LATEST_SLUG=$(ls -t "$CHANGES_DIR" 2>/dev/null | head -1)
if [ -z "$LATEST_SLUG" ]; then
  echo '{"hookSpecificOutput":{"hookEventName":"SubagentStart","additionalContext":"CRITICAL: No change directories found in openspec/changes/. You MUST stop immediately and report that planning is required before implementation. Do not write any code."}}'
  exit 0
fi

SLUG_DIR="$CHANGES_DIR/$LATEST_SLUG"

# Check for either plan-and-tasks.md (gravity 2) or tasks.md (gravity 3-4)
if [ -f "$SLUG_DIR/plan-and-tasks.md" ] || [ -f "$SLUG_DIR/tasks.md" ]; then
  PLAN_FILE="tasks.md"
  [ -f "$SLUG_DIR/plan-and-tasks.md" ] && PLAN_FILE="plan-and-tasks.md"
  echo "{\"hookSpecificOutput\":{\"hookEventName\":\"SubagentStart\",\"additionalContext\":\"Plan found at $SLUG_DIR/$PLAN_FILE. Proceed with implementation.\"}}"
  exit 0
fi

echo "{\"hookSpecificOutput\":{\"hookEventName\":\"SubagentStart\",\"additionalContext\":\"CRITICAL: No plan found in $SLUG_DIR. Neither tasks.md nor plan-and-tasks.md exists. You MUST stop immediately and report that planning is required before implementation.\"}}"
exit 0
