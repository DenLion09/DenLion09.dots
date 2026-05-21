# CR-002: Estandarización de Formato IPC

## Metadata

- **ID:** CR-002
- **Prioridad:** CRÍTICA
- **Esfuerzo estimado:** M (Medio) — incluye transporte Rust
- **Hallazgos relacionados:** SPEC-001, SPEC-010, SPEC-022
- **Fecha:** 2026-05-08
- **Actualizado:** 2026-05-09

---

## Descripción

Se detectaron **5 formatos IPC distintos** entre las especificaciones, además de inconsistencias internas dentro de la misma spec (SPEC-010: "IPC strings planos vs JSON estructurado"). Esta fragmentación impide interoperabilidad y aumenta la deuda técnica exponencialmente.

---

## Fundamento Técnico

### Inventario de Formatos Detectados

| Spec    | Formato Utilizado                      | Estado                     |
| ------- | -------------------------------------- | -------------------------- |
| SPEC-01 | Strings planos (`"flush"`, `"reload"`) | Inconsistente internamente |
| SPEC-03 | JSON estructurado                      | Parcialmente definido      |
| SPEC-04 | JSON plano + strings                   | Inconsistente              |
| SPEC-05 | JSON estructurado                      | Parcialmente definido      |
| SPEC-06 | JSON estructurado                      | Parcialmente definido      |
| SPEC-07 | JSON estructurado                      | Parcialmente definido      |

### Análisis del Problema

1. **SPEC-001 identifica 5 formatos IPC distintos** — sin documentación de cuándo usar cada uno.

2. **Inconsistencia interna en SPEC-01** (SPEC-010):
   - Sección 4.x usa strings planos: `"flush"`, `"reload"`, `"status"`
   - Otras secciones usan JSON: `{"type": "message", "payload": {...}}`

3. **Inconsistencia entre SPECs**:
   - SPEC-04 (SPEC-022) usa IPC JSON plano vs strings planos
   - SPEC-03 usa formato diferente a SPEC-05 para el mismo tipo de mensaje

4. **Ninguna especificación define el protocolo de transporte**:
   - ¿WebSocket? ¿gRPC? ¿HTTP long-poll? ¿Server-Sent Events?
   - ¿这个消息如何序列化? (sin serialización definida)

---

## Impacto

### Si No Se Resuelve

- Cada componente implementará su propio formato IPC
- Impossibilidad de comunicación cross-componente confiable
- Tests de integración imposibles de escribir
- Acoplamiento implícito entre componentes
- Debt técnico grows O(n²) donde n = número de componentes

### Si Se Resuelve

- Protocolo IPC universal ytyped
- Componentes intercambiables
- Tests de integración triviales
- Onboarding de nuevos desarrolladores más rápido
- Base para инструментарий de debugging y monitoring

---

## Solución Propuesta

### Paso 1: Definir Formato de Mensajes Universal

Basado en SPEC-01 y SPEC-05, proponer **JSON estructurado** como formato único:

```typescript
// Mensaje base JSON
interface JSONMessage {
  version: "1.0"; // Versión del protocolo
  id: string; // UUID v4, idempotency key
  timestamp: number; // Unix epoch ms
  type: MessageType; // Enum tipado
  source: ComponentId; // Quién emite
  target?: ComponentId; // Unicast; null = broadcast
  correlationId?: string; // Para request/response
  payload: Record<string, unknown>; // Datos específicos del tipo
  metadata?: {
    retries?: number;
    priority?: "low" | "normal" | "high" | "critical";
    deadline?: number; // Unix epoch ms
  };
}

// Enum de tipos de mensaje
type MessageType =
  // Control
  | "ping"
  | "pong"
  | "ack"
  | "nack"
  | "error"
  // Flujo de datos
  | "flush"
  | "reload"
  | "stream-start"
  | "stream-data"
  | "stream-end"
  // Negocio
  | "context-update"
  | "artifact-generated"
  | "agent-handoff"
  // Estado
  | "status-request"
  | "status-response"
  | "health-check";
```

### Paso 2: Definir Tipos Específicos

```typescript
// Flush (SPEC-012)
interface FlushMessage extends JSONMessage {
  type: "flush";
  payload: {
    reason: "buffer-threshold" | "timeout" | "manual" | "task-complete";
    bufferSize: number;
    tokenBudget: {
      used: number;
      remaining: number;
    };
  };
}

// Reload (SPEC-012)
interface ReloadMessage extends JSONMessage {
  type: "reload";
  payload: {
    contextId: string;
    startFromToken: number;
    includeHistory: boolean;
  };
}

// Status Response (SPEC-036)
interface StatusResponse extends JSONMessage {
  type: "status-response";
  payload: {
    component: ComponentId;
    state: ComponentState;
    metrics: {
      bufferSize?: number;
      flushCount?: number;
      uptime?: number;
    };
  };
}
```

### Paso 3: Documentar Cuándo Usar Cada Tipo

| Tipo de Mensaje | Cuándo Usar                        | Ejemplo                 |
| --------------- | ---------------------------------- | ----------------------- |
| `flush`         | Buffer alcanza threshold o timeout | LLM streaming           |
| `reload`        | Recargar contexto desde caché      | Recovery, branch switch |
| `ack`           | Confirmación de recepción          | Post-flush confirmation |
| `stream-data`   | Datos parciales                    | LLM token stream        |

### Paso 4: Protocolo de Transporte

**Contexto resuelto:**

- Componentes son aplicaciones de escritorio escritas en **Rust** (procesos separados)
- Serialización: **JSON sobre UTF-8** (ya definido por uso con PostgreSQL)
- Transporte: comunicación localhost entre procesos Rust

**Arquitectura de Transporte**

```
┌─────────────────────────────────────────────────┐
│              JSON Message                       │
├─────────────────────────────────────────────────┤
│              MessageBus Interface               │
├─────────────────────────────────────────────────┤
│          Transport Adapter Layer                │
│   ┌──────────────┬──────────────┬─────────────┐ │
│   │ Unix Sockets │ Named Pipes │ TCP Fallback │ │
│   └──────────────┴──────────────┴─────────────┘ │
└─────────────────────────────────────────────────┘
```

**Decisión de Transporte**

| Aspecto             | Decisión                          |
| ------------------- | --------------------------------- |
| Transporte primario | Unix Domain Sockets (`tokio-uds`) |
| Fallback portable   | TCP localhost (127.0.0.1)         |
| Serialización       | JSON sobre UTF-8                  |
| Compresión          | No necesaria (localhost)          |
| Heartbeat           | Cada 30s con `ping`/`pong`        |

**Capa de Abstracción (Rust)**

```rust
// crates/ipc-transport/src/lib.rs
pub enum Transport {
    UnixSocket(PathBuf),      // Unix/Linux/macOS
    #[cfg(windows)]
    NamedPipe(String),          // Windows
    TcpLocalhost(String),       // Fallback portable
}

pub trait IpcTransport: Send + Sync {
    fn send(&self, msg: &[u8]) -> Result<(), IpcError>;
    fn recv(&self, buf: &mut [u8]) -> Result<usize, IpcError>;
}

impl LocalMessageBus {
    pub fn with_transport<T: IpcTransport>(transport: T) -> Self;
    pub fn subscribe<T>(&self, msg_type: MessageType, handler: Handler<T>);
    pub fn publish(&self, msg: &JSONMessage) -> Result<(), IpcError>;
    pub fn request<T>(&self, msg_type: MessageType, payload: T) -> impl Future<Output = Result<JSONMessage, IpcError>>;
}
```

**Crates Rust recomendados:**

| Crate                  | Uso                               |
| ---------------------- | --------------------------------- |
| `tokio-uds`            | Unix Domain Sockets async         |
| `ipc-channel`          | Channels semánticos de alto nivel |
| `serde` + `serde_json` | Serialización JSON (ya en uso)    |
| `tracing`              | Debugging y monitoring            |

**Consideraciones de Plataforma**

| SO      | Transporte Primario | Alternativa   |
| ------- | ------------------- | ------------- |
| Linux   | Unix Domain Sockets | TCP localhost |
| macOS   | Unix Domain Sockets | TCP localhost |
| Windows | Named Pipes         | TCP localhost |

> **Nota:** Unix Domain Sockets es ~0ms latency y cero overhead de red para localhost. Si el target es cross-platform, usar `ipc-channel` que abstrae esta lógica, o detectar el SO en runtime.

**MessageBus como interfaz unificada**

Los componentes TypeScript (plugins) consumen el MessageBus sin conocer el transporte:

- Misma interfaz independientemente del SO
- Si mañana se mueve a red (no local), solo cambia el Transport Adapter
- Tests pueden usar `InMemoryTransport` para mock puro |

---

## Criterios de Aceptación

- [ ] Formato TON Message definido formalmente en un documento
- [ ] Tabla de tipos de mensajes con payload examples
- [ ] Guía de cuándo usar cada tipo
- [ ] SPEC-01, SPEC-03, SPEC-04, SPEC-05, SPEC-06, SPEC-07 actualizadas
- [ ] Todos los mensajes "PENDIENTE" reemplazados con tipos concretos
- [ ] Protocolo de transporte documentado
- [ ] Capa de abstracción `IpcTransport` definida en Rust
- [ ] Implementación Unix Domain Sockets (`tokio-uds`)
- [ ] Implementación TCP localhost como fallback portable
- [ ] `LocalMessageBus` con interfaz unificada (subscribe/publish/request)
- [ ] Ejemplos de código en cada spec

---

## Archivos Afectados

| Archivo                               | Acción                                                  |
| ------------------------------------- | ------------------------------------------------------- |
| `specs/01-ui-shell/spec.md`           | Reescribir sección de IPC                               |
| `specs/03-main-agent/spec.md`         | Actualizar formato de mensajes                          |
| `specs/04-editor-integration/spec.md` | Unificar formato IPC                                    |
| `specs/05-pipeline-nto/spec.md`       | Actualizar protocolo                                    |
| `specs/06-streaming-llm/spec.md`      | Unificar con otros specs                                |
| `specs/07-memory-context/spec.md`     | Actualizar mensajes                                     |
| `crates/ipc-transport/src/lib.rs`     | Crear crate con `IpcTransport` trait y implementaciones |
| `crates/ipc-messagebus/src/lib.rs`    | Crear `LocalMessageBus` con subscribe/publish/request   |
| `docs/ipc-protocol.md`                | Crear documento de referencia                           |

---

## Notas Adicionales

- **Serialización:** JSON sobre UTF-8 (ya definido por uso con PostgreSQL)
- **Target:** Aplicaciones de escritorio Rust (procesos separados)
- **Topología:** Localhost — no requiere compresión ni overhead de red
- **Crates sugeridos:** `tokio-uds`, `ipc-channel`, `serde`, `serde_json`, `tracing` |

---

## Dependencias

- **CR-003** (Definición JSON): Necesita formato base para mensajes
- **Bloquea:** CR-004 (Protocolo Flush/Reload)

---

_Revisado: SPEC-001, SPEC-010, SPEC-022_
