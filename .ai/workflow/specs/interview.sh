#!/usr/bin/env bash
# Spec Interview - Guided spec creation through questions
# Feature: workflow-improvements-2026 | Task: BE-016

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="${SCRIPT_DIR}/templates"
WORKFLOW_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_DIR="$(dirname "$WORKFLOW_DIR")/project"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Interview state
declare -A RESPONSES

# Ask a question and store response
# @param $1 key - Response key
# @param $2 question - Question text
# @param $3 default - Default value (optional)
# @param $4 validation - Validation type (optional: required, kebab, choice:a,b,c)
_ask() {
    local key="$1"
    local question="$2"
    local default="${3:-}"
    local validation="${4:-}"

    echo ""
    echo -e "${CYAN}${question}${NC}"

    if [[ -n "$default" ]]; then
        echo -e "${YELLOW}Default: ${default}${NC}"
    fi

    if [[ "$validation" == choice:* ]]; then
        local choices="${validation#choice:}"
        echo -e "${YELLOW}Options: ${choices}${NC}"
    fi

    local response
    read -r -p "> " response

    # Use default if empty
    if [[ -z "$response" && -n "$default" ]]; then
        response="$default"
    fi

    # Validate
    if [[ "$validation" == "required" && -z "$response" ]]; then
        echo -e "${RED}This field is required${NC}"
        _ask "$key" "$question" "$default" "$validation"
        return
    fi

    if [[ "$validation" == "kebab" ]]; then
        # Convert to kebab-case
        response=$(echo "$response" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-')
    fi

    if [[ "$validation" == choice:* ]]; then
        local choices="${validation#choice:}"
        if ! echo ",$choices," | grep -q ",$response,"; then
            echo -e "${RED}Invalid choice. Options: ${choices}${NC}"
            _ask "$key" "$question" "$default" "$validation"
            return
        fi
    fi

    RESPONSES["$key"]="$response"
    echo -e "${GREEN}Saved: ${response}${NC}"
}

# Ask for multiple items (comma-separated)
# @param $1 key - Response key
# @param $2 question - Question text
_ask_list() {
    local key="$1"
    local question="$2"

    echo ""
    echo -e "${CYAN}${question}${NC}"
    echo -e "${YELLOW}(Enter comma-separated values, or one per line. Empty line to finish)${NC}"

    local items=()
    local line

    while true; do
        read -r -p "> " line
        if [[ -z "$line" ]]; then
            break
        fi

        # Split by comma
        IFS=',' read -ra parts <<< "$line"
        for part in "${parts[@]}"; do
            part=$(echo "$part" | xargs)  # Trim whitespace
            if [[ -n "$part" ]]; then
                items+=("$part")
            fi
        done
    done

    RESPONSES["$key"]="${items[*]}"
    echo -e "${GREEN}Saved ${#items[@]} items${NC}"
}

# Display interview header
_header() {
    clear 2>/dev/null || true
    echo -e "${BOLD}${BLUE}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║           FEATURE SPEC INTERVIEW                           ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
}

# Run feature spec interview
# @param $1 output_path - Optional output path
# @return string - Path to generated spec
interview_feature() {
    local output_path="${1:-}"

    _header
    echo -e "This interview will guide you through creating a feature specification."
    echo -e "Press Enter to use default values, or type your answer."
    echo ""

    # Basic info
    echo -e "${BOLD}== Basic Information ==${NC}"
    _ask "feature_id" "What is the feature ID? (kebab-case identifier)" "" "kebab"
    _ask "feature_name" "What is the feature name? (human-readable)" "" "required"
    _ask "priority" "What is the priority?" "medium" "choice:critical,high,medium,low"

    # Objective
    echo ""
    echo -e "${BOLD}== Objective ==${NC}"
    _ask "summary" "Briefly describe what this feature does:" "" "required"
    _ask "business_value" "What is the business value? (optional)"

    # Requirements
    echo ""
    echo -e "${BOLD}== Requirements ==${NC}"
    _ask_list "requirements" "List the main functional requirements:"
    _ask_list "nfrs" "Any non-functional requirements? (performance, security, etc.)"

    # Tasks
    echo ""
    echo -e "${BOLD}== Tasks ==${NC}"
    _ask_list "backend_tasks" "List backend tasks (if any):"
    _ask_list "frontend_tasks" "List frontend tasks (if any):"
    _ask_list "qa_tasks" "List QA tasks (if any):"

    # Effort
    echo ""
    echo -e "${BOLD}== Planning ==${NC}"
    _ask "effort" "Estimated effort?" "1-2 weeks"

    # Generate spec
    echo ""
    echo -e "${BOLD}== Generating Spec ==${NC}"

    # Determine output path
    if [[ -z "$output_path" ]]; then
        local feature_id="${RESPONSES[feature_id]}"
        output_path="${PROJECT_DIR}/features/${feature_id}/spec.yaml"
    fi

    # Create directory
    mkdir -p "$(dirname "$output_path")"

    # Generate YAML
    _generate_feature_spec > "$output_path"

    echo -e "${GREEN}Spec generated: ${output_path}${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Review and edit: ${output_path}"
    echo "  2. Validate: /workflows:validate ${output_path}"
    echo "  3. Start planning: /workflows:plan ${RESPONSES[feature_id]}"

    echo "$output_path"
}

# Generate feature spec YAML from responses
_generate_feature_spec() {
    local feature_id="${RESPONSES[feature_id]}"
    local feature_name="${RESPONSES[feature_name]}"
    local priority="${RESPONSES[priority]}"
    local summary="${RESPONSES[summary]}"
    local business_value="${RESPONSES[business_value]:-}"
    local effort="${RESPONSES[effort]}"
    local requirements="${RESPONSES[requirements]:-}"
    local nfrs="${RESPONSES[nfrs]:-}"
    local backend_tasks="${RESPONSES[backend_tasks]:-}"
    local frontend_tasks="${RESPONSES[frontend_tasks]:-}"
    local qa_tasks="${RESPONSES[qa_tasks]:-}"

    local today
    today=$(date +%Y-%m-%d)

    cat << EOF
# Feature Specification
# Generated by interview on ${today}

version: "1.0"

feature:
  id: "${feature_id}"
  name: "${feature_name}"
  priority: ${priority}
  status: planning

metadata:
  created: "${today}"
  author: planner
  estimated_effort: "${effort}"

objective:
  summary: |
    ${summary}
EOF

    if [[ -n "$business_value" ]]; then
        cat << EOF

  business_value: |
    ${business_value}
EOF
    fi

    # Generate requirements
    cat << EOF

requirements:
  functional:
EOF

    local req_num=100
    for req in $requirements; do
        ((req_num++))
        cat << EOF
    - id: FR-${req_num}
      title: "${req}"
      description: |
        ${req}
      priority: ${priority}
      acceptance_criteria:
        - "TODO: Define acceptance criteria"
      test_coverage: recommended

EOF
    done

    # NFRs
    if [[ -n "$nfrs" ]]; then
        cat << EOF
  non_functional:
EOF
        local nfr_num=0
        for nfr in $nfrs; do
            ((nfr_num++))
            cat << EOF
    - id: NFR-00${nfr_num}
      type: performance
      requirement: "${nfr}"

EOF
        done
    fi

    # Tasks
    cat << EOF

tasks:
EOF

    # Backend tasks
    if [[ -n "$backend_tasks" ]]; then
        cat << EOF
  backend:
EOF
        local be_num=0
        for task in $backend_tasks; do
            ((be_num++))
            local task_id
            printf -v task_id "BE-%03d" "$be_num"
            cat << EOF
    - id: ${task_id}
      title: "${task}"
      methodology: TDD
      max_iterations: 10
      acceptance_criteria:
        - "TODO: Define acceptance criteria"
      done_when: "TODO: Define completion criteria"

EOF
        done
    fi

    # Frontend tasks
    if [[ -n "$frontend_tasks" ]]; then
        cat << EOF
  frontend:
EOF
        local fe_num=0
        for task in $frontend_tasks; do
            ((fe_num++))
            local task_id
            printf -v task_id "FE-%03d" "$fe_num"
            cat << EOF
    - id: ${task_id}
      title: "${task}"
      methodology: TDD
      max_iterations: 10
      acceptance_criteria:
        - "TODO: Define acceptance criteria"
      done_when: "TODO: Define completion criteria"

EOF
        done
    fi

    # QA tasks
    if [[ -n "$qa_tasks" ]]; then
        cat << EOF
  qa:
EOF
        local qa_num=0
        for task in $qa_tasks; do
            ((qa_num++))
            local task_id
            printf -v task_id "QA-%03d" "$qa_num"
            cat << EOF
    - id: ${task_id}
      title: "${task}"
      methodology: standard
      max_iterations: 5
      acceptance_criteria:
        - "TODO: Define acceptance criteria"
      done_when: "TODO: Define completion criteria"

EOF
        done
    fi

    cat << EOF

phases:
  - name: "Phase 1: Implementation"
    duration: "${effort}"
    deliverables:
      - "Core functionality"
      - "Tests"
      - "Documentation"
EOF
}

# Quick interview (minimal questions)
# @param $1 feature_id - Feature ID
# @param $2 description - Brief description
# @return string - Path to generated spec
interview_quick() {
    local feature_id="${1:?Feature ID required}"
    local description="${2:-New feature}"

    # Auto-fill responses
    RESPONSES["feature_id"]="$feature_id"
    RESPONSES["feature_name"]=$(echo "$feature_id" | tr '-' ' ' | sed 's/.*/\L&/; s/[a-z]*/\u&/g')
    RESPONSES["priority"]="medium"
    RESPONSES["summary"]="$description"
    RESPONSES["effort"]="1-2 weeks"
    RESPONSES["requirements"]=""
    RESPONSES["nfrs"]=""
    RESPONSES["backend_tasks"]=""
    RESPONSES["frontend_tasks"]=""
    RESPONSES["qa_tasks"]=""

    local output_path="${PROJECT_DIR}/features/${feature_id}/spec.yaml"
    mkdir -p "$(dirname "$output_path")"

    _generate_feature_spec > "$output_path"

    echo -e "${GREEN}Quick spec generated: ${output_path}${NC}"
    echo "$output_path"
}

# Interview for API contract
interview_api() {
    local output_path="${1:-}"

    _header
    echo -e "This interview will guide you through creating an API contract."
    echo ""

    echo -e "${BOLD}== API Information ==${NC}"
    _ask "api_name" "API name:" "" "required"
    _ask "api_description" "Brief description:"
    _ask "base_path" "Base path:" "/api/v1"
    _ask "auth_type" "Authentication type:" "bearer" "choice:bearer,basic,api_key,none"

    echo ""
    echo -e "${BOLD}== Endpoints ==${NC}"
    _ask_list "endpoints" "List the endpoints (e.g., 'GET /users', 'POST /users'):"

    # Generate output path
    if [[ -z "$output_path" ]]; then
        local api_name="${RESPONSES[api_name]}"
        local api_id
        api_id=$(echo "$api_name" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
        output_path="${PROJECT_DIR}/contracts/${api_id}.yaml"
    fi

    mkdir -p "$(dirname "$output_path")"

    # Generate API contract
    _generate_api_contract > "$output_path"

    echo -e "${GREEN}API contract generated: ${output_path}${NC}"
    echo "$output_path"
}

# Generate API contract YAML
_generate_api_contract() {
    local api_name="${RESPONSES[api_name]}"
    local api_description="${RESPONSES[api_description]:-}"
    local base_path="${RESPONSES[base_path]}"
    local auth_type="${RESPONSES[auth_type]}"
    local endpoints="${RESPONSES[endpoints]:-}"

    cat << EOF
# API Contract
# Generated by interview

version: "1.0"

api:
  name: "${api_name}"
  description: "${api_description}"
  base_path: "${base_path}"
  version: "1.0.0"

  auth:
    type: ${auth_type}
    required: $([ "$auth_type" != "none" ] && echo "true" || echo "false")

  endpoints:
EOF

    for endpoint in $endpoints; do
        local method path
        method=$(echo "$endpoint" | awk '{print $1}')
        path=$(echo "$endpoint" | awk '{print $2}')

        cat << EOF
    - path: "${path}"
      method: ${method}
      summary: "TODO: Add summary"
      auth_required: true
      responses:
        "200":
          description: "Success"
        "400":
          description: "Bad request"
        "401":
          description: "Unauthorized"
        "500":
          description: "Server error"

EOF
    done
}

# Display interview summary
interview_summary() {
    echo ""
    echo "=== Interview Summary ==="
    echo ""

    for key in "${!RESPONSES[@]}"; do
        echo "  ${key}: ${RESPONSES[$key]}"
    done
}

# Usage information
usage() {
    cat << EOF
Spec Interview - Guided spec creation through questions

Usage:
  source interview.sh

Functions:
  interview_feature [output_path]  Interactive feature spec creation
  interview_api [output_path]      Interactive API contract creation
  interview_quick <id> [desc]      Quick spec with minimal questions
  interview_summary                Show collected responses

Examples:
  # Full interactive feature interview
  interview_feature

  # Quick feature spec
  interview_quick "user-auth" "User authentication feature"

  # API contract interview
  interview_api

  # Custom output path
  interview_feature "my-spec.yaml"

Templates: ${TEMPLATE_DIR}
Output directory: ${PROJECT_DIR}/features/
EOF
}

# If script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-}" in
        --help|-h)
            usage
            ;;
        feature)
            interview_feature "${2:-}"
            ;;
        api)
            interview_api "${2:-}"
            ;;
        quick)
            interview_quick "${2:-}" "${3:-}"
            ;;
        summary)
            interview_summary
            ;;
        *)
            # Default: feature interview
            interview_feature "${1:-}"
            ;;
    esac
fi
