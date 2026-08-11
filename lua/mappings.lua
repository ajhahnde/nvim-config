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

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

map("n", "<Esc>", "<CMD>nohlsearch<CR>", { desc = "Clear search highlight" })
map("n", "<leader>q", "<CMD>close<CR>", { desc = "Close window" })

-- Oil.nvim (Dateisystem wie Buffer bearbeiten)
map("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

-- Todo-comments
map("n", "<leader>st", "<CMD>TodoTelescope<CR>", { desc = "Search TODOs" })

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

-- Trouble (diagnostics list)
map("n", "<leader>xx", "<CMD>Trouble diagnostics toggle<CR>", { desc = "Trouble diagnostics" })
map("n", "<leader>xX", "<CMD>Trouble diagnostics toggle filter.buf=0<CR>", { desc = "Trouble buffer diagnostics" })

-- Diffview (git review)
map("n", "<leader>gd", "<CMD>DiffviewOpen<CR>", { desc = "Diffview open" })
map("n", "<leader>gh", "<CMD>DiffviewFileHistory %<CR>", { desc = "Diffview file history" })

local has_local_workflows, local_workflows = pcall(require, "ajhahnde.workflows")
if has_local_workflows then
  local_workflows.setup()
end
