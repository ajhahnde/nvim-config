return {
  {
    "lewis6991/gitsigns.nvim",
    opts = function(_, opts)
      opts.on_attach = function(bufnr)
        local gitsigns = require "gitsigns"

        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end

        map("n", "]h", function()
          if vim.wo.diff then
            vim.cmd.normal { "]c", bang = true }
          else
            gitsigns.nav_hunk "next"
          end
        end, "Next git hunk")
        map("n", "[h", function()
          if vim.wo.diff then
            vim.cmd.normal { "[c", bang = true }
          else
            gitsigns.nav_hunk "prev"
          end
        end, "Previous git hunk")

        map("n", "<leader>hs", gitsigns.stage_hunk, "Stage hunk")
        map("n", "<leader>hr", gitsigns.reset_hunk, "Reset hunk")
        map("x", "<leader>hs", function()
          gitsigns.stage_hunk { vim.fn.line ".", vim.fn.line "v" }
        end, "Stage selected hunk")
        map("x", "<leader>hr", function()
          gitsigns.reset_hunk { vim.fn.line ".", vim.fn.line "v" }
        end, "Reset selected hunk")
        map("n", "<leader>hp", gitsigns.preview_hunk_inline, "Preview hunk inline")
        map("n", "<leader>hb", function()
          gitsigns.blame_line { full = true }
        end, "Blame line")
      end

      return opts
    end,
  },

  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    opts = {},
  },

  {
    "tpope/vim-fugitive",
    cmd = { "Git", "Gvdiffsplit", "Gdiffsplit", "Gread", "Gwrite", "Gclog" },
    keys = {
      { "<leader>gs", "<cmd>Git<cr>", desc = "Git status" },
    },
  },
}
