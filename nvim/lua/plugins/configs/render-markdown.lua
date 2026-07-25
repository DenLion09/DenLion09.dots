return {
  enabled = true,
  file_types = { "markdown", "vimwiki" },
  code = {
    enabled = true,
    sign = true,
    language_icon = true,
    language_name = true,
    width = "full",
  },
  heading = {
    enabled = true,
    icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
    position = "overlay",
    width = "block",
  },
  latex = {
    enabled = true,
    converter = { "utftex", "latex2text" },
  },
}
