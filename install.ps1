# Claude Skills - Windows Installer
# Installs project-wizard and project-update skills into the user's Claude Code config.
# No git required. Auto-installs uv (needed by /project-wizard) if missing.
#
# Usage (PowerShell on Windows 10/11, run as Administrator):
#   irm https://raw.githubusercontent.com/MasterOfApps/claude-skills/main/install.ps1 | iex

$ErrorActionPreference = 'Stop'

$RepoRawUrl = 'https://raw.githubusercontent.com/MasterOfApps/claude-skills/main'
$SkillsDir  = Join-Path $env:USERPROFILE '.claude\skills'
$Skills     = @('project-wizard', 'project-update')

function Write-Section($Text) {
    Write-Host ''
    Write-Host "=== $Text ===" -ForegroundColor Cyan
}

function Write-Ok($Text)   { Write-Host "  [OK]   $Text" -ForegroundColor Green }
function Write-Skip($Text) { Write-Host "  [SKIP] $Text" -ForegroundColor DarkGray }
function Write-Warn($Text) { Write-Host "  [WARN] $Text" -ForegroundColor Yellow }
function Write-Fail($Text) { Write-Host "  [FAIL] $Text" -ForegroundColor Red }

function Test-Command($Name) {
    $null -ne (Get-Command $Name -ErrorAction SilentlyContinue)
}

Write-Section 'Claude Skills - Windows Installer'
Write-Host "Source : $RepoRawUrl"
Write-Host "Target : $SkillsDir"

# --- Step 1: Ensure target directory exists -----------------------------------
Write-Section 'Step 1 / 5 - Prepare Claude config directory'

if (-not (Test-Path $SkillsDir)) {
    New-Item -ItemType Directory -Path $SkillsDir -Force | Out-Null
    Write-Ok "Created $SkillsDir"
} else {
    Write-Ok "Found $SkillsDir"
}

# --- Step 2: Ensure uv is installed (needed by /project-wizard) ---------------
Write-Section 'Step 2 / 5 - Check / install uv'

if (Test-Command 'uv') {
    Write-Ok 'uv already installed'
} else {
    Write-Host '  uv not found - installing it now (needed by /project-wizard for speckit)...' -ForegroundColor Yellow
    try {
        Invoke-Expression (Invoke-RestMethod -Uri 'https://astral.sh/uv/install.ps1' -UseBasicParsing)

        # Refresh PATH for the current session so uv is reachable immediately
        $machinePath = [System.Environment]::GetEnvironmentVariable('Path', 'Machine')
        $userPath    = [System.Environment]::GetEnvironmentVariable('Path', 'User')
        $env:Path    = "$machinePath;$userPath"

        if (Test-Command 'uv') {
            Write-Ok 'uv installed and available'
        } else {
            Write-Warn 'uv installed but not yet on PATH - close and reopen PowerShell, then re-run this installer.'
        }
    }
    catch {
        Write-Fail "Could not install uv automatically: $($_.Exception.Message)"
        Write-Host '  Install it manually with:' -ForegroundColor Yellow
        Write-Host '    powershell -ExecutionPolicy Bypass -c "irm https://astral.sh/uv/install.ps1 | iex"' -ForegroundColor Yellow
    }
}

# --- Step 3: Download skills --------------------------------------------------
Write-Section 'Step 3 / 5 - Download skills from GitHub'

$installed = 0
foreach ($skill in $Skills) {
    $skillDir  = Join-Path $SkillsDir $skill
    $skillFile = Join-Path $skillDir  'SKILL.md'
    $sourceUrl = "$RepoRawUrl/$skill/SKILL.md"

    try {
        if (-not (Test-Path $skillDir)) {
            New-Item -ItemType Directory -Path $skillDir -Force | Out-Null
        }

        $response = Invoke-WebRequest -Uri $sourceUrl -UseBasicParsing -ErrorAction Stop
        [System.IO.File]::WriteAllText($skillFile, $response.Content, (New-Object System.Text.UTF8Encoding $false))
        Write-Ok "$skill -> $skillFile"
        $installed++
    }
    catch {
        Write-Fail "$skill - could not download from $sourceUrl"
        Write-Host "         $($_.Exception.Message)" -ForegroundColor Red
    }
}

if ($installed -eq 0) {
    Write-Host ''
    Write-Fail 'No skills were installed. Check your internet connection and try again.'
    exit 1
}

# --- Step 4: Check / install Claude Code --------------------------------------
Write-Section 'Step 4 / 5 - Check / install Claude Code'

if (Test-Command 'claude') {
    Write-Ok 'Claude Code CLI (claude) already installed'
} else {
    Write-Host '  Claude Code CLI not found - installing it now...' -ForegroundColor Yellow
    try {
        Invoke-Expression (Invoke-RestMethod -Uri 'https://claude.ai/install.ps1' -UseBasicParsing)

        # Refresh PATH for the current session so claude is reachable immediately
        $machinePath = [System.Environment]::GetEnvironmentVariable('Path', 'Machine')
        $userPath    = [System.Environment]::GetEnvironmentVariable('Path', 'User')
        $env:Path    = "$machinePath;$userPath"

        if (Test-Command 'claude') {
            Write-Ok 'Claude Code installed and available'
        } else {
            Write-Warn 'Claude Code installed but not yet on PATH - close and reopen PowerShell, then type "claude" to start.'
        }
    }
    catch {
        Write-Fail "Could not install Claude Code automatically: $($_.Exception.Message)"
        Write-Host '  Install it manually with:' -ForegroundColor Yellow
        Write-Host '    powershell -ExecutionPolicy Bypass -c "irm https://claude.ai/install.ps1 | iex"' -ForegroundColor Yellow
        Write-Host '  Or download from: https://claude.com/claude-code' -ForegroundColor Yellow
    }
}

# --- Step 5: Done -------------------------------------------------------------
Write-Section 'Step 5 / 5 - Done'

Write-Host ''
Write-Host "Installed $installed skill(s):" -ForegroundColor Green
foreach ($skill in $Skills) {
    $skillFile = Join-Path $SkillsDir "$skill\SKILL.md"
    if (Test-Path $skillFile) { Write-Host "  - /$skill" -ForegroundColor Green }
}

Write-Host ''
Write-Host 'Next steps:' -ForegroundColor Cyan
Write-Host '  1. cd into the folder where you keep your project screenshots / notes'
Write-Host '  2. Start Claude Code:        ' -NoNewline; Write-Host 'claude' -ForegroundColor White
Write-Host '  3. Run the wizard:           ' -NoNewline; Write-Host '/project-wizard' -ForegroundColor White
Write-Host '     (or, if you already have a project: ' -NoNewline; Write-Host '/project-update' -NoNewline -ForegroundColor White; Write-Host ')'
Write-Host ''
Write-Host 'Happy building!' -ForegroundColor Cyan
