# Configuración del Sistema - Debian 13 (Trixie)

## Información General del Sistema

| Campo                 | Valor                        |
| --------------------- | ---------------------------- |
| **Sistema Operativo** | Debian GNU/Linux 13 (Trixie) |
| **Kernel**            | 6.12.57+amd64                |
| **Hostname**          | diorges-pc                   |
| **Arquitectura**      | x86_64                       |
| **Usuario**           | diorges                      |

## Shell

- **Shell actual**: Fish (`/usr/bin/fish`)
- **Shells disponibles**: bash, fish, dash, sh, rbash

### Configuración de Fish

Archivo de configuración: `~/.config/fish/config.fish`

```fish
if status is-interactive
    set fish_greeting ""
end

# opencode
fish_add_path /home/diorges/.opencode/bin
```

## Entorno de Escritorio

- **Gestor de escritorio**: XFCE
- **Gestor de sesión**: LightDM

### Servicios Activos

| Servicio                | Descripción        |
| ----------------------- | ------------------ |
| NetworkManager          | Gestión de redes   |
| bluetooth.service       | Bluetooth          |
| cups.service            | Impresión CUPS     |
| avahi-daemon.service    | mDNS/DNS-SD        |
| accounts-daemon.service | Cuentas de usuario |
| polkit.service          | Autorización       |
| udisks2.service         | Gestión de discos  |
| cron.service            | Tareas programadas |

## Repositorios APT

Archivo: `/etc/etc/apt/sources.list`

```
# Repositorio Principal
deb http://deb.debian.org/debian trixie main contrib non-free non-free-firmware

# Actualizaciones de seguridad
deb http://security.debian.org/debian-security/ trixie security main contrib non-free non-free-firmware

# Updates (volátiles)
deb http://deb.debian.org/debian trixie-updates main contrib non-free non-free-firmware

# Backports
deb http://deb.debian.org/debian trixie-backports main contrib non-free non-free-firmware
```

Repositorios adicionales:

- `vscode.sources` en `/etc/apt/sources.list.d/`

## Herramientas de Desarrollo

| Herramaienta | Versión      | Ubicación       |
| ------------ | ------------ | --------------- |
| Node.js      | v20.19.2     | `/usr/bin/node` |
| npm          | -            | `/usr/bin/npm`  |
| Go           | No instalado | -               |
| Rust         | No instalado | -               |
| Docker       | No instalado | -               |

## Configuración de Git

Archivo: `~/.gitconfig`

```ini
[credential "https://github.com"]
    helper =
    helper = !/usr/bin/gh auth git-credential

[credential "https://gist.github.com"]
    helper =
    helper = !/usr/bin/gh auth git-credential
```

**Nota**: GitHub CLI (`gh`) configurado como helper de credenciales.

## SSH

- **Estado**: No configurado (directorio `~/.ssh` no existe)
- **Recomendación**: Generar claves SSH paraGitHub/GitLab

## Aplicaciones Instaladas (selección)

- **7zip** 25.01
- **VS Code** (fuentes configuradas en apt)
- **Firefox/Mozilla** en `~/.mozilla`
- **LibreOffice** en `~/.config/libreoffice`
- **OnlyOffice** en `~/.config/onlyoffice`
- **ProtonVPN** (paquete `.deb` descargado: `protonvpn-stable-release_1.0.8_all.deb`)
- **Epson Scan 2** en `~/.epsonscan2`
- **GoldenDict** en `~/.config/goldendict`
- **Thunar** (gestor de archivos XFCE)
- **GIMP/GTK** en `~/.config/gtk-3.0`

## Extensiones de VS Code

| Extensión           | ID                                    |
| ------------------- | ------------------------------------- |
| Markdown lint       | davidanson.vscode-markdownlint-0.61.2 |
| ESLint              | dbaeumer.vscode-eslint-3.0.24         |
| Prettier            | esbenp.prettier-vscode-12.4.0         |
| GitHub Copilot      | github.copilot-chat-0.43.0            |
| GitHub Theme        | github.github-vscode-theme-6.3.5      |
| Material Icon Theme | pkief.material-icon-theme-5.33.1      |
| OpenCode            | sst-dev.opencode-0.0.13               |

## OpenCode

- **Instalado en**: `~/.opencode`
- **Configuración**: `~/.config/opencode/`
- **Archivo de configuración**: `~/.config/opencode/opencode.json`
- **Skills disponibles**: sdd-\*, go-testing, branch-pr, issue-creation, judgment-day, skill-creator, skill-registry

## Directorios del Usuario

| Directorio     | Descripción |
| -------------- | ----------- |
| `~/Work`       | Trabajo     |
| `~/Documentos` | Documentos  |
| `~/Descargas`  | Descargas   |
| `~/Imágenes`   | Imágenes    |
| `~/Vídeos`     | Vídeos      |
| `~/Música`     | Música      |
| `~/Escritorio` | Escritorio  |
| `~/Plantillas` | Plantillas  |
| `~/Público`    | Público     |

## Notas y Recomendaciones

1. **SSH**: Generar claves SSH para autenticación con GitHub/GitLab
2. **Docker**: No instalado - considerar instalación si se necesita contenedores
3. **Go/Rust**: No instalados - instalar si se requiere desarrollo en estos lenguajes
4. **VPN**: Paquete de ProtonVPN descargado pero no instalado
5. **Shell**: Fish configurado correctamente con prompt vacío
