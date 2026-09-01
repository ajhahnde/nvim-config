---@type ChadrcConfig
local M = {}

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
      polish_hl = {
        statusline = {
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
        black = "#1c1e26",
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
        pink = "#9a86fd",
        line = "#2c313a",
        green = "#98c379",
        vibrant_green = "#98c379",
        nord_blue = "#61afef",
        blue = "#61afef",
        yellow = "#e5c07b",
        sun = "#e5c07b",
        purple = "#9a86fd",
        dark_purple = "#8975e6",
        teal = "#66b2ff",
        cyan = "#66b2ff",
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

        local git_status = vim.b[bufnr].gitsigns_status_dict
        if not vim.b[bufnr].gitsigns_head or not git_status then
          return ""
        end

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
        local diagnostic_counts = vim.diagnostic.count(bufnr)
        local result = {}

        for _, item in ipairs(counts) do
          local count = diagnostic_counts[item[1]] or 0
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

  header = function()
    return { "", "NEOVIM", "" }
  end,

  buttons = function()
    local buttons = {}

    for _ = 1, 8 do
      buttons[#buttons + 1] = { txt = " ", no_gap = true }
    end

    buttons[#buttons + 1] = {
      txt = "󰸗  " .. os.date "%A, %d. %B %Y" .. "   󱑊  " .. os.date "%H:%M",
      hl = "NvdashAscii",
    }

    for _ = 1, 2 do
      buttons[#buttons + 1] = { txt = " ", no_gap = true }
    end

    buttons[#buttons + 1] = {
      multicolumn = true,
      { txt = "  Find File", keys = "ff", cmd = "Telescope find_files", hl = "NvdashButtons", pad = 4 },
      { txt = "󰈭  Find Word", keys = "fw", cmd = "Telescope live_grep", hl = "NvdashButtons", pad = 4 },
      { txt = "  Mappings", keys = "ch", cmd = "NvCheatsheet", hl = "NvdashButtons" },
    }

    return buttons
  end,
}

return M
