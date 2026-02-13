# 📂 configs

> This repository contains my personal configuration files, organized for easy management and deployment across multiple systems.  

![Demo](https://raw.githubusercontent.com/dbremont/dbremont/main/docs/demostracion.png)

`fzf`, `tldr` pages, `ctlr + r`, `j` (autojump)

## 📌 Structure  

> Our configuration system is structured to maintain flexibility and consistency across different environments. We categorize configurations into two main types:

- **global/** – Shared configurations applicable across all environments.
- **local/** – Machine-specific settings tailored to individual workstations.
- **bin/** – Custom scripts and executable utilities to enhance workflow.

## **🚀 Installation Guide**  

```bash
- ./bootstrap.zsh  # 🛠️ Entry point (Installer)

- rm "$HOME/.config/Code - Insiders/User/keybindings.json"
- ln -s $HOME/configs/global/config/vscode/keybindings.json "$HOME/.config/Code - Insiders/User/keybindings.json"  # VS Code Insiders.

```  

## ⚙️ Usage  

> Leverage **GNU Stow** or manual symlinking to apply configurations efficiently.  

```bash
cd ~ && git clone https://github.com/dbremont/configs
stow -Sv <group>
```

```bash
## Global
cd global

stow -v -R config  --target=$HOME/.config
stow -v -R shell   --target=$HOME
```

```bash
## Local
cd local

```

## Notes

- It is assumed that the **configuration** path is `$HOME/configs`. Refer to the **Git configuration** file for the explicit path reference.

## References

- [jonhoo/configs](https://github.com/jonhoo/configs)
- [JJGO/dotfiles](https://github.com/JJGO/dotfiles)
- [anishathalye/dotfiles](https://github.com/anishathalye/dotfiles)
- [Dotfiles](https://gitlab.com/dwt1/dotfiles)
- [o-y dotfiles](https://github.com/o-y/dotfiles/tree/main)
