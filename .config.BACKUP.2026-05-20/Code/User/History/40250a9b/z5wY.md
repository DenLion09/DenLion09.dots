# Design: IA Chat — Orquestador Central de mi_suit

## Technical Approach

El Chat IA implementa el patrón **Core + Extensibility** como orquestador multiagente. La arquitectura sigue el modelo de flujo SDD/TDD donde el Main Agent recibe input del usuario, analiza la tarea, y delega a sub-agentes especializados (Arquitecto → Coder → Reviewer). El diseño prioriza separación de responsabilidades mediante interfaces claras entre UI, Agent, Tools, Context y Providers.

## Architecture Decisions

### Decision: Chat State Machine con Transiciones Explícitas

**Choice**: Estado global manajado por el patron states con enums con transiciones discretas IDLE → LISTENING → THINKING → DELEGATING → STREAMING → ERROR
**Rationale**: El Chat tiene 6 estados bien definidos (per general_specs.md).

### Decision: Provider Adapter Pattern para LLMs

**Choice**: Interfaz `AI SDK.rs` con implementaciones concretas para cada proveedor (OpenAI, Anthropic, llama.cpp (autogestionado no en mvp), huggin face serverless inference, mistral)
**Alternatives considered**: Un provider monolítico con switch/case, configuración runtime con if/else
**Rationale**: El proposal especifica "soporte para gratuitos, pagos y locales". Cada proveedor tiene rate limits, autenticación, y formato de respuesta distintos. El adapter permite testing con mocks y swapping de proveedor sin modificar lógica de negocio.

### Decision: Tool Registry como Plugin System

**Choice**: Registry centralizado con `ToolDefinition` interface que permite registro dinámico de herramientas
**Alternatives considered**: Hardcoded tools en el agente, inheritance con base class
**Rationale**: La spec indica que MCP viene en Fase 2. El registry diseñado desde el inicio con `registerTool()` y `executeTool()` permite extensión futura sin refactoring. Equivale al pattern usado en VS Code extensions.

### Decision: Context Manager con Buffer Circular

**Choice**: Buffer circular con max_tokens y políticas de eviction LRU
**Alternatives considered**: Flush completo, contexto infinito, embeddings de todo el historial
**Rationale**: El proposal especifica "Flush/reload automático basado en tokens". Un buffer circular es memory-efficient y mantiene los mensajes más recientes (los más relevantes). El eviction LRU preserva contexto de tareas en progreso.

### Decision: Streaming via Tauri Events

**Choice**: Rust backend envía eventos de streaming al frontend via `emit()` de Tauri
**Alternativas considered**: WebSocket standalone, polling HTTP, SSE con proxy
**Rationale**: Tauri ya tiene IPC incorporado. Usar `emit()` elimina dependencia adicional y mantiene el modelo de seguridad de Tauri. El streaming del LLM es un flujo de tokens, no una conexión bidireccional completa.

## Data Flow

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│   User UI   │────▶│ ChatStore    │────▶│ Main Agent  │
│  (React)    │◀────│ (states)     │◀────│ (Orquest)   │
└─────────────┘     └──────────────┘     └──────┬──────┘
       │                    │                    │
       │                    │                    ▼
       │                    │            ┌──────────────┐
       │                    │            │ Tool Registry│
       │                    │            └──────┬───────┘
       │                    │                   │
       ▼                    ▼                   ▼
┌─────────────────────────────────────────────────────────┐
│                    Context Manager                      │
│  ┌─────────────┐  ┌─────────────┐ ┌─────────────┐       │
│  │ MessageBuf  │  │ STRACT.md   │ │ necesari files   │       │
│  └─────────────┘  └─────────────┘ └─────────────┘       │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│                    Provider Adapter                     │
│   OpenAI    │   Anthropic   │   Ollama   │  LM Studio   │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
                    ┌─────────────────┐
                    │  Tauri Backend  │
                    │   (Rust/LLM)    │
                    └─────────────────┘
```

**Flujo típico**:

1. User envía mensaje → ChatStore captura y cambia a LISTENING
2. Main Agent analiza → THINKING → genera plan de delegación
3. Tool Registry ejecuta herramientas necesarias → WORKING
4. Respuesta streamed via Tauri Events → STREAMING
5. Context Manager actualiza buffer circular
6. Fin de stream → IDLE

## File Changes

| File                                              | Action | Description                       |
| ------------------------------------------------- | ------ | --------------------------------- |
| `src/apps/ia_chat/`                               | Create | Carpeta raíz de la app            |
| `src/apps/ia_chat/index.tsx`                      | Create | Entry point, routing              |
| `src/apps/ia_chat/store.ts`                       | Create | Zustand store, state machine      |
| `src/apps/ia_chat/components/ChatWindow.tsx`      | Create | Container principal               |
| `src/apps/ia_chat/components/MessageList.tsx`     | Create | Lista de mensajes                 |
| `src/apps/ia_chat/components/MessageBubble.tsx`   | Create | Rendering individual              |
| `src/apps/ia_chat/components/InputBox.tsx`        | Create | Input del usuario                 |
| `src/apps/ia_chat/components/StatusIndicator.tsx` | Create | Estado visual (Ciri animation)    |
| `src/apps/ia_chat/agent/MainAgent.ts`             | Create | Orquestador de flujo SDD/TDD      |
| `src/apps/ia_chat/agent/types.ts`                 | Create | Interfaces de agentes y contratos |
| `src/apps/ia_chat/tools/ToolRegistry.ts`          | Create | Registro dinámico de herramientas |
| `src/apps/ia_chat/tools/FileTool.ts`              | Create | Leer/escribir/buscar archivos     |
| `src/apps/ia_chat/tools/TerminalTool.ts`          | Create | Ejecución de comandos             |
| `src/apps/ia_chat/tools/WebTool.ts`               | Create | Búsqueda en internet              |
| `src/apps/ia_chat/context/ContextManager.ts`      | Create | Buffer circular, flush/reload     |
| `src/apps/ia_chat/providers/LLMProvider.ts`       | Create | Interfaz abstracta                |
| `src/apps/ia_chat/providers/OllamaProvider.ts`    | Create | Implementación Ollama             |
| `src/apps/ia_chat/providers/OpenAIProvider.ts`    | Create | Implementación OpenAI             |
| `src/shared/markdown/`                            | Create | Componente compartido markdown    |
| `src-tauri/src/chat.rs`                           | Create | Comandos Tauri para LLM           |

## Interfaces / Contracts

```typescript
// Core interfaces para el sistema de chat

interface ChatState {
  status:
    | "IDLE"
    | "LISTENING"
    | "THINKING"
    | "DELEGATING"
    | "WORKING"
    | "STREAMING"
    | "ERROR";
  messages: Message[];
  currentTask?: Task;
}

interface Message {
  id: string;
  role: "user" | "assistant" | "tool";
  content: string;
  timestamp: number;
  toolCalls?: ToolCall[];
}

interface ToolDefinition {
  name: string;
  description: string;
  execute: (params: ToolParams) => Promise<ToolResult>;
  validate?: (params: ToolParams) => boolean;
}

interface LLMProvider {
  name: string;
  stream(prompt: string, onChunk: (token: string) => void): Promise<void>;
  embeddings(text: string): Promise<number[]>;
}

interface ContextWindow {
  messages: Message[];
  maxTokens: number;
  currentTokens: number;
  flush(): void;
  reload(): void;
}

interface DelegationContract {
  taskId: string;
  agentType: "architect" | "coder" | "reviewer";
  objectives: string[];
  budget: number; // max tokens
  deadline: number; // ms
  onFail: "retry" | "escalate" | "abort";
}
```

## Testing Strategy

| Layer       | What to Test                                                          | Approach                        |
| ----------- | --------------------------------------------------------------------- | ------------------------------- |
| Unit        | ChatState transitions, ToolRegistry execution, ContextWindow eviction | Vitest con mocks de proveedores |
| Unit        | LLMProvider adapters, tool validation                                 | Vitest con sinon stubs          |
| Integration | ChatStore → MainAgent → ToolRegistry flow                             | Vitest con store fixture        |
| Integration | Streaming response end-to-end                                         | Playwright con mock server      |
| E2E         | User sends message → sees streamed response                           | Playwright con real Ollama      |

**Coverage target**: >80% en agent logic y tools. UI tests focus on state transitions.

## Migration / Rollback

No migration required — primera implementación. El rollback plan del proposal:

1. Eliminar `src/apps/ia_chat/`
2. Remover imports del router principal
3. Revertir cambios en `src/shared/`
4. Sin pérdida de datos (no hay persistencia en MVP)

## Open Questions

- [ ] **Editor Engine**: ¿CodeMirror 6 o Monaco? Pending decision.
- [ ] **LLM Model**: ¿Qwen2.5-Coder o DeepSeek-Coder? Pending decision.
- [ ] **Streaming format**: ¿JSON chunks o texto plano? Depende del provider.
- [ ] **Guardian Integration**: ¿Input/Output Guard en MVP o Fase 2? Proposal dice no bloqueante pero hay que definir interface.

## Dependencies de otras fases

- **Phase 0 (Tauri)**: Debe completarse antes de implementar este diseño
- **Phase 2 (MCP)**: El ToolRegistry está diseñado para soportar extensibilidad
- **Memoria Atómica**: No es dependencia directa del MVP, pero el ContextManager debe tener interface ready
