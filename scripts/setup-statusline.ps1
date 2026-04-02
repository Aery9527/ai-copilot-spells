#Requires -Version 5.1
<#
.SYNOPSIS
    Install the statusLine configuration to ~/.claude/settings.json and deploy the statusline script.

.DESCRIPTION
    1. Copies .claude/statusline-command.sh from this repo to ~/.claude/
    2. Injects the statusLine key into ~/.claude/settings.json (creates the file if absent)

    After running, the status line is active for all Claude Code sessions on this machine.

.PARAMETER Force
    Overwrite ~/.claude/statusline-command.sh even if it already matches the source.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\scripts\setup-statusline.ps1
#>

[CmdletBinding()]
param(
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

# --- Paths ---
$repoRoot   = Split-Path $PSScriptRoot -Parent
$shSrc      = Join-Path $repoRoot '.claude\statusline-command.sh'
$claudeDir  = Join-Path $env:USERPROFILE '.claude'
$shDst      = Join-Path $claudeDir 'statusline-command.sh'
$settingsPath = Join-Path $claudeDir 'settings.json'

# --- Validate source ---
if (-not (Test-Path $shSrc)) {
    Write-Error "Source not found: $shSrc"
    exit 1
}

# --- Ensure ~/.claude exists ---
if (-not (Test-Path $claudeDir)) {
    New-Item -ItemType Directory -Path $claudeDir | Out-Null
    Write-Host "Created: $claudeDir"
}

# --- Copy statusline-command.sh ---
if ($Force -or -not (Test-Path $shDst)) {
    Copy-Item -Path $shSrc -Destination $shDst -Force
    Write-Host "Copied : $shSrc -> $shDst"
} else {
    $srcHash = (Get-FileHash $shSrc -Algorithm SHA256).Hash
    $dstHash = (Get-FileHash $shDst -Algorithm SHA256).Hash
    if ($srcHash -ne $dstHash) {
        Copy-Item -Path $shSrc -Destination $shDst -Force
        Write-Host "Updated: $shDst"
    } else {
        Write-Host "Skipped: $shDst (already up-to-date)"
    }
}

# --- Read or initialise settings.json ---
if (Test-Path $settingsPath) {
    $raw = Get-Content -Path $settingsPath -Raw -Encoding UTF8
    if ([string]::IsNullOrWhiteSpace($raw)) {
        $settings = [PSCustomObject]@{}
    } else {
        try {
            $settings = $raw | ConvertFrom-Json
        } catch {
            Write-Error "Failed to parse ${settingsPath}: $_"
            exit 1
        }
    }
} else {
    $settings = [PSCustomObject]@{}
}

# --- Inject statusLine ---
$statusLine = [PSCustomObject]@{
    type    = 'command'
    command = 'bash ~/.claude/statusline-command.sh'
}

if ($settings.PSObject.Properties['statusLine']) {
    $settings.statusLine = $statusLine
    $action = 'Updated'
} else {
    $settings | Add-Member -MemberType NoteProperty -Name 'statusLine' -Value $statusLine
    $action = 'Added'
}

$settings | ConvertTo-Json -Depth 10 | Set-Content -Path $settingsPath -Encoding UTF8
Write-Host "${action}: statusLine in $settingsPath"

Write-Host ''
Write-Host 'Done. Status line is now active for all Claude Code sessions.'
