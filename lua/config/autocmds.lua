-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua

-- set diagnostics state for buffer from global for new buffers
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    require("config.util").update_current_buffer_diagnostics()
  end,
})
