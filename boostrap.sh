#!/usr/bin/env zsh

########################################
################ CONFIG ################
########################################
# Source: https://github.com/o-y/dotfiles


# dependencies for Linux
dependencies_linux=(
  "stow" "sudo apt install stow"
  "jot" "sudo apt install athena-jot"
  "fzf" "sudo apt install fzf"
  "rg" "sudo apt install ripgrep"
  "hyperfine" "sudo apt install hyperfine"
  "btop" "sudo apt install btop"
  ## "pipx" "sudo apt install pipx"
  "c++" "sudo apt install build-essential"
  "zoxide" "sudo apt install zoxide"
)

dependencies_common=(
  ## -- dependencies on pipx --
  ## "fuck:pipx" "pipx install --fetch-missing-python --python "3.11" thefuck" # https://github.com/nvbn/thefuck/issues/1444
)

## ZSH Plugins
# git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
# git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

################ Install dependencies ################
echo "[~] installing required dependencies...";

function install_dependencies_internal() {
  local dependencies=( "$@" )
  for (( i=1; i<${#dependencies[@]}; i+=2 )); do
    local dependency="${dependencies[$i]}"
    local installer="${dependencies[$i+1]}"

    # state validation: check for multiple colons or spaces
    if [[ "$dependency" == *:*:* || "$dependency" == *" "* ]]; then
      echo "[!] critical - invalid dependency format: '$dependency'. Cannot contain multiple colons or spaces."
      exit 64
    fi

    # check for colon and dependency
    local required_dependency="" # set if there exists a dependent on the right side of the colon
    if [[ "$dependency" == *:* ]]; then
      required_dependency="${dependency##*:}"
      if ! command -v "$required_dependency" &> /dev/null; then
        echo "[!] critical - skipping '$dependency' installation. required dependent '$required_dependency' not found!"
        continue
      fi
      
      dependency="${dependency%:*}"
    fi

    if ! command -v "$dependency" &> /dev/null; then
      if [[ -n "$required_dependency" ]]; then
        echo "[!] installer - installing dependency: ${dependency} (using: $required_dependency)...";
      else
        echo "[!] installer - installing dependency: ${dependency}...";
      fi
      eval "$installer"
    fi
  done
}

function install_dependencies() {
    install_dependencies_internal "${dependencies_linux[@]}"
    install_dependencies_internal "${dependencies_common[@]}"
}

install_dependencies

## Set Default Shell
chsh -s $(which zsh)

echo "[~] everything successfully (probably) installed and configured! :)"
echo "[?] press any key to reload zsh..."
read -r
zsh