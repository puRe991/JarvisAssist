@echo off
setlocal EnableExtensions

set "ROOT=%~dp0"
if not "%OPENJARVIS_HOME%"=="" set "ROOT=%OPENJARVIS_HOME%\"
set "SRC=%ROOT%src"
set "KEYS=%USERPROFILE%\.openjarvis\cloud-keys.env"
set "OPENJARVIS_IS_32BIT_WINDOWS=0"
if /i "%PROCESSOR_ARCHITECTURE%"=="x86" if "%PROCESSOR_ARCHITEW6432%"=="" set "OPENJARVIS_IS_32BIT_WINDOWS=1"

if not exist "%SRC%\pyproject.toml" (
  echo [fail] OpenJarvis source not found at "%SRC%".
  echo        Re-run deploy\windows\install.ps1 or set OPENJARVIS_HOME before installing.
  exit /b 1
)

where uv >nul 2>nul
if errorlevel 1 (
  echo [fail] uv.exe not found on PATH. Re-run the installer or open a new PowerShell/CMD.
  exit /b 1
)

rem Load cloud keys written by the installer or the desktop Cloud Models tab.
if exist "%KEYS%" (
  for /f "usebackq eol=# tokens=1,* delims==" %%A in ("%KEYS%") do (
    if not "%%A"=="" if not "%%B"=="" set "%%A=%%B"
  )
)

if "%OPENJARVIS_ENGINE%"=="" (
  if "%OPENJARVIS_IS_32BIT_WINDOWS%"=="1" (
    set "OPENJARVIS_ENGINE=cloud"
  ) else (
    set "OPENJARVIS_ENGINE=ollama"
  )
)
if "%OPENJARVIS_MODEL%"=="" (
  if "%OPENJARVIS_IS_32BIT_WINDOWS%"=="1" (
    set "OPENJARVIS_MODEL=gpt-4o-mini"
  ) else (
    set "OPENJARVIS_MODEL=qwen3.5:2b"
  )
)
if "%OPENJARVIS_HOST%"=="" set "OPENJARVIS_HOST=127.0.0.1"
if "%OPENJARVIS_PORT%"=="" set "OPENJARVIS_PORT=8000"

if "%OPENJARVIS_IS_32BIT_WINDOWS%"=="1" if /i "%OPENJARVIS_ENGINE%"=="cloud" if "%OPENAI_API_KEY%"=="" (
  echo [warn] Native 32-bit Windows defaults to cloud mode because Ollama for Windows is 64-bit only.
  echo [warn] OPENAI_API_KEY is not set; configure a cloud key or a remote backend before chatting.
)

if /i "%OPENJARVIS_ENGINE%"=="ollama" (
  where ollama >nul 2>nul
  if errorlevel 1 (
    echo [warn] Ollama is not on PATH. Continuing; jarvis will fail if no other engine is configured.
  ) else (
    ollama list >nul 2>nul
    if errorlevel 1 start "" /min ollama serve
  )
)

echo [info] Starting OpenJarvis on http://%OPENJARVIS_HOST%:%OPENJARVIS_PORT%
echo [info] Engine=%OPENJARVIS_ENGINE% Model=%OPENJARVIS_MODEL%
echo [info] To use OpenAI from this batch: set OPENJARVIS_ENGINE=cloud and OPENJARVIS_MODEL=gpt-4o-mini

uv run --project "%SRC%" jarvis serve --host "%OPENJARVIS_HOST%" --port "%OPENJARVIS_PORT%" --engine "%OPENJARVIS_ENGINE%" --model "%OPENJARVIS_MODEL%"
exit /b %ERRORLEVEL%
