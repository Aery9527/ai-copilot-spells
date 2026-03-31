$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding          = [System.Text.Encoding]::UTF8

$pluginRoot = $PSScriptRoot   # .agents\skills
$failCount  = 0
$passCount  = 0

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

Write-Host "=== Phase 1 Validation: Shared Plugin Root & Metadata ===" -ForegroundColor Cyan
Write-Host "    plugin root: $pluginRoot" -ForegroundColor Blue
Write-Host ""

# ── 1. shared skills\ directory ─────────────────────────────────────────────
Write-Host "-- Check 1: shared skills\ directory" -ForegroundColor Blue
$skillsDir = Join-Path $pluginRoot "skills"
Assert-True (Test-Path $skillsDir -PathType Container) "skills\ directory exists under plugin root"

# ── 2. exactly the four required skill entries ────────────────────────────
Write-Host "-- Check 2: required skill sub-directories" -ForegroundColor Blue
$requiredSkills = @('mongo', 'plan-extension', 'windows-script', 'write-md')
foreach ($skill in $requiredSkills) {
    $p = Join-Path $skillsDir $skill
    Assert-True (Test-Path $p -PathType Container) "skills\$skill\ exists"
    # each skill directory must contain a SKILL.md file specifically
    if (Test-Path $p -PathType Container) {
        $skillMd = Join-Path $p 'SKILL.md'
        Assert-True (Test-Path $skillMd -PathType Leaf) "skills\$skill\SKILL.md exists"
    }
}

# ── 3. GitHub Copilot plugin.json ────────────────────────────────────────
Write-Host "-- Check 3: Copilot plugin.json" -ForegroundColor Blue
$copilotPlugin = Join-Path $pluginRoot "plugin.json"
Assert-True (Test-Path $copilotPlugin -PathType Leaf) "plugin.json exists"
if (Test-Path $copilotPlugin -PathType Leaf) {
    try {
        $pj = Get-Content $copilotPlugin -Raw | ConvertFrom-Json
        Assert-True ($pj.name    -eq 'ai-research-skills') "plugin.json: name = ai-research-skills"
        Assert-True ($pj.version -eq '0.1.0')              "plugin.json: version = 0.1.0"
        # skills path must resolve to an existing directory
        if ($pj.skills) {
            $resolvedSkillsDir = Join-Path $pluginRoot ($pj.skills -replace '/', '\')
            Assert-True (Test-Path $resolvedSkillsDir -PathType Container) "plugin.json: skills path resolves to existing directory"
        }
    } catch {
        Write-Host "  [X] FAIL: plugin.json is not valid JSON" -ForegroundColor Red
        $script:failCount++
    }
}

# ── 4. Claude Code .claude-plugin\plugin.json ─────────────────────────────
Write-Host "-- Check 4: Claude Code .claude-plugin\plugin.json" -ForegroundColor Blue
$claudePlugin = Join-Path (Join-Path $pluginRoot ".claude-plugin") "plugin.json"
Assert-True (Test-Path $claudePlugin -PathType Leaf) ".claude-plugin\plugin.json exists"
if (Test-Path $claudePlugin -PathType Leaf) {
    try {
        $cpj = Get-Content $claudePlugin -Raw | ConvertFrom-Json
        Assert-True ($cpj.name    -eq 'ai-research-skills') ".claude-plugin\plugin.json: name = ai-research-skills"
        Assert-True ($cpj.version -eq '0.1.0')              ".claude-plugin\plugin.json: version = 0.1.0"
        # skills path(s) must start with ./ per Claude Code requirement
        $skillPaths = @($cpj.skills)
        $allRelative = $true
        $allExist    = $true
        foreach ($sp in $skillPaths) {
            if (-not ($sp -like './*')) { $allRelative = $false }
            # resolve relative to .claude-plugin parent (the plugin root)
            $resolvedSp = Join-Path $pluginRoot (($sp -replace '^\./', '') -replace '/', '\')
            if (-not (Test-Path $resolvedSp -PathType Container)) { $allExist = $false }
        }
        Assert-True $allRelative ".claude-plugin\plugin.json: all skill paths start with ./"
        Assert-True $allExist    ".claude-plugin\plugin.json: all skill paths resolve to existing directories"
    } catch {
        Write-Host "  [X] FAIL: .claude-plugin\plugin.json is not valid JSON" -ForegroundColor Red
        $script:failCount++
    }
}

# ── 5. Claude Code .claude-plugin\marketplace.json ────────────────────────
Write-Host "-- Check 5: Claude Code .claude-plugin\marketplace.json" -ForegroundColor Blue
$marketplace = Join-Path (Join-Path $pluginRoot ".claude-plugin") "marketplace.json"
Assert-True (Test-Path $marketplace -PathType Leaf) ".claude-plugin\marketplace.json exists"
if (Test-Path $marketplace -PathType Leaf) {
    try {
        $mj = Get-Content $marketplace -Raw | ConvertFrom-Json
        Assert-True ($mj.name -eq 'ai-research-plugins') "marketplace.json: name = ai-research-plugins"
        # Required by Claude marketplace schema: owner must be an object (non-null)
        Assert-True ($null -ne $mj.owner -and $mj.owner -is [PSCustomObject]) `
            "marketplace.json: owner object is present"
        Assert-True (-not [string]::IsNullOrWhiteSpace($mj.owner.name)) `
            "marketplace.json: owner.name is non-empty"
        # plugins array must have exactly one entry (single-bundle expectation)
        $pluginEntries = @($mj.plugins)
        Assert-True ($pluginEntries.Count -eq 1) "marketplace.json: plugins array has exactly 1 entry"
        $entry = $pluginEntries | Where-Object { $_.source -eq './' }
        Assert-True ($null -ne $entry) "marketplace.json: plugin entry with source = ./"
        Assert-True ($entry.name -eq 'ai-research-skills') "marketplace.json: plugin entry name = ai-research-skills"
    } catch {
        Write-Host "  [X] FAIL: .claude-plugin\marketplace.json is not valid JSON" -ForegroundColor Red
        $script:failCount++
    }
}

# ── 6. No old top-level skill directories (no backward compat layout) ─────
Write-Host "-- Check 6: old top-level skill dirs removed" -ForegroundColor Blue
foreach ($skill in $requiredSkills) {
    $old = Join-Path $pluginRoot $skill
    Assert-True (-not (Test-Path $old -PathType Container)) "Old top-level $skill\ does NOT exist"
}

# ── Summary ───────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "--- Summary ---" -ForegroundColor Blue
Write-Host "  Passed: $passCount" -ForegroundColor Green
Write-Host "  Failed: $failCount" -ForegroundColor Red

if ($failCount -gt 0) { exit 1 }
Write-Host ""
Write-Host "[OK] All Phase 1 checks passed!" -ForegroundColor Green
exit 0
