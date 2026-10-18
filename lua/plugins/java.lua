if false then
  require("lazy").plugins()
end

---@type LazyPluginSpec[]
return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        -- java = { "google-java-format" },
      },
    },
  },

  {
    "mfussenegger/nvim-jdtls",
    opts = function(_, opts)
      return require("lazy.util").merge(opts, {
        jdtls = {
          something = "holy freakin cow what is going on",
          init_options = {
            settings = {
              java = {
                sources = {
                  organizeImports = {
                    starThreshold = 6,
                    staticStarThreshold = 6,
                  },
                },
              },
            },
          },
        },
      })
    end,
  },
}
