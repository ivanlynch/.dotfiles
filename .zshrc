# ZSH Config
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git)
source $ZSH/oh-my-zsh.sh

#aliases for configs
alias reload="source ~/.zshrc"
alias edit="nvim ~/.zshrc"
alias config="cd ~/.config/nvim && nvim ."
alias dotfiles="git --git-dir=$HOME/.dotfiles --work-tree=$HOME"
alias dev="cd /mnt/c/Users/IvanL/dev" 
