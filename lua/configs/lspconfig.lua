local nvchad_lsp = require "nvchad.configs.lspconfig"

-- Neovim's recursive LSP file watcher exhausts macOS's default file limit in
-- workspaces containing Rust target/ trees or Python virtual environments.
-- Keep NvChad's completion capabilities, but disable only file watching.
if nvchad_lsp.capabilities.workspace and nvchad_lsp.capabilities.workspace.didChangeWatchedFiles then
  -- `false` is intentional: NvChad merges capabilities into Neovim's defaults,
  -- where assigning nil would leave the built-in Darwin watcher enabled.
  nvchad_lsp.capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = false
end
nvchad_lsp.defaults()

local servers = { "html", "cssls", "zls", "gopls", "pyright", "ruff", "bashls", "rust_analyzer" }
-- Web languages (ts_ls also works on plain JavaScript), JSON and HTML emmet.
vim.list_extend(servers, { "ts_ls", "jsonls", "emmet_language_server" })
-- Data/config formats: YAML (yamlls) + TOML (taplo).
vim.list_extend(servers, { "yamlls", "taplo" })
-- DevOps / Cloud Engineering: Dockerfile, Compose, Terraform/HCL, Helm,
-- Ansible. Kubernetes/Compose/GitHub-Actions YAML get schema validation from
-- yamlls (SchemaStore), so no extra server needed for those.
vim.list_extend(servers, {
  "dockerls",
  "docker_compose_language_service",
  "terraformls",
  "helm_ls",
  "ansiblels",
})
-- Godot:
--   gdscript -> connects to the RUNNING Godot editor's built-in LSP on
--   127.0.0.1:6005 (Godot itself is the server; nothing to install via mason,
--   the editor must be open). Override the port with $GDScript_Port.
--   lemminx -> XML LSP, its default filetypes include `svg` (Godot icon art).
vim.list_extend(servers, { "gdscript", "lemminx" })
-- astro LS bundles prettier-plugin-astro, so it also formats .astro on save
-- (conform lsp_format = "fallback" picks it up; no npm plugin to install).
vim.list_extend(servers, { "astro" })
-- Systems / low-level: C/C++ (clangd handles both; also covers .h/.S files).
vim.list_extend(servers, { "clangd" })
-- Flash (`fsh`) uses the locally installed standalone stdio server. It does
-- not need workspace settings and intentionally does not execute source code.
vim.list_extend(servers, { "flash" })

vim.lsp.config("flash", {
  cmd = { "flash-language-server" },
  filetypes = { "flash" },
  root_markers = { ".git" },
})

-- astro-ls requires a TypeScript SDK (else: "`typescript.tsdk` init option is
-- required"). This project ships no local `typescript` (the Cloudflare static
-- build doesn't need it), so point astro-ls at the copy mason bundles inside
-- the astro-language-server package — works regardless of project deps.
local mason_tsdk =
  vim.fs.joinpath(vim.fn.stdpath "data", "mason/packages/astro-language-server/node_modules/typescript/lib")
local local_tsdk = vim.fs.find("node_modules/typescript/lib", { upward = true, type = "directory" })[1]
local astro_tsdk = local_tsdk or (vim.fn.isdirectory(mason_tsdk) == 1 and mason_tsdk or nil)

vim.lsp.config("astro", {
  init_options = {
    typescript = {
      tsdk = astro_tsdk,
    },
  },
})

-- bash-language-server parses Bash and POSIX shell, but not Zsh. Attaching it
-- to *.zsh produced persistent false syntax errors; Treesitter still provides
-- Zsh highlighting via the Bash parser in autocmds.lua.
vim.lsp.config("bashls", {
  filetypes = { "sh", "bash" },
  settings = {
    bashIde = {
      globPattern = "*@(.sh|.inc|.bash|.command)",
    },
  },
})

-- Use the workspace's rustup toolchain and run Clippy through rust-analyzer.
-- Mason prepends its bin directory to $PATH, so resolve rust-analyzer next to
-- the rustup executable explicitly. The proxy then honors rust-toolchain files.
local rustup = vim.fn.exepath "rustup"
local rust_analyzer = rustup ~= "" and vim.fs.joinpath(vim.fs.dirname(rustup), "rust-analyzer") or "rust-analyzer"

vim.lsp.config("rust_analyzer", {
  cmd = { rust_analyzer },
  settings = {
    ["rust-analyzer"] = {
      check = {
        command = "clippy",
      },
    },
  },
})

-- Pyright owns Python navigation, completion and hover. Ruff adds the lint
-- diagnostics configured by the project's pyproject.toml without duplicating hover.
vim.lsp.config("ruff", {
  on_attach = function(client)
    client.server_capabilities.hoverProvider = false
  end,
})

vim.lsp.enable(servers)

-- read :h vim.lsp.config for changing options of lsp servers
