return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "nvim-neotest/nvim-nio",
    },

    config = function()
      local dap = require("dap")

      -- LLDB adapter
      dap.adapters.lldb = {
        type = "executable",
        command = "lldb-dap",
        name = "lldb",
      }

      -- c config
      dap.configurations.c = {
        {
          name = "attach playdate simulator",
          type = "lldb",
          request = "attach",
          pid = function()
            return require("dap.utils").pick_process()
          end,
        },
        {
          name = "launch playdate (under debugger)",
          type = "lldb",
          request = "launch",
          program = "PlaydateSimulator",
          args = {
            "HelloWorld.pdx",
          },
          cwd = vim.fn.getcwd(),
          stopOnEntry = false,
        },
      }

      -- UI
      local dapui = require("dapui")
      dapui.setup()

      dap.listeners.after.event_initialized["dapui"] = function()
        dapui.open()
      end

      dap.listeners.before.event_terminated["dapui"] = function()
        dapui.close()
      end

      dap.listeners.before.event_exited["dapui"] = function()
        dapui.close()
      end

      require("nvim-dap-virtual-text").setup()

      -- =========================================================
      -- FIXED KEYBINDS
      -- =========================================================
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "c", "cpp" },
        callback = function(args)
          local bufnr = args.buf

          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, {
              buffer = bufnr,
              desc = desc,
            })
          end

          -- Breakpoints
          map("<leader>db", function()
            dap.toggle_breakpoint()
          end, "Debug: Toggle Breakpoint")

          map("<leader>dB", function()
            dap.set_breakpoint(vim.fn.input("Condition: "))
          end, "Debug: Conditional Breakpoint")

          map("<leader>dbx", function()
            dap.clear_breakpoints()
          end, "Debug: Clear All Breakpoints")

          map("<leader>de", function()
            dap.set_exception_breakpoints({ "all" })
          end, "Debug: Break on Exceptions")

          map("<leader>dc", function()
            dap.run_to_cursor()
          end, "Debug: Run to Cursor")

          map("<leader>dl", function()
            dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
          end, "Debug: Logpoint")

          -- UI / REPL
          map("<leader>du", function()
            dapui.toggle()
          end, "Debug: Toggle UI")

          map("<leader>dr", function()
            dap.repl.open()
          end, "Debug: Open REPL")

          map("<leader>dw", function()
            require("dapui").eval(vim.fn.expand("<cword>"))
          end, "Debug: Evaluate Word")

          -- Full evaluate: expression or selection (flexible)
          map("<leader>de", function()
            require("dapui").eval()
          end, "Debug: Evaluate Expression")

          vim.keymap.set("v", "<leader>de", function()
            require("dapui").eval()
          end, { buffer = bufnr, desc = "Debug: Evaluate Selection" })

          -- Attach Playdate
          map("<leader>da", function()
            dap.continue()
          end, "Debug: Attach Playdate")

          map("<leader>dd", function()
            dap.disconnect({ terminateDebuggee = true })
          end, "Debug: Detach")
        end,
      })
    end,
  },
}
