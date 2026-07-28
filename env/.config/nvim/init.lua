vim.pack.add({
  { src = "https://github.com/saghen/blink.compat", version = vim.version.range("1.*") },
  { src = "https://github.com/saghen/blink.cmp", version = vim.version.range("1.*") },
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/nvim-treesitter/nvim-treesitter-context",
  "https://github.com/nvim-telescope/telescope.nvim",
  "https://github.com/nvim-telescope/telescope-fzf-native.nvim",
  "https://github.com/nvim-telescope/telescope-ui-select.nvim",
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/mason-org/mason-lspconfig.nvim",
  "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",
  "https://github.com/stevearc/conform.nvim",
  "https://github.com/lewis6991/gitsigns.nvim",
  "https://github.com/folke/which-key.nvim",
  "https://github.com/folke/snacks.nvim",
  "https://github.com/folke/noice.nvim",
  "https://github.com/MunifTanjim/nui.nvim",
  "https://github.com/stevearc/oil.nvim",
  "https://github.com/mfussenegger/nvim-dap",
  "https://github.com/rcarriga/nvim-dap-ui",
  "https://github.com/theHamsta/nvim-dap-virtual-text",
  "https://github.com/nvim-neotest/nvim-nio",
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/nvim-lualine/lualine.nvim",
  "https://github.com/yavorski/lualine-macro-recording.nvim",
  "https://github.com/navarasu/onedark.nvim",
  "https://github.com/echasnovski/mini.nvim",
  "https://github.com/echasnovski/mini.icons",
})

-- =============================================================================
-- CORE OPTIONS
-- =============================================================================

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true

vim.opt.showtabline = 0

vim.g.have_nerd_font = true

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.mouse = "a"

vim.opt.showmode = false

vim.opt.clipboard = "unnamedplus"

vim.opt.breakindent = true

vim.opt.undofile = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.signcolumn = "yes"

vim.opt.updatetime = 250

vim.opt.timeoutlen = 300

vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

vim.opt.inccommand = "split"

vim.opt.cursorline = true

vim.opt.scrolloff = 3

vim.opt.hlsearch = true
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- =============================================================================
-- CORE KEYMAPS
-- =============================================================================

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "[d", function()
  vim.diagnostic.jump({ count = -1 })
end, { desc = "Go to previous [D]iagnostic message" })
vim.keymap.set("n", "]d", function()
  vim.diagnostic.jump({ count = 1 })
end, { desc = "Go to next [D]iagnostic message" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic [E]rror messages" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- =============================================================================
-- COLORSCHEME: onedark
-- =============================================================================

require("onedark").setup({
  style = "darker",
})
require("onedark").load()

-- =============================================================================
-- COMPLETION: blink.cmp + blink.compat
-- =============================================================================

require("blink.compat").setup({})

local blink_opts = {
  keymap = { preset = "default" },
  appearance = {
    nerd_font_variant = "Nerd Font Mono",
  },
  completion = {
    ghost_text = {
      enabled = false,
    },
    menu = {
      border = "rounded",
      draw = {
        columns = {
          { "label", "label_description", gap = 2 },
          { "kind_icon", "kind" },
        },
      },
    },
    documentation = { window = { border = "rounded" } },
  },
  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
  },
  fuzzy = {
    implementation = "prefer_rust_with_warning",
    prebuilt_binaries = {
      force_version = "v1.10.0",
    },
  },
}

-- Deduplication filter for completion items
local original = require("blink.cmp.completion.list").show
require("blink.cmp.completion.list").show = function(ctx, items_by_source)
  local seen = {}
  local function filter(item)
    if seen[item.label] then
      return false
    end
    seen[item.label] = true
    return true
  end
  for id in vim.iter(blink_opts.sources.default) do
    items_by_source[id] = items_by_source[id] and vim.iter(items_by_source[id]):filter(filter):totable()
  end
  return original(ctx, items_by_source)
end

require("blink.cmp").setup(blink_opts)

-- =============================================================================
-- TREESITTER + TREESITTER-CONTEXT
-- =============================================================================

require("nvim-treesitter.install").prefer_git = true
require("nvim-treesitter.config").setup({
  ensure_installed = {
    "bash",
    "c",
    "cpp",
    "diff",
    "html",
    "lua",
    "luadoc",
    "markdown",
    "vim",
    "vimdoc",
    "sql",
    "json",
    "go",
    "typescript",
    "javascript",
  },
  auto_install = true,
  highlight = { enable = true },
  indent = { enable = true },
})

require("treesitter-context").setup({
  enable = true,
  max_lines = 0,
  line_numbers = true,
})

-- =============================================================================
-- TELESCOPE (fuzzy finder)
-- =============================================================================

require("telescope").setup({
  extensions = {
    ["ui-select"] = require("telescope.themes").get_dropdown(),
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

-- Telescope keymaps
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
vim.keymap.set("n", "<leader>/", function()
  builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
    winblend = 10,
    previewer = false,
  }))
end, { desc = "[/] Fuzzily search in current buffer" })

local conf = require("telescope.config").values
vim.keymap.set("n", "<leader>s/", function()
  local vimgrep_args = vim.deepcopy(conf.vimgrep_arguments)
  table.insert(vimgrep_args, "--fixed-strings")
  builtin.live_grep({
    grep_open_files = true,
    prompt_title = "Live Grep in Open Files",
    vimgrep_arguments = vimgrep_args,
  })
end, { desc = "[S]earch [/] in Open Files" })

vim.keymap.set("n", "<leader>sn", function()
  builtin.find_files({ cwd = vim.fn.stdpath("config") })
end, { desc = "[S]earch [N]eovim files" })

-- =============================================================================
-- WHICH-KEY (keymap hints)
-- =============================================================================

require("which-key").setup({})

-- =============================================================================
-- SNACKS (UI enhancements)
-- =============================================================================

require("snacks").setup({
  bigfile = { enabled = true },
  dashboard = { enabled = false },
  explorer = { enabled = false },
  indent = { enabled = true },
  input = { enabled = true },
  picker = { enabled = false },
  notifier = {
    enabled = true,
    timeout = 3000,
    level = vim.log.levels.DEBUG,
    icons = {
      error = " ",
      warn = " ",
      info = " ",
      debug = " ",
      trace = " ",
    },
    top_down = false,
  },
  quickfile = { enabled = true },
  scope = { enabled = true },
  scroll = { enabled = true },
  statuscolumn = { enabled = true },
  words = { enabled = true },
})

-- =============================================================================
-- NOICE (UI messages)
-- =============================================================================

require("noice").setup({})

-- =============================================================================
-- OIL (file explorer)
-- =============================================================================

require("oil").setup({
  columns = { "icon", "size" },
  view_options = {
    show_hidden = true,
  },
  float = {
    padding = 2,
    max_width = 0.8,
    max_height = 0.8,
    border = "rounded",
    win_options = {
      winblend = 0,
    },
    get_win_title = nil,
    preview_split = "right",
    override = function(conf)
      return conf
    end,
  },
})

vim.keymap.set("n", "<leader>pv", require("oil").toggle_float, { desc = "Open Oil" })

-- =============================================================================
-- LUALINE (status bar)
-- =============================================================================

require("lualine").setup({
  options = {
    theme = "horizon",
    component_separators = { left = "", right = "" },
    section_separators = { left = "", right = "" },
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = { "branch", "diff", "diagnostics" },
    lualine_c = { "filename", "macro_recording", "%S" },
    lualine_x = { "lsp_status", "encoding", "fileformat", "filetype" },
    lualine_y = { "progress" },
    lualine_z = { "location" },
  },
})

-- =============================================================================
-- GITSIGNS (git decorations)
-- =============================================================================

require("gitsigns").setup({
  signs = {
    add = { text = "+" },
    change = { text = "~" },
    delete = { text = "_" },
    topdelete = { text = "‾" },
    changedelete = { text = "~" },
  },
})

-- =============================================================================
-- MINI.NIM (mini.basics + mini.surround + mini.comment)
-- =============================================================================

require("mini.basics").setup()
require("mini.surround").setup()
require("mini.comment").setup()

-- =============================================================================
-- LSP CONFIG (lspconfig + diagnostics)
-- =============================================================================

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

-- LSP: clangd (PlayDate)
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

-- LSP: jsonls
vim.lsp.config("jsonls", { capabilities = capabilities })
vim.lsp.enable("jsonls")

-- LSP: gopls
vim.lsp.config("gopls", {
  capabilities = capabilities,
  settings = {
    gopls = {
      analyses = { unusedparams = true, nilness = true, shadow = true },
      staticcheck = true,
    },
  },
})
vim.lsp.enable("gopls")

-- LSP: lua_ls
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

-- LSP: postgres_lsp
vim.lsp.config("postgres_lsp", { capabilities = capabilities })
vim.lsp.enable("postgres_lsp")

-- =============================================================================
-- MASON (LSP server installer)
-- =============================================================================

local mason = require("mason")
mason.setup({
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗",
    },
  },
})

local ensure_installed = { "stylua", "lua_ls", "jq", "jsonls", "gopls", "clangd" }
require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

-- =============================================================================
-- CONFORM (formatter)
-- =============================================================================

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

vim.keymap.set({ "", "n", "v" }, "<leader>f", function()
  require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "[F]ormat buffer" })

-- =============================================================================
-- DAP (debugger)
-- =============================================================================

local dap = require("dap")
dap.adapters.lldb = {
  type = "executable",
  command = "lldb-dap",
  name = "lldb",
}

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
    args = { "HelloWorld.pdx" },
    cwd = vim.fn.getcwd(),
    stopOnEntry = false,
  },
}

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

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp" },
  callback = function(args)
    local bufnr = args.buf
    local map = function(keys, func, desc)
      vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
    end

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

    map("<leader>du", function()
      dapui.toggle()
    end, "Debug: Toggle UI")
    map("<leader>dr", function()
      dap.repl.open()
    end, "Debug: Open REPL")
    map("<leader>dw", function()
      require("dapui").eval(vim.fn.expand("<cword>"))
    end, "Debug: Evaluate Word")

    map("<leader>de", function()
      require("dapui").eval()
    end, "Debug: Evaluate Expression")
    vim.keymap.set("v", "<leader>de", function()
      require("dapui").eval()
    end, { buffer = bufnr, desc = "Debug: Evaluate Selection" })

    map("<leader>da", function()
      dap.continue()
    end, "Debug: Attach Playdate")
    map("<leader>dd", function()
      dap.disconnect({ terminateDebuggee = true })
    end, "Debug: Detach")
  end,
})

-- END OF CONFIG
