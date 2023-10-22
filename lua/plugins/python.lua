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

return {
  { import = "lazyvim.plugins.extras.lang.python" },
  { import = "lazyvim.plugins.extras.lang.python-semshi" },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- add tsx and treesitter
      vim.list_extend(opts.ensure_installed, {
        "htmldjango",
        "ninja",
        "python",
        "requirements",
        "rst",
        "toml",
      })
    end,
  },

  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      opts.servers.ruff_lsp = {
        -- autostart = false,
        root_dir = pyutil.find_root_dir,
        init_options = {
          settings = {
            args = {
              "--line-length=119",
            },
          },
        },
      }
      opts.servers.pyright = {
        -- autostart = false,
        root_dir = pyutil.find_root_dir,
        settings = {
          -- pyright = {
          --   disableLanguageServices = true,
          -- },
          python = {
            analysis = {
              -- diagnosticMode = "workspace",
              diagnosticMode = "openFilesOnly",
              typeCheckingMode = "basic",
            },
          },
        },
      }
      opts.servers.pylsp = {
        -- need to come up with mechanism to install pip dependencies
        -- into pylsp venv
        -- * pyls-isort,
        -- * pylsp-rope,
        -- * python-lsp-black,

        autostart = false,
        -- cmd = { 'pylsp', '-vv' },
        root_dir = pyutil.find_root_dir,
        settings = {
          pylsp = {
            plugins = {
              autopep8 = { enabled = false },
              flake8 = { enabled = false },
              -- mccabe = { enabled = false },
              pycodestyle = { enabled = false },
              pydocstyle = { enabled = false },
              pyflakes = { enabled = false },
              pylint = { enabled = false },
              yapf = { enabled = false },
              black = {
                enabled = true,
                cache_config = true,
              },
              jedi_completion = {
                include_params = true,
                include_class_objects = true,
                include_function_objects = true,
                fuzzy = true,
                -- eager = true,
              },
              jedi_hover = { enabled = false },
              -- mypy = {
              --   -- okay, so trying to use mypy from within pylsp the way
              --   -- we've been using it on the command line (with
              --   -- django-stubs, which imports our settings module, which
              --   -- imports other 3rd-party packages) will require getting
              --   -- both the LSP site-packages & our project site-packages
              --   -- into mypy's PYTHONPATH. which is a hassle...
              --   report_progress = true,
              -- },
            },
          },
        },
      }
      -- opts.servers.cucumber_language_server = {
      --   settings = {
      --     cucumber = {
      --       features = { "features/*.feature" },
      --       glue = { "features/steps/**/*.py" },
      --     },
      --   },
      -- },
      return opts
    end,
  },

  {
    "mfussenegger/nvim-dap",
    config = function() end,
    dependencies = {
      {
        "williamboman/mason.nvim",
        opts = function(_, opts)
          opts.ensure_installed = opts.ensure_installed or {}
          table.insert(opts.ensure_installed, "debugpy")
        end,
      },
    },
  },

  -- {
  --   "linux-cultist/venv-selector.nvim",
  --   cmd = "VenvSelect",
  --   opts = function()
  --     return {
  --       name = {
  --         "venv",
  --         ".venv",
  --       },
  --       -- search = false,
  --       auto_refresh = true,
  --       parents = 0,
  --     }
  --   end,
  --   keys = {
  --     { "<leader>cv", "<cmd>:VenvSelect<cr>", desc = "Select VirtualEnv" },
  --     { "<leader>cV", "<cmd>:VenvSelectCached<cr>", desc = "Select Cached VirtualEnv" },
  --   },
  -- },

  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = vim.tbl_deep_extend("force", opts.formatters_by_ft or {}, {
        python = { "isort", "black" },
      })
    end,
  },
}
