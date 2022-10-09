# configs
My configuration files

## Tools

- [kitty](https://sw.kovidgoyal.net/kitty/): The fast, feature-rich, GPU based terminal emulator
- [autojump](https://github.com/wting/autojump): A cd command that learns - easily navigate directories from the command line
- [tldr pages](https://tldr.sh/): Simplified and community-driven man pages
- [fzf](https://github.com/junegunn/fzf): A command-line fuzzy finder
- [zsh](https://www.zsh.org/): Zsh is a shell designed for interactive use, although it is also a powerful scripting language
- [ohmyzsh](https://ohmyz.sh/): Unleash your terminal like  never before.
  - git
  - autojump
  - colored-man-pages
  - zsh-autosuggestions
  - vi-mode
  - fzf
- [rg](https://github.com/BurntSushi/ripgrep): ripgrep recursively searches directories for a regex pattern while respecting your gitignore
- [exa](https://the.exa.website/): A modern replacement for ls
- xclip
- xbindkeys
- ZSH Themes
  - [typewritten](https://github.com/reobin/typewritten)  **Actually Usign**
  - [powerlevel10k](https://github.com/romkatv/powerlevel10k)
  - [spaceship-prompt](https://github.com/spaceship-prompt/spaceship-prompt)
- [Glances](https://nicolargo.github.io/glances/): Glances is a cross-platform system monitoring tool written in Python
  - For the web view you need **Bottle**
- neovim
- git
- ssh (client) / openssh-server (server)
- openssl
- 

## Getting Started

- ln -s $HOME/configs/shell/.config/zsh/.zshrc $HOME/.zshrc
- ln -s $HOME/configs/env/.aliases $HOME/.aliases
- ln -s $HOME/configs/env/.env $HOME/.env
- touch $HOME/.env_local

---

- ln -s $HOME/configs/shell/.config/vim/.vimrc  $HOME/.vimrc
- In vim `:PluginInstall` to install the plugings

## Demostracion

- kitty (terminal emulator), zsh (interpreter)
- `fzf`, `tldr` pages, `ctlr + r` (mcfly), `j` (autojump)

![Demostracion](https://raw.githubusercontent.com/dbremont/dbremont/main/docs/demostracion.png)

## Sources

- [jonhoo/configs](https://github.com/jonhoo/configs)
- [JJGO/dotfiles](https://github.com/JJGO/dotfiles)
- [anishathalye/dotfiles](https://github.com/anishathalye/dotfiles)
- [cirosantilli/dotfiles](https://github.com/cirosantilli/dotfiles)
- [Dotfiles](https://gitlab.com/dwt1/dotfiles)
- [Awesome ZSH Plugisn](https://github.com/unixorn/awesome-zsh-plugins)

## TBD

- Configure glances (triggers for load notification) https://glances.readthedocs.io/en/latest/config.html


[exa](https://the.exa.website/)

[doitlive](https://doitlive.readthedocs.io/en/stable/)

[explainshell](https://explainshell.com/)
