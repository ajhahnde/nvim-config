---@type ChadrcConfig
local M = {}

-- Statusline modules are rendered for every window, including narrow vertical
-- splits. `vim.o.columns` is the width of the whole editor and therefore does
-- not tell us how much room a particular statusline has. Use the window for
-- which Neovim is currently evaluating the statusline instead.
local function statusline_width()
  local win = tonumber(vim.g.statusline_winid)
  if win and vim.api.nvim_win_is_valid(win) then
    return vim.api.nvim_win_get_width(win)
  end

  return vim.o.columns
end

local function shorten(text, max_width)
  if vim.fn.strdisplaywidth(text) <= max_width then
    return text
  end

  local suffix = vim.fn.fnamemodify(text, ":e")
  suffix = suffix ~= "" and "." .. suffix or ""
  local suffix_width = vim.fn.strdisplaywidth(suffix)
  if suffix_width >= max_width - 1 then
    suffix = ""
    suffix_width = 0
  end

  local target = max_width - suffix_width - 1
  local head = ""
  for char in text:gmatch "[\1-\127\194-\244][\128-\191]*" do
    if vim.fn.strdisplaywidth(head .. char) > target then
      break
    end
    head = head .. char
  end

  return head .. "…" .. suffix
end

M.base46 = {
  theme = "onedark",
  transparency = true,
  changed_themes = {
    onedark = {
      -- hl_override only recolors highlight groups that already exist in the
      -- statusline defaults; it silently no-ops on brand-new group names
      -- (St_modified, St_git*, St_muted) since they aren't in that base set.
      -- polish_hl merges unconditionally, so new groups actually get created.
      polish_hl = {
        statusline = {
          -- With transparency=true, base46 sets statusline_bg to NONE for the
          -- whole bar; these overrides give the statusline its own solid strip
          -- so it stays visible against the terminal background
          -- while the editor above remains transparent.
          StatusLine = { fg = "#abb2bf", bg = "#242832" },
          StatusLineNC = { fg = "#545862", bg = "#20242d" },
          St_file = { fg = "#abb2bf", bg = "#242832", bold = true },
          St_modified = { fg = "#d19a66", bg = "#242832" },
          St_gitIcons = { fg = "#9a86fd", bg = "#242832" },
          St_gitAdded = { fg = "#98c379", bg = "#242832" },
          St_gitChanged = { fg = "#e5c07b", bg = "#242832" },
          St_gitRemoved = { fg = "#e06c75", bg = "#242832" },
          St_Lsp = { fg = "#61afef", bg = "#242832" },
          St_LspMsg = { fg = "#98c379", bg = "#242832", italic = true },
          St_lspError = { fg = "#e06c75", bg = "#242832" },
          St_lspWarning = { fg = "#e5c07b", bg = "#242832" },
          St_LspHints = { fg = "#9a86fd", bg = "#242832" },
          St_LspInfo = { fg = "#98c379", bg = "#242832" },
          St_muted = { fg = "#7f848e", bg = "#242832" },
          St_position = { fg = "#1c1e26", bg = "#66b2ff", bold = true },
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
        statusline_bg = "#242832",
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
    separator_style = "block",
    order = {
      "mode",
      "file",
      "modified",
      "git",
      "%=",
      "lsp_msg",
      "%=",
      "diagnostics",
      "lsp",
      "clock",
      "cursor",
    },
    modules = {
      mode = function()
        local utils = require "nvchad.stl.utils"
        if not utils.is_activewin() then
          return ""
        end

        local mode = vim.api.nvim_get_mode().mode
        local mode_data = utils.modes[mode] or { mode:upper(), "Normal" }
        local label = mode_data[1]:sub(1, 1)
        local hl = mode_data[2]
        return "%#St_" .. hl .. "Mode# " .. label .. " %#StatusLine# "
      end,
      file = function()
        local file = require("nvchad.stl.utils").file()
        local width = statusline_width()
        local max_name_width = width < 50 and 8 or width < 70 and 12 or width < 100 and 18 or 28
        local name = shorten(file[2], max_name_width)
        return "%#St_file#" .. file[1] .. " " .. name
      end,
      modified = function()
        local bufnr = require("nvchad.stl.utils").stbufnr()
        return vim.bo[bufnr].modified and "%#St_modified# ●" or ""
      end,
      git = function()
        local utils = require "nvchad.stl.utils"
        local bufnr = utils.stbufnr()

        local width = statusline_width()
        if width < 70 then
          return ""
        end

        if not vim.b[bufnr].gitsigns_head or vim.b[bufnr].gitsigns_git_status then
          return ""
        end

        local git_status = vim.b[bufnr].gitsigns_status_dict

        local show_counts = width >= 95
        local added = show_counts
            and (git_status.added and git_status.added ~= 0)
            and ("%#St_gitAdded# +" .. git_status.added)
          or ""
        local changed = show_counts
            and (git_status.changed and git_status.changed ~= 0)
            and ("%#St_gitChanged# ~" .. git_status.changed)
          or ""
        local removed = show_counts
            and (git_status.removed and git_status.removed ~= 0)
            and ("%#St_gitRemoved# -" .. git_status.removed)
          or ""
        local branch_name = "%#St_gitIcons#   " .. shorten(git_status.head, width < 95 and 10 or 18)

        return branch_name .. added .. changed .. removed
      end,
      lsp_msg = function()
        if statusline_width() < 105 then
          return ""
        end

        return "%#St_LspMsg#" .. require("nvchad.stl.utils").lsp_msg()
      end,
      diagnostics = function()
        if statusline_width() < 65 then
          return ""
        end

        local bufnr = require("nvchad.stl.utils").stbufnr()
        local severity = vim.diagnostic.severity
        local counts = {
          { severity.ERROR, "St_lspError", "" },
          { severity.WARN, "St_lspWarning", "" },
          { severity.HINT, "St_LspHints", "󰌵" },
          { severity.INFO, "St_LspInfo", "󰋼" },
        }
        local result = {}

        for _, item in ipairs(counts) do
          local count = #vim.diagnostic.get(bufnr, { severity = item[1] })
          if count > 0 then
            result[#result + 1] = "%#" .. item[2] .. "# " .. item[3] .. " " .. count
          end
        end

        return table.concat(result)
      end,
      lsp = function()
        local width = statusline_width()
        if width < 80 or not rawget(vim, "lsp") then
          return ""
        end

        local bufnr = require("nvchad.stl.utils").stbufnr()
        for _, client in ipairs(vim.lsp.get_clients { bufnr = bufnr }) do
          local name = width >= 110 and " " .. client.name or ""
          return "%#St_Lsp#  󰒋" .. name
        end

        return ""
      end,
      clock = function()
        if statusline_width() < 75 then
          return ""
        end

        return "%#St_muted#  " .. os.date "%H:%M" .. " "
      end,
      cursor = function()
        if statusline_width() < 45 then
          return "%#St_position# %l "
        end

        return "%#St_position# %l:%v "
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

    -- Abstand bis zu den Buttons
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
