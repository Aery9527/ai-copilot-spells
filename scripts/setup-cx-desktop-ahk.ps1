#Requires -Version 5.1

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

function Select-ChatGPTDesktopAppId {
    param(
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [object[]]$StartApps
    )

    $matches = @($StartApps | Where-Object {
        $null -ne $_ -and -not [string]::IsNullOrWhiteSpace($_.AppID)
    })

    if ($matches.Count -ne 1) {
        throw "Expected exactly one ChatGPT Desktop AppID, but found $($matches.Count)."
    }

    return [string]$matches[0].AppID
}

function Get-ChatGPTDesktopAppId {
    $startApps = @(Get-StartApps | Where-Object { $_.Name -eq 'ChatGPT' })
    return Select-ChatGPTDesktopAppId -StartApps $startApps
}

function Get-AutoHotkeyExecutable {
    $candidates = @()

    foreach ($commandName in @('AutoHotkey64.exe', 'AutoHotkey.exe')) {
        $command = Get-Command $commandName -ErrorAction SilentlyContinue
        if ($null -ne $command -and -not [string]::IsNullOrWhiteSpace($command.Source)) {
            $candidates += $command.Source
        }
    }

    foreach ($programFiles in @($env:ProgramFiles, ${env:ProgramFiles(x86)})) {
        if (-not [string]::IsNullOrWhiteSpace($programFiles)) {
            $candidates += Join-Path $programFiles 'AutoHotkey\v2\AutoHotkey64.exe'
            $candidates += Join-Path $programFiles 'AutoHotkey\v2\AutoHotkey.exe'
        }
    }

    foreach ($candidate in $candidates | Select-Object -Unique) {
        if (Test-Path -LiteralPath $candidate -PathType Leaf) {
            return $candidate
        }
    }

    return $null
}

function Install-AutoHotkey {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        throw 'winget was not found. Install AutoHotkey v2 manually, then re-run this script.'
    }

    Write-Host '  [!] AutoHotkey v2 not found; installing it with winget...' -ForegroundColor Yellow
    winget install --exact --id AutoHotkey.AutoHotkey --silent --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -ne 0) {
        throw "winget failed to install AutoHotkey v2 (exit $LASTEXITCODE)."
    }

    $autoHotkeyExecutable = Get-AutoHotkeyExecutable
    if ([string]::IsNullOrWhiteSpace($autoHotkeyExecutable)) {
        throw 'AutoHotkey v2 was installed, but its executable could not be found. Open a new terminal and re-run this script.'
    }

    return $autoHotkeyExecutable
}

function Write-ChatGPTHotkey {
    param(
        [Parameter(Mandatory)]
        [string]$AppId,

        [Parameter(Mandatory)]
        [string]$AutoHotkeyExecutable
    )

    $managedDirectory = Join-Path $env:LOCALAPPDATA 'ChatGPTHotkey'
    $scriptPath = Join-Path $managedDirectory 'chatgpt-hotkey.ahk'

    if (-not (Test-Path -LiteralPath $managedDirectory -PathType Container)) {
        New-Item -ItemType Directory -Path $managedDirectory | Out-Null
    }

    # Alt+Space overrides Windows' default "window system menu" shortcut system-wide while this script runs.
    $hotkeyScript = @'
#Requires AutoHotkey v2.0

!Space:: {
    appExe := "ChatGPT.exe"
    hwnd := WinExist("ahk_exe " appExe)

    if (!hwnd) {
        Run "shell:AppsFolder\__CHATGPT_APP_ID__"
    } else if WinActive("ahk_exe " appExe) {
        WinClose "ahk_exe " appExe
    } else {
        WinRestore "ahk_exe " appExe
        WinActivate "ahk_exe " appExe
    }
}
'@.Replace('__CHATGPT_APP_ID__', $AppId)

    Set-Content -LiteralPath $scriptPath -Value $hotkeyScript -Encoding UTF8
    Write-Host "  [OK] Wrote hotkey script: $scriptPath" -ForegroundColor Green

    return $scriptPath
}

function Set-ChatGPTHotkeyStartup {
    param(
        [Parameter(Mandatory)]
        [string]$AutoHotkeyExecutable,

        [Parameter(Mandatory)]
        [string]$ScriptPath
    )

    $startupDirectory = [Environment]::GetFolderPath([Environment+SpecialFolder]::Startup)
    $shortcutPath = Join-Path $startupDirectory 'ChatGPT Desktop Hotkey.lnk'
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($shortcutPath)

    $shortcut.TargetPath = $AutoHotkeyExecutable
    $shortcut.Arguments = '"{0}"' -f $ScriptPath
    $shortcut.WorkingDirectory = Split-Path -Path $ScriptPath -Parent
    $shortcut.Save()

    Write-Host "  [OK] Configured startup shortcut: $shortcutPath" -ForegroundColor Green
}

function Invoke-ChatGPTDesktopHotkeySetup {
    Write-Host '=== ChatGPT Desktop Hotkey Setup ===' -ForegroundColor Cyan

    Write-Host '--- Step 1: ChatGPT Desktop ---' -ForegroundColor Blue
    $appId = Get-ChatGPTDesktopAppId
    Write-Host '  [OK] Found exactly one ChatGPT Desktop AppID.' -ForegroundColor Green

    Write-Host '--- Step 2: AutoHotkey v2 ---' -ForegroundColor Blue
    $autoHotkeyExecutable = Get-AutoHotkeyExecutable
    if ([string]::IsNullOrWhiteSpace($autoHotkeyExecutable)) {
        $autoHotkeyExecutable = Install-AutoHotkey
    } else {
        Write-Host "  [OK] Found AutoHotkey v2: $autoHotkeyExecutable" -ForegroundColor Green
    }

    Write-Host '--- Step 3: Hotkey and startup ---' -ForegroundColor Blue
    $scriptPath = Write-ChatGPTHotkey -AppId $appId -AutoHotkeyExecutable $autoHotkeyExecutable
    Set-ChatGPTHotkeyStartup -AutoHotkeyExecutable $autoHotkeyExecutable -ScriptPath $scriptPath
}

if ($MyInvocation.InvocationName -ne '.') {
    try {
        Invoke-ChatGPTDesktopHotkeySetup
        Write-Host ''
        Write-Host 'Done. Alt + Space now toggles ChatGPT Desktop.' -ForegroundColor Green
    } catch {
        Write-Host "  [X] ERROR: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}
