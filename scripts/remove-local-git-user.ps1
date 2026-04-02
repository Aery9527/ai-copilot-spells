[CmdletBinding()]
param(
    [string]$RootPath = "."
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-LineRanges {
    param(
        [Parameter(Mandatory = $true)]
        [byte[]]$Bytes
    )

    $ranges = New-Object System.Collections.Generic.List[object]
    $lineStart = 0
    $index = 0

    while ($index -lt $Bytes.Length) {
        $current = $Bytes[$index]

        if ($current -eq 13) {
            $lineEnd = $index
            if (($index + 1) -lt $Bytes.Length -and $Bytes[$index + 1] -eq 10) {
                $index += 2
            }
            else {
                $index += 1
            }

            $ranges.Add([pscustomobject]@{
                Start      = $lineStart
                ContentEnd = $lineEnd
                End        = $index
            })
            $lineStart = $index
            continue
        }

        if ($current -eq 10) {
            $lineEnd = $index
            $index += 1
            $ranges.Add([pscustomobject]@{
                Start      = $lineStart
                ContentEnd = $lineEnd
                End        = $index
            })
            $lineStart = $index
            continue
        }

        $index += 1
    }

    if ($lineStart -lt $Bytes.Length) {
        $ranges.Add([pscustomobject]@{
            Start      = $lineStart
            ContentEnd = $Bytes.Length
            End        = $Bytes.Length
        })
    }

    return $ranges
}

function Get-SectionHeaders {
    param(
        [Parameter(Mandatory = $true)]
        [byte[]]$Bytes
    )

    $headers = New-Object System.Collections.Generic.List[object]
    $lineRanges = Get-LineRanges -Bytes $Bytes

    foreach ($lineRange in $lineRanges) {
        $lineLength = $lineRange.ContentEnd - $lineRange.Start
        if ($lineLength -le 0) {
            continue
        }

        $lineText = [System.Text.Encoding]::ASCII.GetString($Bytes, $lineRange.Start, $lineLength)
        if ($lineText -match '^\s*\[(?<name>[^\]\r\n]+)\]\s*(?:[;#].*)?$') {
            $headers.Add([pscustomobject]@{
                Name  = $Matches['name'].Trim()
                Start = $lineRange.Start
            })
        }
    }

    return $headers
}

function Get-ConfigPathFromGitPointer {
    param(
        [Parameter(Mandatory = $true)]
        [string]$GitFilePath
    )

    $pointerText = [System.IO.File]::ReadAllText($GitFilePath, [System.Text.UTF8Encoding]::new($false)).Trim()
    if ($pointerText -notmatch '^\s*gitdir:\s*(.+?)\s*$') {
        throw "Unsupported .git file format"
    }

    $gitDirValue = $Matches[1].Trim()
    $resolvedGitDir = [System.IO.Path]::GetFullPath((Join-Path (Split-Path -Parent $GitFilePath) $gitDirValue))
    return Join-Path $resolvedGitDir 'config'
}

function Get-GitConfigCandidates {
    param(
        [Parameter(Mandatory = $true)]
        [string]$SearchRoot
    )

    $resolvedRoot = (Resolve-Path -LiteralPath $SearchRoot).Path
    $pendingDirs = New-Object System.Collections.Generic.Queue[string]
    $pendingDirs.Enqueue($resolvedRoot)

    $seenConfigs = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::OrdinalIgnoreCase)
    $candidates = New-Object System.Collections.Generic.List[object]

    while ($pendingDirs.Count -gt 0) {
        $currentDir = $pendingDirs.Dequeue()

        try {
            $entries = Get-ChildItem -LiteralPath $currentDir -Force -ErrorAction Stop
        }
        catch {
            Write-Warning "Skipped inaccessible directory: $currentDir"
            continue
        }

        foreach ($entry in $entries) {
            if ($entry.Name -eq '.git') {
                try {
                    if ($entry.PSIsContainer) {
                        $configPath = Join-Path $entry.FullName 'config'
                    }
                    else {
                        $configPath = Get-ConfigPathFromGitPointer -GitFilePath $entry.FullName
                    }

                    if (-not (Test-Path -LiteralPath $configPath -PathType Leaf)) {
                        Write-Warning "Skipped missing config: $configPath"
                        continue
                    }

                    $fullConfigPath = [System.IO.Path]::GetFullPath($configPath)
                    if ($seenConfigs.Add($fullConfigPath)) {
                        $candidates.Add([pscustomobject]@{
                            ConfigPath = $fullConfigPath
                            SourcePath = $entry.FullName
                        })
                    }
                }
                catch {
                    Write-Warning "Skipped invalid git metadata at $($entry.FullName): $($_.Exception.Message)"
                }

                continue
            }

            if ($entry.PSIsContainer) {
                $pendingDirs.Enqueue($entry.FullName)
            }
        }
    }

    return $candidates
}

function Remove-UserSectionBytes {
    param(
        [Parameter(Mandatory = $true)]
        [byte[]]$Bytes
    )

    $headers = @(Get-SectionHeaders -Bytes $Bytes)
    $userHeaders = @($headers | Where-Object { $_.Name.Equals('user', [System.StringComparison]::OrdinalIgnoreCase) })

    if ($userHeaders.Count -eq 0) {
        return [pscustomobject]@{
            Status  = 'none'
            Message = 'No [user] section'
            Bytes   = $Bytes
        }
    }

    if ($userHeaders.Count -gt 1) {
        return [pscustomobject]@{
            Status  = 'skipped'
            Message = 'Skipped malformed config: multiple [user] sections'
            Bytes   = $Bytes
        }
    }

    $targetHeader = $userHeaders[0]
    $nextHeader = $headers | Where-Object { $_.Start -gt $targetHeader.Start } | Select-Object -First 1
    $removeEnd = if ($null -ne $nextHeader) { [int]$nextHeader.Start } else { [int]$Bytes.Length }
    $removeLength = $removeEnd - [int]$targetHeader.Start

    $updatedBytes = New-Object byte[] ($Bytes.Length - $removeLength)
    if ($targetHeader.Start -gt 0) {
        [System.Array]::Copy($Bytes, 0, $updatedBytes, 0, $targetHeader.Start)
    }

    $suffixLength = $Bytes.Length - $removeEnd
    if ($suffixLength -gt 0) {
        [System.Array]::Copy($Bytes, $removeEnd, $updatedBytes, $targetHeader.Start, $suffixLength)
    }

    return [pscustomobject]@{
        Status  = 'updated'
        Message = 'Updated'
        Bytes   = $updatedBytes
    }
}

$configCandidates = @(Get-GitConfigCandidates -SearchRoot $RootPath)
if ($configCandidates.Count -eq 0) {
    Write-Host "No git config files found under: $((Resolve-Path -LiteralPath $RootPath).Path)" -ForegroundColor Yellow
    exit 0
}

$updatedCount = 0
$unchangedCount = 0
$skippedCount = 0

foreach ($candidate in $configCandidates) {
    $bytes = [System.IO.File]::ReadAllBytes($candidate.ConfigPath)
    $result = Remove-UserSectionBytes -Bytes $bytes

    switch ($result.Status) {
        'updated' {
            [System.IO.File]::WriteAllBytes($candidate.ConfigPath, $result.Bytes)
            Write-Host "Updated: $($candidate.ConfigPath)" -ForegroundColor Green
            $updatedCount++
        }
        'none' {
            Write-Host "No [user] section: $($candidate.ConfigPath)" -ForegroundColor DarkGray
            $unchangedCount++
        }
        'skipped' {
            Write-Warning "$($result.Message): $($candidate.ConfigPath)"
            $skippedCount++
        }
    }
}

Write-Host ""
Write-Host "Summary" -ForegroundColor Cyan
Write-Host "  Updated : $updatedCount" -ForegroundColor Green
Write-Host "  Unchanged: $unchangedCount" -ForegroundColor Gray
Write-Host "  Skipped : $skippedCount" -ForegroundColor Yellow
