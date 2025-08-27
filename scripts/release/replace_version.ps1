<# 
scripts/release/replace_version.ps1
Usage (PowerShell, repo root):
  .\scripts\release\replace_version.ps1 -Old "0.5.16-007_reviewfix16_featurefix15" -New "0.5.16-007_reviewfix16_featurefix5"

Notes:
- Replaces in file CONTENTS: OLD_fix1 -> NEW, then OLD -> NEW
- Renames FILES/PATHS via git mv: OLD_fix1 -> NEW, then OLD -> NEW
- Updates VERSION, stages changes; you still need to commit.
- If your ExecutionPolicy blocks scripts, run:
    powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\release\replace_version.ps1 -Old "<old>" -New "<new>"
#>

param(
  [Parameter(Mandatory=$true)][string]$Old,
  [Parameter(Mandatory=$true)][string]$New
)

$ErrorActionPreference = "Stop"

function Git($args) {
  $pinfo = New-Object System.Diagnostics.ProcessStartInfo
  $pinfo.FileName = "git"
  $pinfo.Arguments = ($args -join " ")
  $pinfo.RedirectStandardOutput = $true
  $pinfo.RedirectStandardError = $true
  $pinfo.UseShellExecute = $false
  $p = New-Object System.Diagnostics.Process
  $p.StartInfo = $pinfo
  [void]$p.Start()
  $out = $p.StandardOutput.ReadToEnd()
  $err = $p.StandardError.ReadToEnd()
  $p.WaitForExit()
  if ($p.ExitCode -ne 0) { throw "git $args`n$err" }
  return $out.TrimEnd()
}

# Sanity
[void](Git @("rev-parse","--show-toplevel"))
Set-Location (Git @("rev-parse","--show-toplevel"))

Write-Host "== Replace in contents: '$Old`_fix1' -> '$New', then '$Old' -> '$New'"
# Get list of text files that contain $Old
$files = (Git @("grep","-Il","--",$Old)) -split "`n" | Where-Object { $_ -and (Test-Path $_) }
foreach ($f in $files) {
  $orig = Get-Content -Raw -Encoding UTF8 -- $f
  $newc = $orig.Replace("${Old}_fix1",$New).Replace($Old,$New)
  if ($newc -ne $orig) {
    Set-Content -NoNewline -Encoding UTF8 -- $f $newc
    [void](Git @("add","--",$f))
    Write-Host "  updated: $f"
  }
}

Write-Host "== Rename files/paths where needed (git mv)"
$oldEsc = [regex]::Escape($Old)
$tracked = (Git @("ls-files")) -split "`n" | Where-Object { $_ }
foreach ($f in $tracked) {
  $np = [regex]::Replace($f, "$oldEsc`_fix1", $New)
  $np = [regex]::Replace($np, $oldEsc, $New)
  if ($np -ne $f) {
    $parent = Split-Path -Parent $np
    if ($parent) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
    try { [void](Git @("mv","-k","--",$f,$np)) } catch { }
    Write-Host "  renamed: $f -> $np"
  }
}

Write-Host "== Update VERSION"
Set-Content -NoNewline -Encoding UTF8 VERSION $New
[void](Git @("add","VERSION"))
Write-Host "  VERSION := $New"

Write-Host "== Done. Next steps:"
Write-Host "   git status -sb"
Write-Host "   git commit -m ""$New: normalize version strings and paths (drop _fix1)"""
Write-Host "   git push   # or: git push --force-with-lease (if amending)"

