# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# vars
export GLOBAL_CONFIG_PATH=$HOME/configs

# Functions
source $GLOBAL_CONFIG_PATH/bin/functions

# General Environment
source $GLOBAL_CONFIG_PATH/global/tools/global-env
source $GLOBAL_CONFIG_PATH/global/tools/global-aliases

# Local Environment
source $GLOBAL_CONFIG_PATH/local/local-env
# Added by LM Studio CLI (lms)
export PATH="$PATH:/home/dvictoriano/.lmstudio/bin"
# End of LM Studio CLI section

