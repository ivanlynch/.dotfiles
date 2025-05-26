# DEBUG: Inicio de config.fish
echo "DEBUG: Cargando config.fish"
echo "DEBUG: PATH al inicio de config.fish es:"
echo $PATH | tr ':' '\n'
if type -q fzf
    echo "DEBUG: fzf encontrado en el PATH:" (type -p fzf)
else
    echo "DEBUG: fzf NO encontrado en el PATH al inicio de config.fish"
end
echo "DEBUG: Contenido de ~/.config/fish/conf.d/:"
ls -la ~/.config/fish/conf.d
if test -f ~/.config/fish/conf.d/fzf.fish
    echo "DEBUG: Contenido de ~/.config/fish/conf.d/fzf.fish:"
    cat ~/.config/fish/conf.d/fzf.fish
end
# --- FIN DEBUG ---


# ~/.config/fish/config.fish
# (Copiado por Ansible desde la máquina controladora)
# ------------------------------------------------------------
# Configuración general de entorno y PATH (siempre disponible)
# ------------------------------------------------------------
# NOTA: La configuración de PATH para $HOME/.local/bin ahora se maneja
# a través de un archivo en ~/.config/fish/conf.d/ para asegurar
# que se cargue temprano y correctamente.

# Java (Ejemplo, ajusta según tu método de instalación: asdf, sdkman, manual)
if test (uname) = "Darwin"
    if test -d /opt/homebrew/opt/openjdk@11/bin
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
        # pyenv init --path | source # Para solo el path
        pyenv init - | source   # Para shims y autocompletado
    end
end

# asdf (Gestor de versiones, si lo usas)
if test -f "$HOME/.asdf/asdf.fish"
    source "$HOME/.asdf/asdf.fish"
end

# Puppeteer (ejemplo, si lo usas)
if type -q chromium
    set -q PUPPETEER_EXECUTABLE_PATH; or set -gx PUPPETEER_EXECUTABLE_PATH (command -v chromium)
else if type -q chromium-browser
    set -q PUPPETEER_EXECUTABLE_PATH; or set -gx PUPPETEER_EXECUTABLE_PATH (command -v chromium-browser)
end
set -q PUPPETEER_SKIP_CHROMIUM_DOWNLOAD; or set -gx PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true

# Homebrew PATH (si aplica)
if test (uname) = "Darwin"
    if test -d /opt/homebrew # macOS ARM
        fish_add_path -mP /opt/homebrew/bin /opt/homebrew/sbin
    else if test -d /usr/local/Homebrew # macOS Intel (ruta más antigua)
         fish_add_path -mP /usr/local/Homebrew/bin /usr/local/Homebrew/sbin
    else if test -d /usr/local/bin # macOS Intel (ruta común)
         fish_add_path -mP /usr/local/bin /usr/local/sbin
    end
else if test -d /home/linuxbrew/.linuxbrew # Linuxbrew
    fish_add_path -mP /home/linuxbrew/.linuxbrew/bin /home/linuxbrew/.linuxbrew/sbin
end

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
    alias edit="command nvim ~/.config/fish/config.fish" # Usar 'command nvim' para evitar alias de nvim
    alias config="cd ~/.config/nvim && command nvim ."
    alias dotfiles="command git --git-dir=$HOME/.dotfiles --work-tree=$HOME"
    alias ws="cd ~/workspaces"
    alias an="cd ~/ansible"

    # Alias específicos de macOS
    if test (uname) = "Darwin"
        alias dotfiles-pull="$HOME/bin/dotfiles-sync"
        alias tmuxconf="command nvim $HOME/.tmux.conf"
        alias itermconf="open $HOME/.config/iterm2"
        alias surf="/Applications/Windsurf.app/Contents/MacOS/Electron"
        alias ubuntu="chmod +x ~/workspaces/ubuntu/init.sh && ~/workspaces/ubuntu/init.sh"
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
    alias l="command ls -la" # Usar 'command ls' para el ls del sistema si 'ls' está aliasado a eza

    # 'ls' con 'eza' (si está instalado)
    if type -q eza
        alias ls="eza --color=always --long --git --icons=always --time-style=long-iso --no-user --no-permissions"
    end
    
    # 'cat' con 'bat' (si bat está instalado)
    if type -q bat
        if test (uname) = "Darwin" # Para macOS, intenta detectar tema claro/oscuro
            alias cat="bat --theme=(command defaults read -globalDomain AppleInterfaceStyle &> /dev/null && echo default || echo GitHub)"
        else # Para Linux (contenedor Docker) u otros, usa un tema fijo
            alias cat="bat --theme='GitHub'" # Puedes cambiar 'GitHub' por tu tema preferido
        end
    end

    # 'cd' con 'z' (zoxide) (si está instalado)
    if type -q z
        alias cd="z"
    end

end # Fin de 'if status is-interactive'
