local pyutil = require("config.pyutil")
local Path = require("plenary.path")

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "htmldjango",
        "python",
        "requirements",
        "rst",
        "toml",
      })
    end,
  },

  {
    "neovim/nvim-lspconfig",
    init = function()
      require("lazyvim.util").lsp.on_attach(function(client, bufnr)
        local fname = vim.api.nvim_buf_get_name(bufnr)
        local project_root = pyutil.find_package_root(fname)
        if project_root then
          ---@type string?
          local new_folder = vim.fs.dirname(project_root)
          for _, ws_folder in ipairs(vim.lsp.buf.list_workspace_folders()) do
            if ws_folder == new_folder then
              new_folder = nil
              break
            end
          end
          if new_folder then
            vim.lsp.buf.add_workspace_folder(new_folder)
          end
        end

        vim.keymap.set("n", "<leader>cD", pyutil.pyright_toggle_diagnostic_mode, {
          desc = "Toggle Pyright diagnostic mode",
          buffer = true,
        })
      end, "pyright")
    end,
    ---@type PluginLspOpts
    opts = {
      servers = {
        pyright = {
          on_init = function(client)
            if client.root_dir then
              local extra_paths = {}
              local root = Path:new(client.root_dir)
              extra_paths[#extra_paths + 1] = tostring(root)

              local stubs = root / ".stubs"
              if stubs:exists() then
                extra_paths[#extra_paths + 1] = tostring(stubs)
              end

              pyutil.pyright_add_extra_paths(client, unpack(extra_paths))

              for _, candidate in ipairs({ "venv/pyvenv.cfg", ".venv/pyvenv.cfg" }) do
                local pyvenv = (root / candidate)
                if pyvenv:exists() then
                  local executable = pyvenv:parent() / "bin/python"
                  pyutil.pyright_set_python_path(client, tostring(executable))
                  break
                end
              end
            end
          end,
          commands = {
            PyrightAddExtraPath = {
              function(path)
                pyutil.pyright_add_extra_paths(nil, path)
              end,
              desc = "Add a directory to Pyright's `sys.path`",
              nargs = 1,
              complete = "dir",
            },
            PyrightToggleDiagnosticMode = {
              pyutil.pyright_toggle_diagnostic_mode,
              desc = "Toggle Pyright's diagnostic mode between 'workspace' and 'openFilesOnly'",
            },
          },
        },
      },
    },
  },
}
