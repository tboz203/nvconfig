local pyutil = require("config.pyutil")

return {
  { import = "lazyvim.plugins.extras.lang.python" },

  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "black",
        "isort",
      })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
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
        root_dir = pyutil.find_root_dir,
        settings = {
          python = {
            analysis = {
              -- diagnosticMode = "workspace",
              diagnosticMode = "openFilesOnly",
              typeCheckingMode = "basic",
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

  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = vim.tbl_deep_extend("force", opts.formatters_by_ft or {}, {
        -- python = { "isort", "black" },
        python = { "ruff_fix", "ruff_format" },
      })

      opts.formatters = vim.tbl_deep_extend("force", opts.formatters or {}, {
        black = {
          prepend_args = { "-l", "119" },
        },
        isort = {
          prepend_args = { "-l", "119", "--profile", "black" },
        },
        ruff_fix = {
          append_args = { "--config", "line-length = 119" },
        },
        ruff_format = {
          append_args = { "--config", "line-length = 119" },
        },
      })
    end,
  },
}
