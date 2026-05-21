# mi_suit

> **Suite AI-First de productividad y desarrollo**

Una suite integral de productividad donde la IA no es un complemento — es el **orquestador central** que ejecuta, valida y gestiona tareas de forma autónoma en entornos aislados.

---

## El Problema

Los herramientas de IA actuales tienen un problema fundamental: son **reactivas**. Responden a lo que el usuario pide, pero no planifican, norastrean ni ejecutan de forma autónoma.

Además, la fragmentación es la norma:

- Un chat para conversar con IA
- Un editor de código para programar
- Un navegador para investigar
- Un gestor de notas para documentar
- Un sistema de memoria independiente

Cada herramienta vive en su propio silo. No comparten contexto. No se comunican. Y el usuario termina haciendo el trabajo que debería hacer la máquina: orquestar tareas entre aplicaciones.

## La Solución

**mi_suit** es una suite unificada donde:

- ✅ La IA **orquesta** trabajo entre herramientas (no solo responde)
- ✅ El contexto **persiste** entre sesiones via memoria atómica
- ✅ Cada herramienta es **modular** y puede evolucionar independientemente
- ✅ La ejecución es **transparente**: todo es trazable y reversible (Spec-Driven Development)

---

## Stack Tecnológico

| Componente           | Tecnología                                         | Propósito                                                             |
| :------------------- | :------------------------------------------------- | :-------------------------------------------------------------------- |
| **Core**             | [Tauri](https://tauri.app/) (Rust)                 | Binario nativo ligero, seguridad de memoria                           |
| **UI**               | [Leptos](https://leptos.dev/) (Rust)               | Framework reactivo, integración nativa con Tokio                      |
| **LLM SDK**          | [AI SDK.rs](https://github.com/tmcdonell/aisdk-rs) | Capa unificada para 70+ providers (Ollama, OpenAI, Anthropic, Google) |
| **Editor**           | TBD (CodeMirror 6 / Monaco)                        | Editor con LSP, syntax highlighting                                   |
| **Base de Datos**    | PostgreSQL + pgvector                              | Memoria relacional + búsqueda semántica vectorial                     |
| **Inferencia Local** | [Ollama](https://ollama.com/)                      | Modelos locales (GGUF) con mmap/NVMe                                  |
| **Markdown**         | pulldown-cmark                                     | GitHub Flavored Markdown rendering                                    |

---

## Arquitectura

```
┌─────────────────────────────────────────────────────────────┐
│                    APLICACIONES (UI)                        │
│    Chat IA  │  Editor  │  WebView  │  File Explorer  │ ... │
└─────────────┴──────────┴───────────┴─────────────────┴──────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│              HEADLESS GUARDIAN (Communication Bus)          │
│  • Input Guard  • Output Guard  • Loop Sentinel             │
└─────────────┬───────────────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────────────────────────┐
│                      SERVICIOS                              │
│  Memoria Atómica  │  NTO Pipeline  │  Event Bus  │  ...    │
└─────────────────────────────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────────────────────────┐
│                 PERSISTENCIA (PostgreSQL)                   │
│  Micro-skills  │  Task Instances  │  Project Profiles        │
└─────────────────────────────────────────────────────────────┘
```

### Flujo de Ejecución

```
[USUARIO] → [CHAT IA] → [GUARDIAN] → [MAIN AGENT]
                                             │
                          ┌──────────────────┼──────────────────┐
                          ▼                  ▼                  ▼
                   [ARQUITECTO]       [CODER]          [REVIEWER]
                          │                  │                  │
                          └──────────────────┼──────────────────┘
                                            ▼
                                     [OUTPUT GUARD]
                                            │
                                            ▼
                                   [CHAT IA] → [USUARIO]
```

---

## Fases de Desarrollo

| Fase       | Nombre     | Descripción                                            |
| :--------- | :--------- | :----------------------------------------------------- |
| **Fase 0** | Foundation | Setup de repo, testing infra, Tauri scaffold, IPC      |
| **Fase 1** | MVP        | Chat IA, Editor de Código, WebView, Memoria Atómica    |
| **Fase 2** | Extensión  | UI Design, Notas Markdown, Diagramas, Automatización   |
| **Fase 3** | Suite      | Ofimática, interoperabilidad avanzada, hosting híbrido |

### Estado Actual

- **Fase 1 (MVP)** en desarrollo activo
- Repo principal: `ia_chat/IA-Chat-DenLion09` — Chat IA con AI SDK.rs

---

## Principios Fundamentales

| Principio                        | Descripción                                        |
| :------------------------------- | :------------------------------------------------- |
| **Eficiencia Radical**           | Rendimiento máximo con consumo mínimo (8-16GB RAM) |
| **Inmutabilidad y Seguridad**    | Zero Trust, capas virtuales aisladas               |
| **Transparencia y Trazabilidad** | Cada acción es explicable, reversible (SDD)        |
| **Minimalismo Funcional**        | Estética limpia, modo oscuro nativo                |
| **Hosting Híbrido**              | Ejecución local primero, opcional nube             |
| **Extensibilidad**               | Arquitectura modular, herramientas independientes  |

---

## Conceptos Clave

| Término            | Definición                                                                |
| :----------------- | :------------------------------------------------------------------------ |
| **Micro-Skill**    | Unidad atómica de conocimiento ejecutable con instrucciones y constraints |
| **Skill Graph**    | Grafo de dependencias entre micro-skills                                  |
| **Context Flush**  | Protocolo de limpieza del KV Cache después de cada tarea                  |
| **Context Reload** | Recarga de estado + micro-skills después del flush                        |
| **SDD**            | Spec-Driven Development — metodología basada en specs                     |
| **FSM**            | Finite State Machine con guards para validación de agentes                |

---

## Estructura del Proyecto

```
mi_suit/
├── general_specs.md      # Spec maestro del proyecto
├── README.md             # Este archivo
├── ia_chat/
│   └── IA-Chat-DenLion09/ # MVP: Chat IA en Rust
│       ├── src/           # Código fuente Rust
│       ├── specs/         # Especificaciones detalladas
│       ├── tests/         # Tests TDD
│       └── .mi_suit/      # Agentes y skills
├── editor/
│   └── Editor.md          # Spec del editor de código
└── .atl/
    └── skill-registry.md  # Registro de skills del proyecto
```

---

## Primeros Pasos

### Requisitos

- Rust 1.75+
- Node.js 18+ (para Tauri)
- PostgreSQL 15+ (para memoria atómica)
- Ollama (para inferencia local)

### Desarrollo

```bash
# Chat IA MVP
cd ia_chat/IA-Chat-DenLion09
cargo test
cargo run --bin chat_ui
```

---

##why This Exists

La visión es simple: **herramientas que trabajan para ti, no al revés**.

La mayoría de las herramientas de "IA" hoy son modelos de chat sofisticados. Pero un asistente real debería:

1. **Entender** qué estás tratando de lograr
2. **Planificar** los pasos necesarios
3. **Ejecutar** en tu nombre (con tu permiso)
4. **Validar** que el resultado es correcto
5. **Recordar** lo que aprendió para la próxima vez

**mi_suit** construye ese asistente: un orquestador de trabajo que vive en tu máquina, entiende tu contexto, y ejecuta tareas autonomously.

---

## Licencia

MIT — Ver `LICENSE` para detalles.

---

_Construido con Spec-Driven Development y la convicción de que la IA debe ser un compañero de trabajo, no un chatbot._
