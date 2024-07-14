vim.opt.clipboard = "unnamed"
vim.opt.cul = false
vim.opt.relativenumber = true
vim.opt.smartindent = true
vim.opt.fillchars = { eob = " " }
vim.opt.number = true
vim.opt.numberwidth = 2
vim.opt.signcolumn = "yes"
vim.opt.timeoutlen = 400
vim.opt.undofile = true
vim.opt.showmode = false
vim.opt.spelllang = 'en_us'
vim.opt.spell = true

vim.opt.laststatus = 3
vim.opt.statusline = ' '
vim.opt.cmdheight = 1

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.bo.softtabstop = 4

vim.cmd("set foldcolumn=0")
vim.cmd("set foldenable")
vim.cmd("set foldlevel=99")
vim.cmd("set foldmethod=indent")
vim.cmd("set foldnestmax=1")
vim.cmd("set termguicolors")
vim.cmd("set colorcolumn=119")
