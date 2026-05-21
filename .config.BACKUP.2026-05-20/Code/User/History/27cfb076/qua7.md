# CR-003: Definición Completa del Formato TON

## Metadata

- **ID:** CR-003
- **Prioridad:** CRÍTICA
- **Esfuerzo estimado:** M (Medio)
- **Hallazgos relacionados:** DM-004, SPEC-005, SPEC-007, SPEC-024, SPEC-026
- **Fecha:** 2026-05-08

---

## Descripción

El formato **TON (Transferable Object Notation)** se usa en 8+ especificaciones pero su definición formal está marcada como **PENDIENTE** en múltiples specs. Esta indefinición bloquea la implementación del Communication Bus, Event Bus, y múltiples componentes.

---

## Fundamento Técnico

### Hallazgos Detallados

| ID       | Src     | Problema                                                   | Impacto               |
| -------- | ------- | ---------------------------------------------------------- | --------------------- |
| DM-004   | DM 5.1  | 4 decisiones TBD: Editor Engine, Modelo, Event Bus, API GW | Bloquea spec completa |
| SPEC-005 | SPEC-03 | TON usado pero formato PENDIENTE                           | Bloquea pipeline      |
| SPEC-007 | SPEC-05 | TON incompleto bloquea Communication Bus                   | Bloquea componentes   |
| SPEC-024 | SPEC-05 | Regex secrets detection incompleto                         | Falsos negativos      |
| SPEC-026 | SPEC-05 | ARQUITECTO/ejecutor/REVISOR sin definir                    | Roles fantasma        |

### Análisis de Impacto en Cadena

```
TON Incompleto
    │
    ├──▶ SPEC-05: Communication Bus no puede definirse
    │       │
    │       ├──▶ SPEC-06: Streaming no puede coordinar
    │       └──▶ SPEC-07: Memory Context no puede persistir
    │
    ├──▶ SPEC-03: Pipeline NTO no puede ejecutar
    │
    └──▶ DM-004: 4 decisiones TBD (Evento Bus, API GW, etc.)
            │
            └──▶ Arquitectura completa bloqueada
```

### Especificación Fragmentada de TON

| Spec    | Uso de TON                     | Estado                |
| ------- | ------------------------------ | --------------------- |
| SPEC-01 | Context tokens, system prompt  | Parcialmente definido |
| SPEC-03 | Communication Bus, pipeline    | PENDIENTE             |
| SPEC-05 | Presentation Validator, tokens | PENDIENTE             |
| SPEC-06 | Buffer, flush, budget          | PENDIENTE             |
| SPEC-07 | Micro-skills, embeddings       | Parcialmente definido |

---

## Impacto

### Si No Se Resuelve

- **TODOS** los CRs restantes bloqueados (CR-001, 002, 004, 005, 006, 007, 008)
- Impossibilidad de implementar cualquier componente que use TON
- 47+ items PENDIENTE en specs nunca se resolverán
- Proyecto en standstill técnico

### Si Se Resuelve

- Desbloquea todos los CRs subsiguientes
- Base para implementación de componentes
- Lenguaje común entre equipos
- Onboarding de nuevos desarrolladores acelerado

---

## Solución Propuesta

### Paso 1: Definir gramática EBNF de TON

```ebnf
(* ============================================
   TON v1.0 — Transferable Object Notation
   ============================================ *)

(* Primitivos *)
ton-boolean   = "true" | "false" ;
ton-null      = "null" ;
ton-number    = ["-"], digit, { digit }, [".", { digit }] ;
ton-string    = '"', { unicode-char - ('"' | "\") | escape }, '"' ;
ton-identifier = letter, { letter | digit | "_" } ;

escape        = "\", ("n" | "r" | "t" | "\" | '"' | "u", hex, hex, hex, hex) ;

(* Estructuras *)
ton-array     = "[", [ton-value, { ",", ton-value }], "]" ;
ton-object    = "{", [ton-member, { ",", ton-member }], "}" ;
ton-member    = ton-string, ":", ton-value ;

(* Valores *)
ton-value     = ton-null | ton-boolean | ton-number | ton-string
               | ton-array | ton-object ;

(* Tipados para MI-SUIT *)
typed-value   = ton-value ;
```

### Paso 2: Definir Tipos de Sistema

```typescript
// ===== Primitivos de MI-SUIT =====

// Identificadores
type ComponentId = string; // e.g., "NTO:main", "MAIN:worker:1"
type ArtifactId = string; // UUID v4
type ConversationId = string;
type SessionId = string;

// Tokens y límites
interface TokenBudget {
  max: number; // Límite del modelo
  system: number; // Overhead system prompt (DM-032)
  history: number; // Contexto histórico
  available: number; // max - system - history
  buffer: {
    threshold: number; // 50-100 tokens (SPEC-017)
    current: number;
  };
}

// Tipos de contenido
interface Content {
  type: "text" | "code" | "markdown" | "json" | "binary";
  value: string | Uint8Array;
  language?: string; // Para código
  metadata?: Record<string, unknown>;
}

// Artefacto generado
interface Artifact {
  id: ArtifactId;
  type: "file" | "diff" | "patch" | "sourcemap";
  path?: string;
  content: Content;
  generation: {
    agent: ComponentId;
    timestamp: number;
    parentId?: ArtifactId; // Para lineage
    generation: number;
  };
}

// Micro-skill
interface MicroSkill {
  id: string;
  name: string;
  description: string;
  trigger: {
    type: "keyword" | "pattern" | "semantic" | "context";
    pattern: string | RegExp;
  };
  action: {
    type: "insert" | "suggest" | "execute";
    definition: string; // Código o prompt
  };
  metadata: {
    confidence: number; // 0-1
    usageCount: number;
    lastUsed?: number;
  };
}

// ===== Estructuras Compuestas =====

// Handoff entre agentes
interface AgentHandoff {
  type: "handoff";
  from: ComponentId;
  to: ComponentId;
  conversationId: ConversationId;
  payload: {
    instruction: string;
    context: {
      artifacts: ArtifactId[];
      lastArtifact?: ArtifactId;
      tokenBudget: TokenBudget;
    };
  };
  protocol: "sync" | "async"; // SPEC-021
}

// Context para LLM
interface LLMContext {
  systemPrompt: string;
  conversationHistory: Message[];
  activeArtifacts: ArtifactId[];
  tokenBudget: TokenBudget;
  metadata: {
    sessionId: SessionId;
    startedAt: number;
    model: string; // SPEC-004
  };
}

// Mensaje de streaming
interface StreamingToken {
  type: "token" | "function_call" | "context_update";
  value: string;
  isDelta: boolean; // SPEC-041: fin de oración
  lineage?: ArtifactId; // SPEC-042
}

// ===== Event Bus Messages =====

interface SystemEvent {
  type: EventType;
  source: ComponentId;
  timestamp: number;
  payload: unknown;
}

type EventType =
  | "agent:started"
  | "agent:completed"
  | "agent:error"
  | "context:updated"
  | "context:flushed"
  | "artifact:generated"
  | "artifact:approved"
  | "artifact:rejected"
  | "buffer:threshold"
  | "buffer:flushed";
```

### Paso 3: Especificar Secret Detection (DM-012 / SPEC-024)

```typescript
// Regex para detección de secrets (SPEC-024)
const SECRET_PATTERNS = {
  // API Keys
  aws_access_key: /AKIA[0-9A-Z]{16}/,
  aws_secret_key: /[A-Za-z0-9/+=]{40}/,
  generic_api_key:
    /(?:api[_-]?key|apikey|api_secret)['":\s]*[=:]\s*['"]?[A-Za-z0-9]{20,}['"]?/i,

  // Tokens
  jwt: /eyJ[A-Za-z0-9-_]+\.eyJ[A-Za-z0-9-_]+\.[A-Za-z0-9-_]+/,
  github_token: /gh[pousr]_[A-Za-z0-9_]{36,}/,
  slack_token: /xox[baprs]-[0-9]{10,13}-[0-9]{10,13}[a-zA-Z0-9-]*/,

  // Database
  postgres_url: /(?:postgres|postgresql):\/\/[^@]+@[^:\/]+:\d+\/\w+/i,
  mysql_url: /mysql:\/\/[^@]+@[^:\/]+:\d+\/\w+/i,
  redis_url: /redis:\/\/[^@]+@[^:\/]+:\d+/i,

  // Generic secrets
  private_key: /-----BEGIN (?:RSA |EC |DSA |OPENSSH )?PRIVATE KEY-----/,
};

// Evaluación: AND vs OR (SPEC-027)
type DetectionMode = "any" | "all";

interface SecretDetectionConfig {
  patterns: typeof SECRET_PATTERNS;
  mode: DetectionMode; // any = OR, all = AND
  excludePaths: string[]; // paths que no deben escanearse
  minEntropy: number; // bits de entropía mínima
}
```

### Paso 4: Definir Roles del Pipeline (SPEC-026)

```typescript
// Roles del pipeline NTO (SPEC-026)
interface PipelineRole {
  id: string;
  type: "arquitecto" | "ejecutor" | "revisor";
  responsibilities: string[];
  inputs: string[]; // Qué recibe
  outputs: string[]; // Qué produce
  constraints: {
    maxTokens: number;
    maxIterations: number;
    timeout: number;
  };
}

const PIPELINE_ROLES: Record<string, PipelineRole> = {
  arquitecto: {
    id: "NTO:role:arquitecto",
    type: "arquitecto",
    responsibilities: [
      "Planificar estructura del código",
      "Definir componentes y dependencias",
      "Validar contra el diseño original",
    ],
    inputs: ["task", "context", "design"],
    outputs: ["plan", "code-structure"],
    constraints: { maxTokens: 2000, maxIterations: 3, timeout: 30000 },
  },
  ejecutor: {
    id: "NTO:role:ejecutor",
    type: "ejecutor",
    responsibilities: [
      "Implementar código según el plan",
      "Generar artefactos",
      "Reportar progreso",
    ],
    inputs: ["plan", "context"],
    outputs: ["artefacts", "diffs"],
    constraints: { maxTokens: 4000, maxIterations: 10, timeout: 60000 },
  },
  revisor: {
    id: "NTO:role:revisor",
    type: "revisor",
    responsibilities: [
      "Validar calidad del código generado",
      "Verificar seguridad",
      "Aprobar o rechazar",
    ],
    inputs: ["artefacts", "rules"],
    outputs: ["approval", "feedback"],
    constraints: { maxTokens: 1000, maxIterations: 2, timeout: 15000 },
  },
};
```

---

## Criterios de Aceptación

- [ ] Gramática EBNF de TON definida formalmente
- [ ] Tipos de sistema documentados (ComponentId, Artifact, TokenBudget, etc.)
- [ ] Estructuras compuestas especificadas (LLMContext, AgentHandoff, etc.)
- [ ] Secret detection regex con evaluación AND/OR clarificada
- [ ] Roles del pipeline (arquitecto/ejecutor/revisor) documentados
- [ ] SPEC-003, SPEC-005, SPEC-007, SPEC-024, SPEC-026 actualizados
- [ ] Ejemplos de uso en cada estructura

---

## Archivos Afectados

| Archivo                           | Acción                               |
| --------------------------------- | ------------------------------------ |
| `docs/ton-spec.md`                | Crear especificación completa de TON |
| `specs/03-main-agent/spec.md`     | Actualizar roles del pipeline        |
| `specs/05-pipeline-nto/spec.md`   | Completar tipos usados               |
| `specs/06-streaming-llm/spec.md`  | Actualizar buffer y flush            |
| `specs/07-memory-context/spec.md` | Actualizar micro-skills schema       |

---

## Dependencias

- **Ninguna** — Este CR debe ejecutarse primero
- **Es bloqueante para:** CR-001, CR-002, CR-004, CR-005, CR-006, CR-007, CR-008

---

_Revisado: DM-004, SPEC-005, SPEC-007, SPEC-024, SPEC-026_
