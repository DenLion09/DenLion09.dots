# Spec Editor de Código

## 1. Propósito

Editor de código fuente integrado con la suite. Visualiza y edita archivos del proyecto activo, con vinculación directa al agente Coder y al Headless Guardian para validación en tiempo real.

## 2. Responsabilidades

- editar archivos del proyecto
- Sintax highlighting (multi-lenguaje)
- Autocomplete/intellisense
- Error highlighting (linter)
- Git integration (diff, blame)
- Split views
- Search & replace
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
│ Line numbers  │  Contenido编辑ableline                     │
│              │  (syntax highlighted)                        │
└─────────────────────────────────────────────────────────────┘
```

- Line numbers
- Syntax highlighting
- Error/warning gutter (rojo/amarillo)
- Active line highlight
- Bracket matching

### 4.3 Sidebar (File Explorer)

```
┌──────��─────────────────────────────────┬─────────────┐
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

| Acción            | Input                 | Resultado             |
| :---------------- | :-------------------- | :-------------------- |
| **Abrir archivo** | Click en explorer     | Abre archivo en tab   |
| **Guardar**       | Ctrl+S                | Guarda archivo        |
| **Cerrar tab**    | Click ✕ en tab        | Cierra archivo        |
| **Buscar**        | Ctrl+F                | Abre search bar       |
| **Reemplazar**    | Ctrl+H                | Abre replace bar      |
| **Ir a línea**    | Ctrl+G                | Ir a línea específica |
| **Terminal**      | Ctrl+`                | Toggle terminal       |
| **Split**         | Click derecho → Split | Divide view           |
| **Format**        | Shift+Alt+F           | Format código         |
| **Rename**        | F2                    | Rename símbolo        |

## 6. Integración con HEADLESS GUARDIAN

### 6.1 Validación en Tiempo Real

```
1. Usuario edita línea
     ↓
2. Debounce 300ms
     ↓
3. Envía a Code Guardian para lint
     ↓
4. Code Guardian retorna errores/warnings
     ↓
5. Mostrar en gutter (línea) + Problems panel
```

### 6.2 Comportamiento de Errores

| Severity    | Visual    | Acción                        |
| :---------- | :-------- | :---------------------------- |
| **Error**   | 🔴 gutter | Block save, tooltip con error |
| **Warning** | 🟡 gutter | Allow save, highlight línea   |
| **Info**    | 🔵 gutter | Highlight, no block           |

## 7. Integración con Backend

### 7.1 IPC Commands

```
// Rust → Frontend
"file:opened"         → Archivo cargado
"file:modified"      → Cambios detectados
"file:saved"         → Guardado exitoso
"lint:results"       → Resultados de lint
"git:status"        → Estado git del archivo
"agent:highlight"   → Resaltar región por agente

// Frontend → Rust
"file:open"          → Abre archivo
"file:save"          → Guarda archivo
"file:close"         → Cierra archivo
"file:lint"         → Solicita lint
"git:diff"          → Obtiene diff
```

### 7.2 Flujo con NTO

```
1. Chat: "cambia el login para usar JWT"
     ↓
2. NTO → Agente Coder
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

## 9. Features por Lenguaje

| Lenguaje       | Features                                                                           |
| :------------- | :--------------------------------------------------------------------------------- |
| **Go**         | Autocomplete, goto definition, find references, signature help, lint (staticcheck) |
| **TypeScript** | Autocomplete, goto definition, find references, rename, refactor                   |
| **Python**     | Autocomplete, goto definition, lint (pylint)                                       |
| **Rust**       | Autocomplete, goto definition, cargo commands                                      |
| **JSON/YAML**  | Schema validation, format                                                          |

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
