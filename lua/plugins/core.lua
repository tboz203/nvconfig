-- if true then return {} end

return {

  {
    "LazyVim/LazyVim",
    keys = {
      -- clear the LspInfo keymap, using it as a prefix for lsp mappings in config.keymaps
      -- (this still isn't working quite right 😢)
      { "<leader>cl" },
    },
  },
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
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      local cmp = require("cmp")
      opts.sources = cmp.config.sources(vim.list_extend(opts.sources, { { name = "emoji" } }))
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
        require("lazyvim.util").telescope("find_files", { cwd = require("lazy.core.config").options.root }),
        desc = "Find Plugin File",
      },
      {
        "<leader>sp",
        -- function() require("telescope.builtin").live_grep({ cwd = require("lazy.core.config").options.root }) end,
        require("lazyvim.util").telescope("live_grep", { cwd = require("lazy.core.config").options.root }),
        desc = "Grep Plugin Files",
      },
      {
        "gf",
        -- function() require("telescope.builtin").find_files({ search_file = vim.fn.expand("<cfile>") }) end,
        require("lazyvim.util").telescope("find_files", { search_file = vim.fn.expand("<cfile>") }),
        desc = "Telescope to file",
      },
      {
        "<leader>fu",
        require("lazyvim.util").telescope("find_files", { hidden = true, no_ignore = true, no_ignore_parent = true }),
        desc = "Find files unrestricted (root dir)",
      },
      {
        "<leader>fU",
        require("lazyvim.util").telescope(
          "find_files",
          { hidden = true, no_ignore = true, no_ignore_parent = true, cwd = false }
        ),
        desc = "Find files unrestricted (cwd)",
      },
      {
        "<leader>su",
        require("lazyvim.util").telescope("live_grep", {
          vimgrep_arguments = vim.list_extend(
            vim.list_slice(require("telescope.config").values.vimgrep_arguments),
            { "-uu" }
          ),
        }),
        desc = "Grep unrestricted (root dir)",
      },
      {
        "<leader>sU",
        require("lazyvim.util").telescope("live_grep", {
          vimgrep_arguments = vim.list_extend(
            vim.list_slice(require("telescope.config").values.vimgrep_arguments),
            { "-uu" }
          ),
          cwd = false,
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
          vim.keymap.set("n", "<leader>co", "TypescriptOrganizeImports", { buffer = buffer, desc = "Organize Imports" })
          vim.keymap.set("n", "<leader>cR", "TypescriptRenameFile", { desc = "Rename File", buffer = buffer })
        end)
      end,
    },
    ---@class PluginLspOpts
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
      ---@type table<string, fun(server:string, opts:_.lspconfig.options):boolean?>
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
        "cucumber-language-server",
        "stylua",
        "shellcheck",
        "shfmt",
        "yq",
      })
    end,
  },

  -- Use <tab> for completion and snippets (supertab)
  -- first: disable default <tab> and <s-tab> behavior in LuaSnip
  {
    "L3MON4D3/LuaSnip",
    keys = function()
      return {}
    end,
  },
  -- then: setup supertab in cmp
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-emoji",
    },
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      local luasnip = require("luasnip")
      local cmp = require("cmp")

      opts.mapping = vim.tbl_extend("force", opts.mapping, {
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
            -- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
            -- this way you will only jump inside the snippet region
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          elseif has_words_before() then
            cmp.complete()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
      })
    end,
  },

  { "tpope/vim-fugitive" },
  { "tpope/vim-repeat" },
  { "tpope/vim-sensible" },
  { "tpope/vim-unimpaired" },
  { "towolf/vim-helm" },
  { "sheerun/vim-polyglot" },

  { "s1n7ax/nvim-window-picker" },

  {
    "folke/which-key.nvim",
    -- enabled = false,
    event = "VeryLazy",
  },

  {
    "stevearc/aerial.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
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

  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      close_if_last_window = true,
    },
  },

  { import = "lazyvim.plugins.extras.lang.ruby" },
  { import = "lazyvim.plugins.extras.lang.typescript" },

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

  -- { "echasnovski/mini.nvim" },
  { "echasnovski/mini.ai" },
  { "echasnovski/mini.align" },
  { "echasnovski/mini.pairs", enabled = false },
  {
    "echasnovski/mini.surround",
    config = true,
    lazy = false,
    -- keys = { "sa", "sd", "sf", "sF", "sh", "sr", "sn" },
  },
  -- { "echasnovski/mini.animate", enabled = false },

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
