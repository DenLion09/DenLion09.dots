# Spec 07 — Sistema de Memoria Atómica (DB Relacional de Micro-Skills)

## 1. Propósito

El **Sistema de Memoria Atómica** es la base de datos relacional que almacena, organiza y sirve **micro-skills** — unidades mínimas de conocimiento ejecutable que los agentes (Main y subagentes) utilizan para realizar tareas complejas de forma consistente y repetible

Es el **sistema de memoria persistente** del suite AI-First: sobrevive a los Context Flush, persiste entre sesiones, y permite que el Main "recuerde" cómo realizar tareas que ya ejecutó anteriormente sin necesidad de re-planificar desde cero.

### 1.1 ¿Qué es una Micro-Skill?

Una **micro-skill** es una unidad atómica de conocimiento que describe **cómo** realizar una acción específica dentro de un contexto de desarrollo. No es un prompt genérico — es un conjunto estructurado de instrucciones, patrones, constraints y artefactos que un agente puede ejecutar de forma autónoma.

**Ejemplos de micro-skills:**

- `"crear endpoint JWT"` → incluye estructura de archivos, validaciones, tests requeridos
- `"setup auth middleware"` → incluye patrones de middleware, manejo de errores, inyección de dependencias
- `"generar componente React con FlyonUI"` → incluye estructura, anti-fatiga colors, accesibilidad

### 1.2 Problema que Resuelve

Sin Memoria Atómica:

1. El Main **reinventa la rueda** en cada tarea similar
2. No hay **consistencia** entre ejecuciones de la misma tarea
3. El Context Flush **destruye todo** el conocimiento adquirido
4. Los subagentes operan **sin contexto histórico** de cómo se hicieron tareas similares

Con Memoria Atómica:

1. El Main **busca micro-skills existentes** antes de planificar
2. Hay **consistencia garantizada** — misma tarea, mismo patrón
3. El conocimiento **sobrevive al flush** como artefacto durable
4. Los subagentes **heredan patrones** verificados de ejecuciones previas

### 1.3 Alcance

Este spec cubre:

| Dominio                          | Qué cubre                                                        |
| -------------------------------- | ---------------------------------------------------------------- |
| **Esquema de DB**                | Tablas, relaciones, índices para micro-skills, tasks, artifacts  |
| **Ciclo de vida**                | Creación, uso, evolución, deprecación de micro-skills            |
| **Búsqueda y recuperación**      | Cómo el Main encuentra la micro-skill correcta                   |
| **Integración con Flush/Reload** | Cómo sobrevive al Context Flush                                  |
| **Inyección en agentes**         | Cómo se inyectan micro-skills en el contexto del Main/subagentes |
| **API/IPC**                      | Commands y eventos para interactuar con el sistema               |

**NO cubre:**

- Implementación del modelo LLM (específico de inferencia)
- UI del chat (ver spec/03)
- Validaciones de seguridad (ver spec/05 y spec/06)

---

## 2. Terminología

| Término                 | Definición                                                                                    |
| ----------------------- | --------------------------------------------------------------------------------------------- |
| **Micro-Skill**         | Unidad atómica de conocimiento ejecutable con instrucciones, constraints y artefactos         |
| **Skill Graph**         | Grafo de dependencias entre micro-skills (una skill puede requerir otras)                     |
| **Atomic**              | Cada operación de lectura/escritura es transaccional — o se completa completa o no se ejecuta |
| **Artefacto Durable**   | Datos persistidos fuera del contexto del LLM que sobreviven al Context Flush                  |
| **Context Flush**       | Protocolo de limpieza del KV Cache del LLM después de cada tarea                              |
| **Context Reload**      | Protocolo de recarga de STRACT.md + grafo de tareas + micro-skills después del flush          |
| **Skill Injection**     | Proceso de inyectar micro-skills relevantes en el contexto del agente                         |
| **Verification Status** | Nivel de confianza: `unverified`, `tool_verified`, `human_verified`                           |
| **Task Instance**       | Ejecución concreta de una micro-skill en un proyecto específico                               |
| **Skill Fingerprint**   | Hash único que identifica la "huella" de una micro-skill (para detección de duplicados)       |

---

## 3. Arquitectura de Base de Datos

### 3.1 Stack de Persistencia (Single Storage)

> **Decisión de Arquitectura:** El sistema de memoria atómica utiliza **únicamente PostgreSQL + pgvector** como almacenamiento persistente. NO existe dual storage.

```
┌──────────────────────────────────────────────────────────────┐
│                    MEMORIA ATÓMICA                           │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  CAPA: PostgreSQL + pgvector (Persistencia ÚNICA)            │
│  • Micro-skills maestras (catalogo global)                   │
│  • Task instances por proyecto                               │
│  • Embeddings vectoriales para búsqueda semántica            │
│  • Historial de ejecuciones y validaciones                   │
│  • Artefactos durables (FlushHandoff, ValidationArtifacts)   │
│  • Global rules                                               │
│  • Project profiles                                          │
│  • STRACT.md contenido                                        │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

### 3.2 Relación con la App de Chat

> **Aclaración Importante:**

| Componente                     | Tipo             | Persistencia  | Flush                |
| ------------------------------ | ---------------- | ------------- | -------------------- |
| **App de Chat (IA)**           | Cache en memoria | ❌ Efímera    | ✅ Se limpia         |
| **Sistema de Memoria Atómica** | PostgreSQL       | ✅ Permanente | ❌ No se ve afectado |

- **App de Chat**: Maneja session state, conversación activa, contexto de turno, buffers de tokens. Estos datos son **efímeros** y se limpian en cada flush.
- **Sistema de Memoria**: Almacena micro-skills, global rules, artefactos. Estos datos son **persistentes** e independientes del flush.

**El flush ocurre en la App de Chat**, no en el sistema de memoria. El sistema de memoria persiste porque los datos útiles ya fueron guardados **ANTES** del flush mediante instrucciones de prompting.

```
┌──────────────────────────────────────────────────────────────┐
│                    MEMORIA ATÓMICA                           │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  CAPA 1: Cache en Memoria (Contexto Inmediato)              │
│  • Micro-skills en uso activo                                │
│  • Task instances en progreso                                │
│  • Cache de búsqueda de skills                               │
│  • TTL: por sesión (se limpia en flush)                      │
│  • Implementación: estructuras Rust con TTL                  │
│                                                              │
│  CAPA 2: PostgreSQL + pgvector (Persistencia)               │
│  • Micro-skills maestras (catalogo global)                   │
│  • Task instances por proyecto                               │
│  • Embeddings vectoriales para búsqueda semántica            │
│  • Historial de ejecuciones y validaciones                   │
│  • Artefactos durables (FlushHandoff, ValidationArtifacts)   │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

### 3.2 Esquema Relacional

```
┌─────────────────────────────────────────────────────────────────┐
│                     MICRO_SKILLS (catálogo global)              │
├─────────────────────────────────────────────────────────────────┤
│ id              UUID PK          -- Identificador único         │
│ fingerprint     VARCHAR(64) UNIQUE -- Hash de contenido         │
│ name            VARCHAR(255)     -- "crear_endpoint_jwt"        │
│ description     TEXT             -- Descripción legible         │
│ category        VARCHAR(100)     -- "auth", "crud", "testing"   │
│ subcategory     VARCHAR(100)     -- "jwt", "oauth", "session"   │
│ difficulty      VARCHAR(20)      -- "beginner", "intermediate", │
│                                  -- "advanced", "expert"        │
│ stack           TEXT[]           -- ["go", "postgres", "redis"]  │
│ instructions    TEXT             -- Instrucciones paso a paso    │
│ constraints     JSONB            -- Reglas y limitaciones       │
│ expected_files  JSONB            -- Archivos que genera          │
│ validation_rules JSONB           -- Reglas de validación         │
│ template_context JSONB           -- Variables de template        │
│ embedding       VECTOR(768)      -- Embedding semántico         │
│ created_at      TIMESTAMPTZ      │
│ updated_at      TIMESTAMPTZ      │
│ deprecated_at   TIMESTAMPTZ NULL -- Si está deprecada           │
│ verified_by     VARCHAR(50)      -- "tool" | "human"            │
│ verification_status VARCHAR(20)  -- verification status enum    │
│ usage_count     INTEGER DEFAULT 0 -- Cuántas veces se usó       │
│ success_rate    DECIMAL(5,2)     -- % de éxito histórico        │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                   SKILL_DEPENDENCIES (grafo)                    │
├─────────────────────────────────────────────────────────────────┤
│ id              UUID PK                                         │
│ skill_id        UUID FK → micro_skills.id                       │
│ requires_id     UUID FK → micro_skills.id                       │
│ relationship    VARCHAR(30) -- "requires", "enhances", "alt"    │
│ notes           TEXT                                            │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                   TASK_INSTANCES (ejecuciones por proyecto)     │
├─────────────────────────────────────────────────────────────────┤
│ id              UUID PK                                         │
│ project_id      VARCHAR(255)  -- ID del proyecto                │
│ skill_id        UUID FK → micro_skills.id                       │
│ parent_task_id  UUID FK → task_instances.id NULL -- Tarea padre │
│ status          VARCHAR(20) -- "pending", "running",            │
│                               -- "completed", "failed",         │
│                               -- "cancelled"                    │
│ objective       TEXT           -- Objetivo de esta instancia     │
│ context_snapshot JSONB        -- Estado del proyecto al iniciar  │
│ files_created   TEXT[]         -- Archivos generados             │
│ files_modified  TEXT[]         -- Archivos modificados           │
│ started_at      TIMESTAMPTZ                                     │
│ completed_at    TIMESTAMPTZ NULL                                │
│ duration_ms     INTEGER NULL                                    │
│ tokens_consumed INTEGER NULL                                    │
│ validation_result JSONB NULL  -- Resultado de validación        │
│ verification_status VARCHAR(20) -- verification status enum     │
│ error_log       TEXT NULL      -- Si falló                      │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                   VALIDATION_ARTIFACTS                          │
├─────────────────────────────────────────────────────────────────┤
│ id              UUID PK                                         │
│ task_instance_id UUID FK → task_instances.id                    │
│ validation_type VARCHAR(30) -- "input", "output", "code",       │
│                                -- "security", "design"          │
│ status          VARCHAR(20) -- "passed", "failed", "partial"    │
│ result          JSONB        -- Detalle del resultado           │
│ evidence        TEXT[]       -- Referencias a evidencia         │
│ created_at      TIMESTAMPTZ                                     │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                   FLUSH_HANDOFF_ARTIFACTS                       │
├─────────────────────────────────────────────────────────────────┤
│ id              UUID PK                                         │
│ project_id      VARCHAR(255)                                    │
│ task_id         UUID FK → task_instances.id                     │
│ created_at      TIMESTAMPTZ                                     │
│ artifact_data   JSONB        -- FlushHandoffArtifact completo   │
│ -- Ver spec/06 §7.4 para la estructura de FlushHandoffArtifact  │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                   FAILED_VALIDATION_RECORDS                     │
├─────────────────────────────────────────────────────────────────┤
│ id              UUID PK                                         │
│ task_instance_id UUID FK → task_instances.id NULL               │
│ validation_type VARCHAR(30)                                     │
│ failed_content  TEXT                                             │
│ failure_category VARCHAR(100)                                    │
│ failure_severity VARCHAR(20) -- "critical", "high",             │
│                                -- "medium", "low"               │
│ contract_id     VARCHAR(255) NULL                                │
│ retryable       BOOLEAN                                          │
│ retry_count     INTEGER DEFAULT 0                                │
│ max_retries     INTEGER DEFAULT 2                                │
│ partial_output  TEXT NULL                                        │
│ evidence        TEXT[] NULL                                      │
│ resolved        BOOLEAN DEFAULT FALSE                            │
│ resolution      VARCHAR(30) NULL -- "auto_fixed",               │
│                                -- "manual_override",            │
│                                -- "discarded", "escalated"      │
│ resolved_at     TIMESTAMPTZ NULL                                 │
│ created_at      TIMESTAMPTZ                                      │
│ -- Ver spec/06 §9.3 para la estructura completa                 │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                   DELEGATION_CONTRACTS                          │
├─────────────────────────────────────────────────────────────────┤
│ id              UUID PK                                         │
│ parent_agent    VARCHAR(255)                                    │
│ subagent_id     VARCHAR(255)                                    │
│ objective       TEXT                                             │
│ success_criteria TEXT[]                                          │
│ budget          JSONB        -- max_tokens, max_time_ms,         │
│                              -- max_tool_calls                  │
│ fail_policy     VARCHAR(20) -- "fail_closed", "fail_open"       │
│ context_snapshot TEXT[]                                          │
│ payload_mode    VARCHAR(30) -- "text", "semantic_frame",        │
│                               -- "structured_json"              │
│ trust_domain    VARCHAR(100)                                    │
│ required_verification VARCHAR(20)                                │
│ created_at      TIMESTAMPTZ                                     │
│ completed_at    TIMESTAMPTZ NULL                                 │
│ status          VARCHAR(20) -- "active", "completed",           │
│                               -- "failed", "timeout"            │
│ -- Ver spec/06 §6.1 para la estructura completa                 │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                   PROJECT_PROFILES (perfiles por proyecto)      │
├─────────────────────────────────────────────────────────────────┤
│ id              UUID PK                                         │
│ project_id      VARCHAR(255) UNIQUE                              │
│ project_name    VARCHAR(255)                                    │
│ stack           TEXT[]                                           │
│ conventions     JSONB        -- Convenciones del proyecto       │
│ active_skills   UUID[] FK → micro_skills.id  -- Skills usados   │
│ created_at      TIMESTAMPTZ                                     │
│ updated_at      TIMESTAMPTZ                                     │
│ last_flush_at   TIMESTAMPTZ                                     │
│ stract_content  TEXT         -- Contenido actual de STRACT.md   │
└─────────────────────────────────────────────────────────────────┘
```

### 3.3 Diagrama de Relaciones

```
  micro_skills ──┬──< skill_dependencies >──┐
                 │                          │
                 │                          │ (self-referential)
                 │                          │
                 └──< task_instances >──┬───┘
                                        │
                 ┌──────────────────────┤
                 │                      │
  validation_artifacts                  │
                 │                      │
  flush_handoff_artifacts               │
                 │                      │
  failed_validation_records             │
                 │                      │
  delegation_contracts ─────────────────┘

  project_profiles ──> micro_skills (active_skills array)
  project_profiles ──> task_instances (via project_id)
```

### 3.4 Índises Críticos

```sql
-- Búsqueda semántica (pgvector)
CREATE INDEX idx_skills_embedding ON micro_skills
  USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);

-- Búsqueda por categoría y stack
CREATE INDEX idx_skills_category_stack ON micro_skills(category, stack);

-- Búsqueda por fingerprint (deduplicación)
CREATE UNIQUE INDEX idx_skills_fingerprint ON micro_skills(fingerprint);

-- Task instances por proyecto y estado
CREATE INDEX idx_tasks_project_status ON task_instances(project_id, status);

-- Búsqueda de artifacts por task
CREATE INDEX idx_artifacts_task ON validation_artifacts(task_instance_id);

-- Búsqueda de failed validations por categoría
CREATE INDEX idx_failed_by_category ON failed_validation_records(failure_category);

-- Project profiles por project_id
CREATE UNIQUE INDEX idx_profiles_project ON project_profiles(project_id);
```

---

## 4. Micro-Skills: Especificación Detallada

### 4.1 Estructura de una Micro-Skill

```typescript
interface MicroSkill {
  // Identificación
  id: string; // UUID v4
  fingerprint: string; // SHA-256 hash de instructions + constraints
  name: string; // snake_case: "crear_endpoint_jwt"
  description: string; // Descripción legible por humanos

  // Clasificación
  category: string; // Categoría principal
  subcategory: string; // Subcategoría específica
  difficulty: DifficultyLevel;
  stack: string[]; // Tecnologías requeridas

  // Contenido ejecutable
  instructions: string; // Instrucciones paso a paso (markdown)
  constraints: SkillConstraints;
  expected_files: ExpectedFile[];
  validation_rules: ValidationRule[];
  template_context: Record<string, string>;

  // Búsqueda semántica
  embedding: number[]; // Vector de 768 dimensiones

  // Metadatos
  created_at: string;
  updated_at: string;
  deprecated_at?: string;
  verified_by: "tool" | "human";
  verification_status: VerificationLevel;
  usage_count: number;
  success_rate: number; // 0.00 - 100.00
}

type DifficultyLevel = "beginner" | "intermediate" | "advanced" | "expert";

interface SkillConstraints {
  max_files?: number; // Máximo archivos que puede crear
  max_lines_per_file?: number; // Máximo líneas por archivo
  requires_specs?: boolean; // Requiere specs/ directory
  requires_tests?: boolean; // Requiere generar tests
  forbidden_patterns?: string[]; // Patrones que NO debe usar
  required_patterns?: string[]; // Patrones que DEBE usar
  stack_restrictions?: string[]; // Stacks que NO soporta
}

interface ExpectedFile {
  path: string; // Ruta relativa esperada
  purpose: string; // Qué hace este archivo
  min_lines?: number; // Líneas mínimas esperadas
  must_contain?: string[]; // Strings que debe contener
  language: string; // Lenguaje del archivo
}

interface ValidationRule {
  type: "compile" | "test" | "lint" | "security" | "design" | "spec";
  description: string;
  severity: "critical" | "high" | "medium" | "low";
  auto_checkable: boolean; // Si se puede verificar automáticamente
}
```

### 4.2 Ejemplo: Micro-Skill "Crear Endpoint JWT"

```json
{
  "name": "crear_endpoint_jwt",
  "description": "Crea un endpoint de autenticación JWT completo con login, refresh token y middleware de validación",
  "category": "auth",
  "subcategory": "jwt",
  "difficulty": "intermediate",
  "stack": ["go", "postgres", "redis"],
  "instructions": "# Crear Endpoint JWT\n\n1. Crear estructura de paquetes: `auth/`, `auth/jwt.go`, `auth/middleware.go`\n2. Implementar `GenerateToken()` con claims estándar (user_id, exp, iat)\n3. Implementar `ValidateToken()` middleware para proteger rutas\n4. Implementar endpoint POST `/auth/login` con validación de credenciales\n5. Implementar endpoint POST `/auth/refresh` para renovar tokens\n6. Agregar tests unitarios para cada función\n7. Ejecutar linter y security scan\n\n**Notas:**\n- Usar `github.com/golang-jwt/jwt/v5`\n- Tokens expiran en 24h, refresh tokens en 7d\n- Nunca loggear tokens o secrets",
  "constraints": {
    "max_files": 6,
    "requires_tests": true,
    "forbidden_patterns": ["hardcoded_secret", "SELECT *"],
    "required_patterns": ["context.Context", "sql.ErrNoRows"]
  },
  "expected_files": [
    {
      "path": "auth/jwt.go",
      "purpose": "Generación y validación de tokens JWT",
      "min_lines": 40,
      "must_contain": ["GenerateToken", "ValidateToken", "jwt.MapClaims"],
      "language": "go"
    },
    {
      "path": "auth/middleware.go",
      "purpose": "Middleware HTTP para validar tokens en requests",
      "min_lines": 25,
      "must_contain": ["AuthMiddleware", "extractBearerToken"],
      "language": "go"
    },
    {
      "path": "auth/login.go",
      "purpose": "Handler de login con validación de credenciales",
      "min_lines": 30,
      "must_contain": ["LoginHandler", "validateCredentials"],
      "language": "go"
    },
    {
      "path": "auth/jwt_test.go",
      "purpose": "Tests unitarios para funciones JWT",
      "min_lines": 50,
      "must_contain": ["TestGenerateToken", "TestValidateToken"],
      "language": "go"
    }
  ],
  "validation_rules": [
    {
      "type": "compile",
      "description": "El código debe compilar sin errores",
      "severity": "critical",
      "auto_checkable": true
    },
    {
      "type": "test",
      "description": "Todos los tests unitarios deben pasar",
      "severity": "critical",
      "auto_checkable": true
    },
    {
      "type": "security",
      "description": "No debe contener secrets hardcodeados",
      "severity": "critical",
      "auto_checkable": true
    },
    {
      "type": "lint",
      "description": "Debe pasar golangci-lint sin errores",
      "severity": "high",
      "auto_checkable": true
    }
  ],
  "template_context": {
    "token_expiry": "24h",
    "refresh_expiry": "7d",
    "jwt_library": "github.com/golang-jwt/jwt/v5",
    "claims_standard": "user_id, exp, iat"
  }
}
```

### 4.3 Generación del Fingerprint

El fingerprint se genera como hash SHA-256 del contenido canónico:

```
fingerprint = SHA256(
  instructions_normalized +
  constraints_json_sorted +
  expected_files_sorted_by_path +
  validation_rules_sorted_by_type
)
```

Esto permite:

- **Detección de duplicados**: misma skill, mismo fingerprint
- **Detección de cambios**: si el contenido cambia, el fingerprint cambia
- **Integridad**: verificar que una skill no fue corrompida

### 4.4 Generación de Embeddings

El embedding semántico se genera a partir de:

```
embedding_source = name + " " + description + " " + category + " " + instructions[:500]
```

Se usa un modelo de embedding local (compatible con GGUF) para generar vectores de 768 dimensiones. Esto permite:

- **Búsqueda semántica**: "crear login" → encuentra "crear_endpoint_jwt"
- **Búsqueda fuzzy**: no requiere match exacto de palabras
- **Ranking por relevancia**: las skills más relevantes aparecen primero

---

## 5. Ciclo de Vida de Micro-Skills

### 5.1 Estados de una Micro-Skill

```
                    ┌─────────────┐
                    │  DRAFT      │ ← Creada pero no verificada
                    └──────┬──────┘
                           │ tool_verify OR human_verify
                           ▼
                    ┌─────────────┐
                    │  VERIFIED   │ ← Verificada por tool o humano
                    └──────┬──────┘
                           │ usada exitosamente N veces
                           ▼
                    ┌─────────────┐
                    │  TRUSTED    │ ← Alta tasa de éxito (>90%)
                    └──────┬──────┘
                           │ se detecta problema
                           ▼
                    ┌─────────────┐
                    │  DEPRECATED │ ← Marcada como deprecada
                    └─────────────┘
```

### 5.2 Flujo de Creación

```
1. Usuario pide tarea compleja ("crea un login con JWT")
     ↓
2. Main no encuentra micro-skill existente (búsqueda semántica)
     ↓
3. Main PLANIFICA la tarea y la ejecuta paso a paso
     ↓
4. Headless Guardian valida cada paso
     ↓
5. Si TODA la tarea pasa validación → Main genera micro-skill
     ↓
6. Se calcula fingerprint y embedding
     ↓
7. Micro-skill se guarda en PostgreSQL (estado: DRAFT)
     ↓
8. La próxima vez, la micro-skill estará disponible
```

### 5.3 Flujo de Uso

```
1. Usuario pide tarea ("crea un login con JWT")
     ↓
2. Main busca en Memoria Atómica:
   a. Búsqueda semántica (embedding similarity)
   b. Filtro por stack del proyecto
   c. Filtro por categoría
   d. Ordenar por success_rate DESC
     ↓
3. Si encuentra micro-skill TRUSTED o VERIFIED:
   a. Inyecta instrucciones en contexto del Main
   b. Main delega subtareas siguiendo las instrucciones
   c. Headless Guardian valida contra validation_rules
     ↓
4. Si encuentra micro-skill DRAFT:
   a. Main la usa pero con validación extra
   b. Si pasa → incrementa usage_count, recalcula success_rate
   c. Si success_rate > 90% y usage_count > 5 → estado TRUSTED
     ↓
5. Si NO encuentra micro-skill:
   a. Main planifica desde cero
   b. Si exitosa → genera nueva micro-skill (ver 5.2)
```

### 5.4 Flujo de Evolución

```
1. Se ejecuta micro-skill existente
     ↓
2. Headless Guardian detecta que las instructions necesitan actualización
   (ej: nueva versión de librería, nuevo patrón de seguridad)
     ↓
3. Se crea nueva versión de la micro-skill:
   - fingerprint nuevo (contenido diferente)
   - embedding nuevo
   - old_skill.deprecated_at = NOW()
   - new_skill.created_at = NOW()
     ↓
4. La nueva skill hereda el histórico de la anterior:
   - usage_count se suma
   - success_rate se recalcula
```

### 5.5 Flujo de Deprecación

```
Micro-skill se deprecada cuando:
  - success_rate < 60% después de 10+ usos
  - Stack technology ya no soportada
  - Se detecta vulnerability en el patrón
  - Versión superior reemplaza la anterior

Al deprecarse:
  - deprecated_at = NOW()
  - Ya no aparece en búsquedas semánticas
  - Se puede consultar por ID explícito (para referencia histórica)
  - task_instances existentes mantienen referencia
```

---

## 6. Búsqueda y Recuperación

### 6.1 Algoritmo de Búsqueda

El Main usa un algoritmo de **búsqueda multi-etapa** para encontrar la micro-skill más relevante:

```
┌─────────────────────────────────────────────────────────────┐
│              BÚSQUEDA DE MICRO-SKILL                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  STAGE 1: Búsqueda Semántica (pgvector)                     │
│  • Query embedding del input del usuario                    │
│  • cosine_similarity(skill_embedding, query_embedding)      │
│  • Top 20 resultados con similarity > 0.7                   │
│                                                             │
│  STAGE 2: Filtro por Stack del Proyecto                     │
│  • intersection(skill.stack, project.stack)                 │
│  • Descartar skills con 0 overlap de stack                  │
│  • Priorizar skills con mayor overlap                       │
│                                                             │
│  STAGE 3: Filtro por Estado                                 │
│  • Excluir DEPRECATED                                       │
│  • Ordenar: TRUSTED > VERIFIED > DRAFT                      │
│                                                             │
│  STAGE 4: Ranking Final                                     │
│  • Score = (semantic_similarity * 0.5) +                    │
│            (stack_overlap * 0.2) +                          │
│            (success_rate / 100 * 0.2) +                     │
│            (log(usage_count + 1) * 0.1)                     │
│                                                             │
│  RESULTADO: Top 1-3 micro-skills más relevantes             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 6.2 Query de Búsqueda Semántica

```sql
-- Búsqueda semántica de micro-skills
SELECT
  id, name, description, category, subcategory,
  difficulty, stack, instructions,
  verification_status, usage_count, success_rate,
  1 - (embedding <=> $1) AS similarity  -- cosine distance
FROM micro_skills
WHERE deprecated_at IS NULL
  AND verification_status != 'unverified'
  AND 1 - (embedding <=> $1) > 0.7  -- threshold de similitud
ORDER BY similarity DESC
LIMIT 20;
```

### 6.3 API de Búsqueda (IPC)

```
// Frontend/Main → Memoria Atómica
"memory:search" → {
  query: string,           // "crear login con jwt"
  project_id: string,      // ID del proyecto activo
  stack: string[],         // ["go", "postgres"]
  category?: string,       // filtro opcional
  limit?: number           // default: 5
}

// Memoria Atómica → Frontend/Main
"memory:search:results" → {
  skills: MicroSkill[],
  query_embedding: number[],
  search_time_ms: number
}

// Main → Memoria Atómica
"memory:get" → { skill_id: string }
"memory:get:result" → MicroSkill | null

"memory:get_by_fingerprint" → { fingerprint: string }
"memory:get_by_fingerprint:result" → MicroSkill | null
```

---

## 7. Integración con Context Flush & Reload

### 7.1flush en la App de Chat (No afecta al Sistema de Memoria)

> **Aclaración Importante:** El **flush ocurre en la App de Chat**, NO en el sistema de memoria. El sistema de memoria es persistente e independiente.

```
┌─────────────────────────────────────────────────────────────┐
│           RELACIÓN APP DE CHAT ↔ SISTEMA DE MEMORIA         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   ┌─────────────────────┐        ┌─────────────────────┐   │
│   │    APP DE CHAT     │        │ SISTEMA DE MEMORIA  │   │
│   │   (Cache efímero)  │        │   (PostgreSQL)      │   │
│   │                    │        │                     │   │
│   │ • Session state   │        │ • Micro-skills      │   │
│   │ • Conversación     │        │ • Global rules      │   │
│   │ • Contexto turno   │        │ • FlushHandoff       │   │
│   │ • Buffers tokens   │        │ • Project profiles  │   │
│   └─────────┬───────────┘        └──────────┬──────────┘   │
│             │                              │                │
│             │   Guardar/Cargar datos      │                │
│             │   (vía prompting)           │                │
│             ▼                              ▼                │
│       ┌─────────────────────────────────────────────┐       │
│       │           FLUSH (App de Chat)               │       │
│       │  Limpia cache efímero, NO afecta a memoria  │       │
│       └─────────────────────────────────────────────┘       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 7.2 Estrategias de Flush (App de Chat)

> El flush ocurre en la App de Chat. Cuál usar depende del caso de uso.

#### 7.2.1 Flush por Sección (Cambio de Contexto)

```
┌─────────────────────────────────────────────────────────────┐
│              FLUSH POR SECCIÓN                               │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Trigger: Usuario cambia de sección mediante comando        │
│           (puede ser comando de voz)                        │
│                                                             │
│  Acción: Se abre una nueva sección INMEDIATAMENTE           │
│          SIN flush — el contexto anterior se descartan      │
│          porque es información efímera de la sesión         │
│                                                             │
│  Nombre de sección: Asignado por el usuario                │
│  Ejemplo: "Nueva sección: Implementar auth"                │
│                                                             │
│  NOTA: El sistema de memoria NO se ve afectado              │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### 7.2.2 Flush por Finalización de Tarea SDD

```
┌─────────────────────────────────────────────────────────────┐
│              FLUSH POR TAREA SDD                             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Trigger: Finalización de tarea que requiere SDD workflow   │
│           completo:                                        │
│           - New feature                                     │
│           - Corrección de error (bug fix)                  │
│           - New purpose (nueva propuesta)                  │
│                                                             │
│  Acción en App de Chat:                                     │
│          1. Limpiar cache de sesión                        │
│          2. Limpiar buffers de tokens                     │
│          3. Limpiar contexto de turno                      │
│                                                             │
│  Acción en Sistema de Memoria (ya realizada):              │
│          ✓ FlushHandoffArtifact ya guardado                │
│          ✓ Stats de skills ya actualizados                 │
│          ✓ Project profile ya actualizado                 │
│                                                             │
│  NOTA: El sistema de memoria PERSISTE - no se ve afectado   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 7.2 Protocolo de Flush (Flush por Tarea SDD)

Antes de cada Context Flush (flush por tarea SDD), el sistema genera un **FlushHandoffArtifact** y lo persiste:

```
┌─────────────────────────────────────────────────────────────┐
│              FLUSH SEQUENCE                                 │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. Main detecta que tarea fue completada y validada        │
│       ↓                                                     │
│  2. Generar FlushHandoffArtifact con:                       │
│     - Subtareas completadas y validadas                     │
│     - Validation summary                                    │
│     - Pending commitments                                   │
│     - Next task context                                     │
│       ↓                                                     │
│  3. Persistir FlushHandoffArtifact en PostgreSQL            │
│       ↓                                                     │
│  4. Actualizar task_instances con status "completed"        │
│       ↓                                                     │
│  5. Actualizar micro_skills:                                │
│     - usage_count++                                         │
│     - Recalcular success_rate                               │
│     - Si success_rate > 90% y usage_count > 5 → TRUSTED    │
│       ↓                                                     │
│  6. Actualizar project_profiles:                            │
│     - last_flush_at = NOW()                                 │
│     - stract_content = contenido actual de STRACT.md        │
│     - active_skills += skills usadas en esta tarea          │
│       ↓                                                     │
│  7. Limpiar cache en memoria (estado de sesión)               │
│       ↓                                                     │
│  8. Ejecutar Context Flush (KV Cache del LLM)               │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### FlushHandoffArtifact Schema (JSON/TypeScript)

```typescript
interface FlushHandoffArtifact {
  // Metadata
  id: string; // UUID v4
  type: "context" | "artifact" | "micro-skill";
  timestamp: number; // Unix epoch ms
  source: "NTO" | "MAIN" | "subagent";

  // Content
  payload: {
    data: unknown; // Contenido estructurado en JSON
    format: "json" | "text" | "binary";
    encoding?: string;
  };

  // Provenance
  lineage: {
    parentId?: string; // Artefacto padre (para lineage_chain)
    generation: number; // Generación en la chain
    contextWindow?: {
      used: number;
      max: number;
    };
  };

  // Persistencia
  persistence: {
    tier: "hot" | "warm" | "cold";
    ttl?: number; // segundos, null = permanente
    indexFields: string[]; // Campos para indexación
  };
}
```

### 7.3 Protocolo de Reload

Después del Context Flush, el sistema restaura el contexto:

```
┌─────────────────────────────────────────────────────────────┐
│              RELOAD SEQUENCE                                │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. Main se reinicia con contexto vacío                     │
│       ↓                                                     │
│  2. Cargar project_profile del proyecto activo              │
│       ↓                                                     │
│  3. Cargar STRACT.md (estado actual del proyecto)           │
│       ↓                                                     │
│  4. Cargar último FlushHandoffArtifact                      │
│       ↓                                                     │
│  5. Inyectar micro-skills relevantes en contexto:           │
│     - active_skills del project_profile                     │
│     - Skills TRUSTED del stack del proyecto                 │
│     - Skills usadas en las últimas 5 task_instances         │
│       ↓                                                     │
│  6. Context Providers restauran estado de validaciones      │
│     (ver spec/06 §7.3)                                      │
│       ↓                                                     │
│  7. Main está listo para nueva tarea                        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 7.4 Persistencia vs Flush

> **Nota:** El flush ocurre en la App de Chat, NO en el sistema de memoria.

| Componente                 | Tipo          | Se ve afectado por Flush? |
| -------------------------- | ------------- | ------------------------- |
| **App de Chat**            | Cache efímero | ✅ SÍ — se limpia         |
| Session state (chat)       | In-memory     | ✅ Se limpia              |
| Conversación activa (chat) | In-memory     | ✅ Se limpia              |
| Contexto de turno (chat)   | In-memory     | ✅ Se limpia              |
| Buffers de tokens (chat)   | In-memory     | ✅ Se limpia              |
| **Sistema de Memoria**     | Persistente   | ❌ NO — persiste          |
| Micro-skills               | PostgreSQL    | ❌ Persiste               |
| Global rules               | PostgreSQL    | ❌ Persiste               |
| FlushHandoffArtifact       | PostgreSQL    | ❌ Persiste               |
| Task instances             | PostgreSQL    | ❌ Persiste               |
| Project profiles           | PostgreSQL    | ❌ Persiste               |
| STRACT.md                  | PostgreSQL    | ❌ Persiste               |

**¿Por qué funciona?**  
Los datos útiles se guardan en el sistema de memoria **ANTES** del flush mediante instrucciones de prompting del Main. El flush solo limpia la App de Chat, no afecta al sistema de memoria.

---

## 8. Inyección de Micro-Skills en Agentes

### 8.1 Perfil Único (Main) con Inyección

El Main opera bajo el modelo de **Perfil Único** — no mantiene historial de chat largo, pero sí tiene acceso a micro-skills relevantes:

```
┌─────────────────────────────────────────────────────────────┐
│              PERFIL ÚNICO DEL MAIN                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Contexto del Main (siempre disponible):                    │
│  ┌───────────────────────────────────────────────────────┐  │
│  │ 1. STRACT.md (estado del proyecto)                    │  │
│  │ 2. Git logs recientes (últimos 10 commits)            │  │
│  │ 3. Micro-skills inyectadas (top 3 más relevantes)     │  │
│  │ 4. Validation state (validaciones previas)            │  │
│  │ 5. Project conventions                                │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                             │
│  Micro-skills inyectadas = Top 3 del algoritmo de búsqueda  │
│  (ver §6.1) que match con el input del usuario              │
│                                                             │
│  Formato de inyección:                                      │
│  ┌───────────────────────────────────────────────────────┐  │
│  │ ## Micro-Skill: {name}                                │  │
│  │ Categoría: {category}/{subcategory}                   │  │
│  │ Dificultad: {difficulty}                              │  │
│  │                                                         │  │
│  │ ### Instrucciones                                       │  │
│  │ {instructions}                                          │  │
│  │                                                         │  │
│  │ ### Constraints                                         │  │
│  │ {constraints}                                           │  │
│  │                                                         │  │
│  │ ### Archivos Esperados                                  │  │
│  │ {expected_files}                                        │  │
│  │                                                         │  │
│  │ ### Reglas de Validación                                │  │
│  │ {validation_rules}                                      │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 8.2 Inyección en Subagentes

Los subagentes reciben una **versión reducida** de la micro-skill, solo lo necesario para su subtarea:

```typescript
interface SubagentSkillInjection {
  skill_name: string;
  objective: string; // Objetivo específico de esta subtarea
  instructions: string; // Instrucciones relevantes para esta subtarea
  expected_output: ExpectedFile; // El archivo que debe generar
  validation_rules: ValidationRule[]; // Reglas que debe cumplir
  constraints: Partial<SkillConstraints>; // Constraints aplicables
  context_artifacts: string[]; // IDs de artifacts de contexto
}
```

### 8.3 Presupuesto de Contexto

Las micro-skills inyectadas deben caber dentro del presupuesto de contexto del LLM:

| Componente              | Tamaño máximo         | Prioridad |
| ----------------------- | --------------------- | --------- |
| STRACT.md               | ~4K tokens            | Alta      |
| Git logs                | ~2K tokens            | Media     |
| Micro-skills inyectadas | ~8K tokens (3 skills) | Alta      |
| Validation state        | ~2K tokens            | Media     |
| System prompt           | ~2K tokens            | Alta      |
| **Total**               | **~18K tokens**       |           |

Si las micro-skills exceden el presupuesto, se aplica **compresión selectiva**:

1. Mantener instructions completas de la skill #1 (más relevante)
2. Comprimir instructions de skills #2 y #3 a resumen
3. Mantener constraints y validation_rules completos de todas

---

## 9. API/IPC Commands

> **Nota:** Todas las comunicaciones con la Memoria Atómica utilizan **JSON/TypeScript** para estructuras de datos. No se utiliza TON para solicitudes a PostgreSQL.

### 9.1 Commands de Micro-Skills

```
// Búsqueda
"memory:search"              → Buscar micro-skills por query semántica
"memory:search:results"      → Resultados de búsqueda

// CRUD
"memory:skill:create"        → Crear nueva micro-skill
"memory:skill:update"        → Actualizar micro-skill existente
"memory:skill:deprecate"     → Marcar micro-skill como deprecada
"memory:skill:get"           → Obtener micro-skill por ID
"memory:skill:get:fingerprint" → Obtener por fingerprint

// Estadísticas
"memory:skill:stats"         → Obtener stats de una skill (usage, success_rate)
"memory:skill:list"          → Listar skills por categoría/stack/estado

// Task instances
"memory:task:create"         → Crear nueva task instance
"memory:task:update"         → Actualizar estado de task instance
"memory:task:list"           → Listar tasks de un proyecto
"memory:task:get"            → Obtener detalles de una task

// Flush/Reload
"memory:flush:prepare"       → Preparar artefactos pre-flush
"memory:flush:complete"      → Completar flush (limpiar cache en memoria)
"memory:reload"              → Recargar contexto post-flush

// Validaciones
"memory:validation:record"   → Registrar resultado de validación
"memory:validation:list"     → Listar validaciones de una task
"memory:validation:failed"   → Registrar validación fallida

// Delegation
"memory:delegation:create"   → Crear delegation contract
"memory:delegation:complete" → Completar contract con resultado
"memory:delegation:list"     → Listar contracts activos
```

### 9.2 Events

```
"memory:skill:created"       → Nueva micro-skill creada
"memory:skill:deprecated"    → Micro-skill deprecada
"memory:skill:trusted"       → Micro-skill alcanzó estado TRUSTED
"memory:task:completed"      → Task instance completada
"memory:task:failed"         → Task instance falló
"memory:flush:completed"     → Flush completado
"memory:reload:completed"    → Reload completado
"memory:validation:passed"   → Validación pasó
"memory:validation:failed"   → Validación falló
```

---

## 10. Requisitos

### 10.1 Requisitos de Micro-Skills

| ID         | Requisito                                                                        | Prioridad |
| ---------- | -------------------------------------------------------------------------------- | --------- |
| **MS-001** | Toda micro-skill **DEBE** tener un fingerprint único (SHA-256)                   | MUST      |
| **MS-002** | Toda micro-skill **DEBE** tener un embedding semántico (vector 768d)             | MUST      |
| **MS-003** | Las micro-skills **DEBEN** clasificarse por categoría, subcategoría y dificultad | MUST      |
| **MS-004** | Las micro-skills **DEBEN** especificar el stack tecnológico que soportan         | MUST      |
| **MS-005** | Las micro-skills **DEBEN** incluir expected_files con paths y validaciones       | MUST      |
| **MS-006** | Las micro-skills **DEBEN** incluir validation_rules con tipo y severidad         | MUST      |
| **MS-007** | Las micro-skills DRAFT **NO DEBEN** aparecer en búsquedas semánticas             | MUST      |
| **MS-008** | Las micro-skills DEPRECATED **NO DEBEN** inyectarse automáticamente              | MUST      |
| **MS-009** | El sistema **DEBE** detectar duplicados por fingerprint                          | MUST      |
| **MS-010** | El sistema **DEBE** trackear usage_count y success_rate por skill                | MUST      |

### 10.2 Requisitos de Búsqueda

| ID         | Requisito                                                                           | Prioridad |
| ---------- | ----------------------------------------------------------------------------------- | --------- |
| **SR-001** | La búsqueda semántica **DEBE** usar pgvector con cosine similarity                  | MUST      |
| **SR-002** | La búsqueda **DEBE** filtrar por stack del proyecto activo                          | MUST      |
| **SR-003** | La búsqueda **DEBE** excluir skills DEPRECATED y DRAFT                              | MUST      |
| **SR-004** | La búsqueda **DEBE** ordenar por score compuesto (similitud + success_rate + usage) | MUST      |
| **SR-005** | La búsqueda **DEBE** retornar resultados en < 100ms                                 | SHOULD    |
| **SR-006** | La búsqueda **PUEDE** soportar filtros por categoría                                | MAY       |

### 10.3 Requisitos de Persistencia

| ID         | Requisito                                                               | Prioridad |
| ---------- | ----------------------------------------------------------------------- | --------- |
| **PS-001** | Las micro-skills maestras **DEBEN** persistir en PostgreSQL             | MUST      |
| **PS-002** | Los task instances **DEBEN** persistir en PostgreSQL con project_id     | MUST      |
| **PS-003** | Los validation artifacts **DEBEN** persistir asociados a task_instance  | MUST      |
| **PS-004** | Los flush handoff artifacts **DEBEN** persistir en PostgreSQL           | MUST      |
| **PS-005** | El cache en memoria **DEBE** limpiarse en cada Context Flush            | MUST      |
| **PS-006** | Las operaciones de escritura **DEBEN** ser transaccionales (atómicas)   | MUST      |
| **PS-007** | Los failed validation records **DEBEN** persistir con contexto completo | MUST      |

### 10.4 Requisitos de Flush/Reload

| ID         | Requisito                                                                  | Prioridad |
| ---------- | -------------------------------------------------------------------------- | --------- |
| **FR-001** | Antes del flush, el sistema **DEBE** generar FlushHandoffArtifact          | MUST      |
| **FR-002** | Después del flush, el sistema **DEBE** restaurar STRACT.md + micro-skills  | MUST      |
| **FR-003** | El reload **DEBE** inyectar top 3 micro-skills más relevantes              | MUST      |
| **FR-004** | El reload **DEBE** restaurar estado de validaciones previas                | MUST      |
| **FR-005** | Si el reload falla, el sistema **DEBE** reintentar con backoff exponencial | SHOULD    |

### 10.5 Requisitos de Inyección

| ID         | Requisito                                                                 | Prioridad |
| ---------- | ------------------------------------------------------------------------- | --------- |
| **IN-001** | El Main **DEBE** recibir micro-skills inyectadas en su contexto           | MUST      |
| **IN-002** | Los subagentes **DEBEN** recibir solo la porción relevante de la skill    | MUST      |
| **IN-003** | La inyección **NO DEBE** exceder el presupuesto de contexto (~18K tokens) | MUST      |
| **IN-004** | Si excede el presupuesto, se aplica compresión selectiva                  | MUST      |
| **IN-005** | Las skills TRUSTED **DEBEN** tener prioridad sobre DRAFT en la inyección  | MUST      |

---

## 11. Criterios de Aceptación

### 11.1 Micro-Skills

- [ ] **AC-001**: Una micro-skill creada tiene fingerprint único calculado correctamente
- [ ] **AC-002**: Una micro-skill creada tiene embedding semántico generado
- [ ] **AC-003**: No se pueden crear dos micro-skills con el mismo fingerprint
- [ ] **AC-004**: Una micro-skill DRAFT no aparece en resultados de búsqueda semántica
- [ ] **AC-005**: Una micro-skill DEPRECATED no se inyecta automáticamente en el Main
- [ ] **AC-006**: usage_count incrementa correctamente después de cada uso exitoso
- [ ] **AC-007**: success_rate se recalcula correctamente (éxitos / totales \* 100)
- [ ] **AC-008**: Una skill pasa a TRUSTED cuando success_rate > 90% y usage_count > 5

### 11.2 Búsqueda

- [ ] **AC-009**: Búsqueda semántica retorna resultados relevantes (similarity > 0.7)
- [ ] **AC-010**: Búsqueda filtra correctamente por stack del proyecto
- [ ] **AC-011**: Búsqueda ordena por score compuesto correctamente
- [ ] **AC-012**: Búsqueda retorna resultados en < 100ms para catálogo de hasta 1000 skills

### 11.3 Persistencia

- [ ] **AC-013**: Micro-skills persisten después de reinicio del sistema
- [ ] **AC-014**: Task instances se asocian correctamente al project_id
- [ ] **AC-015**: Validation artifacts se vinculan correctamente a task_instances
- [ ] **AC-016**: Operaciones de escritura son atómicas (rollback en fallo)

### 11.4 Flush/Reload

- [ ] **AC-017**: FlushHandoffArtifact se genera antes de cada Context Flush
- [ ] **AC-018**: Después del reload, el Main tiene STRACT.md cargado
- [ ] **AC-019**: Después del reload, las top 3 micro-skills están inyectadas
- [ ] **AC-020**: Después del reload, el estado de validaciones previas se restaura

### 11.5 Inyección

- [ ] **AC-021**: El Main recibe instrucciones completas de las skills inyectadas
- [ ] **AC-022**: Los subagentes reciben solo la porción relevante de la skill
- [ ] **AC-023**: La inyección no excede ~18K tokens de contexto
- [ ] **AC-024**: Cuando excede, se aplica compresión selectiva correctamente

---

## 12. Configuración

### 12.1 Variables de Entorno

```bash
# Database
MEMORY_DB_HOST=localhost
MEMORY_DB_PORT=5432
MEMORY_DB_NAME=atomic_memory
MEMORY_DB_USER=atomic_user
MEMORY_DB_PASSWORD=<secreto>

# Embedding
EMBEDDING_MODEL_PATH=./models/embedding-gguf
EMBEDDING_DIMENSIONS=768

# Búsqueda
SEMANTIC_SIMILARITY_THRESHOLD=0.7
MAX_SEARCH_RESULTS=20
INJECTION_MAX_SKILLS=3

# Contexto
MAIN_CONTEXT_MAX_TOKENS=18000
SKILL_INJECTION_COMPRESSION_THRESHOLD=12000

# Stats
TRUSTED_SUCCESS_RATE_THRESHOLD=90
TRUSTED_MIN_USAGE_COUNT=5
DEPRECATED_SUCCESS_RATE_THRESHOLD=60
DEPRECATED_MIN_USAGE_COUNT=10
```

### 12.2 Config YAML

```yaml
atomic_memory:
  database:
    host: localhost
    port: 5432
    name: atomic_memory
    pool_size: 10
    ssl: false

  embedding:
    model_path: ./models/embedding-gguf
    dimensions: 768
    batch_size: 32

  search:
    similarity_threshold: 0.7
    max_results: 20
    scoring:
      semantic_weight: 0.5
      stack_overlap_weight: 0.2
      success_rate_weight: 0.2
      usage_count_weight: 0.1

  injection:
    max_skills: 3
    context_max_tokens: 18000
    compression_threshold: 12000

  lifecycle:
    trusted:
      success_rate_min: 90
      usage_count_min: 5
    deprecated:
      success_rate_max: 60
      usage_count_min: 10

  flush:
    auto_flush: true
    flush_after_task: true
    retry_backoff_base_ms: 1000
    retry_max_attempts: 3
```

---

## 13. State Machine de Task Instance

### 13.1 Estados y Transiciones

```
                    ┌─────────────┐
                    │  PENDING    │ ← Task creada, esperando ejecución
                    └──────┬──────┘
                           │ start
                           ▼
                    ┌─────────────┐
                    │  RUNNING    │ ← Subagente ejecutando
                    └──────┬──────┘
                           │
               ┌───────────┼───────────┐
               ▼           ▼           ▼
        ┌──────────┐ ┌──────────┐ ┌──────────┐
        │COMPLETED │ │  FAILED  │ │ CANCELLED│
        └────┬─────┘ └────┬─────┘ └────┬─────┘
             │            │            │
             │     retry? ├──── Yes ───┤
             │            │            │
             │            │ No         │
             │            ▼            │
             │     ┌──────────┐        │
             │     │ BLOCKED  │        │
             │     └────┬─────┘        │
             │          │              │
             ▼          ▼              ▼
        ┌─────────────────────────────────┐
        │        PERSISTED                │ ← Artefacto durable
        └─────────────────────────────────┘
```

### 13.2 Tabla de Transiciones

| Desde     | Evento          | A         | Condición                            |
| --------- | --------------- | --------- | ------------------------------------ |
| PENDING   | start           | RUNNING   | Subagente inicia ejecución           |
| RUNNING   | success         | COMPLETED | Todas las validaciones pasaron       |
| RUNNING   | fail            | FAILED    | Alguna validación crítica falló      |
| RUNNING   | cancel          | CANCELLED | Usuario o sistema cancela            |
| FAILED    | retry           | RUNNING   | retryable=true AND retry_count < max |
| FAILED    | no_retry        | BLOCKED   | retryable=false OR max retries       |
| BLOCKED   | manual_override | COMPLETED | Humano aprueba manualmente           |
| COMPLETED | persist         | PERSISTED | Siempre                              |
| BLOCKED   | persist         | PERSISTED | Siempre (con failed record)          |
| CANCELLED | persist         | PERSISTED | Siempre                              |

---

## 14. Integración con Otros Specs

### 14.1 Mapa de Integración

```
┌─────────────────────────────────────────────────────────────┐
│                     MEMORIA ATÓMICA                         │
│                         (Spec 07)                           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ▲ spec/03 (Chat IA)                                        │
│  │ • Main busca micro-skills antes de planificar           │
│  │ • Inyección de skills en contexto del Main              │
│  │ • Tareas complejas usan micro-skills como guía          │
│  │ • Flush/Reload restaura contexto del Main               │
│                                                             │
│  ▲ spec/05 (Headless Guardian)                              │
│  │ • Validación de skills contra validation_rules          │
│  │ • Loop Sentinel detecta skills que fallan repetidamente │
│  │ • Design Inspector valida contra design constraints     │
│                                                             │
│  ▲ spec/06 (Validaciones Chat LLM)                          │
│  │ • ValidationArtifacts se persisten en Memoria Atómica   │
│  │ • FlushHandoffArtifact se genera antes del flush        │
│  │ • FailedValidationRecords se persisten con contexto     │
│  │ • DelegationContracts se almacenan y referencian        │
│                                                             │
│  ▲ spec/01 (UI Contenedor Shell)                            │
│  │ • Configurar Sistema de Memoria Atómica                 │
│  │ • Status bar muestra estado de flush                    │
│                                                             │
│  ▲ spec/02 (Navegador WebView)                              │
│  │ • Configurar Sistema de Memoria Atómica                 │
│                                                             │
│  ▲ spec/04 (Editor de Código)                               │
│  │ • Micro-skills definen expected_files                   │
│  │ • Editor puede abrir archivos generados por skills      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 14.2 Referencias Cruzadas

| Spec                                 | Sección Relevante                  | Relación con Memoria Atómica              |
| ------------------------------------ | ---------------------------------- | ----------------------------------------- |
| `specs/03-ui-chat-ia.md`             | §11 Sistema de Tareas Complejas    | Usa micro-skills para gestionar subtareas |
| `specs/03-ui-chat-ia.md`             | §7.1 Perfil Único                  | Inyección de micro-skills en contexto     |
| `specs/03-ui-chat-ia.md`             | §7.2 Flujo de Delegación           | Skills guían la delegación                |
| `specs/03-ui-chat-ia.md`             | §7.7 Context Flush & Reload        | Flush/Reload protocol                     |
| `specs/05-headless-guardian.md`      | §5.8 Chat Output Validator         | §5.8 menciona integración pendiente       |
| `specs/06-validaciones-chat-llm.md`  | §9 Integración con Memoria Atómica | Modelo de persistencia y ciclo de vida    |
| `specs/06-validaciones-chat-llm.md`  | §7.4 Write Outside the Window      | FlushHandoffArtifact                      |
| `specs/06-validaciones-chat-llm.md`  | §9.3 Validaciones Fallidas         | FailedValidationRecord                    |
| `specs/01-ui-contenedor-shell.md`    | §8 Pendientes                      | Configurar Sistema de Memoria Atómica     |
| `specs/02-ui-navegador-webview.md`   | §11 Pendientes                     | Configurar Sistema de Memoria Atómica     |
| `specs/04-ui-editor-codigo.md`       | Actualización                      | Protocolo obligatorio                     |
| `Especificaciones Suite AI-First.md` | §3 Stack Tecnológico               | PostgreSQL + pgvector                     |

---

## 15. Pendientes de Especificación

### 15.1 Alta Prioridad

- [ ] Definir modelo de embedding a usar (local vs API, dimensiones)
- [ ] Definir formato exacto de STRACT.md y su schema
- [ ] Definir protocolo de migración de micro-skills entre versiones
- [ ] Definir límites de tamaño para instructions y constraints
- [ ] Definir política de backup de la base de datos

### 15.2 Media Prioridad

- [ ] Definir sistema de versionado de micro-skills (v1, v2, etc.)
- [ ] Definir sistema de tagging y folk de micro-skills
- [ ] Definir API para importar/exportar micro-skills (formato portable)
- [ ] Definir sistema de compartir micro-skills entre proyectos
- [ ] Definir métricas de rendimiento del sistema (latencia, throughput)

### 15.3 Baja Prioridad

- [ ] Soporte para micro-skills multi-agente (skills que requieren coordinación)
- [ ] Sistema de rating y feedback de micro-skills por usuarios
- [ ] Marketplace de micro-skills compartidas por la comunidad
- [ ] Visualización del grafo de dependencias de skills en la UI

---

## 16. Historial de Cambios

| Fecha      | Cambio                                                                     | Autor |
| ---------- | -------------------------------------------------------------------------- | ----- |
| 2026-05-01 | Spec inicial basado en análisis de specs/01-06 y especificaciones maestras | —     |
