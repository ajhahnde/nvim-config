local function tree_window_config()
  local columns = vim.o.columns
  local rows = vim.o.lines - vim.o.cmdheight - 1
  local width = math.floor(columns * 0.66)
  local height = math.floor(rows * 0.82)

  return {
    relative = "editor",
    border = "rounded",
    width = width,
    height = height,
    row = math.floor((rows - height) / 2),
    col = math.floor((columns - width) / 2),
    title = " Explorer ",
    title_pos = "center",
  }
end

return {
  {
    "nvim-tree/nvim-tree.lua",
    init = function()
      require("configs.treefloat").setup()
    end,
    opts = function(_, opts)
      opts.hijack_cursor = true
      opts.sync_root_with_cwd = true
      opts.view = vim.tbl_deep_extend("force", opts.view or {}, {
        width = 36,
        signcolumn = "yes",
        preserve_window_proportions = true,
        float = {
          enable = true,
          open_win_config = tree_window_config,
        },
      })
      opts.renderer = vim.tbl_deep_extend("force", opts.renderer or {}, {
        root_folder_label = false,
        highlight_git = "name",
        highlight_opened_files = "name",
        highlight_modified = "name",
        indent_width = 2,
        group_empty = true,
        special_files = { "README.md", "Makefile", "build.zig", "build.sh" },
        indent_markers = {
          enable = true,
          inline_arrows = true,
          icons = { corner = "╰", edge = "│", item = "│", bottom = "─", none = " " },
        },
        icons = {
          show = { file = true, folder = true, folder_arrow = true, git = true },
          git_placement = "after",
          modified_placement = "after",
          padding = " ",
          glyphs = {
            default = "󰈚",
            symlink = "",
            modified = "●",
            folder = {
              default = "",
              empty = "",
              empty_open = "",
              open = "",
              symlink = "",
              symlink_open = "",
              arrow_open = "",
              arrow_closed = "",
            },
            git = {
              unstaged = "󰄱",
              staged = "󰱒",
              unmerged = "",
              renamed = "➜",
              untracked = "★",
              deleted = "",
              ignored = "◌",
            },
          },
        },
      })
      opts.git = vim.tbl_deep_extend("force", opts.git or {}, { enable = true })
      opts.modified = { enable = true }
      opts.diagnostics = vim.tbl_deep_extend("force", opts.diagnostics or {}, {
        enable = true,
        show_on_dirs = true,
        icons = { hint = "󰌶", info = "", warning = "", error = "" },
      })
      opts.filters = vim.tbl_deep_extend("force", opts.filters or {}, { dotfiles = false })
      return opts
    end,
  },

  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      {
        "rcarriga/nvim-notify",
        opts = { background_colour = "#1c1e26" },
      },
    },
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = false,
        lsp_doc_border = false,
      },
    },
  },

  {
    "echasnovski/mini.animate",
    event = "VeryLazy",
    opts = function()
      local animate = require "mini.animate"
      return {
        resize = { timing = animate.gen_timing.linear { duration = 100, unit = "total" } },
        scroll = { enable = false },
      }
    end,
  },

  {
    "nvim-telescope/telescope.nvim",
    opts = function()
      local config = require "nvchad.configs.telescope"
      config.defaults.mappings.i = vim.tbl_extend("force", config.defaults.mappings.i or {}, {
        ["<C-j>"] = require("telescope.actions").move_selection_next,
        ["<C-k>"] = require("telescope.actions").move_selection_previous,
      })
      return config
    end,
  },
}
