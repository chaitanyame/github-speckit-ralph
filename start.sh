#!/bin/bash
# start.sh - Ralph Quick Start with Spec Kit Integration
# Workflow: Spec Kit spec creation → convert → Ralph execution

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo ""
echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║    Ralph + Spec Kit Quick Start       ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
echo ""

# Step 1: Verify setup
echo -e "${YELLOW}Step 1: Verifying dependencies...${NC}"
bash setup.sh
echo ""

# Step 2: Check for PRD or guide to Spec Kit
if [ ! -f "prd.json" ]; then
    echo -e "${YELLOW}Step 2: No PRD found. Let's create one!${NC}"
    echo ""
    echo -e "${CYAN}Two options:${NC}"
    echo -e "  ${GREEN}A)${NC} Use GitHub Spec Kit (recommended)"
    echo -e "  ${GREEN}B)${NC} Convert existing Spec Kit output"
    echo ""
    read -p "Choose (A/B): " -n 1 -r
    echo ""
    echo ""
    
    if [[ $REPLY =~ ^[Aa]$ ]]; then
        echo -e "${CYAN}GitHub Spec Kit Workflow:${NC}"
        echo ""
        echo -e "${YELLOW}1. Initialize Spec Kit:${NC}"
        echo -e "   ${GREEN}uvx --from git+https://github.com/github/spec-kit.git specify init <PROJECT_NAME>${NC}"
        echo ""
        echo -e "${YELLOW}2. Create specifications (in your AI editor):${NC}"
        echo -e "   ${GREEN}/speckit.specify${NC} - Create spec.md with user stories"
        echo -e "   ${GREEN}/speckit.plan${NC}    - Generate implementation plan"
        echo -e "   ${GREEN}/speckit.tasks${NC}   - Create task breakdown"
        echo ""
        echo -e "${YELLOW}3. Convert to Ralph format:${NC}"
        echo -e "   ${GREEN}node speckit-to-prd.js specs/<PROJECT_FOLDER>${NC}"
        echo ""
        echo -e "${YELLOW}4. Run Ralph:${NC}"
        echo -e "   ${GREEN}bash ralph.sh${NC}"
        echo ""
        exit 0
    else
        echo -e "${YELLOW}Enter path to Spec Kit folder:${NC}"
        read -p "Path (e.g., specs/001-my-project): " SPEC_PATH
        
        if [ ! -d "$SPEC_PATH" ]; then
            echo -e "${RED}ERROR: Folder not found: $SPEC_PATH${NC}"
            exit 1
        fi
        
        echo ""
        echo -e "${YELLOW}Converting Spec Kit output to prd.json...${NC}"
        node speckit-to-prd.js "$SPEC_PATH"
        echo ""
    fi
else
    echo -e "${GREEN}Step 2: PRD already exists (prd.json)${NC}"
    echo ""
    read -p "Do you want to convert a new Spec Kit output? (y/N): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        read -p "Path to Spec Kit folder (e.g., specs/001-my-project): " SPEC_PATH
        
        if [ ! -d "$SPEC_PATH" ]; then
            echo -e "${RED}ERROR: Folder not found: $SPEC_PATH${NC}"
            exit 1
        fi
        
        echo ""
        node speckit-to-prd.js "$SPEC_PATH"
        echo ""
    fi
fi

# Step 3: Run Ralph
echo -e "${YELLOW}Step 3: Starting Ralph autonomous loop...${NC}"
echo ""
read -p "Max iterations (default 10): " MAX_ITER
MAX_ITER=${MAX_ITER:-10}
echo ""

bash ralph.sh "$MAX_ITER"
