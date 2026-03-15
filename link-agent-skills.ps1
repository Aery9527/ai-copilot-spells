# link-agent-skills.ps1
# Creates symlinks for .agents/skills into .claude/skills
# Run from any location — script always resolves paths relative to itself.

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$repoRoot     = Split-Path -Parent $MyInvocation.MyCommand.Path
$agentsSkills = Join-Path $repoRoot ".agents\skills"
$claudeSkills = Join-Path $repoRoot ".claude\skills"
$gitignore    = Join-Path $repoRoot ".gitignore"

if (-not (Test-Path $agentsSkills)) {
    Write-Error "錯誤：找不到 $agentsSkills"
    exit 1
}

Write-Host "請選擇連結模式："
Write-Host "  0) 取消"
Write-Host "  1) 將整個 .claude/skills 連結至 .agents/skills（單一 junction）"
Write-Host "  2) 逐一將 .agents/skills 底下的每個 skill 連結至 .claude/skills（可重複執行：新增的 skill 會建立連結，已從 .agents/skills 移除的 skill 會同步清除連結與 .gitignore 條目）"
$choice = Read-Host "請輸入選項 [0/1/2]"

switch ($choice) {
    '1' {
        if (Test-Path $claudeSkills) {
            Remove-Item -Recurse -Force $claudeSkills
        }
        New-Item -ItemType Junction -Path $claudeSkills -Target $agentsSkills | Out-Null
        Write-Host "link  .claude/skills  ->  .agents/skills"

        $existing = @(if (Test-Path $gitignore) { Get-Content $gitignore } else { })
        if ($existing -notcontains ".claude/skills") {
            Add-Content -Path $gitignore -Value ".claude/skills"
            Write-Host "gitignore  .claude/skills"
        }
    }

    '2' {
        New-Item -ItemType Directory -Force -Path $claudeSkills | Out-Null
        $created = 0
        $skipped = 0

        foreach ($skillDir in Get-ChildItem -Path $agentsSkills -Directory) {
            $skillName      = $skillDir.Name
            $target         = Join-Path $claudeSkills $skillName
            $relPath        = "..\..\agents\skills\$skillName"
            $gitignoreEntry = ".claude/skills/$skillName"

            if (Test-Path $target) {
                Write-Host "略過  $skillName  （已存在）"
                $skipped++
            } else {
                New-Item -ItemType Junction -Path $target -Target $skillDir.FullName | Out-Null
                Write-Host "link  $skillName  ->  $relPath"
                $created++
            }

            $existing = @(if (Test-Path $gitignore) { Get-Content $gitignore } else { })
            if ($existing -notcontains $gitignoreEntry) {
                Add-Content -Path $gitignore -Value $gitignoreEntry
                Write-Host "gitignore  $gitignoreEntry"
            }
        }

        # 清理：移除 .claude/skills 中指向 .agents/skills 但來源已不存在的連結
        $removed = 0
        foreach ($item in @(Get-ChildItem -Path $claudeSkills)) {
            $itemInfo = Get-Item $item.FullName
            if ($itemInfo.LinkType -ne 'Junction') { continue }
            if ($itemInfo.Target -notlike "*\.agents\skills*") { continue }
            if (-not (Test-Path (Join-Path $agentsSkills $item.Name))) {
                Remove-Item -Force $item.FullName
                Write-Host "移除  $($item.Name)  （.agents/skills 中已不存在）"
                $removed++
                $gitignoreEntry = ".claude/skills/$($item.Name)"
                $lines = @(if (Test-Path $gitignore) { Get-Content $gitignore } else { })
                if ($lines -contains $gitignoreEntry) {
                    $lines | Where-Object { $_ -ne $gitignoreEntry } | Set-Content $gitignore
                    Write-Host "gitignore 移除  $gitignoreEntry"
                }
            }
        }

        Write-Host ""
        Write-Host "完成：新建 $created 個，略過 $skipped 個，移除 $removed 個"
    }

    '0' {
        Write-Host "已取消"
        exit 0
    }

    default {
        Write-Error "錯誤：無效的選項 '$choice'"
        exit 1
    }
}
