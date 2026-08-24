-- Flash's canonical formatter uses four-space indentation.
vim.bo.commentstring = "# %s"
vim.bo.expandtab = true
vim.bo.shiftwidth = 4
vim.bo.softtabstop = 4
vim.bo.tabstop = 4

vim.opt_local.suffixesadd:append ".fsh"

vim.b.undo_ftplugin = table.concat({
  "setlocal commentstring<",
  "setlocal expandtab<",
  "setlocal shiftwidth<",
  "setlocal softtabstop<",
  "setlocal tabstop<",
  "setlocal suffixesadd<",
}, " | ")
