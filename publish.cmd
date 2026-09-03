@echo off
cd /d "%~dp0"
REM Sin pause — para usar desde terminal
if "%~1"=="" (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Publish-Local.ps1"
) else if /I "%~1"=="--open" (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Publish-Local.ps1" -OpenBrowser
) else if /I "%~2"=="--open" (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Publish-Local.ps1" -Url "%~1" -OpenBrowser
) else (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Publish-Local.ps1" -Url "%~1"
)
