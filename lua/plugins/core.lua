-- if true then
--   return {}
-- end

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
        -- mappings = {
        --   i = {
        --     -- was looking for "allow editing ripgrep command";
        --     -- got "put current highlighted line into vim cmd window"
        --     ["<C-f>"] = "edit_command_line",
        --   },
        --   n = {
        --     ["<C-f>"] = "edit_command_line",
        --   },
        -- },
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
  -- {
  --   "debugloop/telescope-undo.nvim",
  --   keys = {
  --     { "<leader>uu", "<cmd>Telescope undo<cr>", desc = "Telescope undo" },
  --   },
  --   config = function()
  --     require("telescope").load_extension("undo")
  --   end,
  -- },

  -- add tsserver and setup with typescript.nvim instead of lspconfig
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "jose-elias-alvarez/typescript.nvim",
      init = function()
        require("lazyvim.util").lsp.on_attach(function(_, buffer)
          -- stylua: ignore
          vim.keymap.set( "n", "<leader>co", "TypescriptOrganizeImports", { buffer = buffer, desc = "Organize Imports" })
          vim.keymap.set("n", "<leader>cR", "TypescriptRenameFile", { desc = "Rename File", buffer = buffer })
        end)
      end,
    },
    opts = {
      -- autoformat = false,
      -- list active formatters when formatting
      format_notify = true,
      servers = {
        -- tsserver will be automatically installed with mason and loaded with lspconfig
        tsserver = {},
        cucumber_language_server = {
          autostart = false,
          cmd = { "env", "NODENV_VERSION=16.19.0", "cucumber-language-server", "--stdio" },
        },
      },
      -- you can do any additional lsp server setup here
      -- return true if you don't want this server to be setup with lspconfig
      setup = {
        -- example to setup with typescript.nvim
        tsserver = function(_, opts)
          require("typescript").setup({ server = opts })
          return true
        end,
        -- Specify * to use this function as a fallback for any server
        -- ["*"] = function(server, opts) end,
      },
    },
    init = function()
      local keys = require("lazyvim.plugins.lsp.keymaps").get()
      keys[#keys + 1] = { "<leader>cl", false }
    end,
  },

  -- for typescript, LazyVim also includes extra specs to properly setup lspconfig,
  -- treesitter, mason and typescript.nvim. So instead of the above, you can use:
  { import = "lazyvim.plugins.extras.lang.typescript" },

  { import = "lazyvim.plugins.extras.lang.clangd" },

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

  -- use mini.starter instead of alpha
  { import = "lazyvim.plugins.extras.ui.mini-starter" },

  -- add jsonls and schemastore packages, and setup treesitter for json, json5 and jsonc
  { import = "lazyvim.plugins.extras.lang.json" },

  -- add any tools you want to have installed below
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.registries = {
        "lua:config.mason_registry",
        "github:mason-org/mason-registry",
      }
      -- opts.providers = {
      --   -- prefer local tooling
      --   "mason.providers.client",
      --   "mason.providers.registry-api",
      -- }
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
        "cucumber-language-server",
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

  { "s1n7ax/nvim-window-picker" },

  { import = "lazyvim.plugins.extras.lang.typescript" },

  -- { "echasnovski/mini.nvim" },
  { "echasnovski/mini.ai" },
  { "echasnovski/mini.align" },
  { "echasnovski/mini.pairs", cond = false },
  {
    "echasnovski/mini.surround",
    config = true,
    lazy = false,
    -- keys = { "sa", "sd", "sf", "sF", "sh", "sr", "sn" },
  },
  -- { "echasnovski/mini.animate", cond = false },

  -- {
  --   "folke/which-key.nvim",
  --   cond = false,
  --   event = "VeryLazy",
  -- },

  {
    "stevearc/aerial.nvim",
    -- cond = false,
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
      -- {
      --   "folke/trouble.nvim",
      --   optional = true,
      --   keys = {
      --     { "<leader>cs", false },
      --   },
      -- },
    },
    keys = {
      {
        "<leader>cs",
        function()
          require("aerial").toggle()
          -- vim.cmd.wincmd("=")
        end,
        desc = "Toggle Aerial",
      },
    },
    opts = {
      layout = {
        default_direction = "prefer_left",
        preserve_equality = true,
      },
      -- backends = { "treesitter", "lsp" },
      -- filter_kind = false,
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

  -- { import = "lazyvim.plugins.extras.editor.leap" },

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

  -- {
  --   "nvim-neo-tree/neo-tree.nvim",
  --   opts = {
  --     close_if_last_window = true,
  --   },
  -- },

  -- { "<leader>cl", false },

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
    -- opts = function(_, opts)
    --   opts.formatters_by_ft = vim.tbl_deep_extend("force", opts.formatters_by_ft or {}, {
    --     python = { "isort", "black" },
    --   })
    -- end,
    opts = {
      formatters_by_ft = {
        -- sql = { "sleek" },
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
