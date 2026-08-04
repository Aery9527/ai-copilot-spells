#Requires -Version 5.1
<#
.SYNOPSIS
    Bootstrap Codex CLI on this machine: npm, the Codex CLI, then the pet sprites.

.DESCRIPTION
    1. Ensures npm is available: installs Node.js LTS via winget if missing,
       or runs `winget upgrade` on the existing Node.js LTS package if npm was installed via winget.
    2. Installs/updates the Codex CLI via `npm install -g @openai/codex`.
    3. Copies pets\ (next to this script) to ~/.codex/pets/.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\cli-agents\codex\install-cx.ps1
#>

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$nodePackageId = 'OpenJS.NodeJS.LTS'

Write-Host '=== Step 1: npm ===' -ForegroundColor Cyan

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host '  [X] ERROR: winget not found. Install Node.js manually, then re-run this script.' -ForegroundColor Red
    exit 1
}

if (Get-Command npm -ErrorAction SilentlyContinue) {
    winget list -e --id $nodePackageId | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host '  [!] npm already installed via winget, checking for updates...' -ForegroundColor Yellow
        winget upgrade -e --id $nodePackageId --silent --accept-package-agreements --accept-source-agreements
        if ($LASTEXITCODE -eq 0) {
            Write-Host '  [OK] Node.js/npm is up to date.' -ForegroundColor Green
        } else {
            Write-Host "  [!] winget upgrade exited with code $LASTEXITCODE (likely already the latest version)." -ForegroundColor Yellow
        }
    } else {
        Write-Host '  [!] npm already installed but not via winget (e.g. nvm or a manual install) - leaving it as-is, no update attempted.' -ForegroundColor Yellow
    }
} else {
    Write-Host '  [!] npm not found, installing Node.js LTS via winget...' -ForegroundColor Yellow
    winget install -e --id $nodePackageId --silent --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  [X] ERROR: winget install failed with code $LASTEXITCODE (if this is a machine-scope install, try re-running from an elevated terminal)" -ForegroundColor Red
        exit 1
    }
    Write-Host '  [OK] Node.js/npm installed.' -ForegroundColor Green
}

# winget updates the machine/user PATH in the registry, not this process's $env:Path;
# append the fresh values so a newly installed npm is usable without opening a new terminal.
$env:Path = "$env:Path;$([System.Environment]::GetEnvironmentVariable('Path', 'Machine'));$([System.Environment]::GetEnvironmentVariable('Path', 'User'))"

if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
    Write-Host '  [X] ERROR: npm still not found after installation. Open a new terminal and re-run this script.' -ForegroundColor Red
    exit 1
}

Write-Host '=== Step 2: Codex CLI ===' -ForegroundColor Cyan
npm install -g @openai/codex
if ($LASTEXITCODE -ne 0) {
    Write-Host "  [X] ERROR: npm install -g @openai/codex failed with code $LASTEXITCODE" -ForegroundColor Red
    exit 1
}
Write-Host '  [OK] Codex CLI installed/updated.' -ForegroundColor Green

Write-Host '=== Step 3: pets ===' -ForegroundColor Cyan
$petsSrc = Join-Path $PSScriptRoot 'pets'
$petsDst = Join-Path $env:USERPROFILE '.codex\pets'

if (-not (Test-Path -LiteralPath $petsSrc -PathType Container)) {
    Write-Host "  [X] ERROR: pets source not found: $petsSrc" -ForegroundColor Red
    exit 1
}
New-Item -ItemType Directory -Path $petsDst -Force | Out-Null
Copy-Item -Path (Join-Path $petsSrc '*') -Destination $petsDst -Recurse -Force
Write-Host "  [OK] Copied: $petsSrc -> $petsDst" -ForegroundColor Green

Write-Host ''
Write-Host 'Done.' -ForegroundColor Green
