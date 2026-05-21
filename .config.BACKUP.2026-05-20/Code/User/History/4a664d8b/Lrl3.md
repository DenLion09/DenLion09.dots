# Guía de Optimización — EndeavourOS / CachyOS

> **Hardware de referencia**: Celeron N4500 · 8GB RAM · 1080p
> **Objetivo**: Máximo rendimiento, mínima fricción, configuración fácil o automática.

---

## Índice

1. [Elegir el camino](#1-elegir-el-camino)
2. [Instalación rápida](#2-instalación-rápida)
3. [Entorno de escritorio](#3-entorno-de-escritorio)
4. [Laptop features (automático)](#4-laptop-features-automático)
5. [Rendimiento máximo](#5-rendimiento-máximo)
6. [Hermoso sin esfuerzo](#6-hermoso-sin-esfuerzo)
7. [Apps mínimas y funcionales](#7-apps-mínimas-y-funcionales)
8. [Checklist post-instalación](#8-checklist-post-instalación)

---

## 1. Elegir el camino

| Si quieres...                                                                              | Elige        |
| ------------------------------------------------------------------------------------------ | ------------ |
| Máxima velocidad + estética moderna (con 1 tarde de setup)                                 | **Hyprland** |
| instalar y usar en cualquier dispositivo, con GUI, sin tocar terminal para configuraciones | **Gnome**    |

### ¿CachyOS, EndeavourOS o Fedora?

| Aspecto                | CachyOS                                        | EndeavourOS                       | Fedora (Workstation)             |
| ---------------------- | ---------------------------------------------- | --------------------------------- | -------------------------------- |
| Modelo                 | Rolling (semanal)                              | Semi-rolling (quincenal)          | Fixed (6 meses) + rebases        |
| Kernel optimizado      | ✅ `linux-cachyos` (auto)                      | ❌ kernel stock (servible)        | ✅ kernel stock (actualizado)    |
| Rendimiento extra      | ~5-10% en CPU moderna                          | igual que Arch normal             | similar a Arch normal            |
| En N4500 (Jasper Lake) | ❌ Ganancia mínima, puede ser contraproducente | ✅ Más estable en hardware básico | ✅ Muy estable, drivers actuales |
| Instalador GUI         | ✅ sí                                          | ✅ sí                             | ✅ sí (Anaconda)                 |
| Driver GPU auto        | ✅ sí                                          | ✅ sí                             | ✅ sí                            |
| AUR habilitado         | ✅ sí                                          | ✅ sí                             | ❌ NO (usa RPM Fusion)           |
| Ecosistema             | Arch + AUR                                     | Arch + AUR                        | Red Hat/Fedora                   |

#### ¿Cuál elegir?

| Si quieres...                                    | Elige              |
| ------------------------------------------------ | ------------------ |
| Máxima actualización (bleeding edge)             | **CachyOS**        |
| Balance estabilidad + actualizaciones frecuentes | **EndeavourOS**    |
| Enterprise-grade, estabilidad garantizada        | **Fedora**         |
| Ecosistema Arch (AUR, aurutils, yay)             | CachyOS o Endeavor |
| Empresarial / profesional                        | **Fedora**         |

**Recomendación para este hardware**: EndeavourOS. Es más predecible, no fuerza optimizaciones que apenas benefician a un Celeron, y tiene el mismo ecosistema Arch + AUR.

#### ¿Cuándo elegir modelo rolling?

| Criterio                    | Elige rolling         | Elige fixed       |
| --------------------------- | --------------------- | ----------------- |
| Tolerancia a breakages      | Alta                  | Baja              |
| Frecuencia de reinstall     | Cada 1-2 años         | Cada 2-3 años     |
| Gusto por actualizar        | Disfruto estar al día | Prefiero no tocar |
| Uso profesional/servidor    | ❌ NO                 | ✅ SÍ             |
| Hardware moderno (1-2 años) | ✅ Sí (kernel nuevo)  | Puede servir      |
| Hardware básico (4+ años)   | ✅ EndeavourOS        | ✅ Fedora         |

**Regla simple**: Si te molesta actualizar, usa Fedora. Si te gusta estar al día y sabes resolver problemas, rolling es para ti.

---

## 2. Instalación rápida

### EndeavourOS — ~20 minutos

1. Descargar ISO desde [endeavouros.com](https://endeavouros.com)
2. Bootear → elegir **"Online Desktop"**
3. En el instalador gráfico:
   - Elegir **"Desktop: Hyprland"** o **"Desktop: KDE Plasma"**
   - Marcar `endeavouros-hyprland-conf` o `plasma-meta` según tu elección
   - Marcar `NVIDIA` solo si tienes GPU NVIDIA (en este caso Intel UHD → NO marcar)

4. Termina la instalación → reiniciar → **Welcome App** se abre sola:
   - `Enable AUR` → sí
   - `Install Nvidia drivers` → omitir (Intel)
   - `Install printer support` → solo si tienes impresora
   - `Timeshift auto-snapshots` → recomiendo SÍ

**Resultado**: Sistema funcionando con drivers, AUR, y firewall en <30 minutos.

### CachyOS — ~20 minutos

1. Descargar ISO desde [cachyos.org](https://cachyos.org)
2. Bootear → elegir edición **Hyprland** o **KDE**
3. En `cachyos-hello` (se abre automáticamente al iniciar):
   - `Easy Installation` → drivers detectados automáticamente
   - `Kernel Manager` → dejar `linux-cachyos` por defecto
   - `Proton` → solo si juegas

---

## 3. Entorno de escritorio

### Opción A: Hyprland — la recomendada (fácil + moderno + ligero)

**Tiempo total**: 1 hora incluida configuración visual.
**RAM idle**: ~350MB.
**Setup**: 90% con GUI gracias a `nwg-shell`.

#### Post-instalación automática (un solo comando)

**EndeavourOS** (si elegiste Hyprland en el instalador, ya tienes lo básico):

```bash
# Un solo comando: todo lo que necesitas para un Hyprland funcional y bonito
sudo pacman -S nwg-shell hyprpaper waybar rofi-wayland \
  swaync dunst polkit-kde-agent xdg-desktop-portal-hyprland \
  ttf-jetbrains-mono-nerd noto-fonts-emoji \
  brightnessctl playerctl pamixer
```

**CachyOS** (similar):

```bash
sudo pacman -S nwg-shell hyprpaper waybar rofi-wayland \
  swaync dunst brightnessctl pamixer playerctl
```

#### Configurar Hyprland con GUI

```bash
# El asistente gráfico de nwg-shell — ejecuta esto UNA SOLA VEZ:
nwg-shell-install
```

Esto te da:

- ✅ Panel superior/inferior configurable con clicks
- ✅ App launcher con íconos
- ✅ Gestión de ventanas con tiling automático
- ✅ Atajos de teclado pre-configurados
- ✅ Temas pre-instalados

**Lo que configuras con clicks (no terminal)**:

- `Super + M` → abrir el menú de nwg-shell
- `nwg-look` → tema GTK, íconos, cursors (GUI)
- `nwg-bar` → botón de apagado/suspender/reboot
- `nwg-menu` → lanzador de apps

#### Archivos que puedes tocar si quieres (OPCIONAL, no obligatorio)

```bash
~/.config/hypr/hyprland.conf    # muevas, atajos, monitores
~/.config/waybar/config.jsonc    # barra de estado
~/.config/waybar/style.css       # estilos de la barra
```

Pero **no necesitas tocarlos** si usas `nwg-shell`.

#### Atajos básicos que funcionan desde el primer boot

| Tecla                 | Acción                    |
| --------------------- | ------------------------- |
| `Super + Q`           | Cerrar ventana            |
| `Super + Enter`       | Terminal (kitty o foot)   |
| `Super + D`           | Lanzador de apps (rofi)   |
| `Super + 1-9`         | Cambiar workspace         |
| `Super + Shift + 1-9` | Mover ventana a workspace |
| `Super + F`           | Fullscreen                |
| `Super + V`           | Modo float/tile toggle    |
| `Super + L`           | Bloquear pantalla         |

---

### Opción B: KDE Plasma 6 — si NO quieres tocar nada

**RAM idle**: ~550MB (con ajustes).
**Setup**: 100% GUI desde System Settings.

#### Instalación minimalista (evita el grupo completo que trae 50 apps)

**EndeavourOS** — durante la instalación elige "KDE Plasma" → ya viene razonable.
Después:

```bash
# Remover apps que no necesitas
sudo pacman -Rns elisa gwenview okular kate ktorrent krdc krfb \
  kmail kontact akregator korganizer kaddressbook dragon \
  kamoso kmahjongg kmines kpat ksnakeduel katomic kblackbox \
  kbounce kdiamond kfourinline kgoldrunner kollision konquest \
  kreversi kshisen ksquares ksudoku ktuberling kubrick \
  kapman klickety kolf
```

Perdón por la lista larga — **esto es lo que pesa**. Si instalaste KDE sin editar, te viene TODO eso.

**Alternativa más limpia**: instalar solo el grupo core desde terminal:

```bash
sudo pacman -S plasma-desktop plasma-wayland-session
# Luego agregar solo lo que necesitas:
sudo pacman -S dolphin konsole kscreen krunner kwrite
```

**Ajustes para rendimiento** (System Settings → lo buscas en la lupa):

| Ajuste                            | Dónde                        | Valor                            |
| --------------------------------- | ---------------------------- | -------------------------------- |
| Compositor → Renderizer           | Display → Compositor         | `XRender`                        |
| Animaciones                       | Workspace Behavior → Effects | Desactivar sombras/transparencia |
| Baloo (búsqueda)                  | Search → File Search         | DESACTIVAR                       |
| Sesión → Restore previous session | Startup & Shutdown           | `Empty session`                  |
| Power Management                  | Hardware → Power Management  | `Power Save` en batería          |

---

## 4. Laptop features (automático)

### Power Management — un solo paquete lo hace todo

**Opción 1 — power-profiles-daemon** (recomendada, más simple):

```bash
sudo pacman -S power-profiles-daemon
sudo systemctl enable --now power-profiles-daemon
```

Luego usas:

```bash
powerprofilesctl set power-saver   # batería
powerprofilesctl set balanced      # normal
powerprofilesctl set performance   # rendimiento
```

Hyprland y KDE lo detectan automáticamente.

**Opción 2 — auto-cpufreq** (más agresiva, automática):

```bash
# Detectar batería/AC y ajustar CPU automáticamente
yay -S auto-cpufreq
sudo systemctl enable --now auto-cpufreq
```

Listo. No tocas nada más. Detecta cuando estás enchufado vs batería y ajusta frecuencias.

**Recomendación**: usa **power-profiles-daemon** + instala **auto-cpufreq** solo como respaldo.

### Hibernación / Suspensión — automático

```bash
# Tamaño del archivo de hibernación (8GB RAM → 8GB swap)
sudo fallocate -l 8G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Hacerlo permanente
echo '/swapfile none swap defaults 0 0' | sudo tee -a /etc/fstab
```

**CachyOS** ya configura swap automáticamente durante la instalación.
**EndeavourOS** te pregunta el tamaño de swap en el instalador — elige **8GB o "Suspend to disk"**.

Después:

```bash
# En Hyprland: Super + L (bloquear), el botón de apagado en nwg-bar tiene "Suspend"
# En KDE: todo desde System Settings → Power Management → "Sleep and Hibernation" → automático
```

### WiFi — automático (ya funciona al instalar)

Si no ves redes:

```bash
# Solo si hay problemas:
sudo nmtui  # interfaz TUI para NetworkManager - fácil, con menús
```

`nm-applet` (icono en la bandeja del sistema) se instala automáticamente con EndeavourOS/CachyOS.

### Bluetooth — un comando y funciona

```bash
sudo pacman -S bluez bluez-utils blueman
sudo systemctl enable --now bluetooth
```

Luego abres **Blueman** (`blueman-manager` o desde el menú de apps) y conectas con clicks.

En **Hyprland**, `blueman-applet` se agrega al tray automáticamente si lo ejecutas en el `hyprland.conf`:

```conf
exec-once = blueman-applet
```

(nwg-shell ya lo incluye si Blueman está instalado)

### Brillo y teclas de función (automático)

```bash
sudo pacman -S brightnessctl
```

En la mayoría de laptops, las teclas de brillo funcionan OUT OF THE BOX con EndeavourOS/CachyOS.

Si no funcionan, en Hyprland:

```conf
# En ~/.config/hypr/hyprland.conf
bindel = ,XF86MonBrightnessUp, exec, brightnessctl s +5%
bindel = ,XF86MonBrightnessDown, exec, brightnessctl s 5%-
```

En KDE → System Settings → Keyboard → Shortcuts → ya están mapeadas.

### Suspender al cerrar tapa (automático en ambos)

**EndeavourOS**: en `/etc/systemd/logind.conf`:

```
HandleLidSwitch=suspend
HandleLidSwitchExternalPower=suspend   # opcional: también suspendido cuando enchufado
```

**CachyOS**: ya viene configurado para suspender al cerrar tapa.

En KDE: System Settings → Power Management → Energy Saving → "When laptop lid closed" → elegir.

---

## 5. Rendimiento máximo

### Plan de 5 pasos (pocos comandos, mucho efecto)

#### 1. Kernel params de arranque (menos latencia)

Editar `/etc/default/grub` (o en EndeavourOS `/etc/default/grub`):

```
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash mitigations=off nowatchdog"
```

Luego:

```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg   # BIOS
# o
sudo grub-mkconfig -o /boot/efi/EFI/GRUB/grub.cfg   # UEFI
```

Esto desactiva:

- `mitigations=off` → desactiva parches de seguridad de CPU (en un Celeron personal, asumimos riesgo aceptable)
- `nowatchdog` → libera un núcleo que watchdog usa (en N4500 de 2 núcleos, importa)

#### 2. Swappiness baja (menos swap, más RAM)

```bash
echo 'vm.swappiness=10' | sudo tee /etc/sysctl.d/99-swappiness.conf
```

Esto hace que el sistema use swap SOLO cuando sea realmente necesario.

#### 3. Servicios que puedes desactivar (innecesarios en desktop)

```bash
sudo systemctl disable --now bluetooth.service   # si no usas BT
sudo systemctl disable --now cups.service        # si no tienes impresora
sudo systemctl disable --now systemd-resolved    # si usas NetworkManager (default)
```

#### 4. Usar `earlyoom` (evita que el sistema se congele por falta de RAM)

```bash
sudo pacman -S earlyoom
sudo systemctl enable --now earlyoom
```

Con 8GB de RAM, **esto es lo más importante que puedes instalar**. Si una app se vuelve loca y consume toda la RAM, en vez de que la laptop se congele 5 minutos, earlyoom mata el proceso culpable al toque.

#### 5. I/O scheduler para SSD (si tu laptop tiene SSD — casi seguro)

```bash
# Verificar qué scheduler tienes
cat /sys/block/nvme0n1/queue/scheduler

# Para NVMe → `none` es ideal
echo 'ACTION=="add|change", KERNEL=="nvme*", ATTR{queue/scheduler}="none"' | sudo tee /etc/udev/rules.d/60-iosched.rules

# Para SATA SSD → `mq-deadline`
echo 'ACTION=="add|change", KERNEL=="sd*[!0-9]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"' | sudo tee -a /etc/udev/rules.d/60-iosched.rules
```

---

## 6. Hermoso sin esfuerzo

### Hyprland — belleza en 5 minutos

```bash
# Tema Catppuccin Mocha (el más popular, funciona out of the box)
yay -S catppuccin-gtk-theme-mocha nwg-look

# Aplicar tema GTK
nwg-look  # GUI — seleccionas "Catppuccin-Mocha-Standard-..." y aplicas

# Wallpaper bonito (autocambiante)
sudo pacman -S hyprpaper
```

`~/.config/hypr/hyprpaper.conf`:

```conf
preload = ~/Pictures/wallpaper.jpg
wallpaper = ,~/Pictures/wallpaper.jpg
```

Descargar wallpapers: [hyprwall.me](https://hyprwall.me) o buscar "hyprland wallpaper" en Google.
Recomendación personal: fondos oscuros de **Catppuccin** o **Nord** — se ven modernos y gastan menos batería (pantalla LCD).

### KDE — belleza en 2 minutos (GUI)

System Settings → Appearance:

- **Global Theme**: Breeze (viene instalado) o instalar **Catppuccin KDE** desde `systemsettings` → "Get New Global Theme"
- **Iconos**: Tela Circle (instalar con `yay -S tela-circle-icon-theme`)
- **Cursor**: Bibata Modern (`yay -S bibata-cursor-theme`)
- **Dock**: Latte Dock o `panel flotante` → click derecho en panel → "Edit Mode" → hacerlo flotante

En 5 minutos se ve así:

- Tema oscuro
- Iconos redondeados modernos
- Panel flotante transparente
- Dock estilo macOS

### Wallpaper Manager automático (opcional)

```bash
sudo pacman -S variety
```

Variety cambia el wallpaper cada cierto tiempo desde carpetas locales o fuentes online. Funciona tanto en Hyprland como KDE.

---

## 7. Apps mínimas y funcionales

| Categoría | App                                       | Por qué                                                                  |
| --------- | ----------------------------------------- | ------------------------------------------------------------------------ |
| Terminal  | **Kitty** o **Foot**                      | Foot es Wayland nativo, super ligero (~15MB RAM). Kitty es más completo. |
| Navegador | **Firefox** o **Brave**                   | Firefox con `Wayland` nativo. Brave es más rápido con el mismo hardware. |
| Archivos  | **Thunar** (Hyprland) o **Dolphin** (KDE) | Thunar: 20MB, rápido. Dolphin: integración KDE.                          |
| Captura   | **Grim + Slurp** (Hyprland)               | `grim` captura, `slurp` selecciona área. Sin interfaz que consuma.       |
| Editor    | **Geany** o **Kate**                      | Geany 25MB, Kate ~80MB. VS Code pesa 400MB+.                             |
| Notas     | **Notion web** o **Obsidian**             | Ambos corre en Chromium, 200-300MB, pero son productivos.                |
| Música    | **Spotify** (Flatpak) o **ncspot** (TUI)  | Spotify ~200MB, ncspot ~15MB.                                            |
| Video     | **mpv**                                   | Reproductor de video más ligero que existe, acelera GPU automático.      |

### Apps que NO instalar (peso innecesario)

| ❌ App      | Alternativa                                                  |
| ----------- | ------------------------------------------------------------ |
| LibreOffice | **OnlyOffice** (más ligero, compatible MS) o Google Docs web |
| GIMP        | **Pinta** o **Krita** (solo si editas fotos)                 |
| Thunderbird | **Mail web** (Gmail/Outlook/Proton) en Firefox               |
| VirtualBox  | **Quickemu** (más ligero, sin módulos kernel)                |

---

## 8. Checklist post-instalación

Después de instalar, sigue este orden:

### Día 1 — Base funcional (~1 hora)

- [ ] Instalar SO (EndeavourOS recomendado)
- [ ] Conectar WiFi (automático)
- [ ] Abrir Welcome App → habilitar AUR, instalar drivers
- [ ] `sudo pacman -Syu` (actualizar todo)
- [ ] `sudo pacman -S power-profiles-daemon earlyoom` (rendimiento)
- [ ] `sudo systemctl enable --now power-profiles-daemon earlyoom`
- [ ] Instalar Hyprland o ajustar KDE (ver sección 3)
- [ ] Configurar swap/hibernación (sección 4)
- [ } Instalar Bluetooth (solo si lo usas)
- [ ] Instalar `nwg-shell` + `nwg-shell-install` (Hyprland) o ajustar KDE

### Día 2 — Belleza + apps (~30 min)

- [ ] Aplicar tema Catppuccin (Hyprland) o KDE global theme
- [ ] Poner wallpaper
- [ ] Instalar navegador + extensions
- [ ] Instalar OnlyOffice o similar
- [ ] Configurar auto-cpufreq (opcional)

### Día 3 — Ajustes finos (~15 min)

- [ ] Editar `/etc/sysctl.d/99-swappiness.conf` (vm.swappiness=10)
- [ ] Desactivar servicios no necesarios
- [ ] Probar hibernación/suspensión

---

## Resumen — script post-instalación

Todo lo anterior en un solo script. **Copiar, pegar, ejecutar, reiniciar**.

```bash
#!/bin/bash
set -e

echo "=== PAQUETES BASE ==="
sudo pacman -S --noconfirm power-profiles-daemon earlyoom \
  brightnessctl playerctl pamixer

echo "=== ENCENDER SERVICIOS ==="
sudo systemctl enable --now power-profiles-daemon earlyoom

echo "=== SWAPPINESS ==="
echo 'vm.swappiness=10' | sudo tee /etc/sysctl.d/99-swappiness.conf

echo "=== EARLYOOM ya activo ==="

echo ""
echo "✅ Sistema optimizado."
echo "❓ Si usas Hyprland, ejecuta ahora: nwg-shell-install"
echo "❓ Si usas KDE, abre System Settings → ajusta compositor."
```

---

## Notas finales

| Concepto                  | Respuesta                                                          |
| ------------------------- | ------------------------------------------------------------------ |
| ¿Cuánto tiempo toma TODO? | **~2 horas** incluyendo descarga del ISO                           |
| ¿Cuánto en terminal?      | **~5 comandos**, el resto es GUI o asistentes                      |
| ¿Qué tan bonito queda?    | **Mucho.** Catppuccin Mocha + fondos oscuros + animaciones sutiles |
| ¿Pesa?                    | **~350MB** en idle (Hyprland) / **~550MB** (KDE optimizado)        |
| ¿Batería?                 | **Mejor que Windows** con power-profiles-daemon                    |
| ¿Wifi/BT funcionan?       | **Sí, out of the box** en ambos                                    |

---

_Última actualización: 2026-05-20_
