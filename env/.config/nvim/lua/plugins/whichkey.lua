-- Useful plugin to show you pending keybinds.
return {
  "folke/which-key.nvim",
  event = "VimEnter",
  config = function()
    require("which-key").setup()
  end,
}
