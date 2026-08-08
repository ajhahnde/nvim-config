---@type ChadrcConfig
local M = {}

local private_dashboard = {}
do
  local ok, config = pcall(require, "ajhahnde.dashboard")
  if ok then
    private_dashboard = config
  end
end

-- Timestamp when this config loaded == when the nvim session started; used
-- by the `session` statusline module below to show elapsed time.
local session_start = os.time()

M.base46 = {
  theme = "onedark",
  transparency = true,
  changed_themes = {
    onedark = {
      -- hl_override only recolors highlight groups that already exist in the
      -- statusline defaults; it silently no-ops on brand-new group names
      -- (St_modified, St_git*, St_clock) since they aren't in that base set.
      -- polish_hl merges unconditionally, so new groups actually get created.
      polish_hl = {
        statusline = {
          -- With transparency=true, base46 sets statusline_bg to NONE for the
          -- whole bar; these overrides give the statusline its own solid strip
          -- (#2c313a) so it stays visible against the terminal background
          -- while the editor above remains transparent.
          StatusLine = { bg = "#343a46" },
          St_gitIcons = { fg = "#9a86fd", bg = "#343a46", bold = true },
          St_Lsp = { fg = "#61afef", bg = "#343a46" },
          St_LspMsg = { fg = "#98c379", bg = "#343a46" },
          St_lspError = { fg = "#e06c75", bg = "#343a46" },
          St_lspWarning = { fg = "#e5c07b", bg = "#343a46" },
          St_LspHints = { fg = "#9a86fd", bg = "#343a46" },
          St_LspInfo = { fg = "#98c379", bg = "#343a46" },
          St_file = { fg = "#61afef", bg = "#313640" },
          St_file_sep = { fg = "#313640", bg = "#343a46" },
          St_cwd_text = { fg = "#e06c75", bg = "#313640" },
          St_cwd_sep = { fg = "#e06c75", bg = "#343a46" },
          St_modified = { fg = "#d19a66", bg = "#343a46" },
          St_gitAdded = { fg = "#98c379", bg = "#343a46" },
          St_gitChanged = { fg = "#e5c07b", bg = "#343a46" },
          St_gitRemoved = { fg = "#e06c75", bg = "#343a46" },
          St_session_icon = { fg = "#2c313a", bg = "#c678dd" },
          St_session_text = { fg = "#c678dd", bg = "#313640" },
          St_session_sep = { fg = "#c678dd", bg = "#343a46" },
          St_clock_icon = { fg = "#2c313a", bg = "#66b2ff" },
          St_clock_text = { fg = "#66b2ff", bg = "#313640" },
          St_clock_sep = { fg = "#66b2ff", bg = "#343a46" },
        },
      },
      base_30 = {
        white = "#abb2bf",
        darker_black = "#1b1f23",
        black = "#1c1e26", -- matching ghostty background
        black2 = "#282c34",
        one_bg = "#2c313a",
        one_bg2 = "#353b45",
        one_bg3 = "#3e4451",
        grey = "#545862",
        grey_fg = "#5c6370",
        grey_fg2 = "#636d83",
        light_grey = "#7f848e",
        red = "#e06c75",
        baby_pink = "#e06c75",
        pink = "#9a86fd", -- Use purple for pink to avoid rosa
        line = "#2c313a",
        green = "#98c379",
        vibrant_green = "#98c379",
        nord_blue = "#61afef",
        blue = "#61afef",
        yellow = "#e5c07b",
        sun = "#e5c07b",
        purple = "#9a86fd", -- Our pure purple
        dark_purple = "#8975e6",
        teal = "#66b2ff", -- Our sky blue
        cyan = "#66b2ff", -- Our sky blue
        orange = "#d19a66",
        statusline_bg = "#343a46",
        lightbg = "#313640",
        pmenu_bg = "#9a86fd",
        folder_bg = "#61afef",
      },
    },
  },
}

M.ui = {
  statusline = {
    theme = "default",
    separator_style = "round",
    order = {
      "mode",
      "file",
      "git",
      "modified",
      "%=",
      "lsp_msg",
      "%=",
      "diagnostics",
      "lsp",
      "session",
      "clock",
      "cwd",
      "cursor",
    },
    modules = {
      modified = function()
        return vim.bo.modified and "%#St_modified#  " or ""
      end,
      git = function()
        local utils = require "nvchad.stl.utils"
        local bufnr = utils.stbufnr()

        if not vim.b[bufnr].gitsigns_head or vim.b[bufnr].gitsigns_git_status then
          return ""
        end

        local git_status = vim.b[bufnr].gitsigns_status_dict

        local added = (git_status.added and git_status.added ~= 0) and ("%#St_gitAdded#  " .. git_status.added) or ""
        local changed = (git_status.changed and git_status.changed ~= 0)
            and ("%#St_gitChanged#  " .. git_status.changed)
          or ""
        local removed = (git_status.removed and git_status.removed ~= 0)
            and ("%#St_gitRemoved#  " .. git_status.removed)
          or ""
        local branch_name = "%#St_gitIcons# " .. git_status.head

        return " " .. branch_name .. added .. changed .. removed
      end,
      clock = function()
        local icon = "%#St_clock_icon#" .. "󰥔 "
        local text = "%#St_clock_text#" .. " " .. os.date "%H:%M" .. " "
        return "%#St_clock_sep#" .. "\238\130\182" .. icon .. text
      end,
      session = function()
        local elapsed = os.time() - session_start
        local h = math.floor(elapsed / 3600)
        local m = math.floor(elapsed % 3600 / 60)
        local s = elapsed % 60
        local icon = "%#St_session_icon#" .. "󰔛 "
        local text = string.format("%%#St_session_text# %02d:%02d:%02d ", h, m, s)
        return "%#St_session_sep#" .. "\238\130\182" .. icon .. text
      end,
    },
  },

  tabufline = {
    lazyload = true,
  },

  telescope = {
    style = "bordered",
  },
}

M.nvdash = {
  load_on_startup = true,

  -- Header: Normaler Text ohne Emojis
  header = function()
    math.randomseed(os.time())
    local quotes = {
      "Simplicity is the soul of efficiency.",
      "First, solve the problem. Then, write the code.",
      "Imagination is more important than knowledge. - Albert Einstein",
      "If you can't explain it to a six-year-old, you don't understand it yourself. - Albert Einstein",
      "A person who never made a mistake never tried anything new. - Albert Einstein",
      "The important thing is not to stop questioning. - Albert Einstein",
      "Look deep into nature, and then you will understand everything better. - Albert Einstein",
      "If I have seen further than others, it is by standing upon the shoulders of giants. - Isaac Newton",
      "Truth is ever to be found in simplicity. - Isaac Newton",
      "Nothing in life is to be feared, it is only to be understood. - Marie Curie",
      "Intelligence is the ability to adapt to change. - Stephen Hawking",
      "Somewhere, something incredible is waiting to be known. - Carl Sagan",
      "Science is a way of thinking much more than it is a body of knowledge. - Carl Sagan",
      "We're made of star stuff. - Carl Sagan",
      "Science and everyday life cannot and should not be separated. - Rosalind Franklin",
      "What I cannot create, I do not understand. - Richard Feynman",
      "The first principle is that you must not fool yourself and you are the easiest person to fool. - Richard Feynman",
      "Chemistry begins in the stars. - Peter Atkins",
      "Biology is the study of the complex things in the Universe. - Richard Dawkins",
      "The Bible tells us how to go to Heaven, not how the heavens go. - Galileo Galilei",
      "Nature is written in mathematical language. - Galileo Galilei",
      "Medicine is a science of uncertainty and an art of probability. - William Osler",
      "In the center of all rests the Sun. - Nicolaus Copernicus",
      "The opposite of a profound truth may well be another profound truth. - Niels Bohr",
      "The way to get good ideas is to get lots of ideas and throw the bad ones away. - Linus Pauling",
      "Science is what we understand well enough to explain to a computer. - Donald Knuth",
      "The best way to predict the future is to invent it. - Alan Kay",
      "Simplicity is prerequisite for reliability. - Edsger W. Dijkstra",
      "Everything is theoretically impossible, until it is done. - Robert A. Heinlein",
      "The science of today is the technology of tomorrow. - Edward Teller",
      "An investment in knowledge pays the best interest. - Benjamin Franklin",
      "Eppur si muove (And yet it moves). - Galileo Galilei",
    }
    return {
      "",
      quotes[math.random(#quotes)],
      "",
    }
  end,

  -- Mitte & Unten: Datum weiter nach unten verschoben
  buttons = function()
    local btns = {}

    -- Abstand zwischen Quote und Datum (reduziert für besseres Fitting)
    for i = 1, 8 do
      table.insert(btns, { txt = " ", no_gap = true })
    end

    -- Datum und Zeit (Spaces am Anfang entfernt für Zentrierung)
    table.insert(
      btns,
      { txt = "󰸗  " .. os.date "%A, %d. %B %Y" .. "   󱑊  " .. os.date "%H:%M", hl = "NvdashAscii" }
    )

    -- Abstand zwischen Datum und Projekt-Shortcuts
    for i = 1, 2 do
      table.insert(btns, { txt = " ", no_gap = true })
    end

    -- Optional machine-local project shortcuts.
    if private_dashboard.project_buttons then
      table.insert(btns, private_dashboard.project_buttons)
    end

    -- Restlicher Abstand bis zu den Buttons (reduziert)
    for i = 1, 2 do
      table.insert(btns, { txt = " ", no_gap = true })
    end

    -- Horizontale Buttons ganz unten
    table.insert(btns, {
      multicolumn = true,
      { txt = "  Find File", keys = "ff", cmd = "Telescope find_files", hl = "NvdashButtons", pad = 4 },
      { txt = "󰈭  Find Word", keys = "fw", cmd = "Telescope live_grep", hl = "NvdashButtons", pad = 4 },
      { txt = "  Mappings", keys = "ch", cmd = "NvCheatsheet", hl = "NvdashButtons" },
    })

    return btns
  end,
}

return M
