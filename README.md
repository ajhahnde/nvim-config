# Neovim configuration

Personal Neovim configuration based on [NvChad](https://nvchad.com/) and
[lazy.nvim](https://github.com/folke/lazy.nvim).

## Installation

Back up an existing configuration, then clone this repository:

```sh
git clone https://github.com/ajhahnde/nvim-config.git ~/.config/nvim
nvim
```

Neovim installs the configured plugins on first launch. External language
servers, formatters, and linters are managed through Mason where configured.

`lazy-lock.json` is committed intentionally so plugin versions stay
reproducible across machines.

## Local configuration

Project-specific commands, paths, filetypes, and dashboard shortcuts are kept
in ignored files. The public configuration loads these additions only when they
exist, so a fresh clone works without them.
