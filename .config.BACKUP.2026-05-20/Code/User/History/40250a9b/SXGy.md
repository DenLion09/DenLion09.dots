# Design: IA Chat — Orquestador Central de mi_suit

## Technical Approach

El Chat IA implementa el patrón **Core + Extensibility** como orquestador multiagente. La arquitectura sigue el modelo de flujo SDD/TDD donde el Main Agent recibe input del usuario, analiza la tarea, y delega a sub-agentes especializados (Arquitecto → Coder → Reviewer). El diseño prioriza separación de responsabilidades mediante interfaces claras entre UI, Agent, Tools, Context y Providers.

## Architecture Decisions

### Decision: Chat State Machine con Transiciones Explícitas

**Choice**: Estado global manejado por el patrón states con enums con transiciones discretas IDLE → LISTENING → THINKING → WORKING → DELEGATING → STREAMING → ERROR
**Rationale**: El Chat tiene 7 estados bien definidos (per general_specs.md).

### Decision: AI SDK.rs como Capa de LLMs

**Choice**: Librería [AI SDK.rs](https://aisdk.rs) con providers nativos
**Rationale**: El proposal especifica "soporte para gratuitos, pagos y locales". AI SDK.rs provee:

- **Provider agnostic**: misma API para todos los LLMs
- **Type-safe**: validación de capacidades del modelo en compile time (e.g., `OpenAI::gpt_5()` vs `OpenAI::gpt_3_5_turbo()` sin tool support produce compile error)
- **Streaming nativo**: `stream_text()` para respuestas en tiempo real
- **Tools/Agents**: `#[tool]` macro + `.with_tool()` para ejecución de herramientas integrada
- **Structured Output**: `.schema::<T>()` (requiere modelo que soporte la feature)
- **70+ providers**: OpenAI, Anthropic, Google, Ollama, OpenRouter, xAI, etc.

**Patrón de uso**:

```rust
use aisdk::{core::LanguageModelRequest, providers::OpenAI};

// Typed model (compile-time safety)
let response = LanguageModelRequest::builder()
    .model(OpenAI::gpt_5())
    .prompt("Hello")
    .build()
    .generate_text()
    .await?;

// Dynamic model (runtime selection)
let openai = OpenAI::<DynamicModel>::builder()
    .model_name("gpt-5")
    .build()?;
```

**Alternatives considered**: Provider adapter personalizado, implementations separadas por proveedor
**Decision**: AI SDK.rs ya implementa el patrón adapter de forma óptima y probada.

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

### Decision: Sistema de Agentes Híbrido (OpenCode Pattern + AI SDK.rs)

**Choice**: Arquitectura híbrida que combina definición de agentes (patrón OpenCode) con ejecución (AI SDK.rs)

**Componentes del Sistema**:

| Componente   | Ubicación                    | Propósito                                         |
| ------------ | ---------------------------- | ------------------------------------------------- |
| **Agentes**  | `.mi_suit/agents/*.md`       | Definición de agentes con frontmatter YAML        |
| **Skills**   | `.mi_suit/skills/*/SKILL.md` | Instrucciones reutilizables cargables por agentes |
| **Registry** | `src/chat/agent/registry.rs` | Carga y gestiona agentes definidos                |
| **Ejecutor** | `src/chat/agent/executor.rs` | Instancia AI SDK.rs para cada agente              |

**Estructura de un Agente** (`.mi_suit/agents/architect.md`):

```yaml
---
name: architect
description: Agente especializado en diseño y arquitectura de software
model: openai/gpt-5
max_steps: 50
tools:
  - read
  - grep
  - glob
  - search
---
# System Prompt
Eres un arquitecto de software senior. Analiza requisitos, crea diseños detallados
y produce documentos de especificación técnica. Prioriza simplicidad, mantenibilidad
y principios SOLID.
```

### Main Agent (Agente de Entrada)

El **Main Agent** es el **único agente con el que el usuario interactúa directamente**.

**MVP Implementation** (v1.0):

- Recibe mensajes del usuario
- Ejecuta directamente: leer archivos, buscar archivos, búsqueda web
- NO delega a sub-agentes (postergado para Fase 2)
- NO escribe archivos ni ejecuta terminal

**Fase 2** (expansión):

- Delegará tareas complejas a sub-agentes (architect → coder → reviewer)
- Implementará sistema de skills
- Tendrá acceso a terminal (con sandbox)

> **Nota**: La arquitectura del AgentExecutor soporta ambas modalidades. La configuración del Main Agent determina el comportamiento.

**Ejemplo de Main Agent** (`.mi_suit/agents/main.md`):

```yaml
---
name: main
description: Agente orquestador principal - único punto de contacto con el usuario
model: openai/gpt-5
max_steps: 10
tools:
  - read        # Leer archivos para contexto
  - grep        # Buscar contenido en archivos
  - glob        # Buscar archivos por nombre/patrón
  - search      # Búsqueda en internet
subagents:
  - architect   # Diseño y arquitectura
  - coder       # Implementación
  - reviewer    # Revisión de código
---
# System Prompt
Eres el orquestador principal de mi_suit. El usuario interactúa SOLO contigo.

## Tu trabajo:
1. Analiza la solicitud del usuario
2. Si es una tarea simple (lectura, búsqueda), hazla tú mismo
3. Si es compleja (diseño, implementación, revisión), DELEGA al sub-agente apropiado

## Reglas de delegación:
- Diseño/arquitectura → @architect
- Implementación/código → @coder
- Revisión/validación → @reviewer
- Flujos SDD completos → @sdd-flow

## Restricciones:
- NO escribas archivos directamente (usa @coder)
- NO ejecutes comandos de terminal (usa @coder)
- NO realices operaciones destructivas

## Formato de delegación:
Usa el tool de Task para invocar sub-agentes:
```

task({ agent: "architect", prompt: "Análisis de requisitos para..." })

```

```

**Estructura de un Skill** (`.mi_suit/skills/git-release/SKILL.md`):

```yaml
---
name: git-release
description: Create consistent releases and changelogs
license: MIT
---
## What I do
- Draft release notes from merged PRs
- Propose a version bump (semver)

## When to use me
Use when preparing a tagged release.
```

**Carga de Agentes** (v1.0 - MVP):

- Global: `~/.config/mi_suit/agents/`
- Proyecto: `.mi_suit/agents/`
- Skills: **No implementado en MVP** (Fase 2)

> **Extensibilidad futura**: La arquitectura está diseñada para soportar carga de skills en Fase 2 sin refactoring.

**Ejecución con AI SDK.rs**:

```rust
let agent_config = load_agent("architect")?;

let response = LanguageModelRequest::builder()
    .model(OpenAI::gpt_5())
    .system(agent_config.system_prompt)
    .with_tools(agent_config.tools)
    .stop_when(step_count_is(agent_config.max_steps))
    .build()
    .generate_text()
    .await?;
```

**Alternatives considered**: Solo AI SDK.rs (sin registro de agentes), solo archivos de configuración
**Decision**: El patrón OpenCode proporciona DX superior (definición declarativa) mientras AI SDK.rs maneja la ejecución compleja (loops, tools, hooks).

## Data Flow

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│   User UI   │────▶│ ChatStore    │────▶│ Main Agent  │
│  (Yew/Lept) │◀────│ (states)     │◀────│ (Orquest)   │
└─────────────┘     └──────────────┘     └──────┬──────┘
        │                    │                    │
        │                    │                    ▼
        │                    │            ┌──────────────┐
        │                    │            │ Tool Registry│
        │                    │            └──────┬───────┘
        │                    │                   │
        ▼                    ▼                   ▼
┌───────────────────────────────────────────────────────┐
│                    Context Manager                    │
│  ┌─────────────┐  ┌─────────────┐ ┌────────────────┐  │
│  │ MessageBuf  │  │ STRACT.md   │ │ necessary files │  │
│  └─────────────┘  └─────────────┘ └────────────────┘  │
└───────────────────────────────────────────────────────┘
                            │
                            ▼
┌───────────────────────────────────────────────────────┐
│                      AI SDK.rs                        │
│   OpenAI    │   Anthropic   │  Google  │   Ollama    │
│   xAI       │   OpenRouter │   ...   │  (70+ prov)  │
└───────────────────────────────────────────────────────┘
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
4. AI SDK.rs streaming via `stream_text()` → STREAMING
5. Context Manager actualiza buffer circular
6. Fin de stream → IDLE

## File Changes

| File                                              | Action | Description                                |
| ------------------------------------------------- | ------ | ------------------------------------------ |
| `src-tauri/src/chat/`                             | Create | Módulo principal del chat                  |
| `src-tauri/src/chat/mod.rs`                       | Create | Orquestador del flujo SDD/TDD              |
| `src-tauri/src/chat/state.rs`                     | Create | Chat state machine (enum simple)           |
| `src-tauri/src/chat/agent/mod.rs`                 | Create | Módulo de agentes                          |
| `src-tauri/src/chat/agent/registry.rs`            | Create | Registro de agentes (carga .md)            |
| `src-tauri/src/chat/agent/executor.rs`            | Create | Ejecutor con AI SDK.rs                     |
| `src-tauri/src/chat/agent/types.rs`               | Create | Tipos: AgentConfig, SkillConfig            |
| `src-tauri/src/chat/agent/fsm/`                   | Create | **Fase 2**: State machines con guards      |
| `src-tauri/src/chat/agent/fsm/architect.rs`       | Create | **Fase 2**: FSM del Architect              |
| `src-tauri/src/chat/agent/fsm/coder.rs`           | Create | **Fase 2**: FSM del Coder                  |
| `src-tauri/src/chat/agent/fsm/reviewer.rs`        | Create | **Fase 2**: FSM del Reviewer               |
| `src-tauri/src/chat/agent/fsm/guards.rs`          | Create | **Fase 2**: Guards (pre/post validaciones) |
| `src-tauri/src/chat/tools/mod.rs`                 | Create | Registro de herramientas                   |
| `src-tauri/src/chat/tools/file_tool.rs`           | Create | Leer/escribir/buscar archivos              |
| `src-tauri/src/chat/tools/terminal_tool.rs`       | Create | Ejecución de comandos                      |
| `src-tauri/src/chat/tools/web_tool.rs`            | Create | Búsqueda en internet                       |
| `src-tauri/src/chat/context.rs`                   | Create | Buffer circular, flush/reload              |
| `src-tauri/src/chat/providers.rs`                 | Create | Configuración de AI SDK.rs                 |
| `src-tauri/src/chat/commands.rs`                  | Create | Comandos Tauri IPC                         |
| `src-tauri/src/ui/`                               | Create | UI en Rust (Yew/Leptos)                    |
| `src-tauri/src/ui/components/chat_window.rs`      | Create | Container principal                        |
| `src-tauri/src/ui/components/message_list.rs`     | Create | Lista de mensajes                          |
| `src-tauri/src/ui/components/message_bubble.rs`   | Create | Rendering individual                       |
| `src-tauri/src/ui/components/input_box.rs`        | Create | Input del usuario                          |
| `src-tauri/src/ui/components/status_indicator.rs` | Create | Estado visual (Ciri animation)             |
| `.mi_suit/agents/`                                | Create | Directorio de agentes                      |
| `.mi_suit/skills/`                                | Create | Directorio de skills                       |

**Archivos de configuración de agentes (ejemplos)**:

- `.mi_suit/agents/main.md` - **Main Agent** (entrada del usuario, delega a sub-agentes)
- `.mi_suit/agents/architect.md` - Sub-agente arquitecto (diseño/especificaciones)
- `.mi_suit/agents/coder.md` - Sub-agente implementador (escribe código)
- `.mi_suit/agents/reviewer.md` - Sub-agente revisor (code review)
- `.mi_suit/skills/sdd-flow/SKILL.md` - Skill para ejecutar flujos SDD

**Dependencias Rust (Cargo.toml):**

```toml
aisdk = { version = "0.5", features = ["openai", "anthropic", "google", "ollama", "prompt", "opentelemetry"] }
tokio = { version = "1", features = ["full"] }
serde = { version = "1", features = ["derive"] }
serde_json = "1"
serde_yaml = "0.9"  # Parseo de frontmatter YAML de agentes/skills
reqwest = { version = "0.12", features = ["json"] }  # WebTool: HTTP client
pulldown-cmark = "0.10"  # Markdown rendering en UI
tracing = "0.1"  # Observabilidad / Logging
walkdir = "2"  # Recorrer directorios de agentes/skills
yew = "0.21"  # o leptos = "0.6"

# Fase 2: State Machines para validación de sub-agentes
# state-machines = "0.9"  # Full-featured con guards asíncronos
# statum = "0.1"         # Alternativa liviana
```

## Interfaces / Contracts

```rust
// AI SDK.rs usa traits propios para providers. Aquí las interfaces del chat:

// Estado del chat
enum ChatStatus {
    Idle,
    Listening,
    Thinking,
    Delegating,
    Working,
    Streaming,
    Error,
}

struct ChatState {
    status: ChatStatus,
    messages: Vec<Message>,
    current_task: Option<Task>,
}

// Mensaje en el chat
struct Message {
    id: String,
    role: MessageRole, // user, assistant, tool
    content: String,
    timestamp: u64,
    tool_calls: Option<Vec<ToolCall>>,
}

// AI SDK.rs Tool - usa el trait Tool y macro #[tool]
// Ejemplo:
// #[tool]
// fn get_weather(location: String) -> Tool {
//     Ok(format!("72°F in {}", location))
// }
//
// let stream = LanguageModelRequest::builder()
//     .model(OpenAI::gpt_5())
//     .prompt("Weather in SF?")
//     .with_tool(get_weather)
//     .build()
//     .stream_text()
//     .await?;

// AI SDK.rs provee estas primitivas:
// - LanguageModelRequest::builder()...stream_text() para streaming
// - generate_text() para respuestas completas
// - with_tool() para agregar herramientas
// - schema::<T>() para structured output (requiere modelo que soporte)
// - DynamicModel para selección de modelo en runtime

// Context Window (manejado internamente por el agente)
struct ContextWindow {
    messages: Vec<Message>,
    max_tokens: usize,
    current_tokens: usize,
}

// Contrato de delegación
struct DelegationContract {
    task_id: String,
    agent_type: AgentType, // architect, coder, reviewer
    objectives: Vec<String>,
    budget: usize,
    deadline: u64,
    on_fail: OnFailStrategy, // retry, escalate, abort
}

// ============================================================
// Sistema de Agentes (OpenCode Pattern + AI SDK.rs)
// ============================================================

// Configuración de un agente (parseada desde .mi_suit/agents/*.md)
struct AgentConfig {
    name: String,
    description: String,
    model: String,              // e.g., "openai/gpt-5"
    max_steps: u32,             // límite de pasos del agente
    tools: Vec<String>,         // herramientas disponibles (read, grep, glob, search, write, bash, etc.)
    subagents: Vec<String>,     // sub-agentes a los que puede delegar (solo Main Agent)
    system_prompt: String,      // contenido después del frontmatter
}

// Enum para tipos de agentes
enum AgentType {
    Main,        // Agente de entrada (único con el que el usuario conversa)
    Architect,   // Diseño y arquitectura
    Coder,       // Implementación
    Reviewer,    // Revisión
    Custom(String), // Skills o agentes personalizados
}

// Configuración de un skill (parseada desde .mi_suit/skills/*/SKILL.md)
struct SkillConfig {
    name: String,
    description: String,
    license: Option<String>,
    compatibility: Option<String>,
    content: String,            // contenido después del frontmatter
}

// Registro de agentes - carga agentes desde archivos .md
trait AgentRegistry {
    fn load_agent(&self, name: &str) -> Result<AgentConfig, AgentError>;
    fn list_agents(&self) -> Vec<AgentConfig>;
    fn load_skill(&self, name: &str) -> Result<SkillConfig, AgentError>;
    fn list_skills(&self) -> Vec<SkillConfig>;
}

// Ejecutor de agentes - usa AI SDK.rs para ejecutar
trait AgentExecutor {
    async fn execute(&self, agent: &AgentConfig, prompt: &str) -> Result<AgentResponse, AgentError>;
    async fn execute_streaming(&self, agent: &AgentConfig, prompt: &str) -> impl Stream<Item = String>;
}

// Ejemplo de uso:
// let registry = FileAgentRegistry::new(".mi_suit/agents");
// let architect = registry.load_agent("architect")?;
// let executor = AisdkAgentExecutor::new();
// let response = executor.execute(&architect, "Diseña un sistema de auth").await?;
```

## Testing Strategy

| Layer       | What to Test                                                          | Approach                   |
| ----------- | --------------------------------------------------------------------- | -------------------------- |
| Unit        | ChatState transitions, ToolRegistry execution, ContextWindow eviction | `cargo test` + `mockall`   |
| Unit        | AI SDK.rs adapters, tool validation                                   | `tokio::test` con mocks    |
| Integration | ChatStore → MainAgent → ToolRegistry flow                             | `cargo test` integration   |
| Integration | Streaming response end-to-end                                         | Tauri test con mock server |
| E2E         | User sends message → sees streamed response                           | Tauri driver + Ollama real |

**Coverage target**: >80% en agent logic y tools. UI tests focus on state transitions.

## Migration / Rollback

No migration required — primera implementación. El rollback plan del proposal:

1. Eliminar `src/apps/ia_chat/`
2. Remover imports del router principal
3. Revertir cambios en `src/shared/`
4. Sin pérdida de datos (no hay persistencia en MVP)

## Open Questions

> **NOTA**: Las siguientes decisiones fueron postergadas para fase posterior al MVP. El diseño debe ser lo suficientemente flexible para acomodarlas sin cambios arquitectónicos mayores.

- [x] **Guardian Integration**: **REEMPLAZADO por FSM (Fase 2)**. Las validaciones del Guardian ahora se implementan mediante guards en las state machines de los sub-agentes.
- [ ] **Editor Engine**: ¿CodeMirror 6 o Monaco? Pending decision (no requerido para MVP inicial).
- [ ] **LLM Model**: ¿Qwen2.5-Coder o DeepSeek-Coder? Pending decision - usar por defecto `ollama/llama3.2` para MVP.
- [ ] **Streaming format**: ¿JSON chunks o texto plano? Depende del provider - usar texto plano por simplicidad.

## Dependencies de otras fases

- **Phase 0 (Tauri)**: Debe completarse antes de implementar este diseño
- **Phase 2 (Sub-agents + State Machines)**: El sistema de agentes requiere validación avanzada de precondiciones/postcondiciones
- **Phase 2 (MCP)**: El ToolRegistry está diseñado para soportar extensibilidad
- **Phase 2 (Input Enhancer)**: La arquitectura permite integración futura sin cambios
- **Phase 2 (Skills UI)**: El SkillRegistry está diseñado para soportar extensión
- **Memoria Atómica**: No es dependencia directa del MVP, pero el ContextManager tiene interface ready

## Scope MVP (Ready to Production)

El **MVP** incluye únicamente las features necesarias para un chat funcional con LLM local:

| Componente                     | Incluido en MVP | Notas                      |
| ------------------------------ | --------------- | -------------------------- |
| Chat UI (estados, streaming)   | ✅              | Completo                   |
| Markdown rendering             | ✅              | Básico (GFM, código)       |
| Main Agent (sin sub-agentes)   | ✅              | Solo lectura/búsqueda      |
| Herramientas (file, grep, web) | ✅              | Sin terminal por seguridad |
| Context Manager                | ✅              | Buffer básico              |
| AI SDK.rs + Ollama             | ✅              | Solo Ollama por defecto    |
| Provider Dashboard             | ⚠️              | Solo selector de modelo    |

**Excluido del MVP** (Fase 2):

- ❌ Sub-agents (architect, coder, reviewer)
- ❌ Skills system
- ❌ Terminal tool (por seguridad)
- ✅ Guardian Integration → **REEMPLAZADO por FSM con guards** (ver sección "Fase 2: State Machines")
- ❌ MCP
- ❌ Input Enhancer
- ❌ Memoria persistente
- ❌ State Machines con guards (ver abajo)

---

## Fase 2: State Machines con Validación de Precondiciones/Postcondiciones

### El problema

En Fase 2, cuando el Main Agent delega a sub-agentes (Architect → Coder → Reviewer), necesitamos validar **condiciones externas** antes de permitir transiciones:

- **Precondiciones**: "Coder tiene worktree aislado", "existe SPEC.md", "el proyecto tiene estructura válida"
- **Postcondiciones**: "Coder creó STRACK.md", "no hay conflictos de git", "todos los tests pasan"
- **Validación asíncrona**: Verificaciones que requieren I/O (filesystem, git, red)

### Solución: `state-machines` crate

**Dependencia propuesta**:

```toml
state-machines = "0.9"
```

**Arquitectura de la máquina de estados para sub-agentes**:

```rust
// Definición de la máquina del Coder
state_machine! {
    name: CoderMachine,
    state: CoderState,
    initial: Idle,
    async: true,  // Necesario para guards asíncronos

    states: [
        Idle,
        Analyzing,      // Analiza la tarea recibida
        Planning,       // Planifica la implementación
        Implementing,   // Escribe código
        Testing,        // Ejecuta tests
        Validating,     // Valida postcondiciones
        Completed,
        Failed(ErrorReason)
    ],

    events: {
        receive_task {
            guards: [has_valid_task_context],  // Precondición
            transition: { from: Idle, to: Analyzing }
        },

        start_implementation {
            guards: [has_spec_file, has_clean_worktree],  // Precondiciones
            transition: { from: Planning, to: Implementing }
        },

        finish_work {
            guards: [has_strategic_markdown, no_git_conflicts],  // Postcondiciones
            transition: { from: Implementing, to: Validating }
        },

        complete {
            transition: { from: Validating, to: Completed }
        }
    },

    callbacks: {
        before_transition [
            { name: log_transition, from: [Implementing], to: [Validating], on: [finish_work] }
        ],
        after_transition [
            { name: cleanup_worktree, on: [complete, fail] }
        ]
    }
}

// Guards asíncronos - validación externa
async fn has_spec_file(ctx: &CoderContext) -> bool {
    ctx.file_exists("SPEC.md") && ctx.spec_is_valid()
}

async fn has_clean_worktree(ctx: &CoderContext) -> bool {
    ctx.git_worktree_status().is_clean()
}

async fn has_strategic_markdown(ctx: &CoderContext) -> bool {
    ctx.file_exists("STRACK.md") && ctx.strategic_md_is_valid()
}

async fn no_git_conflicts(ctx: &CoderContext) -> bool {
    ctx.git_has_conflicts() == false
}
```

### Máquinas de estado por agente

| Agente        | Estados                                                                    | Guards de precondición                   | Guards de postcondición              |
| ------------- | -------------------------------------------------------------------------- | ---------------------------------------- | ------------------------------------ |
| **Architect** | Idle → Analyzing → Designing → Specifying → Completed/Failed               | proyecto existe, tiene estructura válida | SPEC.md creado, válido               |
| **Coder**     | Idle → Analyzing → Planning → Implementing → Validating → Completed/Failed | worktree limpio, SPEC existe             | STRACK.md creado, sin conflictos git |
| **Reviewer**  | Idle → Analyzing → Reviewing → Verified → Failed                           | código compilable, tests existen         | coverage >80%, sin issues críticos   |

### Beneficios

1. **Compile-time safety**: Transiciones inválidas son errores de compilación
2. **Validación automática**: Guards se ejecutan antes de cada transición
3. **Callbacks para auditoría**: Logging automático de cada transición
4. **Async completo**: Guards pueden hacer I/O (git, filesystem, HTTP)
5. **Debugging mejorado**: Cada transición es explícita y rastreable

### Alternativa liviana: `statum`

Si el overhead de `state-machines` es excesivo, usar `statum` con guards manuales:

```rust
impl Machine<Coding> {
    fn try_finish(self) -> Result<Machine<Completed>, CoderError> {
        if self.ctx.spec_exists() && self.ctx.worktree_is_clean() {
            Ok(self.finish())
        } else {
            Err(CoderError::PreconditionFailed(
                "SPEC.md no existe o worktree no está limpio".into()
            ))
        }
    }
}
```

**Dependencia**: `statum = "0.1"`

> **Decisión pendiente**: Elegir entre `state-machines` (full-featured) o `statum` (liviano) basándose en complejidad real de los flujos de Fase 2.
