-- if true then return {} end

local plugin_root = require("lazy.core.config").options.root

return {

  {
    -- a package manager
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "stylua",
        "shellcheck",
        "shfmt",
      },
    },
  },

  {
    -- a "picker" system
    "nvim-telescope/telescope.nvim",
    dependencies = {
      -- an undo tree navigator
      "debugloop/telescope-undo.nvim",
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
      { "<leader>bs", "<cmd>BufferLineSortByDirectory<cr>", desc = "Sort Buffers by Directory" },
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

  -- {
  --   "ibhagwan/fzf-lua",
  --   optional = true,
  --   lazy = true,
  --   dependencies = {
  --     {
  --       "neovim/nvim-lspconfig",
  --       keys = {
  --         {
  --           "gd",
  --           "<cmd>FzfLua lsp_definitions jump_to_single_result=true ignore_current_line=true<cr>",
  --           desc = "Goto Definition",
  --           has = "definition",
  --         },
  --         { "gr", "<cmd>FzfLua lsp_references<cr>", desc = "References", nowait = true },
  --         { "gI", "<cmd>FzfLua lsp_implementations<cr>", desc = "Goto Implementation" },
  --         { "gy", "<cmd>FzfLua lsp_typedefs<cr>", desc = "Goto T[y]pe Definition" },
  --       },
  --     },
  --   },
  --   keys = function(_, keys)
  --     keys = vim.list_extend(keys or {}, {
  --       { "<leader>sp", LazyVim.pick("live_grep", { cwd = plugin_root }), desc = "Plugin Files" },
  --       { "<leader>fp", LazyVim.pick("files", { cwd = plugin_root }), desc = "Plugin Files" },
  --     })
  --   end,
  -- },

  {
    "ibhagwan/fzf-lua",
    optional = true,
    lazy = true,
    dependencies = {
      "neovim/nvim-lspconfig",
    },
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
      { "<leader>sp", LazyVim.pick("live_grep", { cwd = plugin_root }), desc = "Plugin Files" },
      { "<leader>fp", LazyVim.pick("files", { cwd = plugin_root }), desc = "Plugin Files" },
    },
  },

  {
    "nvim-telescope/telescope.nvim",
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
      { "<leader>sp", LazyVim.pick("live_grep", { cwd = plugin_root }), desc = "Search for Plugin Files" },
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
        -- mode = { "n", "v", "o" },
      },
    },
  },

  -- {
  --   "nvim-tree/nvim-web-devicons",
  --   lazy = true,
  -- },

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

  -- {
  --   "chrisbra/Colorizer",
  -- },

  { "nvim-lua/plenary.nvim", lazy = true },

  {
    "allaman/emoji.nvim",
    dependencies = {
      -- util for handling paths
      -- "nvim-lua/plenary.nvim",
      -- optional for telescope integration
      -- "nvim-telescope/telescope.nvim",
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
        -- mode = { "n", "v", "o" },
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
    "folke/snacks.nvim",
    optional = true,
    opts = {
      picker = {
        sources = {
          explorer = {
            actions = {
              --- open a directory in the explorer
              ---@param picker snacks.Picker
              explorer_open_dir = function(picker)
                local Tree = require("snacks.explorer.tree")
                local current = picker:dir()
                Tree:open(current)
                Tree:expand(Tree:find(current))
                require("snacks.explorer.actions").update(picker, { target = current, refresh = true })
              end,
              ---@param picker snacks.Picker
              explorer_walk_open = function(picker)
                local Tree = require("snacks.explorer.tree")
                local current = picker:dir()
                Tree:walk(Tree:find(current), function(node)
                  if node.dir then
                    node.open = true
                    Tree:expand(node)
                  end
                end, { all = true })
                require("snacks.explorer.actions").update(picker, { target = current, refresh = true })
              end,
              ---@param picker snacks.Picker
              explorer_walk_close = function(picker)
                local current = picker:dir()
                require("snacks.explorer.tree"):close_all(current)
                require("snacks.explorer.actions").update(picker, { target = current, refresh = true })
              end,
            },
            win = {
              list = {
                keys = {
                  ["zo"] = "explorer_open_dir",
                  ["zO"] = "explorer_walk_open",
                  ["zc"] = "explorer_close",
                  ["zC"] = "explorer_walk_close",
                },
              },
            },
          },
        },
      },
    },
  },

  {
    -- interpret ANSI colors
    "0xferrous/ansi.nvim",
    opts = {
      auto_enable = true, -- Auto-enable for configured filetypes
      auto_enable_stdin = true, -- Auto-enable for piped stdin content
      filetypes = { "log", "ansi" },
      theme = "catppuccin",
    },
    ft = { "log", "ansi" },
    cmd = { "AnsiEnable", "AnsiDisable", "AnsiToggle" },
    keys = {
      {
        "<leader>uN",
        function()
          require("ansi").toggle()
        end,
        desc = "Interpret ANSI Colors",
      },
    },
    config = function(_, opts)
      local Ansi = require("ansi")
      local Renderer = require("ansi.renderer")
      Ansi.setup(opts)

      -- write down whether we're enabled or not in each buffer, so that we know what to do when toggling
      local enabled = {}

      Renderer._enable_for_buffer = Renderer.enable_for_buffer
      Renderer.enable_for_buffer = function(bufnr, ...)
        bufnr = bufnr or vim.api.nvim_get_current_buf()
        enabled[bufnr] = true
        Renderer._enable_for_buffer(bufnr, ...)
      end

      Renderer._disable_for_buffer = Renderer.disable_for_buffer
      Renderer.disable_for_buffer = function(bufnr, ...)
        bufnr = bufnr or vim.api.nvim_get_current_buf()
        enabled[bufnr] = false
        Renderer._disable_for_buffer(bufnr, ...)
      end

      Ansi.toggle = function(bufnr, ...)
        bufnr = bufnr or vim.api.nvim_get_current_buf()
        if enabled[bufnr] then
          Ansi.disable(bufnr, ...)
        else
          Ansi.enable(bufnr, ...)
        end
      end
    end,
  },
}
