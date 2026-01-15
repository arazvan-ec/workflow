#!/bin/bash

# tilix_start.sh - Abre Claude Code en múltiples panes de Tilix según roles del workflow
#
# Uso:
#   ./.ai/scripts/tilix_start.sh [feature-id] [workflow] [--execute]
#
# Ejemplos:
#   ./.ai/scripts/tilix_start.sh my-feature default              # Solo crea panes
#   ./.ai/scripts/tilix_start.sh my-feature default --execute    # Ejecuta automáticamente
#   ./.ai/scripts/tilix_start.sh my-feature default -x           # Forma corta

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Functions
info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

success() {
    echo -e "${GREEN}✓${NC} $1"
}

error() {
    echo -e "${RED}✗${NC} $1"
}

warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Show usage
usage() {
    echo "Usage: $0 [feature-id] [workflow] [--execute|-x]"
    echo ""
    echo "Arguments:"
    echo "  feature-id    Feature identifier (default: FEATURE_X)"
    echo "  workflow      Workflow name (default: default)"
    echo "  --execute|-x  Execute Claude Code automatically in each pane"
    echo ""
    echo "Examples:"
    echo "  $0 my-feature default              # Create panes with instructions"
    echo "  $0 my-feature default --execute    # Execute Claude Code automatically"
    echo "  $0 user-auth ddd_parallel -x       # Short form"
    echo ""
    exit 1
}

# Check if running inside Tilix
if [ -z "$TILIX_ID" ]; then
    error "This script must be run from within Tilix terminal"
    echo ""
    echo "Please:"
    echo "1. Open Tilix"
    echo "2. Run this script again"
    exit 1
fi

# Parse arguments
FEATURE_ID="${1:-FEATURE_X}"
WORKFLOW="${2:-default}"
AUTO_EXECUTE=false

# Check for --execute flag
for arg in "$@"; do
    case $arg in
        --execute|-x)
            AUTO_EXECUTE=true
            shift
            ;;
        --help|-h)
            usage
            ;;
    esac
done

info "Starting Tilix workflow setup for feature: $FEATURE_ID"
info "Using workflow: $WORKFLOW"
if [ "$AUTO_EXECUTE" = true ]; then
    success "Auto-execute mode: ON (will start Claude Code automatically)"
else
    info "Auto-execute mode: OFF (will show instructions only)"
fi

# Verify workflow exists
WORKFLOW_FILE="./.ai/projects/PROJECT_X/workflows/${WORKFLOW}.yaml"
if [ ! -f "$WORKFLOW_FILE" ]; then
    error "Workflow file not found: $WORKFLOW_FILE"
    exit 1
fi

success "Workflow file found: $WORKFLOW_FILE"

# Create temporary directory for prompts
TEMP_DIR="/tmp/claude-workflow-$$"
mkdir -p "$TEMP_DIR"

# Define role prompts
cat > "$TEMP_DIR/planner_prompt.txt" << EOF
I am the PLANNER for feature $FEATURE_ID.

Please:
1. Read .ai/roles/planner.md (my role - includes Pairing Patterns!)
2. Read all rules (global_rules.md, ddd_rules.md, project_specific.md)
3. Read .ai/projects/PROJECT_X/workflows/${WORKFLOW}.yaml
4. Follow the planning stage instructions from workflow YAML
5. Create FEATURE_X.md with COMPLETE API specifications
6. Create 30_tasks.md with specific tasks for each role
7. Update 50_state.md when done

Remember: You are a senior architect. Provide COMPLETE specifications so engineers don't need to guess!

Start now.
EOF

cat > "$TEMP_DIR/backend_prompt.txt" << EOF
I am the BACKEND ENGINEER for feature $FEATURE_ID.

Please:
1. Run: ./.ai/scripts/git_sync.sh $FEATURE_ID (pull latest changes)
2. Read .ai/roles/backend.md (my role - includes Pairing Patterns!)
3. Read all rules (global_rules.md, ddd_rules.md, project_specific.md)
4. Read FEATURE_X.md and 30_tasks.md (from planner)
5. Read .ai/projects/PROJECT_X/workflows/${WORKFLOW}.yaml
6. Check 50_state.md (planner section) - ensure it's COMPLETED
7. FIND reference code in ./backend/src/ before starting
8. Implement backend with CHECKPOINTS (stop and verify at each)
9. Update 50_state.md (backend section) as you progress
10. Commit after EACH checkpoint: ./.ai/scripts/git_commit_push.sh backend $FEATURE_ID "message"

Remember: You are a 10x engineer. Reference existing code, use checkpoints, verify everything!

Start when planner is COMPLETED.
EOF

cat > "$TEMP_DIR/frontend_prompt.txt" << EOF
I am the FRONTEND ENGINEER for feature $FEATURE_ID.

Please:
1. Run: ./.ai/scripts/git_sync.sh $FEATURE_ID (pull latest changes)
2. Read .ai/roles/frontend.md (my role - includes Pairing Patterns!)
3. Read all rules (global_rules.md, project_specific.md)
4. Read FEATURE_X.md and 30_tasks.md (from planner)
5. Read .ai/projects/PROJECT_X/workflows/${WORKFLOW}.yaml
6. Check 50_state.md:
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

cat > "$TEMP_DIR/qa_prompt.txt" << EOF
I am the QA/REVIEWER for feature $FEATURE_ID.

Please:
1. Run: ./.ai/scripts/git_sync.sh $FEATURE_ID (pull latest changes)
2. Read .ai/roles/qa.md (my role - includes Pairing Patterns!)
3. Read all rules (global_rules.md, ddd_rules.md, project_specific.md)
4. Read FEATURE_X.md (acceptance criteria)
5. Read .ai/projects/PROJECT_X/workflows/${WORKFLOW}.yaml
6. Check 50_state.md:
   - Backend section - ensure it's COMPLETED
   - Frontend section - ensure it's COMPLETED
7. Execute SYSTEMATIC TESTING (5 phases):
   Phase 1: API Testing (curl commands with responses)
   Phase 2: UI Testing (screenshots at each step)
   Phase 3: Automated Test Execution (show results)
   Phase 4: Code Quality Review (DDD compliance)
   Phase 5: Acceptance Criteria Validation (with evidence)
8. Create qa_report_{FEATURE_ID}.md with COMPLETE findings
9. Update 50_state.md (qa section): APPROVED or REJECTED
10. Commit: ./.ai/scripts/git_commit_push.sh qa $FEATURE_ID "QA review: APPROVED/REJECTED"

Remember: You are a senior quality gate. Provide EVIDENCE (screenshots, logs, test results) for everything!

Start when backend and frontend are COMPLETED.
EOF

# Create panes layout (2x2 grid)
info "Creating panes layout (2x2 grid)..."
echo ""

if [ "$AUTO_EXECUTE" = true ]; then
    # Auto-execute mode: Create panes with Claude Code running

    # Current pane becomes Planner
    info "Setting up Pane 1: PLANNER (current pane)"

    # Create Backend pane (right of Planner)
    info "Setting up Pane 2: BACKEND"
    tilix --action=session-add-right -e bash -c "
        cd '$PWD'
        echo -e '${CYAN}╔═══════════════════════════════════════════════════╗${NC}'
        echo -e '${CYAN}║${NC}  ${GREEN}BACKEND ENGINEER${NC} - Feature: $FEATURE_ID       ${CYAN}║${NC}'
        echo -e '${CYAN}╚═══════════════════════════════════════════════════╝${NC}'
        echo ''
        echo -e '${BLUE}Starting Claude Code...${NC}'
        echo ''
        cat '$TEMP_DIR/backend_prompt.txt' | claude
        exec bash
    "

    # Go back to Planner and create Frontend pane (below Planner)
    sleep 0.5
    tilix --action=app-focus-left
    info "Setting up Pane 3: FRONTEND"
    tilix --action=session-add-down -e bash -c "
        cd '$PWD'
        echo -e '${CYAN}╔═══════════════════════════════════════════════════╗${NC}'
        echo -e '${CYAN}║${NC}  ${GREEN}FRONTEND ENGINEER${NC} - Feature: $FEATURE_ID      ${CYAN}║${NC}'
        echo -e '${CYAN}╚═══════════════════════════════════════════════════╝${NC}'
        echo ''
        echo -e '${BLUE}Starting Claude Code...${NC}'
        echo ''
        cat '$TEMP_DIR/frontend_prompt.txt' | claude
        exec bash
    "

    # Create QA pane (right of Frontend)
    sleep 0.5
    info "Setting up Pane 4: QA"
    tilix --action=session-add-right -e bash -c "
        cd '$PWD'
        echo -e '${CYAN}╔═══════════════════════════════════════════════════╗${NC}'
        echo -e '${CYAN}║${NC}  ${GREEN}QA/REVIEWER${NC} - Feature: $FEATURE_ID            ${CYAN}║${NC}'
        echo -e '${CYAN}╚═══════════════════════════════════════════════════╝${NC}'
        echo ''
        echo -e '${BLUE}Starting Claude Code...${NC}'
        echo ''
        cat '$TEMP_DIR/qa_prompt.txt' | claude
        exec bash
    "

    # Go back to Planner pane and start it
    sleep 0.5
    tilix --action=app-focus-up
    tilix --action=app-focus-left

    # Clear and start Planner in current pane
    clear
    echo -e "${CYAN}╔═══════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}  ${GREEN}PLANNER/ARCHITECT${NC} - Feature: $FEATURE_ID       ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BLUE}Starting Claude Code...${NC}"
    echo ""

    # Start Claude with planner prompt
    cat "$TEMP_DIR/planner_prompt.txt" | claude

    # Cleanup
    rm -rf "$TEMP_DIR"

else
    # Manual mode: Just create panes and show instructions

    # Split horizontally
    tilix --action=session-add-down

    # Split both panes vertically
    tilix --action=session-add-right

    # Go back to top-left and split right
    tilix --action=app-focus-up
    tilix --action=session-add-right

    success "Panes created (4 total)"

    # Now we have 4 panes in this layout:
    # ┌─────────┬─────────┐
    # │ Pane 1  │ Pane 2  │
    # ├─────────┼─────────┤
    # │ Pane 3  │ Pane 4  │
    # └─────────┴─────────┘

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    info "To start Claude Code in each pane, copy-paste the following prompts:"
    echo ""

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "│ ${GREEN}Pane 1 (Top-Left): PLANNER${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    cat "$TEMP_DIR/planner_prompt.txt"
    echo ""

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "│ ${GREEN}Pane 2 (Top-Right): BACKEND${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    cat "$TEMP_DIR/backend_prompt.txt"
    echo ""

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "│ ${GREEN}Pane 3 (Bottom-Left): FRONTEND${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    cat "$TEMP_DIR/frontend_prompt.txt"
    echo ""

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "│ ${GREEN}Pane 4 (Bottom-Right): QA${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    cat "$TEMP_DIR/qa_prompt.txt"
    echo ""

    # Cleanup
    rm -rf "$TEMP_DIR"

    success "Tilix setup complete!"
    echo ""
    info "Next steps:"
    echo "1. In each pane, start Claude Code: ${GREEN}claude${NC}"
    echo "2. Copy-paste the prompt for each role (shown above)"
    echo ""
    warn "TIP: To execute automatically next time, use:"
    echo "     ${CYAN}./.ai/scripts/tilix_start.sh $FEATURE_ID $WORKFLOW --execute${NC}"
    echo ""
fi

success "All panes configured! 🚀"
echo ""
info "Monitor progress:"
echo "  ${CYAN}watch -n 5 'cat .ai/projects/PROJECT_X/features/$FEATURE_ID/50_state.md'${NC}"
echo ""
info "Validate workflow:"
echo "  ${CYAN}./.ai/scripts/validate_workflow.py $FEATURE_ID${NC}"
echo ""
