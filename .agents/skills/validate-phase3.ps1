$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding          = [System.Text.Encoding]::UTF8

$pluginRoot = $PSScriptRoot   # .agents\skills
$failCount  = 0
$passCount  = 0
$tmpBase    = $null

# Save original env vars before isolation
$origUserProfile  = $env:USERPROFILE
$origHome         = $env:HOME
$origAppData      = $env:APPDATA
$origLocalAppData = $env:LOCALAPPDATA

function Assert-True {
    param([bool]$Condition, [string]$Label)
    if ($Condition) {
        Write-Host "  [OK] $Label" -ForegroundColor Green
        $script:passCount++
    } else {
        Write-Host "  [X] FAIL: $Label" -ForegroundColor Red
        $script:failCount++
    }
}

# Invoke an external command and never throw — captures stdout+stderr merged, returns exit code via [ref].
# Uses a background job with a timeout so a hanging CLI cannot block the script indefinitely.
function Invoke-Ext {
    param([string[]]$Cmd, [ref]$ExitCodeRef, [int]$TimeoutSec = 60)
    $exe     = $Cmd[0]
    $cmdArgs = if ($Cmd.Length -gt 1) { $Cmd[1..($Cmd.Length - 1)] } else { @() }
    try {
        $job = Start-Job -ScriptBlock {
            param($e, $a)
            $captured = & $e @a 2>&1
            [PSCustomObject]@{ Output = $captured; ExitCode = $LASTEXITCODE }
        } -ArgumentList $exe, $cmdArgs
        $completed = Wait-Job $job -Timeout $TimeoutSec
        if ($null -eq $completed) {
            Stop-Job  $job
            Remove-Job $job -Force
            $ExitCodeRef.Value = 1
            return "Invoke-Ext: command timed out after ${TimeoutSec}s"
        }
        $result = Receive-Job $job
        Remove-Job $job -Force
        $ExitCodeRef.Value = $result.ExitCode
        return ($result.Output | Out-String)
    } catch {
        $ExitCodeRef.Value = 1
        return $_.ToString()
    }
}

function Restore-Env {
    $env:USERPROFILE  = $script:origUserProfile
    $env:HOME         = $script:origHome
    $env:APPDATA      = $script:origAppData
    $env:LOCALAPPDATA = $script:origLocalAppData
}

function Cleanup {
    Restore-Env
    if ($script:tmpBase -and (Test-Path $script:tmpBase)) {
        Remove-Item $script:tmpBase -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "  [cleanup] removed temp dir" -ForegroundColor DarkGray
    }
}

$tmpBase = Join-Path $env:TEMP "phase3-$(Get-Random)"
New-Item -ItemType Directory -Path $tmpBase -Force | Out-Null

Write-Host "=== Phase 3 Validation: Real Installation (Isolated Environments) ===" -ForegroundColor Cyan
Write-Host "    plugin root: $pluginRoot" -ForegroundColor Blue
Write-Host "    temp base:   $tmpBase" -ForegroundColor Blue
Write-Host ""

try {

    # ── CHECK 1: Copilot positive – install succeeds ─────────────────────────
    Write-Host "-- Check 1: Copilot local-path plugin install (isolated --config-dir)" -ForegroundColor Blue
    $copilotConfigDir = Join-Path $tmpBase "copilot-config"
    New-Item -ItemType Directory -Path $copilotConfigDir -Force | Out-Null
    $c1Code = 0
    $c1Str  = Invoke-Ext @('copilot','plugin','install','--config-dir',$copilotConfigDir,$pluginRoot) ([ref]$c1Code)
    Assert-True ($c1Code -eq 0)                        "Copilot: plugin install exits 0"
    Assert-True ($c1Str  -match 'ai-research-skills')  "Copilot: install output mentions ai-research-skills"

    # ── CHECK 2: Copilot positive – list shows ai-research-skills ─────────────
    Write-Host "-- Check 2: Copilot plugin list shows ai-research-skills (isolated)" -ForegroundColor Blue
    $c2Code = 0
    $c2Str  = Invoke-Ext @('copilot','plugin','list','--config-dir',$copilotConfigDir) ([ref]$c2Code)
    Assert-True ($c2Code -eq 0)                        "Copilot: plugin list exits 0"
    Assert-True ($c2Str  -match 'ai-research-skills')  "Copilot: plugin list shows ai-research-skills"

    # ── CHECK 3: Copilot negative – invalid path fails ────────────────────────
    Write-Host "-- Check 3: Copilot install from invalid path fails (negative)" -ForegroundColor Blue
    $copilotBadDir = Join-Path $tmpBase "copilot-config-bad"
    New-Item -ItemType Directory -Path $copilotBadDir -Force | Out-Null
    $badPluginPath = Join-Path $tmpBase "nonexistent-plugin-xyz"
    $c3Code = 0
    $c3Str  = Invoke-Ext @('copilot','plugin','install','--config-dir',$copilotBadDir,$badPluginPath) ([ref]$c3Code)
    Assert-True ($c3Code -ne 0)                        "Copilot: invalid path install exits non-zero"
    Assert-True ($c3Str.Trim().Length -gt 0)           "Copilot: invalid path install produces error output"

    # ── Isolate Claude environment ─────────────────────────────────────────────
    $claudeHome      = Join-Path $tmpBase "claude-home"
    $claudeAppData   = Join-Path $claudeHome "AppData\Roaming"
    $claudeLocalData = Join-Path $claudeHome "AppData\Local"
    foreach ($d in @($claudeHome, $claudeAppData, $claudeLocalData)) {
        New-Item -ItemType Directory -Path $d -Force | Out-Null
    }
    $env:USERPROFILE  = $claudeHome
    $env:HOME         = $claudeHome
    $env:APPDATA      = $claudeAppData
    $env:LOCALAPPDATA = $claudeLocalData

    # ── Pre-flight: confirm isolated env has no prior ai-research-skills ─────────
    Write-Host "-- Pre-flight: Claude isolated env contains no ai-research-skills" -ForegroundColor Blue
    $pfCode = 0
    $pfStr  = Invoke-Ext @('claude','plugin','list','--json') ([ref]$pfCode)
    Assert-True ($pfStr -notmatch 'ai-research-skills') "Claude pre-flight: isolated env has no ai-research-skills"

    # ── CHECK 4: Claude positive – marketplace add succeeds (isolated) ─────────
    Write-Host "-- Check 4: Claude marketplace add succeeds (isolated HOME/APPDATA)" -ForegroundColor Blue
    $c4Code = 0
    $c4Str  = Invoke-Ext @('claude','plugin','marketplace','add',$pluginRoot,'--scope','user') ([ref]$c4Code)
    Assert-True ($c4Code -eq 0)                                              "Claude: marketplace add exits 0"
    Assert-True ($c4Str -match 'ai-research-plugins|ai-research-skills|marketplace|added|success') `
                                                                             "Claude: marketplace add output confirms registration"

    # ── CHECK 5: Claude positive – plugin install succeeds (isolated) ──────────
    Write-Host "-- Check 5: Claude plugin install succeeds (isolated)" -ForegroundColor Blue
    $c5Code = 0
    $c5Str  = Invoke-Ext @('claude','plugin','install','ai-research-skills@ai-research-plugins') ([ref]$c5Code)
    Assert-True ($c5Code -eq 0)                                                      "Claude: plugin install exits 0"
    Assert-True ($c5Str -match 'ai-research-skills|installed|success|Success')       "Claude: plugin install output confirms ai-research-skills"

    # ── CHECK 6: Claude positive – plugin list shows ai-research-skills ────────
    Write-Host "-- Check 6: Claude plugin list --json shows ai-research-skills (isolated)" -ForegroundColor Blue
    $c6Code = 0
    $c6Str  = Invoke-Ext @('claude','plugin','list','--json') ([ref]$c6Code)
    Assert-True ($c6Code -eq 0)                        "Claude: plugin list --json exits 0"
    Assert-True ($c6Str  -match 'ai-research-skills')  "Claude: plugin list includes ai-research-skills"

    # ── CHECK 7: Claude negative – malformed marketplace manifest fails ─────────
    Write-Host "-- Check 7: Claude rejects malformed marketplace manifest (negative)" -ForegroundColor Blue
    # Build a broken plugin root: marketplace.json missing required 'owner'
    $brokenRoot         = Join-Path $tmpBase "broken-plugin"
    $brokenClaudePlugin = Join-Path $brokenRoot ".claude-plugin"
    New-Item -ItemType Directory -Path $brokenClaudePlugin -Force | Out-Null
    @'
{
  "name": "broken-marketplace",
  "plugins": [
    { "name": "broken-plugin", "source": "./" }
  ]
}
'@ | Set-Content (Join-Path $brokenClaudePlugin "marketplace.json") -Encoding UTF8

    # Fresh isolated home so previously-added marketplace doesn't mask the error
    $brokenHome      = Join-Path $tmpBase "claude-home-bad"
    $brokenAppData   = Join-Path $brokenHome "AppData\Roaming"
    $brokenLocalData = Join-Path $brokenHome "AppData\Local"
    foreach ($d in @($brokenHome, $brokenAppData, $brokenLocalData)) {
        New-Item -ItemType Directory -Path $d -Force | Out-Null
    }
    $env:USERPROFILE  = $brokenHome
    $env:HOME         = $brokenHome
    $env:APPDATA      = $brokenAppData
    $env:LOCALAPPDATA = $brokenLocalData

    $c7Code = 0
    $c7Str  = Invoke-Ext @('claude','plugin','marketplace','add',$brokenRoot,'--scope','user') ([ref]$c7Code)
    Assert-True ($c7Code -ne 0)                                          "Claude: malformed marketplace exits non-zero"
    Assert-True ($c7Str -match 'owner|schema|Invalid|invalid|missing|required') `
                                                                         "Claude: malformed marketplace error mentions schema/owner/invalid"

} finally {
    Cleanup
}

# ── Summary ───────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "--- Summary ---" -ForegroundColor Blue
Write-Host "  Passed: $passCount" -ForegroundColor Green
Write-Host "  Failed: $failCount" -ForegroundColor Red

if ($failCount -gt 0) { exit 1 }
Write-Host ""
Write-Host "[OK] All Phase 3 checks passed!" -ForegroundColor Green
exit 0

