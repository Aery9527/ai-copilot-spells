$scriptUnderTest = Join-Path $PSScriptRoot '..\setup-cx-desktop-ahk.ps1'
. $scriptUnderTest

Describe 'ChatGPT Desktop AppID selection' {
    It 'returns the only ChatGPT Desktop AppID' {
        $apps = @([PSCustomObject]@{ Name = 'ChatGPT'; AppID = 'OpenAI.Codex_example!App' })

        Select-ChatGPTDesktopAppId -StartApps $apps | Should Be 'OpenAI.Codex_example!App'
    }

    It 'fails clearly when no ChatGPT Desktop AppID is available' {
        { Select-ChatGPTDesktopAppId -StartApps @() } |
            Should Throw 'Expected exactly one ChatGPT Desktop AppID, but found 0.'
    }

    It 'fails clearly when multiple ChatGPT Desktop AppIDs are available' {
        $apps = @(
            [PSCustomObject]@{ Name = 'ChatGPT'; AppID = 'OpenAI.Codex_one!App' },
            [PSCustomObject]@{ Name = 'ChatGPT'; AppID = 'OpenAI.Codex_two!App' }
        )

        { Select-ChatGPTDesktopAppId -StartApps $apps } |
            Should Throw 'Expected exactly one ChatGPT Desktop AppID, but found 2.'
    }
}

Describe 'ChatGPT Desktop hotkey setup' {
    It 'stops before installation or file writes when AppID discovery is ambiguous' {
        Mock Get-ChatGPTDesktopAppId { throw 'Expected exactly one ChatGPT Desktop AppID, but found 2.' }
        Mock Get-AutoHotkeyExecutable { }
        Mock Install-AutoHotkey { }
        Mock Write-ChatGPTHotkey { }
        Mock Set-ChatGPTHotkeyStartup { }

        { Invoke-ChatGPTDesktopHotkeySetup } |
            Should Throw 'Expected exactly one ChatGPT Desktop AppID, but found 2.'

        Assert-MockCalled Get-AutoHotkeyExecutable -Exactly 0 -Scope It
        Assert-MockCalled Install-AutoHotkey -Exactly 0 -Scope It
        Assert-MockCalled Write-ChatGPTHotkey -Exactly 0 -Scope It
        Assert-MockCalled Set-ChatGPTHotkeyStartup -Exactly 0 -Scope It
    }

    It 'installs AutoHotkey when absent before writing the managed files' {
        Mock Get-ChatGPTDesktopAppId { 'OpenAI.Codex_example!App' }
        Mock Get-AutoHotkeyExecutable { $null }
        Mock Install-AutoHotkey { 'C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe' }
        Mock Write-ChatGPTHotkey { 'C:\Users\Example\AppData\Local\ChatGPTHotkey\chatgpt-hotkey.ahk' }
        Mock Set-ChatGPTHotkeyStartup { }

        Invoke-ChatGPTDesktopHotkeySetup

        Assert-MockCalled Install-AutoHotkey -Exactly 1 -Scope It
        Assert-MockCalled Write-ChatGPTHotkey -Exactly 1 -Scope It
        Assert-MockCalled Set-ChatGPTHotkeyStartup -Exactly 1 -Scope It
    }

    It 'reuses AutoHotkey when it is already installed' {
        Mock Get-ChatGPTDesktopAppId { 'OpenAI.Codex_example!App' }
        Mock Get-AutoHotkeyExecutable { 'C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe' }
        Mock Install-AutoHotkey { }
        Mock Write-ChatGPTHotkey { 'C:\Users\Example\AppData\Local\ChatGPTHotkey\chatgpt-hotkey.ahk' }
        Mock Set-ChatGPTHotkeyStartup { }

        Invoke-ChatGPTDesktopHotkeySetup

        Assert-MockCalled Install-AutoHotkey -Exactly 0 -Scope It
        Assert-MockCalled Write-ChatGPTHotkey -Exactly 1 -Scope It
        Assert-MockCalled Set-ChatGPTHotkeyStartup -Exactly 1 -Scope It
    }
}
