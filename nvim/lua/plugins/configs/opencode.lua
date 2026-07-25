-- opencode.nvim: Neovim integration for OpenCode AI assistant
-- https://github.com/nickjvandyke/opencode.nvim

---@type opencode.Opts
vim.g.opencode_opts = {
  server = {
    -- start opencode in a snacks terminal on the right
    start = function()
      require("snacks.terminal").open("opencode --port", {
        win = { position = "right", enter = false },
      })
    end,
  },
}
