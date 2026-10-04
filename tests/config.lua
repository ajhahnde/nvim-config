-- Run from the config directory: nvim --clean --headless -i NONE -n -l tests/config.lua
local config_dir = vim.fn.getcwd()
local plugin_dir = vim.fn.stdpath "data" .. "/lazy"
local test_dir = vim.fn.tempname()
vim.fn.mkdir(test_dir, "p")
vim.opt.rtp:prepend(config_dir)
for _, plugin in ipairs { "ui", "nvim-lspconfig", "mason.nvim" } do
  vim.opt.rtp:append(plugin_dir .. "/" .. plugin)
end
vim.opt.rtp:append(vim.fn.stdpath "data" .. "/site")

local stdpath = vim.fn.stdpath
vim.fn.stdpath = function(kind)
  return kind == "state" and test_dir .. "/state" or stdpath(kind)
end

vim.o.columns = 120
vim.g.statusline_winid = nil
local modules = require("chadrc").ui.statusline.modules
local function rendered(module)
  return vim.api.nvim_eval_statusline(module(), {}).str
end
for _, name in ipairs { "report%l.txt", "100%.md", "%{1+1}.lua" } do
  vim.api.nvim_buf_set_name(0, test_dir .. "/" .. name)
  assert(rendered(modules.file):find(name, 1, true), "Filename was interpreted as statusline syntax")
end
vim.b.gitsigns_head = "fix/%l"
vim.b.gitsigns_status_dict = { head = "fix/%l", added = 0, changed = 0, removed = 0 }
assert(rendered(modules.git):find("fix/%l", 1, true))
require("nvchad.stl.utils").state.lsp_msg = "100% ready"
local lsp_msg = rendered(modules.lsp_msg)
assert(lsp_msg:find("100% ready", 1, true), "Unexpected LSP message: " .. vim.inspect { lsp_msg, vim.o.columns })
local get_clients = vim.lsp.get_clients
vim.lsp.get_clients = function()
  return { { name = "server%l" } }
end
assert(rendered(modules.lsp):find("server%l", 1, true))
vim.lsp.get_clients = get_clients

package.loaded["nvchad.configs.lspconfig"] = { capabilities = {}, defaults = function() end }
vim.lsp.enable = function() end
local project_a, project_b = test_dir .. "/a", test_dir .. "/b"
vim.fn.mkdir(project_a .. "/node_modules/typescript/lib", "p")
vim.fn.mkdir(project_b .. "/node_modules/typescript/lib", "p")
vim.fn.chdir(project_a)
require "configs.lspconfig"
local astro = vim.lsp.config.astro
for _, project in ipairs { project_b, project_a } do
  local config = { root_dir = project }
  astro.before_init({}, config)
  assert(config.init_options.typescript.tsdk == project .. "/node_modules/typescript/lib")
end
local fallback = { root_dir = test_dir }
astro.before_init({}, fallback)
local mason_tsdk = stdpath "data" .. "/mason/packages/astro-language-server/node_modules/typescript/lib"
assert(fallback.init_options.typescript.tsdk == (vim.fn.isdirectory(mason_tsdk) == 1 and mason_tsdk or nil))
local no_root = {}
astro.before_init({}, no_root)
assert(no_root.init_options.typescript.tsdk == fallback.init_options.typescript.tsdk)
vim.fn.chdir(config_dir)

package.loaded["nvchad.autocmds"] = {}
local maintenance
vim.defer_fn = function(callback, delay)
  assert(delay == 3000)
  maintenance = callback
end
local notifications = 0
vim.notify = function()
  notifications = notifications + 1
end
local registry = require("mason-core.EventEmitter"):new()
package.loaded["mason-registry"] = registry
local complete_plugins, update_calls, tool_calls = nil, 0, 0
local plugin_failed, throw_update, throw_tools = false, false, false
local plugin_task = {
  has_errors = function()
    return plugin_failed
  end,
}
package.loaded.lazy = {
  update = function()
    update_calls = update_calls + 1
    if throw_update then
      error "simulated Lazy failure"
    end
    return {
      _plugins = {
        { _ = { tasks = { plugin_task } } },
      },
      wait = function(_, callback)
        complete_plugins = callback
      end,
    }
  end,
}
package.loaded["mason-tool-installer"] = {
  check_install = function(force)
    assert(force == true)
    tool_calls = tool_calls + 1
    if throw_tools then
      error "simulated Mason failure"
    end
  end,
}
dofile(config_dir .. "/lua/autocmds.lua")
vim.api.nvim_exec_autocmds("UIEnter", {})
assert(maintenance)
local stamp_file = vim.fn.stdpath "state" .. "/daily-maintenance"
local function stamped()
  return vim.uv.fs_stat(stamp_file) ~= nil
end
local function complete_tools()
  vim.api.nvim_exec_autocmds("User", { pattern = "MasonToolsUpdateCompleted" })
end
local function clean_listeners()
  assert(next(registry.__event_handlers["package:install:failed"]) == nil)
  assert(next(registry.__event_handlers["update:failed"]) == nil)
end
for _, first in ipairs { "plugins", "tools" } do
  maintenance()
  assert(not stamped(), "Maintenance stamped before completion")
  if first == "plugins" then
    complete_plugins()
    assert(not stamped(), "Maintenance did not wait for Mason")
    complete_tools()
  else
    complete_tools()
    assert(not stamped(), "Maintenance did not wait for Lazy")
    complete_plugins()
  end
  assert(vim.fn.readfile(stamp_file)[1] == os.date "%Y-%m-%d")
  clean_listeners()
  local calls = update_calls
  maintenance()
  assert(update_calls == calls, "Successful maintenance ran twice today")
  vim.fn.delete(stamp_file)
end
for _, failure in ipairs { "plugin", "package:install:failed", "update:failed" } do
  plugin_failed = failure == "plugin"
  maintenance()
  if not plugin_failed then
    registry:emit(failure)
  end
  complete_plugins()
  complete_tools()
  assert(not stamped(), "Failed maintenance was stamped")
  clean_listeners()
end
plugin_failed = false
for _, failure in ipairs { "lazy", "mason" } do
  throw_update, throw_tools = failure == "lazy", failure == "mason"
  maintenance()
  assert(not stamped())
  clean_listeners()
  if failure == "mason" then
    complete_plugins()
    assert(not stamped())
  end
end
assert(notifications == 2)
throw_update, throw_tools = false, false
maintenance()
complete_tools()
complete_plugins()
assert(stamped(), "Successful retry was not stamped")
clean_listeners()
assert(tool_calls > 0)

vim.bo.filetype = "python"
vim.api.nvim_buf_set_lines(0, 0, -1, false, { "def test():", "    return 1", "", "print(2)" })
local get_parser = vim.treesitter.get_parser
local parser_calls = 0
vim.treesitter.get_parser = function()
  parser_calls = parser_calls + 1
  return nil
end
require("configs.functionfold").clear_cache(vim.api.nvim_get_current_buf())
vim.cmd "normal! zx"
assert(vim.fn.foldlevel(1) == 0)
assert(parser_calls == 1, "Missing parser was retried per line")
vim.treesitter.get_parser = get_parser
vim.api.nvim_exec_autocmds("CursorHold", {})
assert(vim.fn.foldlevel(1) == 1 and vim.fn.foldlevel(2) == 1 and vim.fn.foldlevel(4) == 0)

vim.fn.delete(test_dir, "rf")
print "Config regressions passed: statusline, Astro, maintenance, folding"
vim.cmd "qa!"
