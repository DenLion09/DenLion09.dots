# Configuracion de Sistema - Debian 13 Trixie

Estrategia de instalación (distro-agnóstico):

- 1. ¿Es GUI? → **Empaquetado oficial directo del repositorio (si existe)**
- 2. ¿Es CLI? → **ScriptOficial directo del repositorio (si existe)**
- 3. ¿Driver/lib de sistema? → **Gestor nativo**
- 4. no brew no flatpack - cacheo personalizado

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
- **btop**: System CLI taskmanager
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
| `fancy-audiovisualizer` | Visualizador de audio |
| `file-search` | Búsqueda de archivos |
| `kaomoji-provider` | Insertar kaomojis desde el launcher |
| `keybind-cheatsheet` | Guía de atajos de teclado |
| `news` | Feed de noticias |
| `noctalia-calculator` | Calculadora integrada |
| `osk-toggle` | Teclado en pantalla on/off |
| `pomodoro` | Temporizador pomodoro |
| `screen-toolkit` | Herramientas de pantalla (capturas, etc.) |
| `timer` | Temporizador simple |
| `todo` | Lista de tareas |
| `usb-drive-manager` | Gestor de dispositivos USB |
| `web-search` | Búsqueda web desde el launcher |

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
| **borgbackup** | Backups deduplicados y comprimidos |
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
