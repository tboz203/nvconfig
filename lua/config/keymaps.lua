-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local util = require("config.util")

-- the basics
vim.keymap.set({ "!", "o" }, "jk", "<esc>", { remap = true })
vim.keymap.set({ "!", "o" }, "jK", "<esc>", { remap = true })
vim.keymap.set({ "!", "o" }, "Jk", "<esc>", { remap = true })
vim.keymap.set({ "!", "o" }, "JK", "<esc>", { remap = true })

vim.keymap.set("", ";", ":")

vim.keymap.set("", "<leader>uL", "<cmd>set list!<cr>", { desc = "Toggle list characters" })

-- the +reformat group
-- stylua: ignore start
vim.keymap.set("n", "<leader>r", "", { desc = "+refactor/reformat" })
vim.keymap.set("n", "<leader>rt", "<cmd>retab!<cr>", { desc = "Retab buffer" })
vim.keymap.set("n", "<leader>rs", "<cmd>luado return line:gsub('%s+$', '')<cr>", { desc = "Remove trailing space in buffer" })
vim.keymap.set("n", "<leader>rr", "<cmd>retab! | luado return line:gsub('%s+$', '')<cr>", { desc = "Retab and Re-space buffer" })
-- stylua: ignore end

-- vi-style format command
vim.keymap.set({ "", "v" }, "Q", "gq", { desc = "Format text" })

-- the builtin keymaps 'H' and 'L' for moving the cursor "high" and "low" are
-- overwritten in LazyVim for switching between buffers. to replace them, we
-- add these, which shadow the notionally similar zz, zt, and zb keymaps
vim.keymap.set("", "zT", "H", { desc = "Move cursor 'Top'" })
vim.keymap.set("", "zZ", "M", { desc = "Move cursor center" })
vim.keymap.set("", "zB", "L", { desc = "Move cursor 'Bottom'" })

-- toggle diagnostics (for LSP, etc)
vim.keymap.set("", "<leader>ud", util.toggle_current_buffer_diagnostics, { desc = "Toggle Diagnostics in Buffer" })
vim.keymap.set("", "<leader>uD", util.toggle_global_diagnostics, { desc = "Toggle Diagnostics Globally" })
