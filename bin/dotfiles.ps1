# Script de instalación universal para Windows
# Configura automáticamente el entorno de PowerShell y dependencias

param(
    [switch]$NoPrompt = $false
)

# URLs
$repoUrl = "https://github.com/ivanlynch/.dotfiles.git"
$rawScriptUrl = "https://raw.githubusercontent.com/ivanlynch/.dotfiles/main/bin/dotfiles"
$profileUrl = "https://raw.githubusercontent.com/ivanlynch/.dotfiles/main/.config/powershell/profile.ps1"

# Configuración de codificación para evitar problemas de caracteres especiales
try {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    [Console]::InputEncoding = [System.Text.Encoding]::UTF8
    $OutputEncoding = [System.Text.Encoding]::UTF8
    $PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
    $PSDefaultParameterValues['*:Encoding'] = 'utf8'
} catch {}

function Write-ColoredOutput($message, $color = "Cyan") {
    Write-Host $message -ForegroundColor $color
}

# --- ACTUALIZACIÓN DE POWERSHELL ---
function Update-PowerShellIfNeeded {
    $currentVersion = $PSVersionTable.PSVersion
    $minRequiredVersion = [version]"7.0.0"
    if ($currentVersion -lt $minRequiredVersion) {
        Write-ColoredOutput "PowerShell $currentVersion detectado. Se requiere PowerShell 7 o superior." "Yellow"
        # Verificar si winget está disponible
        if (Get-Command winget -ErrorAction SilentlyContinue) {
            Write-ColoredOutput "Actualizando PowerShell con winget..." "Yellow"
            try {
                winget install --id Microsoft.PowerShell --source winget --accept-package-agreements --accept-source-agreements
                Write-ColoredOutput "PowerShell actualizado. Por favor, cierra esta ventana y abre 'PowerShell 7' desde el menú Inicio para continuar." "Green"
                exit
            } catch {
                Write-ColoredOutput "No se pudo actualizar automáticamente. Instala PowerShell 7 manualmente desde https://aka.ms/powershell-release?tag=stable" "Red"
                exit 1
            }
        } else {
            Write-ColoredOutput "No se encontró winget. Por favor, instala PowerShell 7 manualmente desde:" "Red"
            Write-ColoredOutput "https://aka.ms/powershell-release?tag=stable" "Yellow"
            exit 1
        }
    } else {
        Write-ColoredOutput "PowerShell $currentVersion está actualizado." "Green"
    }
}

# --- FUNCIONES DE INSTALACIÓN ---
function Initialize-PowerShellProfile {
    Write-ColoredOutput "Configurando entorno de PowerShell..." "Green"
    $psConfigDir = "$HOME\.config\powershell"
    if (-not (Test-Path $psConfigDir)) {
        Write-ColoredOutput "Creando directorio para perfil de PowerShell..." "Cyan"
        New-Item -ItemType Directory -Path $psConfigDir -Force | Out-Null
    }
    $localProfilePath = "$HOME\.dotfiles\.config\powershell\profile.ps1"
    $destinationProfilePath = "$psConfigDir\profile.ps1"
    if (Test-Path $localProfilePath) {
        Write-ColoredOutput "Copiando perfil de PowerShell desde repositorio local..." "Cyan"
        Copy-Item -Path $localProfilePath -Destination $destinationProfilePath -Force
    } else {
        Write-ColoredOutput "Descargando perfil de PowerShell..." "Cyan"
        try {
            Invoke-WebRequest -Uri $profileUrl -OutFile $destinationProfilePath -UseBasicParsing
        } catch {
            $errMsg = $_.Exception.Message
            Write-ColoredOutput "Error al descargar el perfil de PowerShell: $errMsg" "Red"
            exit 1
        }
    }
    $defaultProfileDir = Split-Path -Parent $PROFILE
    if (-not (Test-Path $defaultProfileDir)) {
        New-Item -ItemType Directory -Path $defaultProfileDir -Force | Out-Null
    }
    if (-not (Test-Path $PROFILE) -or (Get-Content $PROFILE | Select-String -Pattern ".config/powershell" -Quiet -SimpleMatch).Count -eq 0) {
        Write-ColoredOutput "Creando enlace al perfil de PowerShell..." "Cyan"
        $profileContent = @"
# Archivo generado automáticamente por dotfiles.ps1
# Redirige al perfil en .config/powershell
. `"$HOME\.config\powershell\profile.ps1`"
"@
        Set-Content -Path $PROFILE -Value $profileContent -Force
    }
    Write-ColoredOutput "Perfil de PowerShell configurado correctamente." "Green"
}

function Install-RequiredPackages {
    Write-ColoredOutput "Instalando dependencias necesarias..." "Green"
    if (-not (Get-Module -ListAvailable -Name PowerShellGet | Where-Object { $_.Version -ge "2.0" })) {
        Write-ColoredOutput "Instalando PowerShellGet..." "Cyan"
        try {
            Install-Module -Name PowerShellGet -Force -SkipPublisherCheck -AllowClobber -Scope CurrentUser -ErrorAction Stop
            Write-ColoredOutput "PowerShellGet instalado correctamente" "Green"
        } catch {
            $errMsg = $_.Exception.Message
            Write-ColoredOutput "Error al instalar PowerShellGet: $errMsg" "Yellow"
            Write-ColoredOutput "Continuando con la instalación..." "Cyan"
        }
    }
    $modules = @("PSReadLine", "Terminal-Icons")
    foreach ($module in $modules) {
        if (-not (Get-Module -ListAvailable -Name $module)) {
            Write-ColoredOutput "Instalando módulo ${module}..." "Cyan"
            try {
                Install-Module -Name $module -Scope CurrentUser -Force -SkipPublisherCheck -ErrorAction Stop
                Write-ColoredOutput "Módulo ${module} instalado correctamente" "Green"
            } catch {
                $errMsg = $_.Exception.Message
                Write-ColoredOutput "Error al instalar ${module}: $errMsg" "Yellow"
                Write-ColoredOutput "Continuando con la instalación..." "Cyan"
            }
        } else {
            Write-ColoredOutput "El módulo ${module} ya está instalado." "Cyan"
        }
    }
    if (-not (Get-Command starship -ErrorAction SilentlyContinue)) {
        Write-ColoredOutput "Instalando Starship prompt..." "Cyan"
        if (Get-Command choco -ErrorAction SilentlyContinue) {
            choco install starship -y
        } else {
            Write-ColoredOutput "Instalando Starship usando el script oficial..." "Cyan"
            Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://starship.rs/install.ps1')
        }
    } else {
        Write-ColoredOutput "Starship ya está instalado." "Cyan"
    }
    Write-ColoredOutput "Configurando Git para dotfiles..." "Cyan"
    if (-not (Test-Path "$HOME\.dotfiles")) {
        Write-ColoredOutput "Clonando repositorio dotfiles..." "Cyan"
        git clone --bare $repoUrl "$HOME\.dotfiles"
        git --git-dir="$HOME\.dotfiles" --work-tree="$HOME" checkout
        git --git-dir="$HOME\.dotfiles" --work-tree="$HOME" config --local status.showUntrackedFiles no
    }
    Write-ColoredOutput "Dependencias instaladas correctamente." "Green"
}

function Restart-Terminal {
    Write-ColoredOutput "Configuración completada con éxito." "Green"
    Write-ColoredOutput "Para aplicar todos los cambios, la terminal debe reiniciarse." "Yellow"
    $isVsCode = $env:TERM_PROGRAM -eq "vscode"
    $isWindowsTerminal = $env:WT_SESSION
    $isNative = -not $isVsCode -and -not $isWindowsTerminal
    if (-not $NoPrompt) {
        $restart = Read-Host "¿Deseas abrir una nueva ventana de PowerShell automáticamente ahora? (S/N)"
        if ($restart -eq "S" -or $restart -eq "s") {
            Write-ColoredOutput "Abriendo una nueva ventana de PowerShell..." "Cyan"
            Start-Process pwsh -ArgumentList "-NoExit", "-Command", "cd '$pwd'"
            if ($isNative) {
                Write-ColoredOutput "Cerrando esta ventana..." "Yellow"
                exit
            } else {
                Write-ColoredOutput "NOTA: Si estás en VSCode o Windows Terminal, cierra manualmente esta pestaña/ventana." "Magenta"
            }
        } else {
            Write-ColoredOutput "Recuerda cerrar y volver a abrir la terminal para aplicar todos los cambios." "Magenta"
        }
    }
    Write-ColoredOutput ""
    Write-ColoredOutput "IMPORTANTE: Para aplicar TODOS los cambios realizados, debes:" "Magenta"
    Write-ColoredOutput "1. Cerrar esta ventana de PowerShell" "Magenta"
    Write-ColoredOutput "2. Abrir una nueva ventana de PowerShell" "Magenta"
    Write-ColoredOutput ""
}

# --- FLUJO PRINCIPAL ---
Write-ColoredOutput "Instalador de dotfiles para Windows" "Green"
Update-PowerShellIfNeeded

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-ColoredOutput "Git no está instalado. Por favor, instala Git antes de continuar." "Red"
    exit 1
}

$tempDir = "$env:TEMP\dotfiles-install"
if (-not (Test-Path $tempDir)) {
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
}
$scriptPath = "$tempDir\dotfiles"
Write-ColoredOutput "Descargando script de dotfiles..."
try {
    Invoke-WebRequest -Uri $rawScriptUrl -OutFile $scriptPath -UseBasicParsing
} catch {
    $errMsg = $_.Exception.Message
    Write-ColoredOutput "Error al descargar el script: $errMsg" "Red"
    exit 1
}
$bashPath = $null
$gitBashPaths = @(
    "C:\Program Files\Git\bin\bash.exe",
    "C:\Program Files (x86)\Git\bin\bash.exe"
)
foreach ($path in $gitBashPaths) {
    if (Test-Path $path) {
        $bashPath = $path
        break
    }
}

Write-ColoredOutput "Configurando entorno de Windows nativo..." "Green"
Initialize-PowerShellProfile
Install-RequiredPackages
Restart-Terminal

if ($bashPath) {
    Write-ColoredOutput "Se ha detectado Git Bash. También puedes ejecutar la configuración con Bash si lo prefieres." "Cyan"
    Write-ColoredOutput "Para usar la configuración de Bash, ejecuta: " "Cyan"
    Write-ColoredOutput "& '$bashPath' '$scriptPath'" "Yellow"
} elseif (Get-Command wsl -ErrorAction SilentlyContinue) {
    Write-ColoredOutput "Se ha detectado WSL. También puedes ejecutar la configuración con WSL si lo prefieres." "Cyan"
    Write-ColoredOutput "Para usar la configuración de WSL, ejecuta: " "Cyan"
    Write-ColoredOutput "wsl bash '$scriptPath'" "Yellow"
}

Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
