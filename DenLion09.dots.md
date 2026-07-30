# Configuracion de Sistema - Debian 13 Trixie

Estrategia de instalación:

- 1. ¿Es GUI? → **Empaquetado oficial directo del repositorio (si existe)**
- 2. ¿Es CLI? → **Script oficial o cargo/pip (si no está empaquetado)**
- 3. ¿Driver/lib de sistema? → **Gestor nativo**
- 4. **No brew** — herramientas CLI via cargo/pip/script oficial
- 5. **Flatpak solo como excepción** — cuando no existe .deb oficial y las dependencias nativas son inmanejables

> [important] Crear TUI para automatizar la Instalación, Configuracion y Actualizacion, Backups

## Fuente 

- **Cascadia Cove Nerd Font**

## Terminal Shell

- **Shell actual**: fish shell

### Configuraciones

- **starship**: prompt minimalista y vacío
- **atuin**: historial de comandos con búsqueda fuzzy
- **fzf**: fuzzy finder
- **carapace**: autocompletado universal
- **bottom (btm)**: System CLI taskmanager — Rust, más ligero que btop
- **grep**: **ripgrep (rg)** grep ultrarapido
- **find**: **fd** — find moderno y rápido
- **navegacion**: **eza** — ls moderno con colores e iconos
- **file manager TUI**: **yazi**
- **info sistema**: **fastfetch** — neofetch moderno
- **bat**: cat con syntax highlighting (usado en fzfbat)
- **jq**: procesador JSON desde la terminal
- **yq**: procesador YAML/XML/TOML desde la terminal

### Plugins (fisher)

| Plugin | Descripción |
|--------|-------------|
| `jorgebucaran/fisher` | Gestor de plugins |
| `jorgebucaran/nvm.fish` | Node Version Manager |
| `patrickf1/fzf.fish` | Integración de fzf (historial, archivos, etc.) |
| `oh-my-fish/plugin-pj` | Project jumper — salta a proyectos por nombre |

### Archivos de configuración

```
~/.config/fish/config.fish         # Configuración principal
~/.config/fish/fish_plugins        # Lista de plugins (fisher)
~/.config/fish/fish_variables      # Variables universales
~/.config/fish/functions/          # Funciones personalizadas
~/.config/fish/completions/        # Completions (carapace)
~/.config/fish/conf.d/             # Configuraciones adicionales
~/.config/fish/themes/             # Temas
```

### Fish Functions / Alias

| Función/Alias | Comando | Descripción |
|---------------|---------|-------------|
| `c` | `clear` | Limpia la terminal |
| `q` | `exit` | Sale de la shell |
| `ll` | `ls -l` | Lista detallada |
| `la` | `ls -a` | Lista con archivos ocultos |
| `lla` | `ls -la` | Lista detallada con ocultos |
| `fzfbat` | `fzf --preview="bat --theme=gruvbox-dark --color=always {}"` | Buscar archivos con previsualización |
| `fzfnvim` | `nvim (fzf --preview="bat --theme=gruvbox-dark --color=always {}")` | Abrir archivo con fzf + nvim |
| `hotspot` | `create_ap` wrapper | Toggle WiFi hotspot on/off |
| `restart-noctalia` | `quickshell kill -c noctalia-shell; and qs -c noctalia-shell -d` | Reinicia Noctalia Shell |
| `desktop-set` | `echo "Session=..." > ~/.dmrc` | Cambia sesión por defecto |
| `desktop-apply` | `sed -i en lightdm.conf` | Aplica cambio de sesión (sudo) |
| `desktop-status` | `grep` en `.dmrc` y `lightdm.conf` | Muestra la sesión activa |

### Entorno

| Variable | Valor | Propósito |
|----------|-------|-----------|
| `EDITOR` | `nvim` | Editor por defecto |
| `VISUAL` | `nvim` | Editor visual |
| `CARAPACE_BRIDGES` | `zsh,fish,bash,inshellisense` | Fuentes de completions |

## Escritorio

**Actual**:
- **Compositor**: Wayland
- **Controlador de ventanas**: Labwc
- **Wayland desktop Shell**: Noctalia Shell
- **Gestor de sesión**: greetd + Noctalia Greeter

#### Plugins de Noctalia activos

| Plugin | Descripción |
|--------|-------------|
| `calendar-widget` | Calendario en la barra/panel |
| `catwalk` | Catwalk screensaver |
| `custom-commands` | Comandos personalizados desde el launcher |
| `dmenu` | Lanzador tipo dmenu |
| `file-search` | Búsqueda de archivos |
| `kaomoji-provider` | Insertar kaomojis desde el launcher |
| `keybind-cheatsheet` | Guía de atajos de teclado |
| `noctalia-calculator` | Calculadora integrada |
| `osk-toggle` | Teclado en pantalla on/off |
| `screen-toolkit` | Herramientas de pantalla (capturas, etc.) |
| `timer` | Temporizador simple |
| `todo` | Lista de tareas |
| `usb-drive-manager` | Gestor de dispositivos USB |
| `web-search` | Búsqueda web desde el launcher |

### Para probar

**GNOME Core + Wayland**:
- **Shell/Compositor**: gnome-shell (Mutter) — Wayland nativo
- **Gestor de sesión**: GDM (gdm3)
- **Paquetes core**: solo gnome-shell, gnome-session, gdm3

**KDE Plasma Core + Wayland**:
- **Shell**: plasma-desktop (plasma-workspace)
- **Compositor**: KWin — Wayland nativo
- **Gestor de sesión**: SDDM
- **Paquetes core**: solo plasma-desktop, kwin-wayland, sddm

**Wayland + Noctalia Shell + KWin (script de tiling)**:
- **Shell**: Noctalia Shell (sin cambios)
- **Compositor**: KWin (reemplaza Labwc)
- **Gestor de sesión**: greetd (sin cambios)
- **Tiling temporal**: script KWin custom (~350 líneas JS)
- **Requisitos del script**:
  - Máquina de estados por ventana: floating → half (↑↓←→) → corner (↑↓ desde half) → maximized (↑ si única app) → minimized (↓ desde half-bottom)
  - Transiciones con Super + flechas siguiendo el estado actual de cada ventana
  - Grids dinámicos 2‑3‑4 columnas según la cantidad de ventanas abiertas (adaptativo, no fijo)
  - Nuevas ventanas tileadas sobre la posición del cursor
  - Grid por defecto configurable por monitor
  - Alt + Right Click → resize desde borde más cercano ✅ (ya incluido en KWin)
- **Instalación mínima**: `kwin-wayland plasma-workspace layer-shell-qt` (sin plasma-desktop completo)
- **Nota**: Noctalia Shell funciona sobre KWin porque KWin 6.3.6 implementa `wlr-layer-shell`.

## Entornos de desarrollo

| Herramienta | Versión      | Ubicación       |
| ------------ | ------------ | --------------- |
| Node.js      | v20.19.2     | `/usr/bin/node` |
| Bun          |              |                 |
| Rust         | v1.95.0      | -               |

## Herramientas de desarrollo

- **pnpm**: gestor de paquetes de node, Bun
- **mise**: nvm, cargo, pip, todo den uno 
- **Git y gh** CLIs, de control de versiones y respaldo de repositorio
- **portless**: reemplaza números de puerto por URLs .localhost estables para desarrollo local
- **Podman**: contenedores rootless para servicios (PostgreSQL, etc.)
- **pgcli**: CLI de PostgreSQL con autocompletado y syntax highlighting
- **mongosh**: MongoDB Shell oficial
- **posting**: Cliente api de terminal "alternativa abruno"

## Aplicaciones de desarrollo

- **Kitty / Alacritty** Terminal GPU-accelerada (kitty) y ultraligera (alacritty)
- **Github Desktop** Cliente de github Nativo
- **OpenPencil** App de diseño tipo figma con MCP para ia
- **opencode** App de terminal para agente de ia
- **DBeaver**  — Gestor multi-DB (PostgreSQL, MongoDB, etc.)
- **Bruno** (`com.usebruno.Bruno`) — API testing offline-first
- **NVim** - editor de texto TUI superextensible
- **Neovide** — GUI gráfica para Neovim (Qt, Wayland, animaciones fluidas)
- **Lunacy** (`com.icons8.Lunacy`) — Editor gráfico para UI/UX.
- **Godot Engine**: motor de videojuegos
- **draw.io** (`com.jgraph.drawio.desktop`) — Diagramas y mapas conceptuales

## Herramientas de Productividad

- **Proton** — Ecosistema unificado:
  - **Proton Mail** — Email cifrado
  - **Proton Calendar** — Calendario
  - **Proton Drive** — Almacenamiento, documentos y hojas de cálculo
  - **Proton Pass** — Gestor de contraseñas
  - **Proton VPN** — VPN cifrada
- **OnlyOffice** — Suite ofimática offline (Word, Excel, PPT)
- **Firefox Browser** 
- **Opera** (probar)

## Sistema

- Archivos   **Nautilus**              `org.gnome.Nautilus`               Gestor de archivos GNOME
  - **Sushi** — Vista previa rápida con Spacebar
  - **Nautilus Console** — Abrir terminal desde el menú contextual
  - **File Roller** — Gestor de archivos comprimidos
  - **p7zip-full** — Soporte para 7z
  - **unrar** — Extracción de RAR
- Video      **mpv**                  `mpv`                               Wayland nativo, ultraligero 
- Visor      **Loupe**                 `org.gnome.Loupe`                  Visor de imágenes GTK4 
- Fotos      **Photon**                `com.github.maoschanz.Photon`      Visor de fotos GTK4    
- Juegos     **Lutris** Game Launcher para juegos y emuladores
- Capturas    **Flameshot** `org.flameshot.Flameshot`  Screenshots con anotaciones 
- Capturas CLI  **grim + slurp**  `grim`, `slurp`  Screenshots desde terminal para Wayland (keyboard shortcuts) 
- Conectividad  **LocalSend** Intercambio de archivos entre dispositivos de la misma red 
- Wi-Fi AP  **linux-wifi-hotspot** `lakinduakash/linux-wifi-hotspot`  Crear hotspot WiFi desde la terminal 
- **BalenaEtcher**: flasheador de dispositivos booteables
- **GParted**: modificador de particiones y gestion de discos

## Herramientas del Sistema

| Herramienta | Propósito |
|-------------|-----------|
| **earlyoom** | Previene OOM en RAM limitada |
| **powertop** | Diagnóstico y optimización de batería |
| **tlp** | Gestión avanzada de energía en laptops |
| **thermald** | Gestión térmica del CPU |
| **timeshift** | Snapshots del sistema (btrfs) |

## Backup

| Herramienta | Propósito |
|-------------|-----------|
| **restic** | Backups cifrados a repos remotos |
| **rsync** | Sincronización incremental de archivos |

## Comunicación

- **Discord** servidores, juegos y comunidades
- **Telegram desktop** chats instantaneos y canales  
- **whatsapp desktop** chats instantaneos

## OS - Startup, keymaps, laptops Functions, wireless, devices USB

### Grub

- **Archivo de configuración**: `grub/grub` en el repo → `/etc/default/grub` en el sistema
- **Modo Startup**: fase `1/5` — clona `grub/grub` del repo, aplica permisos y ejecuta `update-grub`
- **Timeout**: `GRUB_TIMEOUT=0` — arranque inmediato sin esperar entrada
- **Menú**: `GRUB_TIMEOUT_STYLE=hidden` — oculto completamente
- **Colores**: personalizados vía `GRUB_CFG_COLOR_CUSTOM`, normal/highlight en `black/black` (invisible)
- **Background**: `GRUB_BACKGROUND="/boot/grub/boot.png"`
- **Kernel params**: `quiet splash loglevel=0 vt.global_cursor_default=0 systemd.show_status=false rd.systemd.show_status=false` — arranque 100% silencioso
- **os-prober**: `GRUB_DISABLE_OS_PROBER=false` — habilitado para dual-boot

### Startup

- **Configuraciones**:
  - **Modo**: usuario unico autologin
  - **Pantalla de bloqueo**: de noctalia-shell

### keymaps

- Configuracion basada en la actual (depende del Entorno de Escritorio)

### wireless

- **Bluetooth** apagado por defecto
- **Wifi** Recordar si se quedó "encendido" o "apagado" en la sesión anterior 

### devices USB

- **USB** dependencias para dispositivos USB (a veces faltantes)
