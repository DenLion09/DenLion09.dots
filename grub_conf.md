# Configuración de GRUB — `/etc/default/grub`

> Última modificación: 23 de abril de 2026

## Modificaciones respecto a los defaults de Debian/Ubuntu

### 1. `GRUB_TIMEOUT=0` (default: `5`)

Se reduce el timeout a cero segundos para que el sistema arranque inmediatamente sin esperar entrada del usuario. No hay necesidad de elegir entrada del menú en un sistema monousuario.

### 2. `GRUB_TIMEOUT_STYLE=hidden` (default: `menu`)

Oculta completamente el menú de GRUB. Combinado con `GRUB_TIMEOUT=0`, ni siquiera se renderiza — arranque directo y silencioso.

### 3. Colores invisibles

```bash
GRUB_CFG_COLOR_CUSTOM="/boot/grub/colors.cfg"
GRUB_COLOR_NORMAL="black/black"
GRUB_COLOR_HIGHLIGHT="black/black"
```

- `GRUB_COLOR_NORMAL="black/black"` — texto negro sobre fondo negro (invisible)
- `GRUB_COLOR_HIGHLIGHT="black/black"` — selección invisible también

**Propósito**: evitar cualquier texto en pantalla durante el arranque. Si por algún motivo GRUB se muestra (por ejemplo, timeout no-zero por recovery), no se ve nada — pantalla completamente negra.

**Nota**: El archivo `/boot/grub/colors.cfg` referenciado en `GRUB_CFG_COLOR_CUSTOM` **no existe actualmente** en el sistema.

### 4. `GRUB_BACKGROUND="/boot/grub/boot.png"` (default: no hay)

Establece una imagen de fondo personalizada para la pantalla de GRUB. Consistente con la búsqueda de una experiencia visual limpia y personalizada.

**Nota**: El archivo `/boot/grub/boot.png` **no existe actualmente** en el sistema.

### 5. `GRUB_CMDLINE_LINUX_DEFAULT` — parámetros extendidos

**Default Debian/Ubuntu**: `"quiet splash"`

**Valor actual**:
```bash
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash loglevel=0 vt.global_cursor_default=0 systemd.show_status=false rd.systemd.show_status=false"
```

| Parámetro | Propósito |
|-----------|-----------|
| `quiet splash` | Default — pantalla de splash en lugar de logs |
| `loglevel=0` | Suprime completamente los mensajes del kernel (nivel 0 = emergencias solamente) |
| `vt.global_cursor_default=0` | Desactiva el cursor en todas las terminales virtuales durante el arranque |
| `systemd.show_status=false` | Oculta los mensajes de systemd (starting services, OK/FAIL) |
| `rd.systemd.show_status=false` | Lo mismo pero en el initramfs (early boot) |

**Propósito**: Arranque completamente silencioso — ni una línea de texto aparece en pantalla desde que se presiona el botón de encendido hasta que se carga el gestor de sesión. Esto es parte de una optimización estética/de experiencia de usuario en un sistema personal.

### 6. `GRUB_DISABLE_OS_PROBER=false` (default: `true` en instalaciones nuevas)

Habilita `os-prober` para detectar otros sistemas operativos en el disco y agregarlos al menú de GRUB. Esto es necesario si hay un dual-boot.

**Default de Debian/Ubuntu**: `true` (deshabilitado por seguridad, porque os-prober monta particiones para buscar sistemas operativos y puede causar daños en configuraciones con LVM o discos raw).

## Resumen

| Aspecto | Default | Actual | Motivo |
|---------|---------|--------|--------|
| Timeout | 5s | 0s | Arranque inmediato |
| Menú visible | sí | oculto | Sin interacción necesaria |
| Colores | estándar | invisible | Pantalla limpia durante boot |
| Background | ninguno | boot.png | Estética personalizada |
| Verbosidad kernel | quiet splash | quiet + loglevel=0 + sin cursor + sin systemd | Arranque 100% silencioso |
| os-prober | deshabilitado | habilitado | Soporte dual-boot |

## Cómo aplicar cambios

Cada vez que se modifica `/etc/default/grub` (o algún archivo en `/etc/default/grub.d/`), hay que ejecutar:

```bash
sudo update-grub
```

Para que los cambios se reflejen en `/boot/grub/grub.cfg`.
