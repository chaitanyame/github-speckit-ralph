#!/usr/bin/env pwsh
# ralph.ps1 - Main Ralph autonomous loop (PowerShell version)
# Windows-native equivalent of ralph.sh
#
# Usage: .\ralph.ps1 [options]
# Parameters:
#   -Model              AI model to use (default: gpt-4)
#   -MaxIterations      Maximum iterations (default: 10)
#   -Temperature        Creativity level 0.0-1.0 (default: 0.7)
#   -Help               Show help message
#
# Environment variables (overridden by parameters):
#   COPILOT_MODEL, MAX_ITERATIONS, COPILOT_TEMPERATURE

param(
    [string]$Model,
    [int]$MaxIterations,
    [double]$Temperature,
    [switch]$Help
)

if ($Help) {
    Write-Host "Ralph for GitHub Copilot CLI" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usage: .\ralph.ps1 [options]"
    Write-Host ""
    Write-Host "Parameters:"
    Write-Host "  -Model <string>         AI model to use (default: gpt-4)"
    Write-Host "  -MaxIterations <int>    Maximum iterations (default: 10)"
    Write-Host "  -Temperature <double>   Creativity level 0.0-1.0 (default: 0.7)"
    Write-Host "  -Help                   Show this help message"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\ralph.ps1"
    Write-Host "  .\ralph.ps1 -Model claude-3.5-sonnet -MaxIterations 20"
    Write-Host "  .\ralph.ps1 -Model gpt-4 -MaxIterations 15 -Temperature 0.5"
    Write-Host ""
    exit 0
}

$ErrorActionPreference = "Stop"

# Configuration priority: CLI params > env vars > defaults
$MAX_ITERATIONS = if ($MaxIterations -gt 0) { 
    $MaxIterations 
} elseif ($env:MAX_ITERATIONS) { 
    [int]$env:MAX_ITERATIONS 
} else { 
    10 
}

$MODEL = if ($Model) { 
    $Model 
} elseif ($env:COPILOT_MODEL) { 
    $env:COPILOT_MODEL 
} else { 
    "gpt-4" 
}

$TEMPERATURE = if ($Temperature -gt 0) { 
    $Temperature 
} elseif ($env:COPILOT_TEMPERATURE) { 
    $env:COPILOT_TEMPERATURE 
} else { 
    0.7 
}

# Get script directory
$SCRIPT_DIR = Split-Path -Parent $PSCommandPath
$PRD_FILE = Join-Path $SCRIPT_DIR "prd.json"
$PROGRESS_FILE = Join-Path $SCRIPT_DIR "progress.txt"
$PROMPT_FILE = Join-Path $SCRIPT_DIR "prompt.md"

# Color functions
function Write-Success { param($Message) Write-Host $Message -ForegroundColor Green }
function Write-Error { param($Message) Write-Host $Message -ForegroundColor Red }
function Write-Info { param($Message) Write-Host $Message -ForegroundColor Yellow }
function Write-Header { param($Message) Write-Host $Message -ForegroundColor Cyan }

# Check dependencies
Write-Info "Checking dependencies..."
if (-not (Get-Command copilot -ErrorAction SilentlyContinue)) {
    Write-Error "ERROR: GitHub Copilot CLI not found"
    Write-Info "Install with: npm install -g @githubnext/github-copilot-cli"
    exit 1
}

# Check PRD file exists
if (-not (Test-Path $PRD_FILE -PathType Leaf)) {
    Write-Error "ERROR: prd.json not found"
    Write-Info "Run 'node create-prd.js' to create a PRD file first"
    exit 1
}

# Load PRD
try {
    $prdContent = Get-Content $PRD_FILE -Raw | ConvertFrom-Json
} catch {
    Write-Error "ERROR: Failed to parse prd.json"
    exit 1
}

# Archive previous run if branch changed
$currentBranch = $prdContent.branchName
if (Test-Path $PROGRESS_FILE) {
    $lastBranch = (Get-Content $PROGRESS_FILE -First 1).Trim()
    
    if ($lastBranch -ne $currentBranch) {
        $timestamp = Get-Date -Format "yyyy-MM-dd"
        $safeBranch = $lastBranch -replace '^ralph/', ''
        $archiveDir = Join-Path $SCRIPT_DIR "archive\$timestamp-$safeBranch"
        
        Write-Info "Branch changed from $lastBranch to $currentBranch"
        Write-Info "Archiving previous run to: $archiveDir"
        
        New-Item -ItemType Directory -Force -Path $archiveDir | Out-Null
        Copy-Item $PRD_FILE -Destination $archiveDir -Force
        Copy-Item $PROGRESS_FILE -Destination $archiveDir -Force
    }
}

# Initialize progress tracking
Set-Content -Path $PROGRESS_FILE -Value $currentBranch

Write-Header ""
Write-Header "╔════════════════════════════════════════╗"
Write-Header "║         Ralph Autonomous Loop          ║"
Write-Header "║        (PowerShell Edition)            ║"
Write-Header "╚════════════════════════════════════════╝"
Write-Header ""
Write-Info "Project: $($prdContent.projectName)"
Write-Info "Branch: $currentBranch"
Write-Info "Model: $MODEL"
Write-Info "Temperature: $TEMPERATURE"
Write-Info "Max iterations: $MAX_ITERATIONS"
Write-Header ""

# Main loop
for ($iteration = 1; $iteration -le $MAX_ITERATIONS; $iteration++) {
    Write-Header "═══════════════════════════════════════="
    Write-Header "  Iteration $iteration of $MAX_ITERATIONS"
    Write-Header "════════════════════════════════════════"
    
    # Reload PRD to get fresh state
    $prdContent = Get-Content $PRD_FILE -Raw | ConvertFrom-Json
    
    # Count remaining stories
    $remainingStories = @($prdContent.userStories | Where-Object { -not $_.passes })
    $remainingCount = $remainingStories.Count
    
    if ($remainingCount -eq 0) {
        Write-Success ""
        Write-Success "🎉 All user stories completed!"
        Write-Success ""
        exit 0
    }
    
    Write-Info "Remaining stories: $remainingCount"
    
    # Get highest priority incomplete story
    $currentStory = $prdContent.userStories | 
        Where-Object { -not $_.passes } | 
        Sort-Object priority | 
        Select-Object -First 1
    
    if (-not $currentStory) {
        Write-Error "ERROR: No incomplete stories found, but count was $remainingCount"
        exit 1
    }
    
    Write-Info "Current story: $($currentStory.title) (Priority: $($currentStory.priority))"
    Write-Host ""
    
    # Read prompt template
    if (-not (Test-Path $PROMPT_FILE)) {
        Write-Error "ERROR: prompt.md not found"
        exit 1
    }
    
    $promptTemplate = Get-Content $PROMPT_FILE -Raw
    
    # Update progress file
    Add-Content -Path $PROGRESS_FILE -Value "Iteration $iteration - Story: $($currentStory.title)"
    
    # Run Copilot CLI
    Write-Info "Running Copilot CLI..."
    Write-Host ""
    
    try {
        # Capture output to check for completion
        $output = & copilot -m $MODEL --temperature $TEMPERATURE $promptTemplate 2>&1 | Tee-Object -Variable copilotOutput
        $outputString = $copilotOutput -join "`n"
        
        # Check for completion signal
        if ($outputString -match '<promise>COMPLETE</promise>') {
            Write-Success "✓ Story marked as complete by Copilot"
            Add-Content -Path $PROGRESS_FILE -Value "  Status: COMPLETE"
        } else {
            Add-Content -Path $PROGRESS_FILE -Value "  Status: In progress"
        }
    } catch {
        Write-Error "ERROR: Copilot CLI failed: $_"
        Add-Content -Path $PROGRESS_FILE -Value "  Status: ERROR - $($_.Exception.Message)"
    }
    
    Write-Host ""
    Write-Info "Waiting 2 seconds before next iteration..."
    Start-Sleep -Seconds 2
}

Write-Info ""
Write-Info "Reached maximum iterations ($MAX_ITERATIONS)"
Write-Info "Remaining stories: $(($prdContent.userStories | Where-Object { -not $_.passes }).Count)"
Write-Info ""
Write-Info "To continue, run: powershell -File ralph.ps1"
Write-Info "Or set environment: `$env:MAX_ITERATIONS=20; .\ralph.ps1"
Write-Info ""

exit 1
