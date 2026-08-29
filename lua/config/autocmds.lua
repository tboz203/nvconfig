-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua

-- set diagnostics state for buffer from global for new buffers
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    require("config.util").update_current_buffer_diagnostics()
  end,
})

local function augroup(name, autocmds)
  local group = vim.api.nvim_create_augroup(name, { clear = true })
  for _, autocmd in pairs(autocmds) do
    autocmd[2]["group"] = group
    vim.api.nvim_create_autocmd(autocmd[1], autocmd[2])
  end
end
