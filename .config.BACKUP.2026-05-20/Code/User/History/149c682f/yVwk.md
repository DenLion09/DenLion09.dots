# CR-001: Arquitectura de Persistencia — PostgreSQL vs In-Memory

## Metadata

- **ID:** CR-001
- **Prioridad:** CRÍTICA
- **Esfuerzo estimado:** M (Medio)
- **Hallazgos relacionados:** DM-001, DM-018, SPEC-007, SPEC-032
- **Fecha:** 2026-05-08

---

## Descripción

Contradicción documentada entre el Documento Maestro y las especificaciones respecto al sistema de persistencia. El documento indica PostgreSQL como almacenamiento primario (sección 9.2), mientras que secciones anteriores mencionan "In-Memory Cache" sin clarificar roles. Los roles de cada storage nunca se definen formalmente.

---

## Fundamento Técnico

### Problema Identificado

| Fuente         | Afirmación                                 | Sección |
| -------------- | ------------------------------------------ | ------- |
| DM sección 9.2 | PostgreSQL como persistencia primaria      | DM      |
| DM sección 2.1 | In-Memory Cache                            | DM      |
| DM sección 5.1 | PostgreSQL en stack                        | DM      |
| DM sección 9.4 | FlushHandoffArtifact sin schema            | DM      |
| SPEC-032       | Presupuesto tokens sin considerar overhead | SPEC-07 |

### Análisis del Problema

1. **Conflicto semántico**: "In-Memory Cache" sugiere volatidad, pero el sistema requiere persistencia de conversaciones, contextos y micro-skills.

2. **Sin límites definidos**: No existe documentación sobre:
   - Qué datos viven en PostgreSQL
   - Qué datos viven en caché in-memory
   - Cuándo se promociona un dato de caché a persistencia
   - Estrategia de invalidación de caché

3. **FlushHandoffArtifact huérfano**: Se menciona en DM-9.4 como artefacto del pipeline NTO, pero su schema nunca se define ni se especifica su persistencia.

4. **Budget tokens incompleto**: SPEC-032 identifica que el presupuesto de tokens no considera el overhead del system prompt, lo que afecta directamente la planificación de capacidad.

---

## Impacto

### Si No Se Resuelve

- Impossibilidad de implementar almacenamiento de forma coherente
- Riesgo de pérdida de datos por inconsistencia entre componentes
- Impossibilidad de dimensionar infraestructura
- Conflictos en runtime entre múltiples implementadores

### Si Se Resuelve

- Claridad arquitectónica sobre dual storage
- Base sólida para implementación de caché y persistencia
- Definición de schema para FlushHandoffArtifact
- Dimensionamiento correcto de infraestructura

---

## Solución Propuesta

### Paso 1: Definir Modelo de Datos Dual

```
┌─────────────────────────────────────────────────────────────┐
│                    FLUJO DE DATOS                            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────┐     ┌──────────┐     ┌──────────────────┐   │
│  │ Request  │────▶│ In-Mem   │────▶│ PostgreSQL       │   │
│  │ incoming │     │ Cache    │     │ (persistência)   │   │
│  └──────────┘     └──────────┘     └──────────────────┘   │
│                        │                    │               │
│                        ▼                    ▼               │
│              ┌────────────────┐   ┌──────────────────┐   │
│              │ Hot data:      │   │ Cold data:       │   │
│              │ - Session      │   │ - History        │   │
│              │ - Conversación │   │ - Artefactos     │   │
│              │ - Contexto     │   │ - Micro-skills   │   │
│              │ - Buffers      │   │ - Embeddings     │   │
│              └────────────────┘   └──────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Paso 2: Definir Estrategia de Flush

| Tipo de Dato        | Trigger de Flush        | Destino    |
| ------------------- | ----------------------- | ---------- |
| Conversación activa | Cada 30s o fin de turno | PostgreSQL |
| Buffer de tokens    | 50-100 tokens threshold | PostgreSQL |
| Artefacto generado  | Fin de tarea            | PostgreSQL |
| Micro-skill nueva   | Inmediato               | PostgreSQL |
| Context LTM         | Cada N interacciones    | PostgreSQL |
| Session state       | In-memory (no flush)    | RAM        |

### Paso 3: Definir FlushHandoffArtifact Schema

```typescript
interface FlushHandoffArtifact {
  // Metadata
  id: string; // UUID v4
  type: "context" | "artifact" | "micro-skill";
  timestamp: number; // Unix epoch ms
  source: "NTO" | "MAIN" | "subagent";

  // Content
  payload: {
    data: any; // Contenido estructurado en TON
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

### Paso 4: Especificar Estrategia de Caché

```typescript
interface CacheStrategy {
  // LRU cache para datos hot
  maxSize: string; // e.g., "500MB" o "10000 items"
  evictionPolicy: "LRU" | "LFU" | "TTL";

  // Warm-up strategy
  preloadRecent: number; // Reconstruir últimos N contextos al start

  // Invalidación
  invalidationEvents: string[]; // Eventos que invalidan caché
  propagateChanges: boolean; // Push vs pull para sincronización
}
```

---

## Criterios de Aceptación

- [ ] Documento de Arquitectura de Persistencia creado (ADR format)
- [ ] Schema de FlushHandoffArtifact formalmente definido en TON
- [ ] Tabla de mapeo datos → storage (PostgreSQL vs In-Memory)
- [ ] Estrategia de Flush documentada con triggers y thresholds
- [ ] Estrategia de Caché con política de eviction definida
- [ ] Impacto en budget de tokens cuantificado
- [ ] Validado contra SPEC-007 y SPEC-032 existentes

---

## Archivos Afectados

| Archivo                             | Acción                         |
| ----------------------------------- | ------------------------------ |
| `docs/arquitectura/persistencia.md` | Crear nuevo                    |
| `specs/07-*.md`                     | Actualizar schema micro-skills |
| `specs/05-*.md`                     | Actualizar pipeline NTO        |
| `documento-maestro.md`              | Actualizar sección 9.x         |

---

## Dependencias

- **CR-003** (Definición TON): Necesita formato TON para schemas
- **CR-004** (Protocolo Flush/Reload): Depende de estrategia de persistencia

---

_Revisado: DM-001, DM-018_
