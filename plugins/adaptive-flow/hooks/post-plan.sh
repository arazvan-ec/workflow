#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────
# Hook: post-plan — Validates plan completeness after planner agent
# ─────────────────────────────────────────────────────────────────────
# Event: Stop (defined in af-planner.md frontmatter, auto-converted
#         to SubagentStop at runtime)
#
# Exit 0 = allow agent to finish
# Exit 2 = BLOCK agent from finishing (agent receives stdout as feedback
#           and must correct its output before trying to stop again)
# ─────────────────────────────────────────────────────────────────────

set -euo pipefail

# ── Read hook input from stdin ─────────────────────────────────────
INPUT=$(cat /dev/stdin 2>/dev/null || echo '{}')
CWD=$(echo "$INPUT" | jq -r '.cwd // "."' 2>/dev/null || echo ".")
cd "$CWD"

# Find the most recent openspec/changes/ directory
CHANGES_DIR="openspec/changes"
if [ ! -d "$CHANGES_DIR" ]; then
  echo "BLOCKED: No openspec/changes/ directory found. You must create plan artifacts in openspec/changes/<slug>/ before completing."
  exit 2
fi

# Get the most recently modified subdirectory
LATEST_SLUG=$(ls -t "$CHANGES_DIR" 2>/dev/null | head -1)
if [ -z "$LATEST_SLUG" ]; then
  echo "BLOCKED: No change directories found in openspec/changes/. Create a directory with your plan artifacts."
  exit 2
fi

SLUG_DIR="$CHANGES_DIR/$LATEST_SLUG"
ISSUES=""

# ── Check for plan-and-tasks.md (gravity 2) ─────────────────────────
if [ -f "$SLUG_DIR/plan-and-tasks.md" ]; then
  if ! grep -q "Acceptance Criteria" "$SLUG_DIR/plan-and-tasks.md"; then
    ISSUES="${ISSUES}MISSING: plan-and-tasks.md lacks 'Acceptance Criteria' section. Add testable acceptance criteria.\n"
  fi

  if [ -n "$ISSUES" ]; then
    echo -e "BLOCKED: Plan validation failed.\n$ISSUES\nFix the issues above before completing."
    exit 2
  fi

  echo "Post-plan validation passed. Plan found in $SLUG_DIR/plan-and-tasks.md"
  exit 0
fi

# ── Check for spec.md (gravity 3-4) ─────────────────────────────────
if [ ! -f "$SLUG_DIR/spec.md" ] && [ ! -f "$SLUG_DIR/design.md" ] && [ ! -f "$SLUG_DIR/tasks.md" ]; then
  echo "BLOCKED: No plan artifacts found in $SLUG_DIR. Expected spec.md + design.md + tasks.md (Gravity 3-4) or plan-and-tasks.md (Gravity 2)."
  exit 2
fi

if [ -f "$SLUG_DIR/spec.md" ]; then
  if ! grep -qi "acceptance criteria\|acceptance criterion" "$SLUG_DIR/spec.md"; then
    ISSUES="${ISSUES}MISSING: spec.md lacks acceptance criteria. Add a section with testable criteria.\n"
  fi
else
  ISSUES="${ISSUES}MISSING: spec.md not found in $SLUG_DIR. Create it with problem statement and acceptance criteria.\n"
fi

if [ -f "$SLUG_DIR/design.md" ]; then
  if ! grep -qi "SOLID\|solid" "$SLUG_DIR/design.md"; then
    ISSUES="${ISSUES}MISSING: design.md lacks SOLID analysis section. Add SOLID verdicts for each component.\n"
  fi
else
  ISSUES="${ISSUES}MISSING: design.md not found in $SLUG_DIR. Create it with architecture and SOLID analysis.\n"
fi

if [ ! -f "$SLUG_DIR/tasks.md" ]; then
  ISSUES="${ISSUES}MISSING: tasks.md not found in $SLUG_DIR. Create it with ordered task list.\n"
fi

# ── Final verdict ──────────────────────────────────────────────────
if [ -n "$ISSUES" ]; then
  echo -e "BLOCKED: Plan validation failed.\n$ISSUES\nFix the issues above before completing."
  exit 2
fi

echo "Post-plan validation passed. All artifacts found in $SLUG_DIR"
exit 0
