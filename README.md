## My Config

This repo was created to share my config and to be plug and play when i switch computer. The goal is to have one command config for my daily workflow.

### To install my config just run:

#### Linux / macOS
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ivanlynch/.dotfiles/main/bin/dotfiles)"
```

#### Windows
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/ivanlynch/.dotfiles/main/bin/dotfiles.ps1'))
```

### Características

- Configuración cross-platform (Linux, macOS, Windows)
- Detección automática del sistema operativo
- Backup automático de la configuración existente
- Configuración de PowerShell en `.config/powershell` en Windows
- Instalación de dependencias necesarias según el sistema operativo
