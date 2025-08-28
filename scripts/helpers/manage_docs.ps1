<#
    manage_docs.ps1 – zentraler Manager zum Hinzufügen von Einträgen zu versionsspezifischen Dokumenten

    Dieses Skript ermöglicht es, Notizen in die Markdown‑Dateien der aktuellen Version einzutragen
    und optional einen Versionsbump durchzuführen.  Es spiegelt die Funktionalität von
    manage_docs.sh für Windows‑Umgebungen wider und kann sowohl in einer Powershell unter
    Windows als auch unter Linux (pwsh) ausgeführt werden.

    Parameter:
      -Type <string>        Abschnitt (changelog|features|architecture|concepts|readme|known-issues)
      -Entry <string>       Text, der an die Datei angehängt wird
      -NewVersion <string>  Optional: neuer Versionsstring
#>

param(
  [Parameter(Mandatory=$true)][string]$Type,
  [Parameter(Mandatory=$true)][string]$Entry,
  [string]$NewVersion
)

function Write-Log($Message) {
    Write-Host "[manage_docs.ps1] $Message"
}

# Root ermitteln (zwei Ebenen über dem Skriptverzeichnis)
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$Root = Split-Path -Parent (Split-Path -Parent $ScriptDir)
$VersionFile = Join-Path $Root 'VERSION'
if (-not (Test-Path $VersionFile)) {
    throw "VERSION file not found: $VersionFile"
}
$CurVer = (Get-Content $VersionFile -Raw).Trim()

# Abschnitt zu Verzeichnis zuordnen
switch ($Type.ToLower()) {
    'changelog' {'changelogs'}
    'changelogs' {'changelogs'}
    'features' {'features'}
    'architecture' {'architecture'}
    'concepts' {'concepts'}
    'readme' {'readmes'}
    'readmes' {'readmes'}
    'known-issues' {'known-issues'}
    default { throw "Unknown type: $Type" }
} | ForEach-Object { $Section = $_ }

$Dir = Join-Path $Root "docs/$Section"
if (-not (Test-Path $Dir)) { New-Item -ItemType Directory -Force -Path $Dir | Out-Null }
$TargetFile = Join-Path $Dir "$CurVer.md"
if (-not (Test-Path $TargetFile)) {
    "# $CurVer`n" | Set-Content -Path $TargetFile
}

# Text anhängen
$EntryFormatted = "$Entry`n`n"
Add-Content -Path $TargetFile -Value $EntryFormatted
Write-Log "Added entry to docs/$Section/$CurVer.md"

if ($NewVersion) {
    $PrevVer = $CurVer
    foreach ($Sec in 'changelogs','features','architecture','concepts','readmes','known-issues') {
        $Src = Join-Path $Root "docs/$Sec/$PrevVer.md"
        $Dst = Join-Path $Root "docs/$Sec/$NewVersion.md"
        if (Test-Path $Src) {
            Copy-Item -Path $Src -Destination $Dst -Force
        }
    }
    # VERSION aktualisieren
    Set-Content -Path $VersionFile -Value $NewVersion
    Write-Log "VERSION updated to $NewVersion"
    # Helper ausführen (POSIX scripts über sh oder bash, wenn verfügbar)
    $HelperUpdate = Join-Path $Root 'scripts/helpers/helper_update_version_tags.sh'
    $HelperSync = Join-Path $Root 'scripts/helpers/helper_sync_docs.sh'
    if (Test-Path $HelperUpdate) { & 'sh' $HelperUpdate }
    if (Test-Path $HelperSync) { & 'sh' $HelperSync }
    Write-Log "Finalised new version $NewVersion"
}