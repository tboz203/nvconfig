return {
  { import = "lazyvim.plugins.extras.lang.ruby" },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        solargraph = {
          cmd = { "bundle", "exec", "solargraph", "stdio" },
        },
      },
    },
  },
}
