-- if true then
--   return {
--     {
--       "nvim-treesitter/nvim-treesitter",
--       optional = true,
--       opts = function(_, opts)
--         -- turn this *all* the way off
--         opts.ensure_installed = {}
--       end,
--     },
--   }
-- end

return {

  {
    "neovim/nvim-lspconfig",
    opts = {
      -- list active formatters when formatting
      format_notify = true,
      -- servers = {
      --   cucumber_language_server = {},
      -- },
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
      vim.list_extend(opts.ensure_installed, {
        "bash",
        "cmake",
        "dockerfile",
        "git_config",
        "git_rebase",
        "gitattributes",
        "gitcommit",
        "gitignore",
        "go",
        "ini",
        "java",
        "jq",
        "lua",
        "make",
        "markdown",
        "python",
        "ruby",
        "rust",
        "sql",
        "tsx",
        "typescript",
        "vim",
      })
    end,
  },

  {
    "stevearc/conform.nvim",
    opts = function()
      -- attach some noop editorconfig property handlers, so that Neovim's
      -- editorconfig handling stores those properties in `b:editorconfig`,
      -- so that `shfmt_nvim` can calculate the correct args
      local ec_props = require("editorconfig").properties
      ec_props.binary_next_line = function() end
      ec_props.switch_case_indent = function() end
      ec_props.space_redirects = function() end
      ec_props.function_next_line = function() end
    end,
  },

  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        python = { "ruff_fix_most", "ruff_format" },
        sh = { "shfmt_nvim" },
      },

      formatters = {
        sqlfluff = {
          command = "/home/linuxbrew/.linuxbrew/bin/sqlfluff",
          args = { "fix", "-" },
          stdin = true,
          cwd = require("conform.util").root_file({
            ".sqlfluff",
            "pep8.ini",
            "pyproject.toml",
            "setup.cfg",
            "tox.ini",
          }),
          require_cwd = true,
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
        ruff_fix_most = {
          command = "ruff",
          args = {
            "check",
            "--fix",
            "--force-exclude",
            "--select=F,E,I",
            "--ignore=F401",
            "--exit-zero",
            "--no-cache",
            "--stdin-filename",
            "$FILENAME",
            "-",
          },
          stdin = true,
          cwd = require("conform.util").root_file({
            "pyproject.toml",
            "ruff.toml",
            ".ruff.toml",
          }),
        },
      },
    },
  },

  -- {
  --   "neovim/nvim-lspconfig",
  --   opts = {
  --     servers = {
  --       spectral = {
  --         -- find a spectral ruleset file & tell spectral-language-server about it
  --         ---@param params lsp.InitializedParams
  --         ---@param config vim.lsp.ClientConfig
  --         before_init = function(params, config)
  --           local util = require("config.util")
  --           local ruleset_path, item_path
  --           for _, item in ipairs({ config.root_dir, config.cmd_cwd, "." }) do
  --             if item ~= nil then
  --               item_path = util.Path:new(item)
  --               ruleset_path =
  --                 item_path:find_any_upwards(".spectral.yaml", ".spectral.yml", ".spectral.json", ".spectral.js")
  --               if ruleset_path ~= nil then
  --                 config.settings = config.settings or {}
  --                 config.settings.rulesetFile = config.settings.rulesetFile or tostring(ruleset_path)
  --                 vim.notify(
  --                   string.format("Spectral ruleset file is `%s`", config.settings.rulesetFile),
  --                   vim.log.levels.INFO
  --                 )
  --                 return
  --               end
  --             end
  --           end
  --           vim.notify("No Spectral ruleset file found", vim.log.levels.INFO)
  --         end,
  --       },
  --     },
  --   },
  -- },

  {
    "mfussenegger/nvim-lint",
    opts = {
      linters = {
        sqlfluff = {
          cmd = "sqlfluff",
          args = {
            "lint",
            "--format=json",
          },
        },
      },
    },
  },
}
