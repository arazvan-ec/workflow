#!/bin/bash

# tilix_start.sh - Abre Claude Code en múltiples panes de Tilix según roles del workflow
#
# Uso:
#   ./scripts/tilix_start.sh [feature-id] [workflow]
#
# Ejemplos:
#   ./scripts/tilix_start.sh my-feature default
#   ./scripts/tilix_start.sh user-auth ddd_parallel

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

info "Starting Tilix workflow setup for feature: $FEATURE_ID"
info "Using workflow: $WORKFLOW"

# Verify workflow exists
WORKFLOW_FILE="./backend/ai/projects/PROJECT_X/workflows/${WORKFLOW}.yaml"
if [ ! -f "$WORKFLOW_FILE" ]; then
    error "Workflow file not found: $WORKFLOW_FILE"
    exit 1
fi

success "Workflow file found: $WORKFLOW_FILE"

# Create panes layout (2x2 grid)
info "Creating panes layout (2x2 grid)..."

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

# Define role prompts
PLANNER_PROMPT="I am the PLANNER for feature $FEATURE_ID.

Please:
1. Read backend/ai/roles/planner.md (my role)
2. Read all rules (global_rules.md, ddd_rules.md, project_specific.md)
3. Read backend/ai/projects/PROJECT_X/workflows/${WORKFLOW}.yaml
4. Follow the planning stage instructions
5. Create FEATURE_X.md and 30_tasks.md
6. Update 50_state.md when done

Start now."

BACKEND_PROMPT="I am the BACKEND ENGINEER for feature $FEATURE_ID.

Please:
1. Run: git pull
2. Read backend/ai/roles/backend.md (my role)
3. Read all rules (global_rules.md, ddd_rules.md, project_specific.md)
4. Read FEATURE_X.md and 30_tasks.md (from planner)
5. Read backend/ai/projects/PROJECT_X/workflows/${WORKFLOW}.yaml
6. Check 50_state.md (planner section) - ensure it's COMPLETED
7. Implement backend according to DDD
8. Update 50_state.md (backend section) as you progress

Start when planner is COMPLETED."

FRONTEND_PROMPT="I am the FRONTEND ENGINEER for feature $FEATURE_ID.

Please:
1. Run: git pull
2. Read backend/ai/roles/frontend.md (my role)
3. Read all rules (global_rules.md, project_specific.md)
4. Read FEATURE_X.md and 30_tasks.md (from planner)
5. Read backend/ai/projects/PROJECT_X/workflows/${WORKFLOW}.yaml
6. Check 50_state.md:
   - Planner section - ensure it's COMPLETED
   - Backend section - check if API is ready
7. If backend NOT ready: mock API and set status to WAITING_API
8. Implement UI
9. Update 50_state.md (frontend section) as you progress

Start when planner is COMPLETED. You can work in parallel with backend."

QA_PROMPT="I am the QA/REVIEWER for feature $FEATURE_ID.

Please:
1. Run: git pull
2. Read backend/ai/roles/qa.md (my role)
3. Read all rules (global_rules.md, ddd_rules.md, project_specific.md)
4. Read FEATURE_X.md (acceptance criteria)
5. Read backend/ai/projects/PROJECT_X/workflows/${WORKFLOW}.yaml
6. Check 50_state.md:
   - Backend section - ensure it's COMPLETED
   - Frontend section - ensure it's COMPLETED
7. Review all code (backend + frontend)
8. Execute tests
9. Validate acceptance criteria
10. Create qa_report_FEATURE_X.md
11. Update 50_state.md (qa section): APPROVED or REJECTED

Start when backend and frontend are COMPLETED."

# Function to send command to a specific pane
send_to_pane() {
    local pane_num=$1
    local command=$2

    # Focus the pane and send command
    tilix --action=session-switch --session-name="$pane_num" 2>/dev/null || true
    sleep 0.2
    # Type the command (don't auto-execute, let user read first)
    xdotool type --clearmodifiers "$command"
}

info "Configuring panes with role prompts..."
info ""
warn "IMPORTANT: Prompts will be TYPED into each pane (not executed automatically)"
warn "You need to manually start Claude Code in each pane first!"
echo ""
echo "In each pane, run:"
echo "  ${GREEN}claude${NC}  (or your command to start Claude Code)"
echo ""
echo "Then press ENTER in each pane to send the role prompt to Claude."
echo ""
read -p "Press ENTER to continue when ready..."

# Note: The actual implementation of sending commands to specific Tilix panes
# requires Tilix terminal identifiers which are complex to get programmatically.
# This script will guide the user instead.

info "Manual setup instructions:"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "│ ${GREEN}Pane 1 (Top-Left): PLANNER${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "$PLANNER_PROMPT"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "│ ${GREEN}Pane 2 (Top-Right): BACKEND${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "$BACKEND_PROMPT"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "│ ${GREEN}Pane 3 (Bottom-Left): FRONTEND${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "$FRONTEND_PROMPT"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "│ ${GREEN}Pane 4 (Bottom-Right): QA${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "$QA_PROMPT"
echo ""

success "Tilix setup complete!"
echo ""
info "Next steps:"
echo "1. In each pane, start Claude Code: ${GREEN}claude${NC}"
echo "2. Copy-paste the prompt for each role (shown above)"
echo "3. Monitor progress by running: ${GREEN}./scripts/view_state.sh $FEATURE_ID${NC}"
echo ""
info "Enjoy working with parallel Claude Code instances! 🚀"
