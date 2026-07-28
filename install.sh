#!/bin/bash
# =============================================================================
# DenLion09 Dots — Development Stack Installer
# =============================================================================
# TUI interactiva en bash puro, cero dependencias externas.
# Respeta las reglas de DenLion09.dots.md:
#   CLI  → script oficial del repo
#   GUI  → descarga de la pagina web o el repo oficial de github
#   Driver/lib → gestor nativo
#   No brew, no flatpak (con alternativas nativas)
# =============================================================================
# Modos:
#   1. Todo de una  — instala todo en secuencia automática
#   2. Uno por uno  — aprobás cada herramienta antes de instalar
#   3. Selección    — marcás con checkboxes y se instalan en lote
# =============================================================================

set -euo pipefail

# ============================================================================
# 0. CONFIGURACIÓN GLOBAL
# ============================================================================
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_BACKUP_DIR=""
for d in "$REPO_DIR"/.config.BACKUP.*/; do
  [ -d "$d" ] && CONFIG_BACKUP_DIR="$d" && break
done

export NONINTERACTIVE=1

# ============================================================================
# 1. TUI ENGINE — ANSI puro, cero dependencias
# ============================================================================

# Colores
C_RESET='\033[0m'
C_BOLD='\033[1m'
C_DIM='\033[2m'
C_RED='\033[0;31m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[1;33m'
C_BLUE='\033[0;34m'
C_CYAN='\033[0;36m'
C_MAGENTA='\033[0;35m'
C_WHITE='\033[1;37m'
C_BG_BLUE='\033[44m'
C_BG_GREEN='\033[42m'
C_BG_RED='\033[41m'
C_BG_YELLOW='\033[43m'

# Símbolos
CHECK='✔'
CROSS='✘'
ARROW='→'
BULLET='•'

# ─── helpers de output ───────────────────────────────────────────────────────

print_banner() {
  clear
  echo -e "${C_CYAN}${C_BOLD}"
  echo '  ╔═══════════════════════════════════════════════╗'
  echo '  ║        DenLion09 — Stack Installer            ║'
  echo '  ║     Desarrollo · Terminal · Herramientas      ║'
  echo '  ╚═══════════════════════════════════════════════╝'
  echo -e "${C_RESET}"
}

print_step() {
  local num=$1; shift
  echo -e "\n${C_BOLD}${C_BLUE}[${num}]${C_RESET} ${C_BOLD}$*${C_RESET}"
}

print_info()  { echo -e "  ${C_CYAN}${BULLET}${C_RESET} $*"; }
print_ok()    { echo -e "  ${C_GREEN}${CHECK}${C_RESET} $*"; }
print_err()   { echo -e "  ${C_RED}${CROSS}${C_RESET} $*"; }
print_warn()  { echo -e "  ${C_YELLOW}${BULLET}${C_RESET} $*"; }

print_header() {
  local title=$1
  echo
  echo -e "  ${C_BOLD}${C_BG_BLUE}  ${title}  ${C_RESET}"
  echo -e "  ${C_DIM}${C_BLUE}$(printf '═%.0s' $(seq 1 56))${C_RESET}"
}

print_divider() {
  echo -e "  ${C_DIM}────────────────────────────────────────${C_RESET}"
}

# ─── spinner ─────────────────────────────────────────────────────────────────

spinner_run() {
  local pid=$1 msg=$2
  local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
  local i=0
  while kill -0 "$pid" 2>/dev/null; do
    printf "\r  ${C_CYAN}%s${C_RESET} ${msg}..." "${spin:$i:1}"
    i=$(( (i + 1) % ${#spin} ))
    sleep 0.1
  done
  local rc=0
  wait "$pid" 2>/dev/null || rc=$?
  if [ $rc -eq 0 ]; then
    printf "\r  ${C_GREEN}${CHECK}${C_RESET} ${msg}   \n"
  else
    printf "\r  ${C_RED}${CROSS}${C_RESET} ${msg}   \n"
  fi
  return $rc
}

run_bg() {
  local msg=$1; shift
  ("$@" >/dev/null 2>&1) &
  local pid=$!
  spinner_run "$pid" "$msg"
  return $?
}

# ─── input ───────────────────────────────────────────────────────────────────

menu_confirm() {
  local prompt="${1:-¿Continuar?}"
  local input
  read -r -p "$(echo -e "  ${C_YELLOW}${ARROW}${C_RESET} ${prompt} [S/n]: ")" input </dev/tty
  case "${input:-s}" in
    s|S|y|Y|'') return 0 ;;
    *) return 1 ;;
  esac
}

menu_prompt() {
  local prompt=$1
  local input
  read -r -p "$(echo -e "  ${C_YELLOW}${ARROW}${C_RESET} ${prompt} ")" input </dev/tty
  echo "$input"
}

# ============================================================================
# 2. DETECCIÓN DEL SISTEMA
# ============================================================================

OS_ID="$( { . /etc/os-release 2>/dev/null && echo "$ID"; } || echo "linux" )"
OS_ARCH="$(dpkg --print-architecture 2>/dev/null || uname -m)"
HAS_SUDO="no"; command -v sudo >/dev/null 2>&1 && HAS_SUDO="yes"
SUDO=""; [ "$HAS_SUDO" = "yes" ] && SUDO="sudo"

# ============================================================================
# 3. SOPORTE A PROBLEMAS DE RED
# ============================================================================

NETWORK_STATUS=""
NETWORK_CHECKED=false

check_network() {
  local hosts=("https://github.com" "https://google.com" "https://raw.githubusercontent.com")
  local reachable=0

  print_info "Verificando conexión a Internet..."
  for host in "${hosts[@]}"; do
    curl -s --connect-timeout 5 --max-time 10 "$host" >/dev/null 2>&1 && \
      reachable=$((reachable + 1))
  done

  if [ "$reachable" -ge 2 ]; then
    NETWORK_STATUS="ok"
    print_ok "Conexión a Internet verificada"
    return 0
  elif [ "$reachable" -ge 1 ]; then
    NETWORK_STATUS="partial"
    print_warn "Conexión parcial — solo algunos hosts alcanzables"
    return 1
  else
    NETWORK_STATUS="down"
    print_err "Sin conexión a Internet"
    return 2
  fi
}

# Download con reintentos, timeout y feedback en TUI
dl_with_retry() {
  local url=$1 dest=$2
  local max_retries=${3:-3}
  local connect_timeout=${4:-15}
  local max_time=${5:-120}

  rm -f "$dest"
  local attempt=1
  while [ "$attempt" -le "$max_retries" ]; do
    if curl -fsSL --connect-timeout "$connect_timeout" --max-time "$max_time" \
      "$url" -o "$dest" 2>/dev/null; then
      return 0
    fi
    if [ "$attempt" -lt "$max_retries" ]; then
      local delay=$((attempt * 3))
      print_warn "Descarga fallida (intento ${attempt}/${max_retries}) — reintentando en ${delay}s..."
      sleep "$delay"
    fi
    attempt=$((attempt + 1))
  done

  rm -f "$dest"
  return 1
}

# Descarga un script y lo ejecuta (pipe seguro con retry)
curl_pipe_sh_retry() {
  local url=$1
  local tmpd; tmpd=$(mktemp -d)
  local script="$tmpd/install.sh"

  dl_with_retry "$url" "$script" 3 15 60 || { rm -rf "$tmpd"; return 1; }
  chmod +x "$script"
  sh "$script" >/dev/null 2>&1
  local rc=$?
  rm -rf "$tmpd"
  return $rc
}

# API GET con retry (para GitHub releases, etc.)
curl_api_retry() {
  local url=$1
  local max_retries=${2:-3}
  local result=""
  local attempt=1

  while [ "$attempt" -le "$max_retries" ]; do
    result=$(curl -s --connect-timeout 10 --max-time 30 "$url" 2>/dev/null)
    if [ -n "$result" ]; then
      echo "$result"
      return 0
    fi
    attempt=$((attempt + 1))
    [ "$attempt" -le "$max_retries" ] && sleep $((attempt * 2))
  done

  echo ""
  return 1
}

# ============================================================================
# 4. ESTRATEGIAS DE INSTALACIÓN
# ============================================================================

cmd_exists() { command -v "$1" >/dev/null 2>&1; }
pkg_installed() { dpkg -s "$1" >/dev/null 2>&1; }

apt_install() {
  local pkg=$1
  pkg_installed "$pkg" && return 0
  $SUDO apt-get install -y "$pkg" >/dev/null 2>&1
}

apt_update() { $SUDO apt-get update -qq >/dev/null 2>&1; }

dl_deb() {
  local url=$1
  local tmpd; tmpd=$(mktemp -d)
  dl_with_retry "$url" "$tmpd/pkg.deb" 3 15 120 || { rm -rf "$tmpd"; return 1; }
  $SUDO dpkg -i "$tmpd/pkg.deb" >/dev/null 2>&1 || {
    $SUDO apt-get install -f -y >/dev/null 2>&1
    $SUDO dpkg -i "$tmpd/pkg.deb" >/dev/null 2>&1
  }
  local rc=$?; rm -rf "$tmpd"; return $rc
}

dl_appimage() {
  local url=$1 name=$2
  local dest="$HOME/.local/bin/$name"
  mkdir -p "$HOME/.local/bin"
  dl_with_retry "$url" "$dest" 3 15 120 || return 1
  chmod +x "$dest" && return 0
}

curl_pipe_sh() {
  local url=$1
  curl_pipe_sh_retry "$url"
  return $?
}

cargo_install() { cmd_exists "$1" || cargo install "$1" >/dev/null 2>&1; }
pip_install() {
  local pkg=$1
  pip3 show "$pkg" >/dev/null 2>&1 && return 0
  pip3 install --user -q "$pkg" >/dev/null 2>&1
}

add_local_bin_to_path() {
  mkdir -p "$HOME/.local/bin"
  local fconf="${XDG_CONFIG_HOME:-$HOME/.config}/fish/config.fish"
  [ -f "$fconf" ] && grep -q '\.local/bin' "$fconf" 2>/dev/null || \
    echo 'set -gx PATH $PATH "$HOME/.local/bin"' >>"$fconf"
  export PATH="$HOME/.local/bin:$PATH"
}

# ─── Fix Debian binary names ─────────────────────────────────────────────────

# En Debian, bat → batcat, fd → fdfind. Creamos wrappers si hace falta.
fix_debian_binaries() {
  if cmd_exists batcat && ! cmd_exists bat; then
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat" 2>/dev/null || true
    export PATH="$HOME/.local/bin:$PATH"
  fi
  if cmd_exists fdfind && ! cmd_exists fd; then
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd" 2>/dev/null || true
    export PATH="$HOME/.local/bin:$PATH"
  fi
}

# ============================================================================
# 5. REGISTRO DE HERRAMIENTAS
# ============================================================================
# Almacenamos en un archivo temporal con separador \007 (inalterable por texto).
# Formato: nombre|categoria|descripcion|runner|argumento|verificador

TOOLS_FILE=$(mktemp)
cleanup() { rm -f "$TOOLS_FILE"; }
trap cleanup EXIT

tool_reg() {
  local n=$1 c=$2 d=$3 r=$4 a=$5 v=$6
  printf '%s\007%s\007%s\007%s\007%s\007%s\n' "$n" "$c" "$d" "$r" "$a" "$v" >> "$TOOLS_FILE"
}

# Accesores
tool_info() {
  local name=$1 field=$2
  grep -F "$name" "$TOOLS_FILE" | head -1 | cut -d "$(printf '\007')" -f "$field"
}
tool_name()  { tool_info "$1" 1; }
tool_cat()   { tool_info "$1" 2; }
tool_desc()  { tool_info "$1" 3; }
tool_runner(){ tool_info "$1" 4; }
tool_arg()   { tool_info "$1" 5; }
tool_check() { tool_info "$1" 6; }

# Listar herramientas de una categoría (nombres)
tools_in() {
  local cat=$1
  grep "$(printf '\007')${cat}$(printf '\007')" "$TOOLS_FILE" | cut -d "$(printf '\007')" -f 1
}

# ─── REGISTRAR HERRAMIENTAS ──────────────────────────────────────────────────
# runner: apt, script, cargo, pip, appimage, function

# --- Grupo: Terminal ---
tool_reg "fish"       "Terminal"  "Fish Shell — shell interactiva moderna" \
  "apt"       "fish"       "cmd_exists fish"
tool_reg "starship"   "Terminal"  "Prompt minimalista y rápido" \
  "script"    "starship"   "cmd_exists starship"
tool_reg "atuin"      "Terminal"  "Historial de comandos con búsqueda fuzzy" \
  "atuin"     ""           "cmd_exists atuin"
tool_reg "fzf"        "Terminal"  "Fuzzy finder universal" \
  "apt"       "fzf"        "cmd_exists fzf"
tool_reg "carapace"   "Terminal"  "Autocompletado universal para shell" \
  "apt"       "carapace-bin" "cmd_exists carapace"
tool_reg "btop"       "Terminal"  "Monitor del sistema CLI" \
  "apt"       "btop"       "cmd_exists btop"

# --- Grupo: CLI Tools ---
tool_reg "ripgrep"    "CLI Tools" "grep ultrarápido (rg)" \
  "apt"       "ripgrep"    "cmd_exists rg"
tool_reg "fd"         "CLI Tools" "find moderno y rápido (fd)" \
  "apt"       "fd-find"    "cmd_exists fd || cmd_exists fdfind"
tool_reg "eza"        "CLI Tools" "ls moderno con colores e iconos" \
  "apt"       "eza"        "cmd_exists eza"
tool_reg "yazi"       "CLI Tools" "File manager TUI" \
  "apt"       "yazi"       "cmd_exists yazi"
tool_reg "fastfetch"  "CLI Tools" "Información del sistema (neofetch moderno)" \
  "apt"       "fastfetch"  "cmd_exists fastfetch"
tool_reg "bat"        "CLI Tools" "cat con syntax highlighting" \
  "bat"       ""           "cmd_exists bat || cmd_exists batcat"
tool_reg "jq"         "CLI Tools" "Procesador JSON desde terminal" \
  "apt"       "jq"         "cmd_exists jq"
tool_reg "yq"         "CLI Tools" "Procesador YAML/XML/TOML" \
  "pip"       "yq"         "python3 -c 'import yq' 2>/dev/null"

# --- Grupo: Font ---
tool_reg "cascadia-nf" "Font"     "Cascadia Cove Nerd Font (terminal)" \
  "function"  "install_font" "fc-list | grep -qi 'Cascadia.*Code.*NF' 2>/dev/null"

# --- Grupo: Dev Environments ---
tool_reg "mise"       "Dev Env"   "Monoherramienta: nvm, cargo, pip, todo en uno" \
  "script"    "mise"       "cmd_exists mise || test -x \$HOME/.local/bin/mise"
tool_reg "nodejs"     "Dev Env"   "Node.js vía mise (LTS automático)" \
  "function"  "install_mise_node" "cmd_exists node"
tool_reg "bun"        "Dev Env"   "Runtime JS/TS todo-en-uno" \
  "script"    "bun"        "cmd_exists bun"
tool_reg "rust"       "Dev Env"   "Rust con rustup (cargo, rustc)" \
  "rust"      ""           "cmd_exists rustc"

# --- Grupo: Dev Tools ---
tool_reg "pnpm"       "Dev Tools" "Gestor de paquetes Node.js rápido" \
  "script"    "pnpm"       "cmd_exists pnpm"
tool_reg "gh"         "Dev Tools" "GitHub CLI — issues, PRs, repos" \
  "apt"       "gh"         "cmd_exists gh"
tool_reg "git"        "Dev Tools" "Control de versiones (si no está)" \
  "apt"       "git"        "cmd_exists git"
tool_reg "podman"     "Dev Tools" "Contenedores rootless" \
  "apt"       "podman"     "cmd_exists podman"
tool_reg "pgcli"      "Dev Tools" "CLI PostgreSQL con autocompletado" \
  "pip"       "pgcli"      "cmd_exists pgcli"
tool_reg "mongosh"    "Dev Tools" "MongoDB Shell oficial" \
  "function"  "install_mongosh" "cmd_exists mongosh"
tool_reg "portless"  "Dev Tools" "Reemplaza puertos por URLs .localhost para desarrollo local" \
  "function"  "install_portless" "cmd_exists portless"

# --- Grupo: Dev Apps (GUI) ---
tool_reg "xfce4-terminal" "Dev Apps" "Terminal ligera para Wayland" \
  "apt"       "xfce4-terminal" "cmd_exists xfce4-terminal"
tool_reg "github-desktop" "Dev Apps" "GitHub Desktop — cliente gráfico de Git" \
  "function"  "install_github_desktop" "cmd_exists github-desktop || test -f /usr/share/applications/github-desktop.desktop"
tool_reg "dbeaver"  "Dev Apps"  "Gestor multi-DB (PostgreSQL, MongoDB, etc.)" \
  "function"  "install_dbeaver" "cmd_exists dbeaver"
tool_reg "bruno"    "Dev Apps"  "API testing offline-first" \
  "function"  "install_bruno" "test -f \$HOME/.local/bin/bruno || test -f /usr/share/applications/bruno.desktop"
tool_reg "neovim"   "Dev Apps"  "Editor de texto TUI superextensible (última release oficial)" \
  "function"  "install_neovim" "cmd_exists nvim"
tool_reg "opencode" "Dev Apps"  "Terminal agentic AI para desarrollo" \
  "function"  "install_opencode" "cmd_exists opencode"
tool_reg "godot"    "Dev Apps"  "Motor de videojuegos Godot Engine" \
  "function"  "install_godot" "test -f \$HOME/.local/bin/godot"
tool_reg "drawio"   "Dev Apps"  "Diagramas y mapas conceptuales" \
  "function"  "install_drawio" "test -f \$HOME/.local/bin/drawio || test -f /usr/share/applications/drawio.desktop"
tool_reg "openpencil" "Dev Apps"  "Editor de diseño tipo Figma con MCP para IA" \
  "function"  "install_openpencil" "test -f \$HOME/.local/bin/openpencil || test -f /usr/share/applications/openpencil.desktop || dpkg -s openpencil 2>/dev/null"

# --- Grupo: Fisher Plugins ---
tool_reg "fisher"    "Fisher"   "Gestor de plugins de fish" \
  "fisher"   ""         "test -f \$HOME/.config/fish/functions/fisher.fish"
tool_reg "nvm.fish"  "Fisher"   "Node Version Manager para fish" \
  "fisher_pkg" "jorgebucaran/nvm.fish" "test -f \$HOME/.config/fish/conf.d/nvm.fish"
tool_reg "fzf.fish"  "Fisher"   "Integración de fzf (historial, archivos)" \
  "fisher_pkg" "patrickf1/fzf.fish" "test -f \$HOME/.config/fish/conf.d/fzf.fish"
tool_reg "plugin-pj" "Fisher"   "Project jumper — salta a proyectos por nombre" \
  "fisher_pkg" "oh-my-fish/plugin-pj" "test -f \$HOME/.config/fish/functions/pj.fish"

# ============================================================================
# 6. INSTALADORES ESPECÍFICOS
# ============================================================================

# ─── atuin: script oficial, fallback a cargo ────────────────────────────────
install_atuin() {
  cmd_exists atuin && return 0
  curl_pipe_sh "https://raw.githubusercontent.com/atuinsh/atuin/main/install.sh" || \
    cargo_install "atuin"
}

# ─── bat: apt (batcat) + symlink ────────────────────────────────────────────
install_bat() {
  cmd_exists bat && return 0
  pkg_installed "bat" && { cmd_exists batcat && ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat" 2>/dev/null; return 0; }
  apt_install "bat"
  cmd_exists batcat && ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat" 2>/dev/null
}

# ─── Font ────────────────────────────────────────────────────────────────────
install_font() {
  fc-list | grep -qi 'Cascadia.*Code.*NF' 2>/dev/null && return 0
  local fd="${XDG_DATA_HOME:-$HOME/.local/share}/fonts"
  mkdir -p "$fd"
  local tmpd; tmpd=$(mktemp -d)
  print_info "Descargando Cascadia Cove Nerd Font..."
  dl_with_retry "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/CascadiaCode.zip" \
    "$tmpd/CascadiaCode.zip" 3 15 120 || { rm -rf "$tmpd"; return 1; }
  unzip -qo "$tmpd/CascadiaCode.zip" -d "$tmpd/fonts" 2>/dev/null
  cp "$tmpd/fonts"/*.ttf "$fd/" 2>/dev/null || true
  fc-cache -f "$fd" >/dev/null 2>&1
  rm -rf "$tmpd"
  fc-list | grep -qi 'Cascadia.*Code.*NF' 2>/dev/null
}

# ─── mise ────────────────────────────────────────────────────────────────────
install_mise() {
  cmd_exists mise && return 0
  local mise_bin="$HOME/.local/bin/mise"
  [ -x "$mise_bin" ] && return 0
  curl_pipe_sh_retry "https://mise.jdx.dev/install.sh"
  [ -x "$mise_bin" ] && add_local_bin_to_path
}

install_mise_node() {
  cmd_exists node && return 0
  install_mise || return 1
  local mise_bin="$HOME/.local/bin/mise"
  if [ -x "$mise_bin" ]; then
    PATH="$HOME/.local/bin:$PATH" "$mise_bin" use -g "node@lts" >/dev/null 2>&1 || \
    PATH="$HOME/.local/bin:$PATH" "$mise_bin" install "node@lts" >/dev/null 2>&1
  fi
  cmd_exists node
}

# ─── Rust ────────────────────────────────────────────────────────────────────
install_rust() {
  cmd_exists rustc && return 0
  curl_pipe_sh "https://sh.rustup.rs"
  # Cargar rust al PATH de esta sesión
  [ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
  cmd_exists rustc
}

# ─── MongoDB Shell ───────────────────────────────────────────────────────────
install_mongosh() {
  cmd_exists mongosh && return 0
  print_info "Configurando repositorio oficial de MongoDB..."
  local tmpd; tmpd=$(mktemp -d)
  dl_with_retry "https://www.mongodb.org/static/pgp/server-8.0.asc" "$tmpd/mongodb.asc" 3 15 30 || {
    print_warn "No se pudo descargar la clave GPG de MongoDB (problemas de red)"
    rm -rf "$tmpd"; return 1
  }
  $SUDO gpg --dearmor -o /usr/share/keyrings/mongodb-server-8.0.gpg < "$tmpd/mongodb.asc" >/dev/null 2>&1 || true
  rm -rf "$tmpd"
  echo "deb [signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg] https://repo.mongodb.org/apt/debian bookworm/mongodb-org/8.0 main" | \
    $SUDO tee /etc/apt/sources.list.d/mongodb-org-8.0.list >/dev/null
  $SUDO apt-get update -qq >/dev/null 2>&1
  $SUDO apt-get install -y mongodb-mongosh >/dev/null 2>&1
}

# ─── GitHub Desktop ──────────────────────────────────────────────────────────
install_github_desktop() {
  cmd_exists github-desktop && return 0
  print_info "Descargando GitHub Desktop..."
  dl_deb "https://github.com/shiftkey/desktop/releases/download/release-3.4.9-linux2/GitHubDesktop-3.4.9-linux2.deb" || {
    print_warn "GitHub Desktop necesita descarga manual: https://github.com/shiftkey/desktop/releases"
    return 1
  }
}

# ─── DBeaver ─────────────────────────────────────────────────────────────────
install_dbeaver() {
  cmd_exists dbeaver && return 0
  print_info "Descargando DBeaver..."
  dl_deb "https://dbeaver.io/files/dbeaver-ce_latest_${OS_ARCH}.deb" || {
    print_warn "DBeaver necesita descarga manual: https://dbeaver.io/download/"
    return 1
  }
}

# ─── Bruno (AppImage) ────────────────────────────────────────────────────────
install_bruno() {
  test -f "$HOME/.local/bin/bruno" && return 0
  print_info "Buscando Bruno AppImage..."
  local url
  url=$(curl_api_retry "https://api.github.com/repos/usebruno/bruno/releases/latest" \
    | grep "browser_download_url.*AppImage" | head -1 | cut -d'"' -f4) || url=""
  [ -z "$url" ] && { print_warn "Bruno requiere descarga manual: https://www.usebruno.com/downloads"; return 1; }
  dl_appimage "$url" "bruno" || { print_warn "No se pudo descargar Bruno"; return 1; }
}

# ─── OpenCode ────────────────────────────────────────────────────────────────
install_opencode() {
  cmd_exists opencode && return 0
  print_info "Descargando OpenCode..."
  local url arch
  case "$OS_ARCH" in
    amd64|x86_64) arch="x86_64" ;;
    arm64|aarch64) arch="aarch64" ;;
    *) print_warn "Arquitectura no soportada para OpenCode: $OS_ARCH"; return 1 ;;
  esac
  url=$(curl_api_retry "https://api.github.com/repos/opencode-ai/opencode/releases/latest" \
    | grep "browser_download_url.*${arch}.*linux" | grep -v '.sha' | head -1 | cut -d'"' -f4) || url=""
  [ -z "$url" ] && { print_warn "OpenCode requiere descarga manual: https://github.com/opencode-ai/opencode/releases"; return 1; }
  dl_appimage "$url" "opencode" || { print_warn "No se pudo descargar OpenCode"; return 1; }
}

# ─── Godot ───────────────────────────────────────────────────────────────────
install_godot() {
  test -f "$HOME/.local/bin/godot" && return 0
  print_info "Descargando Godot Engine..."
  local dest="$HOME/.local/bin/godot"
  mkdir -p "$HOME/.local/bin"
  local url="https://github.com/godotengine/godot/releases/download/4.4.1-stable/Godot_v4.4.1-stable_linux.x86_64.zip"
  local tmpd; tmpd=$(mktemp -d)
  dl_with_retry "$url" "$tmpd/godot.zip" 3 15 180 || {
    print_warn "Godot no se pudo descargar (problemas de red): https://godotengine.org/download/"; rm -rf "$tmpd"; return 1
  }
  unzip -qo "$tmpd/godot.zip" -d "$tmpd/extract" 2>/dev/null
  local bin; bin=$(find "$tmpd/extract" -name "Godot*" -type f 2>/dev/null | head -1)
  if [ -n "$bin" ]; then
    cp "$bin" "$dest" && chmod +x "$dest"
    print_ok "Godot Engine → ~/.local/bin/godot"
    rm -rf "$tmpd"; return 0
  fi
  rm -rf "$tmpd"; return 1
}

# ─── draw.io (AppImage) ──────────────────────────────────────────────────────
install_drawio() {
  test -f "$HOME/.local/bin/drawio" && return 0
  print_info "Buscando draw.io AppImage..."
  local url
  url=$(curl_api_retry "https://api.github.com/repos/jgraph/drawio-desktop/releases/latest" \
    | grep "browser_download_url.*x86_64.*AppImage" | head -1 | cut -d'"' -f4) || url=""
  [ -z "$url" ] && { print_warn "draw.io requiere descarga manual: https://github.com/jgraph/drawio-desktop/releases"; return 1; }
  dl_appimage "$url" "drawio" || { print_warn "No se pudo descargar draw.io"; return 1; }
}

# ─── OpenPencil (ZSeven-W) ──────────────────────────────────────────────────
install_openpencil() {
  test -f "$HOME/.local/bin/openpencil" && return 0
  pkg_installed "openpencil" && return 0
  print_info "Descargando OpenPencil v0.7.5..."
  # Prefer .deb en Debian/Ubuntu, fallback a AppImage
  local deb_url="https://github.com/ZSeven-W/openpencil/releases/download/v0.7.5/OpenPencil-0.7.5-amd64-linux.deb"
  local img_url="https://github.com/ZSeven-W/openpencil/releases/download/v0.7.5/OpenPencil-0.7.5-x86_64-linux.AppImage"
  dl_deb "$deb_url" 2>/dev/null && { print_ok "OpenPencil instalado (deb)"; return 0; }
  print_info "Deb no disponible, probando AppImage..."
  dl_appimage "$img_url" "openpencil" && { print_ok "OpenPencil → ~/.local/bin/openpencil"; return 0; }
  print_warn "OpenPencil requiere instalación manual: https://github.com/ZSeven-W/openpencil/releases/tag/v0.7.5"
  return 1
}

# ─── Neovim (última release oficial, no apt) ─────────────────────────────────
install_neovim() {
  cmd_exists nvim && return 0
  print_info "Descargando Neovim (última release oficial)..."
  local url="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"
  local tmpd; tmpd=$(mktemp -d)
  dl_with_retry "$url" "$tmpd/nvim.tar.gz" 3 15 180 || {
    print_warn "No se pudo descargar Neovim (problemas de red)"; rm -rf "$tmpd"; return 1
  }
  print_info "Extrayendo Neovim..."
  $SUDO rm -rf /opt/nvim-linux-x86_64
  $SUDO tar -C /opt -xzf "$tmpd/nvim.tar.gz" 2>/dev/null || {
    print_warn "No se pudo extraer Neovim"; rm -rf "$tmpd"; return 1
  }
  rm -rf "$tmpd"

  # Symlink para tener nvim en el PATH global
  $SUDO ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim 2>/dev/null || true
  print_ok "Neovim instalado en /opt/nvim-linux-x86_64"
}

# ─── Portless (Vercel Labs) ─────────────────────────────────────────────────
install_portless() {
  cmd_exists portless && return 0
  if ! cmd_exists npm; then
    print_warn "portless requiere Node.js/npm. Instalá nodejs primero."
    return 1
  fi
  print_info "Instalando portless vía npm global..."
  npm install -g portless >/dev/null 2>&1 || {
    print_warn "portless no se pudo instalar. Probá: npm install -g portless"
    return 1
  }
  print_ok "portless instalado globalmente"
}

# ─── Fisher ──────────────────────────────────────────────────────────────────
install_fisher() {
  test -f "$HOME/.config/fish/functions/fisher.fish" && return 0
  cmd_exists fish || return 1
  local tmpd; tmpd=$(mktemp -d)
  dl_with_retry "https://git.io/fisher" "$tmpd/fisher.fish" 3 15 30 || {
    rm -rf "$tmpd"
    return 1
  }
  fish -c "source $tmpd/fisher.fish && fisher install jorgebucaran/fisher" >/dev/null 2>&1
  local rc=$?
  rm -rf "$tmpd"
  return $rc
}
install_fisher_pkg() {
  local pkg=$1
  install_fisher || return 1
  fish -c "fisher install $pkg" >/dev/null 2>&1
}

# ─── Dispatch general ────────────────────────────────────────────────────────

install_tool() {
  local name=$1
  local runner; runner=$(tool_runner "$name")
  local arg; arg=$(tool_arg "$name")

  case "$runner" in
    apt)      apt_install "$arg" ;;
    script)
      case "$arg" in
        starship) curl_pipe_sh "https://starship.rs/install.sh" ;;
        bun)      curl_pipe_sh "https://bun.sh/install" ;;
        pnpm)     curl_pipe_sh "https://get.pnpm.io/install.sh" ;;
        mise)     install_mise ;;
        *)        return 1 ;;
      esac ;;
    atuin)    install_atuin ;;
    bat)      install_bat ;;
    rust)     install_rust ;;
    pip)      pip_install "$arg" ;;
    fisher)   install_fisher ;;
    fisher_pkg) install_fisher_pkg "$arg" ;;
    function)
      case "$arg" in
        install_font)         install_font ;;
        install_mise_node)    install_mise_node ;;
        install_mongosh)      install_mongosh ;;
        install_github_desktop) install_github_desktop ;;
        install_dbeaver)      install_dbeaver ;;
        install_bruno)        install_bruno ;;
        install_opencode)     install_opencode ;;
        install_godot)        install_godot ;;
        install_drawio)       install_drawio ;;
        install_openpencil)   install_openpencil ;;
        install_neovim)       install_neovim ;;
        install_portless)     install_portless ;;
        *) return 1 ;;
      esac ;;
    *) return 1 ;;
  esac
}

# ============================================================================
# 7. VERIFICACIÓN Y CONFIGURACIÓN
# ============================================================================

check_installed() {
  local name=$1
  local checker; checker=$(tool_check "$name")
  eval "$checker" >/dev/null 2>&1
}

deploy_configs() {
  [ -z "$CONFIG_BACKUP_DIR" ] && { print_warn "No hay .config.BACKUP.*"; return 1; }
  print_header "Desplegando configuraciones"
  local src="$CONFIG_BACKUP_DIR"
  local dst="${XDG_CONFIG_HOME:-$HOME/.config}"
  local total=0 ok=0
  for item in fish starship.toml opencode atuin; do
    [ -e "$src/$item" ] || continue
    total=$((total + 1))
    if [ -d "$src/$item" ]; then
      mkdir -p "$dst/$item"
      cp -r "$src/$item"/* "$dst/$item/" 2>/dev/null && ok=$((ok + 1))
    else
      cp "$src/$item" "$dst/$item" 2>/dev/null && ok=$((ok + 1))
    fi
  done
  [ "$ok" -gt 0 ] && print_ok "$ok/$total configuraciones desplegadas" \
    || print_warn "No se desplegaron configuraciones"
}

# ─── Clonar config de fish desde GitHub ──────────────────────────────────────
deploy_repo_fish() {
  local dst="${XDG_CONFIG_HOME:-$HOME/.config}/fish"
  local clone_url="${DEPLOY_REPO_FISH_URL:-https://github.com/DenLion09/DenLion09.dots.git}"
  print_header "Fish — clonar config desde GitHub"

  # Backup de config existente
  if [ -f "$dst/config.fish" ] && [ ! -L "$dst/config.fish" ]; then
    local backup="${dst}.bak.$(date +%s)"
    print_info "Respaldando config actual → ${backup}"
    cp -r "$dst" "$backup" 2>/dev/null || true
  fi

  local tmpd; tmpd=$(mktemp -d)
  print_info "Clonando repo (solo fish/)..."
  git clone --depth 1 --filter=blob:none --no-checkout "$clone_url" "$tmpd" >/dev/null 2>&1 || {
    print_err "No se pudo clonar el repo"; rm -rf "$tmpd"; return 1
  }
  git -C "$tmpd" sparse-checkout set fish >/dev/null 2>&1 || true
  git -C "$tmpd" checkout >/dev/null 2>&1 || { rm -rf "$tmpd"; return 1; }

  if [ -d "$tmpd/fish" ]; then
    mkdir -p "$dst"
    cp -r "$tmpd/fish/"* "$dst/" 2>/dev/null || true
    cp -r "$tmpd/fish/".[!.]* "$dst/" 2>/dev/null || true
    print_ok "Config de fish clonada desde GitHub → ~/.config/fish/"
  else
    print_warn "No se encontró fish/ en el repo"
    rm -rf "$tmpd"; return 1
  fi
  rm -rf "$tmpd"
}

# ─── Clonar config de Neovim desde GitHub ────────────────────────────────────
deploy_repo_nvim() {
  local dst="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
  local clone_url="https://github.com/DenLion09/DenLion09.dots.git"
  print_header "Neovim — clonar config desde GitHub"

  # Backup de config existente
  if [ -f "$dst/init.lua" ] && [ ! -L "$dst/init.lua" ]; then
    local backup="${dst}.bak.$(date +%s)"
    print_info "Respaldando config actual → ${backup}"
    cp -r "$dst" "$backup" 2>/dev/null || true
  fi

  local tmpd; tmpd=$(mktemp -d)
  print_info "Clonando repo (solo nvim/)..."
  git clone --depth 1 --filter=blob:none --no-checkout "$clone_url" "$tmpd" >/dev/null 2>&1 || {
    print_err "No se pudo clonar el repo"; rm -rf "$tmpd"; return 1
  }
  git -C "$tmpd" sparse-checkout set nvim >/dev/null 2>&1 || true
  git -C "$tmpd" checkout >/dev/null 2>&1 || { rm -rf "$tmpd"; return 1; }

  # Inicializar submódulo de nvim
  if [ -f "$tmpd/.gitmodules" ]; then
    git -C "$tmpd" submodule update --init --recursive >/dev/null 2>&1 || true
  fi

  if [ -d "$tmpd/nvim" ] && [ -f "$tmpd/nvim/init.lua" ]; then
    mkdir -p "$dst"
    cp -r "$tmpd/nvim/"* "$dst/" 2>/dev/null || true
    cp -r "$tmpd/nvim/".[!.]* "$dst/" 2>/dev/null || true
    print_ok "Config de Neovim clonada desde GitHub → ~/.config/nvim/"
  elif [ -d "$tmpd/nvim" ]; then
    # El submodulo esta hueco (sin init), copiar lo que haya
    mkdir -p "$dst"
    cp -r "$tmpd/nvim/"* "$dst/" 2>/dev/null || true
    print_warn "nvim/ sin contenido — cloná el submódulo manualmente si falta algo"
  else
    print_warn "No se encontró nvim/ en el repo"
    rm -rf "$tmpd"; return 1
  fi
  rm -rf "$tmpd"
}

configure_fish_shell() {
  if [ "${SHELL:-}" = "/usr/bin/fish" ] || [ "${SHELL:-}" = "/bin/fish" ]; then
    return 0
  fi
  if cmd_exists fish && menu_confirm "¿Cambiar shell por defecto a fish?"; then
    chsh -s "$(command -v fish)" 2>/dev/null && print_ok "Shell cambiada a fish" \
      || print_err "No se pudo cambiar shell (quizás chsh no está en /etc/shells)"
  fi
}

# ============================================================================
# 8. MODO 1: TODO DE UNA
# ============================================================================

mode_install_all() {
  print_header "Instalación Completa"
  print_info "Stack completo: Terminal + CLI Tools + Font + Dev Env + Dev Tools + Dev Apps"
  echo
  menu_confirm "¿Iniciar instalación completa?" || { print_info "Cancelado"; return; }

  local categories=("Terminal" "CLI Tools" "Font" "Dev Env" "Dev Tools" "Dev Apps" "Fisher")

  # Preparar sistema
  local total=${#categories[@]}
  print_step "0/${total}" "Preparando sistema..."
  run_bg "Actualizando repositorios" apt_update || true

  # Verificar conectividad antes de arrancar
  if ! check_network; then
    print_warn "Problemas de red detectados. Las descargas usarán reintentos automáticos."
    print_info "Si ves muchos fallos, revisá tu conexión y ejecutá el script de nuevo."
    echo
    menu_confirm "¿Continuar de todas formas?" || return
  fi

  install_category_loop "${categories[@]}"
  local global_ok=$CAT_OK global_fail=$CAT_FAIL global_skip=$CAT_SKIP

  # Configs
  deploy_configs

  echo
  print_info "¿Querés desplegar configs desde el repo (fish, nvim)?"
  if menu_confirm "Desplegar fish del repo"; then
    deploy_repo_fish
  fi
  if menu_confirm "Desplegar nvim del repo"; then
    deploy_repo_nvim
  fi

  fix_debian_binaries
  configure_fish_shell

  echo
  print_header "Instalación Completa — Finalizada"
  print_ok "Exitosos: ${global_ok}"
  [ "$global_fail" -gt 0 ] && print_err "Fallos: ${global_fail}" || true
  [ "$global_skip" -gt 0 ] && print_info "Omitidos (ya instalados): ${global_skip}" || true
  echo
  print_info "Cierra sesión y vuelve a entrar para aplicar todos los cambios."
  menu_prompt "Presiona Enter para volver al menú..." >/dev/null
}

# ============================================================================
# 9. MODO 2: UNO POR UNO
# ============================================================================

mode_one_by_one() {
  print_header "Instalación Uno por Uno"

  # Recopilar todas las herramientas en orden por categoría
  local categories=("Terminal" "CLI Tools" "Font" "Dev Env" "Dev Tools" "Dev Apps" "Fisher")
  local all_tools=()
  for cat in "${categories[@]}"; do
    while IFS= read -r t; do all_tools+=("$t"); done <<< "$(tools_in "$cat")"
  done

  print_info "${#all_tools[@]} herramientas disponibles."
  check_network >/dev/null 2>&1 || print_warn "Problemas de red — las descargas usarán reintentos."
  menu_confirm "¿Comenzar?" || return

  local ok=0 fail=0 skip=0
  for tool in "${all_tools[@]}"; do
    local desc; desc=$(tool_desc "$tool")
    local cat; cat=$(tool_cat "$tool")
    echo
    print_header "${tool}"
    print_info "${desc}  [${cat}]"

    if check_installed "$tool"; then
      print_ok "Ya instalado"
      skip=$((skip + 1))
      continue
    fi

    echo
    if ! menu_confirm "¿Instalar ${tool}?"; then
      print_info "Omitido"
      skip=$((skip + 1))
      continue
    fi

    if install_tool "$tool"; then
      print_ok "${tool} instalado correctamente"
      ok=$((ok + 1))
    else
      print_err "${tool} — falló la instalación"
      fail=$((fail + 1))
    fi
  done

  echo
  print_summary "$ok" "$fail" "$skip"
  deploy_configs

  echo
  print_info "¿Querés desplegar configs desde el repo (fish, nvim)?"
  if menu_confirm "Desplegar fish del repo"; then
    deploy_repo_fish
  fi
  if menu_confirm "Desplegar nvim del repo"; then
    deploy_repo_nvim
  fi

  fix_debian_binaries
  configure_fish_shell
}

# ============================================================================
# 10. MODO 3: SELECCIÓN CON CHECKBOXES
# ============================================================================

mode_selection() {
  print_header "Instalación por Selección"

  local categories=("Terminal" "CLI Tools" "Font" "Dev Env" "Dev Tools" "Dev Apps" "Fisher")
  local all_tools=()
  for cat in "${categories[@]}"; do
    while IFS= read -r t; do all_tools+=("$t"); done <<< "$(tools_in "$cat")"
  done

  local total=${#all_tools[@]}
  local sel=()
  for ((i=0; i<total; i++)); do sel[$i]=0; done

  while true; do
    clear
    print_header "Selecciona herramientas a instalar"
    echo -e "  ${C_DIM}<num> → toggle  |  ${C_GREEN}i${C_RESET} → instalar  |  ${C_RED}q${C_RESET} → salir${C_RESET}"
    echo

    local cur_cat=""
    for ((i=0; i<total; i++)); do
      local t="${all_tools[$i]}"
      local cat; cat=$(tool_cat "$t")
      local desc; desc=$(tool_desc "$t")
      local mark=" "; [ "${sel[$i]}" -eq 1 ] && mark="${C_GREEN}*${C_RESET}"

      [ "$cat" != "$cur_cat" ] && { cur_cat="$cat"; echo -e "  ${C_BOLD}${C_CYAN}── ${cat} ──${C_RESET}"; }
      local n=$((i + 1))
      local installed=false; check_installed "$t" && installed=true

      if $installed; then
        echo -e "  ${C_DIM}[${mark}${C_DIM}] ${n}. ${t} — ${desc} ${C_GREEN}(ok)${C_RESET}"
      else
        echo -e "  [${mark}] ${n}. ${C_BOLD}${t}${C_RESET} — ${desc}"
      fi
    done

    echo
    local action
    read -r -p "$(echo -e "  ${C_YELLOW}${ARROW}${C_RESET} Opción: ")" action </dev/tty

    case "$action" in
      q|Q) print_info "Saliendo"; return ;;
      i|I) break ;;
      *)
        if [ "$action" -ge 1 ] 2>/dev/null && [ "$action" -le "$total" ] 2>/dev/null; then
          local idx=$((action - 1))
          sel[$idx]=$(( sel[$idx] == 1 ? 0 : 1 ))
        fi
        ;;
    esac
  done

  # Recoger seleccionados
  local selected=()
  for ((i=0; i<total; i++)); do
    [ "${sel[$i]}" -eq 1 ] && selected+=("${all_tools[$i]}")
  done

  [ ${#selected[@]} -eq 0 ] && { print_warn "No seleccionaste nada."; return; }

  echo
  print_info "${#selected[@]} herramienta(s) seleccionadas."
  check_network >/dev/null 2>&1 || print_warn "Problemas de red — las descargas usarán reintentos."
  menu_confirm "¿Comenzar instalación?" || return

  local ok=0 fail=0 skip=0
  for tool in "${selected[@]}"; do
    echo
    print_header "$tool"
    if check_installed "$tool"; then
      print_ok "Ya instalado"; skip=$((skip + 1)); continue
    fi
    if install_tool "$tool"; then
      print_ok "Instalado correctamente"; ok=$((ok + 1))
    else
      print_err "Falló la instalación"; fail=$((fail + 1))
    fi
  done

  echo
  print_summary "$ok" "$fail" "$skip"
  deploy_configs

  echo
  print_info "¿Querés desplegar configs desde el repo (fish, nvim)?"
  if menu_confirm "Desplegar fish del repo"; then
    deploy_repo_fish
  fi
  if menu_confirm "Desplegar nvim del repo"; then
    deploy_repo_nvim
  fi

  fix_debian_binaries
  configure_fish_shell
}

# ============================================================================
# 11. MODO 4: SOLO CONFIGS
# ============================================================================

mode_deploy_configs() {
  print_header "Despliegue de Configuraciones"
  menu_confirm "¿Desplegar configuraciones desde backup?" || return
  deploy_configs

  echo
  print_info "También podés desplegar configs desde el repo:"
  if menu_confirm "Desplegar fish del repo"; then
    deploy_repo_fish
  fi
  if menu_confirm "Desplegar nvim del repo"; then
    deploy_repo_nvim
  fi

  echo
  print_info "Configuraciones desplegadas. Recarga tu shell o reinicia apps."
  menu_prompt "Presiona Enter..." >/dev/null
}

# ============================================================================
# 12. MODO 5: ESTADO
# ============================================================================

mode_check_status() {
  print_header "Estado del Stack de Desarrollo"

  local categories=("Terminal" "CLI Tools" "Font" "Dev Env" "Dev Tools" "Dev Apps" "Fisher")
  local global_ok=0 global_total=0

  for cat in "${categories[@]}"; do
    echo
    echo -e "  ${C_BOLD}${C_CYAN}── ${cat} ──${C_RESET}"
    while IFS= read -r t; do
      [ -z "$t" ] && continue
      global_total=$((global_total + 1))
      if check_installed "$t"; then
        global_ok=$((global_ok + 1))
        echo -e "  ${C_GREEN}${CHECK}${C_RESET} ${t}"
      else
        echo -e "  ${C_RED}${CROSS}${C_RESET} ${C_DIM}${t}${C_RESET}"
      fi
    done <<< "$(tools_in "$cat")"
  done

  echo
  print_divider
  printf "  ${C_BOLD}Resumen:${C_RESET} ${C_GREEN}%d/%d${C_RESET} herramientas instaladas\n" "$global_ok" "$global_total"
  echo
  menu_prompt "Presiona Enter para volver al menú..." >/dev/null
}

# ============================================================================
# 12.5 MODO STARTUP — Configuración inicial de Debian Desktop
# ============================================================================

# Shared category loop — itera categorías e instala herramientas.
# Usa CAT_OK, CAT_FAIL, CAT_SKIP (globales) para devolver resultados.
install_category_loop() {
  local categories=("$@")
  local step=0 total=${#categories[@]}
  CAT_OK=0 CAT_FAIL=0 CAT_SKIP=0

  for cat in "${categories[@]}"; do
    step=$((step + 1))
    echo
    print_step "${step}/${total}" "${cat}"
    print_divider

    local tools; tools=$(tools_in "$cat")
    if [ -z "$tools" ]; then
      print_warn "(sin herramientas)"
      continue
    fi

    local tlist=()
    while IFS= read -r t; do tlist+=("$t"); done <<< "$tools"

    local ok=0 fail=0 skip=0
    for tool in "${tlist[@]}"; do
      local desc; desc=$(tool_desc "$tool")
      if check_installed "$tool"; then
        skip=$((skip + 1))
        printf "  ${C_DIM}${BULLET} %s — %s ${C_GREEN}(ok)${C_RESET}\n" "$tool" "$desc"
      else
        printf "  ${C_CYAN}${BULLET}${C_RESET} Instalando ${C_BOLD}%s${C_RESET}...\n" "$tool"
        if install_tool "$tool"; then
          print_ok "${tool} instalado"
          ok=$((ok + 1))
        else
          print_err "${tool} — falló la instalación"
          fail=$((fail + 1))
        fi
      fi
    done

    local t="${#tlist[@]}"
    echo -e "  ${C_DIM}→ ${ok} exitosos, ${fail} fallos, ${skip} omitidos (${t} total)${C_RESET}"
    CAT_OK=$((CAT_OK + ok))
    CAT_FAIL=$((CAT_FAIL + fail))
    CAT_SKIP=$((CAT_SKIP + skip))
  done
}

# Globales para el resumen de mode_startup
STARTUP_OK=0
STARTUP_FAIL=0
STARTUP_SKIP=0

# ─── Step 0: GRUB Bootloader ────────────────────────────────────────────
# Clona la config de GRUB desde el repo GitHub y la aplica al sistema.
step_grub() {
  local grub_src="$REPO_DIR/grub/grub"
  local grub_dst="/etc/default/grub"

  # Guard: ya está actualizado?
  if [ -f "$grub_dst" ] && diff -q "$grub_src" "$grub_dst" >/dev/null 2>&1; then
    print_info "GRUB ya está en la configuración deseada (ok)"
    STARTUP_SKIP=$((STARTUP_SKIP + 1))
    return 0
  fi

  local ok=0 fail=0

  # Si el archivo local no existe, clonar desde GitHub
  if [ ! -f "$grub_src" ]; then
    print_info "Clonando config de GRUB desde GitHub..."
    local clone_url="https://github.com/DenLion09/DenLion09.dots.git"
    local tmpd; tmpd=$(mktemp -d)
    git clone --depth 1 --filter=blob:none --no-checkout "$clone_url" "$tmpd" >/dev/null 2>&1 || {
      print_err "No se pudo clonar el repo para obtener grub/"; rm -rf "$tmpd"; fail=$((fail + 1))
      STARTUP_FAIL=$((STARTUP_FAIL + fail)); return 1
    }
    git -C "$tmpd" sparse-checkout set grub >/dev/null 2>&1 || true
    git -C "$tmpd" checkout >/dev/null 2>&1 || {
      print_err "No se pudo hacer checkout de grub/"; rm -rf "$tmpd"; fail=$((fail + 1))
      STARTUP_FAIL=$((STARTUP_FAIL + fail)); return 1
    }
    if [ -f "$tmpd/grub/grub" ]; then
      mkdir -p "$REPO_DIR/grub"
      cp "$tmpd/grub/grub" "$grub_src" 2>/dev/null || true
      print_ok "Config de GRUB clonada desde GitHub"
    else
      print_err "No se encontró grub/grub en el repo"
      rm -rf "$tmpd"; fail=$((fail + 1))
      STARTUP_FAIL=$((STARTUP_FAIL + fail)); return 1
    fi
    rm -rf "$tmpd"
  fi

  # Aplicar la configuración al sistema
  if [ -f "$grub_src" ]; then
    print_info "Aplicando configuración de GRUB al sistema..."
    $SUDO cp "$grub_src" "$grub_dst" 2>/dev/null && {
      $SUDO chmod 644 "$grub_dst" 2>/dev/null
      print_ok "Config de GRUB copiada a $grub_dst"
      ok=$((ok + 1))
    } || {
      print_err "No se pudo copiar la config de GRUB"
      fail=$((fail + 1))
    }

    # Ejecutar update-grub para aplicar
    if [ "$ok" -gt 0 ]; then
      print_info "Ejecutando update-grub..."
      if $SUDO update-grub >/dev/null 2>&1; then
        print_ok "update-grub ejecutado correctamente"
        ok=$((ok + 1))
      else
        print_warn "update-grub falló — ejecutalo manualmente después"
        fail=$((fail + 1))
      fi
    fi
  else
    print_err "Archivo de configuración de GRUB no encontrado en $grub_src"
    fail=$((fail + 1))
  fi

  echo -e "  ${C_DIM}→ grub: ${ok} exitosos, ${fail} fallos${C_RESET}"
  STARTUP_OK=$((STARTUP_OK + ok))
  STARTUP_FAIL=$((STARTUP_FAIL + fail))
}

# ─── Step 1: Desktop Environment ─────────────────────────────────────────
# Wayland tools + Noctalia v5 (APT) / v4 (Quickshell fallback) + LabWC +
# LightDM session files + .dmrc
step_desktop_env() {
  # Guard: todo listo?
  if pkg_installed noctalia && pkg_installed labwc && [ -f "$HOME/.dmrc" ]; then
    print_info "Entorno de escritorio ya configurado (ok)"
    STARTUP_SKIP=$((STARTUP_SKIP + 1))
    return 0
  fi

  local ok=0 fail=0 skip=0

  # R7: Wayland tools
  print_info "Herramientas Wayland..."
  for pkg in wayland-protocols libwayland-dev wayland-utils; do
    if pkg_installed "$pkg"; then
      skip=$((skip + 1))
      printf "  ${C_DIM}${BULLET} %s ${C_GREEN}(ok)${C_RESET}\n" "$pkg"
    elif apt_install "$pkg"; then
      ok=$((ok + 1))
      print_ok "$pkg instalado"
    else
      fail=$((fail + 1))
      print_err "$pkg — falló la instalación"
    fi
  done

  # R8–R9: Noctalia (v5 APT, fallback v4/Quickshell)
  print_info "Noctalia Shell..."
  if pkg_installed noctalia; then
    skip=$((skip + 1))
    print_info "Noctalia ya instalado (ok)"
  else
    local noctalia_ok=true
    local tmpd; tmpd=$(mktemp -d)

    # Keyring
    print_info "Descargando keyring Noctalia..."
    dl_with_retry "https://pkg.noctalia.dev/deb/nickh-archive-keyring.deb" \
      "$tmpd/nickh-archive-keyring.deb" 2 15 60 || noctalia_ok=false
    if $noctalia_ok; then
      $SUDO dpkg -i "$tmpd/nickh-archive-keyring.deb" >/dev/null 2>&1 || noctalia_ok=false
    fi

    # Repo sources
    if $noctalia_ok; then
      print_info "Agregando repositorio Noctalia v5..."
      $SUDO sh -c "curl -fsSL 'https://pkg.noctalia.dev/deb/noctalia-trixie.sources' \
        -o /etc/apt/sources.list.d/noctalia-trixie.sources" 2>/dev/null || noctalia_ok=false
    fi

    # apt update + install
    if $noctalia_ok; then
      apt_update
      if apt_install noctalia; then
        print_ok "Noctalia v5 instalado"
        ok=$((ok + 1))
      else
        noctalia_ok=false
      fi
    fi

    rm -rf "$tmpd"

    # Fallback v4/Quickshell
    if ! $noctalia_ok; then
      print_warn "Noctalia v5 no disponible — probando v4/Quickshell..."
      if cmd_exists qs || cmd_exists noctalia-shell; then
        print_info "Noctalia v4/Quickshell ya presente (ok)"
        skip=$((skip + 1))
      else
        print_warn "Noctalia desktop session puede no estar disponible"
        fail=$((fail + 1))
      fi
    fi
  fi

  # R10: LabWC
  print_info "LabWC..."
  if pkg_installed labwc; then
    skip=$((skip + 1))
    print_info "LabWC ya instalado (ok)"
  elif apt_install labwc; then
    ok=$((ok + 1))
    print_ok "LabWC instalado"
  else
    fail=$((fail + 1))
    print_err "LabWC — falló la instalación"
  fi

  # R11: LightDM + session files
  print_info "LightDM + sesiones..."
  if pkg_installed lightdm; then
    skip=$((skip + 1))
    print_info "LightDM ya instalado (ok)"
  elif apt_install lightdm; then
    ok=$((ok + 1))
    print_ok "LightDM instalado"
  else
    print_err "LightDM — falló la instalación"
    fail=$((fail + 1))
  fi

  # Session .desktop files (via temp file + sudo cp para compatibilidad con set -e)
  local wl_dir="/usr/share/wayland-sessions"
  local xs_dir="/usr/share/xsessions"
  $SUDO mkdir -p "$wl_dir" "$xs_dir" 2>/dev/null || true

  local tmpf; tmpf=$(mktemp)
  cat > "$tmpf" << 'EOF'
[Desktop Entry]
Name=Noctalia
Comment=Noctalia Shell Desktop (Wayland)
Exec=noctalia
Type=Application
EOF
  $SUDO cp "$tmpf" "$wl_dir/noctalia.desktop" 2>/dev/null && \
    print_ok "Session file: wayland-sessions/noctalia.desktop" || \
    { print_err "No se pudo escribir wayland-sessions/noctalia.desktop"; fail=$((fail + 1)); }

  cat > "$tmpf" << 'EOF'
[Desktop Entry]
Name=Noctalia
Comment=Noctalia Shell Desktop (X11 fallback)
Exec=noctalia
Type=Application
EOF
  $SUDO cp "$tmpf" "$xs_dir/noctalia.desktop" 2>/dev/null && \
    print_ok "Session file: xsessions/noctalia.desktop" || \
    { print_err "No se pudo escribir xsessions/noctalia.desktop"; fail=$((fail + 1)); }
  rm -f "$tmpf"

  # R12: .dmrc
  if [ -z "${HOME:-}" ]; then
    print_warn "\$HOME no está definido — saltando .dmrc"
    fail=$((fail + 1))
  else
    if [ -f "$HOME/.dmrc" ]; then
      local dmrc_bak="$HOME/.dmrc.bak.$(date +%s)"
      cp "$HOME/.dmrc" "$dmrc_bak" 2>/dev/null || true
      print_info ".dmrc respaldado → $(basename "$dmrc_bak")"
    fi
    cat > "$HOME/.dmrc" << 'EOF'
[Desktop]
Session=noctalia
EOF
    print_ok ".dmrc escrito — sesión por defecto: noctalia"
    ok=$((ok + 1))
  fi

  # Sub-step summary
  echo -e "  ${C_DIM}→ escritorio: ${ok} exitosos, ${fail} fallos, ${skip} omitidos${C_RESET}"
  STARTUP_OK=$((STARTUP_OK + ok))
  STARTUP_FAIL=$((STARTUP_FAIL + fail))
  STARTUP_SKIP=$((STARTUP_SKIP + skip))
}

# ─── Step 2: Terminal ───────────────────────────────────────────────────
step_terminal() {
  cmd_exists xfce4-terminal && {
    print_info "xfce4-terminal ya instalado (ok)"
    STARTUP_SKIP=$((STARTUP_SKIP + 1))
    return 0
  }

  print_info "Instalando xfce4-terminal..."
  if install_tool "xfce4-terminal"; then
    print_ok "xfce4-terminal instalado"
    STARTUP_OK=$((STARTUP_OK + 1))
  else
    print_err "xfce4-terminal — falló la instalación"
    STARTUP_FAIL=$((STARTUP_FAIL + 1))
  fi
}

# ─── Step 3: Shell ──────────────────────────────────────────────────────
step_shell() {
  # Guard
  if cmd_exists fish && [ -f "${XDG_CONFIG_HOME:-$HOME/.config}/fish/config.fish" ]; then
    print_info "Fish shell ya configurado (ok)"
    STARTUP_SKIP=$((STARTUP_SKIP + 1))
    return 0
  fi

  local ok=0 fail=0 skip=0

  # Fish package
  print_info "Fish Shell..."
  if cmd_exists fish; then
    skip=$((skip + 1))
    print_info "fish ya instalado (ok)"
  elif install_tool "fish"; then
    ok=$((ok + 1))
    print_ok "fish instalado"
  else
    fail=$((fail + 1))
    print_err "fish — falló la instalación"
  fi

  # deploy_repo_fish (non-interactive, sin prompt)
  if cmd_exists fish; then
    print_info "Config de fish desde GitHub..."
    deploy_repo_fish || print_warn "No se pudo clonar config de fish (continuando)"
  fi

  # Fisher plugins (solo si fish está disponible)
  if cmd_exists fish; then
    print_info "Plugins de Fisher..."
    local fisher_tools
    fisher_tools=$(tools_in "Fisher")
    if [ -n "$fisher_tools" ]; then
      local ftlist=()
      while IFS= read -r t; do ftlist+=("$t"); done <<< "$fisher_tools"
      for tool in "${ftlist[@]}"; do
        if check_installed "$tool"; then
          skip=$((skip + 1))
          printf "  ${C_DIM}${BULLET} %s ${C_GREEN}(ok)${C_RESET}\n" "$tool"
        elif install_tool "$tool"; then
          ok=$((ok + 1))
          print_ok "${tool} instalado"
        else
          fail=$((fail + 1))
          print_err "${tool} — falló la instalación"
        fi
      done
    else
      print_warn "(sin plugins Fisher)"
    fi
  fi

  echo -e "  ${C_DIM}→ shell: ${ok} exitosos, ${fail} fallos, ${skip} omitidos${C_RESET}"
  STARTUP_OK=$((STARTUP_OK + ok))
  STARTUP_FAIL=$((STARTUP_FAIL + fail))
  STARTUP_SKIP=$((STARTUP_SKIP + skip))
}

# ─── Step 4: System Apps ────────────────────────────────────────────────
# Todas las categorías vía install_category_loop, SIN post-install hooks
step_apps() {
  local categories=("Terminal" "CLI Tools" "Font" "Dev Env" "Dev Tools" "Dev Apps" "Fisher")
  install_category_loop "${categories[@]}"
  STARTUP_OK=$((STARTUP_OK + CAT_OK))
  STARTUP_FAIL=$((STARTUP_FAIL + CAT_FAIL))
  STARTUP_SKIP=$((STARTUP_SKIP + CAT_SKIP))
}

# ─── Startup orchestrator ───────────────────────────────────────────────
mode_startup() {
  print_header "Startup — Configuración Inicial de Escritorio"
  print_info "Secuencia: GRUB → Escritorio → Terminal → Shell → Apps"
  echo
  menu_confirm "¿Iniciar configuración de startup?" || { print_info "Cancelado"; return; }

  # Resetear contadores
  STARTUP_OK=0 STARTUP_FAIL=0 STARTUP_SKIP=0

  # Verificar red
  if ! check_network; then
    print_warn "Problemas de red detectados. Las descargas usarán reintentos."
    echo
    menu_confirm "¿Continuar de todas formas?" || return
  fi

  # Preparar sistema
  run_bg "Actualizando repositorios" apt_update || true

  # Steps
  print_step "1/5" "GRUB — Gestor de Arranque"
  step_grub
  echo

  print_step "2/5" "Entorno de Escritorio"
  step_desktop_env
  echo

  print_step "3/5" "Terminal"
  step_terminal
  echo

  print_step "4/5" "Shell"
  step_shell
  echo

  print_step "5/5" "Apps del Sistema"
  step_apps
  echo

  # Rollup summary
  print_header "Startup — Resumen"
  local total=$((STARTUP_OK + STARTUP_FAIL + STARTUP_SKIP))
  print_ok "Exitosos: ${STARTUP_OK}"
  [ "$STARTUP_FAIL" -gt 0 ] && print_err "Fallos: ${STARTUP_FAIL}" || true
  [ "$STARTUP_SKIP" -gt 0 ] && print_info "Omitidos (ya instalados): ${STARTUP_SKIP}" || true
  echo -e "  ${C_DIM}→ ${total} operaciones totales${C_RESET}"
  [ "$STARTUP_FAIL" -gt 0 ] && echo -e "  ${C_YELLOW}${BULLET}${C_RESET} Algunos componentes requieren instalación manual"
  echo
  print_info "Cierra sesión y vuelve a entrar para aplicar todos los cambios."
  menu_prompt "Presiona Enter para volver al menú..." >/dev/null
}

# ─── RED Test: deploy_repo_fish URL boundary ────────────────────────────
# Verifica que deploy_repo_fish maneja URLs inalcanzables sin crash
test_startup_git_url_boundary() {
  print_header "RED Test: deploy_repo_fish — URL inalcanzable"
  local old_url="${DEPLOY_REPO_FISH_URL:-}"
  local rc=0

  print_info "Probando con URL inválida..."
  export DEPLOY_REPO_FISH_URL="https://github.com/invalid-repo-no-existe-12345.git"

  local output
  output=$(deploy_repo_fish 2>&1) || rc=$?

  if [ $rc -ne 0 ]; then
    print_ok "RED TEST PASSED — deploy_repo_fish retornó $rc (error esperado)"
    if echo "$output" | grep -qi "warning\|error\|no se pudo\|fall"; then
      print_ok "RED TEST — contiene mensaje de advertencia/error"
    else
      print_warn "RED TEST — retornó error pero sin mensaje claro"
    fi
  else
    print_err "RED TEST FAILED — deploy_repo_fish retornó 0 (debió fallar)"
    rc=1
  fi

  # Restaurar URL original
  if [ -n "$old_url" ]; then
    export DEPLOY_REPO_FISH_URL="$old_url"
  else
    unset DEPLOY_REPO_FISH_URL
  fi

  echo
  [ $rc -eq 0 ] && print_ok "RED TEST completado exitosamente" \
    || print_warn "RED TEST encontró un problema (revisar arriba)"
  return $rc
}

# ============================================================================
# 13. RESUMEN GENÉRICO
# ============================================================================

print_summary() {
  local ok=$1 fail=$2 skip=$3
  local total=$((ok + fail + skip))
  print_divider
  echo -e "  ${C_BOLD}Total:${C_RESET} ${total}  |  ${C_GREEN}Exitosos: ${ok}${C_RESET}  |  ${C_RED}Fallos: ${fail}${C_RESET}  |  ${C_YELLOW}Omitidos: ${skip}${C_RESET}"
  [ "$fail" -gt 0 ] && echo -e "  ${C_YELLOW}${BULLET}${C_RESET} Algunos requieren instalación manual (ver warnings)"
  echo
}

# ============================================================================
# 14. MENÚ PRINCIPAL
# ============================================================================

main_menu() {
  while true; do
    print_banner
    echo -e "  ${C_BOLD}Elegí el modo de instalación:${C_RESET}"
    echo
    echo -e "  ${C_BOLD}1${C_RESET}   Todo de una"
    echo -e "      ${C_DIM}Instala todo en secuencia automática${C_RESET}"
    echo
    echo -e "  ${C_BOLD}2${C_RESET}   Uno por uno"
    echo -e "      ${C_DIM}Te pregunto por cada herramienta${C_RESET}"
    echo
    echo -e "  ${C_BOLD}3${C_RESET}   Selección personalizada"
    echo -e "      ${C_DIM}Checkboxes → instalación en lote${C_RESET}"
    echo
    echo -e "  ${C_BOLD}4${C_RESET}   Solo configuraciones"
    echo -e "      ${C_DIM}Despliega configs desde backup${C_RESET}"
    echo
    echo -e "  ${C_BOLD}5${C_RESET}   Ver estado"
    echo -e "      ${C_DIM}Qué está instalado y qué falta${C_RESET}"
    echo
    echo -e "  ${C_BOLD}6${C_RESET}   Startup"
    echo -e "      ${C_DIM}Configuración inicial de Debian Desktop${C_RESET}"
    echo
    echo -e "  ${C_RED}q${C_RESET}   Salir"
    echo

    local choice
    read -r -p "$(echo -e "  ${C_YELLOW}${ARROW}${C_RESET} Opción [1-6/q]: ")" choice </dev/tty

    case "$choice" in
      1) mode_install_all ;;
      2) mode_one_by_one ;;
      3) mode_selection ;;
      4) mode_deploy_configs ;;
      5) mode_check_status ;;
      6) mode_startup ;;
      q|Q) echo; print_ok "¡Hasta luego!"; exit 0 ;;
      *) ;;
    esac
  done
}

# ============================================================================
# 15. ENTRY POINT
# ============================================================================

# Validar sistema
case "$OS_ID" in
  debian|ubuntu|linuxmint|pop) : ;;
  *)
    print_warn "Script diseñado para Debian/Ubuntu. Detectado: $OS_ID"
    menu_confirm "¿Continuar?" || exit 1
    ;;
esac

[ "$HAS_SUDO" = "yes" ] || { print_err "Este script necesita sudo."; exit 1; }

add_local_bin_to_path

main_menu
