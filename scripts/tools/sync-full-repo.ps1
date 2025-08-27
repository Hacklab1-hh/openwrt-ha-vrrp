# sync-full-repo.ps1
#
# PowerShell version of the sync helper.  Mirrors GitHub branches or tags by
# downloading tar.gz archives without requiring `git`.  Extracts each archive
# into a `mirror/<ref>` directory and updates a `current` symlink (or
# fallback file) to point at the last processed ref.

param(
    [Parameter(Mandatory=$true)][string]$Owner,
    [Parameter(Mandatory=$true)][string]$Repo,
    [string]$Ref,
    [string]$RefsFile = "",
    [switch]$FetchAllRefsViaAPI,
    [switch]$NoSymlink
)

$ErrorActionPreference = "Stop"
$baseDir   = Get-Location
$mirrorDir = Join-Path $baseDir "mirror"
$currentLnk= Join-Path $baseDir "current"

if (!(Test-Path $mirrorDir)) { New-Item -ItemType Directory -Path $mirrorDir | Out-Null }

function Get-Refs {
    if ($FetchAllRefsViaAPI) {
        if (-not $Env:GITHUB_TOKEN) { throw "GITHUB_TOKEN not set." }
        $headers = @{ "Authorization" = "Bearer $($Env:GITHUB_TOKEN)"; "Accept"="application/vnd.github+json" }
        $branches = Invoke-RestMethod -Headers $headers -Uri "https://api.github.com/repos/$Owner/$Repo/branches?per_page=100"
        $tags     = Invoke-RestMethod -Headers $headers -Uri "https://api.github.com/repos/$Owner/$Repo/tags?per_page=200"
        return @($branches.name) + @($tags.name)
    }
    elseif ($Ref) {
        return @($Ref)
    }
    elseif ($RefsFile -and (Test-Path $RefsFile)) {
        return Get-Content -Path $RefsFile | Where-Object { $_.Trim() -ne "" }
    }
    else {
        throw "No refs provided."
    }
}

function Download-And-Extract([string]$refItem) {
    $url = "https://github.com/$Owner/$Repo/archive/refs/heads/$refItem.tar.gz"
    $outTgz = Join-Path $mirrorDir "$($Owner)_$($Repo)_$($refItem).tar.gz"
    try {
        Invoke-WebRequest -Uri $url -Method Get -OutFile $outTgz -UseBasicParsing -ErrorAction Stop
    } catch {
        $url = "https://github.com/$Owner/$Repo/archive/refs/tags/$refItem.tar.gz"
        Invoke-WebRequest -Uri $url -Method Get -OutFile $outTgz -UseBasicParsing -ErrorAction Stop
    }
    $destDirParent = Join-Path $mirrorDir $refItem
    if (Test-Path $destDirParent) { Remove-Item -Recurse -Force $destDirParent }
    New-Item -ItemType Directory -Path $destDirParent | Out-Null
    tar -xzf $outTgz -C $destDirParent
    $sub = Get-ChildItem -Directory -Path $destDirParent | Select-Object -First 1
    if ($null -ne $sub) {
        Get-ChildItem -Path $sub.FullName -Force | Move-Item -Destination $destDirParent -Force
        Remove-Item -Recurse -Force $sub.FullName
    }
    Remove-Item $outTgz -Force
    return $destDirParent
}

$refs = Get-Refs
$lastPath = $null
foreach ($r in $refs) {
    $lastPath = Download-And-Extract $r
}
if (-not $NoSymlink -and $lastPath) {
    if (Test-Path $currentLnk) { Remove-Item $currentLnk -Force -Recurse }
    try {
        New-Item -ItemType SymbolicLink -Path $currentLnk -Target $lastPath | Out-Null
    } catch {
        $fallback = Join-Path $baseDir "CURRENT_PATH.txt"
        Set-Content -Path $fallback -Value $lastPath
    }
}
"Done"