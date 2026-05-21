# Guía de Optimización — Distro-agnóstica

> **Hardware de referencia**: Celeron N4500 · 8GB RAM · 1080p
> **Objetivo**: Máximo rendimiento, mínima fricción, configuración fácil o automática.

---

## Índice

1. [Elegir el camino](#1-elegir-el-camino)
2. [Instalación rápida](#2-instalación-rápida)
3. [Entorno de escritorio](#3-entorno-de-escritorio)
4. [Laptop features](#4-laptop-features)
5. [Rendimiento máximo](#5-rendimiento-máximo)
6. [Hermoso sin esfuerzo](#6-hermoso-sin-esfuerzo)
7. [Apps mínimas y funcionales](#7-apps-mínimas-y-funcionales)
8. [Checklist post-instalación](#8-checklist-post-instalación)

---

## 1. Elegir el camino

| Si quieres...                                                                              | Elige                    |
| ------------------------------------------------------------------------------------------ | ------------------------ |
| Máxima velocidad + estética moderna (con GUI, sin terminal, +119 plugins)                  | **Hyprland + Noctalia**  |
| Máxima velocidad + estética moderna (alternativa estable, más comunidad)                   | **Hyprland + nwg-shell** |
| Máxima velocidad + estética moderna (tú controlas todo)                                    | **Hyprland vanilla**     |
| Instalar y usar en cualquier dispositivo, con GUI, sin tocar terminal para configuraciones | **Gnome**                |

### Rolling vs Fixed — el criterio real

| Criterio                    | Rolling               | Fixed             |
| --------------------------- | --------------------- | ----------------- |
| Tolerancia a breakages      | Alta                  | Baja              |
| Frecuencia de reinstall     | Cada 1-2 años         | Cada 2-3 años     |
| Gusto por actualizar        | Disfruto estar al día | Prefiero no tocar |
| Uso profesional/servidor    | ❌ NO                 | ✅ SÍ             |
| Hardware moderno (1-2 años) | ✅ Sí (kernel nuevo)  | Puede servir      |
| Hardware básico (4+ años)   | ✅ Va bien            | ✅ Va bien        |

**Regla simple**: Si te molesta actualizar, usa fixed. Si te gusta estar al día y sabes resolver problemas, rolling es para ti.

---

## 2. Instalación rápida

Independientemente de la distro, el proceso general es:

1. Descargar el ISO desde el sitio oficial de la distro
2. Bootear desde USB (usar `dd`, Balena Etcher, o Ventoy para crear el USB)
3. Seguir el instalador gráfico
4. Elegir el entorno de escritorio o ventanas (Hyprland, KDE, etc.)
5. Particionado: si hay duda, usar particionado automático guiado
6. Configurar usuario y contraseña
7. Al reiniciar, el asistente post-instalación de la distro (si existe) guía drivers, AUR/OBS, snapshots, etc.

**Tiempo estimado**: ~20-30 minutos según la distro y velocidad de descarga.

---

## 3. Entorno de escritorio

### Hyprland + Shell (GUI sin terminal)

Dos opciones de shell con GUI para Hyprland:

| Shell         | Plugins | Compositors                | Comunidad | Estado               |
| ------------- | ------- | -------------------------- | --------- | -------------------- |
| **Noctalia**  | 119+    | Hyprland, Sway, Niri, etc. | Activa    | En desarrollo activo |
| **nwg-shell** | menos   | Mainly Hyprland            | Estable   | Estable              |

#### Opción 1: Noctalia (recomendada)

- **Web**: [noctalia.dev](https://noctalia.dev)
- Se instala desde el gestor de paquetes de la distro, AUR, OBS, o desde GitHub
- Al ejecutarlo se configura solo — 119+ plugins disponibles
- Múltiples compositors: Hyprland, Sway, Niri, MangoWC, etc.
- Paletas de temas integradas, diseño minimalista "quiet by design"

Plugins populares:

- Listar plugins disponibles
- Instalar plugins individuales por nombre

#### Opción 2: nwg-shell (alternativa estable)

- RAM idle: ~350MB
- Setup: 90% con GUI
- Se instala desde el gestor de paquetes de la distro
- Incluye: panel configurable, app launcher con íconos, tiling automático, atajos pre-configurados

**Lo que configuras con clicks (no terminal)**:

| Acción      | Descripción                       |
| ----------- | --------------------------------- |
| `Super + M` | Menú nwg-shell                    |
| `nwg-look`  | Tema GTK, íconos, cursores (GUI)  |
| `nwg-bar`   | Botón de apagado/suspender/reboot |
| `nwg-menu`  | Lanzador de apps                  |

**Archivos de configuración** (opcionales, no necesarios si usas la shell):

- `~/.config/hypr/hyprland.conf` — monitores, atajos, ventanas
- `~/.config/waybar/config.jsonc` — barra de estado
- `~/.config/waybar/style.css` — estilos de la barra

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

- RAM idle: ~550MB (con ajustes)
- Setup: 100% GUI desde System Settings

**Ajustes para rendimiento** (System Settings → buscar con la lupa):

| Ajuste                  | Dónde                        | Valor                            |
| ----------------------- | ---------------------------- | -------------------------------- |
| Compositor → Renderizer | Display → Compositor         | `XRender`                        |
| Animaciones             | Workspace Behavior → Effects | Desactivar sombras/transparencia |
| Baloo (búsqueda)        | Search → File Search         | DESACTIVAR                       |
| Sesión                  | Startup & Shutdown           | `Empty session`                  |
| Power Management        | Hardware → Power Management  | `Power Save` en batería          |

**Apps innecesarias**: KDE instala muchas por defecto. Revisar y remover juegos, apps de oficina, y herramientas que no se usen. Dejar solo el grupo core: panel, terminal, gestor de archivos, ajustes.

---

## 4. Laptop features

### Power Management

Dos opciones para gestión de energía:

1. **power-profiles-daemon** — Detectar y cambiar entre perfiles (powersave / balanced / performance). La mayoría de entornos lo detectan automáticamente.
2. **auto-cpufreq** — Alternativa más agresiva. Detecta batería vs AC y ajusta frecuencias de CPU automáticamente. No requiere intervención tras instalarlo como servicio.

**Recomendación**: Usar **power-profiles-daemon** e instalar **auto-cpufreq** solo como respaldo.

### Hibernación / Suspensión

- Crear un archivo de intercambio (swap) del mismo tamaño que la RAM. En este hardware, 8GB.
- Activar el swap al arranque del sistema.
- El instalador de la mayoría de distros pregunta el tamaño de swap durante la instalación — elegir 8GB o "Suspend to disk".

### WiFi

- Normalmente funciona out of the box al instalar.
- Si hay problemas, usar `nmtui` (interfaz TUI de NetworkManager — fácil, con menús).
- NetworkManager viene activado por defecto en casi todas las distros.

### Bluetooth

- Instalar bluez, bluez-utils, y un gestor como Blueman.
- Activar el servicio Bluetooth para que arranque automáticamente.
- Blueman tiene applet de bandeja que se auto-integra en Hyprland y KDE.

### Brillo y teclas de función

- `brightnessctl` es la herramienta universal para control de brillo.
- En la mayoría de laptops, las teclas de brillo (Fn) funcionan out of the box.
- Si no, se mapean en la configuración del compositor (Hyprland) o en System Settings (KDE).

### Suspender al cerrar tapa

- Configurar en `/etc/systemd/logind.conf`: `HandleLidSwitch=suspend`.
- En KDE: System Settings → Power Management → Energy Saving → "When laptop lid closed".

---

## 5. Rendimiento máximo

### Plan conceptual (5 pasos, sin comandos)

#### 1. Parámetros de arranque del kernel

Para reducir latencia en un sistema personal:

- **Desactivar mitigaciones de CPU**: En un equipo personal con hardware básico, las mitigaciones de seguridad de CPU (Spectre, Meltdown) consumen ciclos que no tenemos de sobra. Se pueden desactivar sin riesgo real en un entorno doméstico.
- **Desactivar watchdog**: Libera un núcleo de CPU que watchdog usa constantemente. En un Celeron de 2 núcleos, cada ciclo cuenta.

Estos parámetros se configuran en el gestor de arranque (GRUB, systemd-boot, etc.) antes de que el kernel arranque.

#### 2. Swappiness baja

Por defecto, el sistema tiende a usar swap incluso cuando hay RAM disponible. Reducir el valor de swappiness hace que el sistema use swap SOLO cuando sea realmente necesario (memoria cerca del límite).

#### 3. Servicios innecesarios

En un equipo de escritorio personal, estos servicios normalmente pueden desactivarse si no se usan:

- Bluetooth — si no se usa
- CUPS (impresión) — si no hay impresora
- systemd-resolved — si se usa NetworkManager (el gestor de red ya maneja DNS)

#### 4. earlyoom

**Esto es lo más importante para este hardware**. Con 8GB de RAM, si una aplicación se vuelve loca y consume toda la memoria, el sistema se congelaría por minutos. earlyoom detecta falta de RAM y mata el proceso culpable al instante. Esencial para sistemas con poca memoria.

#### 5. I/O scheduler para SSD

Los SSD no necesitan los planificadores de I/O tradicionales (diseñados para discos giratorios). Para NVMe, el scheduler más eficiente es `none`. Para SATA SSD, `mq-deadline`. Esta configuración se aplica a través de reglas de udev que detectan el tipo de disco al arrancar.

---

## 6. Hermoso sin esfuerzo

### Hyprland — belleza rápida

- **Tema**: Catppuccin Mocha (GTK) — el más popular, out of the box.
- **Aplicar**: Usar `nwg-look` (GUI) para seleccionar el tema GTK.
- **Wallpaper**: Usar `hyprpaper` para gestionar fondos de pantalla.
- **Dónde encontrar**: [hyprwall.me](https://hyprwall.me) o buscar "hyprland wallpaper".
- **Recomendación**: Fondos oscuros (Catppuccin, Nord) — se ven modernos y en pantalla LCD gastan menos batería.

### KDE — belleza rápida (todo GUI)

Desde System Settings → Appearance:

- **Global Theme**: Breeze (viene instalado) o instalar Catppuccin KDE desde "Get New Global Theme".
- **Iconos**: Tela Circle.
- **Cursor**: Bibata Modern.
- **Dock**: Hacer el panel flotante (click derecho → Edit Mode → flotante).

En 5 minutos se ve: tema oscuro, iconos redondeados modernos, panel flotante transparente.

---

## 7. Apps mínimas y funcionales

| Categoría | App                                      | Por qué                                                                  |
| --------- | ---------------------------------------- | ------------------------------------------------------------------------ |
| Terminal  | **Kitty** o **Foot**                     | Foot es Wayland nativo, super ligero (~15MB RAM). Kitty es más completo. |
| Navegador | **Firefox** o **Brave**                  | Firefox con Wayland nativo. Brave es más rápido en el mismo hardware.    |
| Archivos  | **Thunar** (WM) o **Dolphin** (KDE)      | Thunar: 20MB, rápido. Dolphin: integración KDE.                          |
| Captura   | **Grim + Slurp**                         | Captura de pantalla en Wayland. Sin interfaz que consuma.                |
| Editor    | **Geany** o **Kate**                     | Geany 25MB, Kate ~80MB. Alternativas ligeras a VS Code (400MB+).         |
| Notas     | **Notion web** o **Obsidian**            | Corre en Chromium, 200-300MB, pero productivos.                          |
| Música    | **Spotify** (Flatpak) o **ncspot** (TUI) | Spotify ~200MB, ncspot ~15MB.                                            |
| Video     | **mpv**                                  | Reproductor más ligero, acelera GPU automáticamente.                     |

### Estrategia de instalación (distro-agnóstica)

La estrategia completa está en `stack.md`. En resumen:

| Tipo               | Método                                | Razón                                                    |
| ------------------ | ------------------------------------- | -------------------------------------------------------- |
| GUI                | **Flatpak** (Flathub)                 | Aislado, actualizado, mismo método en cualquier distro   |
| CLI                | **Homebrew**                          | Misma experiencia en Linux y macOS                       |
| Servicio           | **Podman**                            | Sin Docker daemon, rootless, OCI-compatible              |
| Driver/lib sistema | **Gestor nativo** (zypper, apt, etc.) | Lo que toca el kernel debe ir por el gestor de la distro |

### Apps que NO instalar (peso innecesario)

| ❌ App      | Alternativa                                              |
| ----------- | -------------------------------------------------------- |
| LibreOffice | OnlyOffice (más ligero, compatible MS) o Google Docs web |
| GIMP        | Pinta o Krita (solo si editas fotos)                     |
| Thunderbird | Mail web (Gmail/Outlook/Proton) en Firefox               |
| VirtualBox  | Quickemu (más ligero, sin módulos kernel)                |

---

## 8. Checklist post-instalación

### Día 1 — Base funcional (~1 hora)

- [ ] Instalar SO
- [ ] Conectar WiFi
- [ ] Ejecutar asistente post-instalación (si la distro lo tiene)
- [ ] Actualizar todo el sistema
- [ ] Instalar power-profiles-daemon y earlyoom
- [ ] Activar ambos como servicios
- [ ] Instalar/configurar Hyprland o KDE (ver sección 3)
- [ ] Configurar swap/hibernación
- [ ] Instalar Bluetooth (solo si se usa)
- [ ] Instalar nwg-shell (Hyprland) o ajustar KDE

### Día 2 — Belleza + apps (~30 min)

- [ ] Aplicar tema Catppuccin (Hyprland) o KDE global theme
- [ ] Poner wallpaper
- [ ] Instalar navegador + extensiones
- [ ] Instalar OnlyOffice o similar
- [ ] Configurar auto-cpufreq (opcional)

### Día 3 — Ajustes finos (~15 min)

- [ ] Reducir swappiness
- [ ] Desactivar servicios no necesarios
- [ ] Probar hibernación/suspensión

---

## Resumen

| Concepto                  | Respuesta                                                          |
| ------------------------- | ------------------------------------------------------------------ |
| ¿Cuánto tiempo toma TODO? | **~2 horas** incluyendo descarga del ISO                           |
| ¿Qué tan bonito queda?    | **Mucho.** Catppuccin Mocha + fondos oscuros + animaciones sutiles |
| RAM en idle               | **~350MB** (Hyprland) / **~550MB** (KDE optimizado)                |
| Batería                   | **Mejor que Windows** con power-profiles-daemon                    |
| ¿Wifi/BT funcionan?       | **Sí, out of the box**                                             |

---

_Última actualización: 2026-05-20_ — Distro-agnóstica. Sin comandos: solo conceptos y qué hacer.
