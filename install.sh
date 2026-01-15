#!/usr/bin/env bash

################################################################################
# Claude Code Parallel Workflow System - Installer
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/YOUR_USER/workflow/main/install.sh | bash
#
#   Or download and run:
#   wget https://raw.githubusercontent.com/YOUR_USER/workflow/main/install.sh
#   chmod +x install.sh
#   ./install.sh
#
#   Or run from local repo:
#   cd /path/to/your-project
#   bash /path/to/workflow/install.sh
################################################################################

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

info() { echo -e "${BLUE}ℹ${NC} $*"; }
success() { echo -e "${GREEN}✓${NC} $*"; }
warning() { echo -e "${YELLOW}⚠${NC} $*"; }
error() { echo -e "${RED}✗${NC} $*" >&2; }
header() { echo -e "\n${BOLD}${CYAN}$*${NC}\n"; }
die() { error "$*"; exit 1; }

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"
INSTALL_FROM_LOCAL=false

# Check if we're running from the workflow repo itself
if [[ -f "$SCRIPT_DIR/README.md" ]] && grep -q "Claude Code Parallel Workflow System" "$SCRIPT_DIR/README.md" 2>/dev/null; then
    INSTALL_FROM_LOCAL=true
    SOURCE_DIR="$SCRIPT_DIR"
    info "Installing from local workflow repository: $SOURCE_DIR"
fi

# Target directory (current directory where user runs the script)
TARGET_DIR="$(pwd)"

header "🚀 Claude Code Parallel Workflow System - Installer"

echo "This will install the workflow system in:"
echo "  ${CYAN}$TARGET_DIR${NC}"
echo ""

# Check if ai/ already exists
if [[ -d "$TARGET_DIR/ai" ]]; then
    warning "Directory 'ai/' already exists in this project."
    echo ""
    read -p "$(echo -e ${YELLOW}?${NC} Do you want to backup and replace it? \(y/N\): )" -r
    echo ""

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        info "Installation cancelled."
        exit 0
    fi

    # Backup existing ai/ directory
    BACKUP_NAME="ai.backup.$(date +%Y%m%d_%H%M%S)"
    info "Backing up existing ai/ to $BACKUP_NAME"
    mv "$TARGET_DIR/ai" "$TARGET_DIR/$BACKUP_NAME"
    success "Backup created: $BACKUP_NAME"
fi

info "Installing workflow system..."
echo ""

# Function to copy from local or download from remote
install_file() {
    local rel_path="$1"
    local target_path="$TARGET_DIR/$rel_path"

    # Create directory if needed
    mkdir -p "$(dirname "$target_path")"

    if [[ "$INSTALL_FROM_LOCAL" == "true" ]]; then
        # Copy from local repo
        cp "$SOURCE_DIR/$rel_path" "$target_path"
    else
        # For remote installation, would download from GitHub
        # For now, we'll create the files inline (see below)
        :
    fi
}

# If installing from local, copy everything
if [[ "$INSTALL_FROM_LOCAL" == "true" ]]; then
    info "Copying files from local repository..."

    # Copy ai/ directory
    cp -r "$SOURCE_DIR/ai" "$TARGET_DIR/"

    # Copy scripts/
    mkdir -p "$TARGET_DIR/scripts"
    cp "$SOURCE_DIR/scripts/workflow" "$TARGET_DIR/scripts/"
    cp "$SOURCE_DIR/scripts/workflow-consultant" "$TARGET_DIR/scripts/"
    cp "$SOURCE_DIR/scripts/setup-project" "$TARGET_DIR/scripts/"
    chmod +x "$TARGET_DIR/scripts"/*

    # Copy hooks/
    mkdir -p "$TARGET_DIR/hooks"
    cp -r "$SOURCE_DIR/hooks"/* "$TARGET_DIR/hooks/"

    # Copy documentation
    cp "$SOURCE_DIR/README.md" "$TARGET_DIR/"
    cp "$SOURCE_DIR/QUICKSTART.md" "$TARGET_DIR/"
    cp "$SOURCE_DIR/CHEATSHEET.md" "$TARGET_DIR/"
    cp "$SOURCE_DIR/SUMMARY.md" "$TARGET_DIR/"

    # Copy .gitignore if it doesn't exist
    if [[ ! -f "$TARGET_DIR/.gitignore" ]]; then
        cp "$SOURCE_DIR/.gitignore" "$TARGET_DIR/"
    else
        info ".gitignore already exists, skipping"
    fi

    success "Files copied successfully"
else
    # For remote installation, we would download files here
    # For now, show message to clone the repo
    error "Remote installation not yet implemented."
    echo ""
    info "Please clone the repository and run install.sh from there:"
    echo ""
    echo "  git clone https://github.com/YOUR_USER/workflow.git /tmp/workflow"
    echo "  cd $TARGET_DIR"
    echo "  bash /tmp/workflow/install.sh"
    echo ""
    exit 1
fi

# Create common project directories if they don't exist
info "Creating project structure..."
mkdir -p "$TARGET_DIR/src"
mkdir -p "$TARGET_DIR/frontend"
mkdir -p "$TARGET_DIR/tests"
mkdir -p "$TARGET_DIR/docs"

# Create README files in directories if they don't exist
if [[ ! -f "$TARGET_DIR/src/README.md" ]]; then
    cat > "$TARGET_DIR/src/README.md" << 'EOF'
# Source Code

Backend/server source code goes here.

## Structure

Organize as needed for your architecture.
EOF
fi

if [[ ! -f "$TARGET_DIR/frontend/README.md" ]]; then
    cat > "$TARGET_DIR/frontend/README.md" << 'EOF'
# Frontend

Frontend/UI source code goes here.
EOF
fi

if [[ ! -f "$TARGET_DIR/tests/README.md" ]]; then
    cat > "$TARGET_DIR/tests/README.md" << 'EOF'
# Tests

Test files go here.
EOF
fi

success "Project structure created"

# Install Python dependencies
if command -v pip3 &> /dev/null; then
    info "Installing Python dependencies (PyYAML)..."
    pip3 install pyyaml --quiet 2>/dev/null || pip3 install --user pyyaml --quiet 2>/dev/null || {
        warning "Could not install PyYAML. The workflow-consultant may not work."
        info "Install manually: pip3 install pyyaml"
    }
else
    warning "pip3 not found. Install PyYAML manually: pip3 install pyyaml"
fi

# Initialize git if not already a repo
if [[ ! -d "$TARGET_DIR/.git" ]]; then
    info "Initializing git repository..."
    cd "$TARGET_DIR"
    git init
    success "Git repository initialized"
else
    info "Git repository already exists"
fi

# Create initial commit if this is a new installation
cd "$TARGET_DIR"
if ! git rev-parse HEAD >/dev/null 2>&1; then
    info "Creating initial commit..."
    git add .
    git commit -m "feat: Add Claude Code Parallel Workflow System

Installed workflow system for managing multiple Claude Code instances in parallel.

System includes:
- Context structure in /ai/
- Workflow templates (feature_template, ddd_parallel)
- CLI tools (workflow, workflow-consultant)
- Example feature (example-todo-api)
- Complete documentation

Run './scripts/workflow consult' to get started.
" 2>/dev/null || info "Could not create initial commit (files may already be committed)"
fi

header "✅ Installation Complete!"

echo ""
echo "📁 Installed in: ${CYAN}$TARGET_DIR${NC}"
echo ""
echo "📚 Documentation:"
echo "  • README.md        - Main documentation"
echo "  • QUICKSTART.md    - 5-minute tutorial"
echo "  • CHEATSHEET.md    - Quick commands reference"
echo ""
echo "🎯 Quick Start:"
echo ""
echo "  ${GREEN}# Option 1: Interactive workflow generator (recommended)${NC}"
echo "  ${CYAN}./scripts/workflow consult${NC}"
echo ""
echo "  ${GREEN}# Option 2: Try the example${NC}"
echo "  ${CYAN}./scripts/workflow status example-todo-api${NC}"
echo "  ${CYAN}cat ai/features/example-todo-api/EXAMPLE_USAGE.md${NC}"
echo ""
echo "  ${GREEN}# Option 3: Manual initialization${NC}"
echo "  ${CYAN}./scripts/workflow init my-feature${NC}"
echo ""
echo "📖 Learn more:"
echo "  ${CYAN}cat README.md${NC}"
echo "  ${CYAN}cat QUICKSTART.md${NC}"
echo ""
echo "🎉 ${BOLD}Ready to use multiple Claude Code instances in parallel!${NC}"
echo ""

# Optional: Run setup-project if it exists
if [[ -x "$TARGET_DIR/scripts/setup-project" ]]; then
    echo ""
    read -p "$(echo -e ${BLUE}?${NC} Run setup-project to configure the environment? \(Y/n\): )" -r
    echo ""

    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        "$TARGET_DIR/scripts/setup-project"
    fi
fi

success "Installation successful! 🚀"
