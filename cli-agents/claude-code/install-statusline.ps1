#Requires -Version 5.1
<#
.SYNOPSIS
    Install the statusLine configuration and state-tracking hooks to ~/.claude.

.DESCRIPTION
    1. Copies statusline-command.sh (next to this script) to ~/.claude/statusline-command.sh
    2. Copies hooks/*.sh (next to this script) to ~/.claude/hooks/
    3. Injects the statusLine key into ~/.claude/settings.json
    4. Injects UserPromptSubmit / PreToolUse / Stop hooks for real-time state tracking,
       registered in exec form (bash.exe + args, no shell wrapper) so the hook process
       is spawned directly by Claude Code rather than nested inside another bash.exe —
       MSYS2's CreateProcess(SUSPENDED) fork emulation can leave a permanent zombie if
       the outer process is torn down mid-suspend, and one fewer nesting layer is one
       fewer place that can happen.

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

# --- Locate a real Git-for-Windows bash.exe ---
# Exec-form hands `command` straight to CreateProcess with no shell involved, so it must
# resolve to one specific real bash.exe, not just "something on PATH named bash.exe":
#   - WSL ships C:\Windows\System32\bash.exe as a distro launcher; it can't run a Windows
#     path like this script's absolute hook path, so silently picking it breaks the hook.
#   - Package-manager shims (scoop/choco) can put a wrapper on PATH whose directory has
#     no sibling git.exe, so it isn't a real Git-for-Windows install.
# A trustworthy candidate has a git.exe next to it and lives outside the WSL launcher dir.
function Find-GitBash {
    $candidates = [System.Collections.Generic.List[string]]::new()

    $gitCmd = Get-Command git.exe -ErrorAction SilentlyContinue
    if ($gitCmd) {
        $gitDir = Split-Path -Parent $gitCmd.Source
        $candidates.Add((Join-Path $gitDir 'bash.exe'))       # Git\bin\git.exe layout
        $candidates.Add((Join-Path $gitDir '..\bin\bash.exe')) # Git\cmd\git.exe layout
    }

    $bashCmd = Get-Command bash.exe -ErrorAction SilentlyContinue
    if ($bashCmd) { $candidates.Add($bashCmd.Source) }

    foreach ($base in @($env:ProgramFiles, ${env:ProgramFiles(x86)}, (Join-Path $env:LOCALAPPDATA 'Programs'))) {
        if ($base) { $candidates.Add((Join-Path $base 'Git\bin\bash.exe')) }
    }

    foreach ($c in $candidates) {
        $resolved = $null
        try { $resolved = (Resolve-Path -LiteralPath $c -ErrorAction Stop).Path } catch { continue }
        if ($resolved.StartsWith($env:SystemRoot, [StringComparison]::OrdinalIgnoreCase)) { continue }
        $siblingGit = Join-Path (Split-Path -Parent $resolved) 'git.exe'
        if (Test-Path -LiteralPath $siblingGit) { return $resolved }
    }
    return $null
}

$gitBash = Find-GitBash
if (-not $gitBash) {
    Write-Error 'Git for Windows (bash.exe) not found. Install it from https://git-scm.com/download/win, then re-run this script.'
    exit 1
}
Write-Host "Using  : $gitBash"

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
        # $switchSrc captures $_.FullName before the switch: `switch ($result)` rebinds
        # $_ to $result (a plain string) inside its own script blocks, so reading
        # $_.FullName there would silently resolve to empty instead of the source path.
        $switchSrc = $_.FullName
        $dst       = Join-Path $hooksDstDir $_.Name
        $result    = Copy-ShFile -Src $switchSrc -Dst $dst -Force:$Force
        switch ($result) {
            'Copied'  { Write-Host "Copied : $switchSrc -> $dst" }
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

# --- Inject state-tracking hooks (exec form: command=bash.exe, args=[absolute script path]) ---
$hookScripts = @(
    @{ Event = 'UserPromptSubmit'; File = 'state-running.sh' },
    @{ Event = 'PreToolUse';       File = 'state-running.sh' },
    @{ Event = 'Stop';             File = 'state-idle.sh' }
)

if (-not $settings.PSObject.Properties['hooks']) {
    $settings | Add-Member -MemberType NoteProperty -Name 'hooks' -Value ([PSCustomObject]@{})
}

$hooksBefore = $settings.hooks | ConvertTo-Json -Depth 100 -Compress

foreach ($item in $hookScripts) {
    $eventName  = $item.Event
    $scriptPath = Join-Path $hooksDstDir $item.File

    if (-not (Test-Path -LiteralPath $scriptPath)) {
        Write-Error "$scriptPath not found - hooks/ was not copied, refusing to register a dangling hook."
        exit 1
    }

    if ($null -eq $settings.hooks.PSObject.Properties[$eventName]) {
        $settings.hooks | Add-Member -MemberType NoteProperty -Name $eventName -Value @()
    }

    $entries = [System.Collections.Generic.List[object]]::new()
    foreach ($e in @($settings.hooks.($eventName))) { $entries.Add($e) }

    # Exact-match identity, not a basename wildcard: a wildcard on just the filename would
    # also match an unrelated third-party hook that happens to reference a same-named
    # script somewhere else, and silently delete it. $legacyCmd is the one literal string
    # this installer has ever written for shell-form; $scriptPath is this exact machine's
    # canonical destination path for exec-form.
    $legacyCmd = "bash ~/.claude/hooks/$($item.File)"
    $isOurs = {
        param($h)
        if ($h.command -eq $legacyCmd) { return $true }
        if ($h.args -and @($h.args).Count -ge 1 -and @($h.args)[0] -eq $scriptPath) { return $true }
        return $false
    }

    # Always rebuild rather than "add if not already correct": drop every handler this
    # installer owns for this script, then re-add exactly one fresh, correct entry. This
    # is what keeps re-running safe as "correct" changes over time (e.g. bash.exe moves
    # after a Git for Windows update) — there's no separate "is it already right" check
    # that can itself go stale or under-match and leave a duplicate behind.
    $rebuilt = [System.Collections.Generic.List[object]]::new()
    foreach ($entry in $entries) {
        if ($null -eq $entry.hooks) { $rebuilt.Add($entry); continue }
        $kept = [System.Collections.Generic.List[object]]::new()
        foreach ($h in @($entry.hooks)) {
            if (-not (& $isOurs $h)) { $kept.Add($h) }
        }
        if ($kept.Count -gt 0) {
            $entry.hooks = $kept.ToArray()
            $rebuilt.Add($entry)
        }
    }

    $newEntry = [PSCustomObject]@{
        hooks = @(
            [PSCustomObject]@{
                type    = 'command'
                command = $gitBash
                args    = @($scriptPath)
                timeout = 20
            }
        )
    }
    $rebuilt.Add($newEntry)

    $settings.hooks | Add-Member -MemberType NoteProperty -Name $eventName -Value $rebuilt.ToArray() -Force
}

$hooksAfter = $settings.hooks | ConvertTo-Json -Depth 100 -Compress
if ($hooksBefore -ne $hooksAfter) {
    Write-Host "Updated: hooks in $settingsPath"
} else {
    Write-Host "Skipped: hooks already configured in $settingsPath"
}

# --- Save settings.json ---
$settings | ConvertTo-Json -Depth 100 | Set-Content -Path $settingsPath -Encoding UTF8

Write-Host ''
Write-Host 'Done. Status line and state-tracking hooks are now active for all Claude Code sessions.'
