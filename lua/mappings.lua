require "nvchad.mappings"

local map = vim.keymap.set

local source_search_exclusions = {
  ".git",
  ".venv",
  "target",
  "build",
  "dist",
  "node_modules",
  ".terraform",
  ".next",
  ".direnv",
  "coverage",
}

local function source_search_args(args)
  for _, dir in ipairs(source_search_exclusions) do
    vim.list_extend(args, { "--glob", "!**/" .. dir .. "/**" })
  end
  return args
end

map("n", ";", ":", { desc = "Enter command mode" })
map("i", "jk", "<Esc>", { desc = "Exit insert mode" })

map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })
map("n", "<leader>q", "<cmd>close<cr>", { desc = "Close window" })

map("n", "-", "<cmd>Oil<cr>", { desc = "Open parent directory" })

map("n", "<leader>st", "<cmd>TodoTelescope<cr>", { desc = "Search TODOs" })

map("n", "<leader>fF", function()
  require("telescope.builtin").find_files {
    find_command = source_search_args {
      "rg",
      "--files",
      "--hidden",
      "--no-ignore",
    },
  }
end, { desc = "Find all source files (including ignored)" })
map("n", "<leader>fW", function()
  require("telescope.builtin").live_grep {
    additional_args = source_search_args {
      "--hidden",
      "--no-ignore",
    },
  }
end, { desc = "Grep all source files (including ignored)" })

-- Toggle the function at the cursor. The native zc/zo/za mappings continue to
-- work too; this mnemonic mapping makes the feature easier to discover.
map("n", "<leader>zf", "za", { desc = "Toggle function fold" })

-- Toggle all function folds. Inspect the actual folds instead of keeping a
-- separate state, so manual zc/zo/za operations cannot desynchronise it.
map("n", "<leader>zz", function()
  local has_closed_fold = false
  for lnum = 1, vim.api.nvim_buf_line_count(0) do
    if vim.fn.foldclosed(lnum) ~= -1 then
      has_closed_fold = true
      break
    end
  end

  if has_closed_fold then
    vim.cmd "normal! zR"
  else
    vim.cmd "normal! zM"
  end
end, { desc = "Toggle all function folds" })

map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Trouble diagnostics" })
map("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "Trouble buffer diagnostics" })
map("n", "<leader>dl", vim.diagnostic.open_float, { desc = "Diagnostic details" })

map("n", "<leader>uh", function()
  local bufnr = vim.api.nvim_get_current_buf()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = bufnr }, { bufnr = bufnr })
end, { desc = "Toggle inlay hints" })

map("n", "<leader>gd", "<cmd>DiffviewOpen<cr>", { desc = "Diffview open" })
map("n", "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", { desc = "Diffview file history" })

local local_workflows_path = vim.fs.joinpath(vim.fn.stdpath "config", "lua/local/workflows.lua")
if vim.uv.fs_stat(local_workflows_path) then
  require("local.workflows").setup()
end
