-- if true then
--   return {}
-- end

-- attach some noop editorconfig property handlers, so that Neovim's
-- editorconfig handling stores those properties in `b:editorconfig`,
-- so that `shfmt-nvim` can calculate the correct args
local ec_props = require("editorconfig").properties
ec_props.binary_next_line = function() end
ec_props.switch_case_indent = function() end
ec_props.space_redirects = function() end
ec_props.function_next_line = function() end

--- Helper function to parse options to into a parser if available
---@param self conform.JobFormatterConfig
---@param ctx conform.Context|conform.RangeContext
---@return string[]|nil args the arguments for setting a `prettier` parser if they exist in the options, nil otherwise
local function eval_parser(self, ctx)
  local ft = vim.bo[ctx.buf].filetype
  local ext = vim.fn.fnamemodify(ctx.filename, ":e")
  local options = self.options
  local parser = options
    and ((options.ft_parsers and options.ft_parsers[ft]) or (options.ext_parsers and options.ext_parsers[ext]))
  if parser then
    return { "--parser", parser }
  end
end

return {

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
    opts = {
      formatters_by_ft = {
        sh = { "shfmt-nvim" },
        go = { lsp_format = "prefer" },
        -- sql = { "pg_format", "sqlfluff" },
        -- sql = {},
        sql = { "pg_format" },
        -- java = { "google-java-format" },
        javascript = { "prettier" },
      },

      ---@type {[string]: conform.JobFormatterConfig | {} }
      formatters = {
        sqlfluff = {
          args = { "format", "-", "--stdin-filename", "$FILENAME" },
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
          condition = function(_, ctx)
            return vim.tbl_isempty(vim.fs.find({ ".sqlfluff" }, { path = ctx.filename, upward = true }))
          end,
        },
        ["sqlfluff-ansi"] = {
          inherit = "sqlfluff",
          append_args = { "--dialect=ansi" },
          condition = nil,
        },
        ["sqlfluff-postgres"] = {
          inherit = "sqlfluff",
          append_args = { "--dialect=postgres" },
          condition = nil,
        },
        -- pg_format = {
        --   -- only use this formatter when a `.sqlfluff` file is found
        --   condition = function(ctx)
        --     return vim.fs.find({ ".sqlfluff" }, { path = ctx.filename, upward = true })
        --   end,
        -- },
        ["shfmt-nvim"] = {
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
        prettier = {
          options = {
            ft_parsers = {
              javascript = "babel",
              javascriptreact = "babel",
              typescript = "typescript",
              typescriptreact = "typescript",
              vue = "vue",
              css = "css",
              scss = "scss",
              less = "less",
              html = "html",
              json = "json",
              jsonc = "json",
              yaml = "yaml",
              markdown = "markdown",
              ["markdown.mdx"] = "mdx",
              graphql = "graphql",
              handlebars = "glimmer",
            },
          },
        },
        ["prettier-html"] = {
          inherit = "prettier",
          -- args = { "--parser", "html" },
          -- command = function(self, ctx)
          --   vim.notify(vim.inspect({ "here's that command stuff", self = self, ctx = ctx }), vim.log.levels.INFO)
          --   return "prettier"
          -- end,
          args = function(self, ctx)
            vim.notify(vim.inspect({ "here's that args stuff", self = self, ctx = ctx }), vim.log.levels.INFO)
            return vim.list_extend(
              eval_parser(self, ctx) or { "--stdin-filepath", "$FILENAME" },
              { "--parser", "html" }
            )
          end,
          range_args = function(self, ctx)
            local start_offset, end_offset = require("conform.util").get_offsets_from_range(ctx.buf, ctx.range)
            local args = eval_parser(self, ctx) or { "--stdin-filepath", "$FILENAME" }
            return vim.list_extend(
              args,
              { "--parser", "html", "--range-start=" .. start_offset, "--range-end=" .. end_offset }
            )
          end,
          -- options = {
          --   parser = "html",
          -- },
          -- cmd = { "prettier", "--parser", "html" },
          -- condition = nil,
        },
      },
    },
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      -- list active formatters when formatting
      format_notify = true,
      inlay_hints = { enabled = false },
      servers = {
        terraformls = {
          mason = false, -- not natively understood by lspconfig; picked up by mason-lspconfig
          settings = {
            terraform = {
              path = "tofu",
            },
          },
        },
        gopls = {
          mason = false,
          settings = {
            gopls = {
              analyses = {
                -- "Incorrect or missing package comment"
                ST1000 = false,
                -- "Dot imports are discouraged"
                ST1001 = false,
                -- "Poorly chosen identifier"
                ST1003 = false,
              },
            },
          },
        },
        lemminx = {
          -- mason = false,
          cmd = { "lemminx", "-Djavax.net.ssl.trustStore=/etc/ssl/certs/java/cacerts" },
          settings = {
            xml = {
              -- trace = {
              --   server = "verbose",
              --   client = "verbose",
              -- },
              -- logs = {
              --   client = true,
              --   file = "/home/thomaswbozeman/lemminx.log",
              -- },
              format = {
                -- enabled = false,
                -- enabled = true,
                -- maxLineWidth = 119,
                -- gibberish = "gibberish",
                -- splitAttributes = "gibberish",
                -- joinCDATALines = false,
                -- joinCommentLines = false,
                -- formatComments = false,
                -- joinContentLines = false,
                -- spaceBeforeEmptyCloseTag = true,
              },
              -- validation = {
              --   noGrammar = "hint",
              --   enabled = true,
              --   schema = true,
              -- },
            },
          },
        },
      },
    },
  },

  {
    "neovim/nvim-lspconfig",
    -- when lspconfig is loaded, create a user command to view LSP logs
    opts = function()
      vim.api.nvim_create_user_command("LspLogs", function()
        vim.cmd.edit(vim.fn.stdpath("state") .. "/lsp.log")
        vim.opt_local.buftype = "nowrite"
        vim.opt_local.swapfile = false
      end, { desc = "View LSP Logs" })
    end,
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
          args = { "lint", "--format=json" },
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

  {
    "mfussenegger/nvim-dap",
    optional = true,
    opts = function()
      -- Simple configuration to attach to remote java debug process
      -- Taken directly from https://github.com/mfussenegger/nvim-dap/wiki/Java
      local dap = require("dap")
      dap.configurations.java = {
        {
          type = "java",
          request = "attach",
          name = "Debug (Attach) - Remote",
          hostName = "127.0.0.1",
          -- port = 5005,
          port = 8787,
        },
      }
    end,
  },
}
