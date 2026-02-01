#!/usr/bin/env bash
# pre_tool_use.sh - SDK Lifecycle Hook: Pre Tool Use
# Enforces trust model before file edits and logs all tool uses
#
# This hook is called by Claude Code before each tool execution.
# Environment variables provided by Claude Code:
#   TOOL_NAME - Name of the tool being invoked (e.g., Edit, Write, Bash)
#   TOOL_INPUT - JSON string of tool input parameters
#   SESSION_ID - Current session identifier
#   WORKING_DIR - Current working directory

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AI_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
LOG_DIR="${AI_DIR}/logs"
TRUST_EVALUATOR="${AI_DIR}/extensions/scripts/enforcement/trust_evaluator.sh"

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Timestamp for logging
TIMESTAMP=$(date -Iseconds)
LOG_FILE="${LOG_DIR}/tool_use_$(date +%Y%m%d).log"

# Low-trust paths that require pair review
LOW_TRUST_PATHS=(
    "auth/"
    "Auth/"
    "security/"
    "Security/"
    "payment/"
    "Payment/"
    "billing/"
    "checkout/"
    "session/"
    "credential/"
    "secret/"
    "migrations/"
    ".env"
    "*.pem"
    "*.key"
)

# Parse tool input to extract file path if present
extract_file_path() {
    local input="$1"
    # Try to extract file_path from JSON input
    if command -v jq &> /dev/null; then
        echo "$input" | jq -r '.file_path // .path // empty' 2>/dev/null || echo ""
    else
        # Fallback: grep for common path patterns
        echo "$input" | grep -oP '"file_path"\s*:\s*"[^"]*"' | cut -d'"' -f4 || echo ""
    fi
}

# Check if path matches low-trust patterns
is_low_trust_path() {
    local filepath="$1"

    for pattern in "${LOW_TRUST_PATHS[@]}"; do
        if [[ "$filepath" == *"$pattern"* ]]; then
            return 0  # true - is low trust
        fi
    done
    return 1  # false - not low trust
}

# Log tool use
log_tool_use() {
    local tool="$1"
    local filepath="$2"
    local trust_level="$3"
    local action="$4"

    echo "[${TIMESTAMP}] tool=${tool} file=${filepath:-N/A} trust=${trust_level} action=${action}" >> "$LOG_FILE"
}

# Main hook logic
main() {
    local tool_name="${TOOL_NAME:-unknown}"
    local tool_input="${TOOL_INPUT:-{}}"
    local session_id="${SESSION_ID:-unknown}"

    # Extract file path from tool input
    local filepath
    filepath=$(extract_file_path "$tool_input")

    # Determine trust level
    local trust_level="high"

    # Only check trust for file-modifying tools
    case "$tool_name" in
        Edit|Write|NotebookEdit)
            if [[ -n "$filepath" ]]; then
                # Use trust evaluator if available
                if [[ -f "$TRUST_EVALUATOR" ]]; then
                    source "$TRUST_EVALUATOR"
                    trust_level=$(trust_get_level "$filepath")
                elif is_low_trust_path "$filepath"; then
                    trust_level="low"
                fi

                # Enforce trust model for low-trust paths
                if [[ "$trust_level" == "low" ]]; then
                    echo ""
                    echo -e "${RED}=== TRUST ENFORCEMENT: LOW TRUST PATH ===${NC}"
                    echo -e "${YELLOW}File:${NC} $filepath"
                    echo -e "${YELLOW}Tool:${NC} $tool_name"
                    echo ""
                    echo -e "${RED}This file is in a low-trust path (auth/, security/, payment/).${NC}"
                    echo -e "${RED}Modifications require pair review with a human.${NC}"
                    echo ""
                    echo "Actions required:"
                    echo "  1. Document the change rationale in DECISIONS.md"
                    echo "  2. Request explicit human approval before proceeding"
                    echo "  3. Consider security implications"
                    echo ""

                    # Log the blocked attempt
                    log_tool_use "$tool_name" "$filepath" "$trust_level" "BLOCKED"

                    # Check for PAIR_REVIEW_APPROVED environment variable
                    if [[ "${PAIR_REVIEW_APPROVED:-}" != "true" ]]; then
                        echo -e "${RED}BLOCKED: Set PAIR_REVIEW_APPROVED=true after human review to proceed.${NC}"
                        exit 1
                    else
                        echo -e "${GREEN}Pair review approved. Proceeding with caution.${NC}"
                        log_tool_use "$tool_name" "$filepath" "$trust_level" "APPROVED_WITH_REVIEW"
                    fi
                fi
            fi
            ;;
        Bash)
            # Check for potentially dangerous commands
            if echo "$tool_input" | grep -qE "(rm -rf|chmod 777|curl.*\| bash|wget.*\| sh)"; then
                echo -e "${YELLOW}WARNING: Potentially dangerous command detected.${NC}"
                log_tool_use "$tool_name" "command" "low" "WARNING"
            fi
            ;;
    esac

    # Log all tool uses (successful ones)
    log_tool_use "$tool_name" "$filepath" "$trust_level" "ALLOWED"

    # Output trust info for context
    if [[ -n "$filepath" && "$trust_level" != "high" ]]; then
        echo -e "${BLUE}[Trust: ${trust_level}]${NC} $tool_name on $filepath"
    fi

    exit 0
}

# Run main if not being sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
