# OpenCode — Configuración y Stack de Trabajo

Estrategia de desarrollo asistido con OpenCode: SDD + TDD estricto + DDD, planificación y trazabilidad en GitHub Projects, memoria persistente unificada en GitHub, y perfil vanilla opcional.

## Stack de Trabajo

### Repositorio

- **Host**: GitHub
- **Flujo**: Pull Requests con revisión por lentes (4R)

### Planificación con GitHub Projects

El Project board es la fuente única de verdad para la planificación. Sigue las recomendaciones de GitHub Projects:

#### Estructura del board

- **Columnas = Features**, ordenadas por dependencia (lo que otras necesitan) y complejidad (lo más simple primero). Una feature compleja como un dashboard no aparece hasta que sus fuentes de datos estén implementadas.
- **Items dentro de cada feature** = elementos de desarrollo de bajo nivel: funciones, patrones, estados, componentes. Cada item documenta **qué hace, cómo lo hace y por qué existe** (no código directamente, sino la decisión de diseño).
- **Sub-issues** para descomponer items grandes en trabajo más manejable y permitir que varios items avancen en paralelo.
- **Issue dependencies** entre features para modelar relaciones de bloqueo.

#### Campos personalizados

| Campo | Tipo | Propósito |
|-------|------|-----------|
| Prioridad | Single select (Baja, Media, Alta, Crítica) | Priorización semántica |
| Complejidad | Number (1-13) | Estimación de esfuerzo |
| Fase SDD | Single select (Explore → Propose → Specs → Design → Tasks → Apply → Verify → Archive) | Estado del pipeline dentro del item |
| Iteración | Iteration field | Planificación semanal |
| Impacto | Single select (Bajo, Medio, Alto) | Impacto en el sistema |

#### Vistas

- **Board view**: columnas por feature, arrastrar items entre fases SDD
- **Table view**: backlog completo con filtros por prioridad/complejidad
- **Roadmap view**: timeline de features con dependencias visibles

#### Automatización

- Built-in workflows: al cerrar un issue → mover a "Done"
- Al marcar PR como "ready for review" → asignar revisor automáticamente
- GitHub Actions para sincronizar estado del Project con eventos del SDD pipeline

### Ejecución

- **SDD Orchestrator**: coordina fases (explore → propose → specs → design → tasks → apply → verify → archive). Cada item del board se ejecuta a través del pipeline SDD completo.
- **Chained PRs**: cambios grandes se dividen en PRs encadenados para preservar revisión enfocada.

### Memoria Persistente Unificada

GitHub es la única fuente de verdad para humanos y agentes. Toda la información vive en GitHub y el agente accede a ella mediante el GitHub MCP Server oficial.

| Medio | Propósito | Acceso agente |
|-------|-----------|---------------|
| **Issues** | Artefactos SDD (propuesta, specs, diseño, tareas), decisiones técnicas, session logs entre cortes de contexto | `issue_read` / `issue_write` / `add_issue_comment` vía MCP |
| **GitHub Projects** | Planificación visual con features como columnas, items como elementos de desarrollo, campos personalizados, vistas múltiples y automatizaciones | `projects_get` / `projects_list` / `projects_write` / `update_project_item` vía MCP |
| **Pull Requests** | Discusiones, revisiones 4R, contexto de decisiones y enlaces a issues | `pull_request_read` / `search_pull_requests` vía MCP |
| **Git history** | Trazabilidad completa de cambios con commits convencionales | `get_commit` / `list_commits` / `search_commits` vía MCP |
| **Search** | Búsqueda unificada sobre issues, PRs, código y repositorios | `search_issues` / `search_code` / `search_repositories` vía MCP |

El agente escribe y lee directamente sobre estos recursos de GitHub. La información es visible, auditable y compartida — no existe un almacén paralelo invisible.

### Niveles de Asistencia

Tres modos de interacción registrados en `~/.config/opencode/AGENTS.md`:

| Nivel | Rol del agente | Rol del usuario | Alcance |
|-------|---------------|----------------|---------|
| **Mentor** | Guía con método socrático: no escribe código de aplicación, revisa, comenta, evalúa progreso, inculca nuevas herramientas y tecnologías | Aprende, implementa, decide | Puede asistir y codificar fuera del proyecto (sistema, paquetes, commits, estructura de carpetas) |
| **Asistente** | Ejecuta y revisa — el usuario diseña, propone y revisa | Diseña, propone, revisa código | Proyectos donde el usuario lidera la arquitectura |
| **Developer** | Desarrolla todo por su cuenta a fuerza de prompt | Describe la necesidad | Solo proyectos pequeños (apps, landings, tools) |

### Flujo SDD (Spec-Driven Development)

```
proposal → specs → design → tasks → apply → verify → archive
```

Cada fase es ejecutada por un sub-agente especializado. El orchestrator coordina, valida y nunca ejecuta trabajo inline. El orchestrator **no es un agente Main** — es solo el coordinador de fase.

#### Fases del flujo

| Fase | Propósito |
|------|-----------|
| **Explore** | Investigación del código existente antes de proponer |
| **Propose** | Propuesta con alcance, enfoque e impacto |
| **Specs** | Lectura y descripción de **user stories** — especifica qué debe hacer el sistema desde la perspectiva del usuario |
| **Design** | Siempre se ejecuta. Involucra: **architecture design**, **UX/UI design**, **workflow design**, **dataflow design** (las que sean requeridas por el proyecto). Aquí entra **DDD (Design-Driven Development)** |
| **Tasks** | Desglose en tareas + forecast de líneas/PRs |
| **Apply** | Implementación con TDD estricto cuando el proyecto lo soporta |
| **Verify** | Validación contra specs + tests |
| **Archive** | Cierre y sincronización |

### Design-Driven Development (DDD)

La fase **design** se ejecuta siempre e involucra las áreas que el proyecto requiera:

- **Architecture design**: estructura del sistema, componentes, módulos, boundaries
- **UX/UI design**: interacción, interfaces, flujos de usuario
- **Workflow design**: flujo de trabajo y procesos del negocio
- **Dataflow design**: flujo de datos, estado, API design, base de datos

### strict TDD

Cuando el proyecto lo soporta, el modo strict TDD se activa automáticamente:

1. **Escribir test** antes que la implementación
2. **Implementar** hasta que pase el test
3. **Verificar** que no se rompan tests existentes
4. **Commit** solo con tests verdes

### Lentes de Revisión (4R)

| Lente | Enfoque |
|-------|---------|
| **review-risk** | Seguridad, permisos, exposición de datos, dependencias |
| **review-reliability** | Comportamiento, tests, bordes, determinismo, regresiones |
| **review-resilience** | Fallos, recuperación, degradación, observabilidad, carga |
| **review-readability** | Nombres, complejidad, intención, mantenibilidad |

Selección por riesgo:
- **Bajo** (solo docs/comentarios/formatos) → sin lente
- **Medio** → lente dominante exacta
- **Alto** (>400 líneas, auth/seguridad/pagos) → 4R completo

### Ciclo por cambio

```
┌──────────┐
│ Explore  │  Investigación del código existente
└────┬─────┘
     ↓
┌──────────┐
│ Propose  │  Propuesta con alcance, enfoque e impacto
└────┬─────┘
     ↓
┌──────────┐
│ Specs    │  User stories — qué debe hacer el sistema
└────┬─────┘
     ↓
┌──────────┐
│ Design   │  Architecture, UX/UI, workflow, dataflow
│ (DDD)    │  Según lo que requiera el proyecto
└────┬─────┘
     ↓
┌──────────┐
│ Tasks    │  Desglose en tareas + forecast de líneas/PRs
└────┬─────┘
     ↓
┌──────────┐
│ Apply    │  Implementación (tests primero si strict TDD)
└────┬─────┘
     ↓
┌──────────┐
│ Verify   │  Validación contra specs + tests
└────┬─────┘
     ↓
┌──────────┐
│ Archive  │  Cierre y sincronización
└──────────┘
```

### Gates de calidad

| Gate | Momento | Acción |
|------|---------|--------|
| **pre-commit** | Antes de commit | Validar receipt contra contenido stageado |
| **pre-push** | Antes de push | Validar receipt contra commits |
| **pre-pr** | Antes de PR | Validar receipt contra árbol candidate |
| **release** | Antes de release | Validar receipt contra árbol inmutable |

Después de apply, si no hay receipt válido, se ejecuta `review/start(target)` con los lentes que correspondan según el riesgo del diff.

### Agentes del sistema

#### Orchestrator

Agente coordinador (`sdd-orchestrator`). Coordina fases, aplica gates, nunca ejecuta trabajo de implementación. Mantiene un hilo de conversación delgado. **No es un agente Main** — es solo el orchestrator.

#### SDD Executors (8)

Cada fase tiene su propio sub-agente oculto. Son ejecutores puros — reciben contexto fresco, hacen su trabajo, devuelven resultado. No orquestan.

| Fase | Sub-agente |
|------|-----------|
| Explore | `sdd-explore` |
| Propose | `sdd-propose` |
| Specs | `sdd-spec` |
| Design | `sdd-design` |
| Tasks | `sdd-tasks` |
| Apply | `sdd-apply` |
| Verify | `sdd-verify` |
| Archive | `sdd-archive` |

#### Reviewers (5)

Read-only. Inspeccionan el diff candidate y devuelven hallazgos con evidencia concreta.

| Lente | Sub-agente |
|-------|-----------|
| Riesgo | `review-risk` |
| Confiabilidad | `review-reliability` |
| Resiliencia | `review-resilience` |
| Legibilidad | `review-readability` |
| Refutación | `review-refuter` |

#### Judgment Day (3)

Revisión adversarial dual para hallazgos inferenciales blocker/critical.

| Rol | Sub-agente |
|-----|-----------|
| Juez ciego A | `jd-judge-a` |
| Juez ciego B | `jd-judge-b` |
| Fix quirúrgico | `jd-fix-agent` |

### Skills instalados (core del sistema)

```
_shared/              branch-pr/            chained-pr/
cognitive-doc-design/ comment-writer/       find-skills/
frontend-design/      go-testing/           interface-design/
issue-creation/       judgment-day/         openpencil-design/
sdd-apply/            sdd-archive/          sdd-design/
sdd-explore/          sdd-init/             sdd-onboard/
sdd-propose/          sdd-spec/             sdd-tasks/
sdd-verify/           skill-creator/        skill-improver/
skill-registry/       work-unit-commits/
```

### Skills recomendadas por categoría

Skills que cubren frontend, backend, API REST, bases de datos y CSS. Se cargan bajo demanda vía el tool `skill` de OpenCode — no inflan contexto hasta que el agente las necesita.

#### 🎨 Frontend

| Skill | Fuente | Propósito |
|-------|--------|-----------|
| `react-19` | Gentleman-Skills (curated) | Server Components, Actions, hooks modernos, patrones React |
| `frontend-patterns` | opencode-agent-kit | Component architecture, composición, estado, render |
| `web-design-guidelines` | opencode-agent-kit | Accesibilidad, responsive, jerarquía visual, consistencia |
| `impeccable` | opencode-agent-kit | Pulido fino, micro-interacciones, alineación, spacing |
| `next-js` | farmage/opencode-skills | App Router, Server Actions, data fetching, layouts |
| `vue-nuxt` | farmage/opencode-skills | Composition API, Nuxt modules, SSR, routing |

#### ⚙️ Backend

| Skill | Fuente | Propósito |
|-------|--------|-----------|
| `backend-patterns` | opencode-agent-kit | Arquitectura en capas, servicios, DTOs, repositorios |
| `node-express` | skills-for-open-code | Middleware, routing, error handling, validación |
| `nestjs` | farmage/opencode-skills | Módulos, decorators, guards, interceptors |
| `authentication-patterns` | skills-for-open-code | JWT, OAuth, sessions, refresh tokens, RBAC |
| `caching-patterns` | skills-for-open-code | Redis, CDN, in-memory, stale-while-revalidate |
| `security-review` | opencode-agent-kit | OWASP, input validation, rate limiting, sanitización |

#### 🔌 API REST

| Skill | Fuente | Propósito |
|-------|--------|-----------|
| `rest-api-design` | skills-for-open-code | RESTful naming, status codes, paginación, HATEOAS |
| `openapi-spec` | farmage/opencode-skills | Documentación OpenAPI/Swagger, schemas, endpoints |
| `api-versioning` | skills-for-open-code | URL vs header versioning, breaking vs non-breaking |
| `graphql` | farmage/opencode-skills | Schema design, resolvers, N+1 prevention, subscriptions |
| `grpc` | farmage/opencode-skills | Protobuf, streams, interceptors, deadlines |

#### 🗄️ Bases de Datos

| Skill | Fuente | Propósito |
|-------|--------|-----------|
| `postgres-patterns` | opencode-agent-kit | Schema design, índices, CTEs, window functions |
| `prisma-orm` | skills-for-open-code | Schema, migrations, queries optimizadas, middleware |
| `query-optimization` | skills-for-open-code | EXPLAIN ANALYZE, indexado, joins, subconsultas |
| `migration-strategy` | skills-for-open-code | Zero-downtime, rollback, squashing, data migration |
| `sql-patterns` | farmage/opencode-skills | Anti-patrones, joins vs subqueries, paginación eficiente |
| `redis` | farmage/opencode-skills | Estructuras de datos, caching, rate limiting, pub/sub |

#### 🎯 CSS

| Skill | Fuente | Propósito |
|-------|--------|-----------|
| `tailwind-css` | Gentleman-Skills (curated) | Utility-first, custom config, plugins, responsive |
| `css-architecture` | skills-for-open-code | BEM, ITCSS, Cascade Layers, specificity |
| `design-tokens` | skills-for-open-code | CSS custom properties, temas, tokens de color/espaciado |
| `responsive-design` | skills-for-open-code | Container queries, mobile-first, breakpoints |
| `css-animations` | farmage/opencode-skills | Keyframes, transitions, scroll-driven, View Transitions API |

#### ⭐ Universales

| Skill | Propósito |
|-------|-----------|
| `stop-slop` | Elimina muletillas de IA del output (READMEs, commits, PRs) |
| `handoff` | Comprime la sesión en markdown para continuar en sesión limpia |
| `grill-me` | Entrevista hasta que hay entendimiento compartido del plan |
| `systematic-debugging` | Proceso de 4 fases para root cause — evita parches sin entender |
| `firecrawl` | Web search + scrape + crawl para el agente (OpenCode no trae web nativo) |
| `skill-optimizer` | Mintea el historial de sesiones y extrae patrones que merecen ser skill |

#### Instalación selectiva

```bash
# Desde Gentleman-Skills (curadas por voto comunitario)
git clone https://github.com/Gentleman-Programming/Gentleman-Skills.git
cp -r Gentleman-Skills/curated/react-19       ~/.config/opencode/skills/
cp -r Gentleman-Skills/curated/tailwind-css   ~/.config/opencode/skills/

# Desde farmage/opencode-skills (backend, API, DBs, CSS)
git clone https://github.com/farmage/opencode-skills.git
cp -r opencode-skills/skills/rest-api-design      ~/.config/opencode/skills/
cp -r opencode-skills/skills/postgresql-patterns  ~/.config/opencode/skills/
cp -r opencode-skills/skills/authentication       ~/.config/opencode/skills/
cp -r opencode-skills/skills/nestjs               ~/.config/opencode/skills/
cp -r opencode-skills/skills/css-architecture     ~/.config/opencode/skills/
cp -r opencode-skills/skills/graphql              ~/.config/opencode/skills/

# Skills universales (instalación directa desde GitHub)
# stop-slop, handoff, grill-me, systematic-debugging, firecrawl
# Copiar cada SKILL.md a ~/.config/opencode/skills/<name>/
```

> **Nota**: OpenCode descubre skills automáticamente desde `~/.config/opencode/skills/*/SKILL.md`. No requiere configuración adicional. Las skills se cargan bajo demanda — solo cuando el agente decide que aplican al contexto actual.

### Plugins

| Plugin | Tipo | Propósito |
|--------|------|-----------|
| `model-variants` | Local (ts) | Cachea variantes de modelos (effort levels) para el selector de esfuerzo |
| `skill-registry` | Local (ts) | Refresca el skill registry del proyecto al iniciar OpenCode |
| `opencode-subagent-statusline` | npm | Muestra estado de sub-agentes en la statusline TUI |

### MCP Servers

| Server | Tipo | Propósito |
|--------|------|-----------|
| **GitHub** | Remote (`api.githubcopilot.com/mcp`) o Local (`github/github-mcp-server`) | Acceso del agente a Issues, Projects, PRs, búsqueda y código. Es el puente entre el agente y la fuente única de verdad. Requiere autenticación OAuth (remote) o PAT (local). Toolsets recomendados: `issues`, `projects`, `pull_requests`, `search`, `repos` |
| **Context7** | Remote (`mcp.context7.com`) | Documentación de librerías bajo demanda |
| **Browser Control** | Local (Node, puerto 8089) | Control de navegador |
| **OpenPencil** | Local (`openpencil-mcp-http`) | Diseño UI vía MCP |

### Permisos Bash

| Patrón | Acción |
|--------|--------|
| `*` | `allow` |
| `git commit *` | `ask` |
| `git push` | `ask` |
| `git push *` | `ask` |
| `git push --force *` | `ask` |
| `git rebase *` | `ask` |
| `git reset --hard *` | `ask` |

### Permisos Read (bloqueados)

```
**/*.key
**/*.pem
**/.aws/credentials
**/.config/gh/hosts.yml
**/.credentials/**
**/.env
**/.env.*
**/.ssh/**
**/Library/Keychains/**
**/credentials.json
**/secrets/**
*.env
*.env.*
```

### Agents

Solo agentes nativos de OpenCode. Sin orchestrator, SDD executors, reviewers ni judgment-day.

### TUI Plugins

```json
["opencode-subagent-statusline"]
```

### Configuraciones adicionales

| Clave | Valor |
|-------|-------|
| `default_agent` | `default` |
| `share` | `disabled` |

### Archivos de configuración

```
~/.config/opencode/opencode.json       # Configuración principal
~/.config/opencode/opencode-notifier.json  # Notificaciones del sistema
~/.config/opencode/tui.json            # Plugins de interfaz TUI
~/.config/opencode/plugins/            # Plugins locales (model-variants, skill-registry)
~/.config/opencode/package.json        # Dependencias npm
```
