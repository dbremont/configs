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
cd ~ && git clone https://github.com/dbremont/configs
./configs/install.sh   # 🛠️ Installs dependencies + symlinks all configs
```  

The installer is idempotent: it skips already-linked configs and backs up any
existing real files as `*.bak` before symlinking. VS Code Insiders keybindings
and `~/.ssh/config` permissions are handled automatically.

## ⚙️ Usage  

> Running `./configs/install.sh` symlinks every config into place. The script is
> idempotent, so re-running it after a `git pull` will update links safely.

```bash
cd ~ && git clone https://github.com/dbremont/configs
./configs/install.sh
```

## Notes

- It is assumed that the **configuration** path is `$HOME/configs`. Refer to the **Git configuration** file for the explicit path reference.

## TODO

- [ ] We need a hook manager.

## References

- [jonhoo/configs](https://github.com/jonhoo/configs)
- [JJGO/dotfiles](https://github.com/JJGO/dotfiles)
- [anishathalye/dotfiles](https://github.com/anishathalye/dotfiles)
- [Dotfiles](https://gitlab.com/dwt1/dotfiles)
- [o-y dotfiles](https://github.com/o-y/dotfiles/tree/main)
