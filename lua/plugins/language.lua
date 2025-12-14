return {

  {
    "neovim/nvim-lspconfig",
    opts = {
      -- list active formatters when formatting
      format_notify = true,
      inlay_hints = { enabled = false },
    },
    keys = {
      { "<leader>cl", false },
    },
  },

  -- ensure particular parsers are included by default
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = vim.list_extend(opts.ensure_installed or {}, {
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
        sh = { "shfmt_nvim" },
        go = { lsp_format = "prefer" },
        -- sql = { "pg_format", "sqlfluff" },
        sql = {},
      },

      formatters = {
        sqlfluff = {
          args = { "fix", "--dialect=postgres", "-" },
          stdin = true,
          cwd = require("conform.util").root_file({
            ".sqlfluff",
            "flyway.conf",
            "pep8.ini",
            "pyproject.toml",
            "setup.cfg",
            "tox.ini",
            ".git",
          }),
          require_cwd = false,
          -- only use this formatter when a `.sqlfluff` file is found
          condition = function(ctx)
            return vim.fs.find({ ".sqlfluff" }, { path = ctx.filename, upward = true })
          end,
        },
        pg_format = {
          -- only use this formatter when a `.sqlfluff` file is found
          condition = function(ctx)
            return vim.fs.find({ ".sqlfluff" }, { path = ctx.filename, upward = true })
          end,
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
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gopls = {
          settings = {
            gopls = {
              analyses = {
                -- Incorrect or missing package comment
                ST1000 = false,
                -- Dot imports are discouraged
                ST1001 = false,
                -- Poorly chosen identifier
                ST1003 = false,
              },
            },
          },
        },
        lemminx = {
          cmd = {
            "lemminx",
            "-Djavax.net.ssl.trustStore=/home/linuxbrew/.linuxbrew/Cellar/openjdk/24.0.2/libexec/lib/security/cacerts",
          },
          -- settings = {
          --   xml = {
          --     server = {
          --       vmargs = {
          --         "-Djavax.net.ssl.trustStore=/home/linuxbrew/.linuxbrew/Cellar/openjdk/24.0.2/libexec/lib/security/cacerts",
          --       },
          --     },
          --     -- format = {
          --     --   -- enabled = false,
          --     --   -- splitAttributes = true,
          --     --   -- joinCDATALines = false,
          --     --   -- joinCommentLines = false,
          --     --   -- formatComments = false,
          --     --   -- joinContentLines = false,
          --     --   -- spaceBeforeEmptyCloseTag = false,
          --     -- },
          --   },
          -- },
        },
      },
    },
  },

  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        sql = {},
      },
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

  { "lark-parser/vim-lark-syntax" },

  {
    "nvim-mini/mini.pairs",
    optional = true,
    lazy = false,
    opts = function()
      vim.api.nvim_create_autocmd("BufRead", {
        pattern = "*.rs",
        callback = function()
          vim.keymap.set("i", "'", "'", { buffer = true })
        end,
      })
    end,
  },
}
