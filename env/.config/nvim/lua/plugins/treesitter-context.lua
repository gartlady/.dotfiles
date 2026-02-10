return {
  "nvim-treesitter/nvim-treesitter-context",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  event = "VimEnter",
  config = function()
    require("treesitter-context").setup({
      enable = true,
      max_lines = 0,
      line_numbers = true,
    })
  end,
}
