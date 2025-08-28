@echo off
REM script.bat – Wrapper für die wichtigsten Helfer

REM Dieses Wrapper-Skript bietet eine einheitliche CLI für verschiedene
REM Unterkommandos.  Zusätzlich können mit den Parametern --type
REM "dev-harvest" und "dev-sync-nodes" die Download‑Aggregation bzw.
REM das Synchronisieren auf die Nodes gestartet werden.


SETLOCAL ENABLEDELAYEDEXPANSION
SET cmd=%1
SHIFT
SET scriptdir=%~dp0

REM --type Parser für neue Funktionen
SET type=
SET action=
SET nodes=all

IF /I "%cmd%"=="--type" (
  REM Der nächste Parameter ist der Typ (dev-harvest oder dev-sync-nodes)
  SET type=%1
  SHIFT
  :loop_type
  IF "%1"=="" GOTO after_type
  IF "%1"=="--action" (
    SET action=%2
    SHIFT
    SHIFT
    GOTO loop_type
  )
  IF "%1"=="--nodes" (
    SET nodes=%2
    SHIFT
    SHIFT
    GOTO loop_type
  )
  SHIFT
  GOTO loop_type
  :after_type
)

IF /I "%type%"=="dev-harvest" (
  REM Führe die Harvest‑Funktion aus (Aggregate Downloads)
  powershell -NoProfile -ExecutionPolicy Bypass -File "%scriptdir%scripts\helpers\dev-harvest.ps1"
  GOTO :EOF
)

IF /I "%type%"=="dev-sync-nodes" (
  REM Führe die Sync‑Funktion aus (Pakete auf Nodes kopieren)
  powershell -NoProfile -ExecutionPolicy Bypass -File "%scriptdir%scripts\helpers\dev-sync-nodes.ps1" -Nodes %nodes%
  GOTO :EOF
)

IF /I "%cmd%"=="manage_docs" (
  REM Verwende PowerShell, um manage_docs.ps1 auszuführen
  powershell -NoProfile -ExecutionPolicy Bypass -File "%scriptdir%scripts\helpers\manage_docs.ps1" %*
  GOTO :EOF
)

IF /I "%cmd%"=="readme" (
  REM Verwende bash (z. B. aus Git for Windows) um readme.sh zu starten
  bash "%scriptdir%scripts/readme.sh" %*
  GOTO :EOF
)

IF /I "%cmd%"=="help" (
  bash "%scriptdir%scripts/help.sh" %*
  GOTO :EOF
)

IF /I "%cmd%"=="copy_downloads" (
  REM Alias: nutze dev-harvest.ps1
  powershell -NoProfile -ExecutionPolicy Bypass -File "%scriptdir%scripts\helpers\dev-harvest.ps1"
  GOTO :EOF
)

IF /I "%cmd%"=="upload_nodes" (
  REM Alias: nutze dev-sync-nodes.ps1
  IF "%1"=="--nodes" (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%scriptdir%scripts\helpers\dev-sync-nodes.ps1" -Nodes %2
  ) ELSE (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%scriptdir%scripts\helpers\dev-sync-nodes.ps1"
  )
  GOTO :EOF
)

ECHO Unknown command: %cmd%
ECHO Available commands: manage_docs, readme, help, copy_downloads, upload_nodes
EXIT /B 1