# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH

# Functions
source ~/configs/scripts/functions.sh

# General Environment
source ~/configs/.config/zsh/.env
source ~/configs/.config/zsh/.aliases

# Local Environment
source ~/configs/local/.env

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
source $ZSH/oh-my-zsh.sh