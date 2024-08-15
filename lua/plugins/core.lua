return {
  -- change trouble config
  {
    "folke/trouble.nvim",
    -- opts will be merged with the parent spec
    opts = { use_diagnostic_signs = true },
  },

  -- override nvim-cmp and add cmp-emoji
  {
    "hrsh7th/nvim-cmp",
    dependencies = { "hrsh7th/cmp-emoji" },
    opts = function(_, opts)
      table.insert(opts.sources, { name = "emoji" })
    end,
  },

  -- change some telescope options and a keymap to browse plugin files
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    keys = {
      -- add a keymap to browse plugin files
      {
        "<leader>fp",
        -- function() require("telescope.builtin").find_files({ cwd = require("lazy.core.config").options.root }) end,
        require("lazyvim.util").pick("find_files", { cwd = require("lazy.core.config").options.root }),
        desc = "Find Plugin File",
      },
      {
        "<leader>sp",
        -- function() require("telescope.builtin").live_grep({ cwd = require("lazy.core.config").options.root }) end,
        require("lazyvim.util").pick("live_grep", { cwd = require("lazy.core.config").options.root }),
        desc = "Grep Plugin Files",
      },
      {
        "gf",
        -- function() require("telescope.builtin").find_files({ search_file = vim.fn.expand("<cfile>") }) end,
        require("lazyvim.util").pick("find_files", { search_file = vim.fn.expand("<cfile>") }),
        desc = "Telescope to file",
      },
      {
        "<leader>fu",
        require("lazyvim.util").pick("find_files", { hidden = true, no_ignore = true, no_ignore_parent = true }),
        desc = "Find files unrestricted (root dir)",
      },
      {
        "<leader>fU",
        require("lazyvim.util").pick(
          "find_files",
          { hidden = true, no_ignore = true, no_ignore_parent = true, cwd = nil }
        ),
        desc = "Find files unrestricted (cwd)",
      },
      {
        "<leader>su",
        require("lazyvim.util").pick("live_grep", {
          vimgrep_arguments = vim.list_extend(
            vim.list_slice(require("telescope.config").values.vimgrep_arguments),
            { "-uu" }
          ),
        }),
        desc = "Grep unrestricted (root dir)",
      },
      {
        "<leader>sU",
        require("lazyvim.util").pick("live_grep", {
          vimgrep_arguments = vim.list_extend(
            vim.list_slice(require("telescope.config").values.vimgrep_arguments),
            { "-uu" }
          ),
          cwd = nil,
        }),
        desc = "Find files unrestricted (cwd)",
      },
    },
    -- change some options
    opts = {
      defaults = {
        layout_strategy = "horizontal",
        layout_config = { prompt_position = "top" },
        sorting_strategy = "ascending",
        winblend = 0,
      },
    },
  },
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
    config = function()
      require("telescope").load_extension("fzf")
    end,
  },

  { import = "lazyvim.plugins.extras.lang.typescript" },
  { import = "lazyvim.plugins.extras.lang.clangd" },
  { import = "lazyvim.plugins.extras.lang.ruby" },

  { import = "lazyvim.plugins.extras.ui.mini-starter" },
  { import = "lazyvim.plugins.extras.lang.json" },

  {
    "neovim/nvim-lspconfig",
    opts = {
      -- list active formatters when formatting
      format_notify = true,
      servers = {
        cucumber_language_server = {
          -- autostart = false,
          -- cmd = { "env", "NODENV_VERSION=16.19.0", "cucumber-language-server", "--stdio" },
        },
      },
    },
    init = function()
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
        "ini",
        "java",
        "make",
        "lua",
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

  { "williamboman/mason-lspconfig.nvim" },
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.registries = {
        -- "lua:config.mason_registry",
        "github:mason-org/mason-registry",
      }
      opts.ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      }
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        -- need to figure out a way to reliably install my own tree-sitter-cli
        -- package into cucumber's node_modules...
        "bash-language-server",
        -- "cucumber-language-server",
        "stylua",
        "shellcheck",
        "shfmt",
        "yq",
      })
    end,
  },

  -- Use <tab> for completion and snippets (supertab)
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-emoji",
    },
    opts = function(_, opts)
      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      local cmp = require("cmp")

      opts.mapping = vim.tbl_extend("force", opts.mapping, {
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif vim.snippet.active({ direction = 1 }) then
            vim.schedule(function()
              vim.snippet.jump(1)
            end)
          elseif has_words_before() then
            cmp.complete()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif vim.snippet.active({ direction = -1 }) then
            vim.schedule(function()
              vim.snippet.jump(-1)
            end)
          else
            fallback()
          end
        end, { "i", "s" }),
      })
    end,
  },

  { "tpope/vim-fugitive", lazy = false },
  { "tpope/vim-repeat", lazy = false },
  { "tpope/vim-sensible", lazy = false },
  { "tpope/vim-unimpaired", lazy = false },
  { "towolf/vim-helm", lazy = false },
  { "sheerun/vim-polyglot", lazy = false },
  { "godlygeek/tabular", lazy = false, version = "*" },

  { "s1n7ax/nvim-window-picker" },

  { import = "lazyvim.plugins.extras.lang.typescript" },

  { "echasnovski/mini.ai" },
  { "echasnovski/mini.align" },
  { "echasnovski/mini.pairs", cond = false },
  {
    "echasnovski/mini.surround",
    config = true,
    lazy = false,
  },

  {
    "stevearc/aerial.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      layout = {
        default_direction = "prefer_left",
        preserve_equality = true,
      },
    },
  },

  {
    "simnalamburt/vim-mundo",
    lazy = false,
    config = function()
      vim.g.mundo_right = 1
    end,
    --stylua: ignore
    keys = {
      { "<leader>uu", function() vim.cmd.MundoToggle() end, desc = "Toggle Undotree", },
    },
  },

  {
    "folke/flash.nvim",
    --stylua: ignore
    keys = {
      { "s", false},
      { "S", false},
      { "gs", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "gS", mode = { "n", "o", "x" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      -- { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      -- { "gR", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      -- { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
  },

  {
    "akinsho/bufferline.nvim",
    opts = {
      options = {
        always_show_bufferline = true,
      },
    },
    keys = {
      { "<leader>bb", "<cmd>BufferLinePick<cr>", desc = "Pick buffer" },
      { "<leader>bx", "<cmd>BufferLinePickClose<cr>", desc = "Close buffer with pick" },
      { "<leader>bh", "<cmd>BufferLineMovePrev<cr>", desc = "Move Buffer Left" },
      { "<leader>bl", "<cmd>BufferLineMoveNext<cr>", desc = "Move Buffer Right" },
      -- LazyVim defined `bl` and `br` to delete buffers left and right
      -- respectively; we're overriding one of those, and clearing the other
      { "<leader>br" },
    },
  },

  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function(_, opts)
      -- table.insert(opts.sections.lualine_x, "😄")
      table.remove(opts.sections.lualine_c)
      -- copied from lazyvim.util.lualine.pretty_path, with minor modifications
      table.insert(opts.sections.lualine_c, function()
        local Util = require("lazyvim.util")
        local path = vim.fn.expand("%:p") --[[@as string]]

        if path == "" then
          return ""
        end
        local root = Util.root.get({ normalize = true })
        local cwd = Util.root.cwd()

        if path:find(cwd, 1, true) == 1 then
          path = path:sub(#cwd + 2)
        else
          path = path:sub(#root + 2)
        end

        local sep = package.config:sub(1, 1)
        local parts = vim.split(path, "[\\/]")
        -- if #parts > 3 then
        --   parts = { parts[1], "…", parts[#parts - 1], parts[#parts] }
        -- end

        -- if vim.bo.modified then
        --   parts[#parts] = M.format(self, parts[#parts], "Constant")
        -- end

        return table.concat(parts, sep)
      end)
    end,
  },

  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        sql = { "sql_formatter", "sqlfluff", "pg_format" },
      },
      formatters = {
        sleek = {
          command = "sleek",
        },
        sql_formatter = {
          prepend_args = { "-l", "postgresql" },
        },
      },
    },
  },
}
