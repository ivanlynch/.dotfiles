# Configuración de Fish para contenedor Ubuntu
# ------------------------------------------------------------

# Configuración general de entorno y PATH
fish_add_path /usr/local/bin
fish_add_path $HOME/.local/bin

# pyenv
set -gx PYENV_ROOT $HOME/.pyenv
fish_add_path $PYENV_ROOT/bin
if type -q pyenv
    pyenv init - | source
end

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

# Configuración interactiva
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
    alias ws="cd ~/workspaces"
    alias an="cd ~/ansible"

    # Alias adicionales útiles
    alias l="ls -la"
    alias ls="eza --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions"
    
    # Alias condicional para cat/bat
    if type -q bat
        alias cat="bat --theme=default"
    end

    # Alias para 'cd' usando 'z' si está disponible
    if type -q z
        alias cd="z"
    end
end 