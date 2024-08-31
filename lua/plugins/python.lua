local pyutil = require("config.pyutil")

return {
  { import = "lazyvim.plugins.extras.lang.python" },
  { import = "lazyvim.plugins.extras.dap" },

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
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      -- opts.servers.ruff = {
      --   root_dir = pyutil.find_root_dir,
      --   init_options = {
      --     settings = {
      --       args = {
      --         "--line-length=119",
      --       },
      --     },
      --   },
      -- }
      -- opts.servers.pyright = {
      --   root_dir = pyutil.find_root_dir,
      --   settings = {
      --     python = {
      --       analysis = {
      --         diagnosticMode = "openFilesOnly",
      --         typeCheckingMode = "basic",
      --       },
      --     },
      --   },
      -- }
      opts.servers.pylsp = {
        autostart = false,
      }
      return opts
    end,
  },
}
