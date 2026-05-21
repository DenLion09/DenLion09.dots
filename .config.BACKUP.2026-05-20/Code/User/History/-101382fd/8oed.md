# Spec Validaciones Chat LLM

## 1. Propósito

Define el sistema de validaciones complejas para el flujo de mensajería bidireccional entre el usuario, el Main (orquestador), subagentes y el Headless Guardian. Cubre las validaciones que el spec `05-headless-guardian.md` marca como **pendientes en la sección 5.8** y que el spec `03-ui-chat-ia.md` requiere para los estados DELEGATING, WORKING y STREAMING.

### 1.1 Alcance

Este spec cubre **4 dominios** que el Guardian actual no aborda:

| Dominio                  | Qué valida                                      | Ejemplo                                                   |
| ------------------------ | ----------------------------------------------- | --------------------------------------------------------- |
| **Mensajería proactiva** | Mensajes no solicitados del Main al usuario     | "Delegando al agente Coder...", "Progreso: 3/5 subtareas" |
| **Streaming en vivo**    | Tokens que llegan incrementalmente              | Respuesta del LLM mostrándose token a token               |
| **Delegaciones**         | Tareas enviadas a subagentes y sus resultados   | Contrato de delegación, resultado validado por schema     |
| **Contexto post-flush**  | Estado de validaciones después de Context Flush | ¿Qué subtareas ya se validaron? ¿Cuáles fallaron?         |

### 1.2 Relación con otros specs

```
┌────────────────────────────────────────────────────────────┐
│  spec/03 (UI Chat)        spec/05 (Headless Guardian)      │
│  Define:                      Define:                      │
│  - IPC commands              - Input/Output Guards          │
│  - UI estados                - Code/Security/Loop Guards    │
│  - Tipos de mensaje          - Chat Output Validator (5.8)  │
│  - Flujo delegación          - Spec Enforcer                │
│                               ↓                             │
│                    ┌──────────────────┐                     │
│                    │  ESTE SPEC (06)  │ ← Puente entre 03 y 05
│                    │                  │                     │
│                    │ - Streaming val  │                     │
│                    │ - Delegation ctx │                     │
│                    │ - Proactive msgs │                     │
│                    │ - Post-flush     │                     │
│                    └──────────────────┘                     │
└────────────────────────────────────────────────────────────┘
```

---

## 2. Terminología

| Término                      | Definición                                                                                                            |
| ---------------------------- | --------------------------------------------------------------------------------------------------------------------- |
| **Guardrail**                | Regla de validación que se ejecuta en un punto del pipeline (input, output, tool, delegation)                         |
| **Tripwire**                 | Umbral que, al activarse, bloquea o rechaza el mensaje/acción                                                         |
| **Delegation Contract**      | Acuerdo estructurado entre Main y subagente con objetivos, presupuesto, deadline y política de fallo                  |
| **Verification Status**      | Nivel de confianza en un resultado: `unverified`, `self_verified`, `peer_verified`, `tool_verified`, `human_verified` |
| **Artefacto Durable**        | Datos persistidos fuera del contexto del LLM que sobreviven al Context Flush                                          |
| **Buffer-and-Release**       | Patrón de streaming que acumula N tokens, valida, y libera si pasa                                                    |
| **Write Outside the Window** | Patrón que genera un resumen estructurado antes del flush para restaurar después                                      |
| **Context Provider**         | Componente que inyecta datos dinámicos (estado, historial, validaciones) en el prompt del agente                      |

---

## 3. Requisitos

### 3.1 Requisitos de Mensajería Proactiva

| ID          | Requisito                                                                                                                                                | Prioridad |
| ----------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- | --------- |
| **MSG-001** | Todo mensaje proactivo del Main al usuario **DEBE** pasar por Output Guardrails antes de llegar al chat                                                  | MUST      |
| **MSG-002** | Los mensajes de estado proactivos (delegación, progreso) **DEBEN** incluir un `message_type` estructurado (`delegation`, `progress`, `status`, `result`) | MUST      |
| **MSG-003** | Si un mensaje proactivo falla validación, el sistema **DEBE** reintentar hasta 2 veces con feedback estructurado                                         | MUST      |
| **MSG-004** | Si todos los reintentos fallan, el sistema **DEBE** enviar un mensaje fallback seguro al usuario                                                         | MUST      |
| **MSG-005** | El validador de heartbeat **DEBE** detectar respuestas vacías o genéricas (`HEARTBEAT_OK`) sin trabajo real asociado                                     | SHOULD    |
| **MSG-006** | El sistema **PUEDE** hacer preguntas clarificadoras al usuario antes de actuar (patrón AskUserQuestion)                                                  | MAY       |

### 3.2 Requisitos de Streaming

| ID          | Requisito                                                                                                                                                  | Prioridad |
| ----------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- | --------- |
| **STR-001** | El sistema **DEBE** soportar 3 niveles de validación de streaming: Buffer-and-Release, Stream+Post-Hoc, Non-Streaming                                      | MUST      |
| **STR-002** | La estrategia de streaming **DEBE** ser configurable por nivel de riesgo del contenido                                                                     | MUST      |
| **STR-003** | En modo Buffer-and-Release, el buffer **DEBE** acumular entre 50-100 tokens (~1-2 oraciones) antes de validar                                              | MUST      |
| **STR-004** | El sistema **NO DEBE** validar token individual en streaming — la unidad mínima de validación es la oración                                                | MUST      |
| **STR-005** | Para respuestas JSON estructuradas en streaming, el sistema **DEBE** validar solo cuando el fragmento sea JSON estructuralmente completo                   | MUST      |
| **STR-006** | El sistema **DEBE** exponer `error_spans_in_output` para trackear rangos de texto que fallaron validación                                                  | SHOULD    |
| **STR-007** | El sistema **NO DEBE** soportar `reask` (re-prompt) durante streaming — solo post-completado                                                               | MUST      |
| **STR-008** | Si se detecta contenido bloqueado en streaming, el sistema **DEBE** retornar error estructurado: `{type: "guardrails_violation", code: "content_blocked"}` | MUST      |

### 3.3 Requisitos de Delegación

| ID          | Requisito                                                                                                                                   | Prioridad |
| ----------- | ------------------------------------------------------------------------------------------------------------------------------------------- | --------- |
| **DEL-001** | Toda delegación a subagente **DEBE** incluir un Delegation Contract con: objetivos, presupuesto, deadline, fail_policy                      | MUST      |
| **DEL-002** | Los resultados de subagentes **DEBEN** validarse contra schema antes de cruzar al contexto del padre                                        | MUST      |
| **DEL-003** | Los subagentes **DEBEN** operar en contexto aislado — datos raw no entran en memoria del Main                                               | MUST      |
| **DEL-004** | Las llamadas a tools con side effects dentro de subagentes **DEBEN** pasar por validador gating                                             | MUST      |
| **DEL-005** | Todo resultado de subagente **DEBE** incluir `verification_status` y `lineage_chain`                                                        | MUST      |
| **DEL-006** | Si un subagente falla, el sistema **DEBE** comunicar el error con `LdpError` estructurado (categoría, severidad, retryable, partial_output) | MUST      |
| **DEL-007** | El sistema **DEBE** soportar fallback automático de payload mode si la validación de schema falla                                           | SHOULD    |
| **DEL-008** | El sistema **PUEDE** soportar delegación recursiva (subagente crea sub-subagente)                                                           | MAY       |

### 3.4 Requisitos de Contexto y Post-Flush

| ID          | Requisito                                                                                                                                                                 | Prioridad |
| ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------- |
| **CTX-001** | El validador **DEBE** recibir contexto con presupuesto limitado (~32K caracteres)                                                                                         | MUST      |
| **CTX-002** | El contexto del validador **DEBE** colocar información crítica al INICIO y FINAL del prompt (mitigar "Lost in the Middle")                                                | MUST      |
| **CTX-003** | El historial de conversación **DEBE** tener un límite duro de tokens antes de compresión                                                                                  | MUST      |
| **CTX-004** | Las interacciones previas **DEBEN** aplicar decaimiento temporal: >90d excluir, 30-90d resumen, <30d completo                                                             | SHOULD    |
| **CTX-005** | Los resultados de validación **DEBEN** persistirse como artefactos durables separados del historial de chat                                                               | MUST      |
| **CTX-006** | Después de un Context Flush, el sistema **DEBE** restaurar el estado de validaciones previas vía Context Provider                                                         | MUST      |
| **CTX-007** | El patrón Write Outside the Window **DEBE** generar un resumen de handoff antes del flush que incluya: subtareas validadas, validaciones fallidas, compromisos pendientes | MUST      |
| **CTX-008** | Las validaciones fallidas **DEBEN** almacenarse con: categoría de fallo, severidad, retryable flag, partial_output, evidencia                                             | MUST      |

---

## 4. Arquitectura de Validación

### 4.1 Pipeline Completo

```
┌─────────────────────────────────────────────────────────────────────┐
│                         PIPELINE DE VALIDACIÓN                      │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  [USUARIO]                                                          │
│      │                                                              │
│      ▼                                                              │
│  ┌─────────────────────────┐                                        │
│  │ 1. INPUT GUARDRAILS     │ ← spec/05 §5.1                        │
│  │    • Moderación         │                                        │
│  │    • Inyección          │                                        │
│  │    • Longitud (10KB)    │                                        │
│  │    • Rate limiting      │                                        │
│  └──────────┬──────────────┘                                        │
│             ▼                                                       │
│  ┌─────────────────────────┐                                        │
│  │ 2. MAIN ANALYSIS        │ ← spec/03 §7.2                        │
│  │    • Planificación      │                                        │
│  │    • Delegación         │                                        │
│  └──┬───────────────────┬──┘                                        │
│     │                   │                                           │
│     ▼                   ▼                                           │
│  ┌──────────────┐  ┌──────────────────────────────┐                 │
│  │ 3a. DIRECT   │  │ 3b. DELEGATION GUARDRAILS   │ ← ESTE SPEC     │
│  │     RESPONSE │  │    • Contract validation     │                 │
│  │              │  │    • Schema enforcement      │                 │
│  │              │  │    • Subagent isolation      │                 │
│  └──┬───────────┘  └──────────┬───────────────────┘                 │
│     │                         │                                     │
│     │     ┌───────────────────┘                                     │
│     │     ▼                                                         │
│     │  ┌─────────────────────────┐                                  │
│     │  │ 4. SUBAGENT EXECUTION   │                                  │
│     │  │    • Contexto aislado   │                                  │
│     │  │    • Tool gating        │                                  │
│     │  │    • Schema results     │                                  │
│     │  └──────────┬──────────────┘                                  │
│     │             │                                                 │
│     │             ▼                                                 │
│     │  ┌─────────────────────────┐                                  │
│     │  │ 5. STREAMING VALIDATION │ ← ESTE SPEC                     │
│     │  │    • Buffer & Release   │                                  │
│     │  │    • Chunk validation   │                                  │
│     │  │    • Error spans        │                                  │
│     │  └──────────┬──────────────┘                                  │
│     │             │                                                 │
│     ▼             ▼                                                 │
│  ┌─────────────────────────────────┐                                │
│  │ 6. OUTPUT GUARDRAILS            │ ← spec/05 §5.2, §5.8          │
│  │    • PII detection              │                                │
│  │    • Sensitive data filter      │                                │
│  │    • Tone/coherence check       │                                │
│  │    • Repetition/hallucination   │                                │
│  └──────────┬──────────────────────┘                                │
│             ▼                                                       │
│  ┌─────────────────────────┐                                        │
│  │ 7. CACHE (post-valid)   │ ← Regla: validar ANTES de cachear     │
│  └──────────┬──────────────┘                                        │
│             ▼                                                       │
│  ┌─────────────────────────┐                                        │
│  │ 8. CHAT (frontend)      │ ← spec/03 §4.2                        │
│  │    • Mensaje validado   │                                        │
│  │    • Estado UI actualizado│                                       │
│  └─────────────────────────┘                                        │
│                                                                     │
│  ┌─────────────────────────────────────────────────────┐            │
│  │  DURANTE TODO EL PIPELINE:                          │            │
│  │  • LOOP SENTINEL (spec/05 §5.5)                     │            │
│  │  • AGENT COMM MANAGER (spec/05 §5.9)               │            │
│  │  • CONTEXT BUDGET TRACKER                           │            │
│  └─────────────────────────────────────────────────────┘            │
└─────────────────────────────────────────────────────────────────────┘
```

### 4.2 Orden de Ejecución de Middleware

```
[INPUT] → [RateLimit] → [Auth] → [InputValidation] → [Logging]
     → [LLM CALL / DELEGATION]
     → [OutputValidation] → [Caching] → [OUTPUT]
```

**Regla de oro**: Validar ANTES de cachear. Cachear respuestas no validadas es un anti-patrón.

### 4.3 Validaciones rápidas primero, costosas después

El orden dentro de cada capa de guardrails sigue la regla de **early exit**:

```
Capa de Output Validation:
  1. Longitud (fast: string.length)
  2. Patrones simples (fast: regex para secrets, PII básico)
  3. Estructura/schema (medium: JSON parse, schema validation)
  4. Coherencia (expensive: LLM judge o NLP)
  5. Repetición/hallucinación (expensive: análisis estadístico)
```

Cualquier fallo detiene la cadena inmediatamente.

---

## 5. Streaming Validation Specification

### 5.1 Niveles de Riesgo y Estrategia

| Nivel              | Escenario                                  | Estrategia        | Latencia adicional | Seguridad             |
| ------------------ | ------------------------------------------ | ----------------- | ------------------ | --------------------- |
| **Tier 1** (bajo)  | Chat interno, desarrollo                   | Stream + Post-Hoc | 0ms                | Retracta si falla     |
| **Tier 2** (medio) | Chat con usuarios finales, código generado | Buffer & Release  | +200-500ms         | Pre-entrega por chunk |
| **Tier 3** (alto)  | Acciones con side effects, datos regulados | Non-Streaming     | 3-30s              | Evaluación completa   |

### 5.2 Patrón Buffer-and-Release

```
┌─────────┐    tokens     ┌──────────┐   validate   ┌──────────┐
│  LLM    │ ──────────►   │  Buffer  │ ──────────►  │ Release  │
│ Stream  │    (50-100)   │ (queue)  │   (sentence) │  or      │
│         │    tokens     │          │              │ Block    │
└─────────┘               └──────────┘              └──────────┘
```

**Algoritmo:**

1. Acumular tokens en buffer hasta alcanzar 50-100 tokens O detectar fin de oración
2. Ejecutar guardrails rápidos sobre el buffer (longitud, patrones, PII)
3. Si pasa → liberar buffer al frontend y limpiar
4. Si falla → reemplazar buffer con mensaje seguro y registrar error span
5. Si timeout (>500ms sin oración completa) → liberar buffer actual (trade-off seguridad/latencia)

### 5.3 Patrón Stream + Post-Hoc

```
┌─────────┐    tokens     ┌──────────┐
│  LLM    │ ──────────►   │ Frontend │  (usuario ve en tiempo real)
│ Stream  │               │          │
└─────────┘               └──────────┘
     │                         ▲
     │ full response           │ retraction
     ▼                         │
┌──────────┐   evaluate   ┌──────────┐
│ Post-Hoc │ ──────────► │ Retract  │ (si falla)
│ Evaluator│             │ Warning  │
└──────────┘             └──────────┘
```

**Algoritmo:**

1. Stream tokens al frontend inmediatamente
2. Cuando el stream completa, evaluar respuesta completa
3. Si pasa → log como validado
4. Si falla → enviar mensaje de retracción al frontend con ID de respuesta
5. El frontend reemplaza/marca el contenido como "revisado"

### 5.4 Validación de JSON Estructurado en Streaming

Para respuestas que deben ser JSON (delegation results, structured outputs):

```
Token stream → [StreamParser] → Buffer JSON
                                    │
                           IsComplete? ──► No → seguir acumulando
                                    │
                                   Yes
                                    │
                           [JSON Schema Validate]
                                    │
                              Valid? ──► No → error + retry
                                    │
                                   Yes
                                    │
                              [Emit result]
```

**Reglas:**

- JSON incompleto NO es error — se bufferiza hasta completitud
- Siempre verificar `IsComplete` antes de usar el resultado
- `err == nil` solo significa "sin parse error aún", no "completo"
- Resetear el parser antes de cada nuevo stream

### 5.5 Error Spans en Streaming

El sistema mantiene un registro de rangos de texto que fallaron validación:

```typescript
interface ErrorSpans {
  response_id: string;
  spans: Array<{
    start: number; // posición de inicio en el texto acumulado
    end: number; // posición de fin
    reason: string; // "pii_detected", "injection", "repetition"
    action: "blocked" | "filtered" | "replaced";
    replacement?: string;
  }>;
  is_final: boolean; // true cuando el stream completó
}
```

---

## 6. Delegation Contract Specification

### 6.1 Schema del Contrato

```typescript
interface DelegationContract {
  // Identificación
  contract_id: string; // UUID único
  parent_agent: string; // ID del agente que delega
  subagent_id: string; // ID del subagente
  created_at: string; // RFC3339

  // Objetivo
  objective: string; // Descripción clara del resultado esperado
  success_criteria: string[]; // Criterios medibles de éxito

  // Límites
  budget: {
    max_tokens: number; // Máximo tokens de contexto + output
    max_time_ms: number; // Timeout en milisegundos
    max_tool_calls: number; // Límite de llamadas a herramientas
  };

  // Política de fallo
  fail_policy: "fail_closed" | "fail_open";
  // fail_closed: rechaza resultado, retorna error tipado + partial_output
  // fail_open: acepta resultado pero loggea violación

  // Contexto
  context_snapshot: string[]; // IDs de artefactos de contexto relevantes
  // (NO el contenido completo — el subagente carga desde memoria)

  // Payload mode negociado
  payload_mode: "text" | "semantic_frame" | "structured_json";

  // Trust
  trust_domain: string; // Dominio de seguridad
  required_verification: VerificationLevel;
}

type VerificationLevel =
  | "unverified"
  | "self_verified"
  | "peer_verified"
  | "tool_verified"
  | "human_verified";
```

### 6.2 Schema del Resultado

```typescript
interface DelegationResult {
  contract_id: string; // Referencia al contrato
  status: "success" | "failed" | "partial" | "timeout" | "budget_exceeded";

  // Output
  output: string; // Resultado del subagente
  output_schema_valid: boolean; // ¿Pasó validación de schema?
  partial_output?: string; // Output parcial si falló

  // Verificación
  verification_status: VerificationLevel;
  verification_evidence?: string[]; // Referencias a evidencia
  lineage_chain: string[]; // IDs de subagentes involucrados

  // Costo
  cost: {
    tokens_used: number;
    time_ms: number;
    tool_calls: number;
  };

  // Errores
  error?: LdpError;
}

interface LdpError {
  category: "validation" | "timeout" | "budget" | "schema" | "tool" | "unknown";
  severity: "critical" | "high" | "medium" | "low";
  retryable: boolean;
  message: string;
  partial_output?: string;
}
```

### 6.3 Flujo de Delegación con Validación

```
┌──────────────┐
│  MAIN        │
│  (Orquestador)│
└──────┬───────┘
       │
       │ 1. Crear DelegationContract
       │    con objetivos, budget, fail_policy
       ▼
┌──────────────────────┐
│  DELEGATION GUARD    │ ← Valida el contrato antes de enviar
│  • Budget razonable? │
│  • Objetivos claros? │
│  • Trust domain ok?  │
└──────┬───────────────┘
       │ 2. Contract válido → enviar
       ▼
┌──────────────────────┐
│  SUBAGENT            │ ← Contexto aislado
│  • Ejecuta tarea     │
│  • Tools con gating  │
│  • Genera resultado  │
└──────┬───────────────┘
       │ 3. Resultado raw
       ▼
┌──────────────────────┐
│  RESULT VALIDATOR    │
│  • Schema validation │
│  • Success criteria  │
│  • Budget check      │
│  • Timeout check     │
└──────┬───────────────┘
       │
  Pass?├────── Yes ────────────────► Set verification_status
       │                            │
       │ No                         ▼
       │                     ┌──────────────┐
       │                     │ fail_policy? │
       │                     └──────┬───────┘
       │                            │
       │               fail_closed ─┤
       │                            │    ┌─────────────────┐
       │               fail_open ───┤───►│ Accept + log    │
       │                            │    │ violation       │
       ▼                            │    └─────────────────┘
┌──────────────┐                    │
│ LdpError     │                    │
│ tipificado   │                    │
└──────┬───────┘                    │
       │                            │
       └────────────────────────────┘
       │
       ▼
┌──────────────┐
│ MAIN recibe  │
│ resultado    │
│ validado     │
└──────────────┘
```

---

## 7. Context Management Specification

### 7.1 Budget de Contexto del Validador

El validador recibe contexto con un presupuesto máximo de ~32K caracteres, ordenado para mitigar el efecto "Lost in the Middle":

```
┌─────────────────────────────────────────────┐
│ INICIO (crítico)                            │
│ • Instrucciones del sistema                 │
│ • Criterios de validación                   │
│ • Reglas de fallo                           │
├─────────────────────────────────────────────┤
│ MEDIO                                       │
│ • Historial de conversación (comprimido)    │
│ • Contexto de subtareas previas             │
│ • Datos del usuario (perfil)                │
├─────────────────────────────────────────────┤
│ FINAL (crítico)                             │
│ • Input a validar                           │
│ • Schema esperado                           │
│ • Formato de respuesta requerido            │
└─────────────────────────────────────────────┘
```

### 7.2 Gestión de Historial con Decaimiento Temporal

| Antigüedad                  | Tratamiento                          | Ejemplo                                   |
| --------------------------- | ------------------------------------ | ----------------------------------------- |
| **Actual** (turnos activos) | Completo, verbatim                   | Los últimos 15 pares de mensajes          |
| **<30 días**                | Hechos clave directamente            | "Usuario pidió auth JWT el 15/04"         |
| **30-90 días**              | Resumen breve                        | "Prior contact Feb 2026: login, resolved" |
| **>90 días**                | Excluir (salvo referencia explícita) | N/A                                       |

### 7.3 Context Providers

Los Context Providers inyectan datos dinámicos en el pipeline:

| Provider                        | Qué inyecta                                                 | Cuándo                             |
| ------------------------------- | ----------------------------------------------------------- | ---------------------------------- |
| **ValidationStateProvider**     | Estado de validaciones previas (pass/fail, error spans)     | Al reconstruir contexto post-flush |
| **SubtaskContextProvider**      | Resultados de subtareas completadas con verification_status | Antes de delegar nueva subtarea    |
| **ConversationHistoryProvider** | Historial comprimido con decaimiento temporal               | En cada turno del chat             |
| **UserProfileProvider**         | Datos del usuario relevantes para validación                | Al inicio de sesión + cambios      |
| **DurableArtifactProvider**     | Artefactos Write Outside the Window restaurados             | Post-flush, pre-nueva tarea        |

### 7.4 Write Outside the Window (Pre-Flush)

Antes de cada Context Flush, el sistema **DEBE** generar un artefacto durable:

```typescript
interface FlushHandoffArtifact {
  artifact_id: string;
  created_at: string; // RFC3339
  task_id: string; // Tarea que se completa

  // Subtareas
  completed_subtasks: Array<{
    subtask_id: string;
    status: "validated" | "failed" | "skipped";
    verification_status: VerificationLevel;
    files_created: string[];
    validation_errors?: string[];
  }>;

  // Validaciones
  validation_summary: {
    total_validations: number;
    passed: number;
    failed: number;
    failed_details: Array<{
      category: string;
      severity: string;
      partial_output?: string;
      evidence?: string[];
    }>;
  };

  // Compromisos
  pending_commitments: string[]; // "Se prometió implementar tests"
  warnings: string[]; // Warnings que el usuario debe conocer

  // Contexto para la próxima tarea
  next_task_context: string; // Resumen comprimido para el reload
}
```

---

## 8. Mensajería Proactiva Specification

### 8.1 Tipos de Mensajes Proactivos

| Tipo              | Descripción                        | Validación requerida             | Ejemplo IPC                                     |
| ----------------- | ---------------------------------- | -------------------------------- | ----------------------------------------------- |
| **status**        | Cambio de estado del Main          | Output Guard rápido              | `chat:status` → `THINKING`                      |
| **delegation**    | Notificación de subagente delegado | Contract validation              | `chat:delegation` → "Agente Coder: auth/jwt.go" |
| **progress**      | Progreso de subtarea               | Budget + schema check            | `agent:progress` → "3/5 subtareas"              |
| **result**        | Resultado de subtarea completada   | Full output guardrails           | `chat:message` → resultado                      |
| **heartbeat**     | Check de actividad del agente      | Heartbeat validator              | Interno, no al usuario                          |
| **clarification** | Pregunta al usuario                | Input Guard al recibir respuesta | `chat:action` → opciones                        |

### 8.2 Validación de Heartbeat

El heartbeat validator detecta agentes que reportan actividad sin trabajo real:

```
Heartbeat收到 → [Heartbeat Validator]
                     │
                     │ Check: ¿hay trabajo asociado?
                     │   - ¿Subtareas pendientes?
                     │   - ¿Tools llamadas recientemente?
                     │   - ¿Contexto cambió?
                     │
              Trabajo?├──── Yes ──► HEARTBEAT_OK → continuar
                     │
                     │ No
                     ▼
              [ALERT: Lazy heartbeat]
              • Log como anomalía
              • Incrementar counter
              • Si counter > threshold → escalar
```

### 8.3 IPC Commands Nuevos (extienden spec/03 §7.3)

```
// Main → Frontend (nuevos para validación)
"chat:validation:status"  → Estado de validación (pass/fail/partial)
"chat:validation:error"   → Error de validación con detalles
"chat:retraction"          → Retractar mensaje anterior (stream post-hoc falló)
"chat:clarification"       → Pregunta al usuario con opciones

// Guardian → Main (nuevos)
"guard:stream:chunk_valid"   → Chunk de streaming validado
"guard:stream:chunk_blocked" → Chunk bloqueado con error span
"guard:delegation:result"    → Resultado de delegación validado
"guard:context:restore"      → Contexto restaurado post-flush con validaciones
```

---

## 9. Integración con Memoria Atómica

> **Nota:** La especificación completa del Sistema de Memoria Atómica se encuentra en **`specs/07-sistema-memoria-atomica.md`**. Esta sección describe los puntos de integración específicos para validaciones.

### 9.1 Modelo de Persistencia

Las validaciones se gestionan como **artefactos externos** al contexto del LLM:

```
┌────────────────────────────────────────────────────┐
│                 MEMORIA ATÓMICA                    │
├────────────────────────────────────────────────────┤
│                                                    │
│  ┌─────────────┐  ┌─────────────┐  ┌────────────┐ │
│  │ Subtareas   │  │Validaciones │  │ Artefactos │ │
│  │             │  │             │  │ Durables   │ │
│  │ • ID        │  │ • ID        │  │ • Flush    │ │
│  │ • Objetivo  │  │ • Tipo      │  │   Handoff  │ │
│  │ • Estado    │  │ • Resultado │  │ • Contract │ │
│  │ • Archivos  │  │ • Evidence  │  │   Results  │ │
│  │ • Timestamp │  │ • Status    │  │ • Context  │ │
│  └─────────────┘  └─────────────┘  └────────────┘ │
│                                                    │
│  Los artefactos persisten independientemente       │
│  del contexto del LLM y sobreviven al flush.      │
└────────────────────────────────────────────────────┘
```

### 9.2 Ciclo de Vida de una Validación

```
1. Main delega subtarea → crea DelegationContract
     ↓
2. Subagente ejecuta → genera resultado
     ↓
3. Result Validator valida → crea ValidationArtifact
     ↓
4. ValidationArtifact se persiste en Memoria Atómica
     ↓
5. Main recibe resultado validado → muestra en chat
     ↓
6. Context Flush → genera FlushHandoffArtifact
     ↓
7. Reload → Context Providers restauran estado de validaciones
     ↓
8. Siguiente tarea → conoce validaciones previas
```

### 9.3 Validaciones Fallidas

Cuando una validación falla, el sistema **NO** descarta el resultado — lo persiste con contexto:

```typescript
interface FailedValidationRecord {
  record_id: string;
  timestamp: string;
  validation_type: "input" | "output" | "streaming" | "delegation" | "tool";

  // Qué falló
  failed_content: string; // Contenido que falló (sanitized)
  failure_category: string; // Categoría del fallo
  failure_severity: "critical" | "high" | "medium" | "low";

  // Contexto
  contract_id?: string; // Si fue delegación
  subtask_id?: string; // Si fue subtarea
  error_spans?: ErrorSpans; // Si fue streaming

  // Recovery
  retryable: boolean;
  retry_count: number;
  max_retries: number;
  partial_output?: string; // Lo que sí fue válido
  evidence?: string[]; // Referencias a evidencia

  // Resolución
  resolved: boolean;
  resolution?: "auto_fixed" | "manual_override" | "discarded" | "escalated";
  resolved_at?: string;
}
```

---

## 10. State Machine de Validación

### 10.1 Estados de una Validación

```
                    ┌─────────────┐
                    │  PENDING    │ ← Validación programada
                    └──────┬──────┘
                           │ execute
                           ▼
                    ┌─────────────┐
             pass ──►│  RUNNING    │◄── retry
                    └──────┬──────┘
                           │
              ┌────────────┼────────────┐
              ▼            ▼            ▼
       ┌──────────┐ ┌──────────┐ ┌──────────┐
       │  PASSED  │ │  FAILED  │ │ TIMEOUT  │
       └────┬─────┘ └────┬─────┘ └────┬─────┘
            │            │            │
            │     retryable?├── Yes ───┤
            │            │            │
            │            │ No         │
            │            ▼            │
            │     ┌──────────┐        │
            │     │ BLOCKED  │        │
            │     └────┬─────┘        │
            │          │              │
            │     policy?├── fail_open│
            │          │              │
            │     fail_closed         │
            │          │              │
            ▼          ▼              ▼
       ┌─────────────────────────────────┐
       │        PERSISTED                │ ← Artefacto durable
       └─────────────────────────────────┘
```

### 10.2 Transiciones por Tipo

| Desde   | Evento      | A         | Condición                              |
| ------- | ----------- | --------- | -------------------------------------- |
| PENDING | execute     | RUNNING   | Validación inicia                      |
| RUNNING | check_pass  | PASSED    | Todos los guardrails pasan             |
| RUNNING | check_fail  | FAILED    | Algún guardrail activa tripwire        |
| RUNNING | timeout     | TIMEOUT   | Excede tiempo máximo                   |
| FAILED  | retry       | RUNNING   | retryable=true AND retry_count < max   |
| FAILED  | no_retry    | BLOCKED   | retryable=false OR max retries reached |
| TIMEOUT | retry       | RUNNING   | retryable=true AND retry_count < max   |
| TIMEOUT | no_retry    | BLOCKED   | retryable=false OR max retries reached |
| BLOCKED | fail_open   | PASSED    | fail_policy="fail_open" (accept + log) |
| BLOCKED | fail_closed | BLOCKED   | fail_policy="fail_closed" (reject)     |
| PASSED  | persist     | PERSISTED | Siempre                                |
| BLOCKED | persist     | PERSISTED | Siempre (con failed record)            |
| TIMEOUT | persist     | PERSISTED | Siempre (con failed record)            |

---

## 11. Criterios de Aceptación

### 11.1 Mensajería Proactiva

- [ ] **AC-001**: Todo mensaje enviado al chat pasa por al menos 1 output guardrail antes de mostrarse
- [ ] **AC-002**: Un mensaje proactivo que falla validación se reintenta (máx 2) y si persiste, muestra fallback seguro
- [ ] **AC-003**: El heartbeat validator detecta cuando un agente reporta `OK` sin trabajo real (falso positivo < 5%)
- [ ] **AC-004**: Los mensajes de tipo `delegation` incluyen contract_id y subagent_id verificables

### 11.2 Streaming

- [ ] **AC-005**: En modo Buffer-and-Release, la latencia adicional no excede 500ms por chunk
- [ ] **AC-006**: En modo Stream+Post-Hoc, la retracción se aplica al frontend en < 2s post-evaluación
- [ ] **AC-007**: JSON streaming valida solo fragmentos estructuralmente completos (no produce parse errors)
- [ ] **AC-008**: Content blocked en streaming retorna error `{type: "guardrails_violation", code: "content_blocked"}` en < 100ms

### 11.3 Delegación

- [ ] **AC-009**: Todo subagente recibe un DelegationContract con objetivos, budget y fail_policy antes de ejecutar
- [ ] **AC-010**: Los resultados de subagentes que no pasan schema validation son rechazados (fail_closed) o loggeados (fail_open)
- [ ] **AC-011**: Los subagentes operan con contexto aislado — no acceden a memoria del Main directamente
- [ ] **AC-012**: Tool calls con side effects en subagentes pasan por validador gating antes de ejecutar
- [ ] **AC-013**: Todo resultado incluye verification_status y lineage_chain
- [ ] **AC-014**: Errores de subagente se comunican como LdpError estructurado (no strings libres)

### 11.4 Contexto y Post-Flush

- [ ] **AC-015**: El contexto del validador no excede ~32K caracteres
- [ ] **AC-016**: Información crítica (instrucciones, criterios) está al inicio y final del prompt del validador
- [ ] **AC-017**: Historial de conversación se comprime cuando excede límite configurado
- [ ] **AC-018**: FlushHandoffArtifact se genera antes de cada Context Flush
- [ ] **AC-019**: Post-flush, los Context Providers restauran estado de validaciones previas
- [ ] **AC-020**: Validaciones fallidas persisten con categoría, severidad, retryable flag y evidencia

---

## 12. Configuración

### 12.1 Variables de Entorno

```bash
# Streaming
STREAMING_STRATEGY="buffer_and_release"  # buffer_and_release | stream_post_hoc | non_streaming
STREAMING_BUFFER_SIZE=75                 # Tokens por buffer (50-100)
STREAMING_BUFFER_TIMEOUT_MS=500          # Timeout máximo por buffer

# Delegación
DELEGATION_DEFAULT_FAIL_POLICY="fail_closed"
DELEGATION_MAX_RETRIES=2
DELEGATION_DEFAULT_MAX_TOKENS=4096
DELEGATION_DEFAULT_TIMEOUT_MS=30000

# Contexto
VALIDATOR_CONTEXT_MAX_CHARS=32000
HISTORY_MAX_TURNS=15
HISTORY_COMPACT_THRESHOLD=10

# Heartbeat
HEARTBEAT_LAZY_THRESHOLD=3               # Alert después de N heartbeats sin trabajo
```

### 12.2 Config YAML

```yaml
validation:
  streaming:
    strategy: buffer_and_release
    buffer_size: 75
    buffer_timeout_ms: 500
    fast_checks_first: true

  delegation:
    default_fail_policy: fail_closed
    max_retries: 2
    default_budget:
      max_tokens: 4096
      max_time_ms: 30000
      max_tool_calls: 20

  context:
    validator_max_chars: 32000
    history_max_turns: 15
    compact_threshold: 10
    temporal_decay:
      recent_days: 30 # Incluir completo
      summary_days: 90 # Incluir resumen
      exclude_days: 90 # Excluir

  heartbeat:
    lazy_threshold: 3
    check_interval_ms: 5000
```

---

## 13. Referencias

### Specs relacionados

- `specs/03-ui-chat-ia.md` — Chat IA (IPC commands, estados UI, flujo de delegación)
- `specs/05-headless-guardian.md` — Headless Guardian (Input/Output Guards, Chat Output Validator §5.8)

### Fuentes de investigación

- **Guardrails AI** — Streaming validation patterns
- **AIRuntimeSecurity** — Buffer & Release, Stream + Post-Hoc, Non-Streaming tiers
- **LDP Protocol** — Delegation contracts, typed failures, attested identity
- **AgentSys (arXiv 2602.07398)** — Hierarchical memory isolation
- **Externalization in LLM Agents (arXiv 2604.08224)** — Harness Engineering
- **openclaw PR #21832** — Self-verification loop with full-context
- **ContextPatterns** — Context budget, temporal decay, Write Outside the Window
- **Pedantigo** — StreamParser for incremental JSON
- **CallSphere** — Multi-layer guardrails, hierarchical handoffs

---

## 14. Historial de Cambios

| Fecha      | Cambio                                              | Autor |
| ---------- | --------------------------------------------------- | ----- |
| 2026-05-01 | Spec inicial basado en investigación de 20+ fuentes | —     |
