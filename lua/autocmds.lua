require "nvchad.autocmds"

local general_group = vim.api.nvim_create_augroup("UserGeneral", { clear = true })
local folding_group = vim.api.nvim_create_augroup("UserFunctionFolding", { clear = true })
local lazy_git_group = vim.api.nvim_create_augroup("UserLazyGit", { clear = true })
local markdown_group = vim.api.nvim_create_augroup("UserMarkdown", { clear = true })
local prose_group = vim.api.nvim_create_augroup("UserProse", { clear = true })

local config_dir = vim.fn.stdpath "config"
local lazy_git_running = false

local function lazy_git_notify(message, level)
  vim.schedule(function()
    vim.notify(message, level or vim.log.levels.INFO, { title = "Lazy lockfile" })
  end)
end

local function lazy_git_error(action, result)
  lazy_git_running = false
  local output = vim.trim(result.stderr or result.stdout or "")
  local message = action .. " fehlgeschlagen"
  lazy_git_notify(output == "" and message or message .. ":\n" .. output, vim.log.levels.ERROR)
end

local function lazy_git(args, callback)
  vim.system(vim.list_extend({ "git" }, args), {
    cwd = config_dir,
    text = true,
  }, callback)
end

vim.api.nvim_create_autocmd("User", {
  group = lazy_git_group,
  pattern = "LazyUpdate",
  callback = function()
    if lazy_git_running then
      return
    end
    lazy_git_running = true

    vim.schedule(function()
      lazy_git({ "diff", "--quiet", "HEAD", "--", "lazy-lock.json" }, function(diff)
        if diff.code == 0 then
          lazy_git_running = false
          return
        end
        if diff.code ~= 1 then
          lazy_git_error("Prüfen von lazy-lock.json", diff)
          return
        end

        lazy_git({ "add", "--", "lazy-lock.json" }, function(add)
          if add.code ~= 0 then
            lazy_git_error("Stagen von lazy-lock.json", add)
            return
          end

          lazy_git({ "commit", "-m", "chore(deps): update lazy-lock.json [automated]", "--", "lazy-lock.json" }, function(commit)
            if commit.code ~= 0 then
              lazy_git_error("Commit von lazy-lock.json", commit)
              return
            end

            lazy_git({ "push" }, function(push)
              lazy_git_running = false
              if push.code ~= 0 then
                lazy_git_error("Push des Lockfile-Commits", push)
                return
              end
              lazy_git_notify "lazy-lock.json wurde committed und gepusht"
            end)
          end)
        end)
      end)
    end)
  end,
})

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
