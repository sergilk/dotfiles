vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.opt.wrap = false
vim.opt.swapfile = false
vim.g.mapleader = " "
vim.opt.fillchars:append('eob: ')

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.numberwidth = 2

vim.api.nvim_set_hl(0, "Normal", { bg = "#000000", fg = "#fefefe" }) -- main fg/bg
vim.api.nvim_set_hl(0, "LineNr", { fg = "#222222", bg = "#000000" }) -- number line
vim.api.nvim_set_hl(0, "Visual", { bg = "#1a1a1a" }) -- selection
vim.api.nvim_set_hl(0, "StatusLine", { fg = "#fefefe", bg = "#232323" }) -- status line
vim.api.nvim_set_hl(0, "Comment", { fg = "#666666", italic = true }) -- comments
vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#fefefe", bg = "#ffffff", bold = true }) -- higlight current line

vim.keymap.set('n', '<leader>o', ':update<CR> :source<CR>')
vim.keymap.set('n', '<leader>w', ':write<CR>')
vim.keymap.set({'n', 'v', 'x'}, '<leader>y', '"+y')
vim.keymap.set({'n', 'v', 'x'}, '<leader>d', '"+d')
