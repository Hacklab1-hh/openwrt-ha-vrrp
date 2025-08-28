<#
    dev-sync-nodes.ps1 – synchronisiert Release‑ und IPK‑Pakete auf OpenWrt‑Nodes

    Dieses PowerShell‑Skript kopiert die im Workspace gespeicherten
    openwrt-ha-vrrp‑Archive und ha-vrrp IPK‑Pakete per scp auf
    definierte Nodes.  Die Zielordner /root/vrrp-repo und /root/vrrp-ipk-repo
    werden vor dem Kopieren angelegt.  Die zu adressierenden Nodes
    können über den Parameter --nodes gesteuert werden (all, 1 oder 2).
#>

param(
    [string]$Nodes = "all"
)

# Workspace und Verzeichnisse bestimmen
$workspace = Join-Path -Path $env:USERPROFILE -ChildPath "_workspace"
$repoDir = Join-Path -Path $workspace -ChildPath "vrrp-repo"
$ipkDir  = Join-Path -Path $workspace -ChildPath "vrrp-ipk-repo"

# Node‑Mapping
$nodeMap = @{ "1" = "LamoboR1-1"; "2" = "LamoboR1-2"; "all" = @("LamoboR1-1","LamoboR1-2") }
if (-not $nodeMap.ContainsKey($Nodes)) {
    Write-Host "Unknown nodes option: $Nodes" -ForegroundColor Red
    exit 1
}

# Hilfsfunktion für das Kopieren zu einem Node
function Sync-ToNode {
    param([string]$target)
    # Erstelle die Zielverzeichnisse
    try {
        ssh "root@$target" "mkdir -p /root/vrrp-repo /root/vrrp-ipk-repo" | Out-Null
    } catch {
        Write-Host "[dev-sync-nodes] Warnung: ssh zu $target fehlgeschlagen" -ForegroundColor Yellow
    }
    # Release‑Archive kopieren
    Get-ChildItem -Path $repoDir -Filter "openwrt-ha-vrrp-*.tar.gz" -File -ErrorAction SilentlyContinue | ForEach-Object {
        scp $_.FullName "root@$target:/root/vrrp-repo/" | Out-Null
    }
    Get-ChildItem -Path $repoDir -Filter "openwrt-ha-vrrp-*.tar" -File -ErrorAction SilentlyContinue | ForEach-Object {
        scp $_.FullName "root@$target:/root/vrrp-repo/" | Out-Null
    }
    Get-ChildItem -Path $repoDir -Filter "openwrt-ha-vrrp-*.zip" -File -ErrorAction SilentlyContinue | ForEach-Object {
        scp $_.FullName "root@$target:/root/vrrp-repo/" | Out-Null
    }
    # IPK‑Pakete kopieren
    Get-ChildItem -Path $ipkDir -Filter "ha-vrrp_*_all.ipk" -File -ErrorAction SilentlyContinue | ForEach-Object {
        scp $_.FullName "root@$target:/root/vrrp-ipk-repo/" | Out-Null
    }
}

foreach ($n in $nodeMap[$Nodes]) {
    Sync-ToNode -target $n
}

Write-Host "[dev-sync-nodes] Synchronisation abgeschlossen für Nodes: $Nodes"