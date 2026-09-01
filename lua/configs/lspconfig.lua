local nvchad_lsp = require "nvchad.configs.lspconfig"

if nvchad_lsp.capabilities.workspace and nvchad_lsp.capabilities.workspace.didChangeWatchedFiles then
  nvchad_lsp.capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = false
end
nvchad_lsp.defaults()

local servers = {
  "ansiblels",
  "astro",
  "bashls",
  "clangd",
  "cssls",
  "dockerls",
  "docker_compose_language_service",
  "emmet_language_server",
  "flash",
  "gdscript",
  "gopls",
  "helm_ls",
  "html",
  "jsonls",
  "lemminx",
  "pyright",
  "ruff",
  "rust_analyzer",
  "taplo",
  "terraformls",
  "ts_ls",
  "yamlls",
  "zls",
}

vim.lsp.config("flash", {
  cmd = { "flash-language-server" },
  filetypes = { "flash" },
  root_markers = { ".git" },
})

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

vim.lsp.config("bashls", {
  filetypes = { "sh", "bash" },
  settings = {
    bashIde = {
      globPattern = "*@(.sh|.inc|.bash|.command)",
    },
  },
})

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

vim.lsp.config("ruff", {
  on_attach = function(client)
    client.server_capabilities.hoverProvider = false
  end,
})

vim.lsp.enable(servers)
