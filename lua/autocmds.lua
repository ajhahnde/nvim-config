require "nvchad.autocmds"

local general_group = vim.api.nvim_create_augroup("UserGeneral", { clear = true })
local folding_group = vim.api.nvim_create_augroup("UserFunctionFolding", { clear = true })
local markdown_group = vim.api.nvim_create_augroup("UserMarkdown", { clear = true })
local prose_group = vim.api.nvim_create_augroup("UserProse", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = prose_group,
  pattern = { "gitcommit", "markdown", "text" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.breakindent = true
    vim.opt_local.spell = true
  end,
})

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

vim.api.nvim_create_autocmd({ "TextChanged", "BufWritePost", "InsertLeave" }, {
  group = general_group,
  callback = function()
    vim.cmd.redrawstatus()
  end,
})

local previous_timer = rawget(_G, "UserStatuslineClockTimer")
if previous_timer and not previous_timer:is_closing() then
  previous_timer:stop()
  previous_timer:close()
end

local clock_timer = vim.uv.new_timer()
_G.UserStatuslineClockTimer = clock_timer

if clock_timer then
  clock_timer:start(
    0,
    60000,
    vim.schedule_wrap(function()
      if vim.v.exiting == vim.NIL then
        vim.cmd.redrawstatus()
      end
    end)
  )
end

vim.api.nvim_create_autocmd("VimLeavePre", {
  group = general_group,
  once = true,
  callback = function()
    if clock_timer and not clock_timer:is_closing() then
      clock_timer:stop()
      clock_timer:close()
    end
    _G.UserStatuslineClockTimer = nil
  end,
})

vim.api.nvim_create_autocmd("BufWipeout", {
  group = general_group,
  callback = function(args)
    require("configs.functionfold").clear_cache(args.buf)
  end,
})

vim.treesitter.language.register("bash", "zsh")

local markdown_commands = {
  MdPreview = "MarkdownPreview",
  MdStop = "MarkdownPreviewStop",
  MdToggle = "MarkdownPreviewToggle",
}

vim.api.nvim_create_autocmd("FileType", {
  group = markdown_group,
  pattern = "markdown",
  callback = function(args)
    for name, command in pairs(markdown_commands) do
      vim.api.nvim_buf_create_user_command(args.buf, name, command, { desc = "Run :" .. command })
    end
  end,
})
