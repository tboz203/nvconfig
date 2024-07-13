return {
  {
    "LazyVim/LazyVim",
    opts = {
      -- colorscheme = "tokyonight-night",
      colorscheme = "tokyonight-storm",
      -- colorscheme = "catppuccin-mocha",
    },
  },

  -- make these proactive so we can use them in the color preview selector
  { "catppuccin", lazy = false },
  { "folke/tokyonight.nvim", lazy = false },
  { "ellisonleao/gruvbox.nvim", lazy = false },
}
