# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH
export GLOBAL_CONFIG_PATH=$HOME/configs

# Functions
source $GLOBAL_CONFIG_PATH/bin/functions

# General Environment
source $GLOBAL_CONFIG_PATH/global/tools/global-env
source $GLOBAL_CONFIG_PATH/global/tools/global-aliases

# Local Environment
source $GLOBAL_CONFIG_PATH/local/local-env

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
source $ZSH/oh-my-zsh.sh