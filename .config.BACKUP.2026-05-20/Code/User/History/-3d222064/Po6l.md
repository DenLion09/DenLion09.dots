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

### 4.1 Sidebar Dock

```
┌──┬──┐
│▣ │  │  ← Iconos de herramientas
│▣ │  │    (click = abrir)
│▣ │  │
├──┤  │
│⚙ │  │  ← Settings
└──┴──┘
```

- Iconos vertically organizados
- Tooltip on hover
- Badge indicador de notificaciones

### 4.2 Toolbar Superior

```
┌─────────────────────────────────────────┐
│  ≡  │ Proyecto: [nombre]    │ ─ □ ✕  │
└─────────────────────────────────────────┘
    │         │                   │
    Menu    Nombre          Window controls
```

### 4.3 Workspace Area

- Área principal donde se renderizan las herramientas
- Soporte paralayouts: tab, split horizontal, split vertical
- Arrastrar y soltar pestañaspestañas
- Minimizar/maximizar herramientas

### 4.4 Status Bar

```
┌─────────────────────────────────────────┐
│  [●]  │  RAM: 45MB  │  Agent: IDLE  │  │
└─────────────────────────────────────────┘
```

## 5. Acciones del Usuario

| Acción                  | Input                 | Resultado                      |
| :---------------------- | :-------------------- | :----------------------------- |
| **Abrir herramienta**   | Click en dock         | Nueva herramienta en workspace |
| **Cerrar herramienta**  | Click ✕ en tab        | Cierra herramienta             |
| **Cambiar herramienta** | Click en tab          | Cambia herramienta activa      |
| **Cambiar layout**      | Clic derecho → Layout | Cambia disposición             |
| **Minimizar a dock**    | Click en minimize     | Oculta a solo icono en dock    |
| **Settings**            | Click en ⚙            | Abre panel settings            |
| **Busqueda rapida**     | Ctrl+P                | Command palette                |

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

| Escenario           | Comportamiento                          |
| :------------------ | :-------------------------------------- |
| Herramienta crashea | Muestra error en area, opción de reopen |
| Memory alto         | Warning en status bar                   |
| Sin herramientas    | Muestra selector (EMPTY state)          |
| multiple monitores  | Remember posicion por monitor           |

## 8. Thumbnail Visual

```
┌────────────────┬───────────────────────────��────────────┐
│ ≡        │  Proyecto: mi-app              │ ─  □  ✕ │
├─────────┼──────────────────────────────────────────┤
│         ││                                         │
│  [CHAT] ││     WORKSPACE AREA                       │
│  [EDIT] ││     (Chat, Editor, Browser...)          │
│  [WEB]  ││                                         │
│  [TERM] ││                                         │
│         ││                                         │
│  [⚙]    ││                                         │
├─────────┴──────────────────────────────────────────┤
│  [●]  │  RAM: 45MB  │  Agent: IDLE  │  v1.0.0        │
└───────────────────────────────────────────────────────┘
     │          │               │
   Status    Resource       Agent Status
   Indicator  Usage            (del Headless Guardian)
```

## 9. Pendientes

- [ ] Definir lista exacta de herramientas iniciales
- [ ] Definir shortcuts de teclado por defecto
- [ ] Definir configuración de temas (dark/light)
- [ ] Implementar protocolo Context Flush & Reload
- [ ] Integrar Sintetizador Estricto
- [ ] Configurar Sistema de Memoria Atómica
- [ ] Implementar Guardián como Inspector de Diseño

(End of file - total 140 lines)
