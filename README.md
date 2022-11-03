# configs
My configuration files

![Demostracion](https://raw.githubusercontent.com/dbremont/dbremont/main/docs/demostracion.png)

- kitty (terminal emulator), zsh (interpreter)
- `fzf`, `tldr` pages, `ctlr + r` (mcfly), `j` (autojump)

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
- [exa](https://the.exa.website/): A modern replacement for ls
- git
- ssh (client) / openssh-server (server)
- openssl
- xclip
- xbindkeys
- [exa](https://the.exa.website/)
- [doitlive](https://doitlive.readthedocs.io/en/stable/)
- [explainshell](https://explainshell.com/)


## Getting Started

- ln -s $HOME/configs/shell/.config/zsh/.zshrc $HOME/.zshrc
- ln -s $HOME/configs/env/.aliases $HOME/.aliases
- ln -s $HOME/configs/env/.env $HOME/.env
- touch $HOME/.env-local

### On Chaging the default logging shell

[chsh -s /bin/zsh](https://www.tecmint.com/change-a-users-default-shell-in-linux/)

### On vim Configuration

- ln -s $HOME/configs/shell/.config/vim/.vimrc  $HOME/.vimrc
- In vim `:PluginInstall` to install the plugings

## Sources

- [jonhoo/configs](https://github.com/jonhoo/configs)
- [JJGO/dotfiles](https://github.com/JJGO/dotfiles)
- [anishathalye/dotfiles](https://github.com/anishathalye/dotfiles)
- [cirosantilli/dotfiles](https://github.com/cirosantilli/dotfiles)
- [Dotfiles](https://gitlab.com/dwt1/dotfiles)
- [Awesome ZSH Plugisn](https://github.com/unixorn/awesome-zsh-plugins)
