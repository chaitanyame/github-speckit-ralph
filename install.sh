#!/bin/bash
# Ralph + Spec Kit Installer
# Quick installation script for existing projects

set -e

REPO="https://raw.githubusercontent.com/chaitanyame/github-speckit-ralph/main"

echo ""
echo "╔════════════════════════════════════════╗"
echo "║   Ralph + Spec Kit Framework           ║"
echo "║         Installation                    ║"
echo "╚════════════════════════════════════════╝"
echo ""

# Check if we're in a git repo
if [ ! -d ".git" ]; then
    echo "⚠️  Warning: Not in a git repository. Continuing anyway..."
    echo ""
fi

# Files to download
FILES=(
  "ralph.sh"
  "ralph.ps1"
  "setup.sh"
  "setup.ps1"
  "start.sh"
  "start.ps1"
  "speckit-to-prd.js"
  "prompt.md"
)

echo "📦 Downloading Ralph framework files..."
echo ""

for file in "${FILES[@]}"; do
  echo "  ↓ $file"
  if curl -fsSL "$REPO/$file" -o "$file"; then
    chmod +x "$file" 2>/dev/null || true
  else
    echo "  ✗ Failed to download $file"
    exit 1
  fi
done

echo ""
echo "✅ Files downloaded successfully!"
echo ""

# Update package.json if exists
if [ -f "package.json" ]; then
  echo "📝 Updating package.json with Ralph scripts..."
  
  # Check if node is available
  if command -v node &> /dev/null; then
    node -e "
      const fs = require('fs');
      const pkg = JSON.parse(fs.readFileSync('package.json', 'utf-8'));
      pkg.scripts = pkg.scripts || {};
      
      const platform = process.platform;
      const isWindows = platform === 'win32';
      
      if (isWindows) {
        pkg.scripts.setup = 'powershell -File setup.ps1';
        pkg.scripts.convert = 'node speckit-to-prd.js';
        pkg.scripts.ralph = 'powershell -File ralph.ps1';
        pkg.scripts.start = 'powershell -File start.ps1';
      } else {
        pkg.scripts.setup = 'bash setup.sh';
        pkg.scripts.convert = 'node speckit-to-prd.js';
        pkg.scripts.ralph = 'bash ralph.sh';
        pkg.scripts.start = 'bash start.sh';
      }
      
      fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2) + '\n');
    " && echo "  ✓ package.json updated"
  else
    echo "  ⚠️  Node.js not found. Skipping package.json update."
    echo "     You can manually add scripts later."
  fi
  echo ""
fi

# Create .gitignore entries if .gitignore exists
if [ -f ".gitignore" ]; then
  echo "📝 Updating .gitignore..."
  
  if ! grep -q "# Ralph framework" .gitignore 2>/dev/null; then
    cat >> .gitignore << 'EOF'

# Ralph framework
archive/
.tmp/
.ralph-last-branch
test-converter.js
EOF
    echo "  ✓ .gitignore updated"
  else
    echo "  ✓ .gitignore already configured"
  fi
  echo ""
fi

echo "╔════════════════════════════════════════╗"
echo "║   Installation Complete! 🎉             ║"
echo "╚════════════════════════════════════════╝"
echo ""
echo "Next steps:"
echo ""
echo "  1. Verify dependencies:"
echo "     npm run setup"
echo ""
echo "  2. Create specification with Spec Kit:"
echo "     uvx --from git+https://github.com/github/spec-kit.git specify init myproject"
echo "     Then use: /speckit.specify, /speckit.plan, /speckit.tasks"
echo ""
echo "  3. Convert Spec Kit output to Ralph format:"
echo "     npm run convert specs/001-myproject"
echo ""
echo "  4. Run Ralph autonomous execution:"
echo "     npm run ralph"
echo ""
echo "  Or use the guided launcher:"
echo "     npm run start"
echo ""
echo "Documentation: https://github.com/chaitanyame/github-speckit-ralph"
echo ""
