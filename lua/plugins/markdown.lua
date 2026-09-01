local image_patterns = {}
for _, extension in ipairs { "png", "jpg", "jpeg", "gif", "webp", "avif" } do
  image_patterns[#image_patterns + 1] = "*." .. extension
  image_patterns[#image_patterns + 1] = "*." .. extension:upper()
end

return {
  {
    "3rd/image.nvim",
    ft = { "markdown", "vimwiki" },
    event = { { event = "BufReadPre", pattern = image_patterns } },
    opts = {
      backend = "kitty",
      processor = "magick_cli",
      kitty_method = "normal",
      integrations = {
        markdown = {
          enabled = true,
          clear_in_insert_mode = false,
          download_remote_images = false,
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
      hijack_file_patterns = image_patterns,
    },
  },

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
}
