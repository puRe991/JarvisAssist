@echo off
setlocal EnableExtensions

rem Downloads the canonical OpenJarvis Windows installer and runs it.
rem Optional arguments are forwarded to installer.bat / install.ps1.

set "BASE_URL=https://open-jarvis.github.io/OpenJarvis"
set "WORK_DIR=%TEMP%\OpenJarvisInstall"
set "INSTALLER_BAT=%WORK_DIR%\installer.bat"
set "INSTALL_PS1=%WORK_DIR%\install.ps1"
set "POWERSHELL_EXE=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"

if exist "%SystemRoot%\Sysnative\WindowsPowerShell\v1.0\powershell.exe" (
  set "POWERSHELL_EXE=%SystemRoot%\Sysnative\WindowsPowerShell\v1.0\powershell.exe"
)

if not exist "%POWERSHELL_EXE%" (
  echo [fail] powershell.exe not found. Windows PowerShell 5.1 or newer is required.
  exit /b 1
)

if not exist "%WORK_DIR%" mkdir "%WORK_DIR%" >nul 2>nul
if errorlevel 1 (
  echo [fail] Could not create "%WORK_DIR%".
  exit /b 1
)

echo [info] Downloading OpenJarvis installer to "%WORK_DIR%"...
"%POWERSHELL_EXE%" -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ProgressPreference='SilentlyContinue'; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -UseBasicParsing -Uri '%BASE_URL%/installer.bat' -OutFile '%INSTALLER_BAT%'; Invoke-WebRequest -UseBasicParsing -Uri '%BASE_URL%/install.ps1' -OutFile '%INSTALL_PS1%'"
if errorlevel 1 (
  echo [fail] Download failed. Check your network/TLS settings and retry.
  exit /b 1
)

if not exist "%INSTALLER_BAT%" (
  echo [fail] Downloaded installer.bat is missing.
  exit /b 1
)
if not exist "%INSTALL_PS1%" (
  echo [fail] Downloaded install.ps1 is missing.
  exit /b 1
)

call "%INSTALLER_BAT%" %*
exit /b %ERRORLEVEL%
