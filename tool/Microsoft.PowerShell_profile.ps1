
function gws { # golang workspace: GolandProjects
    cd C:\Users\User\GolandProjects
}

function jws { # java workspace: IdeaProjects
    cd C:\Users\User\IdeaProjects
}

function gcc { # golang claude code
    . "$PSScriptRoot\Set-GoEnv.ps1"
    claude --permission-mode auto @args
}

function ggc { # golang github copilot
    . "$PSScriptRoot\Set-GoEnv.ps1"
    copilot --allow-all-tools @args
}

function gcx { # golang codex
    . "$PSScriptRoot\Set-GoEnv.ps1"
    codex --sandbox workspace-write --ask-for-approval on-request @args
}
