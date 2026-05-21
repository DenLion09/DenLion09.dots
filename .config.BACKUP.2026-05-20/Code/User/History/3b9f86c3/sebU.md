# My stack config

Estrategia de instalación (distro-agnóstico):

1. ¿Es GUI? → **Flatpak** (Flathub)
2. ¿Es CLI? → **Homebrew**
3. ¿Es servicio? → **Podman**
4. ¿No existe en nada? → **Script oficial**
5. ¿Driver/lib sistema? → **apt / gestor nativo**

---

## 📦 Flatpak — GUI (integrado, actualizado, sin pensar)

### 🧠 Desarrollo + IA

- [ ] **Jan** (`ai.jan.Jan`) — Asistente IA local 100% offline. Descarga y corre modelos (Llama, Qwen, Gemma) sin conexión. API compatible con OpenAI en `localhost:1337`. MCP support.
- [ ] **OpenCode GUI** (`ai.opencode.opencode`) — Coding agent open-source, multi-model, extensible vía plugins.
- [ ] **VSCode** (`com.vscodium.codium`) — Editor sin telemetría
- [ ] **DBeaver** (`io.dbeaver.DBeaverCommunity`) — Gestor multi-DB (PostgreSQL, MongoDB, etc.)
- [ ] **Bruno** (`com.usebruno.Bruno`) — API testing offline-first

### 📝 Productividad

- [ ] **Obsidian** (`md.obsidian.Obsidian`) — Notas Markdown
- [ ] **OnlyOffice** (`org.onlyoffice.desktopeditors`) — Ofimática (Word, Excel, PPT)
- [ ] **draw.io** (`com.jgraph.drawio.desktop`) — Diagramas
- [ ] **Evince** (`org.gnome.Evince`) — Lector PDF
- [ ] **Thunderbird** (`org.mozilla.Thunderbird`) — Email + Calendario

### 🔧 Sistema

- [ ] **KeePassXC** (`org.keepassxc.KeePassXC`) — Gestor de contraseñas
- [ ] **Flameshot** (`org.flameshot.Flameshot`) — Capturas de pantalla
- [ ] **OBS Studio** (`com.obsproject.Studio`) — Grabación de pantalla
- [ ] **Inkscape** (`org.inkscape.Inkscape`) — Diseño vectorial/SVG
- [ ] **GIMP** (`org.gimp.GIMP`) — Editor de imágenes
- [ ] **Font Manager** (`org.gnome.FontManager`) — Gestión de fuentes
- [ ] **Flatseal** (`com.github.tchx84.Flatseal`) — Gestor de permisos Flatpak

### ⏱ Time & Tasks

- [ ] **ActivityWatch** (`net.activitywatch.ActivityWatch`) — Time tracking automático

---

## 🍺 Homebrew — CLI + Fonts

### Shell

- [ ] **fish** — Shell moderna
- [ ] **starship** — Prompt minimalista
- [ ] **tmux** — Multiplexer de terminal

### Editores / TUI

- [ ] **neovim** — Editor terminal
- [ ] **zellij** — Multiplexer con UI (alternativa a tmux)
- [ ] **yazi** — File manager TUI

### CLI tools

- [ ] **bat** — cat con syntax highlighting
- [ ] **ripgrep** (rg) — grep ultrarrápido
- [ ] **fd** — find moderno
- [ ] **fzf** — Fuzzy finder
- [ ] **eza** — ls moderno
- [ ] **delta** — Diff con syntax highlighting
- [ ] **duf** — df con mejor UX
- [ ] **bottom** (btm) — htop moderno
- [ ] **lazygit** — Git TUI
- [ ] **gh** — GitHub CLI
- [ ] **httpie** — curl con UX mejorado
- [ ] **jq** — Procesador JSON CLI
- [ ] **yq** — Procesador YAML CLI

### Fonts (cask)

- [ ] **font-fira-code**
- [ ] **font-jetbrains-mono**
- [ ] **font-meslo-lg-nerd-font**

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

- [ ] **fnm** — Node version manager (`curl -fsSL https://fnm.vercel.app/install | bash`)
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
- Go (añadir)

### Frameworks

- **React** / **Next** / **Nest**
- **Astro**
- **Express**
- **Tauri** (Rust)
- **oclif** (CLI)

### Bases de datos

- **PostgreSQL** + pgvector
- **MongoDB**

---

## Gestores de sistema (no agnósticos — dependen de la distro)

### apt (Debian/Ubuntu)

- build-essential, libssl-dev, libpq-dev, etc.

### Drivers / Kernel

- NVIDIA
- Firmwares

---

## Pendientes

- [ ] Probar **Zed** como editor alternativo
- [ ] Solución a paquetes sin conexión
- [ ] Solución a documentación sin conexión
- [ ] Crear Brewfile + script de bootstrap para reproducción limpia
