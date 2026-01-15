#!/bin/bash

# workflow.sh - Script maestro para gestionar workflows de Claude Code en paralelo
#
# Uso:
#   workflow.sh <command> [options]
#
# Comandos:
#   consult                           - Ejecuta consultoría interactiva para sugerir workflow
#   start <feature> <workflow> [-x]   - Inicia todos los roles en Tilix (usa -x para auto-ejecutar)
#   role <role> <feature> [workflow]  - Inicia Claude Code como un rol específico
#   validate [feature]                - Valida workflow(s)
#   sync <feature>                    - Sincroniza con Git (pull)
#   commit <role> <feature> <msg>     - Commit y push cambios
#   help                              - Muestra esta ayuda

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Functions
info() { echo -e "${BLUE}ℹ${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }
error() { echo -e "${RED}✗${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; }
title() { echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; echo -e "${MAGENTA}$1${NC}"; echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; }

# Show usage
usage() {
    echo -e "${CYAN}Claude Code Workflow Manager${NC}"
    echo ""
    echo "Usage: workflow.sh <command> [options]"
    echo ""
    echo "Commands:"
    echo ""
    echo "  ${GREEN}consult${NC}"
    echo "    Ejecuta consultoría interactiva para sugerir el workflow óptimo"
    echo "    Example: workflow.sh consult"
    echo ""
    echo "  ${GREEN}start${NC} <feature> <workflow> [-x|--execute]"
    echo "    Inicia todos los roles en Tilix (2x2 grid: Planner, Backend, Frontend, QA)"
    echo "    Options:"
    echo "      -x, --execute    Auto-ejecuta Claude Code en cada pane"
    echo "    Examples:"
    echo "      workflow.sh start user-auth default"
    echo "      workflow.sh start user-auth default --execute"
    echo ""
    echo "  ${GREEN}role${NC} <role-name> <feature> [workflow]"
    echo "    Inicia Claude Code como un rol específico en la terminal actual"
    echo "    Roles: planner, backend, frontend, qa"
    echo "    Examples:"
    echo "      workflow.sh role planner user-auth"
    echo "      workflow.sh role backend user-auth default"
    echo ""
    echo "  ${GREEN}validate${NC} [feature]"
    echo "    Valida workflow(s)"
    echo "    Examples:"
    echo "      workflow.sh validate              # Valida todos"
    echo "      workflow.sh validate user-auth    # Valida uno específico"
    echo ""
    echo "  ${GREEN}sync${NC} <feature>"
    echo "    Sincroniza con Git (pull) para obtener cambios de otros roles"
    echo "    Example: workflow.sh sync user-auth"
    echo ""
    echo "  ${GREEN}commit${NC} <role> <feature> <message>"
    echo "    Commit y push cambios con formato correcto"
    echo "    Example: workflow.sh commit backend user-auth \"Add User entity\""
    echo ""
    echo "  ${GREEN}help${NC}"
    echo "    Muestra esta ayuda"
    echo ""
    exit 0
}

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Command dispatcher
COMMAND="${1:-help}"

case "$COMMAND" in
    consult)
        title "📋 CONSULTORÍA INTERACTIVA"
        echo ""
        python3 "$SCRIPT_DIR/suggest_workflow.py"
        ;;

    start)
        FEATURE_ID="${2:-}"
        WORKFLOW="${3:-default}"
        AUTO_EXECUTE=""

        if [ -z "$FEATURE_ID" ]; then
            error "Feature ID requerido"
            echo "Usage: workflow.sh start <feature> <workflow> [-x]"
            exit 1
        fi

        # Check for --execute flag
        for arg in "$@"; do
            case $arg in
                -x|--execute)
                    AUTO_EXECUTE="--execute"
                    ;;
            esac
        done

        title "🚀 INICIANDO WORKFLOW: $FEATURE_ID"
        echo ""
        info "Workflow: $WORKFLOW"
        if [ -n "$AUTO_EXECUTE" ]; then
            success "Modo: Auto-ejecutar (Claude Code se iniciará automáticamente)"
        else
            info "Modo: Manual (se mostrarán instrucciones)"
        fi
        echo ""

        # Check if in Tilix
        if [ -z "$TILIX_ID" ]; then
            error "Debes ejecutar este comando desde Tilix"
            echo ""
            echo "Alternativas:"
            echo "  1. Abre Tilix y ejecuta: workflow.sh start $FEATURE_ID $WORKFLOW $AUTO_EXECUTE"
            echo "  2. Usa: workflow.sh role <role-name> $FEATURE_ID"
            exit 1
        fi

        exec "$SCRIPT_DIR/tilix_start.sh" "$FEATURE_ID" "$WORKFLOW" $AUTO_EXECUTE
        ;;

    role)
        ROLE_NAME="${2:-}"
        FEATURE_ID="${3:-}"
        WORKFLOW="${4:-default}"

        if [ -z "$ROLE_NAME" ] || [ -z "$FEATURE_ID" ]; then
            error "Rol y Feature ID requeridos"
            echo "Usage: workflow.sh role <role-name> <feature> [workflow]"
            echo "Roles: planner, backend, frontend, qa"
            exit 1
        fi

        # Validate role
        case "$ROLE_NAME" in
            planner|backend|frontend|qa)
                ;;
            *)
                error "Rol inválido: $ROLE_NAME"
                echo "Roles válidos: planner, backend, frontend, qa"
                exit 1
                ;;
        esac

        title "🎭 INICIANDO ROL: ${ROLE_NAME^^}"
        echo ""
        info "Feature: $FEATURE_ID"
        info "Workflow: $WORKFLOW"
        echo ""

        # Create role-specific prompt
        TEMP_DIR="/tmp/claude-workflow-$$"
        mkdir -p "$TEMP_DIR"

        case "$ROLE_NAME" in
            planner)
                cat > "$TEMP_DIR/prompt.txt" << EOF
I am the PLANNER for feature $FEATURE_ID.

Please:
1. Read .ai/roles/planner.md (my role - includes Pairing Patterns!)
2. Read all rules (.ai/projects/PROJECT_X/rules/global_rules.md, ddd_rules.md, project_specific.md)
3. Read .ai/projects/PROJECT_X/workflows/${WORKFLOW}.yaml
4. Follow the planning stage instructions from workflow YAML
5. Create FEATURE_${FEATURE_ID}.md with COMPLETE API specifications
6. Create 30_tasks.md with specific tasks for each role
7. Update 50_state.md when done

Remember: You are a senior architect. Provide COMPLETE specifications so engineers don't need to guess!

Start now.
EOF
                ;;

            backend)
                cat > "$TEMP_DIR/prompt.txt" << EOF
I am the BACKEND ENGINEER for feature $FEATURE_ID.

Please:
1. Run: ./.ai/scripts/git_sync.sh $FEATURE_ID (pull latest changes)
2. Read .ai/roles/backend.md (my role - includes Pairing Patterns!)
3. Read all rules (.ai/projects/PROJECT_X/rules/global_rules.md, ddd_rules.md, project_specific.md)
4. Read FEATURE_${FEATURE_ID}.md and 30_tasks.md (from planner)
5. Read .ai/projects/PROJECT_X/workflows/${WORKFLOW}.yaml
6. Check .ai/projects/PROJECT_X/features/${FEATURE_ID}/50_state.md (planner section) - ensure it's COMPLETED
7. FIND reference code in ./backend/src/ before starting
8. Implement backend with CHECKPOINTS (stop and verify at each)
9. Update 50_state.md (backend section) as you progress
10. Commit after EACH checkpoint: ./.ai/scripts/git_commit_push.sh backend $FEATURE_ID "message"

Remember: You are a 10x engineer. Reference existing code, use checkpoints, verify everything!

Start when planner is COMPLETED.
EOF
                ;;

            frontend)
                cat > "$TEMP_DIR/prompt.txt" << EOF
I am the FRONTEND ENGINEER for feature $FEATURE_ID.

Please:
1. Run: ./.ai/scripts/git_sync.sh $FEATURE_ID (pull latest changes)
2. Read .ai/roles/frontend.md (my role - includes Pairing Patterns!)
3. Read all rules (.ai/projects/PROJECT_X/rules/global_rules.md, project_specific.md)
4. Read FEATURE_${FEATURE_ID}.md and 30_tasks.md (from planner)
5. Read .ai/projects/PROJECT_X/workflows/${WORKFLOW}.yaml
6. Check .ai/projects/PROJECT_X/features/${FEATURE_ID}/50_state.md:
   - Planner section - ensure it's COMPLETED
   - Backend section - check if API is ready
7. FIND reference components in ./frontend1/src/ before starting
8. If backend NOT ready: mock API and set status to WAITING_API
9. Implement UI with VISUAL VERIFICATION at each checkpoint
10. Test responsive design (375px, 768px, 1024px)
11. Run Lighthouse audit (must be > 90)
12. Update 50_state.md (frontend section) as you progress
13. Commit after EACH checkpoint: ./.ai/scripts/git_commit_push.sh frontend $FEATURE_ID "message"

Remember: You are a 10x UI engineer. Show screenshots, test in browser, verify accessibility!

Start when planner is COMPLETED. You can work in parallel with backend.
EOF
                ;;

            qa)
                cat > "$TEMP_DIR/prompt.txt" << EOF
I am the QA/REVIEWER for feature $FEATURE_ID.

Please:
1. Run: ./.ai/scripts/git_sync.sh $FEATURE_ID (pull latest changes)
2. Read .ai/roles/qa.md (my role - includes Pairing Patterns!)
3. Read all rules (.ai/projects/PROJECT_X/rules/global_rules.md, ddd_rules.md, project_specific.md)
4. Read FEATURE_${FEATURE_ID}.md (acceptance criteria)
5. Read .ai/projects/PROJECT_X/workflows/${WORKFLOW}.yaml
6. Check .ai/projects/PROJECT_X/features/${FEATURE_ID}/50_state.md:
   - Backend section - ensure it's COMPLETED
   - Frontend section - ensure it's COMPLETED
7. Execute SYSTEMATIC TESTING (5 phases):
   Phase 1: API Testing (curl commands with responses)
   Phase 2: UI Testing (screenshots at each step)
   Phase 3: Automated Test Execution (show results)
   Phase 4: Code Quality Review (DDD compliance)
   Phase 5: Acceptance Criteria Validation (with evidence)
8. Create qa_report_${FEATURE_ID}.md with COMPLETE findings
9. Update 50_state.md (qa section): APPROVED or REJECTED
10. Commit: ./.ai/scripts/git_commit_push.sh qa $FEATURE_ID "QA review: APPROVED/REJECTED"

Remember: You are a senior quality gate. Provide EVIDENCE (screenshots, logs, test results) for everything!

Start when backend and frontend are COMPLETED.
EOF
                ;;
        esac

        # Show header
        clear
        echo -e "${CYAN}╔═══════════════════════════════════════════════════╗${NC}"
        echo -e "${CYAN}║${NC}  ${GREEN}${ROLE_NAME^^}${NC} - Feature: $FEATURE_ID"
        echo -e "${CYAN}╚═══════════════════════════════════════════════════╝${NC}"
        echo ""
        info "Starting Claude Code with role-specific prompt..."
        echo ""

        # Start Claude with the prompt
        cat "$TEMP_DIR/prompt.txt" | claude

        # Cleanup
        rm -rf "$TEMP_DIR"
        ;;

    validate)
        FEATURE_ID="${2:-}"

        title "✅ VALIDANDO WORKFLOW"
        echo ""

        if [ -n "$FEATURE_ID" ]; then
            info "Validando feature: $FEATURE_ID"
            python3 "$SCRIPT_DIR/validate_workflow.py" "$FEATURE_ID"
        else
            info "Validando todos los features"
            python3 "$SCRIPT_DIR/validate_workflow.py"
        fi
        ;;

    sync)
        FEATURE_ID="${2:-}"

        if [ -z "$FEATURE_ID" ]; then
            error "Feature ID requerido"
            echo "Usage: workflow.sh sync <feature>"
            exit 1
        fi

        title "🔄 SINCRONIZANDO CON GIT"
        echo ""
        info "Feature: $FEATURE_ID"

        exec "$SCRIPT_DIR/git_sync.sh" "$FEATURE_ID"
        ;;

    commit)
        ROLE="${2:-}"
        FEATURE_ID="${3:-}"
        MESSAGE="${4:-}"

        if [ -z "$ROLE" ] || [ -z "$FEATURE_ID" ] || [ -z "$MESSAGE" ]; then
            error "Rol, Feature ID y mensaje requeridos"
            echo "Usage: workflow.sh commit <role> <feature> <message>"
            echo "Example: workflow.sh commit backend user-auth \"Add User entity\""
            exit 1
        fi

        title "💾 COMMIT Y PUSH"
        echo ""
        info "Rol: $ROLE"
        info "Feature: $FEATURE_ID"
        info "Mensaje: $MESSAGE"

        exec "$SCRIPT_DIR/git_commit_push.sh" "$ROLE" "$FEATURE_ID" "$MESSAGE"
        ;;

    help|--help|-h)
        usage
        ;;

    *)
        error "Comando desconocido: $COMMAND"
        echo ""
        echo "Usa: workflow.sh help"
        exit 1
        ;;
esac
