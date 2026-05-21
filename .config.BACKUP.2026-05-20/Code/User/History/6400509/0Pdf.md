# SPEC — Suite AI-First (Proyecto TAI)

> **Estado:** Planificación — Documento maestro de visión y arquitectura
> **Última actualización:** 2026-05-09
> **Versión:** 2.0 (Consolidada)

---

## 1. Visión y Filosofía

### 1.1 Concepto

Una **suite integral AI-First** que unifica productividad personal, desarrollo de software y automatización bajo un mismo ecosistema. La IA no es un complemento — es el **orquestador central** que ejecuta, valida y gestiona tareas de forma autónoma en entornos aislados.

### 1.2 Principios Fundamentales

| Principio                        | Descripción                                                                        |
| :------------------------------- | :--------------------------------------------------------------------------------- |
| **Eficiencia Radical**           | Rendimiento máximo con consumo mínimo (8-16GB RAM). UI minimalista.                |
| **Inmutabilidad y Seguridad**    | Zero Trust en todas las comunicaciones. Todo ocurre en capas virtuales aisladas.   |
| **Transparencia y Trazabilidad** | Cada acción es explicable, reversible y basada en specs (Spec-Driven Development). |
| **Minimalismo Funcional**        | Estética limpia, modo oscuro nativo. Cada componente hace una cosa bien.           |
| **Hosting Híbrido**              | Ejecución local primero. Opcional nube para trabajo desatendido.                   |
| **Extensibilidad**               | Arquitectura modular: cada herramienta es independiente.                           |

---

## 2. Catálogo de Componentes

### 2.1 Aplicaciones (UI)

| #   | Aplicación            | Spec | Prioridad MVP | Descripción                                                  |
| :-- | :-------------------- | :--- | :------------ | :----------------------------------------------------------- |
| 1   | **Chat IA**           |      | ✅ SI         | Interfaz de conversación con el agente Main. Animación Ciri. |
| 2   | **Editor de Código**  |      | ✅ SI         | Editor con LSP, syntax highlighting, autocompletado.         |
| 3   | **Navegador WebView** |      | ✅ SI         | WebView integrado con DevTools y Source Maps reversos.       |
| 4   | **File Explorer**     |      | ✅ SI         | búsqueda de archivos.                                        |

### 2.2 Servicios (Backend/Sin UI)

| #   | Servicio                       | Spec                                  | Prioridad MVP | Descripción                                                              |
| :-- | :----------------------------- | :------------------------------------ | :------------ | :----------------------------------------------------------------------- |
| 1   | **Sistema de Memoria Atómica** | `specs/07-sistema-memoria-atomica.md` | ✅ SI         | PostgreSQL + pgvector. Globals rules, Coontext Bank Micro-skills Bank. I |
| 2   | **Headless Guardian**          | `specs/05-headless-guardian.md`       | ⚠️ PARCIAL    | Zero Trust Motor: Input/Output Guards, Loop Sentinel, Communication Bus. |
| 3   | **Validaciones Chat LLM**      | `specs/06-validaciones-chat-llm.md`   | ⚠️ PARCIAL    | Streaming validation, Delegation Contracts, Context Management.          |

---

## 3. Sistema de Fases de Desarrollo

### 3.1 Visión General

El desarrollo se organiza en **4 fases** basadas en escalabilidad. Cada fase construye sobre la anterior, priorizando el MVP funcional.

```
┌─────────────────────────────────────────────────────────────┐
│                    DESARROLLO ESCALABLE                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   FASE 0        FASE 1        FASE 2        FASE 3          │
│   (Setup)  ───► (MVP)   ───► (Extensión) ───► (Suite)       │
│                                                             │
│   Infra base    Core AI       Productividad    Ofimática    │
│   Testing       Editor        Infra             Avanzado    │
│   Tauri         WebView       Automatización   Interoperab. │
│                Memoria        Observabilidad   Reportes     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 3.2 Fase 0: Foundation (Setup)

**Objetivo:** Infraestructura base lista para desarrollo.

| Componente             | Descripción                                     | Estado       |
| :--------------------- | :---------------------------------------------- | :----------- |
| Repo setup             | Estructura de repositorio, CI/CD básico         | ❌ Pendiente |
| Testing infrastructure | Framework de testing, linting, pre-commit hooks | ❌ Pendiente |
| Tauri scaffold         | Aplicación Tauri                                | ❌ Pendiente |
| IPC framework          | Commands y events Tauri establecidos            | ❌ Pendiente |

### 3.3 Fase 1: MVP (Core AI + Development)

**Objetivo:** Suite funcional con las 4 apps/core services necesarios para desarrollo asistido por IA.

> **Prioridad máxima.** Esta fase entrega valor inmediato: chat con agente, editor de código, navegador, y memoria persistente.

#### 3.3.1 Entregables MVP

| Entregable                | Tipo     | Dependencias Internas | Descripción                                                                                                                                |
| :------------------------ | :------- | :-------------------- | :----------------------------------------------------------------------------------------------------------------------------------------- |
| **Chat IA**               | App      | Guardian, Memoria     | Interfaz conversacional con Main. Animación Ciri. Estados: IDLE, LISTENING, THINKING, DELEGATING, WORKING, STREAMING, ERROR.               |
| **Editor de Código**      | App      | File Explorer         | Editor con LSP multi-lenguaje, tabs, syntax highlighting.                                                                                  |
| **Navegador WebView**     | App      | —                     | WebView2/WebKit integrado, DevTools, Source Maps reversos.                                                                                 |
| **Memoria Atómica**       | Servicio | PostgreSQL            | DB de micro-skills, búsqueda semántica (pgvector), Flush/Reload, skill injection.                                                          |
| **Headless Guardian**     | Servicio | —                     | Input Guard, Output Guard, Loop Sentinel, Communication Bus. **Funcionalidad core: NO bloquea el MVP, pero es requerido para producción.** |
| **Validaciones Chat LLM** | Servicio | Guardian              | Streaming validation, delegation contracts. **Funcionalidad core: NO bloquea el MVP, pero es requerido para producción.**                  |

#### 3.3.2 Secuencia de Implementación MVP (Orden Sugerido)

```
ORDEN DE IMPLEMENTACIÓN (Topológico):

[1] Tauri Scaffold + IPC
        │
        ▼
[2] Memoria Atómica (PostgreSQL + pgvector)
        │
        ├──► [3] Chat IA (sin Guardian completo)
        │         │
        │         ▼
        │    [4] Editor de Código
        │         │
        │         ▼
        │    [5] File Explorer
        │         │
        │         ▼
        │    [6] Navegador WebView
        │         │
        │         ▼
        └──► [7] Headless Guardian (Input/Output Guards)
                      │
                      ▼
                 [8] Validaciones Chat LLM
```

**Nota:** El Guardian y las validaciones avanzadas no bloquean el MVP inicial, pero deben integrarse antes de producción.

#### 3.3.3 Criterios de Éxito MVP

- [ ] El usuario puede abrir el Chat IA y enviar mensajes en lenguaje natural
- [ ] El Main (agente) responde y delega tareas a subagentes
- [ ] El Editor permite abrir, editar y guardar archivos con syntax highlighting
- [ ] El File Explorer permite buscar archivos por nombre y contenido
- [ ] El Navegador WebView carga páginas web y permite navegación básica
- [ ] El sistema de Memoria Atómica persiste micro-skills entre sesiones
- [ ] El Context Flush limpia la sesión del chat sin perder datos en memoria
- [ ] Las apps se comunican entre sí a través del Guardian Communication Bus

---

### 3.4 Fase 2: Extensión (Productividad + Infraestructura)

**Objetivo:** Ampliar capacidades de productividad, automatización y observabilidad.

#### 3.4.1 Aplicaciones

| Aplicación                     | Descripción                                                   |
| :----------------------------- | :------------------------------------------------------------ |
| **UI Design con IA**           | App independiente, Diseño UI asistido por IA.                 |
| **Notas Markdown**             | Notas con sincronización, Markdown preview.                   |
| **Diagramas**                  | Diagramas de flujo, UML, arquitectura (Mermaid.js integrado). |
| **Gestor de Tareas y eventos** | Kanban, proyectos, seguimiento de issues, calendario          |
| **File Explorer**              | App independiente, búsqueda por nombre/texto, preview.        |
| **Time Tracking**              | Registro de horas, Pomodoro, análisis de productividad.       |
| **Snippet Manager**            | Biblioteca de código reutilizable con búsqueda semántica.     |
| **API Testing**                | Herramienta de testing de APIs REST/GraphQL.                  |
| **Container Manager**          | GUI/CLI para Docker, VMs, entornos aislados.                  |
| **Secrets Manager**            | Variables de entorno, credenciales, .env manager.             |

#### 3.4.2 Servicios

| Servicio            | Descripción                                               |
| :------------------ | :-------------------------------------------------------- |
| **Event Bus**       | Mensajería asíncrona publish/subscribe entre componentes. |
| **API Gateway**     | Unificación y proxy de APIs internas y externas.          |
| **Monitoring**      | Logs, métricas, alertas de aplicaciones.                  |
| **Dashboards**      | Paneles personalizados de métricas y KPIs.                |
| **Webhook Manager** | Testing, monitoring y replay de webhooks.                 |
| **CI/CD Pipeline**  | Integración y despliegue continuo.                        |

#### 3.4.3 Features de Extensión

| Feature           | Descripción                                   |
| :---------------- | :-------------------------------------------- |
| **Habit Tracker** | Seguimiento de rutinas, streaks, métricas.    |
| **E2E Testing**   | Integración Playwright/Cypress.               |
| **Error Tracker** | Error tracking, stack traces.                 |
| **Feature Flags** | Gestión de funcionalidades activas/inactivas. |

---

### 3.5 Fase 3: Suite Completa (Ofimática + Avanzado)

**Objetivo:** Suite completa con capacidades ofimáticas y avanzada interoperabilidad.

#### 3.5.1 Aplicaciones Ofimáticas

| Aplicación                     | Descripción                                              |
| :----------------------------- | :------------------------------------------------------- |
| **Procesador de Texto**        | Word processor propio.                                   |
| **Hojas de Cálculo**           | Spreadsheet propio.                                      |
| **Presentaciones**             | Presentaciones/slides propio.                            |
| **Lector/Editor PDF**          | PDF viewer y editor.                                     |
| **Cliente Email**              | Cliente de email integrado.                              |
| **Chat de Equipo**             | Chat de equipo.                                          |
| **Wiki / Knowledge Base**      | Wiki estructurada, documentación de equipo.              |
| **Constructor de Formularios** | Constructor de formularios que alimentan bases de datos. |

#### 3.5.2 Servicios Avanzados

| Servicio               | Descripción                                       |
| :--------------------- | :------------------------------------------------ |
| **Workflow Engine**    | Automatizaciones tipo Zapier/Make.                |
| **Rule Engine**        | Triggers y acciones basadas en eventos.           |
| **API Integrator**     | Orquestación de APIs externas con mapeo de datos. |
| **Report Generator**   | Reportes automáticos desde bases de datos.        |
| **Usage Analytics**    | Métricas de uso de herramientas, patrones.        |
| **Version Comparator** | Diff visual de datos y configuraciones.           |
| **Hosting Híbrido**    | Nube para trabajo desatendido.                    |
| **Acceso Remoto**      | Mobile web interface.                             |

#### 3.5.3 Integraciones Externas

| Herramienta                | Tipo    | Descripción                    |
| :------------------------- | :------ | :----------------------------- |
| **Editor de Imágenes**     | Externa | GIMP                           |
| **Grabación de Pantalla**  | Externa | OBS Studio                     |
| **Capturas de Pantalla**   | Externa | Flameshot                      |
| **Gestión de Contraseñas** | Externa | Bitwarden / KeePassXC          |
| **Encriptación y Firmas**  | Externa | GnuPG                          |
| **Terminal**               | Externa | Alacritty / Kitty / WezTerm    |
| **Diseño Vectorial/SVG**   | Propia  | Diseño vectorial, SVG creator. |

---

## 4. Arquitectura de Comunicación

### 4.1 Modelo de Capas

```
┌─────────────────────────────────────────────────────────────┐
│                    APLICACIONES (UI)                        │
│    Chat IA  │  Editor  │  WebView  │  File Explorer  │ ...  │
└─────────────┴──────────┴───────────┴─────────────────┴──────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│              HEADLESS GUARDIAN (Communication Bus)          │
│  • Input Guard  • Output Guard  • Loop Sentinel             │
│  • Presentation Validator  • Communication Bus              │
└─────────────┬───────────────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────────────────────────┐
│                      SERVICIOS                              │
│  Memoria Atómica  │  NTO Pipeline  │  Event Bus  │  ...     │
└─────────────────────────────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────────────────────────┐
│                 PERSISTENCIA (PostgreSQL)                   │
│  Micro-skills  │  Task Instances  │  Project Profiles       │
└─────────────────────────────────────────────────────────────┘
```

### 4.2 Flujo de Comunicación

```
[USUARIO] → [CHAT IA] → [HEADLESS GUARDIAN] → [NTO PIPELINE]
                                                      │
                        ┌─────────────────────────────┼─────────────────────────────┐
                        ▼                             ▼                             ▼
                 [ARQUITECTO]                [CODER]                      [REVIEWER]
                        │                             │                             │
                        └─────────────────────────────┼─────────────────────────────┘
                                                      ▼
                                               [OUTPUT GUARD]
                                                      │
                                                      ▼
                                          [PRESENTATION VALIDATOR]
                                                      │
                                                      ▼
                                             [CHAT IA] → [USUARIO]
                                                      │
                                                      ▼
                                            [CONTEXT FLUSH]
                                                      │
                                                      ▼
                                          [MEMORIA ATÓMICA]
```

### 4.3 Formato de Comunicación

> **Decisión de Arquitectura:** Se utiliza **JSON/TypeScript** para todas las comunicaciones internas entre agentes y con PostgreSQL.

| Comunicación              | Formato               |
| :------------------------ | :-------------------- |
| Usuario → Agente          | Lenguaje natural      |
| Agente ↔ Agente           | JSON                  |
| Herramienta ↔ Herramienta | JSON via Guardian Bus |
| Base de Datos             | JSON/TypeScript       |

---

## 5. Resolvedor de Inconsistencias

### 5.1 Notación de Comunicación

**Inconsistencia:** El documento maestro mencionaba "TON" (Token Oriented Notation) como formato de comunicación interno.

**Resolución:** Se adopta **JSON/TypeScript** como formato estándar para todas las comunicaciones internas. TON fue descartado.

---

### 5.2 Scope del Headless Guardian

**Inconsistencia:** En algunas specs, el Guardian se menciona como "subagente de IA". En otras, como "servicio de validación".

**Resolución:** El **Headless Guardian es un servicio de seguridad**, NO un subagente. Los subagentes de IA (Security Scanner, Spec Enforcer, Design Inspector) son gestionados por el Chat IA, y sus comunicaciones pasan por el Guardian para validación.

| Componente            | Tipo         | Descripción                                                                         |
| :-------------------- | :----------- | :---------------------------------------------------------------------------------- |
| **Headless Guardian** | Servicio     | Validación Zero Trust: Input Guard, Output Guard, Loop Sentinel, Communication Bus. |
| **Security Scanner**  | Subagente IA | Detectado vulnerabilidades de seguridad. Gestionado por Chat IA.                    |
| **Spec Enforcer**     | Subagente IA | Verifica adherencia a specs. Gestionado por Chat IA.                                |
| **Design Inspector**  | Subagente IA | Valida reglas de diseño. Gestionado por Chat IA.                                    |

---

### 5.3 Context Flush — Ubicación

**Inconsistencia:** Existía confusión sobre dónde ocurre el Context Flush.

**Resolución:** El **Context Flush ocurre en la App de Chat**, NO en el sistema de memoria. El sistema de memoria es persistente e independiente.

| Componente                     | Tipo          | Persistencia  | Flush                |
| :----------------------------- | :------------ | :------------ | :------------------- |
| **App de Chat**                | Cache efímero | ❌ Efímera    | ✅ Se limpia         |
| **Sistema de Memoria Atómica** | PostgreSQL    | ✅ Permanente | ❌ No se ve afectado |

Los datos útiles se guardan en el sistema de memoria **ANTES** del flush mediante instrucciones de prompting del Main.

---

### 5.4 Perfil Único (Main)

**Inconsistencia:** El concepto "Perfil Único" aparecía sin definición clara.

**Resolución:**

El Main opera bajo el modelo de **Perfil Único**:

- **NO** mantiene historial de chat largo
- Carga información de `STRACT.md` + git logs al inicio
- **Analiza la tarea, planifica y delega** a subagentes con micro-skills específicas
- Realiza **Context Flush** después de cada tarea validada
- La conversación es **bidireccional**: usuario envía mensajes Y Main envía actualizaciones proactivas

---

### 5.5 NTO Pipeline — Terminología

**Inconsistencia:** Se usaban "NTO" y "Núcleo de Transpilación y Orquestación" indistintamente, y su scope era confuso.

**Resolución:** El **NTO (Núcleo de Transpilación y Orquestación)** es el pipeline de ejecución de agentes:

| Etapa | Agente       | Responsabilidad             |
| :---- | :----------- | :-------------------------- |
| 1     | Arquitectura | Análisis, diseño, specs     |
| 2     | Coder        | Implementación de código    |
| 3     | Reviewer     | Validación, tests, security |

El NTO es un **concepto**, no un servicio separado. Se implementa a través del flujo Chat IA → Guardian → Subagentes.

---

## 6. Stack Tecnológico

### 6.1 Tecnologías Base

| Componente            | Tecnología                  | Propósito                                                                 |
| :-------------------- | :-------------------------- | :------------------------------------------------------------------------ |
| **Core**              | Tauri (Rust)                | Binario nativo ligero, seguridad de memoria, acceso a sistema de archivos |
| **UI**                | React + FlyonUI             | Interfaz dinámica, rápida, accesible, modo oscuro nativo                  |
| **Editor Engine**     | TBD (CodeMirror 6 / Monaco) | Editor de código con LSP, syntax highlighting, autocompletado             |
| **Base de Datos**     | PostgreSQL + pgvector       | Memoria relacional + búsqueda semántica vectorial                         |
| **Inferencia**        | mmap / NVMe + GGUF          | Modelos en disco cuantizados (Q4_K, Q5_K)                                 |
| **IPC**               | Tauri Commands + Events     | Comunicación entre UI y subprocesos                                       |
| **Communication Bus** | Headless Guardian           | Validación y enrutamiento de toda comunicación inter-herramienta          |
| **Event Bus**         | TBD                         | Mensajería asíncrona publish/subscribe                                    |
| **API Gateway**       | TBD                         | Unificación y proxy de APIs                                               |

### 6.2 Pendientes de Decisión (Críticos - Fase 1)

| Item | Descripción                                                                   |
| :--- | :---------------------------------------------------------------------------- |
| [ ]  | Selección de modelo de código abierto (Qwen2.5-Coder / DeepSeek-Coder / otro) |
| [ ]  | Selección de editor engine (CodeMirror 6 / Monaco / Ace)                      |
| [ ]  | Definir modelo de embedding para búsqueda semántica de micro-skills           |
| [ ]  | Configurar allowlists/blocklists iniciales del Guardian                       |
| [ ]  | Definir lista exacta de herramientas iniciales para el contenedor             |

---

## 7. Pendientes de each Spec

### spec/03-ui-chat-ia.md

- [ ] Integrar proveedores de modelos en nube y proveedor local
- [ ] Definir modelo LLM a usar (GGUF con mmap)
- [ ] Configurar system prompt por defecto
- [ ] Definir límites de contexto (tokens)
- [ ] Configurar streaming vs batch
- [ ] Implementar protocolos Context Flush & Reload
- [ ] Definir animación Ciri (implementación técnica)
- [ ] Definir acciones sugeridas por defecto

### spec/02-ui-navegador-webview.md

- [ ] Definir qué DevTools features incluir
- [ ] Configurar Source Map generation para frameworks (React, Vue, Svelte)
- [ ] Definir política de cookies por defecto
- [ ] Configuración de proxy
- [ ] Integrar protocolo Context Flush & Reload

### spec/04-ui-editor-codigo.md

- [ ] Seleccionar librería de editor (CodeMirror 6 / Monaco / Ace)
- [ ] Configurar lenguajes soportados inicialmente
- [ ] Definir linters por lenguaje
- [ ] Configurar formatter por defecto
- [ ] Definir theme inicial (dark)

### spec/04b-file-explorer.md

- [ ] Definir motor de búsqueda de texto (ripgrep / native)
- [ ] Configurar profundidad de búsqueda por defecto

### spec/05-headless-guardian.md

- [ ] Definir reglas específicas de sanitization
- [ ] Configurar allowlists iniciales
- [ ] Definir formato de logs para integración
- [ ] Implementar protocolo Context Flush & Reload
- [ ] Configurar Auditoría de Git Log
- [ ] Investigación: Modelo de validación para chats con LLMs
- [ ] Implementar sistema de validaciones complejas para streaming/proactivo
- [ ] Definir formato JSON completo para todos los canales de comunicación
- [ ] Implementar validación específica por canal

### spec/06-validaciones-chat-llm.md

- [ ] Implementar los Criterios de Aceptación (AC-001 a AC-020)

### spec/07-sistema-memoria-atomica.md

- [ ] Definir implementación de embeddings (modelo, dimensiones)
- [ ] Configurar thresholds de búsqueda semántica
- [ ] Implementar protocolo de generación de micro-skills
- [ ] Integrar con el flujo de Context Flush & Reload

---

## 8. Glosario

| Término                 | Definición                                                                                            |
| :---------------------- | :---------------------------------------------------------------------------------------------------- |
| **Micro-Skill**         | Unidad atómica de conocimiento ejecutable con instrucciones, constraints y artefactos.                |
| **Skill Graph**         | Grafo de dependencias entre micro-skills.                                                             |
| **Context Flush**       | Protocolo de limpieza del KV Cache del LLM después de cada tarea.                                     |
| **Context Reload**      | Protocolo de recarga de STRACT.md + grafo de tareas + micro-skills después del flush.                 |
| **Skill Injection**     | Proceso de inyectar micro-skills relevantes en el contexto del Main/subagentes.                       |
| **Verification Status** | Nivel de confianza: `unverified`, `tool_verified`, `human_verified`.                                  |
| **Delegation Contract** | Acuerdo estructurado entre Main y subagente con objetivos, presupuesto, deadline y política de fallo. |
| **STRACT.md**           | Documento de estado actual del proyecto (Spec + Propose + Design + Task).                             |
| **SDD**                 | Spec-Driven Development — metodología de desarrollo basada en especificaciones.                       |

---

## 9. Referencias entre Specs

| Tema                  | Spec Principal                        |
| :-------------------- | :------------------------------------ |
| Chat IA               | `specs/03-ui-chat-ia.md`              |
| Editor de Código      | `specs/04-ui-editor-codigo.md`        |
| File Explorer         | `specs/04b-file-explorer.md`          |
| Navegador WebView     | `specs/02-ui-navegador-webview.md`    |
| Headless Guardian     | `specs/05-headless-guardian.md`       |
| Validaciones Chat LLM | `specs/06-validaciones-chat-llm.md`   |
| Memoria Atómica       | `specs/07-sistema-memoria-atomica.md` |
| UI Contenedor (Shell) | `specs/01-ui-contenedor-shell.md`     |

---

## 10. Historial de Cambios

| Fecha      | Cambio                                                                  | Autor   |
| :--------- | :---------------------------------------------------------------------- | :------ |
| 2026-05-09 | Spec consolidada. Sistema de fases definido. Inconsistencias resueltas. | Diorges |
