#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────
# Hook: pre-commit — Validates code quality before committing
# ─────────────────────────────────────────────────────────────────────
# Event: PreToolUse (matcher: "Bash", defined in af-implementer.md)
#
# This hook fires on ALL Bash tool uses by the implementer agent.
# It filters to only act on git commit commands; all other commands
# are allowed through immediately.
#
# Exit 0 = allow the command
# Exit 2 = block the command (agent receives stdout as feedback)
# ─────────────────────────────────────────────────────────────────────

set -euo pipefail

# ── Read hook input from stdin ─────────────────────────────────────
INPUT=$(cat /dev/stdin 2>/dev/null || echo '{}')
CWD=$(echo "$INPUT" | jq -r '.cwd // "."' 2>/dev/null || echo ".")
TOOL_INPUT=$(echo "$INPUT" | jq -r '.tool_input.command // ""' 2>/dev/null || echo "")

# ── Only act on git commit commands ────────────────────────────────
if ! echo "$TOOL_INPUT" | grep -q "git commit"; then
  exit 0
fi

cd "$CWD"

STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM 2>/dev/null || true)

if [ -z "$STAGED_FILES" ]; then
  exit 0
fi

# ── Check for sensitive files ────────────────────────────────────────
SENSITIVE_PATTERNS=('.env' 'credentials' 'secret' '.key' '.pem' 'token')
for pattern in "${SENSITIVE_PATTERNS[@]}"; do
  MATCHES=$(echo "$STAGED_FILES" | grep -i "$pattern" || true)
  if [ -n "$MATCHES" ]; then
    echo "BLOCKED: Potentially sensitive file staged: $MATCHES"
    echo "If intentional, unstage and re-commit with explicit confirmation."
    exit 2
  fi
done

# ── Run tests if test runner is available ────────────────────────────
if [ -f "package.json" ]; then
  if command -v npm &>/dev/null && npm run test --if-present 2>/dev/null; then
    echo "Tests passed."
  else
    echo "WARNING: Tests may have failed. Review output above."
  fi
elif [ -f "Cargo.toml" ]; then
  if command -v cargo &>/dev/null; then
    cargo test --quiet 2>/dev/null || echo "WARNING: Cargo tests may have failed."
  fi
elif [ -f "pyproject.toml" ] || [ -f "setup.py" ]; then
  if command -v pytest &>/dev/null; then
    pytest --quiet 2>/dev/null || echo "WARNING: Pytest may have failed."
  fi
fi

# ── Run linter if available ──────────────────────────────────────────
if [ -f "package.json" ]; then
  if command -v npm &>/dev/null && npm run lint --if-present 2>/dev/null; then
    echo "Lint passed."
  fi
fi

echo "Pre-commit checks completed."
exit 0
