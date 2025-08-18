return {
  "williamboman/mason.nvim",
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  config = function()
    local mason = require("mason")
    local mason_lspconfig = require("mason-lspconfig")

    mason.setup({
      opts = {
        setup = {
          rust_analyzer = function()
            return true
          end,
        },
      },
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    })

    local ensure_installed = {
      "stylua",
      "lua_ls",
      "jq",
      "jsonls",
      "gopls",
      "biome",
      -- "ts_ls",
      -- "prettierd",
      -- "astro",
      -- "cssls",
      -- "html",
      -- "tailwindcss",
      "markdownlint",
    }
    require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

    mason_lspconfig.setup({
      automatic_installaion = true,
    })
  end,
}
