return {
  "echasnovski/mini.nvim",
  version = false,
  config = function(_, opts)
    require("mini.basics").setup()
    require("mini.surround").setup()
  end,
}
