# Terminal Setup — Fish Shell + CLI Tools

Basado en [DenLion09.dots.md](./DenLion09.dots.md). Solo incluye lo que ahí se menciona.

## Fish Shell

**Shell actual**: fish, configurado como shell por defecto del sistema.

### Archivos de configuración

```
~/.config/fish/config.fish          # Configuración principal
~/.config/fish/fish_plugins         # Lista de plugins (fisher)
~/.config/fish/fish_variables       # Variables universales
~/.config/fish/functions/           # Funciones personalizadas
~/.config/fish/completions/         # Completions (carapace)
~/.config/fish/conf.d/              # Configuraciones adicionales
~/.config/fish/themes/              # Temas (github-colorblind-dark, github-colorblind-white)
```

### config.fish — estructura

El archivo `config.fish` maneja cinco bloques:

1. **Bootstrap de Fisher** — si no existe, lo instala automáticamente al iniciar una shell interactiva
2. **Detección multiplataforma** — Termux, macOS (Apple Silicon / Intel) y Linux
3. **Inicialización de tools** — `starship`, `zoxide`, `atuin`, `fzf`, `carapace` se cargan al iniciar
4. **Look & feel** — colores de syntax highlighting y pager custom (palette gentleman)
5. **Variables de entorno** — `EDITOR`, `VISUAL`, `CARAPACE_BRIDGES`

### Tema / Colors

- Tema **github-colorblind-dark** y **github-colorblind-white** disponibles en `~/.config/fish/themes/`
- Los colores activos están hardcodeados en `config.fish` (líneas 89–120), palette gentleman:
  - `foreground`: `#F3F6F9`
  - `command` (cyan): `#7AA89F`
  - `keyword` (pink): `#FF8DD7`
  - `error` (red): `#CB7C94`
  - `parameter` (purple): `#A3B5D6`
  - `quote` (yellow): `#FFE066`

> **Nota**: También existe `~/.config/fish/conf.d/fish_frozen_theme.fish` (migración automática de fish 4.3) con una palette distinta (Base16), pero los colores de `config.fish` la sobrescriben al arrancar. Conviene eliminar el frozen theme si ya no se necesita.

### Plugins (fisher v4.4.3)

| Plugin | Propósito |
|--------|-----------|
| `jorgebucaran/fisher` | Gestor de plugins |
| `jorgebucaran/nvm.fish` | Node Version Manager — instala y cambia entre versiones de Node.js |
| `patrickf1/fzf.fish` | Integración de fzf: búsqueda en historial (`Ctrl+R`), archivos, directorios, procesos, variables |
| `oh-my-fish/plugin-pj` | Project jumper — salta a proyectos por nombre desde `$PROJECT_PATHS` |

> **Nota**: `fzf.fish` y `plugin-pj` están declarados en `fish_plugins` pero no aparecen instalados actualmente. Para activarlos: `fisher install patrickf1/fzf.fish oh-my-fish/plugin-pj`.

### Fish Functions

| Función | Código | Descripción |
|---------|--------|-------------|
| `c` | `clear` | Limpia la terminal |
| `q` | `exit` | Sale de la shell |
| `ll` | `ls -l` | Lista detallada |
| `la` | `ls -a` | Lista con archivos ocultos |
| `lla` | `ls -la` | Lista detallada con ocultos |
| `fzfbat` | `fzf --preview="bat --theme=gruvbox-dark --color=always {}"` | Buscar archivos con previsualización vía bat |
| `fzfnvim` | `nvim (fzf --preview="bat --theme=gruvbox-dark --color=always {}")` | Abrir archivo con fzf + nvim |
| `hotspot` | Wrapper de `create_ap` | Toggle WiFi hotspot on/off (interfaces: wlp0s20f3 / enp1s0) |

> **Nota**: `ll`, `la`, `lla` están documentados pero no definidos explícitamente en `config.fish`. Pueden depender de `plugin-pj` o de la configuración por defecto de fish. Si no funcionan, hay que agregarlos como aliases en `config.fish`.

---

## CLI Tools que extienden la terminal

### starship — prompt minimalista

- **Versión**: 1.25.1
- **Config**: `~/.config/starship.toml`
- **Paleta**: "DenLion09" basada en github-colorblind-dark
- **Módulos activos**: directory, git_branch, nodejs, rust, golang, php, bun, java, c, conda, zig, cmd_duration, time
- **Carácter de prompt**: `❯` (teal en éxito, rojo en error), minimalista
- **Logo de distro**: se obtiene dinámicamente vía el módulo `$os`, que detecta automáticamente Debian y muestra su icono
- Se activa en `config.fish` con: `starship init fish | source`

#### Configuración (`~/.config/starship.toml`)

```toml
format = """\
($directory)\
$os\
$git_branch\
$fill\
$nodejs\
$rust\
$golang\
$php\
$bun\
$java\
$c\
$conda\
$zig\
$cmd_duration\
$time\
\n$character\
"""

add_newline = true
command_timeout = 3600000
palette = "DenLion09"

[fill]
symbol = ' '

[palettes.DenLion09]
text = "#e6edf3"
red = "#f85149"
green = "#39d2c0"
yellow = "#d29922"
blue = "#58a6ff"
mauve = "#bc8cff"
pink = "#f778ba"
teal = "#39d2c0"
peach = "#d29922"
subtext0 = "#8b949e"
overlay0 = "#21262d"
rosewater = "#f778ba"
flamingo = "#f85149"
maroon = "#da3633"
lavender = "#bc8cff"
subtext1 = "#6e7681"
overlay2 = "#30363d"
overlay1 = "#21262d"
surface2 = "#30363d"
surface1 = "#21262d"
surface0 = "#161b22"
base = "#0d1117"
mantle = "#010409"
crust = "#010409"

[os]
disabled = false
style = "bold blue"

[character]
success_symbol = "[❯](fg:green)"
error_symbol = "[❯](fg:red)"

[username]
style_user = 'bold blue'
style_root = 'bold red'
format = '[$user](fg:blue) '
disabled = false
show_always = true

[directory]
format = "[$path](bold $style)[$read_only]($read_only_style) "
truncation_length = 2
style = "fg:blue"
read_only_style = "fg:blue"
before_repo_root_style = "fg:blue"
truncation_symbol = "…/"
truncate_to_repo = true
read_only = "  "

[directory.substitutions]
"Documents" = "󰈙 "
"Downloads" = " "
"Music" = " "
"Pictures" = " "

[cmd_duration]
format = " took [ $duration]($style) "
style = "bold fg:yellow"
min_time = 500

[git_branch]
format = "-> [$symbol$branch]($style) "
style = "bold fg:mauve"
symbol = " "

[git_status]
format = '[$all_status$ahead_behind ]($style)'
style = "fg:text bg:pink"

[docker_context]
disabled = true
symbol = " "

[python]
disabled = false
format = "[$symbol$pyenv_prefix($version)( $virtualenv)](fg:peach)"
symbol = " "
version_format = "$raw"

[java]
format = '[[ $symbol ($version) ](fg:red)]($style)'
version_format = "$raw"
symbol = " "
disabled = false

[c]
format = '[[ $symbol ($version) ](fg:blue)]($style)'
symbol = " "
version_format = "$raw"
disabled = false

[zig]
format = '[[ $symbol ($version) ](fg:peach)]($style)'
version_format = "$raw"
disabled = false

[bun]
version_format = "$raw"
format = '[[ $symbol ($version) ](fg:text)]($style)'
disabled = false

[nodejs]
symbol = ""
format = '[[ $symbol ($version) ](fg:green)]($style)'

[rust]
symbol = ""
format = '[[ $symbol ($version) ](fg:red)]($style)'

[golang]
symbol = ""
format = '[[ $symbol ($version) ](fg:teal)]($style)'

[php]
symbol = ""
format = '[[ $symbol ($version) ](fg:peach)]($style)'

[time]
disabled = false
time_format = "%R"
format = '[[   $time ](fg:subtext0)]($style)'
```

### atuin — historial de comandos con búsqueda fuzzy

- **Versión**: 18.16.1
- **Config**: `~/.config/atuin/config.toml` (con valores por defecto)
- Almacena el historial de shell en una base de datos SQLite con timestamps, salidas, directorios
- Se activa en `config.fish` con: `atuin init fish | source`
- Reemplaza el historial nativo de fish con búsqueda fuzzy vía `Ctrl+R`

### fzf — fuzzy finder

- **Versión**: 0.73.1
- **Integración nativa**: `fzf --fish | source`
- **Uso en aliases**:
  - `fzfbat` — preview de archivos con bat
  - `fzfnvim` — abre archivo seleccionado en nvim
- **Variables**:
  - `FZF_DEFAULT_OPTS`: `--height 40%`
  - `FZF_DISABLE_KEYBINDINGS`: `0`
  - `FZF_LEGACY_KEYBINDINGS`: `1`
- Previsualización por defecto con `bat --theme=gruvbox-dark`

### carapace — autocompletado universal

- **Versión**: 1.7.0
- **Propósito**: genera autocompletados para cualquier comando desde un solo binario
- **Puente**: `CARAPACE_BRIDGES=zsh,fish,bash,inshellisense`
- **Inicialización**: genera archivos `.fish` en `~/.config/fish/completions/` para cada comando detectado
- Se activa con: `carapace _carapace | source`

### bottom (btm) — System CLI taskmanager

- **Instalación**: `cargo install bottom`
- **Alternativa a**: btop — escrito en Rust, consume menos recursos
- **Métricas**: CPU, memoria, discos, red, procesos
- Tema por defecto con soporte para gráficos en terminal

### ripgrep (rg) — grep ultrarápido

- **Versión**: 15.1.0
- Reemplazo moderno de `grep`. Búsqueda recursiva por defecto, respeta `.gitignore`, utf-8 nativo.
- No requiere configuración en fish — se usa directamente como `rg <patrón>`.

### fd — find moderno y rápido

- **Versión**: 10.4.2
- Reemplazo de `find`. Sintaxis intuitiva, respeta `.gitignore`, colores por tipo.
- No requiere configuración en fish.

### eza — ls moderno con colores e iconos

- **Documentado en DenLion09.dots.md pero no instalado actualmente**
- Alternativa a `ls` con soporte de iconos, colores por tipo de archivo, y vista en árbol
- Para instalarlo: `sudo apt install eza` o `cargo install eza`

### yazi — file manager TUI

- **Documentado en DenLion09.dots.md pero no instalado actualmente**
- File manager de terminal con preview de archivos, tabs, y integración de herramientas externas
- Para instalarlo: `cargo install yazi-fm`

### fastfetch — neofetch moderno

- **Versión**: 2.40.4
- Muestra información del sistema: OS, kernel, uptime, paquetes, shell, resolución, DE, theme, icons, terminal, CPU, GPU, memoria, discos
- No requiere configuración en fish

### bat — cat con syntax highlighting

- **Versión**: 0.26.1
- **Propósito**: `cat` con syntax highlighting, números de línea, integración con git
- **Tema por defecto en aliases**: `gruvbox-dark`
- Se usa en `fzfbat` y `fzfnvim` para previsualización de archivos

### jq — procesador JSON desde la terminal

- **Versión**: 1.7
- Procesa y filtra JSON desde stdin/archivos. Uso típico: `curl api.example.com | jq '.data'`
- No requiere configuración en fish

### yq — procesador YAML/XML/TOML desde la terminal

- **Documentado en DenLion09.dots.md pero no instalado actualmente**
- Análogo a `jq` pero para YAML, XML, TOML, etc.
- Para instalarlo: `pip install yq` o `cargo install yq`

---

## Integración en el startup de Fish

Orden de carga en `config.fish`:

```
1. Clear — pantalla limpia al abrir la terminal
2. Fisher bootstrap (si no existe)
3. Detección de plataforma + PATH
4. starship init fish | source
5. atuin init fish | source
6. fzf --fish | source
7. carapace completions
8. fish_greeting = ""
9. EDITOR/VISUAL = nvim
10. Aliases (ls, fzfbat, fzfnvim)
11. Colores syntax highlighting + pager
```

## Variables de entorno

| Variable | Valor | Propósito |
|----------|-------|-----------|
| `EDITOR` | `nvim` | Editor por defecto para herramientas CLI |
| `VISUAL` | `nvim` | Editor visual por defecto |
| `CARAPACE_BRIDGES` | `zsh,fish,bash,inshellisense` | Fuentes de autocompletado para carapace |
| `FZF_DEFAULT_OPTS` | `--height 40%` | Altura por defecto del selector fzf |

