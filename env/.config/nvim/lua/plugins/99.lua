return {
  "ThePrimeagen/99",
  config = function()
    local _99 = require("99")

    local cwd = vim.uv.cwd()
    local basename = vim.fs.basename(cwd)
    _99.setup({
      -- provider = _99.Providers.ClaudeCodeProvider,  -- default: OpenCodeProvider
      logger = {
        level = _99.DEBUG,
        path = "/tmp/" .. basename .. ".99.debug",
        print_on_error = true,
      },
      tmp_dir = "./tmp",
      completion = {
        custom_rules = {
          "scratch/custom_rules/",
        },
        files = {},
        source = "blink", -- "native" (default), "cmp", or "blink"
      },
      md_files = {
        "AGENT.md",
      },
    })

    vim.keymap.set("v", "<leader>9v", _99.visual, { desc = "99: Enter [V]isual mode" })
    vim.keymap.set("n", "<leader>9x", _99.stop_all_requests, { desc = "99: Stop all requests" })
    vim.keymap.set("n", "<leader>9s", _99.search, { desc = "99: [S]earch" })
    vim.keymap.set("n", "<leader>9m", require("99.extensions.telescope").select_model, { desc = "99: Select [M]odel" })
    vim.keymap.set(
      "n",
      "<leader>9p",
      require("99.extensions.telescope").select_provider,
      { desc = "99: Select [P]rovider" }
    )
  end,
}
