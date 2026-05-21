# Spec Editor de Código

## 1. Propósito

Editor de código fuente integrado con la suite. Visualiza y edita archivos del proyecto activo, con vinculación directa al agente Coder y al Headless Guardian para validación en tiempo real.

## 2. Responsabilidades

- Editar archivos del proyecto
- Resaltado de sintaxis (multi-lenguaje)
- Autocompletado / IntelliSense
- Resaltado de errores (linter)
- Integración con Git (diff, blame)
- Vistas divididas (split views)
- Búsqueda y reemplazo
- Terminal integrado (opcional)

## 3. Estados UI

| Estado      | Descripción                    |
| :---------- | :----------------------------- |
| **EMPTY**   | Sin archivo abierto            |
| **LOADING** | Cargando archivo               |
| **READY**   | Archivo cargado y editable     |
| **EDITED**  | Cambios pendientes sin guardar |
| **SAVING**  | Guardando archivo              |
| **ERROR**   | Error de sintaxis/lint         |

## 4. Componentes UI

### 4.1 Tabs Bar

```
┌─────────────────────────────────────────────────────────────┐
│ [✕] src/auth/jwt.go  │  src/main.go [+] │                   │
│        │                    │            │                   │
│  Archivo activo        Archivo        Add new file button             │
│  (con indicator      adicional    (con indicator               │
│   de cambios)         abierto)        de cambios)              │
└─────────────────────────────────────────────────────────────┘
```

### 4.2 Editor Area

```
┌─────────────────────────────────────────────────────────────┐
│ 1│ package auth                                          │
│ 2│                                                      │
│ 3│ import (                                             │
│ 4│     "github.com/golang-jwt/jwt/v5"                    │
│ 5│     "time"                                           │
│ 6│ )                                                    │
│ 7│                                                      │
│ 8│ func GenerateToken(userID string) (string, error) {  │
│ 9│     token := jwt.New(jwt.SigningMethodHS256)            │
│ 10│     claims := token.Claims.(jwt.MapClaims)             │
│ →  claims["user_id"] = userID                        │
│ 12│     claims["exp"] = time.Now().Add(24 * time.Hour)  │
│ 13│     tokenString, err := token.SignedString(secretKey)  │
│ 14│     return tokenString, err                          │
│ 15│ }                                                   │
│ 16│                                                      │
│──────────────────────────────────────────────────────────────
│   │           │                                         │
 │ Line numbers  │  Contenido editable line                    │
 │              │  (syntax highlighted)                        │
└─────────────────────────────────────────────────────────────┘
```

- Line numbers
- Syntax highlighting
- Error/warning gutter (rojo/amarillo)
- Active line highlight
- Bracket matching
- smart autocompled in line

### 4.3 Sidebar (File Explorer)

```
┌────────────────────────────────────────┬─────────────┐
│ EXPLORER                              │  ✕  │
├────────────────────────────────────────┼─────────────┤
│ ▼ src                                 │            │
│     auth/                             │            │
│       jwt.go                     ← Sele│cted       │
│       login.go                           │            │
│       middleware.go                     │            │
│       main.go                             │            │
│ ▼ tests                                │            │
│     auth_test.go                        │            │
├────────────────────────────────────────┴─────────────┤
│  git:main ✚2 ─1                            │
│  (worktree + changes indicator)                │
└─────────────────────────────────────────────────┘
```

### 4.4 Minimap (optional)

```
┌─────────────────────────────────────────────────────────────┐
│ package auth                                          │
│                                                      │
│ import                                                │
│                                                      │
│ func GenerateToken...                             ●──│
│                                                      │
│                                                      │
│                                                      │
│                                            (scroll  │
│                                             preview)│
└─────────────────────────────────────────────────────────────┘
```

### 4.5 Breadcrumb

```
src/auth/jwt.go > GenerateToken
```

## 5. Acciones del Usuario

Ver [Sección 8](#8-keybindings-por-defecto) para atajos de teclado.

| Acción            | Input                 | Resultado             |
| :---------------- | :-------------------- | :-------------------- |
| **Abrir archivo** | Click en explorer     | Abre archivo en tab   |
| **Guardar**       | Ver Keybindings       | Guarda archivo        |
| **Cerrar tab**    | Click ✕ en tab        | Cierra archivo        |
| **Buscar**        | Ver Keybindings       | Abre search bar       |
| **Reemplazar**    | Ver Keybindings       | Abre replace bar      |
| **Ir a línea**    | Ver Keybindings       | Ir a línea específica |
| **Terminal**      | Ver Keybindings       | Toggle terminal       |
| **Split**         | Click derecho → Split | Divide view           |
| **Format**        | Ver Keybindings       | Format código         |
| **Rename**        | Ver Keybindings       | Rename símbolo        |

## 6. Integración con HEADLESS GUARDIAN

### 6.1 Validación en Tiempo Real

```
1. Usuario edita línea
     ↓
2. Debounce configurable (default: 300ms)
     ↓
3. Envía a Code Guardian para lint
     ↓
4. Code Guardian retorna errores/warnings
     ↓
5. Mostrar en gutter (línea) + Problems panel
```

### 6.2 Comportamiento de Errores

| Severity    | Visual    | Acción                                 |
| :---------- | :-------- | :------------------------------------- |
| **Error**   | 🔴 gutter | Advertencia en save, tooltip con error |
| **Warning** | 🟡 gutter | Allow save, highlight línea            |
| **Info**    | 🔵 gutter | Highlight, no block                    |

## 7. Integración con Backend

### 7.1 IPC Commands

Todos los mensajes IPC siguen la estructura: `{ "event": "nombre", "payload": { ... } }`.

```json
// Rust → Frontend
{
  "event": "file:opened",
  "payload": { "path": "src/auth/jwt.go", "content": "...", "language": "go" }
}
{
  "event": "file:modified",
  "payload": { "path": "src/auth/jwt.go", "modified": true }
}
{
  "event": "file:saved",
  "payload": { "path": "src/auth/jwt.go", "success": true }
}
{
  "event": "lint:results",
  "payload": { "path": "src/auth/jwt.go", "diagnostics": [{ "line": 10, "col": 5, "severity": "error", "message": "..." }] }
}
{
  "event": "git:status",
  "payload": { "path": "src/auth/jwt.go", "status": "modified", "staged": false }
}
{
  "event": "agent:highlight",
  "payload": { "path": "src/auth/jwt.go", "range": { "start": 10, "end": 15 }, "color": "blue" }
}

// Frontend → Rust
{
  "event": "file:open",
  "payload": { "path": "src/auth/jwt.go" }
}
{
  "event": "file:save",
  "payload": { "path": "src/auth/jwt.go", "content": "..." }
}
{
  "event": "file:close",
  "payload": { "path": "src/auth/jwt.go" }
}
{
  "event": "file:lint",
  "payload": { "path": "src/auth/jwt.go", "content": "..." }
}
{
  "event": "git:diff",
  "payload": { "path": "src/auth/jwt.go" }
}
```

### 7.2 Flujo con NTO (Natural Task Orchestrator)

```
1. Chat: "cambia el login para usar JWT"
     ↓
2. NTO (Natural Task Orchestrator) → Agente Coder
     ↓
3. Coder determina archivos a modificar
     ↓
4. Editor recibe: "agent:highlight" para archivos
     ↓
5. Editor marca archivos en explorer
     ↓
6. Usuario/Agente hace cambios
     ↓
7. Code Guardian valida automáticamente
     ↓
8. Si pasa → Prompt para commit
```

## 8. Keybindings por Defecto

| Acción         | Windows/Linux | macOS       |
| :------------- | :------------ | :---------- |
| Save           | Ctrl+S        | Cmd+S       |
| Find           | Ctrl+F        | Cmd+F       |
| Replace        | Ctrl+H        | Cmd+Opt+F   |
| Go to line     | Ctrl+G        | Cmd+G       |
| Multi-cursor   | Alt+Click     | Opt+Click   |
| Toggle comment | Ctrl+/        | Cmd+/       |
| Format         | Shift+Alt+F   | Shift+Opt+F |
| Open terminal  | Ctrl+`        | Cmd+`       |

## 9. Soporte Multi-lenguaje (Enfoque Generalista)

El editor no tiene preferencia por lenguaje específico. Utiliza el **Protocolo de Servidor de Lenguaje (LSP)** para proveer funcionalidades avanzadas a cualquier tecnología con soporte LSP.

### 9.1 Configuración LSP

- Detección automática de lenguaje por extensión/tipo de archivo.
- Soporte para múltiples servidores LSP simultáneos (vía configuración del proyecto).
- Configuración vía archivos estándar (`./lsp-config.json` o settings del proyecto).

### 9.2 Features Estándar (vía LSP)

- **Autocompletado** (IntelliSense)
- **Go to Definition / References**
- **Hover Documentation**
- **Signature Help**
- **Diagnósticos** (Errors, Warnings, Info vía LSP y linters externos)
- **Rename / Refactor**
- **Code Actions** (Quick fixes)
- **Format Document**

### 9.3 Linters y Formateadores

- Configurables por proyecto (archivos `.linters.json` o equivalente).
- Soporte para linters externos independientes del LSP.
- El usuario define qué herramientas usar y sus reglas.

## 10. Casos Edge

| Escenario                  | Comportamiento                  |
| :------------------------- | :------------------------------ |
| Archivo muy grande (>10MB) | Warning, abrir en modo readonly |
| Encoding no soportado      | Offer convertir                 |
| Archivo binario            | Abrir como hex view             |
| Conflict merge             | Mostrar diff interactivo        |
| Archivo eliminado          | Close tab + notification        |

## 11. Thumbnail Visual

```
┌─────────────────────────────────────────────────────────────┐
│ [EDIT] │ src/auth/jwt.go  │  src/main.go             │  [+] │
├───────────────┬─────────────────────────────────────────────┤
│ EXPLORER     │  1│ package auth                             │
│              │  2│                                          │
│ ▼ src        │  3│ import (                                 │
│   auth/    ● │  4│     "github.com/golang-jwt/jwt/v5"       │
│     jwt.go   │  5│     "time"                               │
│     login.go │  6│ )                                        │
│     main.go  │  7│                                          │
│ ▼ tests      │  8│ func GenerateToken(userID string) (string,│
│   auth_test  │  9│     token := jwt.New(jwt.SigningMethodHS2│
│              │ 10│     claims := token.Claims.(jwt.MapClaim│
│              │ ←    ←── cursor                              │
├──────────────┴───┴────────────────────────────────────────────┤
│ Ln 11, Col 4 │ UTF-8 │ Go │ git:main ✚2                     │
└─────────────────────────────────────────────────────────────
```

## 12. Pendientes

- [ ] Seleccionar librería de editor (CodeMirror 6 / Monaco / Ace)
- [ ] Configurar lenguajes soportados inicialmente
- [ ] Definir linters por lenguaje
- [ ] Configurar formatter por defecto
- [ ] Definir theme inicial (dark)

## Actualización para Nuevos Requisitos

### Estructura de Archivos SDD

- SPECS.md: El "Qué" - Requisitos funcionales
- PROPOSE.md: El "Cómo" - Implementación propuesta
- DESIGN.md: El "Por qué" visual - Decisiones de diseño
- STRACT.md: El "Estado" actual - Evolución funcional

### Protocolos Obligatorios

- Context Flush & Reload después de cada tarea
- Guardián Inspector de Diseño para validación estética
- Sistema de Memoria Atómica con DB Relacional de Micro-Skills
- Perfil Único (Main) con inyección de micro-skills
