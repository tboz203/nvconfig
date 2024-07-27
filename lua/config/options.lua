-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.python3_host_prog = vim.fn.expand("~/.pyenv/versions/neovim/bin/python")

-- vim.lsp.set_log_level(vim.log.levels.DEBUG)

-- vim.o.autowrite = false
-- vim.o.autowriteall = false
-- vim.o.hidden = true

vim.o.linebreak = true

-- vim.o.wrapscan = false
vim.o.relativenumber = false

-- vim.opt.listchars = { tab = ">-", trail = "-", extends = "$", precedes = "$" }
vim.opt.spelloptions:append("camel")

-- vim.opt.directory:append("~/.vim/swap//")
-- vim.opt.directory:append("~/.vim/gibberish//")
-- vim.opt.directory:append(".")
