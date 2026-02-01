#!/usr/bin/env bash
# stop.sh - SDK Lifecycle Hook: Stop
# Auto-checkpoint when agent stops and verify no BLOCKED status left unhandled
#
# This hook is called by Claude Code when the agent session ends.
# Environment variables provided by Claude Code:
#   SESSION_ID - Current session identifier
#   STOP_REASON - Reason for stopping (user_request, token_limit, error, etc.)
#   WORKING_DIR - Current working directory
#   SESSION_DURATION - Duration of session in seconds (if available)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AI_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
PROJECT_DIR="${AI_DIR}/project"
LOG_DIR="${AI_DIR}/logs"
CHECKPOINT_SCRIPT="${AI_DIR}/extensions/scripts/create_checkpoint.sh"

# Timestamp
TIMESTAMP=$(date -Iseconds)
SESSION_LOG="${LOG_DIR}/session_$(date +%Y%m%d).log"

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# Find active feature (one with IN_PROGRESS status)
find_active_feature() {
    local active_feature=""

    for state_file in "${PROJECT_DIR}/features"/*/50_state.md; do
        if [[ -f "$state_file" ]]; then
            if grep -q "IN_PROGRESS" "$state_file" 2>/dev/null; then
                active_feature=$(dirname "$state_file" | xargs basename)
                echo "$active_feature"
                return 0
            fi
        fi
    done

    echo ""
}

# Find active role within a feature
find_active_role() {
    local feature_id="$1"
    local state_file="${PROJECT_DIR}/features/${feature_id}/50_state.md"

    if [[ ! -f "$state_file" ]]; then
        echo ""
        return
    fi

    # Check each role section for IN_PROGRESS
    for role in planner backend frontend qa; do
        local role_upper="${role^}"  # Capitalize first letter
        # Look for Status line within role section
        if awk "/^## ${role_upper}/,/^## [A-Z]/" "$state_file" | grep -q "IN_PROGRESS"; then
            echo "$role"
            return 0
        fi
    done

    echo ""
}

# Check for BLOCKED status in any feature
check_blocked_status() {
    local blocked_features=()

    for state_file in "${PROJECT_DIR}/features"/*/50_state.md; do
        if [[ -f "$state_file" ]]; then
            if grep -q "BLOCKED" "$state_file" 2>/dev/null; then
                local feature_id
                feature_id=$(dirname "$state_file" | xargs basename)
                blocked_features+=("$feature_id")
            fi
        fi
    done

    if [[ ${#blocked_features[@]} -gt 0 ]]; then
        echo ""
        echo -e "${RED}=== WARNING: BLOCKED STATUS DETECTED ===${NC}"
        echo -e "${YELLOW}The following features have unhandled BLOCKED status:${NC}"
        for feature in "${blocked_features[@]}"; do
            echo -e "  - ${RED}$feature${NC}"

            # Show what's blocked
            local state_file="${PROJECT_DIR}/features/${feature}/50_state.md"
            echo "    Blocked items:"
            grep -A 2 "BLOCKED" "$state_file" | head -5 | sed 's/^/      /'
        done
        echo ""
        echo -e "${YELLOW}Action required: Address blockers before next session.${NC}"
        echo ""

        return 1
    fi

    return 0
}

# Create auto-checkpoint
create_auto_checkpoint() {
    local feature_id="$1"
    local role="$2"
    local stop_reason="$3"

    local checkpoint_dir="${PROJECT_DIR}/features/${feature_id}/checkpoints"
    mkdir -p "$checkpoint_dir"

    local checkpoint_file="checkpoint_${role}_auto_$(date +%Y%m%d_%H%M%S).md"

    # Gather session modifications if tracked
    local modifications_file="${LOG_DIR}/session_modifications.txt"
    local files_modified=""
    if [[ -f "$modifications_file" ]]; then
        files_modified=$(cat "$modifications_file" | sort -u | head -20)
        # Clear the file for next session
        rm -f "$modifications_file"
    fi

    # Generate auto-checkpoint
    cat > "${checkpoint_dir}/${checkpoint_file}" << EOF
# Auto-Checkpoint: ${role^^} - ${feature_id}

> This checkpoint was automatically created when the agent session ended.
> Use this to resume work in a new session.

**Created**: ${TIMESTAMP}
**Role**: ${role}
**Feature**: ${feature_id}
**Stop Reason**: ${stop_reason}
**Auto-Generated**: true

---

## Session Summary

### Stop Reason
${stop_reason}

### Files Modified This Session
${files_modified:-No files tracked}

---

## Context for Resume

### State at Stop
This checkpoint was automatically created. Please review:
1. The 50_state.md file for current status
2. Recent git commits for actual changes
3. Any error logs in .ai/logs/

---

## Resume Instructions

### 1. Read These Files First
\`\`\`
.ai/project/context.md                          # Project overview
.ai/project/features/${feature_id}/50_state.md  # Current state
\`\`\`

### 2. Verify State
Check that the previous session's changes were properly saved:
\`\`\`bash
git status
git log --oneline -5
\`\`\`

### 3. Continue Work
Resume from where the session ended.

---

## Automatic Verification

EOF

    # Add blocker check results
    if check_blocked_status >> "${checkpoint_dir}/${checkpoint_file}" 2>&1; then
        echo "### Blocker Status" >> "${checkpoint_dir}/${checkpoint_file}"
        echo "No unhandled blockers detected." >> "${checkpoint_dir}/${checkpoint_file}"
    fi

    echo -e "${GREEN}Auto-checkpoint created:${NC} ${checkpoint_dir}/${checkpoint_file}"
}

# Log session end
log_session_end() {
    local session_id="$1"
    local stop_reason="$2"
    local feature_id="$3"
    local role="$4"

    cat >> "$SESSION_LOG" << EOF
---
timestamp: ${TIMESTAMP}
session_id: ${session_id}
stop_reason: ${stop_reason}
feature: ${feature_id:-none}
role: ${role:-none}
---
EOF
}

# Main hook logic
main() {
    local session_id="${SESSION_ID:-$(date +%s)}"
    local stop_reason="${STOP_REASON:-user_request}"

    echo ""
    echo -e "${CYAN}=== Agent Session Ending ===${NC}"
    echo -e "Session ID: ${session_id}"
    echo -e "Stop Reason: ${stop_reason}"
    echo ""

    # Find active feature and role
    local feature_id
    feature_id=$(find_active_feature)

    local role=""
    if [[ -n "$feature_id" ]]; then
        role=$(find_active_role "$feature_id")
        echo -e "Active Feature: ${BLUE}${feature_id}${NC}"
        echo -e "Active Role: ${BLUE}${role:-unknown}${NC}"
    fi

    # Create auto-checkpoint if we have active work
    if [[ -n "$feature_id" && -n "$role" ]]; then
        echo ""
        echo -e "${BLUE}Creating auto-checkpoint...${NC}"
        create_auto_checkpoint "$feature_id" "$role" "$stop_reason"
    fi

    # Check for unhandled blocked status
    echo ""
    echo -e "${BLUE}Checking for unhandled blockers...${NC}"
    if ! check_blocked_status; then
        echo -e "${RED}Please address blockers before starting next session.${NC}"
    else
        echo -e "${GREEN}No unhandled blockers.${NC}"
    fi

    # Log session end
    log_session_end "$session_id" "$stop_reason" "$feature_id" "$role"

    echo ""
    echo -e "${CYAN}=== Session Cleanup Complete ===${NC}"
    echo ""

    exit 0
}

# Run main if not being sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
