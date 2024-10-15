local plugin_root = require("lazy.core.config").options.root

return {
  {
    "simnalamburt/vim-mundo",
    init = function()
      vim.g.mundo_right = 1
    end,
    lazy = true,
    keys = {
      { "<leader>uu", vim.cmd.MundoToggle, desc = "Toggle Undotree" },
    },
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
    "hrsh7th/nvim-cmp",
    optional = true,
    dependencies = { "hrsh7th/cmp-emoji" },
    opts = function(_, opts)
      table.insert(opts.sources, { name = "emoji" })
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
        opts = function()
          local keys = require("lazyvim.plugins.lsp.keymaps").get()
          vim.list_extend(keys, {
            -- from lazyvim/plugins/extras/editor/fzf.lua
            -- { "gd", "<cmd>FzfLua lsp_definitions     jump_to_single_result=true ignore_current_line=true<cr>", desc = "Goto Definition", has = "definition" },
            -- { "gr", "<cmd>FzfLua lsp_references      jump_to_single_result=true ignore_current_line=true<cr>", desc = "References", nowait = true },
            -- { "gI", "<cmd>FzfLua lsp_implementations jump_to_single_result=true ignore_current_line=true<cr>", desc = "Goto Implementation" },
            -- { "gy", "<cmd>FzfLua lsp_typedefs        jump_to_single_result=true ignore_current_line=true<cr>", desc = "Goto T[y]pe Definition" },
            {
              "gd",
              "<cmd>FzfLua lsp_definitions jump_to_single_result=true ignore_current_line=true<cr>",
              desc = "Goto Definition",
              has = "definition",
            },
            { "gr", "<cmd>FzfLua lsp_references<cr>", desc = "References", nowait = true },
            { "gI", "<cmd>FzfLua lsp_implementations<cr>", desc = "Goto Implementation" },
            { "gy", "<cmd>FzfLua lsp_typedefs<cr>", desc = "Goto T[y]pe Definition" },
          })
        end,
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
        "gf",
        function()
          LazyVim.pick.open("find_files", { search_file = vim.fn.expand("<cfile>") })
        end,
        desc = "Telescope to file",
      },
    },
  },
}