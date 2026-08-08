require "nvchad.autocmds"

local general_group = vim.api.nvim_create_augroup("UserGeneral", { clear = true })
local markdown_group = vim.api.nvim_create_augroup("UserMarkdown", { clear = true })
local folding_group = vim.api.nvim_create_augroup("UserFunctionFolding", { clear = true })

-- Runtime ftplugins in recent Neovim versions set their own window-local
-- treesitter foldexpr when a filetype is detected. That happens after the
-- global defaults in options.lua and used to replace our function-only
-- foldexpr. Apply it here, after the ftplugin, for every normal file buffer.
vim.api.nvim_create_autocmd("FileType", {
  group = folding_group,
  callback = function(args)
    if vim.bo[args.buf].buftype ~= "" then
      return
    end

    vim.opt_local.foldmethod = "expr"
    vim.opt_local.foldexpr = "v:lua.require'configs.functionfold'.foldexpr()"
    vim.opt_local.foldlevel = 99
    vim.opt_local.foldenable = true
    vim.opt_local.foldcolumn = "1"
  end,
})

-- Force statusline redraw so the unsaved-changes indicator (chadrc.lua,
-- statusline `modified` module) updates immediately on edit/save instead of
-- lagging behind Neovim's default lazy redraw. TextChanged covers normal-mode
-- edits; insert-mode changes are picked up on InsertLeave — per-keystroke
-- TextChangedI redraws are not worth the cost.
vim.api.nvim_create_autocmd({ "TextChanged", "BufWritePost", "InsertLeave" }, {
  group = general_group,
  callback = function()
    vim.cmd.redrawstatus()
  end,
})

-- Tick the statusline `clock` module (chadrc.lua) once a second so it shows
-- real time instead of only refreshing on the redraws above.
local clock_timer = assert(vim.uv.new_timer())
clock_timer:start(
  0,
  1000,
  vim.schedule_wrap(function()
    if vim.v.exiting == vim.NIL then
      vim.cmd.redrawstatus()
    end
  end)
)

vim.api.nvim_create_autocmd("VimLeavePre", {
  group = general_group,
  once = true,
  callback = function()
    clock_timer:stop()
    if not clock_timer:is_closing() then
      clock_timer:close()
    end
  end,
})

vim.api.nvim_create_autocmd("BufWipeout", {
  group = general_group,
  callback = function(args)
    require("configs.functionfold").clear_cache(args.buf)
  end,
})

-- ── Centered floating nvim-tree polish ──────────────────────────────────────
-- The float's initial size/spot is set in plugins/init.lua (open_win_config).
-- Here we refine it once the tree has actually rendered: snap the box snug to
-- the content (no empty right/bottom), nudge it to the upper third (noice
-- cmdline style), add subtle transparency, and recolor the border + title with
-- the theme accents (cyan border, purple title).
local tree_group = vim.api.nvim_create_augroup("TreeFloatPolish", { clear = true })

-- Snap the float snug to the rendered tree. Terminal nvim can't scale glyph px
-- per-buffer (Ghostty draws one cell size for the whole grid), so instead we
-- size the BOX to the entry count: few entries → small centered box (no empty
-- void), many → grows to a cap, then scrolls. Re-runs on every render so it
-- tracks folder expand/collapse live.
local TREE = {
  min_w = 30, -- never narrower than this
  max_w_pct = 0.66, -- cap at 66% of columns (matches open_win_config)
  min_h = 6, -- never shorter than this
  max_h_pct = 0.82, -- cap at 82% of usable rows
  pad_w = 4, -- breathing room past the longest line (signcol + icon gutter)
}

local function fit_tree_float(win, buf)
  if not (win and vim.api.nvim_win_is_valid(win) and vim.api.nvim_buf_is_valid(buf)) then
    return
  end
  -- Only resize true floats (skip if the tree is ever shown as a split).
  local cfg = vim.api.nvim_win_get_config(win)
  if not cfg.relative or cfg.relative == "" then
    return
  end

  local cols = vim.o.columns
  local rows = vim.o.lines - vim.o.cmdheight - 1

  -- Height = entry count, clamped.
  local lines = vim.api.nvim_buf_line_count(buf)
  local max_h = math.floor(rows * TREE.max_h_pct)
  local h = math.max(TREE.min_h, math.min(lines, max_h))

  -- Width = longest rendered line + padding, clamped.
  local longest = 0
  for _, l in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
    local w = vim.fn.strdisplaywidth(l)
    if w > longest then
      longest = w
    end
  end
  local max_w = math.floor(cols * TREE.max_w_pct)
  local w = math.max(TREE.min_w, math.min(longest + TREE.pad_w, max_w))

  local row = math.floor((rows - h) / 2)
  local col = math.floor((cols - w) / 2)

  -- Guard: only touch the window if geometry actually changed. Otherwise the
  -- resize re-triggers a render → TreeRendered → resize → infinite loop.
  if cfg.width == w and cfg.height == h and cfg.row == row and cfg.col == col then
    return
  end
  vim.api.nvim_win_set_config(win, {
    relative = "editor",
    width = w,
    height = h,
    row = row,
    col = col,
  })
end

-- ── zsh highlighting ────────────────────────────────────────────────────────
-- No dedicated zsh treesitter grammar; the bash parser (already in
-- ensure_installed) covers zsh syntax well enough for highlighting.
pcall(vim.treesitter.language.register, "bash", "zsh")

-- ── Markdown ex-commands: :MdPreview / :MdStop / :MdToggle ──────────────────
-- Browser preview via markdown-preview.nvim (GitHub-style rendering incl.
-- inline HTML, badges, <picture>). Buffer-local commands, markdown files only.
vim.api.nvim_create_autocmd("FileType", {
  group = markdown_group,
  pattern = "markdown",
  callback = function(args)
    vim.api.nvim_buf_create_user_command(args.buf, "MdPreview", function()
      vim.cmd "MarkdownPreview"
    end, { desc = "Markdown browser preview (GitHub-style, renders HTML)" })
    vim.api.nvim_buf_create_user_command(args.buf, "MdStop", function()
      vim.cmd "MarkdownPreviewStop"
    end, { desc = "Stop the Markdown browser preview" })
    vim.api.nvim_buf_create_user_command(args.buf, "MdToggle", function()
      vim.cmd "MarkdownPreviewToggle"
    end, { desc = "Toggle the Markdown browser preview" })
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = tree_group,
  pattern = "NvimTree",
  callback = function(ev)
    local win = vim.api.nvim_get_current_win()

    -- accent border/title (scoped to this window) + see-through
    vim.api.nvim_set_hl(0, "NvimTreeFloatBorder", { fg = "#66b2ff", bg = "NONE" })
    vim.api.nvim_set_hl(0, "NvimTreeFloatTitle", { fg = "#9a86fd", bold = true })
    vim.wo[win].winhighlight = "FloatBorder:NvimTreeFloatBorder,FloatTitle:NvimTreeFloatTitle"
    vim.wo[win].winblend = 10

    fit_tree_float(win, ev.buf)

    -- Subscribe once: re-fit on every (re)render — open, expand, collapse, cd.
    if not vim.g._tree_fit_hooked then
      vim.g._tree_fit_hooked = true
      local api = require "nvim-tree.api"
      api.events.subscribe(api.events.Event.TreeRendered, function(data)
        vim.schedule(function()
          fit_tree_float(data.winnr, data.bufnr)
        end)
      end)
    end
  end,
})
