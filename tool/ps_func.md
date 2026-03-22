# 在Windows 的 PowerShell 中設定一些快捷函數

- PS5 放在 `~\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1`
- PS7 放在 `~\Documents\PowerShell\Microsoft.PowerShell_profile.ps1`
- update powershell `winget upgrade Microsoft.PowerShell`

```
# claude code shortcuts

function gcc { # Golang Claude Code
    $env:GO_HOME="C:\Users\User\sdk\go1.26.0\bin"
    $env:PATH="$env:GO_HOME;$env:PATH"
    claude --allowedTools "Bash(*)" @args
}

# github copilot shortcuts

function ggc { # Golang Github Copilot
    $env:GO_HOME="C:\Users\User\sdk\go1.26.0\bin"
    $env:PATH="$env:GO_HOME;$env:PATH"
    copilot --allow-all-tools @args
}

# workspace shortcuts

function gws { # golang workspace: GolandProjects
	cd C:\Users\User\GolandProjects
}

```



