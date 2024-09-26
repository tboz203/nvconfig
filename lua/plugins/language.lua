return {

  {
    "folke/lazydev.nvim",
    ft = "lua",
    dependencies = {
      {
        "hrsh7th/nvim-cmp",
        opts = function(_, opts)
          opts.sources = opts.sources or {}
          table.insert(opts.sources, { name = "lazydev" })
        end,
      },
    },
  },

  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.registries = {
        "lua:config.mason_registry",
        "github:mason-org/mason-registry",
      }
    end,
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      -- list active formatters when formatting
      format_notify = true,
    },
    init = function()
      -- disable the lsp info keybinding provided here; we define our own (conflicting) keybindings elsewhere
      local keys = require("lazyvim.plugins.lsp.keymaps").get()
      keys[#keys + 1] = { "<leader>cl", false }
    end,
  },

  -- ensure particular parsers are included by default
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
    --stylua: ignore
      vim.list_extend(opts.ensure_installed, {
        "bash", "cmake", "dockerfile", "git_config", "git_rebase",
        "gitattributes", "gitcommit", "gitignore", "ini", "java", "lua",
        "make", "markdown", "python", "ruby", "rust", "sql", "tsx",
        "typescript", "vim",
      })
    end,
  },

  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      -- attach some noop editorconfig property handlers, so that Neovim's
      -- editorconfig handling stores those properties in `b:editorconfig`,
      -- so that `shfmt_nvim` can calculate the correct args
      local ec_props = require("editorconfig").properties
      ec_props.binary_next_line = function() end
      ec_props.switch_case_indent = function() end
      ec_props.space_redirects = function() end
      ec_props.function_next_line = function() end

      opts.formatters_by_ft = vim.tbl_extend("force", opts.formatters_by_ft or {}, {
        python = { "ruff_organize_imports", "ruff_fix", "ruff_format" },
        sql = { "sql_formatter", "sqlfluff", "pg_format" },
        sh = { "shfmt_nvim" },
      })

      opts.formatters = vim.tbl_extend("force", opts.formatters or {}, {
        sleek = {
          command = "sleek",
        },
        sql_formatter = {
          prepend_args = { "-l", "postgresql" },
        },
        shfmt_nvim = {
          -- attempting to use shfmt to enforce in-editor settings
          command = "shfmt",
          args = function(_, ctx)
            local args = { "-filename", "$FILENAME" }

            if vim.bo[ctx.buf].expandtab then
              vim.list_extend(args, { "-i", ctx.shiftwidth })
            else
              vim.list_extend(args, { "-i", 0 })
            end

            local editorconfig = vim.b[ctx.buf].editorconfig or {}

            -- the defaults here use my personal taste. this one will default to false
            if editorconfig["binary_next_line"] == "true" then
              args[#args + 1] = "--binary-next-line"
            end

            -- the rest default to true
            if editorconfig["switch_case_indent"] ~= "false" then
              args[#args + 1] = "--case-indent"
            end

            if editorconfig["space_redirects"] ~= "false" then
              args[#args + 1] = "--space-redirects"
            end

            if editorconfig["space_redirects"] ~= "false" then
              args[#args + 1] = "--space-redirects"
            end

            return args
          end,
        },
      })
    end,
  },
}
