return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    -- "hrsh7th/cmp-nvim-lsp",
    "saghen/blink.cmp",
  },
  opts = {
    autoformat = false,
  },
  config = function()
    local lspconfig = require("lspconfig")
    -- local cmp_nvim_lsp = require("cmp_nvim_lsp")

    local on_attach = function(client, bufnr)
      local map = function(keys, func, desc)
        vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
      end

      -- Jump to the definition of the word under your cursor.
      map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")

      -- Find references for the word under your cursor.
      map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")

      -- Jump to the implementation of the word under your cursor.
      map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")

      -- Jump to the type of the word under your cursor.
      map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")

      -- Fuzzy find all the symbols in your current document.
      map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")

      -- Fuzzy find all the symbols in your current workspace.
      map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")

      -- Rename the variable under your cursor.
      map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")

      -- Execute a code action, usually your cursor needs to be on top of an error
      -- or a suggestion from your LSP for this to activate.
      map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")

      -- Opens a popup that displays documentation about the word under your cursor
      map("K", vim.lsp.buf.hover, "Hover Documentation")

      map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
    end

    -- local capabilities = cmp_nvim_lsp.default_capabilities()
    local capabilities = require('blink.cmp').get_lsp_capabilities()

    local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end

    lspconfig.tailwindcss.setup({
      filetypes = {
        "astro",
        "astro-markdown",
        "gohtml",
        "gohtmltmpl",
        "handlebars",
        "hbs",
        "html",
        "html-eex",
        "markdown",
        "mdx",
        "css",
        "javascript",
        "javascriptreact",
        "rescript",
        "typescript",
        "typescriptreact",
        "templ",
      },
      init_options = {
        userLanguages = {
          templ = "html",
        },
      },
      on_attach = on_attach,
      capabilities = capabilities,
      settings = {
        tailwindCSS = {
          classAttributes = {
            "class",
            "className",
            "textClassName",
          },
          experimental = {
            classRegex = {
              { "cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
              { "cx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
            },
          },
        },
      },
    })

    lspconfig["html"].setup({
      capabilities = capabilities,
      on_attach = on_attach,
    })

    lspconfig["ts_ls"].setup({
      capabilities = capabilities,
      on_attach = on_attach,
    })

    lspconfig["cssls"].setup({
      capabilities = capabilities,
      on_attach = on_attach,
    })

    -- lspconfig["clangd"].setup({
    --   on_attach = on_attach,
    --   capabilities = cmp_nvim_lsp.default_capabilities(),
    --   root_dir = function(fname)
    --     return require("lspconfig.util").root_pattern(
    --       "Makefile",
    --       "configure.ac",
    --       "configure.in",
    --       "config.h.in",
    --       "meson.build",
    --       "meson_options.txt",
    --       "build.ninja"
    --     )(fname) or require("lspconfig.util").root_pattern("compile_commands.json", "compile_flags.txt")(fname) or require(
    --       "lspconfig.util"
    --     ).find_git_ancestor(fname)
    --   end,
    --   cmd = {
    --     "clangd",
    --     "--background-index",
    --     "--clang-tidy",
    --     "--log=verbose",
    --     "--header-insertion=iwyu",
    --     "--completion-style=detailed",
    --     "--function-arg-placeholders",
    --     "--fallback-style=llvm",
    --     "--query-driver=/home/dylan/projects/personal/playdate/arm-gnu-toolchain-13.3.rel1-x86_64-arm-none-eabi/bin/arm-none-eabi-gcc",
    --   },
    --   init_options = {
    --     usePlaceholders = true,
    --     completeUnimported = true,
    --     clangdFileStatus = true,
    --     fallbackFlags = { "-std=c++17" },
    --   },
    -- })

    lspconfig["astro"].setup({
      capabilities = capabilities,
      on_attach = on_attach,
    })

    lspconfig["jsonls"].setup({
      capabilities = capabilities,
      on_attach = on_attach,
    })

    lspconfig["rust_analyzer"].setup({
      -- on_attach = function(client, bufnr)
      --   vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
      -- end,
      on_attach = on_attach,
      settings = {
        ["rust-analyzer"] = {
          imports = {
            granularity = {
              group = "module",
            },
            prefix = "self",
          },
          cargo = {
            buildScripts = {
              enable = true,
            },
          },
          procMacro = {
            enable = true,
          },
        },
      },
    })

    lspconfig["gopls"].setup({
      capabilities = capabilities,
      on_attach = on_attach,
    })

    lspconfig["lua_ls"].setup({
      capabilities = capabilities,
      on_attach = on_attach,
      settings = {
        Lua = {
          diagnostics = {
            globals = { "vim" },
          },
          workspace = {
            library = {
              [vim.fn.expand("$VIMRUNTIME/lua")] = true,
              [vim.fn.stdpath("config") .. "/lua"] = true,
            },
          },
        },
      },
    })
  end,
}
