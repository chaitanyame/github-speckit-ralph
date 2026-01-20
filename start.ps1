#!/usr/bin/env pwsh
# start.ps1 - Ralph Quick Start with Spec Kit Integration
# Workflow: Spec Kit spec creation → convert → Ralph execution

$ErrorActionPreference = "Stop"

$SCRIPT_DIR = Split-Path -Parent $PSCommandPath
Set-Location $SCRIPT_DIR

# Color functions
function Write-Success { param($Message) Write-Host $Message -ForegroundColor Green }
function Write-Info { param($Message) Write-Host $Message -ForegroundColor Yellow }
function Write-Header { param($Message) Write-Host $Message -ForegroundColor Cyan }
function Write-Err { param($Message) Write-Host $Message -ForegroundColor Red }

Write-Host ""
Write-Header "╔════════════════════════════════════════╗"
Write-Header "║    Ralph + Spec Kit Quick Start       ║"
Write-Header "╚════════════════════════════════════════╝"
Write-Host ""

# Step 1: Verify setup
Write-Info "Step 1: Verifying dependencies..."
& "$SCRIPT_DIR\setup.ps1"
if ($LASTEXITCODE -ne 0) {
    exit 1
}
Write-Host ""

# Step 2: Check for PRD or guide to Spec Kit
if (-not (Test-Path "prd.json")) {
    Write-Info "Step 2: No PRD found. Let's create one!"
    Write-Host ""
    Write-Header "Two options:"
    Write-Success "  A) Use GitHub Spec Kit (recommended)"
    Write-Success "  B) Convert existing Spec Kit output"
    Write-Host ""
    $choice = Read-Host "Choose (A/B)"
    Write-Host ""
    
    if ($choice -match '^[Aa]$') {
        Write-Header "GitHub Spec Kit Workflow:"
        Write-Host ""
        Write-Info "1. Initialize Spec Kit:"
        Write-Success "   uvx --from git+https://github.com/github/spec-kit.git specify init <PROJECT_NAME>"
        Write-Host ""
        Write-Info "2. Create specifications (in your AI editor):"
        Write-Success "   /speckit.specify - Create spec.md with user stories"
        Write-Success "   /speckit.plan    - Generate implementation plan"
        Write-Success "   /speckit.tasks   - Create task breakdown"
        Write-Host ""
        Write-Info "3. Convert to Ralph format:"
        Write-Success "   node speckit-to-prd.js specs/<PROJECT_FOLDER>"
        Write-Host ""
        Write-Info "4. Run Ralph:"
        Write-Success "   powershell -File ralph.ps1"
        Write-Host ""
        exit 0
    } else {
        Write-Info "Enter path to Spec Kit folder:"
        $specPath = Read-Host "Path (e.g., specs/001-my-project)"
        
        if (-not (Test-Path $specPath)) {
            Write-Err "ERROR: Folder not found: $specPath"
            exit 1
        }
        
        Write-Host ""
        Write-Info "Converting Spec Kit output to prd.json..."
        node speckit-to-prd.js $specPath
        Write-Host ""
    }
} else {
    Write-Success "Step 2: PRD already exists (prd.json)"
    Write-Host ""
    $response = Read-Host "Do you want to convert a new Spec Kit output? (y/N)"
    if ($response -match '^[Yy]') {
        $specPath = Read-Host "Path to Spec Kit folder (e.g., specs/001-my-project)"
        
        if (-not (Test-Path $specPath)) {
            Write-Err "ERROR: Folder not found: $specPath"
            exit 1
        }
        
        Write-Host ""
        node speckit-to-prd.js $specPath
        Write-Host ""
    }
}

# Step 3: Run Ralph
Write-Info "Step 3: Starting Ralph autonomous loop..."
Write-Host ""
$maxIterInput = Read-Host "Max iterations (default 10)"
$maxIter = if ($maxIterInput) { [int]$maxIterInput } else { 10 }
Write-Host ""

& "$SCRIPT_DIR\ralph.ps1" -MaxIterations $maxIter
