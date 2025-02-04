# 📂 configs

> This repository contains my personal configuration files, organized for easy management and deployment across multiple systems.  

![Demo](https://raw.githubusercontent.com/dbremont/dbremont/main/docs/demostracion.png)

`fzf`, `tldr` pages, `ctlr + r`, `j` (autojump)

## 📌 Structure  

> Our configuration system is structured to maintain flexibility and consistency across different environments. We categorize configurations into two main types:

- **global/** – Shared configurations applicable across all environments.
- **local/** – Machine-specific settings tailored to individual workstations.
- **bin/** – Custom scripts and executable utilities to enhance workflow.

## ⚙️ Usage  

> Leverage **GNU Stow** or manual symlinking to apply configurations efficiently.  

```bash
stow global  # Apply global configs
stow local   # Apply local workstation-specific configs
stow bin     # Apply custom scripts
```

## Feature Work

- Third-party tools to "handle" config file installation like (GNU Stow, ..).

## References

- [jonhoo/configs](https://github.com/jonhoo/configs)
- [JJGO/dotfiles](https://github.com/JJGO/dotfiles)
- [anishathalye/dotfiles](https://github.com/anishathalye/dotfiles)
- [Dotfiles](https://gitlab.com/dwt1/dotfiles)
