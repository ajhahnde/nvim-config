require "nvchad.options"

local o = vim.o
o.relativenumber = false
o.scrolloff = 8
o.sidescrolloff = 8
o.mousescroll = "ver:1,hor:4"
o.confirm = true

o.foldmethod = "expr"
o.foldexpr = "v:lua.require'configs.functionfold'.foldexpr()"
o.foldlevel = 99
o.foldenable = true
