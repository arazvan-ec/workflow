#!/bin/bash

# install.sh - Instalador del sistema Claude Code Workflow
#
# Uso:
#   cd /path/to/tu-proyecto
#   bash /path/to/workflow/install.sh

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

info() { echo -e "${BLUE}ℹ${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }
error() { echo -e "${RED}✗${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; }

echo -e "${CYAN}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║   Claude Code - Sistema de Workflow Paralelo             ║
║   Instalador                                              ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Get source and target directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$(pwd)"

info "Source: $SCRIPT_DIR"
info "Target: $TARGET_DIR"

if [ "$SCRIPT_DIR" == "$TARGET_DIR" ]; then
    error "Don't run the installer from the workflow directory itself!"
    echo ""
    echo "Instead, do:"
    echo "  cd /path/to/your-project"
    echo "  bash $SCRIPT_DIR/install.sh"
    exit 1
fi

echo ""
read -p "Install workflow system to $TARGET_DIR? (y/N): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    warn "Installation cancelled"
    exit 0
fi

# Check if directories already exist
if [ -d "$TARGET_DIR/.ai" ] || [ -d "$TARGET_DIR/scripts" ]; then
    warn "Some directories already exist (.ai or scripts)"
    read -p "Do you want to continue and potentially overwrite? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        warn "Installation cancelled"
        exit 0
    fi
fi

info "Copying workflow system files..."

# Copy .ai structure
mkdir -p "$TARGET_DIR/.ai"
cp -r "$SCRIPT_DIR/.ai/"* "$TARGET_DIR/.ai/"
success "Copied .ai/"

# Create backend/src if not exists
mkdir -p "$TARGET_DIR/backend/src"
mkdir -p "$TARGET_DIR/backend/tests"
success "Created backend/src/ and backend/tests/"

# Copy frontend structures
for frontend in frontend1 frontend2; do
    mkdir -p "$TARGET_DIR/$frontend/ai"
    if [ -d "$SCRIPT_DIR/$frontend/ai" ]; then
        cp -r "$SCRIPT_DIR/$frontend/ai/"* "$TARGET_DIR/$frontend/ai/" 2>/dev/null || true
    fi
    mkdir -p "$TARGET_DIR/$frontend/src"
    mkdir -p "$TARGET_DIR/$frontend/tests"
    success "Created $frontend/ structure"
done

# Copy scripts
mkdir -p "$TARGET_DIR/scripts"
cp "$SCRIPT_DIR/scripts/"* "$TARGET_DIR/scripts/"
chmod +x "$TARGET_DIR/scripts/"*.sh "$TARGET_DIR/scripts/"*.py
success "Copied scripts/"

# Copy README
cp "$SCRIPT_DIR/README.md" "$TARGET_DIR/WORKFLOW_README.md"
success "Copied README.md → WORKFLOW_README.md"

# Initialize git if not exists
if [ ! -d "$TARGET_DIR/.git" ]; then
    info "Initializing git repository..."
    cd "$TARGET_DIR"
    git init
    success "Git repository initialized"
fi

# Installation complete
echo ""
success "Installation complete!"
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Next Steps:${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "1. Read the documentation:"
echo "   ${CYAN}cat WORKFLOW_README.md${NC}"
echo ""
echo "2. Run the workflow consultant:"
echo "   ${CYAN}./scripts/suggest_workflow.py${NC}"
echo ""
echo "3. Or start directly with Tilix:"
echo "   ${CYAN}./scripts/tilix_start.sh my-feature default${NC}"
echo ""
echo "4. Validate your workflow:"
echo "   ${CYAN}./scripts/validate_workflow.py${NC}"
echo ""
echo -e "${GREEN}Happy coding with Claude Code! 🚀${NC}"
