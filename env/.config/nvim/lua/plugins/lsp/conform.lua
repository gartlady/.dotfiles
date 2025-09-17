return {
  "stevearc/conform.nvim",
  lazy = false,
  keys = {
    {
      "<leader>f",
      function()
        require("conform").format({ async = true, lsp_fallback = true })
      end,
      mode = "",
      desc = "[F]ormat buffer",
    },
  },
  opts = {},
  config = function()
    local conform = require("conform")

    conform.setup({
      formatters_by_ft = {
        lua = { "stylua" },
        javascript = { "biome" },
        json = { "jq" },
        jsonc = { "jq" },
        javascriptreact = { "biome" },
        typescript = { "biome" },
        typescriptreact = { "biome" },
        css = { "prettierd" },
        html = { "prettierd" },
        yaml = { "prettierd" },
        sql = { "postgres_lsp", "sleek" },
        cpp = { "clang-format" },
        h = { "clang-format" },
        c = { "clang-format" },
        sh = { "shfmt", "beautysh" },
        zig = { "zig fmt" },
      },
    })
  end,
}
