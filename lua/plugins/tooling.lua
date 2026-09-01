local treesitter_parsers = {
  "asm",
  "astro",
  "bash",
  "c",
  "cpp",
  "css",
  "dockerfile",
  "gdscript",
  "gdshader",
  "go",
  "godot_resource",
  "gomod",
  "hcl",
  "html",
  "javascript",
  "jsdoc",
  "json",
  "make",
  "markdown",
  "markdown_inline",
  "python",
  "rust",
  "toml",
  "tsx",
  "typescript",
  "xml",
  "yaml",
  "zig",
}

local mason_tools = {
  "ansible-language-server",
  "ansible-lint",
  "astro-language-server",
  "bash-language-server",
  "clang-format",
  "clangd",
  "css-lsp",
  "docker-compose-language-service",
  "dockerfile-language-server",
  "emmet-language-server",
  "gdtoolkit",
  "goimports",
  "gopls",
  "hadolint",
  "helm-ls",
  "html-lsp",
  "json-lsp",
  "lemminx",
  "lua-language-server",
  "prettier",
  "pyright",
  "ruff",
  "shellcheck",
  "shfmt",
  "stylua",
  "taplo",
  "terraform-ls",
  "tflint",
  "typescript-language-server",
  "yaml-language-server",
  "zls",
}

local function setup_treesitter(_, opts)
  local parsers = opts.ensure_installed or {}
  opts.ensure_installed = nil

  local treesitter = require "nvim-treesitter"
  treesitter.setup(opts)

  local function install()
    treesitter.install(parsers)
  end

  if #vim.api.nvim_list_uis() > 0 then
    install()
    return
  end

  local group = vim.api.nvim_create_augroup("UserTreesitterInstall", { clear = true })
  vim.api.nvim_create_autocmd("UIEnter", { group = group, once = true, callback = install })
end

local function setup_lint()
  local lint = require "lint"
  lint.linters_by_ft = {
    bash = { "shellcheck" },
    dockerfile = { "hadolint" },
    gdscript = { "gdlint" },
    sh = { "shellcheck" },
    terraform = { "tflint" },
    tf = { "tflint" },
    ["yaml.ansible"] = { "ansible_lint" },
  }

  local group = vim.api.nvim_create_augroup("UserLint", { clear = true })
  vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
    group = group,
    callback = function(args)
      local filetype = vim.bo[args.buf].filetype
      if not lint.linters_by_ft[filetype] or not vim.api.nvim_buf_is_loaded(args.buf) then
        return
      end

      vim.api.nvim_buf_call(args.buf, lint.try_lint)
    end,
  })
end

return {
  {
    "neovim/nvim-lspconfig",
    event = "User FilePost",
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    opts = { ensure_installed = treesitter_parsers },
    config = setup_treesitter,
  },

  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "BufReadPost",
    opts = { max_lines = 3 },
  },

  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    opts = {},
  },

  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    event = "VeryLazy",
    opts = {
      ensure_installed = mason_tools,
      auto_update = false,
      run_on_start = true,
      start_delay = 3000,
      debounce_hours = 24,
    },
  },

  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufWritePost" },
    config = setup_lint,
  },

  {
    "FelipeLema/cmp-async-path",
    url = "https://github.com/FelipeLema/cmp-async-path",
  },

  {
    "supermaven-inc/supermaven-nvim",
    event = "InsertEnter",
    opts = { disable_keymaps = true },
  },

  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      local cmp = require "cmp"
      opts.mapping["<Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
          return
        end

        local has_preview, preview = pcall(require, "supermaven-nvim.completion_preview")
        if has_preview and preview.has_suggestion() then
          preview.on_accept_suggestion()
        elseif require("luasnip").expand_or_jumpable() then
          require("luasnip").expand_or_jump()
        else
          fallback()
        end
      end, { "i", "s" })
      return opts
    end,
  },
}
