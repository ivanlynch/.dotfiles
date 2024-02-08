# ZSH Config
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

#aliases for configs
alias reload="source ~/.zshrc"
alias edit="nvim ~/.zshrc"
alias config="cd ~/.config/nvim && nvim ."
alias df="git --git-dir=$HOME/.dotfiles --work-tree=$HOME"
alias tc="nvim /Users/ivanlynch/.config/alacritty/alacritty.yml"
alias ws="cd ~/workspaces"
alias an="cd ~/ansible"
alias clean-env="chmod +x ~/workspaces/clean/init.sh && ~/workspaces/clean/init.sh"

# Load current dev folder based on the SO
if [[ $(uname) == "Darwin" ]]; then
    alias dev="cd ~/dev" 
elif [[ $(uname) == "Linux" ]]; then
    alias dev="cd /mnt/c/Users/IvanL/dev" 
fi

# Java Setup
export PATH="/opt/homebrew/opt/openjdk@11/bin:$PATH"

# Android Setup
export ANDROID_HOME=$HOME/Library/Android/sdk
export ANDROID_SDK_ROOT=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

# Created by `pipx` on 2023-10-25 20:47:59
export PATH="$PATH:/Users/ivanlynch/.local/bin"

# Pyenv Config
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
export PATH="/opt/homebrew/opt/curl/bin:$PATH"

#Asdf setup
. "$HOME/.asdf/asdf.sh"
export PATH="/opt/homebrew/opt/openjdk@11/bin:$PATH"

#Puppeter
export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
export PUPPETEER_EXECUTABLE_PATH=`which chromium`

source /Users/ivanlynch/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
