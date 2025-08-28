<#
    upload_nodes.ps1 – überträgt Pakete via scp auf entfernte Knoten

    Dieses PowerShell‑Skript kopiert die Inhalte des lokalen
    "_workspace\vrrp-repo" sowie "_workspace\vrrp-ipk-repo" auf die
    angegebenen Zielhosts.  Es wird vorausgesetzt, dass auf dem
    Zielsystem ein SSH‑Server läuft und die Befehle "ssh" und
    "scp" verfügbar sind (z. B. über OpenSSH for Windows oder WSL).

    Beispielaufruf:
      .\upload_nodes.ps1 LamoboR1-1 LamoboR1-2
#>

param(
    [Parameter(Mandatory=$true, ValueFromRemainingArguments=$true)]
    [string[]]$Nodes
)

$workspace = Join-Path $env:USERPROFILE '_workspace'
$repoSrc = Join-Path $workspace 'vrrp-repo'
$ipkSrc  = Join-Path $workspace 'vrrp-ipk-repo'

if (-not (Test-Path $repoSrc)) {
    Write-Error "[upload_nodes.ps1] Source repo directory not found: $repoSrc"
    exit 1
}
if (-not (Test-Path $ipkSrc)) {
    Write-Error "[upload_nodes.ps1] Source ipk directory not found: $ipkSrc"
    exit 1
}

foreach ($node in $Nodes) {
    Write-Host "[upload_nodes] Verbinde zu $node..."
    try {
        # Erstelle Zielverzeichnisse
        ssh $node "mkdir -p /root/vrrp-repo /root/vrrp-ipk-repo" | Out-Null
        # Kopiere Repo-Dateien
        $repoFiles = Get-ChildItem -Path $repoSrc -File
        foreach ($file in $repoFiles) {
            scp -q $file.FullName "${node}:/root/vrrp-repo/" | Out-Null
        }
        # Kopiere IPK-Dateien
        $ipkFiles = Get-ChildItem -Path $ipkSrc -File
        foreach ($file in $ipkFiles) {
            scp -q $file.FullName "${node}:/root/vrrp-ipk-repo/" | Out-Null
        }
        Write-Host "[upload_nodes] Dateien erfolgreich an $node übertragen."
    } catch {
        Write-Error "[upload_nodes] Fehler beim Übertragen der Dateien nach $node: $_"
    }
}