# Spec UI Contenedor

## 1. Propósito

gui principal de la suite. Funciona como dock/launcher que carga y visualiza todas las herramientas dentro de sí misma.

## 2. Responsabilidades

- Gestionar el estadoglobal de la aplicación
- Lanzar y cerrar herramientas
- Navegación entre herramientas(abiertas
- Gestión de workspaces/proyectos
- Minimal resource footprint

## 3. Estados UI

| Estado          | Descripción                           | Default                            |
| :-------------- | :------------------------------------ | :--------------------------------- |
| **EMPTY**       | Ninguna herramienta abierta           | mostrar proyectos anteriores/nuevo |
| **TOOL_SELECT** | Selector de herramientasvisible       | popup para seleccionar herramienta |
| **ACTIVE**      | Una o más herramientas abiertas       | focus en la herramienta abierta    |
| **FULLSCREEN**  | Herramienta en modo pantalla completa |                                    |

## 4. Componentes UI

### 4.1 Toolbar Superior (Barra Principal)

```
┌─────────────────────────────────────────────────────────┐
│  ≡  │  Proyecto: [nombre]    [▣] [▣] [▣] [▣]  │ ─ □ ✕ │
└─────────────────────────────────────────────────────────┘
     │     │                              │              │
   Menu  Project name                  Tool Icons   Window ctrls
                                         (click = abrir)
```

- Iconos horizontalmente organizados en la barra superior, alineados a la derecha
- Tooltip on hover con nombre de herramienta
- Badge indicador de notificaciones sobre el icono
- Icono activo resaltado (herramienta con focus)
- Click en herramienta ya abierta = traer al frente
- Click derecho en icono = contexto (cerrar, minimizar, etc.)

### 4.2 Workspace Area

- Área principal donde se renderizan las herramientas
- Soporte para layouts: tab, split horizontal, split vertical
- Minimizar/maximizar herramientas dentro del workspace
- Navegación entre herramientas abiertas vía menú contextual o atajos

### 4.3 Settings Panel

- Accessible desde el menu ≡ (hamburguesa) o shortcut
- Se abre como panel lateral derecho o modal overlay
- No ocupa espacio permanente en la UI

## 5. Acciones del Usuario

| Acción                  | Input                            | Resultado                      |
| :---------------------- | :------------------------------- | :----------------------------- |
| **Abrir herramienta**   | Click en icono toolbar           | Nueva herramienta en workspace |
| **Cerrar herramienta**  | Click ✕ en header de herramienta | Cierra herramienta             |
| **Cambiar herramienta** | Click en icono toolbar           | Enfoca herramienta             |
| **Cambiar layout**      | Clic derecho en icono → Layout   | Cambia disposición             |
| **Minimizar**           | Click en minimize header         | Minimiza herramienta           |
| **Settings**            | Menu ≡ → Settings                | Abre panel settings            |
| **Busqueda rapida**     | Ctrl+P                           | Command palette                |

## 6. Integración con Backend

### 6.1 IPC Commands

```
// Rust → Frontend
"tool:opened"      → Notifica que herramienta se abrió
"tool:closed"      → Notifica que herramienta se cerró
"tool:state"       → Estado actual de herramienta
"worktree:switch"  → Cambio de worktree activo
"agent:status"     → Estado de agentes

// Frontend → Rust
"tool:open"        → Abre herramienta
"tool:close"       → Cierra herramienta
"tool:focus"       → Enfoca herramienta
"worktree:create" → Crea nuevo worktree
"worktree:commit"  → Commitea cambios
```

### 6.2 Casos Edge

| Escenario           | Comportamiento                           |
| :------------------ | :--------------------------------------- |
| Herramienta crashea | Muestra error en area, opción de reopen  |
| Memory alto         | Indicador visual en icono de herramienta |
| Sin herramientas    | Muestra selector (EMPTY state)           |
| multiple monitores  | Remember posicion por monitor            |

## 8. Thumbnail Visual

_Inactivo_

```
┌────────────────────────────────────────────────────────────┐
│  ≡      │  Proyecto: mi-app    [▣] [▣] [▣] [▣]  │ ─  □  ✕  │  ← Toolbar
├────────────────────────────────────────────────────────────┤
│                                                            │
│                                                            │
│              WORKSPACE AREA                                │
│      (Chat, Editor, Browser en layout activo)              │
│                                                            │
│                                                            │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

_Activo_

```
┌────────────────────────────────────────────────────────────┐
│  ≡      │  Proyecto: mi-app    [▣] [▣] [▣] [▣]  │ ─  □  ✕  │  ← Toolbar
├────────────────────────────────────────────────────────────┤
│                                                            │
│                                                            │
│              WORKSPACE AREA                                │
│      (Chat, Editor, Browser en layout activo)              │
│                                                            │
│                                                            │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

## 9. Pendientes

- [ ] Definir lista exacta de herramientas iniciales
- [ ] Definir shortcuts de teclado por defecto
- [ ] Definir configuración de temas (dark/light)
- [ ] Implementar protocolo Context Flush & Reload
- [ ] Configurar Sistema de Memoria Atómica
- [ ] Implementar Guardián como Inspector de Diseño
