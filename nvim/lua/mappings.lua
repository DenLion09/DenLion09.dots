local map = vim.keymap.set

-- general
map("n", "<C-s>", "<cmd> w <CR>", { desc = "Save" })
map("i", "jk", "<ESC>", { desc = "Exit insert" })
map("n", "<C-c>", "<cmd> %y+ <CR>", { desc = "Copy whole file" })
map("n", "<C-q>", "<cmd> bd <CR>", { desc = "Close buffer" })

-- nvimtree
map("n", "<C-n>", "<cmd> NvimTreeToggle <CR>", { desc = "Toggle NvimTree" })
map("n", "<C-h>", "<cmd> NvimTreeFocus <CR>", { desc = "Focus NvimTree" })

-- find: telescope file search
map("n", "<leader>ff", "<cmd> Telescope find_files <CR>", { desc = "Find files" })
map("n", "<leader>fo", "<cmd> Telescope oldfiles <CR>", { desc = "Recent files" })
map("n", "<leader>fw", "<cmd> Telescope live_grep <CR>", { desc = "Grep text" })

-- search: telescope code/content search
map("n", "<leader>sb", "<cmd> Telescope buffers <CR>", { desc = "Buffers" })
map("n", "<leader>sh", "<cmd> Telescope help_tags <CR>", { desc = "Help tags" })
map("n", "<leader>sk", "<cmd> Telescope keymaps <CR>", { desc = "Keymaps" })
map("n", "<leader>sd", "<cmd> Telescope diagnostics <CR>", { desc = "Diagnostics" })
map("n", "<leader>sm", "<cmd> Telescope marks <CR>", { desc = "Marks" })

-- git
map("n", "<leader>gs", "<cmd> Telescope git_status <CR>", { desc = "Git status" })
map("n", "<leader>gg", function()
  Snacks.lazygit()
end, { desc = "Lazygit" })

-- code: lsp, format, diagnostics
map("n", "<leader>cf", function()
  require("conform").format()
end, { desc = "Format code" })
map("n", "<leader>ci", vim.diagnostic.open_float, { desc = "Cursor diagnostics" })

-- opencode
map("n", "<leader>oa", function()
  require("opencode").ask("@this: ")
end, { desc = "Ask OpenCode" })
map("x", "<leader>oa", function()
  require("opencode").ask("@this: ")
end, { desc = "Ask OpenCode" })
map("n", "<leader>os", function()
  require("opencode").select()
end, { desc = "Select OpenCode" })
map("n", "go", function()
  return require("opencode").operator("@this ")
end, { desc = "Append range to OpenCode", expr = true })

-- markdown
map("n", "<leader>md", "<cmd> RenderMarkdown toggle <CR>", { desc = "Toggle Markdown render" })
map("n", "<leader>mp", "<cmd> RenderMarkdown preview <CR>", { desc = "Markdown preview" })

-- snacks: terminal, dashboard
map("n", "<leader>tt", function()
  Snacks.terminal()
end, { desc = "Toggle terminal" })
map("n", "<leader>d", function()
  Snacks.dashboard()
end, { desc = "Dashboard" })

-- comment
map("n", "<leader>/", "gcc", { remap = true, desc = "Comment line" })
map("v", "<leader>/", "gc", { remap = true, desc = "Comment selection" })
