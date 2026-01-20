#!/bin/bash
# Setup script for Copilot-Ralph Enhanced
# Verifies all dependencies are installed

set -e

echo ""
echo "🚀 Copilot-Ralph Enhanced Setup"
echo "================================"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track if all checks pass
ALL_GOOD=true

# Check GitHub Copilot CLI
echo -n "Checking GitHub Copilot CLI... "
if command -v copilot &> /dev/null; then
    echo -e "${GREEN}✓ found${NC}"
else
    echo -e "${RED}✗ not found${NC}"
    echo "  Install: npm install -g @github/copilot"
    ALL_GOOD=false
fi

# Check jq
echo -n "Checking jq... "
if command -v jq &> /dev/null; then
    echo -e "${GREEN}✓ found${NC}"
else
    echo -e "${RED}✗ not found${NC}"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "  Install: brew install jq"
    else
        echo "  Install: apt-get install jq (Linux) or brew install jq (macOS)"
    fi
    ALL_GOOD=false
fi

# Check Node.js
echo -n "Checking Node.js... "
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    echo -e "${GREEN}✓ found${NC} ($NODE_VERSION)"
    
    # Check version (need 18+)
    MAJOR_VERSION=$(echo $NODE_VERSION | cut -d'.' -f1 | sed 's/v//')
    if [ "$MAJOR_VERSION" -lt 18 ]; then
        echo -e "  ${YELLOW}⚠ Warning: Node.js 18+ recommended (you have $NODE_VERSION)${NC}"
    fi
else
    echo -e "${RED}✗ not found${NC}"
    echo "  Install: https://nodejs.org/"
    ALL_GOOD=false
fi

# Check Git
echo -n "Checking Git... "
if command -v git &> /dev/null; then
    echo -e "${GREEN}✓ found${NC}"
else
    echo -e "${RED}✗ not found${NC}"
    echo "  Install: https://git-scm.com/"
    ALL_GOOD=false
fi

# Check if in git repo
echo -n "Checking Git repository... "
if git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${GREEN}✓ yes${NC}"
else
    echo -e "${YELLOW}⚠ not a git repo${NC}"
    echo "  Ralph commits progress - run 'git init' first"
fi

echo ""

# Final result
if [ "$ALL_GOOD" = true ]; then
    echo -e "${GREEN}✅ All dependencies installed!${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Create PRD: node create-prd.js"
    echo "  2. Run Ralph:  ./ralph.sh"
    echo ""
    exit 0
else
    echo -e "${RED}❌ Missing dependencies - install them and run setup again${NC}"
    echo ""
    exit 1
fi
