return {
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

  { "folke/flash.nvim", cond = false },

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
    dependencies = {
      {
        "neovim/nvim-lspconfig",
        optional = true,
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
      local lazy_config = require("lazy.core.config")
      keys = vim.list_extend(keys or {}, {
        { "<leader>fp", LazyVim.pick("files", { cwd = lazy_config.options.root }), desc = "Find Plugin Files" },
        { "<leader>sp", LazyVim.pick("grep", { cwd = lazy_config.options.root }), desc = "Search Plugin Files" },
      })
    end,
  },
}
