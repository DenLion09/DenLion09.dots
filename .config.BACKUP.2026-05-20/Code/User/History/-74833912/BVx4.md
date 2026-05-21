# Exploration: IA Chat

## Current State

El proyecto **mi_suit** es una suite AI-First basada en **Tauri + React**. El Chat IA es el **orquestador central** del sistema. Actualmente NO hay código implementado - solo documentación de especificaciones en:

- `apps/IA_Chat.md` (spec de features)
- `general_specs.md` (arquitectura general)

El stack tecnológico definido:

- **Core**: Tauri (Rust)
- **UI**:
- **BD**: PostgreSQL + pgvector
- **LLM**: Modelos GGUF (mmap/NVMe) (no en mvp)

## Affected Areas

| Archivo            | Relevancia                         |
| ------------------ | ---------------------------------- |
| `apps/IA_Chat.md`  | Spec de features del Chat IA       |
| `general_specs.md` | Arquitectura general, fases, stack |
| `ia_chat/specs/`   | Directorio vacío para delta specs  |

## Approaches

| Approach                                                                                                                 | Pros                                      | Cons                                  | Complexity  |
| ------------------------------------------------------------------------------------------------------------------------ | ----------------------------------------- | ------------------------------------- | ----------- |
| **1. MVP First** — Implementar solo Fase MVP (chat básico, markdown, herramientas archivo/terminal, contexto automático) | Entrega valor rápido, arquitectura simple | Limita funcionalidades Phase 2        | Medium      |
| **2. Full Spec** — Implementar todo lo definido en apps/IA_Chat.md incluyendo MCP, Skills UI, Memoria persistente        | Feature completo, alineado con specs      | Mayor tiempo, más complejidad         | High        |
| **3. Core + Extensibility** — MVP con arquitectura preparada para Phase 2 (plugins MCP, skill registry)                  | Balance tiempo/feature, future-proof      | Requiere diseño de plugins anticipado | Medium-High |

## Recommendation

**Approach 3 (Core + Extensibility)** es el recomendado porque:

1. Permite entregar el MVP rápidamente
2. La arquitectura de plugins MCP y skill registry debe diseñarse desde el inicio
3. Evita rewrites cuando se agreguen features de Phase 2

**Prioridad de implementación sugerida:**

1. UI Chat con estados (IDLE → STREAMING)
2. Integración con LLM local/cloud (dashboard de proveedores)
3. Herramientas: leer/escribir/buscar archivos, terminal
4. Context Flush/Reload (integración con git + STRACT.md)
5. Arquitectura de plugins para MCP + Skills

## Risks

- **Sin código base**: Todo está por construir - requiere setup de Tauri primero
- **Dependencias externas**: IA SDK.rs
- **Integración Guardian**: El Communication Bus es crítico pero no bloqueante para MVP
- **Stack no chosen**: Editor engine (CodeMirror/Monaco), Event Bus, API Gateway pendientes

## Ready for Proposal

**Sí** — La exploración está lista. El siguiente paso es:

- **sdd-propose** para crear el change proposal formal con scope, approach, y rollback
- Debería incluir el setup de Tauri como dependencia, ya que todo el proyecto depende de él
