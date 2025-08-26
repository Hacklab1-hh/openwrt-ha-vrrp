# Datei: scripts/git/rescue-repo.ps1
# Zweck: Nach versehentlichem Löschen von .git lokalen Stand retten und mit Remote wieder verbinden.
# Aufruf:  pwsh -File .\scripts\git\rescue-repo.ps1 -Remote https://github.com/Hacklab1-hh/openwrt-ha-vrrp.git

param(
  [string]$Remote = "https://github.com/Hacklab1-hh/openwrt-ha-vrrp.git",
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"

function Run($cmd, [switch]$AllowFail) {
  Write-Host ">> $cmd"
  try { & cmd /c $cmd } catch { if (-not $AllowFail) { throw } }
}

# 0) Sanity
if (-not (Test-Path ".")) { throw "Kein Arbeitsverzeichnis gefunden." }
if (Test-Path ".git") { throw ".git existiert bereits – dieses Skript ist für den Rettungsfall ohne .git gedacht." }

# 1) Rettungssnapshot
Run "git init"
Run "git add -A"
Run "git commit -m ""Rescue: rebuild .git after accidental deletion"""

# Patch sichern
$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$patchPath = "..\rescue-$stamp.patch"
Run "git format-patch -1 HEAD --stdout > ""$patchPath"""

# 2) Remote anbinden & History holen
Run "git remote add origin $Remote" -AllowFail
Run "git fetch origin"

# Remote-Default-Branch ermitteln (origin/HEAD -> origin/<branch>)
$ref = (git symbolic-ref --short refs/remotes/origin/HEAD 2>$null)
if (-not $ref) { throw "Konnte origin/HEAD nicht ermitteln. Prüfe Remote ($Remote) oder Branch-Schutz." }
$branch = $ref.Split('/')[1]
Write-Host "Remote-Default-Branch erkannt: $branch"

# 3) Auf Remote-Branch schalten
Run "git checkout -B $branch origin/$branch"

# 4) Patch anwenden
if ($DryRun) {
  Run "git apply --check ""$patchPath""" -AllowFail
  Write-Host "DryRun beendet. Patchprüfung ok/nok siehe oben."
  exit 0
} else {
  # git am bewahrt Autor/Datum; bei Konflikten manuell lösen und 'git am --continue'
  Run "git am ""$patchPath""" -AllowFail
  Write-Host "Falls Konflikte auftraten: löse sie und führe 'git am --continue' aus."
}

# 5) Push
Run "git push -u origin $branch" -AllowFail
Write-Host "✅ Rettung abgeschlossen. Repo ist wieder verbunden."
