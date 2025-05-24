# Inicializa Starship prompt
Invoke-Expression (&starship init powershell)

# Aliases para configuraciones
function Reload-Profile { & $PROFILE }
Set-Alias -Name reload -Value Reload-Profile

function Edit-Profile { code $PROFILE }
Set-Alias -Name edit -Value Edit-Profile

function Edit-NvimConfig { Set-Location "$HOME\.config\nvim"; nvim . }
Set-Alias -Name config -Value Edit-NvimConfig

function Invoke-DotFiles { git --git-dir=$HOME/.dotfiles --work-tree=$HOME @args }
Set-Alias -Name dotfiles -Value Invoke-DotFiles

function Edit-TmuxConfig { nvim "$HOME\.tmux.conf" }
Set-Alias -Name tmuxconf -Value Edit-TmuxConfig

function Open-Workspaces { Set-Location "$HOME\workspaces" }
Set-Alias -Name ws -Value Open-Workspaces

function Open-Ansible { Set-Location "$HOME\ansible" }
Set-Alias -Name an -Value Open-Ansible

function Open-Dev { Set-Location "$HOME\dev" }
Set-Alias -Name dev -Value Open-Dev

function Clean-Environment { 
    $initScript = "$HOME\workspaces\clean\init.ps1"
    if (Test-Path $initScript) {
        & $initScript
    } else {
        Write-Host "El script de inicialización no existe en la ruta: $initScript" -ForegroundColor Red
    }
}
Set-Alias -Name clean-env -Value Clean-Environment

# Configuración de Java si está presente
$javaPath = "C:\Program Files\Java\jdk-11"
if (Test-Path $javaPath) {
    $env:PATH = "$javaPath\bin;$env:PATH"
    $env:JAVA_HOME = $javaPath
}

# Configuración de Android si está presente
$androidHome = "$HOME\AppData\Local\Android\Sdk"
if (Test-Path $androidHome) {
    $env:ANDROID_HOME = $androidHome
    $env:ANDROID_SDK_ROOT = $androidHome
    $env:PATH = "$env:PATH;$androidHome\emulator;$androidHome\tools;$androidHome\tools\bin;$androidHome\platform-tools"
}

# Configuración para Python
# El equivalente a pyenv en Windows es pyenv-win
# Asumiendo que está instalado
$pyenvPath = "$HOME\.pyenv\pyenv-win\"
if (Test-Path $pyenvPath) {
    $env:PYENV = $pyenvPath
    $env:PYENV_ROOT = $pyenvPath
    $env:PATH = "$env:PYENV\bin;$env:PYENV\shims;$env:PATH"
}

# Configuración de Puppeteer
$env:PUPPETEER_SKIP_CHROMIUM_DOWNLOAD = "true"
if (Get-Command chromium -ErrorAction SilentlyContinue) {
    $env:PUPPETEER_EXECUTABLE_PATH = (Get-Command chromium).Path
} elseif (Get-Command chrome -ErrorAction SilentlyContinue) {
    $env:PUPPETEER_EXECUTABLE_PATH = (Get-Command chrome).Path
}

# Importar PSReadLine para autocompletado similar a zsh-autosuggestions
Import-Module PSReadLine

# Verificar la versión de PSReadLine antes de configurar opciones avanzadas
$psReadLineVersion = (Get-Module PSReadLine).Version
if ($psReadLineVersion -ge [Version]"2.1.0") {
    # Estas opciones solo están disponibles en PSReadLine 2.1.0 o superior
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle ListView
}
# Esta opción está disponible en todas las versiones
Set-PSReadLineOption -EditMode Windows

# Importar Terminal-Icons para mostrar iconos en el directorio (equivalente visual)
if (Get-Module -ListAvailable -Name Terminal-Icons) {
    Import-Module -Name Terminal-Icons
} else {
    Write-Host "Para tener iconos en la terminal, instala el módulo Terminal-Icons con: Install-Module -Name Terminal-Icons -Repository PSGallery" -ForegroundColor Yellow
}

