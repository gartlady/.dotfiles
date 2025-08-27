-- Fuzzy Finder (files, lsp, etc)
return {
  "nvim-telescope/telescope.nvim",
  event = "VimEnter",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    {
      "nvim-telescope/telescope-fzf-native.nvim",

      -- `build` is used to run some command when the plugin is installed/updated.
      -- This is only run then, not every time Neovim starts up.
      build = "make",

      -- `cond` is a condition used to determine whether this plugin should be
      -- installed and loaded.
      cond = function()
        return vim.fn.executable("make") == 1
      end,
    },
    { "nvim-telescope/telescope-ui-select.nvim" },
    { "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
  },
  config = function()
    require("telescope").setup({
      extensions = {
        ["ui-select"] = {
          require("telescope.themes").get_dropdown(),
        },
        "fzf",
      },
      pickers = {
        live_grep = {
          file_ignore_patterns = { "node_modules", ".git", ".venv" },
          additional_args = function(_)
            return { "--hidden" }
          end,
        },
        find_files = {
          file_ignore_patterns = { "node_modules", ".git", ".venv" },
          hidden = true,
        },
      },
    })

    pcall(require("telescope").load_extension, "fzf")
    pcall(require("telescope").load_extension, "ui-select")

    local builtin = require("telescope.builtin")
    vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
    vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
    vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
    vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
    vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
    vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
    vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
    vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
    vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
    vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })

    -- @TODO: Implement more
    -- keys = {
    --     { "<leader>/",  '<cmd>Telescope current_buffer_fuzzy_find<cr>', desc = "Buffer search", },
    --     { "<leader>fb", '<cmd>Telescope buffers<cr>',                   desc = "Buffers", },
    --     { "<leader>fc", '<cmd>Telescope git_commits<cr>',               desc = "Commits", },
    --     { "<leader>ff", '<cmd>Telescope find_files<cr>',                desc = "Find All Files", },
    --     { "<C-p>",      '<cmd>Telescope git_files<cr>',                 desc = "Git files", },
    --     { "<leader>fh", '<cmd>Telescope help_tags<cr>',                 desc = "Help", },
    --     { "<leader>fj", '<cmd>Telescope command_history<cr>',           desc = "History", },
    --     { "<leader>fk", '<cmd>Telescope keymaps<cr>',                   desc = "Keymaps", },
    --     { "<leader>fl", '<cmd>Telescope lsp_references<cr>',            desc = "Lsp References", },
    --     { "<leader>fo", '<cmd>Telescope oldfiles<cr>',                  desc = "Old files", },
    --     { "<leader>fr", '<cmd>Telescope live_grep<cr>',                 desc = "Ripgrep", },
    --     { "<leader>fs", '<cmd>Telescope grep_string<cr>',               desc = "Grep String", },
    --     { "<leader>ft", '<cmd>Telescope treesitter<cr>',                desc = "Treesitter", },
    -- },
    --
    vim.keymap.set("n", "<leader>/", function()
      builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
        winblend = 10,
        previewer = false,
      }))
    end, { desc = "[/] Fuzzily search in current buffer" })

    local conf = require("telescope.config").values
    vim.keymap.set("n", "<leader>s/", function()
      builtin.live_grep({
        grep_open_files = true,
        prompt_title = "Live Grep in Open Files",
        vimgrep_arguments = table.insert(conf.vimgrep_arguments, "--fixed-strings"),
      })
    end, { desc = "[S]earch [/] in Open Files" })

    vim.keymap.set("n", "<leader>sn", function()
      builtin.find_files({ cwd = vim.fn.stdpath("config") })
    end, { desc = "[S]earch [N]eovim files" })
  end,
}
