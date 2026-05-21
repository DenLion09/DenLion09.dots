# Especificaciones Técnicas por Fase de Implementación

> **Proyecto:** Suite AI-First (Proyecto TAI)  
> **Última actualización:** 2026-05-09  
> **Versión:** 1.0

# FASE 1: MVP (Minimum Viable Product)

## Aplicaciones Core AI + Development

### 1. Chat IA (Interfaz de Conversación)

> **Spec:** `specs/03-ui-chat-ia.md` Eliminada
> **Prioridad:** ✅ SI (Core MVP)  
> **Estado:** Especificado

#### Características Técnicas

| Aplicacion                   | Descripción                                                                                                    |
| :--------------------------- | :------------------------------------------------------------------------------------------------------------- |
| **Interfaz de Chat**         | Interfaz conversacional + live con el agente Main (orquestador principal)                                      |
| **Estados UI**               | LISTENING, THINKING, DELEGATING, ERROR                                                                         |
| **Animación Ciri**           | Indicador visual de estado inspirado en señales orgánicas/fluidas (opcional)                                   |
| **Mensajería Bidireccional** | El usuario envía mensajes Y el Main envía actualizaciones proactivas                                           |
| **Adjuntos**                 | Drag & drop de archivos, input de voz                                                                          |
| **Tipos de Mensaje**         | texto, código, archivo, error, system, acción, git-log, delegación                                             |
| **Input Enhancer**           | Corrección ortográfica antes de enviar al Guardian (NO es validación de seguridad) (temporalmente inavilitado) |
| **Subagentes de Review**     | Security Scanner, Spec Enforcer, Design Inspector (gestionados por Chat IA)                                    |
| **Integración con Guardian** | Toda comunicación validada por Headless Guardian                                                               |
| **IPC Commands**             | chat:message, chat:status, chat:action, chat:delegation, chat:file-created, agent:progress, main:flush         |

#### Integración con Backend

| Componente                     | Integración                                         |
| :----------------------------- | :-------------------------------------------------- |
| **NTO Pipeline**               | Arquitectura → Coder → Reviewer pipeline secuencial |
| **Headless Guardian**          | Input validation, output validation, Loop Sentinel  |
| **Sistema de Memoria Atómica** | Búsqueda de micro-skills, skill injection           |
| **Context Flush/Reload**       | Protocolo de limpieza y recarga post-tarea          |

#### Pendientes (Sin Especificar)

- [ ] Integrar proveedores de modelos en nube y local (GGUF con mmap)
- [ ] Definir modelo LLM a usar
- [ ] Configurar system prompt por defecto
- [ ] Definir límites de contexto (tokens)
- [ ] Configurar streaming vs batch
- [ ] Definir animación Ciri (implementación técnica detallada)
- [ ] Definir acciones sugeridas por defecto

---

### 2. Editor de Código (Code Editor)

> **Spec:** `specs/04-ui-editor-codigo.md`  
> **Prioridad:** ✅ SI (Core MVP)  
> **Estado:** Especificado

#### Características Técnicas

| Feature                            | Descripción                                                           |
| :--------------------------------- | :-------------------------------------------------------------------- |
| **Edición de Código**              | Editor de código fuente con soporte multi-lenguaje                    |
| **Syntax Highlighting**            | Resaltado de sintaxis para múltiples lenguajes                        |
| **Tabs Múltiples**                 | Múltiples archivos abiertos simultáneamente                           |
| **LSP (Language Server Protocol)** | Autocompletado, go-to-definition, hover documentation, signature help |
| **Integración con Linters**        | Validación en tiempo real, diagnósticos por lenguaje                  |
| **Git Integration**                | Diff, status, blame integrados                                        |
| **Vistas Divididas**               | Split horizontal/vertical                                             |
| **Búsqueda y Reemplazo**           | Find & replace (Ctrl+F, Ctrl+H)                                       |
| **Ir a Línea**                     | Go to line específico (Ctrl+G)                                        |
| **Format Code**                    | Formateo automático por lenguaje                                      |
| **Minimapa (Opcional)**            | Scroll preview del documento                                          |
| **Breadcrumb**                     | Navegación de ruta de archivo                                         |

#### Integración con Backend

| Componente            | Integración                                                    |
| :-------------------- | :------------------------------------------------------------- |
| **Headless Guardian** | Code Guardian valida lint en tiempo real (debounce 300ms)      |
| **File Explorer**     | Popup independiente (Ctrl+P) para apertura de archivos         |
| **NTO Pipeline**      | Receive `agent:highlight` para archivos modificados por agente |

#### Estados UI

| Estado  | Descripción                    |
| :------ | :----------------------------- |
| EMPTY   | Sin archivo abierto            |
| LOADING | Cargando archivo               |
| READY   | Archivo cargado y editable     |
| EDITED  | Cambios pendientes sin guardar |
| SAVING  | Guardando archivo              |
| ERROR   | Error de sintaxis/lint         |

#### Pendientes (Sin Especificar)

- [ ] Seleccionar librería de editor (CodeMirror 6 / Monaco / Ace)
- [ ] Configurar lenguajes soportados inicialmente
- [ ] Definir linters por lenguaje
- [ ] Configurar formatter por defecto
- [ ] Definir theme inicial (dark)

---

### 3. File Explorer (Popup de Búsqueda)

> **Spec:** `specs/04b-file-explorer.md`  
> **Prioridad:** ✅ SI (Core MVP)  
> **Estado:** Especificado

#### Características Técnicas

| Feature                          | Descripción                                                          |
| :------------------------------- | :------------------------------------------------------------------- |
| **Popup Independiente**          | Ventana emergente (Ctrl+P / Cmd+P) para búsqueda                     |
| **Búsqueda por Nombre**          | Filtro rápido de archivos por nombre                                 |
| **Búsqueda de Texto**            | Full-text search en contenido del proyecto (ripgrep/native)          |
| **Preview con Syntax Highlight** | Vista previa de archivos con resaltado de sintaxis                   |
| **Indicadores Git**              | Estado: modificado (🔴), staged, sin seguimiento (🔵), warnings (🟡) |
| **Integración con Editor**       | Enter/Doble click abre archivo en Editor                             |
| **Keybindings**                  | ↑/↓ navegación, Enter abrir, Escape cerrar                           |

#### Integración con Backend

| Componente           | Integración                       |
| :------------------- | :-------------------------------- |
| **Editor de Código** | Abre archivos seleccionados       |
| **Eventos IPC**      | explorer:search, explorer:results |

#### Pendientes (Sin Especificar)

- [ ] Definir motor de búsqueda de texto (ripgrep / native)
- [ ] Configurar profundidad de búsqueda por defecto
- [ ] Decidir si el popup debe recordar última posición/búsqueda

---

### 4. Navegador WebView

> **Spec:** `specs/02-ui-navegador-webview.md`  
> **Prioridad:** ✅ SI (Core MVP)  
> **Estado:** Especificado

#### Características Técnicas

| Feature                  | Descripción                                            |
| :----------------------- | :----------------------------------------------------- |
| **WebView Integrado**    | WebView2 (Windows) / WebKit (macOS/Linux)              |
| **URL Bar**              | Navegación URL con validación de allowlist de dominios |
| **Navegación**           | Back, forward, reload, stop                            |
| **DevTools Integrado**   | Inspector HTML, Console, Network, Sources              |
| **Source Maps Reversos** | DOM path → código fuente ( React, Vue, Svelte)         |
| **Interceptar Requests** | Para API testing                                       |
| **Gestión de Cookies**   | Sesiones aisladas                                      |
| **Gestures Táctiles**    | Zoom, scroll en dispositivos táctiles                  |

#### Integración con Backend

| Componente            | Integración                                         |
| :-------------------- | :-------------------------------------------------- |
| **Headless Guardian** | Valida scripts inyectados, requests, forms, cookies |
| **Editor de Código**  | Source maps reversos abren en Editor                |

#### Estados UI

| Estado   | Descripción       |
| :------- | :---------------- |
| EMPTY    | Sin URL ingresada |
| LOADING  | Cargando página   |
| READY    | Página cargada    |
| ERROR    | Error de carga    |
| DEVTOOLS | DevTools abierto  |

#### Pendientes (Sin Especificar)

- [ ] Definir qué DevTools features incluir
- [ ] Configurar Source Map generation para frameworks
- [ ] Definir política de cookies por defecto
- [ ] Configuración de proxy

---

### 5. UI Contenedor (Shell)

> **Spec:** `specs/01-ui-contenedor-shell.md`  
> **Prioridad:** ❌ NO (Excluido de MVP inicial)  
> **Estado:** Especificado

#### Características Técnicas

| Feature                     | Descripción                                   |
| :-------------------------- | :-------------------------------------------- |
| **Dock/Launcher Principal** | GUI principal que carga herramientas          |
| **Toolbar Superior**        | Iconos de herramientas alineados a la derecha |
| **Workspace Area**          | Área principal de renderizado de herramientas |
| **Gestión de Proyectos**    | Workspaces múltiples                          |
| **Layouts**                 | Tab, split horizontal, split vertical         |
| **Settings Panel**          | Panel lateral o modal overlay                 |
| **Consumo de Memoria**      | Target: <100MB RAM                            |

#### Estados UI

| Estado      | Descripción                           |
| :---------- | :------------------------------------ |
| EMPTY       | Ninguna herramienta abierta           |
| TOOL_SELECT | Selector de herramientas visible      |
| ACTIVE      | Una o más herramientas abiertas       |
| FULLSCREEN  | Herramienta en modo pantalla completa |

#### Pendientes (Sin Especificar)

- [ ] Definir lista exacta de herramientas iniciales
- [ ] Definir shortcuts de teclado por defecto
- [ ] Definir configuración de temas (dark/light)

---

## Servicios Backend (MVP)

### 6. Sistema de Memoria Atómica

> **Spec:** `specs/07-sistema-memoria-atomica.md`  
> **Prioridad:** ✅ SI (Core MVP)  
> **Estado:** Especificado

#### Características Técnicas

| Feature                   | Descripción                                               |
| :------------------------ | :-------------------------------------------------------- |
| **PostgreSQL + pgvector** | Base de datos relacional con búsqueda vectorial           |
| **Micro-Skills**          | Unidades atómicas de conocimiento ejecutable              |
| **Búsqueda Semántica**    | Embeddings vectoriales (768 dimensiones)                  |
| **Skill Graph**           | Grafo de dependencias entre micro-skills                  |
| **Lazy Loading**          | Solo carga skills necesarias (no todo el contexto)        |
| **Flush/Reload**          | Protocolo de limpieza post-tarea (sobrevive al flush)     |
| **Skill Injection**       | Inyección de micro-skills relevantes en contexto del Main |
| **Verification Status**   | Niveles: unverified, tool_verified, human_verified        |
| **Ciclo de Vida**         | DRAFT → VERIFIED → TRUSTED → DEPRECATED                   |

#### Esquema de Base de Datos

| Tabla                     | Descripción                  |
| :------------------------ | :--------------------------- |
| micro_skills              | Catálogo global de skills    |
| skill_dependencies        | Grafo de dependencias        |
| task_instances            | Ejecuciones por proyecto     |
| validation_artifacts      | Resultados de validaciones   |
| flush_handoff_artifacts   | Datos para reload post-flush |
| failed_validation_records | Validaciones fallidas        |
| delegation_contracts      | Contratos de delegación      |
| project_profiles          | Perfiles por proyecto        |

#### Algoritmo de Búsqueda (Multi-etapa)

1. **Búsqueda Semántica** (pgvector): Top 20 con similarity > 0.7
2. **Filtro por Stack**: Intersection con stack del proyecto
3. **Filtro por Estado**: Excluir DEPRECATED, ordenar TRUSTED > VERIFIED > DRAFT
4. **Ranking Final**: semantic*similarity * 0.5 + stack*overlap * 0.2 + success*rate * 0.2 + log(usage*count) * 0.1

#### Integración con Chat IA

> **Aclaración:** El flush ocurre en la App de Chat, NO en el sistema de memoria. El sistema de memoria es persistente e independiente.

| Componente                      | Relación                     |
| :------------------------------ | :--------------------------- |
| App de Chat (Cache efímero)     | Se limpia en flush           |
| Sistema de Memoria (PostgreSQL) | Persiste - NO se ve afectado |

#### Pendientes (Sin Especificar)

- [ ] Definir implementación de embeddings (modelo, dimensiones)
- [ ] Configurar thresholds de búsqueda semántica
- [ ] Implementar protocolo de generación de micro-skills

---

### 7. Headless Guardian (Zero Trust Motor)

> **Spec:** `specs/05-headless-guardian.md`  
> **Prioridad:** ⚠️ PARCIAL (Requerido para producción, no bloquea MVP inicial)  
> **Estado:** Especificado

#### Características Técnicas

| Feature                          | Descripción                                               |
| :------------------------------- | :-------------------------------------------------------- |
| **Input Guard**                  | Sanitize, validate, classify, route input de herramientas |
| **Output Guard**                 | Validate, filter, format, reject output de subagentes     |
| **Loop Sentinel**                | Detecta y bloquea ciclos infinitos                        |
| **Communication Bus**            | Bus central de comunicación entre herramientas            |
| **Presentation Layer Validator** | Reduce a información necesaria, sanitiza paths            |
| **Zero Trust**                   | Ningún componente confía ciegamente en otro               |

#### Reglas de Sanitization

| Tipo               | Acción                     |
| :----------------- | :------------------------- |
| Command Injection  | Block + log                |
| Path Traversal     | Normalize path + validate  |
| Prompt Injection   | Detectar y marcar contexto |
| Special Characters | Escapar según contexto     |

#### Reglas de Filtering (Output)

| Tipo         | Patrón                                      | Acción         |
| :----------- | :------------------------------------------ | :------------- |
| API Keys     | `/api[keyK]ey.*[:=]["\'][\w-]+["\']/`       | Mask + warning |
| Tokens       | `/Bearer [\w-]+/`                           | Mask           |
| Passwords    | `/pass(word)?[\w]*.*[:=]["\'][^"\']+["\']/` | Mask           |
| Private Keys | `-----BEGIN.*PRIVATE KEY-----`              | Block + alert  |

#### Loop Sentinel Thresholds

| Tipo                | Threshold     | Acción                           |
| :------------------ | :------------ | :------------------------------- |
| Retry Loop          | 3 intentos    | Notify user + send error to chat |
| Circular Dependency | Detectado     | Block + unwind stack             |
| Same Output         | 2 consecutive | Block + prompt user              |

#### Comunicación (JSON Format)

| Comando               | Descripción                   |
| :-------------------- | :---------------------------- |
| bus:message           | Mensaje entre herramientas    |
| bus:validated         | Mensaje aprobado por Guardian |
| bus:blocked           | Mensaje bloqueado             |
| guard:validate:input  | Validar input                 |
| guard:validate:output | Validar output                |
| guard:loop:detected   | Loop infinito detectado       |

#### Pendientes (Sin Especificar)

- [ ] Definir reglas específicas de sanitization
- [ ] Configurar allowlists iniciales
- [ ] Definir formato de logs para integración
- [ ] Implementar protocolo Context Flush & Reload
- [ ] Configurar Auditoría de Git Log
- [ ] Investigación: Modelo de validación para chats con LLMs
- [ ] Implementar sistema de validaciones complejas para streaming/proactivo

---

### 8. Validaciones Chat LLM

> **Spec:** `specs/06-validaciones-chat-llm.md`  
> **Prioridad:** ⚠️ PARCIAL (Requerido para producción, no bloquea MVP inicial)  
> **Estado:** Especificado

#### Dominios de Validación

| Dominio                  | Qué valida                                      |
| :----------------------- | :---------------------------------------------- |
| **Mensajería Proactiva** | Mensajes no solicitados del Main al usuario     |
| **Streaming en Vivo**    | Tokens que llegan incrementalmente              |
| **Delegaciones**         | Tareas enviadas a subagentes y sus resultados   |
| **Contexto Post-Flush**  | Estado de validaciones después de Context Flush |

#### Streaming Strategies

| Nivel          | Escenario                 | Estrategia        | Latencia   |
| :------------- | :------------------------ | :---------------- | :--------- |
| Tier 1 (bajo)  | Chat interno              | Stream + Post-Hoc | 0ms        |
| Tier 2 (medio) | Chat con usuarios finales | Buffer & Release  | +200-500ms |
| Tier 3 (alto)  | Acciones con side effects | Non-Streaming     | 3-30s      |

#### Patrón Buffer-and-Release

1. Acumular 50-100 tokens en buffer O detectar fin de oración
2. Ejecutar guardrails rápidos (longitud, patrones, PII)
3. Si pasa → liberar buffer al frontend
4. Si falla → reemplazar con mensaje seguro + registrar error span

#### Delegation Contract Schema

```typescript
interface DelegationContract {
  contract_id: string;
  parent_agent: string;
  subagent_id: string;
  objective: string;
  success_criteria: string[];
  budget: { max_tokens; max_time_ms; max_tool_calls };
  fail_policy: "fail_closed" | "fail_open";
  context_snapshot: string[];
  payload_mode: "text" | "semantic_frame" | "structured_json";
  trust_domain: string;
  required_verification: VerificationLevel;
}
```

#### Criterios de Aceptación (AC-001 a AC-020)

- AC-001 a AC-004: Mensajería proactiva
- AC-005 a AC-008: Streaming
- AC-009 a AC-014: Delegación
- AC-015 a AC-020: Contexto y Post-Flush

#### Pendientes (Sin Especificar)

- [ ] Implementar los Criterios de Aceptación (AC-001 a AC-020)

---

# FASE 2: Intermedia (Productividad + Infraestructura)

## Aplicaciones de Productividad

### 9. Notas Markdown

> **Spec:** `specs/` (sin especificar)  
> **Prioridad:** Fase 2  
> **Estado:** Sin especificar

#### Features (Inferidas)

| Feature                      | Descripción                          |
| :--------------------------- | :----------------------------------- |
| **Notas con Sincronización** | Persistencia de notas entre sesiones |
| **Markdown Preview**         | Renderizado de Markdown en vivo      |
| **Organización**             | Carpetas, tags, búsqueda             |
| **Export**                   | PDF, HTML, Markdown                  |

#### Pendientes

- [ ] **Sin especificar** — Requiere especificación técnica detallada

---

### 10. Diagramas (Flujos, UML, Arquitectura)

> **Spec:** `specs/` (sin especificar)  
> **Prioridad:** Fase 2  
> **Estado:** Sin especificar

#### Features (Inferidas)

| Feature           | Descripción                                       |
| :---------------- | :------------------------------------------------ |
| **Editor Visual** | Herramienta de dibujo integrada                   |
| **Mermaid.js**    | Renderizado de diagramas desde código             |
| **Templates**     | Diagramas predefinidos (flujo, UML, arquitectura) |
| **Export**        | PNG, SVG, PDF                                     |

#### Pendientes

- [ ] **Sin especificar** — Requiere especificación técnica detallada

---

### 11. Gestor de Tareas y Eventos (Kanban)

> **Spec:** `specs/` (sin especificar)  
> **Prioridad:** Fase 2  
> **Estado:** Sin especificar

#### Features (Inferidas)

| Feature                   | Descripción                                       |
| :------------------------ | :------------------------------------------------ |
| **Kanban Board**          | Columnas configurables (To Do, In Progress, Done) |
| **Proyectos**             | Múltiples proyectos/tareas                        |
| **Seguimiento de Issues** | Integración con sistema de issues                 |
| **Calendario**            | Vista de calendario de eventos                    |
| **Fechas Límite**         | Deadline y recordatorios                          |

#### Pendientes

- [ ] **Sin especificar** — Requiere especificación técnica detallada

---

### 12. Time Tracking (Pomodoro)

> **Spec:** `specs/` (sin especificar)  
> **Prioridad:** Fase 2  
> **Estado:** Sin especificar

#### Features (Inferidas)

| Feature                       | Descripción                                 |
| :---------------------------- | :------------------------------------------ |
| **Registro de Horas**         | Tracking de tiempo por tarea                |
| **Pomodoro Timer**            | Técnica Pomodoro integrada                  |
| **Análisis de Productividad** | Estadísticas de tiempo invertido            |
| **Reportes**                  | Resúmenes de tiempo por día/semana/proyecto |

#### Pendientes

- [ ] **Sin especificar** — Requiere especificación técnica detallada

---

### 13. Snippet Manager

> **Spec:** `specs/` (sin especificar)  
> **Prioridad:** Fase 2  
> **Estado:** Sin especificar

#### Features (Inferidas)

| Feature                  | Descripción                              |
| :----------------------- | :--------------------------------------- |
| **Biblioteca de Código** | Almacenamiento de snippets reutilizables |
| **Búsqueda Semántica**   | Embeddings para búsqueda por contenido   |
| **Categorización**       | Tags, lenguajes, proyectos               |
| **Insertar en Editor**   | Integración directa con Editor de Código |

#### Pendientes

- [ ] **Sin especificar** — Requiere especificación técnica detallada

---

### 14. Gestor de Bookmarks

> **Spec:** `specs/` (sin especificar)  
> **Prioridad:** Fase 2  
> **Estado:** Sin especificar

#### Features (Inferidas)

| Feature                   | Descripción                 |
| :------------------------ | :-------------------------- |
| **Curación de Contenido** | Guardar URLs con metadata   |
| **Lectura Posterior**     | Marcar para leer después    |
| **Organización**          | Carpetas, tags              |
| **Sincronización**        | Persistencia entre sesiones |

#### Pendientes

- [ ] **Sin especificar** — Requiere especificación técnica detallada

---

## Aplicaciones de Desarrollo - Web/API

### 15. API Testing

> **Spec:** `specs/` (sin especificar)  
> **Prioridad:** Fase 2  
> **Estado:** Sin especificar

#### Features (Inferidas)

| Feature             | Descripción                      |
| :------------------ | :------------------------------- |
| **Cliente HTTP**    | GET, POST, PUT, DELETE, PATCH    |
| **Request Builder** | Headers, body, query params      |
| **Colecciones**     | Agrupar requests                 |
| **Historia**        | Historial de requests realizados |
| **Variables**       | Environment variables            |

#### Pendientes

- [ ] **Sin especificar** — Requiere especificación técnica detallada

---

### 16. Local Dev (Exponer Localhost)

> **Spec:** `specs/` (sin especificar)  
> **Prioridad:** Fase 2  
> **Estado:** Sin especificar

#### Features (Inferidas)

| Feature                | Descripción                  |
| :--------------------- | :--------------------------- |
| **Tunneling**          | Exponer localhost a internet |
| **Gestión de Puertos** | Mapeo de puertos locales     |
| **URLs Temporales**    | Generar URLs para testing    |
| **Auth**               | Autenticación para acceso    |

#### Pendientes

- [ ] **Sin especificar** — Requiere especificación técnica detallada

---

## Aplicaciones de Desarrollo - Infraestructura

### 17. Gestor de Contenedores (Container Manager)

> **Spec:** `specs/` (sin especificar)  
> **Prioridad:** Fase 2  
> **Estado:** Sin especificar

#### Features (Inferidas)

| Feature                 | Descripción                           |
| :---------------------- | :------------------------------------ |
| **Docker GUI**          | Interfaz para gestión de contenedores |
| **Gestión de Imágenes** | Listar, descargar, eliminar imágenes  |
| **Volumes**             | Gestión de volúmenes                  |
| **Networks**            | Configuración de redes                |
| **Logs**                | Ver logs de contenedores              |
| **Entornos Aislados**   | Crear entornos isolados               |

#### Pendientes

- [ ] **Sin especificar** — Requiere especificación técnica detallada

---

### 18. Gestor de Secretos (Secrets Manager)

> **Spec:** `specs/` (sin especificar)  
> **Prioridad:** Fase 2  
> **Estado:** Sin especificar

#### Features (Inferidas)

| Feature                   | Descripción                           |
| :------------------------ | :------------------------------------ |
| **Variables de Entorno**  | Gestión de .env files                 |
| **Credenciales**          | Almacenamiento seguro de credenciales |
| **Encriptación**          | Cifrado de secrets en disco           |
| **Inyección en Terminal** | Injectar secrets en environment       |
| **Proyectos Múltiples**   | Secrets por proyecto                  |

#### Pendientes

- [ ] **Sin especificar** — Requiere especificación técnica detallada

---

### 19. CI/CD Pipeline

> **Spec:** `specs/` (sin especificar)  
> **Prioridad:** Fase 2  
> **Estado:** Sin especificar

#### Features (Inferidas)

| Feature                | Descripción                     |
| :--------------------- | :------------------------------ |
| **Pipeline Builder**   | Definir stages y jobs           |
| **Integración Git**    | Triggers en push, PR, merge     |
| **Ejecución de Steps** | Run commands, tests, deployment |
| **Logs**               | Output de pipeline en vivo      |
| **Estado**             | Dashboard de pipelines          |

#### Pendientes

- [ ] **Sin especificar** — Requiere especificación técnica detallada

---

## Servicios de Infraestructura (Fase 2)

### 20. Event Bus

> **Spec:** `specs/` (sin especificar)  
> **Prioridad:** Fase 2  
> **Estado:** Sin especificar

#### Features (Inferidas)

| Feature                | Descripción                            |
| :--------------------- | :------------------------------------- |
| **Publish/Subscribe**  | Mensajería asíncrona entre componentes |
| **Event Sourcing**     | Historial inmutable de eventos         |
| **Webhooks**           | Dispatcher de webhooks                 |
| **State Broadcasting** | Notificar cambios de estado            |
| **Trigger de Reglas**  | Rules engine escucha eventos           |

#### Pendientes

- [ ] **Sin especificar** — Requiere especificación técnica detallada

---

### 21. API Gateway

> **Spec:** `specs/` (sin especificar)  
> **Prioridad:** Fase 2  
> **Estado:** Sin especificar

#### Features (Inferidas)

| Feature                 | Descripción                       |
| :---------------------- | :-------------------------------- |
| **Unificación de APIs** | Endpoint único para herramientas  |
| **Routing**             | Routeo interno entre herramientas |
| **Proxy Externo**       | Proxy con auth, rate limiting     |
| **Autenticación**       | Control de acceso centralizado    |

#### Pendientes

- [ ] **Sin especificar** — Requiere especificación técnica detallada

---

### 22. Monitoring (Logs, Métricas, Alertas)

> **Spec:** `specs/` (sin especificar)  
> **Prioridad:** Fase 2  
> **Estado:** Sin especificar

#### Features (Inferidas)

| Feature             | Descripción                     |
| :------------------ | :------------------------------ |
| **Log Aggregation** | Recolectar logs de aplicaciones |
| **Métricas**        | CPU, memoria, red, aplicación   |
| **Alertas**         | Thresholds configurables        |
| **Dashboard**       | Panels de visualización         |

#### Pendientes

- [ ] **Sin especificar** — Requiere especificación técnica detallada

---

### 23. Dashboards (Métricas, KPIs)

> **Spec:** `specs/` (sin especificar)  
> **Prioridad:** Fase 2  
> **Estado:** Sin especificar

#### Features (Inferidas)

| Feature                    | Descripción                      |
| :------------------------- | :------------------------------- |
| **Paneles Personalizados** | Crear dashboards custom          |
| **Widgets**                | Gráficos, métricas, tablas       |
| **KPI Tracking**           | Seguimiento de indicadores clave |
| **Compartir**              | Exportar/compartir dashboards    |

#### Pendientes

- [ ] **Sin especificar** — Requiere especificación técnica detallada

---

### 24. Webhook Manager

> **Spec:** `specs/` (sin especificar)  
> **Prioridad:** Fase 2  
> **Estado:** Sin especificar

#### Features (Inferidas)

| Feature        | Descripción                 |
| :------------- | :-------------------------- |
| **Testing**    | Test de webhooks entrantes  |
| **Monitoring** | Estado de webhooks          |
| **Replay**     | Replay de webhooks fallidos |
| **Logs**       | Historial de webhooks       |

#### Pendientes

- [ ] **Sin especificar** — Requiere especificación técnica detallada

---

### 25. Feature Flags

> **Spec:** `specs/` (sin especificar)  
> **Prioridad:** Fase 2  
> **Estado:** Sin especificar

#### Features (Inferidas)

| Feature                 | Descripción                        |
| :---------------------- | :--------------------------------- |
| **Gestión de Features** | Activar/desactivar funcionalidades |
| **Rollout**             | Gradual release                    |
| **Targeting**           | Por usuario, grupo, porcentaje     |
| **Audit**               | Historial de cambios               |

#### Pendientes

- [ ] **Sin especificar** — Requiere especificación técnica detallada

---

### 26. Error Tracker

> **Spec:** `specs/` (sin especificar)  
> **Prioridad:** Fase 2  
> **Estado:** Sin especificar

#### Features (Inferidas)

| Feature                | Descripción              |
| :--------------------- | :----------------------- |
| **Captura de Errores** | Stack traces, contexto   |
| **Agrupación**         | Errores similares juntos |
| **Asignación**         | Asignar a miembros       |
| **Resolución**         | Workflow de fixes        |

#### Pendientes

- [ ] **Sin especificar** — Requiere especificación técnica detallada

---

### 27. UI Design con IA

> **Spec:** `specs/` (sin especificar)  
> **Prioridad:** Fase 2  
> **Estado:** Sin especificar

#### Features (Inferidas)

| Feature                    | Descripción                     |
| :------------------------- | :------------------------------ |
| **Diseño Asistido por IA** | Generar UI desde descripción    |
| **Componentes**            | Biblioteca de componentes       |
| **Preview**                | Vista previa en tiempo real     |
| **Export**                 | Generar código (HTML/CSS/React) |

#### Pendientes

- [ ] **Sin especificar** — Requiere especificación técnica detallada

---

### 28. Generador de Documentación

> **Spec:** `specs/` (sin especificar)  
> **Prioridad:** Fase 2  
> **Estado:** Sin especificar

#### Features (Inferidas)

| Feature                   | Descripción               |
| :------------------------ | :------------------------ |
| **Generación Automática** | Docs desde código fuente  |
| **API Docs**              | Swagger/OpenAPI from code |
| **Markdown Export**       | Exportar a Markdown       |
| **Hosting**               | Servir documentación      |

#### Pendientes

- [ ] **Sin especificar** — Requiere especificación técnica detallada

---

### 29. Conector Universal (Adapter Pattern)

> **Spec:** `specs/` (sin especificar)  
> **Prioridad:** Fase 2  
> **Estado:** Sin especificar

#### Features (Inferidas)

| Feature            | Descripción                    |
| :----------------- | :----------------------------- |
| **Adaptadores**    | Conectar herramientas entre sí |
| **Mapeo de Datos** | Transformaciones               |
| **Workflows**      | Encadenar herramientas         |

#### Pendientes

- [ ] **Sin especificar** — Requiere especificación técnica detallada

---

### 30. Import/Export

> **Spec:** `specs/` (sin especificar)  
> **Prioridad:** Fase 2  
> **Estado:** Sin especificar

#### Features (Inferidas)

| Feature       | Descripción             |
| :------------ | :---------------------- |
| **Importar**  | Desde otras plataformas |
| **Exportar**  | Formatos estándar       |
| **Migración** | Datos completos         |

#### Pendientes

- [ ] **Sin especificar** — Requiere especificación técnica detallada

---

# FASE 3: Avanzada (Ofimática + Suite Completa)

## Aplicaciones Ofimáticas

### 31. Procesador de Texto (Word Processor)

> **Spec:** `specs/` (sin especificar)  
> **Prioridad:** Fase 3  
> **Estado:** Sin especificar

#### Features (Inferidas)

| Feature             | Descripción                           |
| :------------------ | :------------------------------------ |
| **Editor de Texto** | Procesamiento de texto completo       |
| **Formateo**        | Negrita, cursiva, encabezados, listas |
| **Tablas**          | Insertar y editar tablas              |
| **Imágenes**        | Insertar imágenes                     |
| **Export**          | PDF, DOCX, Markdown                   |

#### Pendientes

- [ ] **Sin especificar** — Requiere especificación técnica detallada

---

### 32. Hojas de Cálculo (Spreadsheet)

> **Spec:** `specs/` (sin especificar)  
> **Prioridad:** Fase 3  
> **Estado:** Sin especificar

#### Features (Inferidas)

| Feature      | Descripción                    |
| :----------- | :----------------------------- |
| **Celdas**   | Celdas con datos, fórmulas     |
| **Fórmulas** | Funciones内置 y personalizadas |
| **Gráficos** | Generar gráficos desde datos   |
| **Export**   | CSV, Excel, PDF                |

#### Pendientes

- [ ] **Sin especificar** — Requiere especificación técnica detallada

---

### 33. Presentaciones (Slides)

> **Spec:** `specs/` (sin especificar)  
> **Prioridad:** Fase 3  
> **Estado:** Sin especificar

#### Features (Inferidas)

| Feature               | Descripción              |
| :-------------------- | :----------------------- |
| **Creador de Slides** | Crear presentaciones     |
| **Temas**             | Plantillas predefinidas  |
| **Transiciones**      | Animaciones entre slides |
| **Export**            | PDF, PPTX                |

#### Pendientes

- [ ] **Sin especificar** — Requiere especificación técnica detallada

---

### 34. Lector/Editor PDF

> **Spec:** `specs/` (sin especificar)  
> **Prioridad:** Fase 3  
> **Estado:** Sin especificar

#### Features (Inferidas)

| Feature         | Descripción                |
| :-------------- | :------------------------- |
| **Viewer PDF**  | Visor de PDF integrado     |
| **Anotaciones** | Resaltar, comentar         |
| **Edición**     | Modificar texto (limitado) |
| **Firmas**      | Firmar documentos          |

#### Pendientes

- [ ] **Sin especificar** — Requiere especificación técnica detallada

---

### 35. Cliente de Email

> **Spec:** `specs/` (sin especificar)  
> **Prioridad:** Fase 3  
> **Estado:** Sin especificar

#### Features (Inferidas)

| Feature       | Descripción             |
| :------------ | :---------------------- |
| **Lectura**   | Ver emails              |
| **Escritura** | Redactar emails         |
| **Carpetas**  | Organizar por carpetas  |
| **IMAP/SMTP** | Conectar con servidores |

#### Pendientes

- [ ] **Sin especificar** — Requiere especificación técnica detallada

---

### 36. Chat de Equipo (Team Chat)

> **Spec:** `specs/` (sin especificar)  
> **Prioridad:** Fase 3  
> **Estado:** Sin especificar

#### Features (Inferidas)

| Feature      | Descripción             |
| :----------- | :---------------------- |
| **Canales**  | Canales de comunicación |
| **Mensajes** | Chat en tiempo real     |
| **Archivos** | Compartir archivos      |
| **Usuarios** | Gestión de miembros     |

#### Pendientes

- [ ] **Sin especificar** — Requiere especificación técnica detallada

---

### 37. Calendario

> **Spec:** `specs/` (sin especificar)  
> **Prioridad:** Fase 3  
> **Estado:** Sin especificar

#### Features (Inferidas)

| Feature            | Descripción                          |
| :----------------- | :----------------------------------- |
| **Eventos**        | Crear y editar eventos               |
| **Reuniones**      | Scheduling de reuniones              |
| **Recordatorios**  | Notificaciones                       |
| **Sincronización** | Integración con calendarios externos |

#### Pendientes

- [ ] **Sin especificar** — Requiere especificación técnica detallada

---

### 38. Wiki / Knowledge Base

> **Spec:** `specs/` (sin especificar)  
> **Prioridad:** Fase 3  
> **Estado:** Sin especificar

#### Features (Inferidas)

| Feature           | Descripción             |
| :---------------- | :---------------------- |
| **Documentación** | Wiki estructurada       |
| **Colaboración**  | Múltiples autores       |
| **Búsqueda**      | Buscar en documentación |
| **Markdown**      | Soporte Markdown        |

#### Pendientes

- [ ] **Sin especificar** — Requiere especificación técnica detallada

---

### 39. Constructor de Formularios

> **Spec:** `specs/` (sin especificar)  
> **Prioridad:** Fase 3  
> **Estado:** Sin especificar

#### Features (Inferidas)

| Feature            | Descripción                      |
| :----------------- | :------------------------------- |
| **Constructor UI** | Arrastrar componentes            |
| **Tipos de Campo** | Texto, checkbox, radio, dropdown |
| **Validación**     | Reglas de validación             |
| **Base de Datos**  | Guardar respuestas               |

#### Pendientes

- [ ] **Sin especificar** — Requiere especificación técnica detallada

---

## Servicios Avanzados

### 40. Workflow Engine

> **Spec:** `specs/` (sin especificar)  
> **Prioridad:** Fase 3  
> **Estado:** Sin especificar

#### Features (Inferidas)

| Feature              | Descripción                   |
| :------------------- | :---------------------------- |
| **Automatizaciones** | Como Zapier/Make              |
| **Triggers**         | Eventos que inician workflows |
| **Acciones**         | Operaciones a ejecutar        |
| **Condiciones**      | Lógica condicional            |

#### Pendientes

- [ ] **Sin especificar** — Requiere especificación técnica detallada

---

### 41. Rule Engine

> **Spec:** `specs/` (sin especificar)  
> **Prioridad:** Fase 3  
> **Estado:** Sin especificar

#### Features (Inferidas)

| Feature         | Descripción                  |
| :-------------- | :--------------------------- |
| **Triggers**    | Eventos que disparan reglas  |
| **Acciones**    | Acciones basadas en triggers |
| **Condiciones** | Evaluación de condiciones    |
| **Logs**        | Historial de ejecuciones     |

#### Pendientes

- [ ] **Sin especificar** — Requiere especificación técnica detallada

---

### 42. API Integrator

> **Spec:** `specs/` (sin especificar)  
> **Prioridad:** Fase 3  
> **Estado:** Sin especificar

#### Features (Inferidas)

| Feature            | Descripción                 |
| :----------------- | :-------------------------- |
| **Orquestación**   | Manejar múltiples APIs      |
| **Mapeo de Datos** | Transformaciones entre APIs |
| **Retry Logic**    | Reintentos automáticos      |
| **Rate Limiting**  | Control de tasa             |

#### Pendientes

- [ ] **Sin especificar** — Requiere especificación técnica detallada

---

### 43. Generador de Reportes

> **Spec:** `specs/` (sin especificar)  
> **Prioridad:** Fase 3  
> **Estado:** Sin especificar

#### Features (Inferidas)

| Feature                  | Descripción            |
| :----------------------- | :--------------------- |
| **Reportes Automáticos** | Desde bases de datos   |
| **Templates**            | Plantillas de reportes |
| **Programación**         | Generación programada  |
| **Export**               | PDF, Excel, HTML       |

#### Pendientes

- [ ] **Sin especificar** — Requiere especificación técnica detallada

---

### 44. Usage Analytics

> **Spec:** `specs/` (sin especificar)  
> **Prioridad:** Fase 3  
> **Estado:** Sin especificar

#### Features (Inferidas)

| Feature             | Descripción                   |
| :------------------ | :---------------------------- |
| **Métricas de Uso** | Cómo se usan las herramientas |
| **Patrones**        | Identificar patrones de uso   |
| **Dashboards**      | Visualización de analytics    |
| **Export**          | Exportar datos                |

#### Pendientes

- [ ] **Sin especificar** — Requiere especificación técnica detallada

---

### 45. Version Comparator

> **Spec:** `specs/` (sin especificar)  
> **Prioridad:** Fase 3  
> **Estado:** Sin especificar

#### Features (Inferidas)

| Feature             | Descripción                |
| :------------------ | :------------------------- |
| **Diff Visual**     | Comparar versiones         |
| **Configuraciones** | Comparar configs           |
| **Datos**           | Comparar datasets          |
| **Unified View**    | Vista unificada de cambios |

#### Pendientes

- [ ] **Sin especificar** — Requiere especificación técnica detallada

---

### 46. Hosting Híbrido

> **Spec:** `specs/` (sin especificar)  
> **Prioridad:** Fase 3  
> **Estado:** Sin especificar

#### Features (Inferidas)

| Feature                           | Descripción                   |
| :-------------------------------- | :---------------------------- |
| **Nube para Trabajo Desatendido** | Ejecutar sin supervisión      |
| **Sincronización**                | Sincronizar estado local/nube |
| **Backup**                        | Respaldo en nube              |

#### Pendientes

- [ ] **Sin especificar** — Requiere especificación técnica detallada

---

### 47. Acceso Remoto (Mobile Web)

> **Spec:** `specs/` (sin especificar)  
> **Prioridad:** Fase 3  
> **Estado:** Sin especificar

#### Features (Inferidas)

| Feature                | Descripción        |
| :--------------------- | :----------------- |
| **Interfaz Web Móvil** | Acceso desde móvil |
| **Responsive**         | UI adaptativa      |
| **Sincronización**     | Estado consistente |

#### Pendientes

- [ ] **Sin especificar** — Requiere especificación técnica detallada

---

### 48. Diseño Vectorial / SVG Creator

> **Spec:** `specs/` (sin especificar)  
> **Prioridad:** Fase 3  
> **Estado:** Sin especificar

#### Features (Inferidas)

| Feature          | Descripción                |
| :--------------- | :------------------------- |
| **Editor SVG**   | Crear gráficos vectoriales |
| **Herramientas** | Shapes, paths, texto       |
| **Export**       | Exportar como SVG          |
| **Preview**      | Vista previa               |

#### Pendientes

- [ ] **Sin especificar** — Requiere especificación técnica detallada

---

### 49. Habit Tracker

> **Spec:** `specs/` (sin especificar)  
> **Prioridad:** Fase 3  
> **Estado:** Sin especificar

#### Features (Inferidas)

| Feature                  | Descripción                 |
| :----------------------- | :-------------------------- |
| **Seguimiento de Rutas** | Hábitos diarios             |
| **Streaks**              | Rachas de días consecutivos |
| **Métricas**             | Estadísticas de hábitos     |
| **Recordatorios**        | Notificaciones              |

#### Pendientes

- [ ] **Sin especificar** — Requiere especificación técnica detallada

---

### 50. Infrastructure as Code

> **Spec:** `specs/` (sin especificar)  
> **Prioridad:** Fase 3  
> **Estado:** Sin especificar

#### Features (Inferidas)

| Feature              | Descripción           |
| :------------------- | :-------------------- |
| **Terraform/Pulumi** | Integración IaC       |
| **Plantillas**       | Módulos reutilizables |
| **Plan/Apply**       | Preview y apply       |
| **Estado**           | Gestión de estado     |

#### Pendientes

- [ ] **Sin especificar** — Requiere especificación técnica detallada

---

### 51. Infrastructure Dashboard

> **Spec:** `specs/` (sin especificar)  
> **Prioridad:** Fase 3  
> **Estado:** Sin especificar

#### Features (Inferidas)

| Feature                 | Descripción                   |
| :---------------------- | :---------------------------- |
| **Dashboard Unificado** | Vista de infraestructura      |
| **Recursos**            | Listar recursos cloud/on-prem |
| **Costos**              | Seguimiento de costos         |
| **Alertas**             | Notificaciones de estado      |

#### Pendientes

- [ ] **Sin especificar** — Requiere especificación técnica detallada

---

## Resumen por Fase

### Fase 1: MVP (8 componentes)

|  #  | Componente                 | Tipo     | Estado Spec           |
| :-: | :------------------------- | :------- | :-------------------- |
|  1  | Chat IA                    | App      | Especificado          |
|  2  | Editor de Código           | App      | Especificado          |
|  3  | File Explorer              | App      | Especificado          |
|  4  | Navegador WebView          | App      | Especificado          |
|  5  | UI Contenedor (Shell)      | App      | Especificado (no MVP) |
|  6  | Sistema de Memoria Atómica | Servicio | Especificado          |
|  7  | Headless Guardian          | Servicio | Parcial               |
|  8  | Validaciones Chat LLM      | Servicio | Parcial               |

### Fase 2: Intermedia (21 componentes)

|  #  | Componente                | Estado Spec     |
| :-: | :------------------------ | :-------------- |
|  9  | Notas Markdown            | Sin especificar |
| 10  | Diagramas                 | Sin especificar |
| 11  | Gestor de Tareas (Kanban) | Sin especificar |
| 12  | Time Tracking             | Sin especificar |
| 13  | Snippet Manager           | Sin especificar |
| 14  | Gestor de Bookmarks       | Sin especificar |
| 15  | API Testing               | Sin especificar |
| 16  | Local Dev                 | Sin especificar |
| 17  | Container Manager         | Sin especificar |
| 18  | Secrets Manager           | Sin especificar |
| 19  | CI/CD Pipeline            | Sin especificar |
| 20  | Event Bus                 | Sin especificar |
| 21  | API Gateway               | Sin especificar |
| 22  | Monitoring                | Sin especificar |
| 23  | Dashboards                | Sin especificar |
| 24  | Webhook Manager           | Sin especificar |
| 25  | Feature Flags             | Sin especificar |
| 26  | Error Tracker             | Sin especificar |
| 27  | UI Design con IA          | Sin especificar |
| 28  | Generador de Docs         | Sin especificar |
| 29  | Conector Universal        | Sin especificar |
| 30  | Import/Export             | Sin especificar |

### Fase 3: Avanzada (21 componentes)

|  #  | Componente                 | Estado Spec     |
| :-: | :------------------------- | :-------------- |
| 31  | Procesador de Texto        | Sin especificar |
| 32  | Hojas de Cálculo           | Sin especificar |
| 33  | Presentaciones             | Sin especificar |
| 34  | PDF Reader/Editor          | Sin especificar |
| 35  | Cliente de Email           | Sin especificar |
| 36  | Chat de Equipo             | Sin especificar |
| 37  | Calendario                 | Sin especificar |
| 38  | Wiki / Knowledge Base      | Sin especificar |
| 39  | Constructor de Formularios | Sin especificar |
| 40  | Workflow Engine            | Sin especificar |
| 41  | Rule Engine                | Sin especificar |
| 42  | API Integrator             | Sin especificar |
| 43  | Report Generator           | Sin especificar |
| 44  | Usage Analytics            | Sin especificar |
| 45  | Version Comparator         | Sin especificar |
| 46  | Hosting Híbrido            | Sin especificar |
| 47  | Acceso Remoto              | Sin especificar |
| 48  | Diseño Vectorial/SVG       | Sin especificar |
| 49  | Habit Tracker              | Sin especificar |
| 50  | Infrastructure as Code     | Sin especificar |
| 51  | Infrastructure Dashboard   | Sin especificar |

---

## Referencias

- `general_specs.md` — Documento maestro de visión y arquitectura
- `Especificaciones Suite AI-First Proyecto TAI V2.md` — Especificaciones detalladas V2
- `specs/` — Especificaciones técnicas detalladas por componente

---

## Notas

1. Las aplicaciones marked "sin especificar" requieren sus propias specs técnicas antes de implementación
2. El Headless Guardian y Validaciones Chat LLM son parciales porque no bloquean el MVP inicial pero son requeridos para producción
3. La UI Contenedor está excluida del MVP porque las herramientas pueden ejecutarse de forma independiente (standalone)
4. Los servicios de Fase 2 y 3 se inferieron del roadmap en `general_specs.md` y pueden contener inconsistencias con los archivos de referencia
