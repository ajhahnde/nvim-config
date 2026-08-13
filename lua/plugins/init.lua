return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre", -- format on save
    opts = require "configs.conform",
  },

  -- Prettier nvim-tree: wider, soft indent guides, git status on the right,
  -- grouped empty folders, dimmed extras and highlighted modified/open files.
  {
    "nvim-tree/nvim-tree.lua",
    opts = function(_, opts)
      opts.hijack_cursor = true
      opts.sync_root_with_cwd = true

      opts.view = vim.tbl_deep_extend("force", opts.view or {}, {
        width = 36,
        signcolumn = "yes",
        preserve_window_proportions = true,
        -- Centered floating tree, cmdline-popup style (matches noice command_palette).
        float = {
          enable = true,
          -- Big, fixed, centered box. The FileType autocmd in autocmds.lua only
          -- adds winblend + accent border/title on top of this geometry.
          open_win_config = function()
            local cols = vim.o.columns
            local rows = vim.o.lines - vim.o.cmdheight - 1
            local w = math.floor(cols * 0.66)
            local h = math.floor(rows * 0.82)
            return {
              relative = "editor",
              border = "rounded",
              width = w,
              height = h,
              row = math.floor((rows - h) / 2),
              col = math.floor((cols - w) / 2),
              title = " Explorer ",
              title_pos = "center",
            }
          end,
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
          git_placement = "after", -- status glyph on the right, not jammed by the name
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
    "stevearc/oil.nvim",
    cmd = "Oil",
    opts = {},
  },

  {
    "folke/todo-comments.nvim",
    event = "VimEnter",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  },

  -- Project-wide search and replace with an editable diff preview.
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

  -- Add, change and delete surrounding quotes, brackets and tags via
  -- ys{motion}{char}, cs{old}{new} and ds{char}.
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    opts = {},
  },

  -- Automatically close and rename paired HTML/Astro/JSX/TSX/XML tags.
  {
    "windwp/nvim-ts-autotag",
    event = { "BufReadPre", "BufNewFile" },
    opts = {},
  },

  -- Save sessions automatically per project and Git branch. Restoring stays
  -- explicit so opening a single file never unexpectedly replaces the layout.
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

  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      {
        "rcarriga/nvim-notify",
        opts = {
          -- Transparency removes NotifyBackground's bg value, but notify's
          -- fade stages still need the actual terminal background for blending.
          background_colour = "#1c1e26",
        },
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
    "3rd/image.nvim",
    ft = { "markdown", "vimwiki" },
    opts = {
      backend = "kitty",
      integrations = {
        markdown = {
          enabled = true,
          clear_in_insert_mode = false,
          download_remote_images = true,
          only_render_image_at_cursor = false,
          filetypes = { "markdown", "vimwiki" },
        },
      },
      max_width = 100,
      max_height = 12,
      max_width_window_percentage = math.huge,
      max_height_window_percentage = math.huge,
      window_overlap_clear_enabled = false,
      window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
    },
  },

  {
    "echasnovski/mini.animate",
    event = "VeryLazy",
    opts = function()
      local animate = require "mini.animate"
      return {
        resize = {
          timing = animate.gen_timing.linear { duration = 100, unit = "total" },
        },
        scroll = { enable = false },
      }
    end,
    config = function(_, opts)
      require("mini.animate").setup(opts)
    end,
  },

  {
    "neovim/nvim-lspconfig",
    event = "User FilePost",
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "nvim-telescope/telescope.nvim",
    opts = function()
      local conf = require "nvchad.configs.telescope"

      conf.defaults.mappings.i = vim.tbl_extend("force", conf.defaults.mappings.i or {}, {
        ["<C-j>"] = require("telescope.actions").move_selection_next,
        ["<C-k>"] = require("telescope.actions").move_selection_previous,
      })

      return conf
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    -- The current main branch does not support lazy-loading.
    lazy = false,
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "zig",
        "rust",
        "toml",
        "go",
        "gomod",
        "python",
        "c",
        "cpp",
        "bash",
        "markdown",
        "markdown_inline",
        "json",
        "yaml",
        "html",
        "css",
        -- JavaScript and documentation
        "javascript",
        "jsdoc",
        -- Astro and TypeScript/TSX
        "astro",
        "typescript",
        "tsx",
        -- Godot: GDScript, .tscn/.tres scenes & resources,
        -- shaders, plus XML (Godot icon .svg art maps to the xml parser).
        "gdscript",
        "godot_resource",
        "gdshader",
        "xml",
        -- DevOps / Cloud: Dockerfile syntax, HCL (Terraform/Packer/Nomad).
        "dockerfile",
        "hcl",
        -- Systems / low-level: Makefile build system, x86/ARM/RISC-V assembly.
        "make",
        "asm",
      })
      return opts
    end,
  },

  -- Browser Markdown preview (GitHub-style, renders inline HTML/badges/<picture>
  -- that in-buffer renderers skip). Commands: :MdPreview / :MdStop (autocmds.lua).
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
    ft = { "markdown" },
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
    init = function()
      vim.g.mkdp_auto_close = 0 -- keep the browser tab when switching buffers
      vim.g.mkdp_theme = "dark"
    end,
  },

  -- In-buffer Markdown rendering (headers, tables, code blocks, callouts)
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      code = {
        width = "block",
        right_pad = 1,
        sign = false,
      },
      heading = {
        sign = false,
      },
    },
    keys = {
      { "<leader>mr", "<cmd>RenderMarkdown toggle<cr>", desc = "Markdown render toggle" },
    },
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
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    opts = {},
  },

  -- Git commands in nvim: :Git add ., :Git commit, :Git blame, :Git push, etc.
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "Gvdiffsplit", "Gdiffsplit", "Gread", "Gwrite", "Gclog" },
    keys = {
      { "<leader>gs", "<cmd>Git<cr>", desc = "Git status" },
    },
  },

  -- Pin the LSP/formatter/linter toolset so a fresh machine auto-installs it
  -- (NvChad v2.5 dropped mason auto-install).
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    event = "VeryLazy",
    opts = {
      ensure_installed = {
        "zls",
        "gopls",
        "pyright",
        "bash-language-server",
        "lua-language-server",
        "html-lsp",
        "css-lsp",
        -- JS/JSON LSP + HTML emmet
        "typescript-language-server",
        "json-lsp",
        "emmet-language-server",
        -- Data/config formats: YAML LSP + TOML LSP (taplo also formats TOML).
        "yaml-language-server",
        "taplo",
        -- Astro LSP (also formats .astro via its bundled prettier plugin).
        "astro-language-server",
        -- DevOps / Cloud: LSP servers for Docker, Compose, Terraform, Helm,
        -- Ansible + dedicated linters (hadolint, tflint, ansible-lint).
        "dockerfile-language-server",
        "docker-compose-language-service",
        "terraform-ls",
        "helm-ls",
        "ansible-language-server",
        "hadolint",
        "tflint",
        "ansible-lint",
        "stylua",
        "goimports",
        "prettier",
        "ruff",
        "shfmt",
        "shellcheck",
        -- Godot: gdtoolkit -> gdformat (conform) + gdlint
        -- (nvim-lint); lemminx -> XML/SVG LSP. The gdscript LSP itself is
        -- NOT here: it is Godot's own editor server on :6005 (see lspconfig).
        "gdtoolkit",
        "lemminx",
        -- Systems / low-level: C/C++ LSP + formatter. rust-analyzer comes
        -- from rustup so project-local rust-toolchain files are honored.
        "clangd",
        "clang-format",
      },
      auto_update = true,
      run_on_start = true,
      start_delay = 3000,
      debounce_hours = 24,
    },
  },

  -- Linting beyond LSP: shell, Godot and DevOps/Cloud linters.
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufWritePost" },
    config = function()
      local lint = require "lint"
      lint.linters_by_ft = {
        sh = { "shellcheck" },
        bash = { "shellcheck" },
        -- gdlint ships in gdtoolkit (installed via mason).
        gdscript = { "gdlint" },
        -- DevOps / Cloud: Dockerfile, Terraform, Ansible linters.
        dockerfile = { "hadolint" },
        terraform = { "tflint" },
        tf = { "tflint" },
        ["yaml.ansible"] = { "ansible_lint" },
      }
      local group = vim.api.nvim_create_augroup("UserLint", { clear = true })
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
        group = group,
        callback = function()
          -- Only lint filetypes that actually have a linter configured; skips
          -- the no-op spawn attempt in every other buffer.
          if lint.linters_by_ft[vim.bo.filetype] then
            lint.try_lint()
          end
        end,
      })
    end,
  },

  -- Override NvChad's Codeberg URL for cmp-async-path (504 errors) with the
  -- GitHub mirror. Lazy.nvim deduplicates by plugin name, so this wins.
  {
    "FelipeLema/cmp-async-path",
    url = "https://github.com/FelipeLema/cmp-async-path",
  },

  -- AI inline completion (free tier, fast).
  {
    "supermaven-inc/supermaven-nvim",
    event = "InsertEnter",
    opts = {
      -- Tab is taken by cmp menu navigation; avoid clashing with it.
      keymaps = { accept_suggestion = "<C-l>" },
    },
  },
}
