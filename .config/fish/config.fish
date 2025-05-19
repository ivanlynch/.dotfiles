# Interactive-only configuration
if status is-interactive
    # Initialize starship prompt
    if type -q starship
        starship init fish | source
    end
    
    # Initialize zoxide (better cd command) properly
    if type -q zoxide
        # This is the correct way to initialize zoxide
        # We use eval here to ensure proper initialization
        status is-interactive; and eval (zoxide init fish)
    end
    
    # Configure common aliases
    alias reload="source ~/.config/fish/config.fish"
    alias edit="vim ~/.config/fish/config.fish"
    alias cat="bat --theme=(defaults read -globalDomain AppleInterfaceStyle &> /dev/null && echo default || echo Github)"
    alias l="ls -la"
    alias ls="eza --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions"
    
    # Only set the cd alias if the z command is available
    if type -q z
        alias cd="z"
    end
    
    alias surf="/Applications/Windsurf.app/Contents/MacOS/Electron"
end

# Homebrew configuration
if test -d /home/linuxbrew/.linuxbrew # Linux
    set -gx HOMEBREW_PREFIX "/home/linuxbrew/.linuxbrew"
else if test -d /opt/homebrew # MacOS
    set -gx HOMEBREW_PREFIX "/opt/homebrew"
end

# Set derived Homebrew paths
if test -n "$HOMEBREW_PREFIX"
    set -gx HOMEBREW_CELLAR "$HOMEBREW_PREFIX/Cellar"
    set -gx HOMEBREW_REPOSITORY "$HOMEBREW_PREFIX/Homebrew"
    
    # Add Homebrew paths
    fish_add_path -gP "$HOMEBREW_PREFIX/bin" "$HOMEBREW_PREFIX/sbin"
    
    # Set man and info paths if they don't exist
    set -q MANPATH; or set -gx MANPATH "$HOMEBREW_PREFIX/share/man" $MANPATH
    set -q INFOPATH; or set -gx INFOPATH "$HOMEBREW_PREFIX/share/info" $INFOPATH
end

# ASDF configuration
if test -d "$HOME/.asdf"
    # Add ASDF shims to path
    set -gx PATH "$HOME/.asdf/shims" $PATH
    
    # Generate ASDF completions
    if type -q asdf
        asdf completion fish > ~/.config/fish/completions/asdf.fish
    end
end

# Add Windsurf to path
fish_add_path -gP /Applications/Windsurf.app/Contents/MacOS