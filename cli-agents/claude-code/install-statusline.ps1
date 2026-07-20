#Requires -Version 5.1
<#
.SYNOPSIS
    Install the statusLine configuration and state-tracking hooks to ~/.claude.

.DESCRIPTION
    1. Copies statusline-command.sh (next to this script) to ~/.claude/statusline-command.sh
    2. Copies hooks/*.sh (next to this script) to ~/.claude/hooks/
    3. Injects the statusLine key into ~/.claude/settings.json
    4. Injects UserPromptSubmit / PreToolUse / Stop hooks for real-time state tracking

    After running, the status line shows accurate execution state (執行中 / 等待指示)
    powered by lifecycle hooks, for all Claude Code sessions on this machine.

.PARAMETER Force
    Overwrite all target .sh files even if they already match the source.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\cli-agents\claude-code\install-statusline.ps1
#>

[CmdletBinding()]
param(
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

# Some environments disable module autoloading, which hides Get-FileHash /
# ConvertFrom-Json / ConvertTo-Json (all in Microsoft.PowerShell.Utility).
Import-Module Microsoft.PowerShell.Utility -ErrorAction SilentlyContinue

# --- Paths ---
$shSrc        = Join-Path $PSScriptRoot 'statusline-command.sh'
$hooksSrcDir  = Join-Path $PSScriptRoot 'hooks'
$claudeDir    = Join-Path $env:USERPROFILE '.claude'
$shDst        = Join-Path $claudeDir 'statusline-command.sh'
$hooksDstDir  = Join-Path $claudeDir 'hooks'
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

# --- Helper: copy sh file with hash check ---
function Copy-ShFile {
    param([string]$Src, [string]$Dst, [switch]$Force)
    if ($Force -or -not (Test-Path $Dst)) {
        Copy-Item -Path $Src -Destination $Dst -Force
        return 'Copied'
    }
    $srcHash = (Get-FileHash $Src -Algorithm SHA256).Hash
    $dstHash = (Get-FileHash $Dst -Algorithm SHA256).Hash
    if ($srcHash -ne $dstHash) {
        Copy-Item -Path $Src -Destination $Dst -Force
        return 'Updated'
    }
    return 'Skipped'
}

# --- Copy statusline-command.sh ---
$result = Copy-ShFile -Src $shSrc -Dst $shDst -Force:$Force
switch ($result) {
    'Copied'  { Write-Host "Copied : $shSrc -> $shDst" }
    'Updated' { Write-Host "Updated: $shDst" }
    'Skipped' { Write-Host "Skipped: $shDst (already up-to-date)" }
}

# --- Copy hook scripts ---
if (Test-Path $hooksSrcDir) {
    if (-not (Test-Path $hooksDstDir)) {
        New-Item -ItemType Directory -Path $hooksDstDir | Out-Null
        Write-Host "Created: $hooksDstDir"
    }
    Get-ChildItem -Path $hooksSrcDir -Filter '*.sh' | ForEach-Object {
        $dst    = Join-Path $hooksDstDir $_.Name
        $result = Copy-ShFile -Src $_.FullName -Dst $dst -Force:$Force
        switch ($result) {
            'Copied'  { Write-Host "Copied : $($_.FullName) -> $dst" }
            'Updated' { Write-Host "Updated: $dst" }
            'Skipped' { Write-Host "Skipped: $dst (already up-to-date)" }
        }
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
    Write-Host "Updated: statusLine in $settingsPath"
} else {
    $settings | Add-Member -MemberType NoteProperty -Name 'statusLine' -Value $statusLine
    Write-Host "Added  : statusLine in $settingsPath"
}

# --- Inject state-tracking hooks ---
# Format: @(event, command)
$stateHooks = @(
    @('UserPromptSubmit', 'bash ~/.claude/hooks/state-running.sh'),
    @('PreToolUse',       'bash ~/.claude/hooks/state-running.sh'),
    @('Stop',             'bash ~/.claude/hooks/state-idle.sh')
)

if (-not $settings.PSObject.Properties['hooks']) {
    $settings | Add-Member -MemberType NoteProperty -Name 'hooks' -Value ([PSCustomObject]@{})
}

$hooksChanged = $false
foreach ($pair in $stateHooks) {
    $eventName = $pair[0]
    $cmd       = $pair[1]
    $newEntry  = [PSCustomObject]@{
        hooks = @([PSCustomObject]@{ type = 'command'; command = $cmd })
    }

    if ($null -eq $settings.hooks.PSObject.Properties[$eventName]) {
        # Event not present — add fresh
        $settings.hooks | Add-Member -MemberType NoteProperty -Name $eventName -Value @($newEntry)
        $hooksChanged = $true
    } else {
        # Event exists — check if our command is already registered
        $alreadyPresent = $false
        foreach ($entry in @($settings.hooks.($eventName))) {
            if ($null -ne $entry.hooks) {
                foreach ($h in @($entry.hooks)) {
                    if ($h.command -eq $cmd) { $alreadyPresent = $true; break }
                }
            }
            if ($alreadyPresent) { break }
        }
        if (-not $alreadyPresent) {
            # Append without disturbing existing entries
            $list = [System.Collections.Generic.List[object]]::new()
            foreach ($e in @($settings.hooks.($eventName))) { $list.Add($e) }
            $list.Add($newEntry)
            $settings.hooks | Add-Member -MemberType NoteProperty -Name $eventName `
                -Value $list.ToArray() -Force
            $hooksChanged = $true
        }
    }
}

if ($hooksChanged) {
    Write-Host "Updated: hooks in $settingsPath"
} else {
    Write-Host "Skipped: hooks already configured in $settingsPath"
}

# --- Save settings.json ---
$settings | ConvertTo-Json -Depth 10 | Set-Content -Path $settingsPath -Encoding UTF8

Write-Host ''
Write-Host 'Done. Status line and state-tracking hooks are now active for all Claude Code sessions.'
