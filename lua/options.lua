require "nvchad.options"

-- add yours here!

local o = vim.o
o.relativenumber = false
o.scrolloff = 8
o.sidescrolloff = 8
o.mousescroll = "ver:1,hor:4"

-- Fold functions only (not classes/blocks/ifs) via custom treesitter
-- foldexpr, see configs/functionfold.lua. foldlevel=99 keeps everything
-- open on load; toggle-all mapping lives in mappings.lua (<leader>zz).
local functionfold = require "configs.functionfold"
_G.UserFunctionFoldExpr = functionfold.foldexpr
o.foldmethod = "expr"
o.foldexpr = "v:lua.UserFunctionFoldExpr()"
o.foldlevel = 99
o.foldenable = true

-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!
