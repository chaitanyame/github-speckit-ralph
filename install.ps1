#!/usr/bin/env pwsh
# Ralph + Spec Kit Installer (Windows)
# Quick installation script for existing projects

$ErrorActionPreference = "Stop"

$Repo = "https://raw.githubusercontent.com/chaitanyame/github-speckit-ralph/main"

Write-Host ""
Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   Ralph + Spec Kit Framework           ║" -ForegroundColor Cyan
Write-Host "║         Installation                    ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Check if we're in a git repo
if (-not (Test-Path ".git" -PathType Container)) {
    Write-Host "⚠️  Warning: Not in a git repository. Continuing anyway..." -ForegroundColor Yellow
    Write-Host ""
}

# Files to download
$Files = @(
    "ralph.sh",
    "ralph.ps1",
    "setup.sh",
    "setup.ps1",
    "start.sh",
    "start.ps1",
    "speckit-to-prd.js",
    "prompt.md"
)

# Spec Kit integration files (GitHub Copilot)
$SpecKitFiles = @(
    ".github/agents/speckit.converttaskstoprd.md",
    ".github/prompts/speckit.converttaskstoprd.md"
)

Write-Host "📦 Downloading Ralph framework files..." -ForegroundColor Yellow
Write-Host ""

foreach ($File in $Files) {
    Write-Host "  ↓ $File" -ForegroundColor Gray
    try {
        Invoke-WebRequest -Uri "$Repo/$File" -OutFile $File -ErrorAction Stop
    } catch {
        Write-Host "  ✗ Failed to download $File" -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "📦 Downloading Spec Kit integration files..." -ForegroundColor Yellow
Write-Host ""

foreach ($File in $SpecKitFiles) {
    Write-Host "  ↓ $File" -ForegroundColor Gray
    try {
        # Create directory if it doesn't exist
        $Dir = Split-Path $File -Parent
        if ($Dir -and -not (Test-Path $Dir)) {
            New-Item -ItemType Directory -Path $Dir -Force | Out-Null
        }
        Invoke-WebRequest -Uri "$Repo/$File" -OutFile $File -ErrorAction Stop
    } catch {
        Write-Host "  ✗ Failed to download $File" -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "✅ Files downloaded successfully!" -ForegroundColor Green
Write-Host ""

# Update package.json if exists
if (Test-Path "package.json") {
    Write-Host "📝 Updating package.json with Ralph scripts..." -ForegroundColor Yellow
    
    try {
        $pkg = Get-Content "package.json" -Raw | ConvertFrom-Json
        
        if (-not $pkg.scripts) {
            $pkg | Add-Member -NotePropertyName "scripts" -NotePropertyValue @{} -Force
        }
        
        $pkg.scripts | Add-Member -NotePropertyName "setup" -NotePropertyValue "powershell -File setup.ps1" -Force
        $pkg.scripts | Add-Member -NotePropertyName "convert" -NotePropertyValue "node speckit-to-prd.js" -Force
        $pkg.scripts | Add-Member -NotePropertyName "ralph" -NotePropertyValue "powershell -File ralph.ps1" -Force
        $pkg.scripts | Add-Member -NotePropertyName "start" -NotePropertyValue "powershell -File start.ps1" -Force
        
        $pkg | ConvertTo-Json -Depth 10 | Set-Content "package.json"
        Write-Host "  ✓ package.json updated" -ForegroundColor Green
    } catch {
        Write-Host "  ⚠️  Failed to update package.json: $($_.Exception.Message)" -ForegroundColor Yellow
    }
    Write-Host ""
}

# Create .gitignore entries if .gitignore exists
if (Test-Path ".gitignore") {
    Write-Host "📝 Updating .gitignore..." -ForegroundColor Yellow
    
    $gitignoreContent = Get-Content ".gitignore" -Raw -ErrorAction SilentlyContinue
    
    if ($gitignoreContent -notmatch "# Ralph framework") {
        Add-Content -Path ".gitignore" -Value @"

# Ralph framework
archive/
.tmp/
.ralph-last-branch
test-converter.js
"@
        Write-Host "  ✓ .gitignore updated" -ForegroundColor Green
    } else {
        Write-Host "  ✓ .gitignore already configured" -ForegroundColor Green
    }
    Write-Host ""
}

Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║   Installation Complete! 🎉             ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  1. Verify dependencies:"
Write-Host "     npm run setup"
Write-Host ""
Write-Host "  2. Create specification with Spec Kit:"
Write-Host "     uvx --from git+https://github.com/github/spec-kit.git specify init myproject"
Write-Host "     Then use: /speckit.specify, /speckit.plan, /speckit.tasks"
Write-Host ""
Write-Host "  3. Convert Spec Kit output to Ralph format:"
Write-Host "     npm run convert specs/001-myproject"
Write-Host ""
Write-Host "  4. Run Ralph autonomous execution:"
Write-Host "     npm run ralph"
Write-Host ""
Write-Host "  Or use the guided launcher:"
Write-Host "     npm run start"
Write-Host ""
Write-Host "Documentation: https://github.com/chaitanyame/github-speckit-ralph" -ForegroundColor Cyan
Write-Host ""
