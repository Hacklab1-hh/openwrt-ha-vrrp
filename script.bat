@echo off
REM script.bat – Wrapper für die wichtigsten Helfer

REM Der erste Parameter bestimmt das Unterkommando (manage_docs, readme, help).
REM Weitere Parameter werden an das entsprechende Skript weitergereicht.

SETLOCAL
SET cmd=%1
SHIFT
SET scriptdir=%~dp0

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

ECHO Unknown command: %cmd%
ECHO Available commands: manage_docs, readme, help
EXIT /B 1