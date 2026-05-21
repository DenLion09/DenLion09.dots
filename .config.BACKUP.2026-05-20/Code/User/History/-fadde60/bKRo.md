# Spec File Explorer (Popup)

## 1. Propósito

Ventana emergente (popup) independiente para navegación, búsqueda y previsualización de archivos dentro del proyecto activo. Sustituye el concepto tradicional de sidebar permanente para maximizar el área de edición.

## 2. Responsabilidades

- Búsqueda rápida por nombre de archivo (filtro)
- Búsqueda de texto interno (full-text search en el proyecto)
- Vista previa de archivos con resaltado de sintaxis
- Indicación de estado Git (modificado, staged, sin seguimiento)
- Integración con el Editor de Código para apertura de archivos

## 3. Estados UI

| Estado         | Descripción                           |
| :------------- | :------------------------------------ |
| **IDLE**       | Popup cerrado                         |
| **SEARCHING**  | Procesando búsqueda de archivos/texto |
| **PREVIEWING** | Mostrando vista previa de un archivo  |
| **LOADING**    | Cargando contenido de archivo grande  |

## 4. Componentes UI

### 4.1 Popup Principal

```
┌─────────────────────────────────────────────────────────────┐
│                                                         [✕] │
├─────────────────────────────────────────────────────────────┤
│ 📄 src/auth/jwt.go             | PREVIEW: src/auth/jwt.go   🔴 2  🟡 1 │
│ 📄 src/auth/login.go          1│ package auth               │
│ 📄 tests/auth_test.go         2│                            │
│ 📄 src/main.go                3│ import (                   │
│                               4│     "github.com/golang-jwt/jwt/v5" │
│                               5│     "time"                 │
│                               6│ )                          │
│                                |                            │
│                                │                            |
│                                |                            │
│                                |                            │
|                                |                            |
│                                |                            |
└─────────────────────────────────────────────────────────────┘
```

**Elementos:**

- **Search Bar**: Input principal con placeholder dinámico.
- **Results List**: Lista de archivos con iconos y estado Git.
- **Preview Panel**: Vista previa con resaltado de sintaxis y números de línea.

### 4.2 Indicadores Git

| Icono | Significado                    |
| :---- | :----------------------------- |
| 🔴    | Cambios no staged (2 archivos) |
| 🟡    | Warnings / Conflictos          |
| 🔵    | Archivos sin seguimiento       |
| ✅    | Sin cambios / Tracked          |

### 4.3 Integración con Editor

- Al hacer **Enter** o **Click** en un archivo de la lista: Cierra popup y abre el archivo en el Editor de Código.
- Al hacer **Click** en el botón de cierre [✕] o presionar **Escape**: Cierra el popup sin cambios.
- El editor puede enviar un evento `"agent:highlight"` para resaltar archivos específicos en la lista (ej. tras una acción del Coder).

## 5. Acciones del Usuario

| Acción             | Input                  | Resultado                  |
| :----------------- | :--------------------- | :------------------------- |
| **Abrir Popup**    | Ctrl+P / Cmd+P         | Muestra el explorador      |
| **Buscar archivo** | Escribir en search bar | Filtra lista por nombre    |
| **Buscar texto**   | Prefijo o toggle       | Busca texto interno (grep) |
| **Previsualizar**  | Hover sobre archivo    | Muestra preview con syntax |
| **Abrir archivo**  | Enter / Doble click    | Abre en editor principal   |
| **Cerrar**         | Escape / Click [✕]     | Oculta el popup            |

## 6. Keybindings

| Acción               | Windows/Linux | macOS  |
| :------------------- | :------------ | :----- |
| Toggle File Explorer | Ctrl+P        | Cmd+P  |
| Navigate list        | ↑ / ↓         | ↑ / ↓  |
| Open selected file   | Enter         | Enter  |
| Close popup          | Escape        | Escape |

## 7. Integración con Backend (IPC)

Utiliza la misma estructura de mensajes definida en `04-ui-editor-codigo.md` (Sección 7.1).

### 7.1 Eventos Específicos

```json
// Frontend → Rust (Solicitar búsqueda)
{
  "event": "explorer:search",
  "payload": { "query": "jwt", "type": "filename" }
}
{
  "event": "explorer:search",
  "payload": { "query": "GenerateToken", "type": "content" }
}

// Rust → Frontend (Resultados)
{
  "event": "explorer:results",
  "payload": {
    "results": [
      { "path": "src/auth/jwt.go", "matches": 2, "git_status": "modified" }
    ]
  }
}
```

## 8. Casos Edge

| Escenario                        | Comportamiento                        |
| :------------------------------- | :------------------------------------ |
| Proyecto muy grande (>10k files) | Paginar resultados o limitar a 100    |
| Búsqueda de texto pesada         | Mostrar progreso, timeout de 5s       |
| Archivo binario en preview       | Mensaje: "Preview no disponible"      |
| Sin resultados                   | Mensaje: "No se encontraron archivos" |

## 9. Pendientes

- [ ] Definir motor de búsqueda de texto (ripgrep / native)
- [ ] Configurar profundidad de búsqueda por defecto
- [ ] Decidir si el popup debe recordar la última posición/búsqueda
- [ ] Theme inicial (dark, consistente con el editor)
