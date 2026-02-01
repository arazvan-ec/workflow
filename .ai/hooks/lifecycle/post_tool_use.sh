#!/usr/bin/env bash
# post_tool_use.sh - SDK Lifecycle Hook: Post Tool Use
# Auto-updates state files after tool completion and creates audit trail
#
# This hook is called by Claude Code after each tool execution.
# Environment variables provided by Claude Code:
#   TOOL_NAME - Name of the tool that was invoked
#   TOOL_INPUT - JSON string of tool input parameters
#   TOOL_RESULT - Result/output of the tool execution
#   TOOL_SUCCESS - "true" or "false" indicating success
#   SESSION_ID - Current session identifier
#   WORKING_DIR - Current working directory

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AI_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
PROJECT_DIR="${AI_DIR}/project"
LOG_DIR="${AI_DIR}/logs"
AUDIT_LOG="${LOG_DIR}/audit_$(date +%Y%m%d).log"

# Ensure directories exist
mkdir -p "$LOG_DIR"

# Timestamp
TIMESTAMP=$(date -Iseconds)

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Parse file path from tool input
extract_file_path() {
    local input="$1"
    if command -v jq &> /dev/null; then
        echo "$input" | jq -r '.file_path // .path // empty' 2>/dev/null || echo ""
    else
        echo "$input" | grep -oP '"file_path"\s*:\s*"[^"]*"' | cut -d'"' -f4 || echo ""
    fi
}

# Detect which feature the file belongs to
detect_feature() {
    local filepath="$1"

    # Check if file is within a feature directory
    if [[ "$filepath" == *"/features/"* ]]; then
        # Extract feature ID from path
        echo "$filepath" | sed -n 's|.*/features/\([^/]*\)/.*|\1|p'
    else
        # Try to find active feature from state files
        local active_feature=""
        for state_file in "${PROJECT_DIR}/features"/*/50_state.md; do
            if [[ -f "$state_file" ]]; then
                # Check if any role is IN_PROGRESS
                if grep -q "IN_PROGRESS" "$state_file" 2>/dev/null; then
                    active_feature=$(dirname "$state_file" | xargs basename)
                    break
                fi
            fi
        done
        echo "$active_feature"
    fi
}

# Update 50_state.md with tool activity
update_state_file() {
    local feature_id="$1"
    local tool_name="$2"
    local filepath="$3"
    local success="$4"

    local state_file="${PROJECT_DIR}/features/${feature_id}/50_state.md"

    if [[ ! -f "$state_file" ]]; then
        return 0  # No state file to update
    fi

    # Update Last Updated timestamp
    if grep -q "^\*\*Last Updated\*\*:" "$state_file"; then
        sed -i "s/^\*\*Last Updated\*\*:.*/\*\*Last Updated\*\*: $(date -Iseconds)/" "$state_file"
    fi

    # If file was modified, add to artifacts list (if not already there)
    if [[ -n "$filepath" && "$success" == "true" ]]; then
        local rel_path="${filepath#$(pwd)/}"

        # Check which role section to update based on file type
        local role_section=""
        case "$rel_path" in
            *test*|*Test*|*spec*|*Spec*)
                role_section="QA"
                ;;
            *component*|*Component*|*.tsx|*.vue|*frontend*|*ui/*)
                role_section="Frontend"
                ;;
            *controller*|*service*|*repository*|*domain*|*.php|*backend*|*api/*)
                role_section="Backend"
                ;;
            *plan*|*architect*|*design*|*contract*)
                role_section="Planner"
                ;;
        esac

        # Log file modification to audit log
        echo "[${TIMESTAMP}] feature=${feature_id} role=${role_section:-unknown} file=${rel_path}" >> "$AUDIT_LOG"
    fi
}

# Create audit trail entry
create_audit_entry() {
    local tool_name="$1"
    local filepath="$2"
    local success="$3"
    local session_id="$4"

    local status
    if [[ "$success" == "true" ]]; then
        status="SUCCESS"
    else
        status="FAILED"
    fi

    cat >> "$AUDIT_LOG" << EOF
---
timestamp: ${TIMESTAMP}
session: ${session_id}
tool: ${tool_name}
file: ${filepath:-N/A}
status: ${status}
---
EOF
}

# Track file modifications for session summary
track_modification() {
    local filepath="$1"
    local tool_name="$2"

    local session_file="${LOG_DIR}/session_modifications.txt"

    if [[ -n "$filepath" ]]; then
        # Add to session modifications list (unique entries)
        if ! grep -q "^${filepath}$" "$session_file" 2>/dev/null; then
            echo "$filepath" >> "$session_file"
        fi
    fi
}

# Main hook logic
main() {
    local tool_name="${TOOL_NAME:-unknown}"
    local tool_input="${TOOL_INPUT:-{}}"
    local tool_success="${TOOL_SUCCESS:-true}"
    local session_id="${SESSION_ID:-$(date +%s)}"

    # Extract file path
    local filepath
    filepath=$(extract_file_path "$tool_input")

    # Only process file-modifying tools
    case "$tool_name" in
        Edit|Write|NotebookEdit)
            if [[ -n "$filepath" ]]; then
                # Detect feature
                local feature_id
                feature_id=$(detect_feature "$filepath")

                # Update state file if feature detected
                if [[ -n "$feature_id" ]]; then
                    update_state_file "$feature_id" "$tool_name" "$filepath" "$tool_success"
                fi

                # Track modification
                track_modification "$filepath" "$tool_name"

                # Create audit entry
                create_audit_entry "$tool_name" "$filepath" "$tool_success" "$session_id"

                # Output info
                if [[ "$tool_success" == "true" ]]; then
                    echo -e "${GREEN}[Audit]${NC} Logged: $tool_name on $filepath"
                fi
            fi
            ;;
        Bash)
            # Log bash commands for audit
            create_audit_entry "$tool_name" "bash_command" "$tool_success" "$session_id"
            ;;
    esac

    exit 0
}

# Run main if not being sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
