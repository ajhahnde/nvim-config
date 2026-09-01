return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts = require "configs.conform",
  },

  {
    "stevearc/oil.nvim",
    cmd = "Oil",
    opts = {},
  },

  {
    "Konfekt/vim-office",
    lazy = false,
    init = function()
      local libreoffice_bin = "/Applications/LibreOffice.app/Contents/MacOS"
      if vim.fn.isdirectory(libreoffice_bin) == 1 then
        vim.env.PATH = libreoffice_bin .. ":" .. vim.env.PATH
      end
    end,
  },

  {
    "folke/todo-comments.nvim",
    event = "VimEnter",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  },

  {
    "MagicDuck/grug-far.nvim",
    cmd = { "GrugFar", "GrugFarWithin" },
    opts = {},
    keys = {
      {
        "<leader>sr",
        function()
          require("grug-far").open()
        end,
        desc = "Search and replace project",
      },
      {
        "<leader>sr",
        function()
          require("grug-far").with_visual_selection()
        end,
        mode = "x",
        desc = "Search and replace selection",
      },
    },
  },

  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    opts = {},
  },

  {
    "windwp/nvim-ts-autotag",
    event = { "BufReadPre", "BufNewFile" },
    opts = {},
  },

  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {},
    keys = {
      {
        "<leader>ps",
        function()
          require("persistence").load()
        end,
        desc = "Project session restore",
      },
      {
        "<leader>pS",
        function()
          require("persistence").select()
        end,
        desc = "Project session select",
      },
      {
        "<leader>pl",
        function()
          require("persistence").load { last = true }
        end,
        desc = "Project session restore last",
      },
      {
        "<leader>pd",
        function()
          require("persistence").stop()
        end,
        desc = "Project session stop saving",
      },
    },
  },

  {
    "folke/flash.nvim",
    opts = {},
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump()
        end,
        desc = "Flash",
      },
      {
        "S",
        mode = { "n", "x", "o" },
        function()
          require("flash").treesitter()
        end,
        desc = "Flash Treesitter",
      },
    },
  },
}
