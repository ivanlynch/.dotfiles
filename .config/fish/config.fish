# ------------------------------------------------------------
# Configuración del PATH de Homebrew (MUY IMPORTANTE: DEBE IR PRIMERO)
# ------------------------------------------------------------
if test (uname) = "Darwin"
    if test -d /opt/homebrew # macOS ARM
        fish_add_path -mP /opt/homebrew/bin /opt/homebrew/sbin
    else if test -d /usr/local/Homebrew # macOS Intel (ruta más antigua)
         fish_add_path -mP /usr/local/Homebrew/bin /usr/local/Homebrew/sbin
    else if test -d /usr/local/bin # macOS Intel (ruta común donde Homebrew instala symlinks)
         fish_add_path -mP /usr/local/bin /usr/local/sbin
    end
else if test -d /home/linuxbrew/.linuxbrew # Linuxbrew
    fish_add_path -mP /home/linuxbrew/.linuxbrew/bin /home/linuxbrew/.linuxbrew/sbin
end

# ------------------------------------------------------------
# Configuración general de entorno y PATH (después de Homebrew)
# ------------------------------------------------------------
# NOTA: La configuración de PATH para $HOME/.local/bin ahora se maneja
# a través de un archivo en ~/.config/fish/conf.d/ para asegurar
# que se cargue temprano y correctamente (asegúrate que esto no entre en conflicto
# con el orden si pones $HOME/.local/bin aquí también).
# Si $HOME/.local/bin está en conf.d, se cargará incluso antes que este archivo.

# Java (Ejemplo, ajusta según tu método de instalación: asdf, sdkman, manual)
if test (uname) = "Darwin"
    if test -d /opt/homebrew/opt/openjdk@11/bin # Ejemplo: Java de Homebrew
        fish_add_path -mP /opt/homebrew/opt/openjdk@11/bin
    end
end

# Android (Ejemplo, ajusta según tu método de instalación)
if test (uname) = "Darwin"
    set -q ANDROID_HOME; or set -gx ANDROID_HOME $HOME/Library/Android/sdk
    set -q ANDROID_SDK_ROOT; or set -gx ANDROID_SDK_ROOT $HOME/Library/Android/sdk
    if test -n "$ANDROID_HOME"
        fish_add_path -mP $ANDROID_HOME/emulator
        fish_add_path -mP $ANDROID_HOME/tools
        fish_add_path -mP $ANDROID_HOME/tools/bin
        fish_add_path -mP $ANDROID_HOME/platform-tools
    end
end

# pyenv (si lo usas)
set -q PYENV_ROOT; or set -gx PYENV_ROOT $HOME/.pyenv
if test -d "$PYENV_ROOT"
    fish_add_path -mP $PYENV_ROOT/bin
    if type -q pyenv
        pyenv init - | source   # Para shims y autocompletado
    end
end

# asdf (Gestor de versiones)
# Esta sección DEBE ir DESPUÉS de la configuración del PATH de Homebrew.

# 1. Asegurar que el directorio 'bin' de asdf (instalación manual) esté en PATH.
if test -d "$HOME/.asdf/bin"
    fish_add_path -P "$HOME/.asdf/bin"
end
# Nota: Si asdf fue instalado por Homebrew, su 'bin' (symlink)
# es usualmente /opt/homebrew/bin/asdf, que ya debería estar en PATH
# gracias a la sección de Homebrew PATH de arriba.

# 2. Cargar el script asdf.fish.
set -l asdf_init_script_path "" # Declarar e inicializar

if test -f "$HOME/.asdf/asdf.fish" # Priorizar instalación manual/directa de asdf
    set asdf_init_script_path "$HOME/.asdf/asdf.fish"
else if type -q brew # Si no se encontró asdf.fish manual Y el comando 'brew' existe
    # Intentar encontrar asdf.fish si asdf fue instalado vía Homebrew
    set -l brew_asdf_opt_dir (brew --prefix asdf 2>/dev/null)
    if test -n "$brew_asdf_opt_dir"; and test -f "$brew_asdf_opt_dir/libexec/asdf.fish"
        set asdf_init_script_path "$brew_asdf_opt_dir/libexec/asdf.fish"
    end
    set -e brew_asdf_opt_dir # Limpiar variable temporal
end # Fin de la comprobación 'type -q brew'

# Cargar el script asdf.fish si se encontró una ruta válida
if test -n "$asdf_init_script_path"
    source "$asdf_init_script_path"
else
    # Opcional: Descomentar para mostrar una advertencia si asdf.fish no se encuentra.
    # echo "Advertencia: No se pudo encontrar asdf.fish. asdf no se inicializará completamente." >&2
end
set -e asdf_init_script_path # Limpiar variable temporal

# Puppeteer (ejemplo, si lo usas)
if type -q chromium
    set -q PUPPETEER_EXECUTABLE_PATH; or set -gx PUPPETEER_EXECUTABLE_PATH (command -v chromium)
else if type -q chromium-browser
    set -q PUPPETEER_EXECUTABLE_PATH; or set -gx PUPPETEER_EXECUTABLE_PATH (command -v chromium-browser)
end
set -q PUPPETEER_SKIP_CHROMIUM_DOWNLOAD; or set -gx PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true

# Windsurf (Solo si estás en macOS y tienes esta app)
if test (uname) = "Darwin"
    if test -d "/Applications/Windsurf.app"
        fish_add_path -mP "/Applications/Windsurf.app/Contents/MacOS"
    end
end

# ------------------------------------------------------------
# Configuración interactiva (solo para sesiones interactivas)
# ------------------------------------------------------------
if status is-interactive

    # Prompt moderno (Starship)
    if type -q starship
        starship init fish | source
    end

    # zoxide (cd mejorado)
    if type -q zoxide
        zoxide init fish | source
    end

    # Aliases generales
    alias reload="source ~/.config/fish/config.fish"
    alias edit="command nvim ~/.config/fish/config.fish"
    alias config="cd ~/.config/nvim && command nvim ."
    alias dotfiles="command git --git-dir=$HOME/.dotfiles --work-tree=$HOME"
    alias ws="cd ~/workspaces"
    alias an="cd ~/ansible"
    alias ubuntu="chmod +x ~/workspaces/ubuntu/init.sh && ~/workspaces/ubuntu/init.sh"
    alias alpine="chmod +x ~/workspaces/alpine/init.sh && ~/workspaces/alpine/init.sh"

    # Alias específicos de macOS
    if test (uname) = "Darwin"
        alias dotfiles-pull="$HOME/bin/dotfiles-sync"
        alias tmuxconf="command nvim $HOME/.tmux.conf"
        alias itermconf="open $HOME/.config/iterm2"
        alias surf="/Applications/Windsurf.app/Contents/MacOS/Electron"
    end

    # Alias condicional para 'dev'
    if test (uname) = "Darwin"
        alias dev="cd ~/dev"
    else # Linux
        if test -d "/mnt/c/Users/IvanL/dev" # Ruta específica de tu WSL
            alias dev="cd /mnt/c/Users/IvanL/dev"
        else
            alias dev="cd ~/dev"
        end
    end

    # Alias adicionales útiles
    alias l="command ls -la"

    # 'ls' con 'eza' (si está instalado)
    if type -q eza
        alias ls="eza --color=always --long --git --icons=always --time-style=long-iso --no-user --no-permissions"
    end
    
    # 'cat' con 'bat' (si bat está instalado)
    if type -q bat
        if test (uname) = "Darwin"
            alias cat="bat --theme=(command defaults read -globalDomain AppleInterfaceStyle &> /dev/null && echo default || echo GitHub)"
        else
            alias cat="bat --theme='GitHub'"
        end
    end

    # 'cd' con 'z' (zoxide) (si está instalado)
    if type -q z
        alias cd="z"
    end

    # Git aliases
    if type -q git
        alias g="git"
        alias ga="git add"
        alias gaa="git add --all"
        alias gb="git branch"
        alias gco="git checkout"
        alias gcm="git commit -m"
        alias gca="git commit --amend"
        alias gd="git diff"
        alias gl="git log --oneline --graph --decorate --all"
        alias gp="git push"
        alias gpl="git pull"
        alias gs="git status"
    end

end # Fin de 'if status is-interactive'

# ------------------------------------------------------------
# Funciones personalizadas
# ------------------------------------------------------------

function alpine
    bash /home/ivanlynch/workspaces/alpine/init.sh
end
