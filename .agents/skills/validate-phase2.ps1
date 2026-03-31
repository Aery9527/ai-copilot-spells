$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding          = [System.Text.Encoding]::UTF8

$pluginRoot = $PSScriptRoot   # .agents\skills
$repoRoot   = Split-Path (Split-Path $pluginRoot -Parent) -Parent
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

Write-Host "=== Phase 2 Validation: Repo Documentation & Install Guidance ===" -ForegroundColor Cyan
Write-Host "    repo root:   $repoRoot" -ForegroundColor Blue
Write-Host "    plugin root: $pluginRoot" -ForegroundColor Blue
Write-Host ""

# ── Load file contents up-front ───────────────────────────────────────────────
$pluginReadme = Join-Path $pluginRoot "README.md"
$rootReadme   = Join-Path $repoRoot  "README.md"
$agentsMd     = Join-Path $repoRoot  "AGENTS.md"

$pluginReadmeContent = if (Test-Path $pluginReadme -PathType Leaf) { Get-Content $pluginReadme -Raw -Encoding UTF8 } else { '' }
$rootContent         = if (Test-Path $rootReadme   -PathType Leaf) { Get-Content $rootReadme   -Raw -Encoding UTF8 } else { '' }
$agentsContent       = if (Test-Path $agentsMd     -PathType Leaf) { Get-Content $agentsMd     -Raw -Encoding UTF8 } else { '' }

# ── 1. .agents\skills\README.md exists ───────────────────────────────────────
Write-Host "-- Check 1: .agents\skills\README.md exists" -ForegroundColor Blue
Assert-True (Test-Path $pluginReadme -PathType Leaf) ".agents\skills\README.md exists"

# ── 2. Plugin README contains GitHub Copilot install guidance ────────────────
Write-Host "-- Check 2: plugin README – GitHub Copilot install guidance" -ForegroundColor Blue
Assert-True ($pluginReadmeContent -match 'copilot plugin install') `
    "plugin README contains 'copilot plugin install'"
Assert-True ($pluginReadmeContent -match '\.agents/skills|\.agents\\skills') `
    "plugin README references .agents/skills path in install command"

# ── 3. Plugin README contains Claude Code install guidance ───────────────────
Write-Host "-- Check 3: plugin README – Claude Code install guidance" -ForegroundColor Blue
Assert-True ($pluginReadmeContent -match '/plugin marketplace add') `
    "plugin README contains '/plugin marketplace add'"
Assert-True ($pluginReadmeContent -match 'ai-research-skills') `
    "plugin README mentions 'ai-research-skills'"
Assert-True ($pluginReadmeContent -match '/plugin install') `
    "plugin README contains '/plugin install'"

# ── 4. Root README.md mentions ai-research-skills ────────────────────────────
Write-Host "-- Check 4: root README.md mentions ai-research-skills" -ForegroundColor Blue
Assert-True (Test-Path $rootReadme -PathType Leaf) "root README.md exists"
Assert-True ($rootContent -match 'ai-research-skills') `
    "root README.md mentions 'ai-research-skills'"

# ── 5. Root README.md links to .agents/skills/README.md ─────────────────────
Write-Host "-- Check 5: root README.md links to plugin README" -ForegroundColor Blue
Assert-True ($rootContent -match '\.agents/skills/README\.md|\.agents\\skills\\README\.md') `
    "root README.md links to .agents/skills/README.md"

# ── 6. Root README.md describes .agents/skills as plugin root (not flat dir) ─
Write-Host "-- Check 6: root README.md describes .agents/skills as plugin root" -ForegroundColor Blue
# At least one line referencing .agents/skills must also mention 'plugin'
$agentsSkillsLines  = ($rootContent -split "`n") | Where-Object { $_ -match '\.agents[/\\]skills' }
$linesMentionPlugin = ($agentsSkillsLines | Where-Object { $_ -match 'plugin' }).Count -gt 0
Assert-True $linesMentionPlugin `
    "root README.md: a line referencing .agents/skills also mentions 'plugin'"
# Must NOT still show the old flat layout (individual skill dirs directly under .agents/skills)
$hasOldFlatLayout = $rootContent -match '\.agents/skills/mongo|\.agents/skills/plan-extension|\.agents/skills/windows-script|\.agents/skills/write-md'
Assert-True (-not $hasOldFlatLayout) `
    "root README.md does NOT document old flat skill dirs directly under .agents/skills"

# ── 7. Root README directory tree shows plugin-oriented entries ──────────────
Write-Host "-- Check 7: root README directory tree shows plugin entries" -ForegroundColor Blue
Assert-True ($rootContent -match 'plugin\.json') `
    "root README directory tree shows plugin.json under .agents/skills"
Assert-True ($rootContent -match '\.claude-plugin') `
    "root README directory tree shows .claude-plugin under .agents/skills"

# ── 8. AGENTS.md .agents/skills row mentions plugin-root or ai-research-skills ─
Write-Host "-- Check 8: AGENTS.md .agents/skills row – plugin-root semantics" -ForegroundColor Blue
Assert-True (Test-Path $agentsMd -PathType Leaf) "AGENTS.md exists"
$agentsSkillsRows  = ($agentsContent -split "`n") | Where-Object { $_ -match '\.agents/skills/' -and $_ -match '\|' }
$rowMentionsPlugin = ($agentsSkillsRows | Where-Object { $_ -match 'plugin|ai-research-skills' }).Count -gt 0
Assert-True $rowMentionsPlugin `
    "AGENTS.md: .agents/skills/ row mentions 'plugin' or 'ai-research-skills'"

# ── Summary ───────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "--- Summary ---" -ForegroundColor Blue
Write-Host "  Passed: $passCount" -ForegroundColor Green
Write-Host "  Failed: $failCount" -ForegroundColor Red

if ($failCount -gt 0) { exit 1 }
Write-Host ""
Write-Host "[OK] All Phase 2 checks passed!" -ForegroundColor Green
exit 0
