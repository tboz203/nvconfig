-- if true then return {} end

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
        local package_root = pyutil.find_package_root(fname)
        if package_root then
          local package_parent = vim.fs.dirname(package_root)
          require("config.util").lsp_client_add_workspace_folder(client, package_parent)
          pyutil.pyright_add_extra_paths(client, package_parent)
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
        ruff = {
          init_options = {
            settings = {
              lineLength = 119,
              logLevel = "debug",
            },
          },
          commands = {
            RuffChangeSetting = {
              pyutil.ruff_change_setting,
              desc = "Change a setting for the Ruff language server",
              nargs = "+",
            },
          },
        },
        pyright = {
          on_init = function(client)
            if client.root_dir then
              local extra_paths = {}
              local root = Path:new(client.root_dir)
              -- ensure project root is in our package import search path
              extra_paths[#extra_paths + 1] = tostring(root)

              -- and our stubs directory, if it exists
              local stubs = root / ".stubs"
              if stubs:exists() then
                extra_paths[#extra_paths + 1] = tostring(stubs)
              end

              pyutil.pyright_add_extra_paths(client, unpack(extra_paths))

              -- set pyright's python path to a venv executable if we find one
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
