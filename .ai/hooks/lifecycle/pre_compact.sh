#!/usr/bin/env bash
# pre_compact.sh - SDK Lifecycle Hook: Pre Compact
# Saves context summary before compaction and preserves critical state information
#
# This hook is called by Claude Code before context window compaction.
# Environment variables provided by Claude Code:
#   SESSION_ID - Current session identifier
#   COMPACT_REASON - Reason for compaction (token_limit, user_request, etc.)
#   WORKING_DIR - Current working directory
#   CONTEXT_TOKENS - Approximate number of tokens being compacted (if available)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AI_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
PROJECT_DIR="${AI_DIR}/project"
LOG_DIR="${AI_DIR}/logs"
CONTEXT_DIR="${LOG_DIR}/context_snapshots"

# Timestamp
TIMESTAMP=$(date -Iseconds)

# Colors
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Ensure directories exist
mkdir -p "$CONTEXT_DIR"

# Find active feature
find_active_feature() {
    for state_file in "${PROJECT_DIR}/features"/*/50_state.md; do
        if [[ -f "$state_file" ]]; then
            if grep -q "IN_PROGRESS" "$state_file" 2>/dev/null; then
                dirname "$state_file" | xargs basename
                return 0
            fi
        fi
    done
    echo ""
}

# Find active role
find_active_role() {
    local feature_id="$1"
    local state_file="${PROJECT_DIR}/features/${feature_id}/50_state.md"

    if [[ ! -f "$state_file" ]]; then
        echo ""
        return
    fi

    for role in planner backend frontend qa; do
        local role_upper="${role^}"
        if awk "/^## ${role_upper}/,/^## [A-Z]/" "$state_file" 2>/dev/null | grep -q "IN_PROGRESS"; then
            echo "$role"
            return 0
        fi
    done
    echo ""
}

# Extract current task from state file
extract_current_task() {
    local feature_id="$1"
    local role="$2"
    local state_file="${PROJECT_DIR}/features/${feature_id}/50_state.md"

    if [[ ! -f "$state_file" ]]; then
        echo "Unknown"
        return
    fi

    local role_upper="${role^}"
    # Look for Next Action in role section
    awk "/^## ${role_upper}/,/^## [A-Z]/" "$state_file" 2>/dev/null | \
        grep -A 3 "### Next Action" | tail -n +2 | head -3 | \
        sed 's/^<!-- .* -->//' | tr '\n' ' ' | sed 's/^[[:space:]]*//'

    echo ""
}

# Extract key decisions from DECISIONS.md if exists
extract_key_decisions() {
    local feature_id="$1"
    local decisions_file="${PROJECT_DIR}/features/${feature_id}/DECISIONS.md"

    if [[ -f "$decisions_file" ]]; then
        # Get last 5 decisions
        grep -E "^(##|\*\*Decision|\*\*Rationale)" "$decisions_file" 2>/dev/null | tail -15
    else
        echo "No DECISIONS.md found"
    fi
}

# Get recent git activity
get_recent_git_activity() {
    git log --oneline -10 2>/dev/null || echo "Not a git repository"
}

# Get modified files in session
get_session_modifications() {
    local modifications_file="${LOG_DIR}/session_modifications.txt"
    if [[ -f "$modifications_file" ]]; then
        cat "$modifications_file" | sort -u
    else
        echo "No tracked modifications"
    fi
}

# Create context snapshot
create_context_snapshot() {
    local session_id="$1"
    local feature_id="$2"
    local role="$3"
    local compact_reason="$4"

    local snapshot_file="${CONTEXT_DIR}/context_${session_id}_$(date +%Y%m%d_%H%M%S).md"

    cat > "$snapshot_file" << EOF
# Context Snapshot Before Compaction

> This snapshot preserves critical context information before context window compaction.
> Claude Code can reference this to restore important state after compaction.

**Created**: ${TIMESTAMP}
**Session ID**: ${session_id}
**Compact Reason**: ${compact_reason}
**Feature**: ${feature_id:-None active}
**Role**: ${role:-None active}

---

## Critical State Information

### Active Work Context
- **Feature**: ${feature_id:-No active feature}
- **Role**: ${role:-No active role}
- **Current Task**: $(extract_current_task "$feature_id" "$role")

### Files Modified This Session
\`\`\`
$(get_session_modifications)
\`\`\`

### Recent Git Activity
\`\`\`
$(get_recent_git_activity)
\`\`\`

---

## Key Information to Preserve

### Current State Summary
EOF

    # Add current state file content if exists
    if [[ -n "$feature_id" ]]; then
        local state_file="${PROJECT_DIR}/features/${feature_id}/50_state.md"
        if [[ -f "$state_file" ]]; then
            echo "" >> "$snapshot_file"
            echo "#### Feature State (50_state.md)" >> "$snapshot_file"
            echo '```markdown' >> "$snapshot_file"
            # Extract just the status tables, not full content
            grep -E "^\| \*\*Status\*\*|^\| \*\*Completion|^## (Planner|Backend|Frontend|QA)" "$state_file" | head -20 >> "$snapshot_file"
            echo '```' >> "$snapshot_file"
        fi
    fi

    cat >> "$snapshot_file" << EOF

### Key Decisions Made
\`\`\`
$(extract_key_decisions "$feature_id")
\`\`\`

---

## Resume After Compaction

### Essential Context to Reload
1. **Project context**: .ai/project/context.md
2. **Feature state**: .ai/project/features/${feature_id:-FEATURE_X}/50_state.md
3. **This snapshot**: ${snapshot_file}

### Immediate Next Steps
After compaction, Claude should:
1. Read the project context file
2. Read the current feature state
3. Continue with the task that was in progress

---

## Technical Context

### Working Directory
$(pwd)

### Environment
- Date: $(date)
- Git Branch: $(git branch --show-current 2>/dev/null || echo "N/A")
- Git Status: $(git status --short 2>/dev/null | head -5 || echo "N/A")

---

**Snapshot Purpose**: This file allows Claude to quickly restore context after
the context window is compacted. It should be read early in the resumed conversation.
EOF

    echo "$snapshot_file"
}

# Main hook logic
main() {
    local session_id="${SESSION_ID:-$(date +%s)}"
    local compact_reason="${COMPACT_REASON:-token_limit}"
    local context_tokens="${CONTEXT_TOKENS:-unknown}"

    echo ""
    echo -e "${CYAN}=== Pre-Compaction Hook ===${NC}"
    echo -e "Session ID: ${session_id}"
    echo -e "Compact Reason: ${compact_reason}"
    echo -e "Context Tokens: ${context_tokens}"
    echo ""

    # Find active context
    local feature_id
    feature_id=$(find_active_feature)

    local role=""
    if [[ -n "$feature_id" ]]; then
        role=$(find_active_role "$feature_id")
    fi

    echo -e "${BLUE}Saving context summary...${NC}"

    # Create context snapshot
    local snapshot_file
    snapshot_file=$(create_context_snapshot "$session_id" "$feature_id" "$role" "$compact_reason")

    echo -e "${GREEN}Context snapshot saved:${NC} ${snapshot_file}"

    # Output summary for Claude to see before compaction
    echo ""
    echo -e "${YELLOW}=== CONTEXT SUMMARY FOR POST-COMPACTION ===${NC}"
    echo ""
    echo "After compaction, read these files to restore context:"
    echo "  1. ${snapshot_file}"
    if [[ -n "$feature_id" ]]; then
        echo "  2. ${PROJECT_DIR}/features/${feature_id}/50_state.md"
    fi
    echo "  3. ${PROJECT_DIR}/context.md"
    echo ""

    if [[ -n "$feature_id" && -n "$role" ]]; then
        echo -e "${BLUE}Current Work:${NC}"
        echo "  Feature: ${feature_id}"
        echo "  Role: ${role}"
        echo "  Task: $(extract_current_task "$feature_id" "$role")"
    fi

    echo ""
    echo -e "${CYAN}=== Pre-Compaction Complete ===${NC}"
    echo ""

    exit 0
}

# Run main if not being sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
