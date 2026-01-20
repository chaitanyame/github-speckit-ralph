#!/usr/bin/env pwsh
# setup.ps1 - Verify all dependencies for Ralph (PowerShell version)
# Windows-native equivalent of setup.sh

$ErrorActionPreference = "Stop"

# Color definitions
function Write-Success { param($Message) Write-Host $Message -ForegroundColor Green }
function Write-Error { param($Message) Write-Host $Message -ForegroundColor Red }
function Write-Info { param($Message) Write-Host $Message -ForegroundColor Yellow }

Write-Host ""
Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   Ralph Setup Verification (Windows)   ║" -ForegroundColor Cyan
Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host ""

$AllGood = $true

# Check for GitHub Copilot CLI
Write-Host "Checking for GitHub Copilot CLI..." -NoNewline
if (Get-Command copilot -ErrorAction SilentlyContinue) {
    Write-Success " ✓ Found"
} else {
    Write-Error " ✗ Not found"
    Write-Info "  Install with: npm install -g @githubnext/github-copilot-cli"
    $AllGood = $false
}

# Check for uvx (Spec Kit)
Write-Host "Checking for uvx (Spec Kit)..." -NoNewline
if (Get-Command uvx -ErrorAction SilentlyContinue) {
    Write-Success " ✓ Found"
} else {
    Write-Info " ⚠ Not found (optional)"
    Write-Info "  Install with: pip install uv"
    Write-Info "  Then you can use Spec Kit for spec creation"
}

# Check for Node.js
Write-Host "Checking for Node.js..." -NoNewline
if (Get-Command node -ErrorAction SilentlyContinue) {
    $nodeVersion = node --version
    $majorVersion = [int]($nodeVersion -replace 'v(\d+)\..*', '$1')
    
    if ($majorVersion -ge 18) {
        Write-Success " ✓ Found ($nodeVersion)"
    } else {
        Write-Error " ✗ Version too old ($nodeVersion)"
        Write-Info "  Node.js v18 or higher required"
        $AllGood = $false
    }
} else {
    Write-Error " ✗ Not found"
    Write-Info "  Install from: https://nodejs.org"
    $AllGood = $false
}

# Check for Git
Write-Host "Checking for Git..." -NoNewline
if (Get-Command git -ErrorAction SilentlyContinue) {
    Write-Success " ✓ Found"
} else {
    Write-Error " ✗ Not found"
    Write-Info "  Install from: https://git-scm.com"
    $AllGood = $false
}

# Check if in a git repository
Write-Host "Checking if in git repository..." -NoNewline
try {
    git rev-parse --git-dir 2>$null | Out-Null
    Write-Success " ✓ Yes"
} catch {
    Write-Error " ✗ No"
    Write-Info "  Run 'git init' to initialize a repository"
    $AllGood = $false
}

Write-Host ""
if ($AllGood) {
    Write-Success "✓ All dependencies satisfied!"
    Write-Host ""
    Write-Info "Ready to run:"
    Write-Host "  1. Create PRD:  " -NoNewline -ForegroundColor White
    Write-Host "node create-prd.js" -ForegroundColor Cyan
    Write-Host "  2. Run Ralph:   " -NoNewline -ForegroundColor White
    Write-Host "powershell -File ralph.ps1" -ForegroundColor Cyan
    Write-Host "  3. Or use launcher: " -NoNewline -ForegroundColor White
    Write-Host "powershell -File start.ps1" -ForegroundColor Cyan
    Write-Host ""
    exit 0
} else {
    Write-Error "✗ Some dependencies are missing"
    Write-Host ""
    exit 1
}
