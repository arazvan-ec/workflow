#!/usr/bin/env bash

################################################################################
# Claude Code Workflow System - Bootstrap Script
#
# This is a minimal bootstrap script that clones the workflow system
# and runs the full installer in your project directory.
#
# Usage:
#   cd /path/to/your-project
#   bash <(curl -fsSL https://raw.githubusercontent.com/YOUR_USER/workflow/main/bootstrap.sh)
#
# Or save and run:
#   curl -fsSL https://raw.githubusercontent.com/YOUR_USER/workflow/main/bootstrap.sh -o bootstrap.sh
#   chmod +x bootstrap.sh
#   ./bootstrap.sh
################################################################################

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

info() { echo -e "${BLUE}ℹ${NC} $*"; }
success() { echo -e "${GREEN}✓${NC} $*"; }
error() { echo -e "${RED}✗${NC} $*" >&2; }
header() { echo -e "\n${BOLD}${CYAN}$*${NC}\n"; }

header "🚀 Claude Code Workflow System - Bootstrap"

# GitHub repository URL (CHANGE THIS to your actual repo)
REPO_URL="https://github.com/YOUR_USER/workflow.git"
TEMP_DIR="/tmp/workflow-install-$$"

# Alternative: If you host this elsewhere, adjust accordingly
# For now, we'll provide instructions for local installation

info "This script will install the Claude Code Workflow System in your current directory."
echo ""
echo "Current directory: ${CYAN}$(pwd)${NC}"
echo ""

# Check if git is installed
if ! command -v git &> /dev/null; then
    error "Git is not installed. Please install git first."
    exit 1
fi

# Method 1: Clone from GitHub (if repo is public)
if false; then  # Set to true when you have a public repo
    info "Cloning workflow system from GitHub..."
    git clone --depth 1 "$REPO_URL" "$TEMP_DIR"
    success "Repository cloned"

    info "Running installer..."
    bash "$TEMP_DIR/install.sh"

    # Cleanup
    rm -rf "$TEMP_DIR"
    success "Cleanup complete"

    exit 0
fi

# Method 2: Instructions for manual installation
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
info "To install the workflow system, follow these steps:"
echo ""
echo "${BOLD}Option A: From GitHub (when available)${NC}"
echo "  ${CYAN}git clone https://github.com/YOUR_USER/workflow.git /tmp/workflow${NC}"
echo "  ${CYAN}cd $(pwd)${NC}"
echo "  ${CYAN}bash /tmp/workflow/install.sh${NC}"
echo ""
echo "${BOLD}Option B: From local copy${NC}"
echo "  1. Clone or copy the workflow repository to a local directory"
echo "  2. Run from your project directory:"
echo "     ${CYAN}cd $(pwd)${NC}"
echo "     ${CYAN}bash /path/to/workflow/install.sh${NC}"
echo ""
echo "${BOLD}Option C: Direct copy (if you have the files)${NC}"
echo "  ${CYAN}cp -r /path/to/workflow/ai $(pwd)/${NC}"
echo "  ${CYAN}cp -r /path/to/workflow/scripts $(pwd)/${NC}"
echo "  ${CYAN}cp -r /path/to/workflow/hooks $(pwd)/${NC}"
echo "  ${CYAN}cp /path/to/workflow/*.md $(pwd)/${NC}"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
info "Once installed, run: ${CYAN}./scripts/workflow consult${NC}"
echo ""
