# DenLion09 Dots

Configuración y automatización del stack de desarrollo personal sobre **Debian 13 Trixie**.

## Instalación

Una línea para descargar y ejecutar el instalador interactivo desde GitHub:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/DenLion09/DenLion09.dots/master/install.sh)
```

El instalador ofrece tres modos:

| Modo | Descripción |
|------|-------------|
| **Todo de una** | Instala todo el stack en secuencia automática |
| **Uno por uno** | Aprobás cada herramienta antes de instalarla |
| **Selección** | Marcás con checkboxes y se instalan en lote |

Además incluye un modo **Startup** para configuración inicial del sistema (GRUB, shell, etc.) y un modo **Solo configs** para desplegar las configuraciones desde el backup incluido en el repo.

> **Nota**: El script está pensado para Debian 13 Trixie (o derivados basados en apt). Detecta automáticamente `sudo` y la arquitectura del sistema.

---

## Stack de Terminal

| Programa | Descripción |
|----------|-------------|
| **[Fish Shell](https://fishshell.com/)** | Shell interactiva moderna con autosugerencias, syntax highlighting y completado nativo |
| **[Starship](https://starship.rs/)** | Prompt minimalista y rápido, escrito en Rust, configurable via TOML |
| **[Atuin](https://atuin.sh/)** | Historial de comandos con búsqueda fuzzy, timestamps y sincronización |
| **[fzf](https://github.com/junegunn/fzf)** | Fuzzy finder universal — archivos, historial, procesos, todo desde la terminal |
| **[Carapace](https://carapace-sh.github.io/carapace-bin/)** | Autocompletado universal para cualquier comando, puente entre shells |
| **[bottom](https://github.com/ClementTsang/bottom)** | Monitor del sistema CLI (`btm`) en Rust, más ligero que btop |

### Plugins de Fish (Fisher)

| Plugin | Propósito |
|--------|-----------|
| `jorgebucaran/fisher` | Gestor de plugins para Fish |
| `jorgebucaran/nvm.fish` | Node Version Manager integrado en Fish |
| `patrickf1/fzf.fish` | Integración de fzf: historial, archivos, directorios, procesos |
| `oh-my-fish/plugin-pj` | Project jumper — salta a proyectos por nombre |

---

## CLI Tools

| Programa | Descripción |
|----------|-------------|
| **[ripgrep](https://github.com/BurntSushi/ripgrep)** (`rg`) | grep ultrarápido, recursivo, respeta `.gitignore` |
| **[fd](https://github.com/sharkdp/fd)** | find moderno, sintaxis intuitiva, colores por tipo |
| **[eza](https://github.com/eza-community/eza)** | ls moderno con colores, iconos y vista en árbol |
| **[yazi](https://yazi-rs.github.io/)** | File manager TUI con previews, tabs y herramientas externas |
| **[fastfetch](https://github.com/fastfetch-cli/fastfetch)** | Información del sistema (neofetch moderno) |
| **[bat](https://github.com/sharkdp/bat)** | cat con syntax highlighting, números de línea e integración con git |
| **[jq](https://jqlang.github.io/jq/)** | Procesador JSON desde la terminal |
| **[yq](https://github.com/kislyuk/yq)** | Procesador YAML/XML/TOML desde la terminal |

---

## Font

| Programa | Descripción |
|----------|-------------|
| **Cascadia Cove Nerd Font** | Fuente monoespaciada con ligaduras, powerline y glyphs de Nerd Fonts |

---

## Entornos de Desarrollo

| Programa | Descripción |
|----------|-------------|
| **[mise](https://mise.jdx.dev/)** | Monoherramienta que reemplaza nvm, cargo, pip y más |
| **[Node.js](https://nodejs.org/)** | LTS automático vía mise |
| **[Bun](https://bun.sh/)** | Runtime JS/TS todo-en-uno (bundler, runner, package manager) |
| **[Rust](https://www.rust-lang.org/)** | Lenguaje de sistemas, instalado vía rustup con cargo y rustc |

---

## Herramientas de Desarrollo

| Programa | Descripción |
|----------|-------------|
| **[pnpm](https://pnpm.io/)** | Gestor de paquetes Node.js rápido, eficiente en disco |
| **[Git](https://git-scm.com/)** | Control de versiones |
| **[GitHub CLI](https://cli.github.com/)** (`gh`) | Issues, PRs, repos y más desde la terminal |
| **[Podman](https://podman.io/)** | Contenedores rootless, compatible con Docker |
| **[pgcli](https://www.pgcli.com/)** | CLI de PostgreSQL con autocompletado y syntax highlighting |
| **[MongoDB Shell](https://www.mongodb.com/products/tools/shell)** (`mongosh`) | Shell oficial de MongoDB |
| **[portless](https://portless.dev/)** | Reemplaza números de puerto por URLs `.localhost` estables |

---

## Aplicaciones de Desarrollo (GUI)

| Programa | Descripción |
|----------|-------------|
| **[Kitty](https://sw.kovidgoyal.net/kitty/)** | Terminal GPU-accelerada, tabs, Wayland nativo, Nerd Fonts |
| **[Alacritty](https://alacritty.org/)** | Terminal ultraligera en Rust, GPU, Wayland |
| **[Neovim](https://neovim.io/)** | Editor TUI superextensible (última release oficial, no apt) |
| **[Neovide](https://neovide.dev/)** | GUI gráfica para Neovim con animaciones fluidas y Wayland |
| **[OpenCode](https://opencode.ai/)** | Terminal agentic AI para desarrollo |
| **[GitHub Desktop](https://github.com/shiftkey/desktop)** | Cliente gráfico de Git |
| **[DBeaver](https://dbeaver.io/)** | Gestor multi-DB: PostgreSQL, MongoDB, SQLite, MySQL y más |
| **[Bruno](https://www.usebruno.com/)** | API testing offline-first con editor directo de colecciones |
| **[OpenPencil](https://github.com/ZSeven-W/openpencil)** | Editor de diseño tipo Figma con MCP para asistentes de IA |
| **[Godot Engine](https://godotengine.org/)** | Motor de videojuegos open-source |
| **[draw.io](https://www.drawio.com/)** | Diagramas y mapas conceptuales |

### Herramientas del sistema (GUI)

| Programa | Descripción |
|----------|-------------|
| **[Nautilus](https://apps.gnome.org/Nautilus/)** | Gestor de archivos GNOME |
| **Nautilus Console** | "Abrir terminal aquí" en el menú contextual |
| **File Roller** | Gestor de archivos comprimidos (ZIP, tar, etc.) |
| **p7zip-full** | Soporte para archivos 7z |
| **unrar** | Extracción de archivos RAR |
| **[Sushi](https://apps.gnome.org/Sushi/)** | Vista previa rápida de archivos con la barra espaciadora |

---

## Archivos de Configuración

El repo incluye configuraciones listas para desplegar en `~/.config/`:

| Ruta | Descripción |
|------|-------------|
| `fish/` | Shell Fish — config.fish, funciones, temas, plugins |
| `nvim/` | Neovim — init.lua, lazy.nvim, LSPs y plugins |
| `kitty/` | Kitty terminal — config |
| `.config.BACKUP.*/` | Backup completo de configs (starship, atuin, fish, opencode) |

### Neovim

Configuración basada en lazy.nvim con:

- **LSP**: html, cssls, lua_ls, ts_ls, pyright, rust_analyzer, jsonls, marksman, eslint
- **Plugins**: telescope, blink.cmp, conform (formateo al guardar), snacks.nvim, treesitter, render-markdown (con soporte Mermaid), opencode.nvim
- **Tema**: github-nvim-theme (dark/light, colorblind-friendly)
- **Mason**: instalación de LSPs y formateadores desde Neovim

### Fish Shell

- **Prompt**: Starship con paleta DenLion09 (basada en GitHub Colorblind Dark)
- **Historial**: Atuin con búsqueda fuzzy (`Ctrl+R`)
- **Autocompletado**: Carapace universal
- **Funciones**: `fzfbat`, `fzfnvim`, `hotspot`, `desktop-*`, `restart-noctalia`

---

## Stack Adicional

Herramientas documentadas en la configuración que pueden instalarse manualmente:

- **Sistema**: earlyoom, powertop, tlp, thermald, timeshift, restic
- **Multimedia**: mpv, Loupe (visor), Photon (fotos), Flameshot (capturas), grim + slurp
- **Conectividad**: LocalSend, linux-wifi-hotspot, Proton VPN
- **Comunicación**: Discord, Telegram Desktop, WhatsApp Desktop
- **Productividad**: Proton Mail/Calendar/Drive/Pass, OnlyOffice, Firefox
- **Juegos**: Lutris
- **Utilidades**: BalenaEtcher, GParted
- **Escritorio**: Labwc + Noctalia Shell sobre Wayland

---

## Personalización

El instalador también permite:

- Cambiar la shell por defecto a Fish
- Configurar Nautilus como gestor de archivos predeterminado
- Crear wrappers para binarios Debian (batcat → bat, fdfind → fd)
- Desplegar configuraciones desde el backup incluido
- Clonar configs de Fish y Neovim directamente desde el repo

---

## Licencia

MIT
