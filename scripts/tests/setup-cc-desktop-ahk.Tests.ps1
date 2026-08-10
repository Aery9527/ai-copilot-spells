$scriptUnderTest = Join-Path $PSScriptRoot '..\setup-cc-desktop-ahk.ps1'
. $scriptUnderTest

Describe 'Claude Desktop AppID selection' {
    It 'returns the only Claude Desktop AppID' {
        $apps = @([PSCustomObject]@{ Name = 'Claude'; AppID = 'Claude_example!Claude' })

        Select-ClaudeDesktopAppId -StartApps $apps | Should Be 'Claude_example!Claude'
    }

    It 'fails clearly when no Claude Desktop AppID is available' {
        { Select-ClaudeDesktopAppId -StartApps @() } |
            Should Throw 'Expected exactly one Claude Desktop AppID, but found 0.'
    }

    It 'fails clearly when multiple Claude Desktop AppIDs are available' {
        $apps = @(
            [PSCustomObject]@{ Name = 'Claude'; AppID = 'Claude_one!Claude' },
            [PSCustomObject]@{ Name = 'Claude'; AppID = 'Claude_two!Claude' }
        )

        { Select-ClaudeDesktopAppId -StartApps $apps } |
            Should Throw 'Expected exactly one Claude Desktop AppID, but found 2.'
    }
}

Describe 'Claude Desktop hotkey setup' {
    It 'stops before installation or file writes when AppID discovery is ambiguous' {
        Mock Get-ClaudeDesktopAppId { throw 'Expected exactly one Claude Desktop AppID, but found 2.' }
        Mock Get-AutoHotkeyExecutable { }
        Mock Install-AutoHotkey { }
        Mock Write-ClaudeHotkey { }
        Mock Set-ClaudeHotkeyStartup { }

        { Invoke-ClaudeDesktopHotkeySetup } |
            Should Throw 'Expected exactly one Claude Desktop AppID, but found 2.'

        Assert-MockCalled Get-AutoHotkeyExecutable -Exactly 0 -Scope It
        Assert-MockCalled Install-AutoHotkey -Exactly 0 -Scope It
        Assert-MockCalled Write-ClaudeHotkey -Exactly 0 -Scope It
        Assert-MockCalled Set-ClaudeHotkeyStartup -Exactly 0 -Scope It
    }

    It 'installs AutoHotkey when absent before writing the managed files' {
        Mock Get-ClaudeDesktopAppId { 'Claude_example!Claude' }
        Mock Get-AutoHotkeyExecutable { $null }
        Mock Install-AutoHotkey { 'C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe' }
        Mock Write-ClaudeHotkey { 'C:\Users\Example\AppData\Local\ClaudeHotkey\claude-hotkey.ahk' }
        Mock Set-ClaudeHotkeyStartup { }

        Invoke-ClaudeDesktopHotkeySetup

        Assert-MockCalled Install-AutoHotkey -Exactly 1 -Scope It
        Assert-MockCalled Write-ClaudeHotkey -Exactly 1 -Scope It
        Assert-MockCalled Set-ClaudeHotkeyStartup -Exactly 1 -Scope It
    }

    It 'reuses AutoHotkey when it is already installed' {
        Mock Get-ClaudeDesktopAppId { 'Claude_example!Claude' }
        Mock Get-AutoHotkeyExecutable { 'C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe' }
        Mock Install-AutoHotkey { }
        Mock Write-ClaudeHotkey { 'C:\Users\Example\AppData\Local\ClaudeHotkey\claude-hotkey.ahk' }
        Mock Set-ClaudeHotkeyStartup { }

        Invoke-ClaudeDesktopHotkeySetup

        Assert-MockCalled Install-AutoHotkey -Exactly 0 -Scope It
        Assert-MockCalled Write-ClaudeHotkey -Exactly 1 -Scope It
        Assert-MockCalled Set-ClaudeHotkeyStartup -Exactly 1 -Scope It
    }
}
