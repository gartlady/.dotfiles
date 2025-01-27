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
        cpp = { "clang-format" },
        h = { "clang-format" },
        c = { "clang-format" },
        go = { "gofumpt", "gofmt", "goimports" },
        markdown = { "prettierd" },
        sh = { "shfmt" },
      },
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      },
    })
  end,
}
