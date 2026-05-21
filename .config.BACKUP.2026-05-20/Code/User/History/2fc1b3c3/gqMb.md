# Spec Chat IA

## 1. Propósito

Interfaz de conversación en vivo con el agente IA principal (Main). El Main opera como un **subproceso headless** sin interfaz propia; el chat es su ventana de comunicación con el usuario. El usuario interactúa en lenguaje natural; el chat actúa como puerta de entrada al pipeline NTO (Orquestador) y al Headless Guardian.

**Animación de estado:** cuando el modelo está trabajando/escuchando, se muestra una animación inspirada en Ciri (señal visual orgánica y fluida) para indicar actividad sin saturar la UI.

## 2. Responsabilidades

- Recibir input del usuario en lenguaje natural (live chat)
- Mostrar output del agente en lenguaje natural (streaming)
- Mostrar estado del agente mediante animación tipo Ciri (thinking, working, idle)
- Adjuntar archivos/drag & drop
- Historial de conversación temporal (se mantiene durante la tarea activa)
- Click en archivos modificados → abre en Editor en la línea exacta
- Click en entradas de git log → abre diff en Editor

## 3. Estados UI

| Estado         | Descripción                                    | Animación Ciri           |
| :------------- | :--------------------------------------------- | :----------------------- |
| **IDLE**       | Esperando input, Main listo                    | Pulso suave, pausado     |
| **LISTENING**  | Capturando input del usuario (escribiendo/voz) | Pulso activo, receptivo  |
| **THINKING**   | Main analizando y planificando tarea           | Onda expansiva lenta     |
| **DELEGATING** | Main enviando tarea a subagente(s)             | Destello direccional     |
| **WORKING**    | Subagente(s) ejecutando acciones               | Onda rápida, constante   |
| **STREAMING**  | Main generando respuesta al usuario            | Flujo continuo           |
| **ERROR**      | Error en el agente o validación                | Pulso rojo, intermitente |

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
│    │                                                usuario │
│    └─────────────────────────────────────────────────────┘  │
│                                                           │
│  ┌─────────────────────────────────────────────────────────┐│
│  │ ◉ Analizando tu solicitud...                           ││
│  └─────────────────────────────────────────────────────────┘│
│                                                           │
│  ┌─────────────────────────────────────────────────────────┐│
│  │ ◉ Delegando al agente Coder...                         ││
│  └─────────────────────────────────────────────────────────┘│
│                                                           │
│  ┌─────┓ ┌───────────────────────────────────────────┐    │
│  │ ◉   │ │ He creado los siguientes archivos:        │    │
│  └─────┘ │ • auth/login.go (click → abre)            │    │
│          │ • auth/middleware.go (click → abre)       │    │
│          │ • auth/jwt.go (click → abre)              │    │
│          │                                            │    │
│          │ ¿Quieres que continúe con los tests?       │    │
│          └───────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

- Timestamp en cada mensaje
- Código syntax highlighted
- Soporte formateo dinamico, listas, tabla, graficos, diagramas
- Acciones sugeridas como botones
- **Archivos modificados:** clickeables, abren en Editor en la línea exacta
- **Git log entries:** clickeables, abren diff en Editor

### 4.3 Animación Ciri (Indicador de Estado) (se muestra en lugar del input area cuando el modo live esta activo)

Animación orgánica inspirada en señales de energía fluida:

"uvicado en todo el contorno de la ui de chat"

- **IDLE:** pulso muy suave, casi imperceptible — el Main está "respirando"
- **LISTENING:** pulso activo y receptivo — indicando que está capturando input
- **THINKING:** onda expansiva lenta — el Main está analizando y planificando
- **DELEGATING:** destello direccional hacia afuera — enviando tarea a subagente(s)
- **WORKING:** onda rápida y constante — subagente(s) ejecutando
- **STREAMING:** flujo continuo hacia el usuario — generando respuesta
- **ERROR:** pulso rojo intermitente — requiere atención

### 4.4 Input Area (Indicador de Estado) (se oculta cuando el modo live esta activo)

```
┌─────────────────────────────────────────────────────────────┐
│ 📎 │ Escribe tu mensaje...                    │ ⏎  │ 🎤 │
│     │   (textarea auto-expand)            │Send│ Mic │
│     │                                    │    │     │
└─────────────────────────────────────────────────────────────┘
  Attach  Input                    Send   Voice input
```

### 4.5 Status Bar

```
┌─────────────────────────────────────────────────────────────┐
│ [●] │  Main: THINKING  │  Agentes: 2 activos │ Flush: LISTO │
└─────────────────────────────────────────────────────────────┘
```

## 5. Acciones del Usuario

| Acción             | Input             | Resultado              |
| :----------------- | :---------------- | :--------------------- |
| **Enviar mensaje** | Enter o click ⏎   | Envía a Main           |
| **Multiline**      | Shift+Enter       | Nueva línea            |
| **Adjuntar**       | Click 📎          | File picker            |
| **Drag & drop**    | Arrastrar archivo | Adjunta archivo        |
| **Voice**          | Click 🎤          | Graba audio            |
| **Limpiar**        | Click ⋮ → Clear   | Limpia chat + Flush    |
| **Exportar**       | Click ⋮ → Export  | Exporta Markdown       |
| **Copy code**      | Click en código   | Copy al clipboard      |
| **Abrir archivo**  | Click en archivo  | Abre en Editor (línea) |
| **Ver diff**       | Click en git log  | Abre diff en Editor    |

## 6. Tipos de Mensaje

| Tipo           | Visual                                    | Cuándo se usa                              |
| :------------- | :---------------------------------------- | :----------------------------------------- |
| **texto**      | Texto plano con markdown                  | Respuestas normales del agente             |
| **codigo**     | Bloque con syntax highlight + copy button | Código generado por subagentes             |
| **archivo**    | Link clickeable al archivo + línea        | Archivos creados/modificados por agentes   |
| **error**      | Error en rojo con details                 | Errores de validación, timeout, fallos     |
| **system**     | Mensaje del sistema en gris               | Flush completado, agentes delegados, etc.  |
| **accion**     | Botón de acción (sugerencia)              | Sugerencias del agente ("continuar", etc.) |
| **git-log**    | Entry de git con diff preview             | Cambios commiteados, clickeable            |
| **delegación** | Indicador de agente delegado              | "Agente Coder trabajando en auth/login.go" |

## 7. Integración con Backend

### 7.1 Perfil Único (Main)

Main opera bajo el modelo de Perfil Único:

- No mantiene historial de chat largo
- Carga información de STRACT.md y git logs - git commits
- **Analiza la tarea, planifica y delega** a uno o más subagentes con micro-skills específicas
- Realiza Context Flush después de cada tarea validada
- La conversación es **bidireccional**: el usuario envía mensajes Y el Main envía actualizaciones de estado proactivamente
- las herramientas tambien pueden eviar mensajes al main o a los subagentes en ejecucion

### 7.2 Flujo de Delegación

```
0. justo al corgar el software: el modelo carga specs/ si no existen es un proyecto nuevo
     ↓
1. Usuario envía mensaje
     ↓
2. Main analiza la tarea (THINKING)
     ↓
3. Main planifica la estrategia
     ↓
4. Main delega a uno o más subagentes y crea STRACT.md (DELEGATING)
     ↓
5. Subagente(s) ejecutan con micro-skills en worktree (WORKING)
     ↓
6. Main recibe resultados y genera respuesta (STREAMING)
     ↓
7. Usuario escucha/ve respuesta + archivos modificados
     ↓
8. usuario aprueba modificaciones de archivos
     ↓
9. Context Flush tras validación
     ↓
10. Reload: Carga (STRACT.md)s + grafo de tareas
     ↓
11. Listo para siguiente tarea (IDLE)
```

### 7.3 IPC Commands

```
// Main → Frontend (proactivo)
"chat:message"      → Nuevo mensaje del agente
"chat:status"       → Cambio de estado (thinking, working, etc.)
"chat:action"       → Acción sugerida
"chat:delegation"   → Subagente delegado con su tarea
"chat:file-created" → Archivo creado (path + línea)
"chat:git-log"      → Entry de git log con diff
"agent:progress"    → Progreso de tarea
"main:flush"        → Indica que se hizo flush

// Frontend → Main
"chat:send"         → Envía mensaje del usuario
"chat:cancel"       → Cancela operación actual
"chat:action:click" → Usuario clickea acción sugerida
"chat:file:open"    → Usuario abre archivo desde chat
"chat:git-log:open" → Usuario abre diff desde git log
"context:flush"     → Solicita flush de KV Cache
```

### 7.4 Modelo de Mensajería

El chat NO es un simple request/response. Es un **sistema de mensajería en vivo**:

- **Usuario → Main:** mensajes de texto, archivos, comandos
- **Main → Usuario:** respuestas, actualizaciones de estado, delegaciones, archivos creados
- **Main → Main:** planificación interna, delegación a subagentes
- **Subagente → Main:** resultados de tareas, progreso
- **Main → Frontend:** streaming de respuestas, indicadores visuales

## 8. Comunicación con Headless Guardian

Toda validación de input/output es responsabilidad del Headless Guardian. Ver `specs/05-headless-guardian.md` para detalles completos.

El chat solo recibe:

- mensajes de el usuario
- informacion ya validada por iuput Guard
- Alertas de seguridad que se muestran al usuario

## 9. Casos Edge

| Escenario             | Comportamiento                         |
| :-------------------- | :------------------------------------- |
| Timeout               | Mostrar error + opción de retry        |
| Rate limit            | Queue + notificar al usuario           |
| Offline               | Cachear mensajes, enviar después       |
| Flush fallido         | Reintentar con backoff exponencial     |
| Agente delegado falla | Notificar, ofrecer retry               |
| Múltiples agentes     | Mostrar progreso y estado por cada uno |

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
│  │ ◉ Analizando...  →  ◉ Delegando...  →  ◉ Listo     ││
│  └─────────────────────────────────────────────────────────┘│
│                                                           │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ 📝 He creado:                                        │   │
│  │ ⬡ auth/jwt.go (click → abre)                        │   │
│  │ ⬡ auth/middleware.go (click → abre)                 │   │
│  └─────────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────────┤
│ 📎 │ Escribe tu mensaje...                    │ ⏎  │ 🎤 │
├─────────────────────────────────────────────────────────────┤
│ [●] │  Main: IDLE  │  Agentes: 1 activo  │  Flush: LISTO  │
└─────────────────────────────────────────────────────────────┘
```

## 11. Sistema de Tareas Complejas

### 11.1 Concepto

Para tareas complejas repetitivas (ej: "crea un login completo"), el sistema gestiona subtareas como parte de la **Memoria Atómica** (micro-skills):

- El Main busca en la memoria instruciones (micro skills) para la gestion de tareas largas
- el modelo delega despues de planificar y cumplir con lo especificado en las (micro skills)
- El flush ocurre solo al finalizar la tarea completa

### 11.2 Ejemplo: Login Completo

```
Tarea: "Crea un login con JWT"
├── Subtarea 1: auth/jwt.go (generar token)
├── Subtarea 2: auth/middleware.go (validar token)
├── Subtarea 3: auth/login.go (endpoint login)
├── Subtarea 4: tests unitarios
└── Subtarea 5: documentación

Flush → Solo después de las 5 subtareas validadas
```

### 11.3 Pendientes del Sistema

- [ ] Definir esquema de división de tareas complejas
- [ ] Integrar con Sistema de Memoria Atómica (DB relacional de micro-skills)
- [ ] Definir protocolo de persistencia de subtareas
- [ ] Definir validación humana por subtarea

## 12. Pendientes

### Prioridad Alta

- [ ] Definir modelo LLM a usar (GGUF con mmap)
- [ ] Configurar system prompt por defecto
- [ ] Definir límites de contexto (tokens)
- [ ] Configurar streaming vs batch
- [ ] Implementar protocolos Context Flush & Reload
- [ ] Configurar Perfil Único con inyección de micro-skills
- [ ] Definir animación Ciri (implementación técnica)
- [ ] Definir acciones sugeridas por defecto

### Investigación Requerida

- [x] ~~Modelo de mensajería bidireccional para chats con LLMs~~ → **Definido en `specs/06-validaciones-chat-llm.md`**
- [ ] Estructura de payloads IPC (investigar formato estándar)

## 13. Referencias Cruzadas

| Tema                                            | Spec Principal                      |
| :---------------------------------------------- | :---------------------------------- |
| Headless Guardian (validación)                  | `specs/05-headless-guardian.md`     |
| Validaciones Chat LLM (streaming, delegaciones) | `specs/06-validaciones-chat-llm.md` |
| Navegador WebView                               | `specs/02-ui-navegador-webview.md`  |
| Editor de Código                                | `specs/04-ui-editor-codigo.md`      |
| File Explorer                                   | `specs/04b-file-explorer.md`        |
| Contenedor Shell                                | `specs/01-ui-contenedor-shell.md`   |
