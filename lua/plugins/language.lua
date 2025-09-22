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
      inlay_hints = { enabled = false },
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

    -- getting nvim + treesitter to work in windows was a mess. the approach that finally worked was:
    --
    -- 1. putting `tree-sitter` (the cli) onto the path by hand (mason tries to "gunzip" a github release file using
    --    7z, which appears to use a stored filename rather than simply removing a '.gz' suffix)
    -- 2. manually invoking `tree-sitter init-config` to make it shut up about its useless missing config
    -- 3. installing msys2 + gcc, putting the appropriate path (`/c/msys64/ucrt64/`) onto the PATH, and setting
    --    `CC=gcc.exe CPP=g++.exe` before invoking nvim
    --
    -- > `tree-sitter build` seems to REALLY want to use `cl.exe`, but MSVC is a nonstarter for license reasons.
    -- > i'm pretty confident i've used `zig` somewhere as a replacement, but 1) getting the build to accept it was a
    -- > trial, and then 2) the resultant libraries seemed to have an ... unrecognized operating system?? idk

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
}
