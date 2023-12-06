local util = require("config.util")
local pyutil = require("config.pyutil")

vim.api.nvim_create_user_command("LspAddExtraPath", function(opts)
  local path = opts.fargs[1]
  for _, client in ipairs(vim.lsp.get_active_clients()) do
    if client.name == "pyright" then
      local extra_paths = util.lookup(client.config.settings, "python", "analysis", "extraPaths") or {}
      table.insert(extra_paths, path)
      client.config.settings = vim.tbl_deep_extend("force", client.config.settings, {
        python = {
          analysis = {
            extraPaths = extra_paths,
          },
        },
      })
      client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
    elseif client.name == "pylsp" then
      local extra_paths = util.lookup(client.config.settings, "pylsp", "plugins", "jedi", "extra_paths") or {}
      table.insert(extra_paths, path)
      client.config.settings = vim.tbl_deep_extend("force", client.config.settings, {
        pylsp = {
          plugins = {
            jedi = {
              extra_paths = extra_paths,
            },
          },
        },
      })
      client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
    end
  end
end, {
  nargs = 1,
  complete = "dir",
})

require("lazyvim.util").lsp.on_attach(function(client, bufnr)
  pyutil.set_client_venv_paths(client, bufnr)

  -- add a mapping to toggle pyright diagnostic mode
  if client.name == "pyright" then
    vim.keymap.set("n", "<leader>cD", pyutil.toggle_pyright_diagnostic_mode, {
      desc = "Toggle Pyright diagnostic mode",
      buffer = true,
    })
  end
end)

-- vim.cmd([[
--     " tweaks to indenting
--     set indentkeys-=<:>
--     set indentkeys+=:
-- ]])
