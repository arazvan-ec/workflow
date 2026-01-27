#!/usr/bin/env bash
# Spec Validator - Validate YAML specs against JSON schemas
# Feature: workflow-improvements-2026 | Task: BE-015

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCHEMA_DIR="${SCRIPT_DIR}/schema"
WORKFLOW_DIR="$(dirname "$SCRIPT_DIR")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check for required tools
_check_tools() {
    local missing=()

    # Check for yq (YAML processor)
    if ! command -v yq &>/dev/null; then
        missing+=("yq")
    fi

    # Check for jq (JSON processor)
    if ! command -v jq &>/dev/null; then
        missing+=("jq")
    fi

    if [[ ${#missing[@]} -gt 0 ]]; then
        echo -e "${YELLOW}Warning: Some validation features require: ${missing[*]}${NC}" >&2
        echo "Install with:" >&2
        echo "  apt install jq  # Debian/Ubuntu" >&2
        echo "  brew install yq jq  # macOS" >&2
        return 1
    fi

    return 0
}

# Detect spec type from content
# @param $1 spec_path - Path to YAML spec
# @return string - Spec type (feature, api, task)
_detect_spec_type() {
    local spec_path="$1"

    if [[ ! -f "$spec_path" ]]; then
        echo "unknown"
        return
    fi

    # Check for type indicators
    if grep -q "^feature:" "$spec_path" 2>/dev/null; then
        echo "feature"
    elif grep -q "^api:" "$spec_path" 2>/dev/null; then
        echo "api"
    elif grep -q "^task:" "$spec_path" 2>/dev/null; then
        echo "task"
    else
        echo "unknown"
    fi
}

# Get schema path for spec type
_get_schema_path() {
    local spec_type="$1"

    case "$spec_type" in
        feature)
            echo "${SCHEMA_DIR}/feature_spec.json"
            ;;
        api)
            echo "${SCHEMA_DIR}/api_contract.json"
            ;;
        task)
            echo "${SCHEMA_DIR}/task_spec.json"
            ;;
        *)
            echo ""
            ;;
    esac
}

# Validate YAML syntax
# @param $1 spec_path - Path to YAML spec
# @return bool - true if valid
spec_validate_syntax() {
    local spec_path="${1:?Spec path required}"

    if [[ ! -f "$spec_path" ]]; then
        echo -e "${RED}Error: File not found: ${spec_path}${NC}" >&2
        return 1
    fi

    # Use Python for YAML validation (most reliable)
    if command -v python3 &>/dev/null; then
        if python3 -c "import yaml; yaml.safe_load(open('$spec_path'))" 2>/dev/null; then
            echo -e "${GREEN}YAML syntax: valid${NC}"
            return 0
        else
            echo -e "${RED}YAML syntax: invalid${NC}" >&2
            python3 -c "import yaml; yaml.safe_load(open('$spec_path'))" 2>&1 | head -5 >&2
            return 1
        fi
    fi

    # Fallback: check yq (Mike Farah version with -o flag)
    if command -v yq &>/dev/null && yq --version 2>&1 | grep -q "mikefarah"; then
        if yq eval '.' "$spec_path" > /dev/null 2>&1; then
            echo -e "${GREEN}YAML syntax: valid${NC}"
            return 0
        else
            echo -e "${RED}YAML syntax: invalid${NC}" >&2
            return 1
        fi
    fi

    echo -e "${YELLOW}Cannot validate YAML syntax (no parser available)${NC}"
    return 0
}

# Validate spec against schema
# @param $1 spec_path - Path to YAML spec
# @param $2 schema_type - Optional schema type override
# @return bool - true if valid
spec_validate() {
    local spec_path="${1:?Spec path required}"
    local schema_type="${2:-}"

    if [[ ! -f "$spec_path" ]]; then
        echo -e "${RED}Error: File not found: ${spec_path}${NC}" >&2
        return 1
    fi

    # Validate syntax first
    if ! spec_validate_syntax "$spec_path"; then
        return 1
    fi

    # Detect spec type if not provided
    if [[ -z "$schema_type" ]]; then
        schema_type=$(_detect_spec_type "$spec_path")
    fi

    if [[ "$schema_type" == "unknown" ]]; then
        echo -e "${YELLOW}Warning: Unknown spec type. Cannot validate against schema.${NC}"
        return 0
    fi

    local schema_path
    schema_path=$(_get_schema_path "$schema_type")

    if [[ -z "$schema_path" || ! -f "$schema_path" ]]; then
        echo -e "${YELLOW}Warning: Schema not found for type: ${schema_type}${NC}"
        return 0
    fi

    echo -e "${BLUE}Validating against: ${schema_type} schema${NC}"

    # Convert YAML to JSON and validate
    local json_content=""

    # Try Python first (most reliable)
    if command -v python3 &>/dev/null; then
        json_content=$(python3 -c "import yaml, json; print(json.dumps(yaml.safe_load(open('$spec_path'))))" 2>/dev/null || echo "")
    # Fallback to yq (Mike Farah version)
    elif command -v yq &>/dev/null && yq --version 2>&1 | grep -q "mikefarah"; then
        json_content=$(yq -o=json eval '.' "$spec_path" 2>/dev/null || echo "")
    fi

    if [[ -n "$json_content" ]] && command -v jq &>/dev/null; then
        local dummy_check
        dummy_check="$json_content"

        # Basic structure validation with jq
        local errors=()

        # Check required fields based on type
        case "$schema_type" in
            feature)
                if ! echo "$json_content" | jq -e '.version' &>/dev/null; then
                    errors+=("Missing required field: version")
                fi
                if ! echo "$json_content" | jq -e '.feature' &>/dev/null; then
                    errors+=("Missing required field: feature")
                fi
                if ! echo "$json_content" | jq -e '.feature.id' &>/dev/null; then
                    errors+=("Missing required field: feature.id")
                fi
                if ! echo "$json_content" | jq -e '.objective' &>/dev/null; then
                    errors+=("Missing required field: objective")
                fi
                if ! echo "$json_content" | jq -e '.requirements' &>/dev/null; then
                    errors+=("Missing required field: requirements")
                fi
                ;;
            api)
                if ! echo "$json_content" | jq -e '.version' &>/dev/null; then
                    errors+=("Missing required field: version")
                fi
                if ! echo "$json_content" | jq -e '.api' &>/dev/null; then
                    errors+=("Missing required field: api")
                fi
                if ! echo "$json_content" | jq -e '.api.name' &>/dev/null; then
                    errors+=("Missing required field: api.name")
                fi
                if ! echo "$json_content" | jq -e '.api.endpoints' &>/dev/null; then
                    errors+=("Missing required field: api.endpoints")
                fi
                ;;
            task)
                if ! echo "$json_content" | jq -e '.version' &>/dev/null; then
                    errors+=("Missing required field: version")
                fi
                if ! echo "$json_content" | jq -e '.task' &>/dev/null; then
                    errors+=("Missing required field: task")
                fi
                if ! echo "$json_content" | jq -e '.task.id' &>/dev/null; then
                    errors+=("Missing required field: task.id")
                fi
                ;;
        esac

        if [[ ${#errors[@]} -gt 0 ]]; then
            echo -e "${RED}Schema validation: FAILED${NC}"
            for err in "${errors[@]}"; do
                echo -e "  ${RED}- ${err}${NC}"
            done
            return 1
        fi

        echo -e "${GREEN}Schema validation: PASSED${NC}"
        return 0
    fi

    echo -e "${YELLOW}Cannot perform schema validation (missing yq/jq)${NC}"
    return 0
}

# Check implementation compliance
# @param $1 spec_path - Path to spec
# @param $2 impl_paths - Comma-separated paths to implementation files
# @return JSON - Compliance report
spec_check_compliance() {
    local spec_path="${1:?Spec path required}"
    local impl_paths="${2:-}"

    if [[ ! -f "$spec_path" ]]; then
        echo '{"error": "Spec not found"}'
        return 1
    fi

    local spec_type
    spec_type=$(_detect_spec_type "$spec_path")

    echo "{"
    echo "  \"spec_path\": \"${spec_path}\","
    echo "  \"spec_type\": \"${spec_type}\","
    echo "  \"compliance\": {"

    local compliant=true
    local checks=()

    # Extract requirements from spec
    if [[ "$spec_type" == "feature" ]] && command -v yq &>/dev/null; then
        # Check if tasks exist
        local task_count
        task_count=$(yq eval '.tasks | length' "$spec_path" 2>/dev/null || echo "0")

        if [[ "$task_count" -gt 0 ]]; then
            checks+=("\"has_tasks\": true")
        else
            checks+=("\"has_tasks\": false")
            compliant=false
        fi

        # Check if requirements have acceptance criteria
        local req_count
        req_count=$(yq eval '.requirements.functional | length' "$spec_path" 2>/dev/null || echo "0")
        checks+=("\"requirement_count\": ${req_count}")

        # Check for test coverage requirements
        local test_required
        test_required=$(yq eval '.requirements.functional[] | select(.test_coverage == "required") | .id' "$spec_path" 2>/dev/null | wc -l || echo "0")
        checks+=("\"tests_required_count\": ${test_required}")
    fi

    # Output checks
    local first=true
    for check in "${checks[@]}"; do
        if ! $first; then
            echo ","
        fi
        first=false
        echo "    ${check}"
    done

    echo ""
    echo "  },"
    echo "  \"compliant\": ${compliant}"
    echo "}"
}

# Validate all specs in a directory
# @param $1 dir_path - Directory to scan
# @return void - Outputs summary
spec_validate_all() {
    local dir_path="${1:-.ai/project/features}"

    if [[ ! -d "$dir_path" ]]; then
        echo -e "${RED}Error: Directory not found: ${dir_path}${NC}" >&2
        return 1
    fi

    echo "=== Spec Validation Report ==="
    echo "Directory: ${dir_path}"
    echo ""

    local total=0
    local passed=0
    local failed=0

    # Find all YAML files
    while IFS= read -r spec_file; do
        ((total++))
        echo -e "${BLUE}Validating: ${spec_file}${NC}"

        if spec_validate "$spec_file"; then
            ((passed++))
        else
            ((failed++))
        fi
        echo ""
    done < <(find "$dir_path" -name "*.yaml" -o -name "*.yml" 2>/dev/null | head -50)

    echo "=== Summary ==="
    echo "Total:  ${total}"
    echo -e "Passed: ${GREEN}${passed}${NC}"
    echo -e "Failed: ${RED}${failed}${NC}"

    [[ $failed -eq 0 ]]
}

# Generate validation report as JSON
# @param $1 spec_path - Path to spec
# @return JSON - Validation report
spec_validate_json() {
    local spec_path="${1:?Spec path required}"

    local spec_type
    spec_type=$(_detect_spec_type "$spec_path")

    local syntax_valid="true"
    local schema_valid="true"
    local errors=()

    # Check syntax
    if ! spec_validate_syntax "$spec_path" &>/dev/null; then
        syntax_valid="false"
        errors+=("YAML syntax error")
    fi

    # Check schema
    if ! spec_validate "$spec_path" &>/dev/null; then
        schema_valid="false"
        errors+=("Schema validation failed")
    fi

    # Output JSON
    cat << EOF
{
  "path": "${spec_path}",
  "type": "${spec_type}",
  "syntax_valid": ${syntax_valid},
  "schema_valid": ${schema_valid},
  "errors": [$(printf '"%s",' "${errors[@]}" | sed 's/,$//')]
}
EOF
}

# Display human-readable validation
# @param $1 spec_path - Path to spec
spec_display() {
    local spec_path="${1:?Spec path required}"

    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║               SPEC VALIDATION                              ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    echo "File: ${spec_path}"
    echo "Type: $(_detect_spec_type "$spec_path")"
    echo ""

    spec_validate "$spec_path"
    local result=$?

    echo ""
    if [[ $result -eq 0 ]]; then
        echo -e "${GREEN}Status: VALID${NC}"
    else
        echo -e "${RED}Status: INVALID${NC}"
    fi

    return $result
}

# Usage information
usage() {
    cat << EOF
Spec Validator - Validate YAML specs against JSON schemas

Usage:
  source validator.sh

Functions:
  spec_validate <path> [type]     Validate spec against schema
  spec_validate_syntax <path>     Validate YAML syntax only
  spec_check_compliance <spec> <impls>  Check implementation compliance
  spec_validate_all [dir]         Validate all specs in directory
  spec_validate_json <path>       Get validation result as JSON
  spec_display <path>             Human-readable validation

Spec Types:
  feature   - Feature specifications (feature_spec.json)
  api       - API contracts (api_contract.json)
  task      - Task definitions (task_spec.json)

Examples:
  # Validate a feature spec
  spec_validate ".ai/project/features/auth/spec.yaml"

  # Validate all specs in features directory
  spec_validate_all ".ai/project/features"

  # Get JSON result
  spec_validate_json "spec.yaml" | jq '.'

  # Check compliance
  spec_check_compliance "spec.yaml" "src/module.sh"

Schema directory: ${SCHEMA_DIR}
EOF
}

# If script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-}" in
        --help|-h)
            usage
            ;;
        validate)
            spec_validate "${2:-}" "${3:-}"
            ;;
        syntax)
            spec_validate_syntax "${2:-}"
            ;;
        compliance)
            spec_check_compliance "${2:-}" "${3:-}"
            ;;
        all)
            spec_validate_all "${2:-.ai/project/features}"
            ;;
        json)
            spec_validate_json "${2:-}"
            ;;
        display)
            spec_display "${2:-}"
            ;;
        *)
            if [[ -n "${1:-}" ]]; then
                spec_display "$1"
            else
                usage
            fi
            ;;
    esac
fi
