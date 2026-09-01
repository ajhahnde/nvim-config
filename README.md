# Neovim configuration

An NvChad-based setup focused on fast navigation, broad language support, and
predictable project tooling.

## Interface

- Transparent OneDark theme with a responsive statusline
- Centered, content-sized file explorer and an editable Oil directory view
- Telescope pickers, structured notifications, and command-line popups
- Function-only Tree-sitter folds with buffer-local fold controls
- Project sessions scoped by working directory and Git branch
- Kitty graphics rendering for PNG, JPEG, GIF, WebP, and AVIF in Ghostty
- Inline and browser-based Markdown rendering

## Editing

- Format-on-save with Conform and language-specific formatter selection
- Asynchronous linting for shell, Docker, Terraform, Ansible, and GDScript
- Completion from LSP, snippets, buffers, paths, and inline suggestions
- Surround operations, automatic tag pairing, and project-wide replacement
- Function-aware jumping, diagnostics views, inlay hints, and TODO search
- Prose-friendly wrapping and spell checking for Markdown, text, and commits

## Language support

- Web: JavaScript, TypeScript, TSX, Astro, HTML, CSS, JSON, Emmet
- Systems: C, C++, Rust, Zig, Go, assembly, Make
- Scripting: Python, Bash, Lua
- Infrastructure: Docker, Compose, Terraform, HCL, Helm, Ansible, YAML, TOML
- Godot: GDScript, scenes, resources, shaders, XML, and SVG
- Dedicated `.fsh` detection, syntax, indentation, completion, diagnostics,
  and formatting

## Git workflow

- Inline hunk navigation, preview, staging, reset, and blame
- Repository status and commands through Fugitive
- File and repository history through Diffview

## Tool management

- Reproducible plugin revisions through `lazy-lock.json`
- Daily update checks without automatic lockfile changes
- Automatic installation of missing Tree-sitter parsers and Mason tools
- Explicit upgrades through `:Lazy update` and `:MasonToolsUpdate`

Machine-local integrations live under `lua/local/` and remain outside version
control.
