# **Especificaciones Técnicas: Suite AI-First (Proyecto TAI) V2**

> **Estado:** Planificación — Documento maestro de visión y arquitectura
> **Última actualización:** 2026-05-05
> **Documentos complementarios:** `herramientas-suite-completa.md` (catálogo completo), `specs/` (especificaciones técnicas detalladas)

---

## **1. Concepto y Visión**

### **¿Qué se quiere construir?**

Una **suite integral AI-First** que unifica productividad personal, desarrollo de software y automatización bajo un mismo ecosistema. No es un simple editor de código ni un asistente IA aislado — es un entorno donde la IA orquesta herramientas propias y externas, genera, valida y ejecuta software de forma autónoma en entornos aislados, y gestiona la productividad del usuario de extremo a extremo.

### **¿Por qué?**

Para resolver la fricción entre la concepción de una idea y su implementación técnica completa. Las herramientas actuales son fragmentadas: un IDE para código, un chatbot para IA, un suite ofimática para documentos, herramientas separadas para infraestructura. Este proyecto unifica todo bajo una **arquitectura AI-First** donde:

- La IA no es un complemento — es el **orquestador central**
- Cada acción es **explicable, reversible y basada en specs**
- El desarrollador se enfoca en **diseño de alto nivel**, no en tareas repetitivas
- La productividad personal y el desarrollo conviven en el **mismo ecosistema**

### **Filosofía del Producto**

| Principio                        | Descripción                                                                                                                                                            |
| :------------------------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Eficiencia Radical**           | Rendimiento máximo con consumo mínimo (8-16GB RAM). Tecnologías nativas, gestión de memoria en disco (mmap/NVMe). UI minimalista sin recursos innecesarios.            |
| **Inmutabilidad y Seguridad**    | El código/datos nunca se modifican directamente sin validación. Todo ocurre en capas virtuales (worktrees, entornos aislados). Zero Trust en todas las comunicaciones. |
| **Transparencia y Trazabilidad** | Cada acción de la IA es explicable, reversible y basada en una fuente de verdad (Spec-Driven). Logs completos de toda operación.                                       |
| **Minimalismo Funcional**        | Estética limpia, modo oscuro nativo, eliminación de ruidos visuales. Cada componente hace una cosa y la hace bien.                                                     |
| **Hosting Híbrido**              | Ejecución local primero. Opción a nube para trabajo desatendido. Acceso remoto desde móvil/dispositivo vinculado proximamente.                                         |
| **Extensibilidad**               | Arquitectura modular: cada herramienta es independiente. El usuario usa lo que necesita, cuando lo necesita.                                                           |

---

## **2. Arquitectura de Suite: UI Contenedor + Herramientas Independientes**

Este proyecto es una **SUITE** compuesta por múltiples herramientas/clientes, cada uno con su propia UI independiente, comunicados a través de servicios compartidos.

### **2.1 Componentes Arquitectónicos**

| Componente                | Descripción                                                                                                                                                  |
| :------------------------ | :----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **UI Contenedor (Shell)** | Aplicación principal Tauri que funciona como dock/launcher. Permite cargar y visualizar todas las herramientas dentro de sí misma. Consumo <100MB RAM.       |
| **Herramientas/Clientes** | Cada herramienta es una UI independiente con su propia lógica de presentación. Pueden ejecutarse dentro del contenedor O de forma autónoma.                  |
| **Backend/Servicios**     | Sistemas sin UI que comunican las herramientas: Headless Guardian, NTO Pipeline, Agente de IA, API Gateway, Event Bus. Funcionan como subprocesos separados. |

### **2.2 Diagrama Arquitectónico Completo**

```
┌──────────────────────────────────────────────────────────────────────────┐
│                        UI CONTENEDOR (SHELL)                             │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐        │
│  │  CHAT    │ │  EDITOR  │ │ BROWSER  │ │ TERMINAL │ │ OFIMÁTICA│  ...   │
│  │   IA     │ │  CODE    │ │ EMULADOR │ │          │ │ SUITE    │        │
│  └────┬─────┘ └────┬─────┘ └────┬─────┘ └────┬─────┘ └────┬─────┘        │
│       │            │            │            │            │              │
│       └────────────┴────────────┴────────────┴────────────┘              │
│                              │                                           │
│              ┌───────────────┴─────────────────┐                          │
│              │    BACKEND/SERVICIOS (sin UI)   │                         │
│              │  ┌──────────────────────────┐   │                         │
│              │  │  Headless Guardian       │   │ ← Zero Trust Motor      │
│              │  │  • Input/Output Guard    │   │   (validación universal)│
│              │  │  • Communication Bus     │   │                         │
│              │  │  • Loop Sentinel         │   │                         │
│              │  │  • Presentation Validator│   │                         │
│              │  └──────────────────────────┘   │                         │
│              │  ┌──────────────────────────┐   │                         │
│              │  │  NTO Pipeline            │   │ ← Orquestación IA       │
│              │  │  • Agente Arquitectura   │   │                         │
│              │  │  • Agente Coder          │   │                         │
│              │  │  • Agente Reviewer       │   │                         │
│              │  └──────────────────────────┘   │                         │
│              │  ┌──────────────────────────┐   │                         │
│              │  │  API Gateway             │   │ ← Unificación APIs      │
│              │  │  • Internal routing      │   │                         │
│              │  │  • External proxy        │   │                         │
│              │  │  • Auth & rate limiting  │   │                         │
│              │  └──────────────────────────┘   │                         │
│              │  ┌──────────────────────────┐   │                         │
│              │  │  Event Bus               │   │ ← Mensajería asíncrona  │
│              │  │  • Publish/Subscribe     │   │   entre componentes     │
│              │  │  • Event sourcing        │   │                         │
│              │  │  • Webhook dispatcher    │   │                         │
│              │  └──────────────────────────┘   │                         │
│              │  ┌──────────────────────────┐   │                         │
│              │  │  Redis                   │   │ ← Contexto inmediato    │
│              │  │  • Session cache         │   │                         │
│              │  │  • Micro-skills active   │   │                         │
│              │  │  • Task queue            │   │                         │
│              │  └──────────────────────────┘   │                         │
│              │  ┌──────────────────────────┐   │                         │
│              │  │  PostgreSQL + pgvector   │   │ ← Persistencia          │
│              │  │  • Micro-skills catalog  │   │                         │
│              │  │  • Task history          │   │                         │
│              │  │  • Vector search         │   │                         │
│              │  │  • User data             │   │                         │
│              │  └──────────────────────────┘   │                         │
│              └─────────────────────────────────┘                         │
└──────────────────────────────────────────────────────────────────────────┘
```

### **2.3 Puntos Clave**

- La UI Contenedor es **OPTIONAL** — cada herramienta puede correr de forma independiente
- Las herramientas se comunican con los servicios via **IPC** (Tauri Commands + Events)
- El usuario puede tener **múltiples herramientas abiertas** simultáneamente dentro del contenedor
- La UI Contenedor consume **<100MB RAM**
- Todas las comunicaciones inter-herramienta pasan por el **Guardian Communication Bus** (Zero Trust)
- Eventos asíncronos entre componentes van por el **Event Bus** (publish/subscribe)
- APIs internas y externas se unifican en el **API Gateway**

---

## **3. Catálogo Completo de Herramientas**

> Basado en `herramientas-suite-completa.md`. Cada herramienta marcada como **"Implementación propia"** requiere su propia especificación técnica.

### **3.1 Ofimática**

| Herramienta                           | Tipo                  | Prioridad | Estado Spec  |
| :------------------------------------ | :-------------------- | :-------- | :----------- |
| Procesador de texto                   | Implementación propia | Fase 4    | ❌ Pendiente |
| Hojas de cálculo                      | Implementación propia | Fase 4    | ❌ Pendiente |
| Presentaciones                        | Implementación propia | Fase 4    | ❌ Pendiente |
| Lector/Editor PDF                     | Implementación propia | Fase 3    | ❌ Pendiente |
| Notas (Markdown)                      | Implementación propia | Fase 2    | ❌ Pendiente |
| Diagramas (flujos, UML, arquitectura) | Implementación propia | Fase 2    | ❌ Pendiente |
| Cliente Email                         | Implementación propia | Fase 3    | ❌ Pendiente |
| Chat de equipo                        | Implementación propia | Fase 3    | ❌ Pendiente |
| Calendario                            | Implementación propia | Fase 3    | ❌ Pendiente |
| Gestor de tareas (Kanban, issues)     | Implementación propia | Fase 2    | ❌ Pendiente |
| Constructor de formularios            | Implementación propia | Fase 4    | ❌ Pendiente |
| Base de conocimiento (Wiki)           | Implementación propia | Fase 3    | ❌ Pendiente |

### **3.2 Desarrollo — Core**

| Herramienta                     | Tipo                                            | Prioridad  | Estado Spec                                                     |
| :------------------------------ | :---------------------------------------------- | :--------- | :-------------------------------------------------------------- |
| **Editor/IDE**                  | Implementación propia                           | **Fase 1** | ✅ `specs/04-ui-editor-codigo.md`, `specs/04b-file-explorer.md` |
| **Terminal**                    | Externa (Alacritty/Kitty/WezTerm)               | Fase 1     | ❌ Pendiente integración                                        |
| Control de versiones            | Git + GitUI                                     | Fase 1     | Parcial (git worktree en specs)                                 |
| Gestión de lenguajes y paquetes | apt/pacman + npm/pip/go/cargo + ofline solution | Fase 1     | ❌ Pendiente                                                    |

### **3.3 Desarrollo — Productividad**

| Herramienta                             | Tipo                  | Prioridad | Estado Spec  |
| :-------------------------------------- | :-------------------- | :-------- | :----------- |
| Tracking de tiempo (Pomodoro, horas)    | Implementación propia | Fase 2    | ❌ Pendiente |
| Gestor de snippets (búsqueda semántica) | Implementación propia | Fase 2    | ❌ Pendiente |
| Gestor de bookmarks                     | Implementación propia | Fase 2    | ❌ Pendiente |
| Gestor de hábitos                       | Implementación propia | Fase 3    | ❌ Pendiente |

### **3.4 Desarrollo — Web / API**

| Herramienta                   | Tipo                         | Prioridad  | Estado Spec                           |
| :---------------------------- | :--------------------------- | :--------- | :------------------------------------ |
| **Navegador WebView**         | Implementación propia        | **Fase 1** | ✅ `specs/02-ui-navegador-webview.md` |
| API Testing                   | Implementación propia        | Fase 2     | ❌ Pendiente                          |
| Proxy/Debug                   | mitmproxy / Browser DevTools | Fase 1     | Parcial (DevTools en browser spec)    |
| Local Dev (exponer localhost) | Implementación propia        | Fase 2     | ❌ Pendiente                          |

### **3.5 Desarrollo — Infraestructura**

| Herramienta               | Tipo                  | Prioridad | Estado Spec  |
| :------------------------ | :-------------------- | :-------- | :----------- |
| Infrastructure as Code    | Implementación propia | Fase 3    | ❌ Pendiente |
| Automatización de tareas  | Make / Taskfile       | Fase 1    | ❌ Pendiente |
| Pipeline CI/CD            | Implementación propia | Fase 2    | ❌ Pendiente |
| Gestor de contenedores    | Implementación propia | Fase 2    | ❌ Pendiente |
| Gestión de secretos       | Implementación propia | Fase 2    | ❌ Pendiente |
| Dashboard infraestructura | Implementación propia | Fase 3    | ❌ Pendiente |

### **3.6 Desarrollo — Testing y Calidad**

| Herramienta         | Tipo                              | Prioridad | Estado Spec                        |
| :------------------ | :-------------------------------- | :-------- | :--------------------------------- |
| Tests unitarios     | unit test (go test, jest, pytest) | Fase 1    | Parcial (Headless Guardian valida) |
| Tests automatizados | Implementación propia             | Fase 2    | ❌ Pendiente                       |
| E2E testing         | Playwright / Cypress              | Fase 2    | ❌ Pendiente                       |
| Linters             | Lenguaje-native                   | Fase 1    | Parcial (Editor spec)              |
| Pre-commit hooks    | git hooks                         | Fase 1    | ❌ Pendiente                       |

### **3.7 Desarrollo — Observabilidad**

| Herramienta                                  | Tipo                  | Prioridad | Estado Spec  |
| :------------------------------------------- | :-------------------- | :-------- | :----------- |
| **Monitorización** (logs, métricas, alertas) | Implementación propia | Fase 2    | ❌ Pendiente |
| **Dashboards** (métricas, KPIs)              | Implementación propia | Fase 2    | ❌ Pendiente |
| Gestor de webhooks                           | Implementación propia | Fase 2    | ❌ Pendiente |
| Feature flags                                | Implementación propia | Fase 2    | ❌ Pendiente |
| Traceador de errores                         | Implementación propia | Fase 2    | ❌ Pendiente |

### **3.8 Desarrollo — Diseño y Multimedia**

| Herramienta            | Tipo                  | Prioridad | Estado Spec              |
| :--------------------- | :-------------------- | :-------- | :----------------------- |
| Edición de imágenes    | GIMP (externa)        | Fase 3    | ❌ Pendiente integración |
| **UI Design con IA**   | Implementación propia | Fase 1    | ❌ Pendiente             |
| Diseño vectorial / SVG | Implementación propia | Fase 3    | ❌ Pendiente             |
| Grabación de pantalla  | OBS Studio (externa)  | Fase 3    | ❌ Pendiente integración |
| Capturas de pantalla   | Flameshot (externa)   | Fase 1    | ❌ Pendiente integración |

### **3.9 Seguridad**

| Herramienta                        | Tipo                            | Prioridad  | Estado Spec                        |
| :--------------------------------- | :------------------------------ | :--------- | :--------------------------------- |
| Gestión de contraseñas             | Bitwarden / KeePassXC (externa) | Fase 1     | ❌ Pendiente integración           |
| Encriptación y firmas              | GnuPG (externa)                 | Fase 2     | ❌ Pendiente integración           |
| **Headless Guardian** (Zero Trust) | Implementación propia           | **Fase 1** | ✅ `specs/05-headless-guardian.md` |

### **3.10 Automatización**

| Herramienta                               | Tipo                  | Prioridad | Estado Spec  |
| :---------------------------------------- | :-------------------- | :-------- | :----------- |
| **Motor de workflows** (tipo Zapier/Make) | Implementación propia | Fase 3    | ❌ Pendiente |
| **Generador de docs**                     | Implementación propia | Fase 2    | ❌ Pendiente |
| **Motor de reglas** (triggers/actions)    | Implementación propia | Fase 3    | ❌ Pendiente |
| **Integrador de APIs**                    | Implementación propia | Fase 3    | ❌ Pendiente |

### **3.11 Interoperabilidad**

| Herramienta                              | Tipo                  | Prioridad | Estado Spec  |
| :--------------------------------------- | :-------------------- | :-------- | :----------- |
| **Conector universal** (Adapter pattern) | Implementación propia | Fase 2    | ❌ Pendiente |
| **Importador/Exportador**                | Implementación propia | Fase 2    | ❌ Pendiente |
| **API Gateway**                          | Implementación propia | Fase 2    | ❌ Pendiente |
| **Event Bus**                            | Implementación propia | Fase 2    | ❌ Pendiente |

### **3.12 Reportes y Analíticas**

| Herramienta                 | Tipo                  | Prioridad | Estado Spec  |
| :-------------------------- | :-------------------- | :-------- | :----------- |
| **Generador de reportes**   | Implementación propia | Fase 3    | ❌ Pendiente |
| **Analíticas de uso**       | Implementación propia | Fase 3    | ❌ Pendiente |
| **Comparador de versiones** | Implementación propia | Fase 3    | ❌ Pendiente |

### **3.13 IA / Asistentes**

| Herramienta                         | Tipo                  | Prioridad  | Estado Spec                              |
| :---------------------------------- | :-------------------- | :--------- | :--------------------------------------- |
| **Chat IA** (Orquestador principal) | Implementación propia | **Fase 1** | ✅ `specs/03-ui-chat-ia.md`              |
| Validaciones Chat LLM               | Implementación propia | **Fase 1** | ✅ `specs/06-validaciones-chat-llm.md`   |
| Sistema de Memoria Atómica          | Implementación propia | **Fase 1** | ✅ `specs/07-sistema-memoria-atomica.md` |
| Asistente de IA gráfico             | Implementación propia | Fase 2     | ❌ Pendiente                             |

### **3.14 Herramientas Especificadas (specs/)**

| Spec                      | Archivo                               | Descripción                                                                                               |
| :------------------------ | :------------------------------------ | :-------------------------------------------------------------------------------------------------------- |
| **UI Contenedor (Shell)** | `specs/01-ui-contenedor-shell.md`     | Shell principal, dock, workspace, toolbar, status bar. Gestión de herramientas y navegación.              |
| **Navegador WebView**     | `specs/02-ui-navegador-webview.md`    | Navegador web integrado, DevTools, Source Maps reversos.                                                  |
| **Chat IA**               | `specs/03-ui-chat-ia.md`              | Interfaz de conversación con agente, mensajes, input, context sidebar. Animación Ciri.                    |
| **Editor de Código**      | `specs/04-ui-editor-codigo.md`        | Editor de código, tabs, LSP multi-lenguaje, integración con linters.                                      |
| **File Explorer**         | `specs/04b-file-explorer.md`          | Popup independiente para búsqueda y preview de archivos (Ctrl+P).                                         |
| **Headless Guardian**     | `specs/05-headless-guardian.md`       | Zero Trust motor con Input/Output Guards, Loop Sentinel, Communication Bus, Presentation Validator.       |
| **Validaciones Chat LLM** | `specs/06-validaciones-chat-llm.md`   | Streaming validation, Delegation Contracts, Context Management, Mensajería proactiva.                     |
| **Memoria Atómica**       | `specs/07-sistema-memoria-atomica.md` | DB relacional de micro-skills (PostgreSQL + pgvector). Búsqueda semántica, Flush/Reload, Skill injection. |

> **Nota:** Las specs detalladas son canonicales. Este documento resume la visión de alto nivel.

---

## **4. Núcleo Lógico: Spec-Driven Development (SDD)**

### **4.1 TON (Token Oriented Notation)**

DSL propio para comunicación interna entre agentes (NO para el usuario).

- **Usuario → Agente:** Lenguaje natural
- **Agente ↔ Agente:** Formato TON
- **Herramienta ↔ Herramienta:** Formato TON via Guardian Communication Bus
- **Validador:** El Headless Guardian convierte entrada y salida

```
Ejemplo flujo TON:
Usuario: "hazme un login con JWT"
     ↓
Headless Guardian (valida input)
     ↓
TON: {action: "create", entity: "auth", spec: "jwt"}
     ↓
Agente Principal → Agente Especialista
     ↓
Output en TON
     ↓
Headless Guardian (valida output)
     ↓
Usuario: Respuesta en lenguaje natural
```

### **4.2 NTO (Núcleo de Transpilación y Orquestación)**

Arquitectura de pipeline secuencial para MVP (evolutivo a multi-agent asíncrono).

| Etapa | Agente       | Responsabilidad             |
| :---- | :----------- | :-------------------------- |
| **1** | Arquitectura | Análisis, diseño, specs     |
| **2** | Coder        | Implementación de código    |
| **3** | Reviewer     | Validación, tests, security |

**Flujo completo:**

```
1. Usuario envía request en lenguaje natural
     ↓
2. Headless Guardian valida y convierte a TON
     ↓
3. Agente Arquitectura diseña solución → produce specs
     ↓
4. Headless Guardian valida specs (Spec Enforcer)
     ↓
5. Agente Coder implementa código
     ↓
6. Headless Guardian valida código (compila, tests, security)
     ↓
7. Agente Reviewer revisa calidad final
     ↓
8. Headless Guardian valida output final (Output Guard + Presentation Validator)
     ↓
9. Retorna respuesta a usuario
     ↓
10. Context Flush → Memoria Atómica persiste conocimiento
     ↓
11. Reload: STRACT.md + grafo de tareas + micro-skills
```

**Principio Zero Trust:** Ningún agente confía ciegamente en otro. Cada stage valida el output del anterior. **Ninguna herramienta se comunica directamente con otra** — todo pasa por el Guardian Communication Bus.

### **4.3 Perfil Único (Main)**

El agente Main opera bajo el modelo de **Perfil Único**:

- **NO** mantiene historial de chat largo
- Carga información de `STRACT.md` + git logs
- **Analiza la tarea, planifica y delega** a subagentes con micro-skills específicas
- Realiza **Context Flush** después de cada tarea validada
- La conversación es **bidireccional**: usuario envía mensajes Y Main envía actualizaciones proactivas
- Las herramientas también pueden enviar mensajes al Main o a subagentes en ejecución

---

## **5. Stack Tecnológico y Performance**

### **5.1 Tecnologías Base**

| Componente            | Tecnología                  | Propósito                                                                          |
| :-------------------- | :-------------------------- | :--------------------------------------------------------------------------------- |
| **Core**              | Tauri (Rust)                | Binario nativo ligero, seguridad de memoria, acceso a sistema de archivos          |
| **UI**                | React + FlyonUI             | Interfaz dinámica, rápida, accesible, modo oscuro nativo                           |
| **Editor Engine**     | TBD (CodeMirror 6 / Monaco) | Editor de código con LSP, syntax highlighting, autocompletado                      |
| **Base de Datos**     | Redis + PostgreSQL          | Contexto inmediato (Redis) + memoria vectorial persistente (PostgreSQL + pgvector) |
| **Inferencia**        | mmap / NVMe + GGUF          | Modelos en disco cuantizados (Q4_K, Q5_K) para ~4GB VRAM                           |
| **Modelo**            | TBD (código abierto)        | Modelo potente pero no colosal. GGUF Q4.                                           |
| **IPC**               | Tauri Commands + Events     | Comunicación entre UI y subprocesos                                                |
| **Communication Bus** | Headless Guardian           | Validación y enrutamiento de TODA comunicación inter-herramienta                   |
| **Event Bus**         | TBD                         | Mensajería asíncrona publish/subscribe entre componentes                           |
| **API Gateway**       | TBD                         | Unificación y proxy de APIs internas y externas                                    |

### **5.2 Modelo de Procesos**

```

UI Contenedor
├─ Chat IA (propia UI)

PROCESO PRINCIPAL (Tauri)
│
├── UI Contenedor
│   └── HERRAMIENTAS (UI Independientes)
│       ├── Chat IA (propia UI)
│       ├── Editor de Código (propia UI + LSP)
│       ├── Navegador/WebView (propia UI + DevTools)
│       ├── Terminal (propia UI)
│       ├── File Explorer (popup Ctrl+P)
│       ├── Ofimática Suite (procesador, hojas, presentaciones)
│       ├── PDF Reader/Editor
│       ├── Notas Markdown
│       ├── Diagramas (UML, flujos)
│       ├── Email Client
│       ├── Team Chat
│       ├── Calendario
│       ├── Task Manager (Kanban)
│       ├── Formularios
│       ├── Wiki / Base de conocimiento
│       ├── Time Tracking
│       ├── Snippet Manager
│       ├── Bookmark Manager
│       ├── Habit Tracker
│       ├── API Testing
│       ├── Local Dev Manager
│       ├── CI/CD Pipeline
│       ├── Container Manager
│       ├── Secrets Manager
│       ├── Infrastructure Dashboard
│       ├── Testing Suite
│       ├── Monitoring + Dashboards
│       ├── Webhook Manager
│       ├── Feature Flags
│       ├── Error Tracker
│       ├── UI Design with AI
│       ├── Vectorial/SVG Designer
│       ├── Workflow Engine
│       ├── Doc Generator
│       ├── Rule Engine
│       ├── API Integrator
│       ├── Universal Connector
│       ├── Import/Export Manager
│       ├── Report Generator
│       ├── Usage Analytics
│       ├── Version Comparator
│       └── AI Assistant (gráfico)
│
└── SUBPROCESOS (Servicios sin UI)
    ├── Headless Guardian (Zero Trust Motor)
    │   ├── Input Guard
    │   ├── Output Guard
    │   ├── Loop Sentinel
    │   ├── Communication Bus
    │   └── Presentation Layer Validator
    ├── NTO Pipeline (Arquitectura → Coder → Reviewer)
    ├── API Gateway (Internal routing + External proxy)
    ├── Event Bus (Publish/Subscribe + Event sourcing)
    ├── Redis (Contexto inmediato, cache de sesión)
    ├── PostgreSQL + pgvector (Memoria Atómica, persistencia)
    └── Modelo IA (mmap/NVMe, GGUF quantized)
```

### **5.3 Optimización de Memoria**

| Estrategia        | Descripción                                                                  |
| :---------------- | :--------------------------------------------------------------------------- |
| UI minimalista    | Sin frameworks pesados. Tauri + React consume <100MB RAM para el contenedor. |
| Lazy loading      | Cada herramienta se carga bajo demanda. No se instancian tools no usadas.    |
| Worktrees         | Código vivo aislado en ramas git, no en memoria.                             |
| Redis TTL         | Cache de sesión con expiración. Se limpia en cada Context Flush.             |
| Nube proximamente | Modelo + DB + worktrees en servidor remoto para trabajo desatendido.         |

### **5.4 Arquitectura de Targets**

| Fase        | Target                      | Descripción                                          |
| :---------- | :-------------------------- | :--------------------------------------------------- |
| **Fase 1**  | Navegador (WebView2/WebKit) | WebView integrado con DevTools, Source Maps reversos |
| **Fase 2+** | Emuladores adicionales      | iOS/Android según demanda                            |

---

## **6. Headless Guardian — Zero Trust Motor**

> **Máxima prioridad.** Especificación completa en `specs/05-headless-guardian.md`.

### **6.1 Responsabilidades**

| Función               | Descripción                                                          |
| :-------------------- | :------------------------------------------------------------------- |
| **Input Validation**  | Valida y sanitiza input de TODAS las herramientas al modelo          |
| **Output Validation** | Valida output de subagentes y pasos de implementación                |
| **Communication Bus** | Bus central de comunicación entre TODAS las herramientas de la suite |
| **Loop Detection**    | Bloquea ciclos infinitos con límites de retry configurables          |

> **Nota:** Security Scanner, Spec Enforcer y Design Inspector son **subagentes de IA** gestionados por el Chat IA (ver `specs/03-ui-chat-ia.md` §8). El Guardian valida sus inputs/outputs cuando se comunican con otros componentes a través del Communication Bus.

### **6.2 Subsistemas**

```
┌─────────────────────────────────────────────────────────┐
│                    HEADLESS GUARDIAN                    │
│                  (Secure Communication Bus)             │
├─────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐   │
│  │ INPUT GUARD  │  │ OUTPUT GUARD │  │ LOOP         │   │
│  │ • Sanitize   │  │ • Validate   │  │ SENTINEL     │   │
│  │ • Validate   │  │ • Filter     │  │ • Detect     │   │
│  │ • Classify   │  │ • Format     │  │ • Block      │   │
│  │ • Route      │  │ • Reject     │  │ • Unwind     │   │
│  └──────────────┘  └──────────────┘  └──────────────┘   │
│                                                         │
│  ┌──────────────────────────────────────────────────┐   │
│  │         COMMUNICATION BUS (Agent Comm)           │   │
│  │  • Valida y enruta TODO el tráfico               │   │
│  │  • Chat ↔ Navigator, Editor, Container, etc.     │   │
│  │  • + validación de seguridad por canal           │   │
│  └──────────────────────────────────────────────────┘   │
│                                                         │
│  ┌──────────────────────────────────────────────────┐   │
│  │         PRESENTATION LAYER VALIDATOR             │   │
│  │  • Reduce a información necesaria                │   │
│  │  • Sanitiza paths, formato de presentación       │   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

### **6.3 Canales de Comunicación (Guardian Bus)**

| Canal              | Tipo de Mensaje       | Validación Específica                |
| :----------------- | :-------------------- | :----------------------------------- |
| Chat ↔ Navigator   | URLs, comandos        | Allowlist domains                    |
| Chat ↔ Editor      | File paths, content   | Path traversal check                 |
| Chat ↔ Container   | Commands, env vars    | Command injection                    |
| Chat ↔ Explorer    | Paths, operations     | Path traversal                       |
| Chat ↔ Terminal    | Commands              | Command injection                    |
| Chat ↔ Ofimática   | Documentos, templates | Content sanitization                 |
| Chat ↔ API Testing | Requests, responses   | URL validation, payload sanitization |
| Chat ↔ Monitoring  | Queries, alerts       | Query injection prevention           |
| Todas ↔ Event Bus  | Eventos               | Schema validation                    |

---

## **7. Sistema de Comunicación Inter-Componentes**

### **7.1 Guardian Communication Bus (Síncrono/Validado)**

Todo tráfico síncrono entre herramientas pasa por el Guardian para validación Zero Trust. Especificación completa en `specs/05-headless-guardian.md` §5.5.

**Formato TON (Token Object Notation):**

```json
{
  "ton": "bus:message",
  "from": "chat",
  "to": "editor",
  "payload": {
    "action": "open_file",
    "path": "src/auth/login.go",
    "line": 42
  },
  "async": true,
  "callback": "bus:message:response"
}
```

### **7.2 Event Bus (Asíncrono/Publish-Subscribe)**

Sistema de mensajería asíncrona para eventos que NO requieren validación síncrona:

| Uso                    | Ejemplo                                            |
| :--------------------- | :------------------------------------------------- |
| **Notificaciones**     | "Build completado", "Test passed", "Nuevo email"   |
| **Webhooks**           | Dispatcher de webhooks entrantes/salientes         |
| **Event Sourcing**     | Historial inmutable de eventos del sistema         |
| **State broadcasting** | "Herramienta X cambió de estado"                   |
| **Trigger de reglas**  | Motor de reglas escucha eventos y dispara acciones |

### **7.3 API Gateway**

Unificación y proxy de APIs:

- **APIs internas:** Ruteo entre herramientas de la suite
- **APIs externas:** Proxy con auth, rate limiting, caching
- **API unificada:** Endpoint único para acceso programático a la suite
- **Conector universal:** Adapter pattern para conectar herramientas entre sí

---

## **8. Sistema de Validaciones Chat LLM**

> Especificación completa en `specs/06-validaciones-chat-llm.md`.

### **8.1 Dominios de Validación**

| Dominio                  | Qué valida                                      | Ejemplo                                                   |
| :----------------------- | :---------------------------------------------- | :-------------------------------------------------------- |
| **Mensajería proactiva** | Mensajes no solicitados del Main al usuario     | "Delegando al agente Coder...", "Progreso: 3/5 subtareas" |
| **Streaming en vivo**    | Tokens que llegan incrementalmente              | Respuesta del LLM token a token                           |
| **Delegaciones**         | Tareas enviadas a subagentes y sus resultados   | Delegation Contract con objetivos, budget, fail_policy    |
| **Contexto post-flush**  | Estado de validaciones después de Context Flush | Qué subtareas ya se validaron, cuáles fallaron            |

### **8.2 Pipeline de Validación**

```
[USUARIO] → [INPUT GUARDRAILS] → [MAIN ANALYSIS]
     ↓
[DIRECT RESPONSE] o [DELEGATION GUARDRAILS] → [SUBAGENT EXECUTION]
     ↓
[STREAMING VALIDATION] → [OUTPUT GUARDRAILS] → [CACHE] → [CHAT FRONTEND]
```

**Niveles de streaming:**

- **Tier 1 (bajo):** Stream + Post-Hoc (0ms latencia, retracta si falla)
- **Tier 2 (medio):** Buffer & Release (+200-500ms, pre-entrega por chunk)
- **Tier 3 (alto):** Non-Streaming (3-30s, evaluación completa)

---

## **9. Sistema de Memoria Atómica**

> Especificación completa en `specs/07-sistema-memoria-atomica.md`.

### **9.1 Qué es**

Base de datos relacional (PostgreSQL + pgvector) que almacena **micro-skills** — unidades mínimas de conocimiento ejecutable que los agentes usan para realizar tareas complejas de forma consistente y repetible.

### **9.2 Arquitectura de Persistencia**

| Capa                              | Tecnología            | Propósito                                                                                               |
| :-------------------------------- | :-------------------- | :------------------------------------------------------------------------------------------------------ |
| **Capa 1: Redis**                 | Cache de sesión       | Micro-skills activas, tasks en progreso, búsqueda cache. TTL: por sesión.                               |
| **Capa 2: PostgreSQL + pgvector** | Persistencia duradera | Catálogo global de micro-skills, embeddings vectoriales, historial de ejecuciones, artefactos durables. |

### **9.3 Ciclo de Vida de Micro-Skills**

```
DRAFT → VERIFIED → TRUSTED → (potencialmente) DEPRECATED
```

- **Creación:** Se genera automáticamente tras una tarea exitosa validada
- **Búsqueda:** Multi-etapa (semántica → stack → estado → ranking)
- **Inyección:** Top 3 más relevantes se inyectan en el contexto del Main
- **Evolución:** Se actualiza cuando se detectan nuevos patrones o tecnologías
- **Deprecación:** Cuando success_rate < 60% o tecnología obsoleta

### **9.4 Context Flush & Reload**

- **Flush:** Persiste FlushHandoffArtifact → actualiza stats → limpia Redis → limpia KV Cache
- **Reload:** Carga project profile → STRACT.md → último handoff → inyecta micro-skills → restaura validaciones

---

## **10. Funcionalidades Clave del Editor e Interacción**

| Funcionalidad                          | Descripción                                                                                                 |
| :------------------------------------- | :---------------------------------------------------------------------------------------------------------- |
| **Edición por Visión**                 | Vinculación directa entre emulador/navegador y código fuente mediante Source Maps reversos                  |
| **Multi-Agent Roleplay**               | Roles definidos (Arquitecto, Coder, Reviewer) con herramientas específicas y límites de jurisdicción        |
| **Intervención Humana Conversacional** | Streaming de audio y pantalla en tiempo real para resolver conflictos mediante voz o ajustes visuales       |
| **Git Worktree Flow**                  | Cada tarea de la IA y del usuario vive en una rama aislada; merge solo tras pasar tests automáticos         |
| **LSP Multi-lenguaje**                 | Protocolo de Servidor de Lenguaje para autocompletado, go-to-definition, diagnósticos en cualquier lenguaje |

---

## **11. Observabilidad y Validación**

### **11.1 Headless Guardian Observability**

| Métrica             | Descripción                      |
| :------------------ | :------------------------------- |
| **Validation Rate** | % de inputs que pasan validación |
| **Block Rate**      | % de requests bloqueados         |
| **Avg Latency**     | Tiempo promedio de validación    |
| **Loop Count**      | # de loops detectados            |
| **Security Alerts** | # de alertas de seguridad        |

### **11.2 System-Wide Observability**

- **Context-Streamer:** Alimentación constante de logs y métricas hacia la memoria de la IA para auto-corrección proactiva
- **Loop Detection:** Bloqueo de seguridad ante ciclos de error infinitos
- **Monitoring Dashboard:** Paneles personalizados de métricas y KPIs (herramienta propia, Fase 2)
- **Error Tracker:** Error tracking, stack traces, análisis de fallos (herramienta propia, Fase 2)
- **Webhook Manager:** Testing, monitoring y replay de webhooks (herramienta propia, Fase 2)

---

## **12. Roadmap**

### **Fase 0: Foundation (SDD Setup)**

| Componente             | Descripción                                     |
| :--------------------- | :---------------------------------------------- |
| Repo setup             | Estructura de repositorio, CI/CD básico         |
| Testing infrastructure | Framework de testing, linting, pre-commit hooks |
| Tauri scaffold         | Aplicación Tauri base con React + FlyonUI       |
| IPC framework          | Commands y events Tauri establecidos            |

### **Fase 1: Core AI + Development (MVP)**

| Componente                | Descripción                                                        | Spec                    |
| :------------------------ | :----------------------------------------------------------------- | :---------------------- |
| **UI Contenedor (Shell)** | Shell principal, dock, workspace, toolbar, gestión de herramientas | `specs/01`              |
| **Headless Guardian**     | Zero Trust motor completo — máxima prioridad                       | `specs/05`              |
| **Chat IA**               | Interfaz de conversación, animación Ciri, delegación               | `specs/03`              |
| **Editor de Código**      | Editor con LSP multi-lenguaje, file explorer popup                 | `specs/04`, `specs/04b` |
| **Navegador WebView**     | WebView integrado, DevTools, Source Maps reversos                  | `specs/02`              |
| **NTO Pipeline**          | Arquitectura → Coder → Reviewer                                    | Parcial en specs        |
| **Memoria Atómica**       | DB de micro-skills, Flush/Reload, skill injection                  | `specs/07`              |
| **Validaciones Chat LLM** | Streaming, delegation contracts, context management                | `specs/06`              |
| **Integración Modelo**    | Setup mmap/NVMe, modelo GGUF                                       | Pendiente               |
| **Integración Terminal**  | Terminal integrada (Alacritty/Kitty/WezTerm)                       | Pendiente               |

### **Fase 2: Productivity + Infrastructure**

| Componente               | Descripción                                                  |
| :----------------------- | :----------------------------------------------------------- |
| **Redis Context**        | Memoria de sesión inmediata, cache de micro-skills           |
| **Notas Markdown**       | Notas con sincronización                                     |
| **Diagramas**            | Diagramas de flujo, UML, arquitectura                        |
| **Task Manager**         | Kanban, proyectos, seguimiento de issues                     |
| **Time Tracking**        | Registro de horas, pomodoro, análisis de productividad       |
| **Snippet Manager**      | Biblioteca de código reutilizable con búsqueda semántica     |
| **Bookmark Manager**     | Curación de contenido, lectura posterior                     |
| **CI/CD Pipeline**       | Integración y despliegue continuo                            |
| **Container Manager**    | GUI/CLI para Docker, VMs, entornos aislados                  |
| **Secrets Manager**      | Variables de entorno, credenciales, .env manager             |
| **API Testing**          | Herramienta de testing de APIs                               |
| **Local Dev**            | Manejo de extensiones y paquetes en local, exponer localhost |
| **API Gateway**          | Unificación y proxy de APIs                                  |
| **Event Bus**            | Mensajería asíncrona publish/subscribe                       |
| **Conector Universal**   | Adapter pattern para conectar herramientas                   |
| **Import/Export**        | Migración de datos desde otras plataformas                   |
| **Doc Generator**        | Documentación automática desde código                        |
| **Monitoring**           | Logs, métricas, alertas de aplicaciones                      |
| **Dashboards**           | Paneles personalizados de métricas y KPIs                    |
| **Webhook Manager**      | Testing, monitoring y replay de webhooks                     |
| **Feature Flags**        | Gestión de funcionalidades activas/inactivas                 |
| **Error Tracker**        | Error tracking, stack traces                                 |
| **Asistente IA Gráfico** | Asistente visual con IA                                      |
| **Tests Automatizados**  | Framework de tests automatizados                             |
| **E2E Testing**          | Playwright/Cypress integración                               |
| **Integración GnuPG**    | Encriptación y firmas                                        |

### **Fase 3: Ofimática + Avanzado**

| Componente                   | Descripción                                      |
| :--------------------------- | :----------------------------------------------- |
| **PostgreSQL + pgvector**    | Memoria vectorial persistente (completa)         |
| **PDF Reader/Editor**        | Lector y editor de PDF                           |
| **Email Client**             | Cliente de email integrado                       |
| **Team Chat**                | Chat de equipo                                   |
| **Calendario**               | Gestión de eventos, reuniones, planificación     |
| **Wiki / Knowledge Base**    | Wiki estructurada, documentación de equipo       |
| **Habit Tracker**            | Seguimiento de rutinas, streaks, métricas        |
| **Infrastructure as Code**   | Herramienta propia de IaC                        |
| **Infrastructure Dashboard** | Dashboard unificado de infraestructura           |
| **UI Design con IA**         | Diseño UI asistido por IA                        |
| **Vectorial/SVG Designer**   | Diseño vectorial, SVG creator                    |
| **Integración GIMP**         | Edición de imágenes                              |
| **Integración OBS**          | Grabación de pantalla                            |
| **Workflow Engine**          | Automatizaciones tipo Zapier/Make                |
| **Rule Engine**              | Triggers y acciones basadas en eventos           |
| **API Integrator**           | Orquestación de APIs externas con mapeo de datos |
| **Report Generator**         | Reportes automáticos desde bases de datos        |
| **Usage Analytics**          | Métricas de uso de herramientas, patrones        |
| **Version Comparator**       | Diff visual de datos y configuraciones           |
| **Hosting Híbrido**          | Nube para trabajo desatendido                    |
| **Acceso Remoto**            | Mobile web interface                             |

### **Fase 4: Suite Completa**

| Componente              | Descripción                                             |
| :---------------------- | :------------------------------------------------------ |
| **Procesador de Texto** | Word processor propio                                   |
| **Hojas de Cálculo**    | Spreadsheet propio                                      |
| **Presentaciones**      | Presentaciones/slides propio                            |
| **Formularios**         | Constructor de formularios que alimentan bases de datos |
| **Emuladores**          | iOS/Android según demanda                               |

---

## **13. Pendientes de Decisión**

### **Críticos (Fase 1)**

- [ ] Selección de modelo de código abierto (Qwen2.5-Coder / DeepSeek-Coder / otro)
- [ ] Selección de editor engine (CodeMirror 6 / Monaco / Ace)
- [ ] Configuración de thresholds para Loop Detection (Retry=3, Same Output=2)
- [ ] Definir modelo de embedding para búsqueda semántica de micro-skills
- [ ] Configurar allowlists/blocklists iniciales del Guardian
- [ ] Definir lista exacta de herramientas iniciales para el contenedor

### **Importantes (Fase 1-2)**

- [ ] Definir shortcuts de teclado por defecto para todas las herramientas
- [ ] Definir configuración de temas (dark/light)
- [ ] Estructura de payloads IPC (investigar formato estándar)
- [ ] Definir qué DevTools features incluir en el navegador
- [ ] Configurar Source Map generation para frameworks (React, Vue, Svelte)
- [ ] Definir política de cookies por defecto en el navegador
- [ ] Selección de motor de búsqueda de texto (ripgrep / native)
- [ ] Definir lenguajes soportados inicialmente en el editor
- [ ] Configurar linters y formatters por defecto

### **Estratégicos (Fase 2+)**

- [ ] Strategy de hosting en nube (si aplica)
- [ ] Prioridad de emuladores adicionales (iOS/Android)
- [ ] Configuración de proxy para el navegador
- [ ] Integración con herramientas externas (GIMP, OBS, Flameshot, Bitwarden, etc.)
- [ ] Definir stack tecnológico para Event Bus
- [ ] Definir arquitectura de API Gateway
- [ ] Strategy de migración de datos desde otras plataformas

---

## **14. Principios de Arquitectura**

### **14.1 Zero Trust Universal**

**Toda** comunicación entre herramientas pasa por el Guardian Communication Bus para validación. Sin excepciones.

### **14.2 Herramientas Independientes**

Cada herramienta es un módulo autónomo con su propia UI. El contenedor es opcional. Las herramientas pueden ejecutarse de forma standalone.

### **14.3 Spec-Driven**

Cada herramienta debe tener su propia especificación técnica antes de implementación. Las specs son canonicales.

### **14.4 AI-First, No AI-Only**

La IA orquesta — no reemplaza. El usuario siempre tiene el control final. Cada acción de la IA es transparente, validada y reversible.

### **14.5 Progressive Enhancement**

- **Fase 1:** Desarrollo core + IA (MVP funcional)
- **Fase 2:** Productividad + infraestructura (suite de desarrollo completa)
- **Fase 3:** Ofimática + avanzado (suite integral)
- **Fase 4:** Suite completa (ofimática full + emuladores)

### **14.6 Memoria Persistente**

El conocimiento no se pierde. Micro-skills sobreviven al Context Flush, se acumulan, evolucionan y mejoran con el uso.

---

## **15. Resumen de Brechas Detectadas**

Al cruzar `herramientas-suite-completa.md` con el estado actual de especificaciones, se identificaron las siguientes categorías sin specs detalladas que necesitan ser creadas antes de implementación:

| Categoría                  | Herramientas sin spec  | Specs necesarias                            |
| :------------------------- | :--------------------- | :------------------------------------------ |
| **Ofimática**              | 12 herramientas        | 4-6 specs (agrupar por tipo)                |
| **Productividad**          | 4 herramientas         | 1-2 specs                                   |
| **Infraestructura**        | 6 herramientas         | 2-3 specs                                   |
| **Observabilidad**         | 5 herramientas         | 1-2 specs                                   |
| **Automatización**         | 4 herramientas         | 1-2 specs                                   |
| **Interoperabilidad**      | 4 herramientas         | 1 spec (API Gateway + Event Bus + Conector) |
| **Reportes**               | 3 herramientas         | 1 spec                                      |
| **Diseño**                 | 2 herramientas propias | 1 spec                                      |
| **Integraciones externas** | 5 herramientas         | Docs de integración                         |

**Total estimado de specs nuevas:** ~15-20 especificaciones adicionales antes de que el proyecto esté completamente especificado.
