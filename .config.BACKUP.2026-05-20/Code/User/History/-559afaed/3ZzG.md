# Plan de Integración: TON + Headless Guardian

## 1. Visión General

El sistema TON (Token Oriented Notation) es el **formato de mensajería** que todas las herramientas usan para comunicarse. El Headless Guardian es el **motor de validación** que intercepta, valida y enruta cada mensaje TON antes de que llegue a su destino.

**Principio fundamental:** NINGÚN mensaje TON llega a su destino sin pasar por el Guardian. Zero Trust significa que el Guardian no confía en el remitente, ni en el payload, ni en el destinatario.

```
┌──────────┐    TON message    ┌──────────────────────────────────────┐
│  SENDER  │ ────────────────► │         HEADLESS GUARDIAN             │
│ (Chat,   │                   │                                       │
│ Editor,  │                   │  1. Input Guard (sanitiza + valida)   │
│ etc.)    │                   │  2. Channel Validator (reglas canal)  │
└──────────┘                   │  3. Loop Sentinel (detecta ciclos)    │
          ◄─────────────────── │  4. Route (entrega al destinatario)   │
         TON validated/blocked │  5. Output Guard (si es respuesta)    │
                               └──────────────────────────────────────┘
```

---

## 2. Problemas Actuales en las Specs

### 2.1 Inconsistencias Detectadas

| #      | Problema                                                                                                                                                                                                                                                                                           | Specs Afectadas                  | Impacto                                               |
| :----- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :------------------------------- | :---------------------------------------------------- |
| **P1** | Spec/05 tiene DOS diagramas de arquitectura duplicados y contradictorios (líneas 20-46 vs 49-78). El segundo incluye "Chat Output Validator", "Agent Comm Manager" y "Sub-agents" como componentes internos del Guardian, pero la nota del §2 dice que los sub-agentes son gestionados por Chat IA | spec/05 §2 vs §3                 | Confusión sobre qué vive DENTRO del Guardian vs FUERA |
| **P2** | El formato TON en spec/05 §10.1 es mínimo — no incluye campos para tracking de validación, correlation IDs, timestamps, o retry metadata que spec/06 requiere para delegaciones y streaming                                                                                                        | spec/05 §10, spec/06 §6          | Formato TON incompleto para casos reales              |
| **P3** | spec/05 §5.5 enumera canales (Chat↔Navigator, etc.) pero no define los payloads TON específicos por canal. Solo dice "TON" como formato                                                                                                                                                            | spec/05 §5.5                     | No hay schema por canal                               |
| **P4** | spec/06 define un pipeline de validación complejo (streaming, delegaciones, heartbeats) pero no conecta explícitamente con el formato TON ni con los commands/events de spec/05                                                                                                                    | spec/06 §4.1, spec/05 §10        | Dos sistemas de validación que no se hablan           |
| **P5** | Los IPC commands de spec/03 (chat:message, chat:status, etc.) no usan formato TON — son strings simples. spec/03 §14 dice "siempre via Guardian" pero no muestra el formato TON                                                                                                                    | spec/03 §7.3, spec/03 §14        | Inconsistencia entre IPC actual y TON                 |
| **P6** | spec/06 §8.3 define nuevos IPC commands (chat:validation:status, guard:stream:chunk_valid, etc.) que no existen en el registro TON de spec/05                                                                                                                                                      | spec/06 §8.3, spec/05 §10.2-10.3 | Commands sin registro TON                             |

### 2.2 Resolución de Problemas

| Problema | Resolución                                                                                                                                                                                                                                                                                                                                                                    |
| -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **P1**   | La arquitectura CANÓNICA es la primera (líneas 20-46): Guardian = Input Guard + Output Guard + Loop Sentinel + Communication Bus. Los sub-agentes (Security Scanner, Spec Enforcer, Design Inspector) son gestionados por Chat IA, NO viven dentro del Guardian. El "Chat Output Validator" se unificó como "Presentation Layer Validator" (§5.4) que SÍ vive en el Guardian. |
| **P2**   | Extender formato TON con campos opcionales de tracking (ver §3 abajo)                                                                                                                                                                                                                                                                                                         |
| **P3**   | Definir schema TON por canal con validación específica (ver §5)                                                                                                                                                                                                                                                                                                               |
| **P4**   | Unificar: el pipeline de spec/06 SE IMPLEMENTA a través de TON + Guardian. Cada etapa del pipeline es un guard que procesa mensajes TON.                                                                                                                                                                                                                                      |
| **P5**   | Todos los IPC commands se envuelven en TON. El string `"chat:message"` se convierte en `ton: "chat:message"` dentro del envelope TON.                                                                                                                                                                                                                                         |
| **P6**   | Registrar todos los nuevos commands/events en el catálogo TON unificado (ver §4)                                                                                                                                                                                                                                                                                              |

---

## 3. Formato TON Extendido

### 3.1 Estructura Base (obligatoria)

```json
{
  "ton": "bus:message",
  "version": "1.0.0",
  "id": "uuid-v4",
  "timestamp": "2026-05-01T10:30:00Z",
  "from": "chat",
  "to": "editor",
  "payload": { ... },
  "async": true,
  "callback": "bus:message:response"
}
```

| Campo       | Tipo             | Obligatorio | Descripción                                           |
| ----------- | ---------------- | :---------: | ----------------------------------------------------- |
| `ton`       | string           |     ✅      | Tipo de mensaje (command TON)                         |
| `version`   | string           |     ✅      | Versión del protocolo TON                             |
| `id`        | string (UUID)    |     ✅      | ID único del mensaje (para tracking y loop detection) |
| `timestamp` | string (RFC3339) |     ✅      | Cuándo se creó el mensaje                             |
| `from`      | string           |     ✅      | Identificador del remitente                           |
| `to`        | string           |     ✅      | Identificador del destinatario                        |
| `payload`   | object           |     ✅      | Datos del mensaje (schema varía por canal)            |
| `async`     | boolean          |     ✅      | Si es asíncrono (espera callback) o fire-and-forget   |
| `callback`  | string           | Condicional | Event TON para respuesta (obligatorio si async=true)  |

### 3.2 Campos de Tracking (opcionales, usados por Guardian)

```json
{
  "trace": {
    "correlation_id": "uuid-v4",
    "parent_message_id": "uuid-v4|null",
    "hop_count": 0,
    "validation_status": "pending|approved|blocked|partial",
    "guard_applied": ["input_guard", "channel_validator", "loop_sentinel"],
    "error_spans": []
  },
  "delegation": {
    "contract_id": "uuid-v4",
    "subagent_id": "agent_coder_01",
    "budget_remaining": { "tokens": 3500, "time_ms": 25000 }
  },
  "streaming": {
    "stream_id": "uuid-v4",
    "chunk_index": 3,
    "total_chunks": null,
    "is_final": false
  }
}
```

| Campo                     | Uso                                         | Cuándo se agrega                   |
| ------------------------- | ------------------------------------------- | ---------------------------------- |
| `trace.correlation_id`    | Agrupa mensajes de la misma transacción     | Guardian al recibir primer mensaje |
| `trace.parent_message_id` | Cadena de causalidad (mensaje A → generó B) | Guardian al reenviar               |
| `trace.hop_count`         | Detecta loops (si > threshold, bloquear)    | Guardian incrementa en cada hop    |
| `trace.validation_status` | Estado de validación del mensaje            | Guardian después de validar        |
| `trace.guard_applied`     | Qué guards se aplicaron                     | Guardian después de validar        |
| `trace.error_spans`       | Rangos de texto que fallaron validación     | Streaming validator (spec/06 §5.5) |
| `delegation.*`            | Metadata de delegación a subagente          | Main al delegar tarea              |
| `streaming.*`             | Metadata de chunk de streaming              | LLM al enviar tokens               |

### 3.3 Envelope de Respuesta del Guardian

```json
// Mensaje aprobado
{
  "ton": "bus:validated",
  "id": "uuid-v4-new",
  "timestamp": "2026-05-01T10:30:01Z",
  "from": "guardian",
  "to": "editor",
  "original_from": "chat",
  "original_ton": "bus:message",
  "original_id": "uuid-v4-original",
  "payload": { "action": "open_file", "path": "src/auth/login.go", "line": 42 },
  "status": "approved",
  "trace": {
    "correlation_id": "corr-uuid",
    "parent_message_id": "uuid-v4-original",
    "hop_count": 1,
    "validation_status": "approved",
    "guard_applied": ["input_guard", "channel_validator", "loop_sentinel"]
  }
}

// Mensaje bloqueado
{
  "ton": "bus:blocked",
  "id": "uuid-v4-new",
  "timestamp": "2026-05-01T10:30:01Z",
  "from": "guardian",
  "to": "chat",
  "original_from": "chat",
  "original_id": "uuid-v4-original",
  "reason": "Path traversal detected: ../../../etc/passwd",
  "type": "security",
  "severity": "critical",
  "trace": {
    "correlation_id": "corr-uuid",
    "parent_message_id": "uuid-v4-original",
    "hop_count": 1,
    "validation_status": "blocked",
    "guard_applied": ["input_guard"]
  }
}
```

---

## 4. Catálogo TON Unificado

### 4.1 Commands (mensajes que se envían)

| Command                 | From → To            | Payload Schema                                | Validación Guardian                             |
| :---------------------- | :------------------- | :-------------------------------------------- | :---------------------------------------------- | -------------------------- |
| `bus:message`           | any → any            | `{ action, ... }`                             | Input Guard + Channel Validator + Loop Sentinel |
| `bus:subscribe`         | tool → guardian      | `{ channel: string }`                         | Validate channel exists                         |
| `bus:unsubscribe`       | tool → guardian      | `{ channel: string }`                         | Validate subscription exists                    |
| `guard:validate:input`  | tool → guardian      | `{ raw_input: string, source: string }`       | Input Guard completo                            |
| `guard:validate:output` | agent → guardian     | `{ raw_output: string, agent_id: string }`    | Output Guard completo                           |
| `guard:loop:detected`   | guardian → any       | `{ loop_type, affected_agents, action }`      | Auto-generado                                   |
| `chat:send`             | frontend → chat      | `{ message: string, attachments?: string[] }` | Input Guard (prompt injection, length)          |
| `chat:cancel`           | frontend → chat      | `{ task_id?: string }`                        | Validate task exists                            |
| `chat:file:open`        | frontend → editor    | `{ path: string, line?: number }`             | Path traversal check                            |
| `chat:git-log:open`     | frontend → editor    | `{ commit: string }`                          | Validate commit exists                          |
| `context:flush`         | chat → guardian      | `{ project_id: string }`                      | Validate project, save artifacts                |
| `memory:search`         | chat → memory        | `{ query, project_id, stack, limit? }`        | Validate project access                         |
| `memory:skill:create`   | chat → memory        | `MicroSkill`                                  | Validate schema, check duplicate fingerprint    |
| `web:navigate`          | chat → navigator     | `{ url: string }`                             | Allowlist domains                               |
| `web:script:inject`     | chat → navigator     | `{ script: string, target?: string }`         | Sanitize script, validate target                |
| `file:open`             | frontend → editor    | `{ path: string }`                            | Path traversal check                            |
| `file:save`             | frontend → editor    | `{ path: string, content: string }`           | Path traversal, content scan                    |
| `file:lint`             | editor → guardian    | `{ path: string, content: string }`           | Code Guardian validation                        |
| `explorer:search`       | frontend → explorer  | `{ query: string, type: "filename"            | "content" }`                                    | Sanitize query, rate limit |
| `tool:open`             | frontend → container | `{ tool_id: string }`                         | Validate tool exists                            |
| `tool:close`            | frontend → container | `{ tool_id: string }`                         | Validate tool is open                           |
| `worktree:create`       | chat → container     | `{ name: string, branch?: string }`           | Validate name, check exists                     |
| `worktree:commit`       | chat → container     | `{ message: string, files?: string[] }`       | Validate message, check files                   |

### 4.2 Events (mensajes que se reciben)

| Event                        | From → To            | Payload Schema                                   | Cuándo se emite                         |
| :--------------------------- | :------------------- | :----------------------------------------------- | :-------------------------------------- | --------- | ------ | ---------------- |
| `bus:message:sent`           | guardian → sender    | `{ original_id, to, delivered_at }`              | Mensaje enrutado exitosamente           |
| `bus:message:blocked`        | guardian → sender    | `{ original_id, reason, type, severity }`        | Mensaje bloqueado                       |
| `bus:validated`              | guardian → dest      | `{ original_from, payload, status }`             | Mensaje aprobado y entregado            |
| `guard:input:validated`      | guardian → sender    | `{ original_id, sanitization_applied }`          | Input pasó validación                   |
| `guard:output:validated`     | guardian → agent     | `{ original_id, filters_applied }`               | Output pasó validación                  |
| `guard:loop:detected`        | guardian → all       | `{ loop_type, affected, action }`                | Loop detectado                          |
| `guard:agent:blocked`        | guardian → all       | `{ agent_id, reason }`                           | Agente bloqueado                        |
| `chat:message`               | chat → frontend      | `{ content, type, timestamp, files? }`           | Nuevo mensaje del agente                |
| `chat:status`                | chat → frontend      | `{ status: "IDLE"                                | "THINKING"                              | "WORKING" | ... }` | Cambio de estado |
| `chat:delegation`            | chat → frontend      | `{ subagent_id, objective, contract_id }`        | Subagente delegado                      |
| `chat:file-created`          | chat → frontend      | `{ path, line?, language }`                      | Archivo creado                          |
| `chat:git-log`               | chat → frontend      | `{ commit, diff_preview, files_changed }`        | Entry de git log                        |
| `chat:validation:status`     | chat → frontend      | `{ status, details }`                            | Estado de validación                    |
| `chat:retraction`            | chat → frontend      | `{ message_id, reason }`                         | Retraer mensaje (stream post-hoc falló) |
| `agent:progress`             | chat → frontend      | `{ task_id, progress, total }`                   | Progreso de tarea                       |
| `file:opened`                | editor → frontend    | `{ path, content, language }`                    | Archivo cargado                         |
| `file:modified`              | editor → frontend    | `{ path, modified: boolean }`                    | Archivo modificado                      |
| `file:saved`                 | editor → frontend    | `{ path, success: boolean }`                     | Archivo guardado                        |
| `lint:results`               | guardian → frontend  | `{ path, diagnostics[] }`                        | Resultados de lint                      |
| `web:loaded`                 | navigator → frontend | `{ url, status_code }`                           | Página cargada                          |
| `web:error`                  | navigator → frontend | `{ url, error_message }`                         | Error de carga                          |
| `tool:opened`                | container → frontend | `{ tool_id }`                                    | Herramienta abierta                     |
| `tool:closed`                | container → frontend | `{ tool_id }`                                    | Herramienta cerrada                     |
| `main:flush`                 | chat → frontend      | `{ project_id, artifacts_saved: number }`        | Flush completado                        |
| `memory:search:results`      | memory → chat        | `{ skills[], query_embedding, search_time_ms }`  | Resultados búsqueda                     |
| `memory:skill:created`       | memory → chat        | `{ skill_id, name, fingerprint }`                | Nueva micro-skill                       |
| `guard:stream:chunk_valid`   | guardian → chat      | `{ stream_id, chunk_index, content }`            | Chunk streaming válido                  |
| `guard:stream:chunk_blocked` | guardian → chat      | `{ stream_id, chunk_index, reason, error_span }` | Chunk streaming bloqueado               |
| `guard:delegation:result`    | guardian → chat      | `{ contract_id, status, result }`                | Resultado de delegación                 |
| `guard:context:restore`      | guardian → chat      | `{ project_id, restored_artifacts[] }`           | Contexto restaurado post-flush          |

---

## 5. Validación por Canal

Cada canal tiene reglas de validación específicas que el Guardian aplica DESPUÉS del Input Guard genérico.

### 5.1 Matriz de Validación

```
Mensaje TON entra al Guardian
       │
       ▼
┌─────────────────────────┐
│ 1. INPUT GUARD (genérico)│  ← Siempre: sanitize, validate size, detect injection
└──────────┬──────────────┘
           ▼
┌─────────────────────────┐
│ 2. LOOP SENTINEL         │  ← Siempre: check hop_count, retry patterns, circular
└──────────┬──────────────┘
           ▼
┌─────────────────────────┐
│ 3. CHANNEL VALIDATOR     │  ← Específico por canal (ver abajo)
└──────────┬──────────────┘
           ▼
    approved → deliver to destination
    blocked  → return bus:blocked to sender
```

### 5.2 Reglas por Canal

| Canal                | Campo Crítico                         | Validación Específica                                                                          | Acción si falla                            |
| :------------------- | :------------------------------------ | :--------------------------------------------------------------------------------------------- | :----------------------------------------- | ------------- |
| **Chat → Navigator** | `payload.url`                         | Allowlist de dominios, no localhost/internal IPs, max URL length 2048                          | Block + log                                |
| **Navigator → Chat** | `payload.html`, `payload.screenshot`  | Sanitize HTML (eliminar `<script>`, `on*` handlers), max size 5MB                              | Strip tags + warn o block                  |
| **Chat → Editor**    | `payload.path`                        | Path traversal check (no `..`, no absolute paths fuera del proyecto), file extension allowlist | Block + alert                              |
| **Editor → Chat**    | `payload.content`                     | Scan for secrets (API keys, tokens, passwords), max content size 50KB                          | Mask secrets + warn                        |
| **Chat → Container** | `payload.command`                     | Command injection check (no `;`, `                                                             | `, `&&`, backticks), allowlist de comandos | Block + alert |
| **Container → Chat** | `payload.output`                      | Filter sensitive data (env vars, tokens, keys), max output size 100KB                          | Filter + warn                              |
| **Chat → Explorer**  | `payload.path`, `payload.query`       | Path traversal, query length max 256 chars                                                     | Block                                      |
| **Explorer → Chat**  | `payload.tree`, `payload.content`     | No system paths (/etc, /proc, etc.), max files returned 100                                    | Filter + limit                             |
| **Chat → Terminal**  | `payload.command`                     | Command injection, dangerous commands blocklist (rm -rf, dd, mkfs, etc.)                       | Block + alert                              |
| **Terminal → Chat**  | `payload.output`, `payload.exit_code` | Mask tokens/keys in output, max output 50KB                                                    | Filter + truncate                          |

### 5.3 Schema de Payload por Canal

```typescript
// Chat → Navigator
interface NavigatePayload {
  action: "navigate" | "back" | "forward" | "reload";
  url?: string; // required for navigate
}

// Chat → Editor
interface FileOperationPayload {
  action: "open_file" | "save_file" | "close_file" | "highlight";
  path: string; // relative path only
  line?: number;
  content?: string; // for save
  range?: { start: number; end: number }; // for highlight
}

// Chat → Container
interface ContainerCommandPayload {
  action: "run_command" | "create_worktree" | "commit" | "set_env";
  command?: string;
  worktree_name?: string;
  commit_message?: string;
  env_var?: { key: string; value: string };
}

// Chat → Explorer
interface ExplorerPayload {
  action: "search" | "list" | "preview";
  query: string;
  type: "filename" | "content";
  limit?: number; // default 50, max 100
}

// Chat → Terminal
interface TerminalPayload {
  action: "execute" | "cancel";
  command: string;
  timeout_ms?: number; // default 30000, max 120000
  working_dir?: string; // relative path only
}
```

---

## 6. Flujo Completo de un Mensaje TON

### 6.1 Diagrama de Flujo

```
┌──────────────────────────────────────────────────────────────────────┐
│                     FLUJO COMPLETO DE MENSAJE TON                     │
└──────────────────────────────────────────────────────────────────────┘

1. SENDER construye mensaje TON
   { ton: "bus:message", from: "chat", to: "editor", payload: { action: "open_file", path: "src/auth/login.go" }, id: "msg-001", ... }
   │
   ▼
2. GUARDIAN recibe mensaje
   │
   ├── 2a. INPUT GUARD
   │   ├── Sanitize: verificar no hay inyección en payload.path
   │   ├── Validate: tamaño del mensaje < 10KB, campos requeridos presentes
   │   ├── Classify: detectar intent (file operation)
   │   └── Si falla → return bus:blocked con reason
   │
   ├── 2b. LOOP SENTINEL
   │   ├── Check hop_count: si > 10 → block (loop)
   │   ├── Check pattern: mismo from→to→payload en últimos 3 mensajes → block
   │   └── Si pasa → increment hop_count
   │
   ├── 2c. CHANNEL VALIDATOR (Chat→Editor)
   │   ├── Path traversal: no "..", no absolute paths fuera del proyecto
   │   ├── File extension: .go, .ts, .js, .tsx, .jsx, .md, .json, .yaml, .css, .html, etc.
   │   └── Si falla → return bus:blocked con reason
   │
   ▼
3. GUARDIAN enruta mensaje
   ├── Update tool state: editor → PROCESSING
   ├── Emit event: bus:message:sent
   └── Deliver payload to editor
   │
   ▼
4. RECEIVER procesa mensaje
   ├── Editor abre archivo
   └── Genera respuesta TON: { ton: "file:opened", from: "editor", to: "chat", payload: { path, content, language } }
   │
   ▼
5. GUARDIAN valida respuesta (OUTPUT GUARD)
   ├── Filter: scan content por secrets (API keys, tokens)
   ├── Validate: content < 50KB, language válido
   └── Si secrets encontrados → mask + warn
   │
   ▼
6. PRESENTATION LAYER VALIDATOR
   ├── Paths absolutos → convertir a relativos
   ├── Content size → si > 50KB, truncar + note
   └── Format: verificar estructura del mensaje
   │
   ▼
7. GUARDIAN entrega a CHAT
   └── Emit event: bus:validated
   │
   ▼
8. CHAT muestra al usuario
```

### 6.2 State Machine de Mensaje TON

```
              ┌──────────┐
              │ CREATED  │  ← Sender construye mensaje
              └────┬─────┘
                   │ send
                   ▼
              ┌──────────┐
              │ RECEIVED │  ← Guardian recibe
              └────┬─────┘
                   │
          ┌────────┼────────┐
          ▼        ▼        ▼
     ┌────────┐┌────────┐┌────────┐
     │INPUT   ││ LOOP   ││CHANNEL │
     │GUARD   ││SENTINEL││VALIDATE│
     └───┬────┘└───┬────┘└───┬────┘
         │         │         │
         └────┬────┘         │
              │              │
         pass?├── No ────────┤
              │              │
              ▼              ▼
         ┌──────────┐  ┌──────────┐
         │ APPROVED │  │ BLOCKED  │
         └────┬─────┘  └────┬─────┘
              │             │
              ▼             │
         ┌──────────┐       │
         │ ROUTING  │       │
         └────┬─────┘       │
              │             │
              ▼             │
         ┌──────────┐       │
         │DELIVERED │       │
         └──────────┘       │
                            ▼
                     ┌──────────┐
                     │  LOGGED  │  ← Siempre se loguea
                     └──────────┘
```

---

## 7. Integración con Spec/06 (Validaciones Complejas)

### 7.1 Streaming Validation via TON

El spec/06 define patrones de validación de streaming. Aquí se conectan con TON:

```
LLM genera tokens ──► Stream Parser ──► Buffer (50-100 tokens)
                                              │
                                     Sentence complete?
                                      │          │
                                    Yes          No (timeout 500ms)
                                      │          │
                                      ▼          ▼
                              ┌──────────────────┐
                              │  Build TON chunk │
                              │  ton: "guard:    │
                              │    stream:chunk" │
                              │  chunk_index: N  │
                              └────────┬─────────┘
                                       │
                              ┌────────▼─────────┐
                              │  OUTPUT GUARD    │
                              │  (fast checks)   │
                              │  - Length        │
                              │  - PII patterns  │
                              │  - Injection     │
                              └────────┬─────────┘
                                       │
                                pass?  ├── No
                                       │
                                       ▼
                              ┌──────────────────┐
                              │ bus:blocked      │
                              │ type: "stream"   │
                              │ error_span: {...}│
                              └──────────────────┘

                                       │ pass
                                       ▼
                              ┌──────────────────┐
                              │ guard:stream:    │
                              │   chunk_valid    │
                              │ → Frontend       │
                              └──────────────────┘
```

**TON de chunk de streaming:**

```json
{
  "ton": "guard:stream:chunk",
  "id": "chunk-uuid-001",
  "timestamp": "2026-05-01T10:30:00Z",
  "from": "llm",
  "to": "chat",
  "payload": {
    "content": "He creado el archivo ",
    "token_count": 7
  },
  "async": false,
  "streaming": {
    "stream_id": "stream-uuid-001",
    "chunk_index": 3,
    "total_chunks": null,
    "is_final": false
  }
}
```

### 7.2 Delegation via TON

El spec/06 define Delegation Contracts. Aquí se conectan con TON:

```json
// Main delega a subagente
{
  "ton": "bus:message",
  "id": "msg-delegate-001",
  "timestamp": "2026-05-01T10:30:00Z",
  "from": "chat",
  "to": "agent_coder",
  "payload": {
    "action": "delegate_task",
    "objective": "Implementar auth/jwt.go con GenerateToken y ValidateToken",
    "success_criteria": [
      "Archivo compila sin errores",
      "Tests unitarios pasan",
      "No secrets hardcodeados"
    ]
  },
  "async": true,
  "callback": "bus:message:response",
  "delegation": {
    "contract_id": "contract-uuid-001",
    "subagent_id": "agent_coder_01",
    "budget_remaining": {
      "max_tokens": 4096,
      "max_time_ms": 30000,
      "max_tool_calls": 20
    },
    "fail_policy": "fail_closed",
    "required_verification": "tool_verified"
  }
}

// Subagente responde
{
  "ton": "bus:message",
  "id": "msg-delegate-result-001",
  "timestamp": "2026-05-01T10:30:15Z",
  "from": "agent_coder",
  "to": "chat",
  "payload": {
    "action": "task_complete",
    "status": "success",
    "files_created": ["auth/jwt.go"],
    "output": "Archivo generado exitosamente"
  },
  "async": false,
  "delegation": {
    "contract_id": "contract-uuid-001",
    "subagent_id": "agent_coder_01",
    "verification_status": "tool_verified",
    "lineage_chain": ["agent_coder_01"],
    "cost": {
      "tokens_used": 2048,
      "time_ms": 15000,
      "tool_calls": 3
    }
  }
}
```

### 7.3 Mensajería Proactiva via TON

```json
// Main notifica delegación (proactivo)
{
  "ton": "chat:delegation",
  "id": "msg-proactive-001",
  "timestamp": "2026-05-01T10:30:01Z",
  "from": "chat",
  "to": "frontend",
  "payload": {
    "message_type": "delegation",
    "content": "Delegando al agente Coder: auth/jwt.go",
    "subagent_id": "agent_coder_01",
    "contract_id": "contract-uuid-001"
  },
  "async": false
}

// Main notifica progreso (proactivo)
{
  "ton": "agent:progress",
  "id": "msg-proactive-002",
  "timestamp": "2026-05-01T10:30:05Z",
  "from": "chat",
  "to": "frontend",
  "payload": {
    "message_type": "progress",
    "content": "Progreso: 3/5 subtareas completadas",
    "task_id": "task-uuid-001",
    "progress": 3,
    "total": 5
  },
  "async": false
}
```

---

## 8. Loop Detection con TON

El Loop Sentinel usa los campos TON para detectar ciclos:

### 8.1 Mecanismos de Detección

| Tipo                    | Cómo se detecta                                                              | Datos TON usados                                                | Threshold                                 |
| ----------------------- | ---------------------------------------------------------------------------- | --------------------------------------------------------------- | ----------------------------------------- |
| **Hop Count**           | `trace.hop_count` > MAX_HOPS                                                 | `trace.hop_count`                                               | 10 hops                                   |
| **Retry Loop**          | Mismo `from` + mismo `ton` + mismo `payload.hash` en N intentos consecutivos | `from`, `ton`, hash(payload), timestamp                         | 3 intentos (GUARDIAN_MAX_RETRIES)         |
| **Circular Dependency** | A→B→C→A detectado en `trace.parent_message_id` chain                         | `from`, `to`, `trace.parent_message_id`, `trace.correlation_id` | Detectado = bloquear                      |
| **Same Output**         | Mismo output hash en N respuestas consecutivas del mismo agente              | `from`, hash(payload), timestamp                                | 2 consecutivos (GUARDIAN_MAX_SAME_OUTPUT) |

### 8.2 Implementación del Tracking

```
Guardian mantiene en memoria (Redis):

loop_detection_index:
  - by_correlation_id: { correlation_id → [message_ids] }
  - by_agent_retry: { "from:ton:payload_hash" → { count, last_timestamp } }
  - by_agent_output: { "from" → [output_hash, timestamp] }
  - by_hop_chain: { message_id → { hop_count, chain: [from→to, from→to, ...] } }
```

---

## 9. Casos Edge y Manejo de Errores

### 9.1 Matriz de Errores

| Escenario                      | Qué pasa                      | TON de respuesta                                             | Recovery                              |
| :----------------------------- | :---------------------------- | :----------------------------------------------------------- | :------------------------------------ |
| **Input inválido**             | Input Guard rechaza           | `bus:blocked` con `type: "validation"`                       | Sender corrige y reenvía              |
| **Path traversal**             | Channel Validator bloquea     | `bus:blocked` con `type: "security"`, `severity: "critical"` | No retry, alert                       |
| **Loop detectado**             | Loop Sentinel bloquea         | `guard:loop:detected` broadcast                              | Unwind stack, notify user             |
| **Timeout de validación**      | Guardian no responde en 5s    | Sender recibe timeout                                        | Retry con backoff exponencial (max 3) |
| **Destinatario no existe**     | Routing falla                 | `bus:blocked` con `type: "routing"`                          | Sender verifica tool_id               |
| **Message queue full**         | Cola saturada (>1000 pending) | `bus:blocked` con `type: "overload"`                         | Backpressure, retry after 1s          |
| **Secret detectado en output** | Output Guard mask             | `bus:validated` con `trace.warning: "secret_masked"`         | Content delivered con mask            |
| **Stream chunk blocked**       | Streaming validator rechaza   | `guard:stream:chunk_blocked` con `error_span`                | Continue stream, mark span            |
| **Delegation budget exceeded** | Subagente excede budget       | `bus:blocked` con `type: "budget"`, delegation metadata      | Fail per fail_policy                  |
| **Agent crash**                | Destinatario no responde      | `bus:blocked` con `type: "agent_unavailable"`                | Isolate agent, retry on restart       |

### 9.2 Retry Policy

```
Retry solo aplica para:
  - Timeout de validación
  - Queue overload
  - Agent temporarily unavailable

NO retry para:
  - Security blocks (path traversal, command injection, secrets)
  - Loop detection
  - Validation failures (input/output format)

Backoff exponencial:
  - Retry 1: 500ms
  - Retry 2: 1000ms
  - Retry 3: 2000ms
  - Max: 3 retries
```

---

## 10. Tasks de Implementación

### Fase 1: Core TON + Guardian Bus

| #      | Task                                                                         | Dependencias | Estimación |
| ------ | ---------------------------------------------------------------------------- | :----------: | :--------: |
| **T1** | Definir y tipar formato TON extendido (TypeScript interfaces + JSON schemas) |   Ninguna    |     2h     |
| **T2** | Implementar Communication Bus (message queue, routing, state management)     |      T1      |     4h     |
| **T3** | Implementar Input Guard (sanitize, validate, classify)                       |    T1, T2    |     3h     |
| **T4** | Implementar Output Guard (filter secrets, validate format)                   |  T1, T2, T3  |     3h     |
| **T5** | Implementar Loop Sentinel (hop count, retry detection, circular dependency)  |      T2      |     3h     |
| **T6** | Implementar Channel Validators (reglas por canal)                            |  T1, T2, T3  |     4h     |

### Fase 2: Integration with Tools

| #       | Task                                                                     | Dependencias | Estimación |
| ------- | ------------------------------------------------------------------------ | :----------: | :--------: |
| **T7**  | Adaptar Chat IA para enviar/recibir mensajes TON (envolver IPC commands) |    T1-T6     |     3h     |
| **T8**  | Adaptar Editor para recibir/enviar mensajes TON                          |    T1-T6     |     2h     |
| **T9**  | Adaptar Navigator para recibir/enviar mensajes TON                       |    T1-T6     |     2h     |
| **T10** | Adaptar Explorer para recibir/enviar mensajes TON                        |    T1-T6     |     2h     |
| **T11** | Adaptar Terminal para recibir/enviar mensajes TON                        |    T1-T6     |     2h     |
| **T12** | Adaptar Container para recibir/enviar mensajes TON                       |    T1-T6     |     2h     |

### Fase 3: Advanced Validations (spec/06)

| #       | Task                                                                   |  Dependencias  | Estimación |
| ------- | ---------------------------------------------------------------------- | :------------: | :--------: |
| **T13** | Implementar Streaming Validator (Buffer-and-Release, error spans)      |   T1-T6, T7    |     4h     |
| **T14** | Implementar Delegation Guard (contract validation, schema enforcement) |   T1-T6, T7    |     4h     |
| **T15** | Implementar Presentation Layer Validator (reduce, sanitize paths)      |   T1-T6, T7    |     2h     |
| **T16** | Implementar Heartbeat Validator                                        |   T1-T6, T7    |     2h     |
| **T17** | Implementar Context Provider para post-flush restore                   | T1-T6, spec/07 |     4h     |

### Fase 4: Observability + Testing

| #       | Task                                                           | Dependencias | Estimación | Estimación |
| ------- | -------------------------------------------------------------- | :----------: | :--------: | ---------- |
| **T18** | Logging structured (DEBUG, INFO, WARN, ERROR, ALERT)           |    T1-T6     |     2h     |
| **T19** | Metrics (validation rate, block rate, avg latency, loop count) |  T1-T6, T18  |     2h     |
| **T20** | Test suite: unit tests para cada guard                         |    T1-T6     |     6h     |
| **T21** | Test suite: integration tests para flujos completos            |    T1-T17    |     8h     |
| **T22** | Test suite: edge cases (loops, timeouts, security blocks)      |    T1-T17    |     4h     |

**Total estimado: ~72 horas de desarrollo**

---

## 11. Decisiones de Diseño

### 11.1 ¿Por qué TON como envelope y no como payload?

TON es el **envelope** (sobre) que contiene el mensaje. El `payload` es el contenido específico. Esto permite:

- Validación consistente del envelope (siempre tiene from, to, id, timestamp)
- Routing sin necesidad de parsear el payload
- Tracking y debugging uniformes
- Canal-agnostic: el Guardian puede validar el envelope sin conocer el payload

### 11.2 ¿Por qué validation ANTES de routing?

Zero Trust: nunca confíes en el remitente. Si ruteas primero y validas después, un mensaje malicioso ya llegó al destinatario. Validar primero garantiza que solo mensajes seguros se entregan.

### 11.3 ¿Por qué hop_count en el trace y no en el payload?

El hop_count es metadata de infraestructura, no del mensaje. Ponerlo en `trace` evita que el remitente lo manipule. El Guardian lo controla exclusivamente.

---

## 12. Referencias Cruzadas

| Spec                      | Secciones Relevantes                                                      |
| ------------------------- | ------------------------------------------------------------------------- |
| spec/05 (Guardian)        | §3 (arquitectura), §5.1-5.5 (subsistemas), §10 (TON API)                  |
| spec/06 (Validaciones)    | §4 (pipeline), §5 (streaming), §6 (delegations), §8 (proactive messaging) |
| spec/03 (Chat IA)         | §7.3 (IPC commands), §14 (Guardian Bus), §8 (sub-agentes)                 |
| spec/07 (Memoria Atómica) | §9 (IPC commands para memoria)                                            |
| spec/04 (Editor)          | §7.1 (IPC commands del editor)                                            |
