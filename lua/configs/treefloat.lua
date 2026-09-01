local M = {}

local dimensions = {
  min_width = 30,
  max_width_ratio = 0.66,
  min_height = 6,
  max_height_ratio = 0.82,
  horizontal_padding = 4,
}

local subscribed = false

local function fit_window(window, buffer)
  if not (vim.api.nvim_win_is_valid(window) and vim.api.nvim_buf_is_valid(buffer)) then
    return
  end

  local config = vim.api.nvim_win_get_config(window)
  if config.relative == "" then
    return
  end

  local columns = vim.o.columns
  local rows = vim.o.lines - vim.o.cmdheight - 1
  local max_width = math.floor(columns * dimensions.max_width_ratio)
  local max_height = math.floor(rows * dimensions.max_height_ratio)
  local height = math.min(math.max(vim.api.nvim_buf_line_count(buffer), dimensions.min_height), max_height)

  local longest = 0
  for _, line in ipairs(vim.api.nvim_buf_get_lines(buffer, 0, -1, false)) do
    longest = math.max(longest, vim.fn.strdisplaywidth(line))
    if longest + dimensions.horizontal_padding >= max_width then
      break
    end
  end

  local width = math.min(math.max(longest + dimensions.horizontal_padding, dimensions.min_width), max_width)
  local row = math.floor((rows - height) / 2)
  local column = math.floor((columns - width) / 2)

  if config.width == width and config.height == height and config.row == row and config.col == column then
    return
  end

  vim.api.nvim_win_set_config(window, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = column,
  })
end

function M.setup()
  local group = vim.api.nvim_create_augroup("UserTreeFloat", { clear = true })
  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "NvimTree",
    callback = function(args)
      local window = vim.api.nvim_get_current_win()
      vim.api.nvim_set_hl(0, "NvimTreeFloatBorder", { fg = "#66b2ff", bg = "NONE" })
      vim.api.nvim_set_hl(0, "NvimTreeFloatTitle", { fg = "#9a86fd", bold = true })
      vim.wo[window].winhighlight = "FloatBorder:NvimTreeFloatBorder,FloatTitle:NvimTreeFloatTitle"
      vim.wo[window].winblend = 10
      fit_window(window, args.buf)

      if subscribed then
        return
      end

      subscribed = true
      local api = require "nvim-tree.api"
      api.events.subscribe(api.events.Event.TreeRendered, function(data)
        vim.schedule(function()
          fit_window(data.winnr, data.bufnr)
        end)
      end)
    end,
  })
end

return M
