return {
  "https://github.com/nvim-treesitter/nvim-treesitter-context",
  event = "VimEnter",
  config = function()
    require("treesitter-context").setup({
      enable = true,
      max_lines = 0,
      line_numbers = true,
    })
  end,
}
