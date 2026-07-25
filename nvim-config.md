# Configuración de Neovim

Basada en [TinyVim](https://github.com/NvChad/tinyvim) de NvChad — minimalista, con lazy.nvim como gestor de plugins.

## Filosofía

- Configuración mínima pero funcional, sin hardcore lazyloading
- Plugins esenciales sin sobrecarga innecesaria
- LSP, autocompletado, formateo y navegación listos desde el inicio

## Estructura de archivos

```
~/.config/nvim/
├── init.lua                 # Entry point
├── lazy-lock.json           # Lock de versiones de plugins
├── .stylua.toml             # Config de StyLua (formateador Lua)
├── lua/
│   ├── options.lua          # Opciones globales de Neovim
│   ├── mappings.lua         # Atajos de teclado
│   ├── commands.lua         # Comandos y autocmds personalizados
│   ├── lazy_config.lua      # Configuración de lazy.nvim
│   └── plugins/
│       ├── init.lua         # Declaración de plugins
│       └── configs/         # Configuraciones individuales
│           ├── blink.lua
│           ├── conform.lua
│           ├── lspconfig.lua
│           ├── oil.lua
│           ├── opencode.lua
│           ├── render-markdown.lua
│           ├── snacks.lua
│           ├── telescope.lua
│           ├── treesitter.lua
│           └── which-key.lua
```

## init.lua (Entry point)

- Desactiva netrw (oil.nvim toma el control de navegación de directorios)
- Carga: `options`, `mappings`, `commands`
- Bootstrap de lazy.nvim (clonado automático si no existe)
- Carga los plugins (el colorscheme lo define el plugin github-nvim-theme)

## options.lua — Opciones globales

| Opción | Valor | Descripción |
|--------|-------|-------------|
| `mapleader` | Espacio | Tecla líder |
| `laststatus` | 3 | Statusline global (una sola para toda la ventana) |
| `showmode` | false | No mostrar modo (ya lo maneja la statusline) |
| `clipboard` | unnamedplus | Copia al portapapeles del sistema |
| `expandtab` | true | Espacios en vez de tabs |
| `shiftwidth` | 2 | Indentación de 2 espacios |
| `tabstop` / `softtabstop` | 2 | Tamaño de tabulación |
| `smartindent` | true | Indentación inteligente |
| `ignorecase` / `smartcase` | true | Búsqueda case-insensitive inteligente |
| `mouse` | a | Soporte de ratón |
| `number` | true | Números de línea |
| `signcolumn` | yes | Columna de signos siempre visible |
| `splitbelow` / `splitright` | true | Splits hacia abajo y derecha |
| `termguicolors` | true | Colores true color |
| `timeoutlen` | 400 | Timeout para secuencias de teclas |
| `undofile` | true | Historial de cambios persistente |
| `cursorline` | true | Resaltar línea actual |
| `fillchars.eob` | `" "` | Sin caracteres `~` en líneas vacías |
| `IndentLine` highlight | Link a `Comment` | Color de líneas de indentación |

- Agrega `mason/bin` al PATH automáticamente

## mappings.lua — Atajos de teclado

### Generales

| Atajo | Acción |
|-------|--------|
| `<C-s>` | Guardar archivo |
| `jk` (insert mode) | Salir al modo normal |
| `<C-c>` | Copiar todo el archivo al portapapeles |
| `<C-q>` | Cerrar buffer (`:bd`) |

### NvimTree

| Atajo | Acción |
|-------|--------|
| `<C-n>` | Toggle NvimTree |
| `<C-h>` | Foco en NvimTree |

### Find — Telescope (archivos)

| Atajo | Acción |
|-------|--------|
| `<leader>ff` | Buscar archivos |
| `<leader>fo` | Archivos recientes |
| `<leader>fw` | Live grep (buscar texto) |

### Search — Telescope (código/contenido)

| Atajo | Acción |
|-------|--------|
| `<leader>sb` | Buffers abiertos |
| `<leader>sh` | Help tags |
| `<leader>sk` | Keymaps |
| `<leader>sd` | Diagnostics |
| `<leader>sm` | Marks |

### Git

| Atajo | Acción |
|-------|--------|
| `<leader>gs` | Git status (Telescope) |
| `<leader>gg` | Lazygit (Snacks) |

### Code (LSP, format)

| Atajo | Acción |
|-------|--------|
| `<leader>cf` | Formatear con conform.nvim |
| `<leader>ci` | Cursor diagnostics — abre float con diagnóstico bajo el cursor |

### OpenCode

| Atajo | Modo | Acción |
|-------|------|--------|
| `<leader>oa` | Normal/Visual | Ask — promptea a OpenCode con contexto `@this:` |
| `<leader>os` | Normal | Select — menú de prompts, comandos y servidores |
| `go` | Normal | Operator — envía rango vía motion (ej: `goiw`) |

### Markdown

| Atajo | Acción |
|-------|--------|
| `<leader>md` | Toggle render-markdown |
| `<leader>mp` | Preview render-markdown |

### Terminal

| Atajo | Acción |
|-------|--------|
| `<leader>tt` | Toggle terminal (Snacks) |

### Dashboard

| Atajo | Acción |
|-------|--------|
| `<leader>d` | Abrir dashboard (Snacks) |

### Comentarios

| Atajo | Acción |
|-------|--------|
| `<leader>/` (normal) | Comentar/descomentar línea |
| `<leader>/` (visual) | Comentar/descomentar selección |

## commands.lua — Comandos y Autocmds

### Comandos personalizados

| Comando | Acción |
|---------|--------|
| `:MasonInstallAll` | Instala LSPs y formateadores: css-lsp, html-lsp, lua-language-server, typescript-language-server, stylua, prettier, mermaid-cli |
| `:TSInstallAll` | Instala todos los parsers de treesitter configurados |

### Autocmds

- **FileType *** → Inicia treesitter en todo archivo (con `pcall` para no fallar si no hay parser)

## lazy_config.lua

Configuración mínima de lazy.nvim:

```lua
{
  install = { colorscheme = { "github_dark_colorblind", "github_light_colorblind" } },
}
```

## Plugins

### nvim-lua/plenary.nvim

Utilidades para Lua. Dependencia de otros plugins. Carga diferida automática.

### nvim-tree/nvim-tree.lua

Explorador de archivos en árbol. Se activa con `:NvimTreeToggle` y `:NvimTreeFocus`. Configuración por defecto.

### stevearc/oil.nvim

Navegador de archivos tipo editor (editas el directorio como un buffer). Reemplaza a netrw. Configuración:

- **default_file_explorer**: true
- **Columnas**: icono, permisos, tamaño, fecha modificación
- **Keymaps**: desactiva `<C-p>`, `<C-l>`, `<C-h>` (conflicto con navegación)
- **show_hidden**: true
- **Float window**: padding 2, max_width 90, auto altura

### nvim-treesitter/nvim-treesitter

Resaltado de sintaxis mejorado y análisis estructural. Parsers instalados:

| Parser | Lenguaje |
|--------|----------|
| `lua` | Lua |
| `vim` / `vimdoc` | VimL |
| `javascript` / `typescript` | JavaScript / TypeScript |
| `tsx` | React TSX |
| `html` / `css` | HTML / CSS |
| `json` | JSON |
| `python` | Python |
| `rust` | Rust |
| `bash` | Shell script |
| `markdown` / `markdown_inline` | Markdown |
| `yaml` | YAML |
| `toml` | TOML |
| `mermaid` | Diagramas Mermaid |
| `regex` | Expresiones regulares |
| `luadoc` / `printf` | Documentación Lua / printf |

Se actualiza con `:TSUpdate`.

### saghen/blink.cmp

Motor de autocompletado (versión 1.x). Se carga al entrar en Insert mode.

- **Snippets**: LuaSnip + friendly-snippets
- **Autopairs**: nvim-autopairs
- **Fuentes**: LSP, snippets, buffer, path
- **Fuzzy**: `prefer_rust` (usa fuzzy nativo Rust si está disponible)
- **Ghost text**: activado
- **Documentación**: auto-show a los 200ms, borde "single"
- **Keymaps**: `<CR>` acepta, `<C-b/f>` scroll docs

### williamboman/mason.nvim

Gestor de instalación de LSPs, formateadores y linters. Se actualiza con `:MasonUpdate`.

### neovim/nvim-lspconfig + lspconfig.lua

Configuración de servidores LSP. Usa la API moderna `vim.lsp.enable()` (Neovim >= 0.11).

**LSPs configurados**:

| LSP | Lenguaje |
|-----|----------|
| `html` | HTML |
| `cssls` | CSS |
| `lua_ls` | Lua |
| `ts_ls` | TypeScript/JavaScript |
| `pyright` | Python |
| `rust_analyzer` | Rust |
| `jsonls` | JSON |
| `marksman` | Markdown |
| `eslint` | ESLint |

**Keymaps LSP** (auto-definidos en `LspAttach`):

| Atajo | Acción |
|-------|--------|
| `gd` | Ir a definición |
| `gD` | Ir a declaración |
| `gi` | Ir a implementación |
| `gr` | Ir a referencias |
| `<leader>D` | Ir a type definition |
| `K` | Hover |
| `<leader>cs` | Signature help |
| `<leader>ca` | Code action (normal y visual) |
| `<leader>cr` / `<leader>rn` | Rename |
| `<leader>cd` | Document symbols |
| `<leader>cD` | Workspace symbols |
| `<leader>wa` | Add workspace folder |
| `<leader>wr` | Remove workspace folder |
| `<leader>wl` | List workspace folders |
| `<leader>ch` | Toggle inlay hints |
| `gl` | Diagnostic float |
| `[d` / `]d` | Diagnostic anterior/siguiente |
| `[e` / `]e` | Error anterior/siguiente |
| `<leader>ci` | Cursor diagnostics — abre float con diagnóstico bajo el cursor |
| `<leader>cl` | Diagnostic a location list |

### stevearc/conform.nvim

Formateador automático. **Formatea al guardar** (formateo automático con `format_on_save`). También manual con `<leader>cf`.

| Filetype | Formateador |
|----------|-------------|
| lua | stylua |
| javascript / javascriptreact | prettier |
| typescript / typescriptreact | prettier |
| json | prettier |
| html | prettier |
| css | prettier |
| python | ruff |
| rust | rustfmt (fallback LSP) |
| sh / bash / zsh | shfmt |

**Autoformat config:**

```lua
{
  format_on_save = {
    timeout_ms = 500,
    lsp_format = "fallback",
  },
}
```

### folke/snacks.nvim

Suite de utilidades (carga inmediata, priority 1000). Módulos activados:

| Módulo | Descripción |
|--------|-------------|
| animate | Animaciones suaves (scroll, cursor) |
| dashboard | Pantalla de inicio personalizada con header ASCII y acceso rápido a oil.nvim |
| gh | Integración con GitHub |
| input | Input mejorado con LSP completions (usado por opencode.nvim Ask) |
| git | Git integrado (hunks, signs, blame) |
| rename | Renombrar inteligente |
| scope | Seguimiento del scope actual (función, bloque) |
| scroll | Scroll suave |
| terminal | Gestión de terminales mejorada |
| util | Utilidades (mover, saltar) |
| words | Resaltado de palabras coincidentes |

### folke/which-key.nvim

Ayuda contextual de atajos. Grupos definidos:

| Prefijo | Grupo |
|---------|-------|
| `<leader>c` | code |
| `<leader>f` | find |
| `<leader>g` | git |
| `<leader>m` | markdown |
| `<leader>o` | opencode |
| `<leader>s` | search |
| `<leader>t` | terminal |
| `<leader>w` | workspace |

Borde redondeado en la ventana.

### nickjvandyke/opencode.nvim

Plugin Neovim que integra [OpenCode](https://opencode.ai/) en Neovim — prompts, contexto del editor, comandos y eventos sin salir de Neovim.

**Archivos de configuración:**

| Archivo | Propósito |
|---------|-----------|
| `lua/plugins/init.lua` | Plugin spec lazy.nvim (version pin `*`) |
| `lua/plugins/configs/opencode.lua` | `vim.g.opencode_opts` con arranque en snacks.terminal |
| `lua/plugins/configs/snacks.lua` | Módulo `input` activado para LSP completions en Ask |

**Integraciones:**
- **snacks.terminal**: arranca `opencode --port` en terminal derecha si no está corriendo
- **snacks.input**: autocompletado LSP y resaltado en el prompt Ask

**Contextos disponibles en prompts:**

| Placeholder | Contexto |
|-------------|----------|
| `@this` | Rango/selección actual, o posición del cursor |
| `@buffer` | Buffer actual |
| `@buffers` | Buffers abiertos |
| `@diagnostics` | Diagnósticos LSP en el rango/buffer |
| `@marks` | Marcas globales |
| `@quickfix` | Lista quickfix |
| `@visible` | Texto visible en pantalla |

**Prompts incorporados (acceso vía `<leader>os`):**

| Prompt | Acción |
|--------|--------|
| `diagnostics` | Explica diagnósticos |
| `document` | Documenta el código |
| `explain` | Explica el código y su contexto |
| `fix` | Corrige diagnósticos |
| `implement` | Implementa código |
| `optimize` | Optimiza rendimiento y legibilidad |
| `review` | Revisa corrección y legibilidad |
| `test` | Añade tests |

### nvimdev/indentmini.nvim

Líneas de indentación minimalistas. Se activa al leer buffers o crear archivos nuevos. Configuración por defecto.

### nvim-telescope/telescope.nvim

Buscador fuzzy. Orden ascendente, prompt en la parte superior.

### MeanderingProgrammer/render-markdown.nvim

Renderizador de Markdown en Neovim. Mejora la visualización de archivos markdown con soporte para diagramas **Mermaid** (vía `mermaid-cli`).

**Características:**
- Renderiza títulos, tablas, listas, blockquotes, checkboxes, callouts
- Resalta bloques de código con iconos de lenguaje y fondo
- Renderiza diagramas Mermaid (`mmdc`) dentro de bloques de código
- Renderiza LaTeX inline y en bloque
- Vista modal: raw vs renderizado según el modo de Neovim
- Anti-conceal: muestra el texto original al pasar el cursor

**Dependencias:**
- `mermaid-cli` (mmdc) — instalado vía Mason o npm: `npm install -g @mermaid-js/mermaid-cli`
- Parser `mermaid` de treesitter

**Configuración:**

```lua
{
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  opts = {
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
  },
}
```

**Comandos:**

| Comando | Acción |
|---------|--------|
| `:RenderMarkdown toggle` | Activar/desactivar renderizado |
| `:RenderMarkdown preview` | Vista previa en split lateral |

Si `mermaid-cli` no está disponible globalmente, instalarlo con npm:
```bash
npm install -g @mermaid-js/mermaid-cli
```
O desde Mason con `:MasonInstall mermaid-cli`.

### projekt0n/github-nvim-theme

Colorscheme que replica los temas de GitHub UI con soporte para daltonismo (colorblind). Reemplaza a nightfox.nvim.

- **Variante oscura**: `github_dark_colorblind` (por defecto)
- **Variante clara**: `github_light_colorblind`
- Basado en [Primer Design System](https://primer.style/)
- Compilación de configuración con `:GithubThemeCompile`
- Soporte completo para Treesitter, LSP, plugins

Ver sección [Colorscheme](#colorscheme) para configuración detallada.

### Otros plugins

| Plugin | Propósito |
|--------|-----------|
| nvim-web-devicons | Iconos de archivo |
| mini.statusline | Barra de estado minimalista |
| gitsigns.nvim | Signos de git en el gutter |
| github-nvim-theme | Colorscheme (github-colorblind-dark / github-colorblind-white) |
| render-markdown.nvim | Renderizado de Markdown con soporte Mermaid |
| LuaSnip + friendly-snippets | Motor y colección de snippets |
| nvim-autopairs | Auto-cierre de paréntesis, corchetes, etc. |
| which-key.nvim | Ayuda de atajos contextual |

## Colorscheme

**github-nvim-theme** ([projekt0n/github-nvim-theme](https://github.com/projekt0n/github-nvim-theme)) — temas que replican los colorschemes de GitHub con soporte para daltonismo (colorblind).

### Variantes

| Tema | Comando |
|------|---------|
| `github_dark_colorblind` | `:colorscheme github_dark_colorblind` |
| `github_light_colorblind` | `:colorscheme github_light_colorblind` |

### Configuración

```lua
{
  "projekt0n/github-nvim-theme",
  name = "github-theme",
  lazy = false,
  priority = 1000,
  config = function()
    require("github-theme").setup({
      options = {
        transparent = false,
        hide_end_of_buffer = true,
        styles = {
          comments = "italic",
          functions = "bold",
          keywords = "bold",
        },
        darken = {
          floats = true,
          sidebars = { enable = true },
        },
      },
    })

    -- Tema oscuro por defecto (colorblind-friendly)
    vim.cmd("colorscheme github_dark_colorblind")
  end,
}
```

### Cambio rápido entre temas

Para cambiar al tema claro sin daltonismo:
```
:colorscheme github_light_colorblind
```

> **Nota**: Requiere compilar la configuración con `:GithubThemeCompile` si se personalizan paletas.

## Formateo de código (StyLua)

`.stylua.toml` para archivos Lua:

- Column width: 120
- Line endings: Unix
- Indent: 2 espacios
- Quotes: AutoPreferDouble (dobles por defecto)
- Call parentheses: None (omitir paréntesis innecesarios)
