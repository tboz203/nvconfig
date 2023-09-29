-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- the basics
vim.keymap.set({ "!", "v", "o" }, "jk", "<esc>", { remap = true })
vim.keymap.set("n", ";", ":")

-- the +reformat group
vim.keymap.set("n", "<leader>rt", "<cmd>retab!<cr>", { desc = "Retab file" })
vim.keymap.set("n", "<leader>rs", "<cmd>%s/\\s\\+$//e<cr>", { desc = "Remove trailing space" })
vim.keymap.set("n", "<leader>rn", "<cmd>%s/\\r$//e<cr>", { desc = "Remove spurious carriage returns" })
vim.keymap.set(  "n",  "<leader>rr",  "<cmd>retab!<cr><cmd>%s/\\s\\+$//e<cr><cmd>%s/\\r$//e<cr>",  { desc = "Retab, Re-space, Re-newline" })
-- vi-style format command
vim.keymap.set({ "n", "v" }, "Q", "gq", { desc = "Format text" })

-- alternate mappings for High / Middle / Low
vim.keymap.set("n", "<leader>H", "H", { desc = "Move cursor 'High'" })
vim.keymap.set("n", "<leader>M", "M", { desc = "Move cursor 'Middle'" })
vim.keymap.set("n", "<leader>L", "L", { desc = "Move cursor 'Low'" })

-- lsp debugging
vim.keymap.set("n", "<leader>cL", "<cmd>LspLog<cr>", { desc = "Lsp Log output" })

-- bufferline commands
vim.keymap.set("n", "<leader>bb", function() require("bufferline").pick() end, { desc = "Pick buffer" })
vim.keymap.set("n", "<leader>bx", function() require("bufferline").close_with_pick() end, { desc = "Pick buffer to close" })
