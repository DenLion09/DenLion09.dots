local wk = require "which-key"

wk.setup {
  plugins = { spelling = true },
  icons = { group = "" },
  win = { border = "rounded" },
}

wk.add {
  { "<leader>c", group = "code" },
  { "<leader>f", group = "find" },
  { "<leader>g", group = "git" },
  { "<leader>m", group = "markdown" },
  { "<leader>o", group = "opencode" },
  { "<leader>s", group = "search" },
  { "<leader>t", group = "terminal" },
  { "<leader>w", group = "workspace" },
}
