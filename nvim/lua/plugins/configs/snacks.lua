return {
  -- animate: smooth scrolling, cursor, and window animations
  animate = { enabled = true },

  -- dashboard: replace the startup screen
  dashboard = {
    enabled = true,
    preset = {
      header = [[
    ╔═══════════════════════════════════════╗
    ║                                       ║
    ║              N E O V I M              ║
    ║                                       ║
    ╚═══════════════════════════════════════╝
      ]],
    },
    sections = {
      { section = "header" },
      { section = "keys", gap = 1, padding = 1 },
      { section = "startup" },
    },
  },

  -- gh: GitHub integration
  gh = { enabled = true },

  -- input: enhanced input() with LSP completions (used by opencode.nvim Ask)
  input = { enabled = true },

  -- git: enhanced git integration (hunks, signs, blame)
  git = { enabled = true },

  -- lazygit: open lazygit from neovim
  lazygit = { enabled = true },

  -- rename: smart rename
  rename = { enabled = true },

  -- scope: track the current scope (function, block, etc.)
  scope = { enabled = true },

  -- scroll: smooth scrolling
  scroll = { enabled = true },

  -- terminal: improved terminal management
  terminal = { enabled = true },

  -- util: utility functions (move, jump, etc.)
  util = { enabled = true },

  -- words: dim inactive word matches, LSP references
  words = { enabled = true },
}
