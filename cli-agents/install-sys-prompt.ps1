#Requires -Version 5.1

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$sourceRoot = $PSScriptRoot
$homeRoot = $env:USERPROFILE
$rulesSource = Join-Path $sourceRoot 'sys-prompt.md'
$installItems = @(
    [PSCustomObject]@{
        Template = Join-Path $sourceRoot 'claude-code\.claude\CLAUDE.md'
        Target   = Join-Path $homeRoot '.claude\CLAUDE.md'
    }
    [PSCustomObject]@{
        Template = Join-Path $sourceRoot 'codex\.codex\AGENTS.md'
        Target   = Join-Path $homeRoot '.codex\AGENTS.md'
    }
    [PSCustomObject]@{
        Template = Join-Path $sourceRoot 'github-copilot\.copilot\copilot-instructions.md'
        Target   = Join-Path $homeRoot '.copilot\copilot-instructions.md'
    }
)

foreach ($path in @($rulesSource) + @($installItems | ForEach-Object { $_.Template })) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Source file not found: $path"
    }
}

Write-Host '=== Install system prompts ===' -ForegroundColor Cyan

foreach ($item in $installItems) {
    $targetDirectory = Split-Path -Parent $item.Target
    New-Item -ItemType Directory -Path $targetDirectory -Force | Out-Null
    Copy-Item -LiteralPath $item.Template -Destination $item.Target -Force
    Write-Host "  [OK] Template: $($item.Target)" -ForegroundColor Green
}

foreach ($item in $installItems) {
    Copy-Item -LiteralPath $rulesSource -Destination $item.Target -Force
    Write-Host "  [OK] Rules:    $($item.Target)" -ForegroundColor Green
}

Write-Host 'Done.' -ForegroundColor Green
