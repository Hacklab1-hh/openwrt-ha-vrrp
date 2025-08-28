<#
    copy_downloads.ps1 – kopiert heruntergeladene VRRP‑Pakete in das lokale Workspace

    Dieses PowerShell‑Skript sucht im Standard‑Downloadverzeichnis des
    Benutzers (oder in einem optional übergebenen Pfad) nach Dateien vom
    Typ "openwrt-ha-vrrp-*.tar.gz", ".tar", ".zip" sowie nach
    IPK‑Paketen der Form "ha-vrrp_*_all.ipk".  Gefundene Archive werden in
    das lokale "_workspace\vrrp-repo" kopiert, IPK‑Pakete in
    "_workspace\vrrp-ipk-repo".  Existierende Dateien werden
    überschrieben.

    Beispielaufruf:
      .\copy_downloads.ps1 C:\Users\Bob\Downloads
#>

param(
    [string]$DownloadDir
)

if (-not $DownloadDir) {
    if ($env:USERPROFILE) {
        $DownloadDir = Join-Path $env:USERPROFILE 'Downloads'
    } else {
        Write-Error "[copy_downloads.ps1] USERPROFILE not set and no download dir specified."
        exit 1
    }
}

try {
    $DownloadDir = (Resolve-Path -Path $DownloadDir -ErrorAction Stop).ProviderPath
} catch {
    Write-Error "[copy_downloads.ps1] Directory not found: $DownloadDir"
    exit 1
}

$workspace = Join-Path $env:USERPROFILE '_workspace'
$repoDest = Join-Path $workspace 'vrrp-repo'
$ipkDest = Join-Path $workspace 'vrrp-ipk-repo'

New-Item -Force -ItemType Directory -Path $repoDest, $ipkDest | Out-Null

function Copy-FilesFrom {
    param([string]$SourceDir)
    # Archivefiles
    Get-ChildItem -Path $SourceDir -File -ErrorAction SilentlyContinue | Where-Object {
        $_.Name -like 'openwrt-ha-vrrp-*.tar.gz' -or
        $_.Name -like 'openwrt-ha-vrrp-*.tar' -or
        $_.Name -like 'openwrt-ha-vrrp-*.zip'
    } | ForEach-Object {
        Copy-Item -Force -LiteralPath $_.FullName -Destination $repoDest
    }
    # IPK files
    Get-ChildItem -Path $SourceDir -File -ErrorAction SilentlyContinue | Where-Object {
        $_.Name -like 'ha-vrrp_*.ipk'
    } | ForEach-Object {
        Copy-Item -Force -LiteralPath $_.FullName -Destination $ipkDest
    }
}

# copy from main directory
Copy-FilesFrom -SourceDir $DownloadDir

# copy from nested vrrp-repo directory
if (Test-Path (Join-Path $DownloadDir 'vrrp-repo')) {
    Copy-FilesFrom -SourceDir (Join-Path $DownloadDir 'vrrp-repo')
}

# copy from nested vrrp-ipk-repo directory (only IPK packages)
if (Test-Path (Join-Path $DownloadDir 'vrrp-ipk-repo')) {
    Get-ChildItem -Path (Join-Path $DownloadDir 'vrrp-ipk-repo') -File -ErrorAction SilentlyContinue | Where-Object {
        $_.Name -like 'ha-vrrp_*.ipk'
    } | ForEach-Object {
        Copy-Item -Force -LiteralPath $_.FullName -Destination $ipkDest
    }
}

Write-Host "[copy_downloads] Artefakte wurden nach $repoDest und $ipkDest kopiert."