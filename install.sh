#!/usr/bin/env zsh

########################################
################ CONFIG ################
########################################
# Source: https://github.com/o-y/dotfiles

# Absolute path of this script's directory (the repo root).
CONFIG_DIR="${0:A:h}"


# dependencies for Linux
dependencies_linux=(
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

################ Deploy configs ################
echo "[~] deploying configs...";

# link_config <source-relative-to-$CONFIG_DIR> <destination>
# Creates an idempotent symlink: skips if already correct, backs up any existing
# real file as <dest>.bak before linking.
function link_config() {
  local src="$CONFIG_DIR/$1"
  local dest="$2"

  if [[ ! -e "$src" ]]; then
    echo "[!] warning - source not found, skipping: $src"
    return 1
  fi

  # Already linked to the right place?
  if [[ -L "$dest" ]] && [[ "${dest:A}" == "${src:A}" ]]; then
    echo "[=] ok - already linked: $dest"
    return 0
  fi

  # Back up an existing non-symlink (real file / dir) before replacing it.
  if [[ -e "$dest" ]] && [[ ! -L "$dest" ]]; then
    echo "[~] backing up existing: $dest -> ${dest}.bak"
    mv "$dest" "${dest}.bak"
  fi

  mkdir -p "${dest:h}"
  ln -sfn "$src" "$dest"
  echo "[+] linked: $dest -> $src"
}

function deploy_configs() {
  # XDG app configs -> $HOME/.config/<app>/
  link_config "global/kitty/kitty.conf"        "$HOME/.config/kitty/kitty.conf"
  link_config "global/nvim"                    "$HOME/.config/nvim"
  link_config "global/fastfetch/config.jsonc"  "$HOME/.config/fastfetch/config.jsonc"
  link_config "global/pip/pip.conf"            "$HOME/.config/pip/pip.conf"

  # Home dotfiles (helper files like global-aliases / git hooks are referenced by
  # absolute path from .zshrc / .gitconfig, so they are NOT symlinked here).
  link_config "global/gdb/.gdbinit"            "$HOME/.gdbinit"
  link_config "global/git/.gitconfig"          "$HOME/.gitconfig"
  link_config "global/zsh/.zshrc"              "$HOME/.zshrc"

  # SSH (tighten permissions so ssh accepts the config)
  link_config "global/ssh/config"              "$HOME/.ssh/config"
  chmod 600 "$HOME/.ssh/config" 2> /dev/null

  # VS Code Insiders (non-standard target path, handled manually)
  link_config "global/vscode/keybindings.json" "$HOME/.config/Code - Insiders/User/keybindings.json"
}

deploy_configs

## Set Default Shell
chsh -s $(which zsh)

echo "[~] everything successfully (probably) installed and configured! :)"
echo "[?] press any key to reload zsh..."
read -r
zsh
