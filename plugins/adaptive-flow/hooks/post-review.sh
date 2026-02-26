#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────
# Hook: post-review — Validates review completeness after reviewer agent
# ─────────────────────────────────────────────────────────────────────
# Event: Stop (defined in af-reviewer.md frontmatter, auto-converted
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
LAST_MESSAGE=$(echo "$INPUT" | jq -r '.last_assistant_message // ""' 2>/dev/null || echo "")
cd "$CWD"

CHANGES_DIR="openspec/changes"
ISSUES=""

# ── First, check the agent's last message for verdict ──────────────
if [ -n "$LAST_MESSAGE" ]; then
  if echo "$LAST_MESSAGE" | grep -qi "APPROVED\|REJECTED"; then
    VERDICT=$(echo "$LAST_MESSAGE" | grep -oi "APPROVED\|REJECTED" | head -1)
    echo "Review verdict found in agent output: $VERDICT"
  fi
fi

# ── Then, check for QA report on disk ─────────────────────────────
if [ ! -d "$CHANGES_DIR" ]; then
  echo "BLOCKED: No openspec/changes/ directory. You must write the QA report to openspec/changes/<slug>/ before completing."
  exit 2
fi

LATEST_SLUG=$(ls -t "$CHANGES_DIR" 2>/dev/null | head -1)
if [ -z "$LATEST_SLUG" ]; then
  echo "BLOCKED: No change directories found. Write the QA report to openspec/changes/<slug>/."
  exit 2
fi

SLUG_DIR="$CHANGES_DIR/$LATEST_SLUG"

# ── Look for QA report ───────────────────────────────────────────────
QA_REPORT=""
for pattern in "qa-report" "review" "QA"; do
  FOUND=$(find "$SLUG_DIR" -maxdepth 1 -name "${pattern}*" 2>/dev/null | head -1)
  if [ -n "$FOUND" ]; then
    QA_REPORT="$FOUND"
    break
  fi
done

if [ -z "$QA_REPORT" ]; then
  echo "BLOCKED: No QA report found in $SLUG_DIR. You must write a QA report file (e.g., qa-report.md) with a Verdict section before completing."
  exit 2
fi

# ── Check for verdict ────────────────────────────────────────────────
if ! grep -qi "APPROVED\|REJECTED" "$QA_REPORT"; then
  ISSUES="${ISSUES}MISSING: QA report lacks a verdict. Add '## Verdict: APPROVED' or '## Verdict: REJECTED'.\n"
fi

# ── Check for evidence ───────────────────────────────────────────────
if ! grep -qi "evidence\|verified\|PASS\|FAIL" "$QA_REPORT"; then
  ISSUES="${ISSUES}MISSING: QA report lacks evidence for criteria verification. Add PASS/FAIL status with evidence for each criterion.\n"
fi

# ── Final verdict ──────────────────────────────────────────────────
if [ -n "$ISSUES" ]; then
  echo -e "BLOCKED: Review validation failed.\n$ISSUES\nFix the issues above in the QA report before completing."
  exit 2
fi

VERDICT=$(grep -oi "APPROVED\|REJECTED" "$QA_REPORT" | head -1)
echo "Post-review validation passed. Verdict: $VERDICT"

if [ "$VERDICT" = "REJECTED" ]; then
  echo "NOTE: Review was REJECTED. The coordinator should trigger rework."
fi

exit 0
