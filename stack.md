# My stack config

Estrategia de instalación (distro-agnóstico):

1. ¿Es GUI? → **Flatpak** (Flathub)
2. ¿Es CLI? → **Homebrew**
3. ¿Es servicio? → **Podman**
4. ¿No existe en nada? → **Script oficial**
5. ¿Driver/lib sistema? → **apt / gestor nativo**

---

## 📦 Flatpak — GUI (integrado, actualizado, sin pensar)

### GUI - Sistema y configuracion

- [ ] Software (Flatpak GUI) - Simple rampisa y eficiente. GTK3/4.
- [ ] Blak Box terminal. Hermoza, configurable, GTK3/4

### 🧠 Desarrollo + IA

- [x] **Jan** (`ai.jan.Jan`) — Asistente IA local 100% offline. Descarga y corre modelos (Llama, Qwen, Gemma) sin conexión. API compatible con OpenAI en `localhost:1337`. MCP support.
- [x] **OpenCode GUI (beta)** (`ai.opencode.opencode`) — Coding agent open-source, multi-model, extensible vía plugins.
- [x] **Gentle AI** (config: `~/.config/opencode/AGENTS.md`) — Orquestador SDD con skills especializados (explore, propose, spec, design, tasks, apply, verify, archive). Corre sobre OpenCode.
- [x] **DBeaver** (`io.dbeaver.DBeaverCommunity`) — Gestor multi-DB (PostgreSQL, MongoDB, etc.)
- [x] **Bruno** (`com.usebruno.Bruno`) — API testing offline-first
- [x] **GitHub Desktop** (`io.github.shiftey.Desktop`) — Cliente Git GUI. Fork comunitario con soporte Linux. Diffs syntax highlighted, gestión de PRs, integración con editor y terminal.

### 📝 Productividad

- [x] **AppFlowy** (`io.appflowy.AppFlowy`) — Alternativa open-source a Notion. Notas, bases de datos, tareas, todo en uno. Nativo Rust+Flutter, offline, 84MB.
- [x] **Obsidian** (`md.obsidian.Obsidian`) — Notas Markdown
- [x] **OnlyOffice** (`org.onlyoffice.desktopeditors`) — Ofimática (Word, Excel, PPT)
- [x] **draw.io** (`com.jgraph.drawio.desktop`) — Diagramas
- [x] **Thunderbird** (`org.mozilla.Thunderbird`) — Email + Calendario

### 🎨 Diseño UI/UX

- [x] **Lunacy** (`com.icons8.Lunacy`) — Editor gráfico para UI/UX. Gratuito, offline, importa `.fig` de Figma. IA integrada: upscaling, remover fondos, generar texto/avatares. Librería de 1.5M+ iconos, fotos e ilustraciones.

### 🖥️ Interfaz unificada (GTK3/4) — evita conflictos de decoradores

> Para Hyprland/Noctalia: todas GTK para mantener theme consistente

| Categoría   | App (Flatpak)            | ID Flatpak                        | Notas                  |
| ----------- | ------------------------ | --------------------------------- | ---------------------- |
|             | **Black Box** (KGX)      | `com.raggesilver.BlackBox`        | GTK4 native            |
| Archivos    | **Nautilus**             | `org.gnome.Nautilus`              | Offic. GNOME Files     |
|             | **Thunar**               | `org.xfce.Thunar`                 | Más ligero             |
| Video       | **Celluloid**            | `io.github.GnomeDoctor.Celluloid` | GTK4, MPV frontend     |
|             | **GNOME Videos** (Totem) | `org.gnome.Totem`                 | Reproductor oficial    |
| Visor       | **Loupe**                | `org.gnome.Loupe`                 | Visor de imágenes GTK4 |
|             | **Eye of GNOME**         | `org.gnome.eog`                   | Alternativa            |
| Calculadora | **GNOME Calculator**     | `org.gnome.Calculator`            | GTK4                   |
| Mapas       | **Photon**               | `com.github.maoschanz.Photon`     | Visor de fotos GTK     |

### 🔧 Sistema

- [x] **KeePassXC** (`org.keepassxc.KeePassXC`) — Gestor de contraseñas
- [x] **Flameshot** (`org.flameshot.Flameshot`) — Capturas de pantalla
- [x] **OBS Studio** (`com.obsproject.Studio`) — Grabación de pantalla
- [x] **Inkscape** (`org.inkscape.Inkscape`) — Diseño vectorial/SVG
- [x] **GIMP** (`org.gimp.GIMP`) — Editor de imágenes
- [x] **Font Manager** (`org.gnome.FontManager`) — Gestión de fuentes
- [x] **Flatseal** (`com.github.tchx84.Flatseal`) — Gestor de permisos Flatpak

### ⏱ Time & Tasks

- [ ] **ActivityWatch** (`net.activitywatch.ActivityWatch`) — Time tracking automático

### 🎮 Gaming

- [ ] **Steam** (`com.valvesoftware.Steam`) — Tienda y lanzador de juegos. Proton para juegos Windows.
- [ ] **Lutris** (`net.lutris.Lutris`) — Plataforma de preservación de juegos. Lo UNIFICATODO: Steam, GOG, Epic, ISOs, .exe sueltos, Wine prefixes, emuladores. Un solo lanzador para cubrir todo.

### 🎮 Periféricos (por si acaso)

- [ ] **xboxdrv** — Emula cualquier control como Xbox 360 (XInput). Necesario para juegos viejos de Windows que no detectan controles modernos. (`brew install xboxdrv` o gestor nativo)
- [ ] **sc-controller** (AppImage) — Remapeo avanzado de controles, perfiles por juego, giroscopio, macros. Alternativa system-wide a Steam Input. (`https://github.com/C0rn3j/sc-controller/releases`)

---

## 🌐 Descarga directa — No Flatpak (oficial, sin gestor de paquetes)

- [ ] **VSCode** (`https://code.visualstudio.com/download`) — Editor oficial de Microsoft con telemetría parcialmente configurable. Soporte nativo de ESLint, Prettier, Git, GitHub Copilot, Live Share, y miles de extensiones en marketplace.

---

## 🍺 Homebrew — CLI + Fonts

### Shell

- [ ] **fish** — Shell moderna (configuracion ia first)
- [ ] **starship** — Prompt minimalista

### TUI

- [ ] **yazi** — File manager TUI
- [ ] **lazygit** — Git TUI

### CLI tools

- [ ] **bat** — cat con syntax highlighting
- [ ] **ripgrep** (rg) — grep ultrarrápido
- [ ] **fd** — find moderno
- [ ] **fzf** — Fuzzy finder
- [ ] **eza** — ls moderno
- [ ] **delta** — Diff con syntax highlighting
- [ ] **duf** — df con mejor UX
- [ ] **bottom** (btm) — htop moderno
- [ ] **gh** — GitHub CLI
- [ ] **httpie** — curl con UX mejorado
- [ ] **jq** — Procesador JSON CLI
- [ ] **yq** — Procesador YAML CLI

### Fonts (cask)

- [ ] **Cascadia Code nerd font**

---

## 🐳 Podman — Servicios (aislados, portables)

- [ ] **PostgreSQL + pgvector** — Base de datos + búsqueda semántica
- [ ] **Open WebUI** — Interfaz LLM local (si no va por Flatpak)
- [ ] **Plane** — Gestor de proyectos (Kanban, issues, calendario)
- [ ] **n8n** — Automatización tipo Zapier/Make
- [ ] **Vaultwarden** — Bitwarden server auto-hosteado
- [ ] **Woodpecker CI** — CI/CD liviano

---

## 📜 Scripts oficiales

- [ ] **nvm** — Node version manager (`curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash`)
- [ ] **uv** — Python version manager + package resolver (`curl -LsSf https://astral.sh/uv/install.sh | sh`)
- [ ] **rustup** — Rust toolchain (`curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`)
- [ ] **Ollama** — LLMs locales (`curl -fsSL https://ollama.com/install.sh | sh`)
- [ ] **mise** — Version manager todo-en-uno (opcional, unifica fnm + uv + rustup)

---

## 🛠️ Version Managers

| Lenguaje | Tool       | Comando                           |
| -------- | ---------- | --------------------------------- |
| Node.js  | **fnm**    | `fnm install 22`                  |
| Python   | **uv**     | `uv python install 3.12`          |
| Rust     | **rustup** | `rustup toolchain install stable` |
| Go       | **g**      | `g install 1.22`                  |
| Java     | **sdkman** | `sdk install java 21`             |

## 📦 Gestores de paquetes de lenguajes

| Lenguaje | Tool              | Para                                           |
| -------- | ----------------- | ---------------------------------------------- |
| Python   | **pipx**          | Apps CLI Python (httpie, poetry, cookiecutter) |
| Rust     | **cargo install** | Apps CLI Rust                                  |
| Node     | **pnpm**          | Proyectos JS/TS                                |
| Go       | **go install**    | Apps CLI Go                                    |

---

## Stack de desarrollo

### Lenguajes

- JavaScript / TypeScript
- Python
- Rust
- Go

### Frameworks

- **React** / **Next** / **Nest**
- **Astro**
- **Express**
- **Tauri** (Rust)
- **oclif** (CLI)

### Bases de datos

- **PostgreSQL**
- **MongoDB**

---

## Gestores de sistema (no agnósticos — dependen de la distro)

### apt (Debian/Ubuntu)

- build-essential, libssl-dev, libpq-dev, etc.

### Drivers / Kernel

- NVIDIA / INTEL / AMD
- Firmwares

---

## Pendientes

- [ ] Probar **Zed** como editor alternativo
- [ ] Solución a paquetes sin conexión
- [ ] Solución a documentación sin conexión
