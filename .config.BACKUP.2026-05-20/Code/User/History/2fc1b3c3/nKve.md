# Spec Chat IA

## 1. Propósito

Interfaz de conversación con el agente IA principal. El usuario interactúa en lenguaje natural; el chat actúa como puerta de entrada al pipeline NTO (Orquestador) y al Headless Guardian.

## 2. Responsabilidades

- Recibir input del usuario en lenguaje natural
- Mostrar output del agente en lenguaje natural
- Mostrar estado del agente (thinking, working, idle)
- Adjuntar archivos/drag & drop
- Historial de conversación (temporal, se flushea después de cada tarea)
- Context preview (qué archivos están activos)

## 3. Estados UI

| Estado         | Descripción                   |
| :------------- | :---------------------------- |
| **IDLE**       | Esperando input               |
| **TYPING**     | Usuario escribiendo           |
| **THINKING**   | Agente procesando (streaming) |
| **WORKING**    | Ejecutando acciones           |
| **RESPONDING** | Generando respuesta           |
| **ERROR**      | Error en el agente            |

## 4. Componentes UI

### 4.1 Header

```
┌─────────────────────────────────────────────────────────────┐
│ [CHAT] │  Main (Orquestador)              │ ⚙ │ ─ │ □ │ ✕ │
└─────────────────────────────────────────────────────────────┘
   Icon     Título del agente          Window controls
```

### 4.2 Area de Mensajes

```
┌─────────────────────────────────────────────────────────────┐
│  ┌─────────────────────────────────────────────────────────┐│
│  │ 🗨️ Hola, ¿qué quieres construir hoy?                  ││
│  └─────────────────────────────────────────────────────────┘│
│                                                           │
│    ┌─────────────────────────────────────────────────────┐  │
│    │ Crea un endpoint de login con JWT                  │  │
│    │                                                usuario │  │
│    └─────────────────────────────────────────────────────┘  │
│                                                           │
│  ┌─────────────────────────────────────────────────────────┐│
│  │ 🧠 Pensando...                                        ││
│  └─────────────────────────────────────────────────────────┘│
│                                                           │
│  ┌─────────────────────────────────────────────────────────┐│
│  │ 📝 Generando código...                                 ││
│  └───────────────────────────────────────────────────────���─┘│
│                                                           │
│  ┌─────┓ ┌───────────────────────────────────────────┐  │
│  │ 🗨️ │ │ He creado los siguientes archivos:        ││
│  └─────┘ │ • auth/login.go                                        │
│          │ • auth/middleware.go                                   │
│          │ • auth/jwt.go                                          │
│          │                                                      │
│          │ ¿Quieres que continúe con los tests?                 │
│  └─────────────────────────────────────────────────────────┘
└─────────────────────────────────────────────────────────────┘
```

- Mensajes con avatars (usuário vs agente)
- Timestamp en cada mensaje
- Código syntax highlighted
- Soporte markdown (listas, bold, links)
- Acciones sugeridas como botones

### 4.3 Input Area

```
┌─────────────────────────────────────────────────────────────┐
│ 📎 │ Escribe tu mensaje...                    │ ⏎  │ 🎤 │
│     │   (textarea auto-expand)            │Send│ Mic │
│     │                                    │    │     │
└─────────────────────────────────────────────────────────────┘
  Attach  Input                    Send   Voice input
```

### 4.4 Context Sidebar (collapsible)

```
┌──────────────────┬────────────────────────────────────────┐
│ CHAT        │  📁 src/                 │   Activos         │
│            │    ├── auth/              │                   │
│            │    │  ├── login.go        │   auth/jwt.go     │
│            │    │  ├── middleware.go   │   auth/login.go    │
│            │    │  └── jwt.go         │                   │
│            │    └── main.go            │                   │
│            │                         │   Worktree: dev      │
│            │                         │   Agente: Coder     │
└──────────────────┴────────────────────────────────────────┘
```

### 4.5 Status Bar

```
┌─────────────────────────────────────────────────────────────┐
│ [●] │  Main: THINKING  │  Grafo: 3 nodos  │  Flush: LISTO  │
└─────────────────────────────────────────────────────────────┘
```

## 5. Acciones del Usuario

| Acción             | Input             | Resultado         |
| :----------------- | :---------------- | :---------------- |
| **Enviar mensaje** | Enter o click ⏎   | Envia a NTO       |
| **Multiline**      | Shift+Enter       | Nueva línea       |
| **Adjuntar**       | Click 📎          | File picker       |
| **Drag & drop**    | Arrastrar archivo | Adjunta archivo   |
| **Voice**          | Click 🎤          | Graba audio       |
| **Limpiar**        | Click ⋮ → Clear   | Limpia + Flush    |
| **Exportar**       | Click ⋮ → Export  | Exporta Markdown  |
| **Copy code**      | Click en código   | Copy al clipboard |

## 6. Tipos de Mensaje

| Tipo        | Visual                                    |
| :---------- | :---------------------------------------- |
| **texto**   | Texto plano con markdown                  |
| **codigo**  | Bloque con syntax highlight + copy button |
| **archivo** | Link al archivo + preview                 |
| **error**   | Error en rojo con details                 |
| **system**  | Mensaje del sistema en gris               |
| **accion**  | Botón de acción (sugerencia)              |

## 7. Integración con Backend

### 7.1 Perfil Único (Main)

Main opera bajo el modelo de Perfil Único:

- No mantiene historial de chat largo
- Carga información de STRACT.md y grafo de tareas
- Delega a subagentes con micro-skills específicas
- Realiza Context Flush después de cada tarea validada

### 7.2 IPC Commands

```
// Rust → Frontend
"chat:message"      → Nuevo mensaje del agente
"chat:status"       → Cambio de estado (thinking, working, etc.)
"chat:action"      → Acción sugerida
"chat:context"      → Archivos actualmente en contexto
"agent:progress"    → Progreso de tarea
"main:flush"       → Indica que se hizo flush

// Frontend → Rust
"chat:send"         → Envia mensaje del usuario
"chat:cancel"       → Cancela operación actual
"chat:action:click"→ Usuario clickea acción sugerida
"context:add"      → Agrega archivo al contexto
"context:remove"   → Remueve archivo del contexto
"context:flush"    → Solicita flush de KV Cache
```

### 7.3 Flujo Completo

```
1. Usuario envía mensaje
     ↓
2. Frontend → Main: "chat:send"
     ↓
3. Main → Input Guard (validación)
     ↓
4. Input Guard → Main: validado
     ↓
5. Main analiza grafo de tareas
     ↓
6. Main → Subagente(s) con micro-skills
     ↓
7. Subagente ejecuta tarea
     ↓
8. Code Guardian valida código
     ↓
9. Design Inspector valida estética
     ↓
10. Output Guard filtra información
     ↓
11. Main → Usuario: respuesta
     ↓
12. Context Flush: Borra KV Cache
     ↓
13. Reload: Carga STRACT.md + grafo
     ↓
14. Listo para siguiente tarea
```

## 8. Integración con Headless Guardian

| stage                 | Input del HG                            |
| :-------------------- | :-------------------------------------- |
| **Input Validation**  | HG valida mensaje antes de enviar a NTO |
| **Output Validation** | HG valida respuesta antes de mostrar    |
| **Security**          | HG filtra información sensible          |
| **Loop Detection**    | HG detecta ciclos, muestra warning      |
| **Design Validation** | HG verifica código anti-fatiga          |
| **Stack Validation**  | HG verifica stack MERN + FlyonUI        |

## 9. Casos Edge

| Escenario          | Comportamiento                     |
| :----------------- | :--------------------------------- |
| Input muy largo    | Truncar + warning, o chunking      |
| Request muy grande | Mostrar "request too large"        |
| Timeout            | Mostrar error + opción de retry    |
| Rate limit         | Queue + notificar al usuario       |
| Offline            | Cachear mensajes, enviar después   |
| Flush fallido      | Reintentar con backoff exponencial |

## 10. Thumbnail Visual

```
┌─────────────────────────────────────────────────────────────┐
│ [CHAT] │  Main (Orquestador)           │ ⚙ │ ─ │ □ │ ✕ │
├─────────────────────────────────────────────────────────────┤
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ 🗨️ Hola, soy tu asistente de código.                │ │
│ │   Puedo ayudarte a crear features, debuggear,       │ │
│ │   o explicarte código existente.                   │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                           │
│    ┌─────────────────────────────────────────────────────┐ │
│    │ Crea un login con JWT                              │ │
│    └─────────────────────────────────────────────────────┘ │
│                                                           │
│  ┌─────────────────────────────────────────────────────────┐│
│  │ 🧠 Analizando...  →  📝 Implementando...  →  ✅ Listo ││
│  └─────────────────────────────────────────────────────────┘ │
│                                                           │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ 📝 He creado:                                        │   │
│  │ ⬡ auth/jwt.go                                        │   │
│  │ ⬡ auth/middleware.go                                 │   │
│  └─────────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────────┤
│ 📎 │ Escribe tu mensaje...                    │ ⏎  │ 🎤 │
├─────────────────────────────────────────────────────────────┤
│ [●] │  Main: IDLE  │  Grafo: 5 nodos  │  Flush: LISTO  │
└─────────────────────────────────────────────────────────────┘
```

## 11. Pendientes

- [ ] Definir modelo LLM a usar (GGUF con mmap)
- [ ] Configurar system prompt por defecto
- [ ] Definir límites de contexto (tokens)
- [ ] Configurar streaming vs batch
- [ ] Definir acciones sugeridas por defecto
- [ ] Implementar protocolos Context Flush & Reload
- [ ] Configurar Sistema de Memoria Atómica
- [ ] Configurar Perfil Único con inyección de micro-skills
- [ ] Implementar Auditría de Git Log

## 12. Requisitos de Actualización

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
- Auditoría de Git Log para reconstrucción lógica
