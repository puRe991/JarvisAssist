@echo off
setlocal EnableExtensions

rem OpenJarvis Windows installer wrapper.
rem Keeps cmd.exe users on the same canonical PowerShell installer.

set "SCRIPT_DIR=%~dp0"
set "INSTALL_PS1=%SCRIPT_DIR%install.ps1"

if not exist "%INSTALL_PS1%" (
  echo [fail] install.ps1 not found next to installer.bat:
  echo        "%INSTALL_PS1%"
  echo        Use downloader.bat or download install.ps1 into the same folder.
  exit /b 1
)

set "POWERSHELL_EXE=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"

rem If a 32-bit cmd.exe runs on 64-bit Windows, Sysnative reaches the real
rem 64-bit PowerShell. On native 32-bit Windows, Sysnative does not exist and
rem System32 is correct.
if exist "%SystemRoot%\Sysnative\WindowsPowerShell\v1.0\powershell.exe" (
  set "POWERSHELL_EXE=%SystemRoot%\Sysnative\WindowsPowerShell\v1.0\powershell.exe"
)

if not exist "%POWERSHELL_EXE%" (
  echo [fail] powershell.exe not found. Windows PowerShell 5.1 or newer is required.
  exit /b 1
)

echo [info] Running OpenJarvis installer via "%POWERSHELL_EXE%"...
"%POWERSHELL_EXE%" -NoProfile -ExecutionPolicy Bypass -File "%INSTALL_PS1%" %*
exit /b %ERRORLEVEL%
