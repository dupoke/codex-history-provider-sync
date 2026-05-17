@echo off
setlocal
set "SCRIPT_DIR=%~dp0"
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -Sta -File "%SCRIPT_DIR%launch_ui.ps1" %*
set "EXITCODE=%ERRORLEVEL%"
if not "%EXITCODE%"=="0" (
  echo.
  echo Launch failed. Exit code: %EXITCODE%
  echo.
  echo If Python is missing, install Python 3 first:
  echo https://www.python.org/downloads/windows/
  echo.
  pause
)