# ~/.config/fish/config.fish
# ------------------------------------------------------------
# Configuración general de entorno y PATH (siempre disponible)
# ------------------------------------------------------------

# Java (Ajusta la ruta si es diferente en Linux o si usas asdf/sdkman)
if test (uname) = "Darwin"
    fish_add_path /opt/homebrew/opt/openjdk@11/bin
end

# Android (Ajusta las rutas si son diferentes en Linux)
if test (uname) = "Darwin"
    set -gx ANDROID_HOME $HOME/Library/Android/sdk
    set -gx ANDROID_SDK_ROOT $HOME/Library/Android/sdk
    fish_add_path $ANDROID_HOME/emulator
    fish_add_path $ANDROID_HOME/tools
    fish_add_path $ANDROID_HOME/tools/bin
    fish_add_path $ANDROID_HOME/platform-tools
else # Linux
    # Podrías definir rutas alternativas para Android SDK en Linux si lo usas allí
    # Por ejemplo:
    # set -gx ANDROID_HOME $HOME/Android/Sdk
    # fish_add_path $ANDROID_HOME/emulator ... etc.
end


# pipx (Generalmente $HOME/.local/bin está en PATH por defecto en sistemas modernos)
fish_add_path $HOME/.local/bin

# pyenv
set -gx PYENV_ROOT $HOME/.pyenv
if test -d "$PYENV_ROOT" # Solo añade a PATH e inicializa si pyenv está instalado
    fish_add_path $PYENV_ROOT/bin
    if type -q pyenv
        pyenv init - | source
    end
end

# curl (Homebrew, específico de macOS si se instaló allí)
if test (uname) = "Darwin"
    fish_add_path /opt/homebrew/opt/curl/bin
end

# asdf (Gestor de versiones)
if test -d "$HOME/.asdf"
    # Añadir shims y completions de asdf
    # La forma recomendada por asdf es sourcear su script:
    source "$HOME/.asdf/asdf.fish"
    # Las siguientes líneas son alternativas o complementarias, asdf.fish suele encargarse
    # set -gx PATH "$HOME/.asdf/shims" $PATH
    # if type -q asdf
    #     mkdir -p ~/.config/fish/completions
    #     asdf completion fish > ~/.config/fish/completions/asdf.fish
    # end
end

# Puppeteer (solución multiplataforma, asume que chromium está en PATH)
if type -q chromium
    set -gx PUPPETEER_EXECUTABLE_PATH (command -v chromium)
else if type -q chromium-browser
    set -gx PUPPETEER_EXECUTABLE_PATH (command -v chromium-browser)
end
set -gx PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true

# Homebrew (soporte multiplataforma)
if test -d /home/linuxbrew/.linuxbrew # Linuxbrew
    set -gx HOMEBREW_PREFIX "/home/linuxbrew/.linuxbrew"
else if test -d /opt/homebrew # Homebrew en macOS ARM
    set -gx HOMEBREW_PREFIX "/opt/homebrew"
else if test -d /usr/local/Homebrew # Homebrew en macOS Intel (más antiguo)
    set -gx HOMEBREW_PREFIX "/usr/local/Homebrew"
end

if test -n "$HOMEBREW_PREFIX"
    set -gx HOMEBREW_CELLAR "$HOMEBREW_PREFIX/Cellar"
    set -gx HOMEBREW_REPOSITORY "$HOMEBREW_PREFIX/Homebrew" # Ajusta si tu repo está en otro lado
    fish_add_path -gP "$HOMEBREW_PREFIX/bin" "$HOMEBREW_PREFIX/sbin"

    # Configurar MANPATH e INFOPATH si no están ya configurados para incluir Homebrew
    # Esto previene añadir duplicados o rutas incorrectas
    set -l man_path_to_add "$HOMEBREW_PREFIX/share/man"
    if not contains -- "$man_path_to_add" $MANPATH
        if test -z "$MANPATH" # Si MANPATH está vacío
            set -gx MANPATH "$man_path_to_add"
        else
            set -gx MANPATH "$man_path_to_add" $MANPATH
        end
    end

    set -l info_path_to_add "$HOMEBREW_PREFIX/share/info"
    if not contains -- "$info_path_to_add" $INFOPATH
        if test -z "$INFOPATH" # Si INFOPATH está vacío
            set -gx INFOPATH "$info_path_to_add"
        else
            set -gx INFOPATH "$info_path_to_add" $INFOPATH
        end
    end
end

# Windsurf (Solo si estás en macOS y tienes esta app)
if test (uname) = "Darwin"
    if test -d "/Applications/Windsurf.app"
        fish_add_path -gP "/Applications/Windsurf.app/Contents/MacOS"
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
    alias edit="nvim ~/.config/fish/config.fish" # Asume nvim está instalado
    alias config="cd ~/.config/nvim; nvim ."    # Asume nvim y esa ruta de config
    alias dotfiles="git --git-dir=$HOME/.dotfiles --work-tree=$HOME"
    alias ws="cd ~/workspaces" # Ajusta si tu directorio de workspaces es otro
    alias an="cd ~/ansible"   # Ajusta si tu directorio de ansible es otro

    # Alias específicos de macOS (no fallarán en Linux, simplemente no harán nada útil)
    if test (uname) = "Darwin"
        alias dotfiles-pull="$HOME/bin/dotfiles-sync" # Asume que este script existe en macOS
        alias tmuxconf="nvim $HOME/.tmux.conf"       # Asume tmux.conf en esa ruta
        alias itermconf="open $HOME/.config/iterm2"  # 'open' es de macOS
        alias surf="/Applications/Windsurf.app/Contents/MacOS/Electron" # App de macOS
        alias ubuntu="chmod +x ~/workspaces/ubuntu/init.sh; ~/workspaces/ubuntu/init.sh" # Script específico de tu setup
    end

    # Alias condicional para 'dev' según SO
    switch (uname)
        case Darwin
            alias dev="cd ~/dev" # Ajusta si tu dir dev es otro
        case Linux
            # Soporte para WSL y Linux nativo
            if test -d "/mnt/c/Users/IvanL/dev" # Ruta muy específica de TU config WSL
                alias dev="cd /mnt/c/Users/IvanL/dev"
            else
                alias dev="cd ~/dev" # Ajusta si tu dir dev es otro en Linux
            end
    end

    # Alias adicionales útiles
    alias l="ls -la" # Clásico alias

    # 'ls' con 'eza' (si está instalado)
    if type -q eza
        alias ls="eza --color=always --long --git --icons=always --time-style=long-iso --no-user --no-permissions"
        # He ajustado algunos flags de eza para una salida común, puedes personalizarlos.
        # --no-filesize quitado, --time-style añadido, --no-time quitado.
    end
    
    # 'cat' con 'bat' (si está instalado)
    if type -q bat
        if test (uname) = "Darwin" # Para macOS, intenta detectar tema claro/oscuro
            alias cat="bat --theme=(defaults read -globalDomain AppleInterfaceStyle &> /dev/null && echo default || echo GitHub)"
        else # Para Linux (contenedor) u otros, usa un tema fijo
            alias cat="
