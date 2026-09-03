@echo off
setlocal EnableExtensions
REM Local Publish — publica una URL local en Internet
REM Uso:
REM   publish-local.bat
REM   publish-local.bat http://localhost:3000
REM   publish-local.bat 3000
REM   publish-local.bat http://localhost:5173 --open

cd /d "%~dp0"

set "OPEN="
set "TARGET="

:parse
if "%~1"=="" goto run
if /I "%~1"=="--open" (
  set "OPEN=-OpenBrowser"
  shift
  goto parse
)
if /I "%~1"=="-OpenBrowser" (
  set "OPEN=-OpenBrowser"
  shift
  goto parse
)
if not defined TARGET (
  set "TARGET=%~1"
  shift
  goto parse
)
shift
goto parse

:run
if defined TARGET (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Publish-Local.ps1" -Url "%TARGET%" %OPEN%
) else (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Publish-Local.ps1" %OPEN%
)
set "ERR=%ERRORLEVEL%"
echo.
pause
exit /b %ERR%
