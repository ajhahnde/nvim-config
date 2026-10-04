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
  "opaal",
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

local opaal_language_server = vim.fn.exepath "opaal-language-server"
if opaal_language_server == "" and vim.env.HOME then
  local development_server = vim.fs.joinpath(vim.env.HOME, "opaal", "target", "debug", "opaal-language-server")
  if vim.fn.executable(development_server) == 1 then
    opaal_language_server = development_server
  end
end

vim.lsp.config("opaal", {
  cmd = { opaal_language_server ~= "" and opaal_language_server or "opaal-language-server" },
  filetypes = { "opaal" },
  root_markers = { "opaal.toml", ".git" },
  before_init = function(params, config)
    if not config.root_dir then
      return
    end

    local manifest = vim.fs.joinpath(config.root_dir, "opaal.toml")
    local stat = vim.uv.fs_lstat(manifest)
    if stat and stat.type == "file" then
      params.initializationOptions = {
        opaal = { projectManifest = vim.uri_from_fname(manifest) },
      }
    end
  end,
})

local mason_tsdk =
  vim.fs.joinpath(vim.fn.stdpath "data", "mason/packages/astro-language-server/node_modules/typescript/lib")

vim.lsp.config("astro", {
  before_init = function(_, config)
    local tsdk = config.root_dir and require("lspconfig.util").get_typescript_server_path(config.root_dir) or ""
    if tsdk == "" and vim.fn.isdirectory(mason_tsdk) == 1 then
      tsdk = mason_tsdk
    end

    config.init_options = config.init_options or {}
    config.init_options.typescript = config.init_options.typescript or {}
    config.init_options.typescript.tsdk = tsdk ~= "" and tsdk or nil
  end,
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
