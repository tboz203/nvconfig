-- if true then return {} end

return {
  { "tpope/vim-fugitive" },
  { "tpope/vim-repeat" },
  { "tpope/vim-sensible" },
  { "tpope/vim-sleuth" },
  { "tpope/vim-unimpaired" },

  { "s1n7ax/nvim-window-picker" },

  { "godlygeek/tabular", cmd = "Tabularize", version = "*" },

  -- disabling b/c it seems to be fighting with vim-sleuth
  { "sheerun/vim-polyglot", cond = false },

  { "towolf/vim-helm", ft = "helm", cond = "false" },

  -- { "nvim-mini/mini.nvim", cond = false },
  -- { "nvim-mini/mini.ai", cond = false },
  -- { "nvim-mini/mini.align", cond = false },
  -- { "nvim-mini/mini.pairs", cond = false },
  -- { "nvim-mini/mini.surround", cond = false },
  -- { "nvim-mini/mini.animate", cond = false },
}
