
# workspace

function gws { # golang workspace: GolandProjects
    cd C:\Users\User\GolandProjects
}

function jws { # java workspace: IdeaProjects
    cd C:\Users\User\IdeaProjects
}

# agent cli

function acc {
    . "$PSScriptRoot\Set-DevEnv.ps1"
    . "$PSScriptRoot\Exe-CC.ps1"
}

function agc {
    . "$PSScriptRoot\Set-DevEnv.ps1"
    . "$PSScriptRoot\Exe-GC.ps1"
}

function acx {
    . "$PSScriptRoot\Set-DevEnv.ps1"
    . "$PSScriptRoot\Exe-CX.ps1"
}

# golang cli

function gcc {
    . "$PSScriptRoot\Set-DevEnv.ps1"
    . "$PSScriptRoot\Set-GoEnv.ps1"
    . "$PSScriptRoot\Set-GoVersion.ps1"
    . "$PSScriptRoot\Exe-CC.ps1"
}

function ggc {
    . "$PSScriptRoot\Set-DevEnv.ps1"
    . "$PSScriptRoot\Set-GoEnv.ps1"
    . "$PSScriptRoot\Set-GoVersion.ps1"
    . "$PSScriptRoot\Exe-GC.ps1"
}

function gcx {
    . "$PSScriptRoot\Set-DevEnv.ps1"
    . "$PSScriptRoot\Set-GoEnv.ps1"
    . "$PSScriptRoot\Set-GoVersion.ps1"
    . "$PSScriptRoot\Exe-CX.ps1"
}

# java cli

function jcc {
    . "$PSScriptRoot\Set-DevEnv.ps1"
    . "$PSScriptRoot\Set-JavaVersion.ps1"
    . "$PSScriptRoot\Exe-CC.ps1"
}

function jgc {
    . "$PSScriptRoot\Set-DevEnv.ps1"
    . "$PSScriptRoot\Set-JavaVersion.ps1"
    . "$PSScriptRoot\Exe-GC.ps1"
}

function jcx {
    . "$PSScriptRoot\Set-DevEnv.ps1"
    . "$PSScriptRoot\Set-JavaVersion.ps1"
    . "$PSScriptRoot\Exe-CX.ps1"
}