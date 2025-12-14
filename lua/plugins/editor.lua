-- if true then return {} end

local plugin_root = require("lazy.core.config").options.root

return {

  {
    -- a package manager
    "mason-org/mason.nvim",
    -- optional = true,
    opts = {
      registries = {
        -- "lua:config.mason_registry",
        "github:mason-org/mason-registry",
      },
      ensure_installed = {
        "stylua",
        "shellcheck",
        "shfmt",
      },
    },
  },

  {
    -- an undo tree navigator
    "simnalamburt/vim-mundo",
    cond = false,
    init = function()
      vim.g.mundo_right = 1
    end,
    lazy = true,
    keys = {
      { "<leader>uu", vim.cmd.MundoToggle, desc = "Toggle Undotree" },
    },
  },

  {
    -- an undo tree navigator
    "debugloop/telescope-undo.nvim",
    dependencies = {
      {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
      },
    },
    keys = {
      { "<leader>uu", "<cmd>Telescope undo<cr>", desc = "Telescope undo" },
    },
    opts = {
      extensions = {
        undo = {
          side_by_side = true,
          layout_config = {
            preview_width = 0.75,
          },
        },
      },
    },
    config = function(_, opts)
      require("telescope").setup(opts)
      require("telescope").load_extension("undo")
    end,
  },

  {
    "folke/flash.nvim",
    optional = true,
    lazy = true,
    -- cond = false,
    keys = function()
      -- heck you, and all your friends too
      return {}
    end,
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
      local util = require("lazyvim.util.lualine")
      table.remove(opts.sections.lualine_c, 4)
      table.insert(opts.sections.lualine_c, 4, util.pretty_path({ length = 0 }))
    end,
  },

  {
    "ibhagwan/fzf-lua",
    optional = true,
    dependencies = {
      {
        "neovim/nvim-lspconfig",
        keys = {
          {
            "gd",
            "<cmd>FzfLua lsp_definitions jump_to_single_result=true ignore_current_line=true<cr>",
            desc = "Goto Definition",
            has = "definition",
          },
          { "gr", "<cmd>FzfLua lsp_references<cr>", desc = "References", nowait = true },
          { "gI", "<cmd>FzfLua lsp_implementations<cr>", desc = "Goto Implementation" },
          { "gy", "<cmd>FzfLua lsp_typedefs<cr>", desc = "Goto T[y]pe Definition" },
        },
      },
    },
    keys = function(_, keys)
      keys = vim.list_extend(keys or {}, {
        { "<leader>sp", LazyVim.pick("live_grep", { cwd = plugin_root }), desc = "Plugin Files" },
        { "<leader>fp", LazyVim.pick("files", { cwd = plugin_root }), desc = "Plugin Files" },
      })
    end,
  },

  {
    "nvim-telescope/telescope.nvim",
    optional = true,
    opts = {
      defaults = {
        layout_strategy = "horizontal",
        layout_config = { prompt_position = "top" },
        sorting_strategy = "ascending",
        winblend = 0,
      },
    },
    keys = {
      --stylua: ignore start
      { "<leader>sp", LazyVim.pick("live_grep", { cwd = plugin_root }), desc = "Plugin Files" },
      { "<leader>su", LazyVim.pick("live_grep", { additional_args = { "-uu" } }), desc = "Unrestricted (root dir)" },
      { "<leader>sU", LazyVim.pick("live_grep", { additional_args = { "-uu" }, cwd = nil }), desc = "Unrestricted (cwd)" },
      { "<leader>sb", LazyVim.pick("live_grep", { grep_open_files = true }), desc = "Buffers" },

      { "<leader>fp", LazyVim.pick("files", { cwd = plugin_root }), desc = "Plugin Files" },
      { "<leader>fu", LazyVim.pick("files", { hidden = true, no_ignore = true, no_ignore_parent = true }), desc = "Unrestricted Files (root dir)" },
      { "<leader>fU", LazyVim.pick("files", { hidden = true, no_ignore = true, no_ignore_parent = true, cwd = nil }), desc = "Unrestricted Files (cwd)" },

      --stylua: ignore end

      {
        "gF",
        function()
          -- wrapped in a function to evaluate `expand("<cfile>")` at runtime
          LazyVim.pick.open("files", { pattern = vim.fn.expand("<cfile>") })
        end,
        desc = "Telescope to file under cursor",
        mode = { "n", "v", "o" },
      },
    },
  },

  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
  },

  {
    -- remove a keymapping group description (overwritten in keymaps.lua)
    "ThePrimeagen/refactoring.nvim",
    optional = true,
    keys = {
      { "<leader>r", false },
    },
  },

  {
    "folke/persistence.nvim",
    opts = {
      need = 2,
    },
  },

  {
    "chrisbra/Colorizer",
  },

  {
    "allaman/emoji.nvim",
    -- version = "1.0.0", -- optionally pin to a tag
    -- ft = "markdown", -- adjust to your needs
    dependencies = {
      -- util for handling paths
      "nvim-lua/plenary.nvim",
      -- optional for telescope integration
      "nvim-telescope/telescope.nvim",
      -- optional for fzf-lua integration via vim.ui.select
      -- "ibhagwan/fzf-lua",
    },
    opts = {
      -- default is false, also needed for blink.cmp integration!
      enable_cmp_integration = true,
    },
    keys = {
      {
        "<leader>se",
        function()
          require("telescope").load_extension("emoji").emoji()
        end,
        desc = "[S]earch [E]moji",
        mode = { "n", "v", "o" },
      },
    },
  },

  {
    "stevearc/aerial.nvim",
    opts = {
      layout = {
        width = 40,
      },
    },
  },

  {
    "olimorris/codecompanion.nvim",
    cond = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "ravitemer/mcphub.nvim",
    },
    opts = {
      strategies = {
        chat = {
          adapter = "gemini",
        },
        inline = {
          adapter = "gemini",
        },
        cmd = {
          adapter = "gemini",
        },
      },
      adapters = {
        gemini = function()
          return require("codecompanion.adapters").extend("gemini", {
            env = {
              -- not quite correct...
              api_key = "cmd:gcloud auth application-default print-access-token",
            },
          })
        end,
      },
    },
  },
}
