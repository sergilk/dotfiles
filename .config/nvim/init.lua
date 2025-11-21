local vim = vim
local Plug = vim.fn['plug#']

vim.call('plug#begin')
-- List your plugins here
Plug 'uZer/pywal16.nvim'
vim.call('plug#end')
local pywal16 = require('pywal16')
pywal16.setup()
--vim.cmd('silent! colorscheme pywal16')

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.opt.wrap = false
vim.opt.swapfile = false
vim.g.mapleader = " "
vim.opt.fillchars:append('eob: ')
vim.o.clipboard = 'unnamedplus'

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.numberwidth = 2

vim.keymap.set('n', '<leader>w', ':write<CR>')
vim.keymap.set('n', '<leader>q', ':quit<CR>')
vim.keymap.set({'n', 'v', 'x'}, '<leader>y', '"+y')
vim.keymap.set({'n', 'v', 'x'}, '<leader>d', '"+d')