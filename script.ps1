<#
    script.ps1 – Wrapper für die wichtigsten Helfer

    Dieses PowerShell‑Script bietet eine einheitliche Schnittstelle zu
    den vorhandenen Hilfsskripten.  Der erste Parameter wählt das
    Unterkommando aus (manage_docs, readme oder help); alle weiteren
    Argumente werden an das entsprechende Skript weitergegeben.

    Beispiele:
      .\script.ps1 manage_docs --type readme --entry "Dies ist ein Test" --new-version 0.5.16-007
      .\script.ps1 readme 0.5.16-007_reviewfix17_a4_fix2
      .\script.ps1 help
#>

param(
  [Parameter(Mandatory=$true)][string]$Command,
  [Parameter(ValueFromRemainingArguments=$true)][string[]]$Args
)

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition

switch ($Command.ToLower()) {
    'manage_docs' {
        # call the PowerShell version of manage_docs
        & "$scriptRoot/scripts/helpers/manage_docs.ps1" @Args
    }
    'readme' {
        # readme.sh läuft unter einer POSIX‑Shell; rufe bash auf
        & bash "$scriptRoot/scripts/readme.sh" @Args
    }
    'help' {
        & bash "$scriptRoot/scripts/help.sh" @Args
    }
    default {
        Write-Host "Unknown command: $Command" -ForegroundColor Red
        Write-Host "Available commands: manage_docs, readme, help"
        exit 1
    }
}