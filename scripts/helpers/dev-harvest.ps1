<#
    dev-harvest.ps1 – sammelt heruntergeladene Release‑Archive und IPK‑Pakete

    Dieses PowerShell‑Skript durchsucht den Download‑Ordner des Benutzers
    (und optional ein Unterverzeichnis "vrrp-repo") nach
    openwrt-ha-vrrp‑Archiven und ha-vrrp IPK‑Paketen.  Gefundene Dateien
    werden in die Entwicklungs‑Workspace‑Verzeichnisse kopiert
    (<Benutzer>\_workspace\vrrp-repo und vrrp-ipk-repo).
#>

param(
    [Parameter(Mandatory=$false)][string]$Action = "run"
)

if ($Action -ne "run") {
    Write-Host "Unknown action: $Action" -ForegroundColor Red
    exit 1
}

# Workspace und Download‑Pfad bestimmen
$workspace = Join-Path -Path $env:USERPROFILE -ChildPath "_workspace"
$repoDir = Join-Path -Path $workspace -ChildPath "vrrp-repo"
$ipkDir  = Join-Path -Path $workspace -ChildPath "vrrp-ipk-repo"

New-Item -ItemType Directory -Path $repoDir -Force | Out-Null
New-Item -ItemType Directory -Path $ipkDir  -Force | Out-Null

$downloads = Join-Path -Path $env:USERPROFILE -ChildPath "Downloads"
$additional = Join-Path -Path $downloads -ChildPath "vrrp-repo"

$srcDirs = @()
if (Test-Path $downloads) { $srcDirs += $downloads }
if (Test-Path $additional) { $srcDirs += $additional }

foreach ($dir in $srcDirs) {
    # Release‑Archive kopieren
    Get-ChildItem -Path $dir -Filter "openwrt-ha-vrrp-*.tar.gz" -File -ErrorAction SilentlyContinue | ForEach-Object {
        Copy-Item -Path $_.FullName -Destination $repoDir -Force
    }
    Get-ChildItem -Path $dir -Filter "openwrt-ha-vrrp-*.tar" -File -ErrorAction SilentlyContinue | ForEach-Object {
        Copy-Item -Path $_.FullName -Destination $repoDir -Force
    }
    Get-ChildItem -Path $dir -Filter "openwrt-ha-vrrp-*.zip" -File -ErrorAction SilentlyContinue | ForEach-Object {
        Copy-Item -Path $_.FullName -Destination $repoDir -Force
    }
    # IPK‑Pakete kopieren
    Get-ChildItem -Path $dir -Filter "ha-vrrp_*_all.ipk" -File -ErrorAction SilentlyContinue | ForEach-Object {
        Copy-Item -Path $_.FullName -Destination $ipkDir -Force
    }
}

Write-Host "[dev-harvest] Dateien in $repoDir und $ipkDir aktualisiert."