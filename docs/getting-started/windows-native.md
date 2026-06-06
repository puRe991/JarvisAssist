# Native Windows (advanced)

Phase-1 of the native-Windows-support RFC (#298). Mirrors the Linux
(systemd) and macOS (launchd) deployments — but for PowerShell, without
WSL2 or Docker. Choose this over [WSL2](wsl2.md) only if you want to
avoid a Linux VM; WSL2 remains the smoother experience for most users.

## What you get

- A PowerShell installer plus `cmd.exe` batch wrappers that probe
  prerequisites, install `uv`, clone the repo, install Ollama plus a starter
  model on 64-bit Windows, and run `uv sync --extra server`.
- An optional Windows scheduled-task service equivalent to the systemd
  unit and launchd plist.
- A `start-jarvis.bat` helper in `%LOCALAPPDATA%\OpenJarvis` for manual
  startup without remembering `uv` commands.
- Optional OpenAI API-key import into `%USERPROFILE%\.openjarvis\cloud-keys.env`.
- Loopback default — the service binds `127.0.0.1` so no OpenJarvis server API
  key is required.

## What you need

- Windows 10 1809+ or Windows 11.
- Python 3.10 – 3.13 (Python 3.14 has no numpy Windows wheels yet —
  see [#432](https://github.com/open-jarvis/OpenJarvis/issues/432)).
- `git` on PATH.
- ~5 GB free disk on `%LOCALAPPDATA%`.
- Native 32-bit Windows can use the cloud-engine path, but local Ollama models
  are skipped because the Windows Ollama installer is 64-bit only. Install
  32-bit Python 3.10 - 3.13 manually before running the installer.

## Install

In any PowerShell:

```powershell
irm https://open-jarvis.github.io/OpenJarvis/install.ps1 | iex
```

In `cmd.exe`, use the batch downloader:

```cmd
curl -L -o downloader.bat https://open-jarvis.github.io/OpenJarvis/downloader.bat
.\downloader.bat
```

In a cloned repo, the batch files are `deploy\windows\installer.bat` and
`deploy\windows\downloader.bat`.

The installer will:

1. Refuse non-Windows hosts and old Windows builds.
2. Confirm Python 3.10 – 3.13.
3. Confirm `git`.
4. Install `uv` if absent (via the official `astral.sh/uv` PowerShell
   installer).
5. Clone the repo to `%LOCALAPPDATA%\OpenJarvis\src`.
6. Run `uv sync --extra server`.
7. Install/start Ollama if needed and pull the `qwen3.5:2b` starter model
   on 64-bit Windows; on native 32-bit Windows, skip Ollama and default the
   starter batch to cloud mode.
8. Offer to store an OpenAI API key for cloud models.
9. Install `%LOCALAPPDATA%\OpenJarvis\start-jarvis.bat`.
10. Prompt to register the scheduled-task service (skip with
   `-SkipService`).

## Run it

```powershell
cd "$env:LOCALAPPDATA\OpenJarvis\src"
uv run jarvis serve
```

Or use the generated batch:

```cmd
%LOCALAPPDATA%\OpenJarvis\start-jarvis.bat
```

To use OpenAI from the batch, store `OPENAI_API_KEY` during install or in the
Cloud Models tab, then run:

```cmd
set OPENJARVIS_ENGINE=cloud
set OPENJARVIS_MODEL=gpt-4o-mini
%LOCALAPPDATA%\OpenJarvis\start-jarvis.bat
```

Open `http://127.0.0.1:8000/health` to verify.

## Scheduled-task service

If you skipped the prompt during install, register the auto-start task
manually:

```powershell
$srv = "$env:LOCALAPPDATA\OpenJarvis\src\deploy\windows\jarvis-service.ps1"
powershell -ExecutionPolicy Bypass -File $srv install
```

State:

```powershell
powershell -ExecutionPolicy Bypass -File $srv status
```

Remove:

```powershell
powershell -ExecutionPolicy Bypass -File $srv uninstall
```

See [`deploy/windows/README.md`](https://github.com/open-jarvis/OpenJarvis/blob/main/deploy/windows/README.md)
for the LAN-exposed configuration and the parity table against
systemd / launchd.

## See also

- [WSL2 install](wsl2.md) — the recommended Windows path.
- [Full installer reference](install.md).
