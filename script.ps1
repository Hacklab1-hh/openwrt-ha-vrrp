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

# Prüfe auf neue Wrapper‑Parameter
if ($Command -eq '--type') {
    if ($Args.Count -lt 1) {
        Write-Host "Missing type value after --type" -ForegroundColor Red
        exit 1
    }
    $type = $Args[0]
    # Entferne den Typ aus den Argumenten
    $argsList = @()
    if ($Args.Count -gt 1) {
        $argsList = $Args[1..($Args.Count-1)]
    }
    $action = ''
    $nodes = 'all'
    # Argumente parsen
    for ($i = 0; $i -lt $argsList.Count; $i++) {
        switch ($argsList[$i]) {
            '--action' {
                if ($i + 1 -lt $argsList.Count) {
                    $action = $argsList[$i + 1]; $i++
                }
            }
            '--nodes' {
                if ($i + 1 -lt $argsList.Count) {
                    $nodes = $argsList[$i + 1]; $i++
                }
            }
        }
    }
    switch ($type.ToLower()) {
        'dev-harvest' {
            if ($action -eq '' -or $action -eq 'run') {
                & "$scriptRoot/scripts/helpers/dev-harvest.ps1"
            } else {
                Write-Host "Unknown action for dev-harvest: $action" -ForegroundColor Red
                exit 1
            }
        }
        'dev-sync-nodes' {
            if ($action -eq '' -or $action -eq 'run') {
                & "$scriptRoot/scripts/helpers/dev-sync-nodes.ps1" -Nodes $nodes
            } else {
                Write-Host "Unknown action for dev-sync-nodes: $action" -ForegroundColor Red
                exit 1
            }
        }
        default {
            Write-Host "Unknown type: $type" -ForegroundColor Red
            exit 1
        }
    }
    return
}

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
    'copy_downloads' {
        # Alias für dev-harvest
        & "$scriptRoot/scripts/helpers/dev-harvest.ps1" @Args
    }
    'upload_nodes' {
        # Alias für dev-sync-nodes
        # Standardmäßig werden alle Nodes adressiert
        if ($Args.Count -ge 2 -and $Args[0] -eq '--nodes') {
            $targetNodes = $Args[1]
            & "$scriptRoot/scripts/helpers/dev-sync-nodes.ps1" -Nodes $targetNodes
        } else {
            & "$scriptRoot/scripts/helpers/dev-sync-nodes.ps1"
        }
    }
    default {
        Write-Host "Unknown command: $Command" -ForegroundColor Red
        Write-Host "Available commands: manage_docs, readme, help, copy_downloads, upload_nodes"
        exit 1
    }
}