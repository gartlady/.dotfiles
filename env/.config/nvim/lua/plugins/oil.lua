return {
  {
    "stevearc/oil.nvim",
    dependencies = { { "echasnovski/mini.icons", opts = {} } },
    config = function()
      require("oil").setup({
        columns = { "icon", "size" },
        view_options = {
          show_hidden = true,
        },
        float = {
          padding = 2,
          max_width = 0.8,
          max_height = 0.8,
          border = "rounded",
          win_options = {
            winblend = 0,
          },
          get_win_title = nil,
          preview_split = "right",
          override = function(conf)
            return conf
          end,
        },
      })

      -- Open parent directory in floating window
      vim.keymap.set("n", "<leader>pv", require("oil").toggle_float, { desc = "Open Oil" })
    end,
  },
}
