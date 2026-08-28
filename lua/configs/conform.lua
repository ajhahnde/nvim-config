local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    markdown = { "prettier" },
    css = { "prettier" },
    html = { "prettier" },
    -- Web and data formats
    javascript = { "prettier" },
    javascriptreact = { "prettier" },
    json = { "prettier" },
    jsonc = { "prettier" },
    yaml = { "prettier" },
    toml = { "taplo" },
    -- Astro is left to its LSP formatter (lsp_format = "fallback").
    typescript = { "prettier" },
    typescriptreact = { "prettier" },
    -- Systems / low-level: clang-format for C/C++ and assembly-adjacent headers.
    c = { "clang_format" },
    cpp = { "clang_format" },
    sh = { "shfmt" },
    bash = { "shfmt" },
    rust = { "rustfmt" },
    zig = { "zigfmt" },
    go = { "goimports", "gofmt" },
    python = { "ruff_organize_imports", "ruff_format" },
    -- gdformat ships in gdtoolkit (installed via mason).
    gdscript = { "gdformat" },
    -- DevOps / Cloud: `terraform fmt` for .tf / .tfvars.
    terraform = { "terraform_fmt" },
    ["terraform-vars"] = { "terraform_fmt" },
  },

  format_on_save = {
    -- These options will be passed to conform.format()
    timeout_ms = 1500,
    lsp_format = "fallback",
  },
}

return options
