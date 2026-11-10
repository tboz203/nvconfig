-- modifying the "find references" keybinding to exclude /src/test when the current buffer is in /src/main/
local find_references_skip_test = function()
  local exclude_test_files = vim.api.nvim_buf_get_name(0):match("/src/main/")
  local filter = nil
  if exclude_test_files then
    filter = function(item)
      return not item.file:match("/src/test")
    end
  end
  Snacks.picker.lsp_references({
    filter = {
      filter = filter,
    },
  })
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
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        jdtls = {
          keys = {
            { "gr", find_references_skip_test, nowait = true, desc = "References" },
          },
        },
      },
    },
  },

  {
    "mfussenegger/nvim-jdtls",
    opts = function(_, opts)
      return require("lazy.util").merge(opts, {
        jdtls = {
          init_options = {
            settings = {
              java = {
                sources = {
                  organizeImports = {
                    starThreshold = 6,
                    staticStarThreshold = 6,
                  },
                },
                maven = {
                  profiles = {
                    vim.g.jdtls_maven_profile
                  }
                }
              },
            },
          },
        },
      })
    end,
  },
}
