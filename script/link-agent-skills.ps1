# ===========================================
# Agent Skills Linker (PowerShell)
# 建立 .agents/skills → .claude/skills 的 junction
#
# 用法:
#   .\script\link-agent-skills.ps1    互動式選單
# ===========================================

$repoRoot     = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$claudeSkills = Join-Path $repoRoot ".claude\skills"   # 真實目錄（source）
$agentsSkills = Join-Path $repoRoot ".agents\skills"   # junction 位置（target）
$gitignore    = Join-Path $repoRoot ".gitignore"

# ---------------------------------------------------------------------------
# Helper: Add entry to .gitignore (if not already present)
# ---------------------------------------------------------------------------
function Add-GitignoreEntry {
    param([string]$Entry)
    if (-not (Test-Path $gitignore)) {
        Set-Content -Path $gitignore -Value $Entry
        Write-Host "  [OK] Added '$Entry' to .gitignore" -ForegroundColor Green
        return
    }
    $lines = Get-Content $gitignore -Raw
    $lineList = $lines -split "`n" | ForEach-Object { $_.TrimEnd("`r") }
    if ($lineList -notcontains $Entry) {
        Add-Content -Path $gitignore -Value $Entry
        Write-Host "  [OK] Added '$Entry' to .gitignore" -ForegroundColor Green
    } else {
        Write-Host "  [--] '$Entry' already in .gitignore" -ForegroundColor Yellow
    }
}

# ---------------------------------------------------------------------------
# Helper: Remove entry from .gitignore
# ---------------------------------------------------------------------------
function Remove-GitignoreEntry {
    param([string]$Entry)
    if (-not (Test-Path $gitignore)) { return }
    $lines = Get-Content $gitignore
    $newLines = $lines | Where-Object { $_ -ne $Entry }
    if ($lines.Count -ne $newLines.Count) {
        Set-Content -Path $gitignore -Value $newLines
        Write-Host "  [OK] Removed '$Entry' from .gitignore" -ForegroundColor Green
    }
}

# ---------------------------------------------------------------------------
# Menu
# ---------------------------------------------------------------------------
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "   Agent Skills Linker" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  真實目錄: .claude\skills" -ForegroundColor Blue
Write-Host "  Junction:  .agents\skills  ->  .claude\skills" -ForegroundColor Blue
Write-Host ""
Write-Host "  [0] 取消" -ForegroundColor Yellow
Write-Host "  [1] 將整個 .agents/skills 連結至 .claude/skills（單一 junction）" -ForegroundColor Green
Write-Host "  [2] 逐一將 .claude/skills 底下的每個 skill 連結至 .agents/skills" -ForegroundColor Green
Write-Host "  [3] 取消連結（移除已建立的 junction 與 gitignore 條目）" -ForegroundColor Green
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan

$choice = Read-Host "Enter your choice (0-3)"

switch ($choice) {
    "0" {
        Write-Host "Operation cancelled." -ForegroundColor Yellow
        exit 0
    }
    "1" {
        # Mode 1: Single junction for the whole .agents/skills directory
        Write-Host ""
        Write-Host "Mode 1: 建立單一 junction..." -ForegroundColor Blue

        if (-not (Test-Path $claudeSkills)) {
            Write-Host "ERROR: .claude\skills 不存在，請先建立真實目錄" -ForegroundColor Red
            exit 1
        }

        if (Test-Path $agentsSkills) {
            Write-Host "  移除既有的 .agents\skills..." -ForegroundColor Yellow
            Remove-Item -Recurse -Force $agentsSkills
        }

        New-Item -ItemType Junction -Path $agentsSkills -Target $claudeSkills | Out-Null
        Write-Host "  [OK] Junction created: .agents\skills -> .claude\skills" -ForegroundColor Green

        Add-GitignoreEntry ".agents/skills"
    }
    "2" {
        # Mode 2: Per-skill junctions
        Write-Host ""
        Write-Host "Mode 2: 建立逐個 skill junction..." -ForegroundColor Blue

        if (-not (Test-Path $claudeSkills)) {
            Write-Host "ERROR: .claude\skills 不存在，請先建立真實目錄" -ForegroundColor Red
            exit 1
        }

        # Ensure .agents/skills is a real directory (not a junction)
        $agentsInfo = Get-Item $agentsSkills -ErrorAction SilentlyContinue
        if ($null -ne $agentsInfo -and $agentsInfo.LinkType -eq 'Junction') {
            Write-Host "  [!] .agents\skills 目前是 junction，移除後重建為目錄..." -ForegroundColor Yellow
            Remove-Item -Force $agentsSkills
        }
        New-Item -ItemType Directory -Force -Path $agentsSkills | Out-Null

        # Create per-skill junctions
        $skills = Get-ChildItem -Path $claudeSkills -Directory -ErrorAction SilentlyContinue
        if ($null -eq $skills -or $skills.Count -eq 0) {
            Write-Host "  [!] .claude\skills 下沒有子目錄" -ForegroundColor Yellow
        } else {
            foreach ($skill in $skills) {
                $linkPath = Join-Path $agentsSkills $skill.Name
                $linkInfo = Get-Item $linkPath -ErrorAction SilentlyContinue
                if ($null -ne $linkInfo) {
                    if ($linkInfo.LinkType -eq 'Junction') {
                        Write-Host "  [--] $($skill.Name): junction 已存在，略過" -ForegroundColor Yellow
                    } else {
                        Write-Host "  [!] $($skill.Name): 目標已存在但非 junction，略過" -ForegroundColor Yellow
                    }
                    Add-GitignoreEntry ".agents/skills/$($skill.Name)"
                    continue
                }
                New-Item -ItemType Junction -Path $linkPath -Target $skill.FullName | Out-Null
                Write-Host "  [OK] $($skill.Name): junction created" -ForegroundColor Green
                Add-GitignoreEntry ".agents/skills/$($skill.Name)"
            }
        }

        # Cleanup: remove junctions pointing to non-existent .claude/skills sources
        Write-Host ""
        Write-Host "  清理失效的 junction..." -ForegroundColor Yellow
        $agentsItems = Get-ChildItem -Path $agentsSkills -ErrorAction SilentlyContinue
        if ($null -ne $agentsItems) {
            foreach ($item in $agentsItems) {
                if ($item.LinkType -eq 'Junction') {
                    $source = Join-Path $claudeSkills $item.Name
                    if (-not (Test-Path $source)) {
                        Write-Host "  [RM] $($item.Name): 來源已不存在，移除 junction" -ForegroundColor Red
                        Remove-Item -Force $item.FullName
                        Remove-GitignoreEntry ".agents/skills/$($item.Name)"
                    }
                }
            }
        }
    }
    "3" {
        # Mode 3: Unlink
        Write-Host ""
        Write-Host "Mode 3: 取消連結..." -ForegroundColor Blue

        if (-not (Test-Path $agentsSkills)) {
            Write-Host "  [--] .agents\skills 不存在，無需清理" -ForegroundColor Yellow
            exit 0
        }

        $agentsInfo = Get-Item $agentsSkills -ErrorAction SilentlyContinue

        if ($null -ne $agentsInfo -and $agentsInfo.LinkType -eq 'Junction') {
            # Case A: .agents/skills itself is a junction
            Remove-Item -Force $agentsSkills
            Write-Host "  [OK] 移除 junction: .agents\skills" -ForegroundColor Green
            Remove-GitignoreEntry ".agents/skills"
        } else {
            # Case B: scan for per-skill junctions pointing to .claude/skills
            $removed = 0
            $agentsItems = Get-ChildItem -Path $agentsSkills -ErrorAction SilentlyContinue
            if ($null -ne $agentsItems) {
                foreach ($item in $agentsItems) {
                    if ($item.LinkType -eq 'Junction') {
                        $target = $item.Target
                        if ($null -ne $target -and ($target -like "*\.claude\skills*" -or $target -like "*/.claude/skills*")) {
                            Remove-Item -Force $item.FullName
                            Write-Host "  [OK] 移除 junction: .agents\skills\$($item.Name)" -ForegroundColor Green
                            Remove-GitignoreEntry ".agents/skills/$($item.Name)"
                            $removed++
                        }
                    }
                }
            }
            if ($removed -eq 0) {
                Write-Host "  [--] 未找到指向 .claude\skills 的 junction" -ForegroundColor Yellow
            }
        }
    }
    default {
        Write-Host "Invalid choice." -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "[OK] 完成" -ForegroundColor Green

exit 0
