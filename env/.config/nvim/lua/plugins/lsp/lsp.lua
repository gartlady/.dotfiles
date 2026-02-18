return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "saghen/blink.cmp",
  },
  opts = {
    autoformat = false,
  },
  config = function()
    local blink = require("blink.cmp")
    local capabilities = blink.get_lsp_capabilities()

    local on_attach = function(_, bufnr)
      local map = function(keys, func, desc)
        vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
      end

      -- Jump to the definition of the word under your cursor.
      map("gd", function()
        require("telescope.builtin").lsp_definitions()
      end, "[G]oto [D]efinition")
      map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
      map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
      map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
      map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
      map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
      map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
      map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
      map("K", vim.lsp.buf.hover, "Hover Documentation")
      map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
    end

    -- Diagnostic signs
    local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
    vim.diagnostic.config({
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = signs.Error,
          [vim.diagnostic.severity.WARN] = signs.Warn,
          [vim.diagnostic.severity.HINT] = signs.Hint,
          [vim.diagnostic.severity.INFO] = signs.Info,
        },
      },
    })

    vim.lsp.config("clangd", {
      on_attach = on_attach,
      capabilities = capabilities,
      root_dir = function(fname)
        return require("lspconfig.util").root_pattern(
          "Makefile",
          "configure.ac",
          "configure.in",
          "config.h.in",
          "meson.build",
          "meson_options.txt",
          "build.ninja"
        )(fname) or require("lspconfig.util").root_pattern("compile_commands.json", "compile_flags.txt")(fname) or require(
          "lspconfig.util"
        ).find_git_ancestor(fname)
      end,
      -- dynamically modify command for this workspace
      on_new_config = function(new_config, new_root_dir)
        local gcc_path = os.getenv("PLAYDATE_ARM_GCC") or ""
        local query_driver = gcc_path ~= "" and
          (gcc_path .. "/bin/arm-none-eabi-gcc") or
          "arm-none-eabi-gcc"

        new_config.cmd = vim.list_extend({
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--log=verbose",
          "--header-insertion=iwyu",
          "--completion-style=detailed",
          "--function-arg-placeholders",
          "--fallback-style=llvm",
          "--query-driver=" .. query_driver,
        }, new_config.cmd or {})
      end,
      init_options = {
        usePlaceholders = true,
        completeUnimported = true,
        clangdFileStatus = true,
        fallbackFlags = { "-std=c++17" },
      },
    })
    vim.lsp.enable("clangd")

    -- jsonls
    vim.lsp.config("jsonls", { capabilities = capabilities, on_attach = on_attach })
    vim.lsp.enable("jsonls")

    -- === gopls with workspace-aware enhancements ===
    vim.lsp.config("gopls", {
      capabilities = capabilities,
      on_attach = function(client, bufnr)
        print("gopls attached to buffer " .. bufnr .. " (client id: " .. client.id .. ")")
        on_attach(client, bufnr)
      end,
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
      on_new_config = function(new_config, root_dir)
        new_config.init_options = new_config.init_options or {}
        new_config.init_options.env = vim.tbl_extend("force", new_config.init_options.env or {}, {
          GOFLAGS = "-tags=integration",
        })
      end,
    })
    vim.lsp.enable("gopls")

    -- zls
    vim.lsp.config("zls", {
      capabilities = capabilities,
      on_attach = on_attach,
      cmd = { "/usr/local/bin/zls" },
      filetypes = { "zig", "zir" },
      root_dir = require("lspconfig.util").root_pattern("zls.json", "build.zig", ".git"),
      single_file_support = true,
    })
    vim.lsp.enable("zls")

    -- lua_ls
    vim.lsp.config("lua_ls", {
      capabilities = capabilities,
      on_attach = on_attach,
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

    -- postgres_lsp
    vim.lsp.config("postgres_lsp", { capabilities = capabilities, on_attach = on_attach })
    vim.lsp.enable("postgres_lsp")
  end,
}
