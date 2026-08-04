#Requires -Version 5.1

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$sourceRoot = $PSScriptRoot
$homeRoot = $env:USERPROFILE
$commonPromptSource = Join-Path $sourceRoot 'common-prompt.md'
$installItems = @(
    [PSCustomObject]@{
        Template           = Join-Path $sourceRoot 'claude-code\.claude\CLAUDE.md'
        Target             = Join-Path $homeRoot '.claude\CLAUDE.md'
        AppendCommonPrompt = $true
    }
    [PSCustomObject]@{
        Template           = Join-Path $sourceRoot 'codex\.codex\AGENTS.md'
        Target             = Join-Path $homeRoot '.codex\AGENTS.md'
        AppendCommonPrompt = $true
    }
    [PSCustomObject]@{
        Template           = Join-Path $sourceRoot 'github-copilot\.copilot\copilot-instructions.md'
        Target             = Join-Path $homeRoot '.copilot\copilot-instructions.md'
        AppendCommonPrompt = $true
    }
)

foreach ($path in @($commonPromptSource) + @($installItems | ForEach-Object { $_.Template })) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Source file not found: $path"
    }
}

$commonPrompt = Get-Content -LiteralPath $commonPromptSource -Raw -Encoding UTF8
$backupSuffix = Get-Date -Format 'yyMMddHHmmss'

Write-Host '=== Install common prompts ===' -ForegroundColor Cyan

foreach ($item in $installItems) {
    $targetDirectory = Split-Path -Parent $item.Target
    New-Item -ItemType Directory -Path $targetDirectory -Force | Out-Null
    if (Test-Path -LiteralPath $item.Target -PathType Leaf) {
        $backupPath = "$($item.Target)_$backupSuffix"
        Move-Item -LiteralPath $item.Target -Destination $backupPath -Force
        Write-Host "  [Backup] $($item.Target) -> $backupPath" -ForegroundColor Yellow
    }
    Copy-Item -LiteralPath $item.Template -Destination $item.Target -Force
    Write-Host "  [OK] Template: $($item.Target)" -ForegroundColor Green
}

foreach ($item in $installItems) {
    if ($item.AppendCommonPrompt) {
        Add-Content -LiteralPath $item.Target -Value ("`r`n" + $commonPrompt) -Encoding UTF8
        Write-Host "  [OK] Common prompt: $($item.Target)" -ForegroundColor Green
    }
}

Write-Host 'Done.' -ForegroundColor Green
