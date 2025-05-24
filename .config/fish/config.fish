# ~/.config/fish/config.fish
# ------------------------------------------------------------
# Configuración general de entorno y PATH (siempre disponible)
# ------------------------------------------------------------

# Java
fish_add_path /opt/homebrew/opt/openjdk@11/bin

# Android
set -gx ANDROID_HOME $HOME/Library/Android/sdk
set -gx ANDROID_SDK_ROOT $HOME/Library/Android/sdk
fish_add_path $ANDROID_HOME/emulator
fish_add_path $ANDROID_HOME/tools
fish_add_path $ANDROID_HOME/tools/bin
fish_add_path $ANDROID_HOME/platform-tools

# pipx
fish_add_path $HOME/.local/bin

# pyenv
set -gx PYENV_ROOT $HOME/.pyenv
fish_add_path $PYENV_ROOT/bin
if type -q pyenv
    pyenv init - | source
end

# curl (Homebrew)
fish_add_path /opt/homebrew/opt/curl/bin

# asdf
if test -d "$HOME/.asdf"
    set -gx PATH "$HOME/.asdf/shims" $PATH
    if type -q asdf
        asdf completion fish > ~/.config/fish/completions/asdf.fish
    end
    if test -f "$HOME/.asdf/asdf.fish"
        source "$HOME/.asdf/asdf.fish"
    end
end

# Puppeteer (solución multiplataforma)
if type -q chromium
    set -gx PUPPETEER_EXECUTABLE_PATH (command -v chromium)
else if type -q chromium-browser
    set -gx PUPPETEER_EXECUTABLE_PATH (command -v chromium-browser)
end
set -gx PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true

# Homebrew (soporte multiplataforma)
if test -d /home/linuxbrew/.linuxbrew
    set -gx HOMEBREW_PREFIX "/home/linuxbrew/.linuxbrew"
else if test -d /opt/homebrew
    set -gx HOMEBREW_PREFIX "/opt/homebrew"
end
if test -n "$HOMEBREW_PREFIX"
    set -gx HOMEBREW_CELLAR "$HOMEBREW_PREFIX/Cellar"
    set -gx HOMEBREW_REPOSITORY "$HOMEBREW_PREFIX/Homebrew"
    fish_add_path -gP "$HOMEBREW_PREFIX/bin" "$HOMEBREW_PREFIX/sbin"
    set -q MANPATH; or set -gx MANPATH "$HOMEBREW_PREFIX/share/man" $MANPATH
    set -q INFOPATH; or set -gx INFOPATH "$HOMEBREW_PREFIX/share/info" $INFOPATH
end

# Windsurf
fish_add_path -gP /Applications/Windsurf.app/Contents/MacOS

# ------------------------------------------------------------
# Configuración interactiva (solo para sesiones interactivas)
# ------------------------------------------------------------
if status is-interactive

    # Prompt moderno
    if type -q starship
        starship init fish | source
    end

    # zoxide (cd mejorado)
    if type -q zoxide
        status is-interactive; and eval (zoxide init fish)
    end

    # Aliases generales
    alias reload="source ~/.config/fish/config.fish"
    alias edit="nvim ~/.config/fish/config.fish"
    alias config="cd ~/.config/nvim; nvim ."
    alias dotfiles="git --git-dir=$HOME/.dotfiles --work-tree=$HOME"
    alias dotfiles-pull="$HOME/bin/dotfiles-sync"
    alias tmuxconf="nvim $HOME/.tmux.conf"
    alias itermconf="open $HOME/.config/iterm2"
    alias ws="cd ~/workspaces"
    alias an="cd ~/ansible"
    alias clean-env="chmod +x ~/workspaces/clean/init.sh; ~/workspaces/clean/init.sh"
    alias surf="/Applications/Windsurf.app/Contents/MacOS/Electron"

    # Alias condicional para 'dev' según SO
    switch (uname)
        case Darwin
            alias dev="cd ~/dev"
        case Linux
            # Soporte para WSL y Linux nativo
            if test -d "/mnt/c/Users/IvanL/dev"
                alias dev="cd /mnt/c/Users/IvanL/dev"
            else
                alias dev="cd ~/dev"
            end
    end

    # Alias adicionales útiles
    alias l="ls -la"
    alias ls="eza --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions"
    
    # Alias condicional para cat/bat
    if type -q bat
        alias cat="bat --theme=(defaults read -globalDomain AppleInterfaceStyle &> /dev/null && echo default || echo Github)"
    end

    # Alias para 'cd' usando 'z' si está disponible
    if type -q z
        alias cd="z"
    end
end
