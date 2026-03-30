return {
  "neovim/nvim-lspconfig",
  lazy = false,
  dependencies = {
    "saghen/blink.cmp",
  },
  config = function()
    local blink = require("blink.cmp")
    local capabilities = blink.get_lsp_capabilities()

    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        local bufnr = args.buf

        local map = function(keys, func, desc)
          vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
        end

        map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
        map("gr", require("telescope.builtin").lsp_references, "References")
        map("gI", require("telescope.builtin").lsp_implementations, "Implementation")
        map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type Definition")

        map("<leader>rn", vim.lsp.buf.rename, "Rename")
        map("<leader>ca", vim.lsp.buf.code_action, "Code Action")
        map("K", vim.lsp.buf.hover, "Hover")
      end,
    })

    vim.diagnostic.config({
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = " ",
          [vim.diagnostic.severity.WARN] = " ",
          [vim.diagnostic.severity.HINT] = "󰠠 ",
          [vim.diagnostic.severity.INFO] = " ",
        },
      },
    })

    ----------------------------------------------------------------
    -- clangd 
    ----------------------------------------------------------------
    vim.lsp.config("clangd", {
      capabilities = capabilities,
      cmd = (function()
        local gcc_path = os.getenv("PLAYDATE_ARM_GCC")
        local cmd = {
          "clangd",
          "--background-index",
          "--completion-style=detailed",
          "--function-arg-placeholders",
          "--fallback-style=llvm",
        }

        if gcc_path and gcc_path ~= "" then
          table.insert(cmd, "--query-driver=" .. gcc_path .. "/bin/arm-none-eabi-gcc")
        end

        return cmd
      end)(),
      init_options = {
        usePlaceholders = true,
        completeUnimported = true,
        clangdFileStatus = true,
      },
    })

    vim.lsp.enable("clangd")

    ----------------------------------------------------------------
    -- jsonls
    ----------------------------------------------------------------
    vim.lsp.config("jsonls", {
      capabilities = capabilities,
    })
    vim.lsp.enable("jsonls")

    ----------------------------------------------------------------
    -- gopls
    ----------------------------------------------------------------
    vim.lsp.config("gopls", {
      capabilities = capabilities,
      settings = {
        gopls = {
          analyses = {
            unusedparams = true,
            nilness = true,
            shadow = true,
          },
          staticcheck = true,
        },
      },
    })
    vim.lsp.enable("gopls")

    ----------------------------------------------------------------
    -- lua_ls
    ----------------------------------------------------------------
    vim.lsp.config("lua_ls", {
      capabilities = capabilities,
      settings = {
        Lua = {
          diagnostics = { globals = { "vim" } },
          workspace = {
            library = {
              [vim.fn.expand("$VIMRUNTIME/lua")] = true,
              [vim.fn.stdpath("config") .. "/lua"] = true,
            },
          },
        },
      },
    })
    vim.lsp.enable("lua_ls")

    ----------------------------------------------------------------
    -- postgres_lsp
    ----------------------------------------------------------------
    vim.lsp.config("postgres_lsp", {
      capabilities = capabilities,
    })
    vim.lsp.enable("postgres_lsp")
  end,
}
