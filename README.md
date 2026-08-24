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
Plugins (including Tree-sitter parsers) and Mason tools are updated
automatically in the background, at most once every 24 hours.

`lazy-lock.json` is committed intentionally so plugin versions stay
reproducible across machines.

## FlashOS Flash

Files ending in `.fsh` use the `flash` filetype, built-in syntax highlighting,
four-space indentation, Flash comments, LSP diagnostics/completion/navigation,
and LSP formatting on save. The standalone `flash-language-server` executable
must be available on `PATH`. Install it from a local FlashOS checkout with:

```sh
cd components/flash
cargo install --path crates/flash-lsp --locked
```

## Local configuration

Project-specific commands, paths, and filetypes are kept in ignored files. The
public configuration loads these additions only when they exist, so a fresh
clone works without them.
