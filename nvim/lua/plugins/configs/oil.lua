return {
  default_file_explorer = true,
  columns = {
    "icon",
    "permissions",
    "size",
    "mtime",
  },
  keymaps = {
    ["<C-p>"] = false,
    ["<C-l>"] = false,
    ["<C-h>"] = false,
  },
  view_options = {
    show_hidden = true,
  },
  -- oil will show dotfiles and cleanup the float window
  float = {
    padding = 2,
    max_width = 90,
    max_height = 0,
  },
}
