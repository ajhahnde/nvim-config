local M = {}

local DAY_IN_SECONDS = 24 * 60 * 60
local START_DELAY_MS = 5000
local timestamp_file = vim.fn.stdpath "state" .. "/lazy-auto-update"

local function update_is_due()
  local ok, lines = pcall(vim.fn.readfile, timestamp_file)
  local last_update = ok and tonumber(lines[1]) or nil

  return not last_update or os.difftime(os.time(), last_update) >= DAY_IN_SECONDS
end

local function remember_update_attempt()
  vim.fn.mkdir(vim.fs.dirname(timestamp_file), "p")
  vim.fn.writefile({ tostring(os.time()) }, timestamp_file)
end

function M.setup()
  local group = vim.api.nvim_create_augroup("UserDailyPluginUpdate", { clear = true })

  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "VeryLazy",
    once = true,
    callback = function()
      -- Keep headless commands such as tests and Git hooks deterministic.
      if #vim.api.nvim_list_uis() == 0 or not update_is_due() then
        return
      end

      -- Record the attempt before starting so several Neovim instances do not
      -- launch competing updates. Lazy also refreshes lazy-lock.json and runs
      -- plugin build hooks (including Tree-sitter parser updates).
      remember_update_attempt()
      vim.defer_fn(function()
        require("lazy").update { show = false }
      end, START_DELAY_MS)
    end,
  })
end

return M
