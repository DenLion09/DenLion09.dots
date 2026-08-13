# Plan de Estudios Maestro: Ingeniería de Software Web

Este documento contiene el plan de estudios estructurado para alcanzar un nivel de ingeniería de software competitivo en la industria. Está organizado en cuatro bloques de dificultad progresiva, cada uno con prerrequisitos explícitos. El plan asume acceso continuo a herramientas de IA como capa de ejecución: la IA comprime la ejecución (escribir, implementar, generar boilerplate), mientras el ingeniero especifica, decide, delega y verifica por comportamiento. La operación manual queda integrada como red de seguridad natural en cada nivel, no como un plan alternativo.

---

## Bloque 1: Fundamentos y Trabajo Asistido
**Prerrequisitos:** Ninguno.
- **Ciencias de la Computación:** Fundamentos de programación, datos, tipos de datos y tipos de tipado.
    - **Datos primitivos:** Características y funciones universales presentes en todos los lenguajes.
- **Lenguajes y Entornos de Ejecución (Runtimes) — enfoque lectura-primero:** comprender y explicar código antes que escribirlo fluidamente; la escritura es asistida por IA.
    - **JS/TS:** Sintaxis fundamental, estructuras de control y tipado estricto inicial. Lectura de código existente y explicación en prosa de qué hace.
    - **Node.js / Bun.js (Básico):** Qué es un entorno de ejecución fuera del navegador, diferencias entre Bun y Node, introducción a la modularidad y funciones básicas de la API.
    - **Rust:** Sintaxis básica, uso de Cargo y comprensión de variables inmutables vs. mutables.
    - **Bash — la terminal como interfaz:** Navegación del sistema de archivos (`pwd`, `ls`, `cd`, `cp`, `mv`, `rm`, `ln`, `find`, `du`, `df`), permisos y usuarios (`chmod`, `chown`, `umask`, `whoami`, `id`, `groups`), texto y pipelines (`cat`, `less`, `head`, `tail`, `grep`, `sort`, `wc`, `cut`), redirección, variables de entorno y `PATH`, procesos básicos (`ps`, `top`, `kill`, `jobs`), red básica (`ping`, `curl`, `ssh`, `scp`, `dig`) y editor en terminal (nvim/nano).
- **Web Core y Redes:** Principios fundamentales de redes (modelo cliente-servidor, conceptos de IP y DNS). Estructura y diseño web base con **HTML** semántico y **CSS**.
- **Ciclo de Vida del Software:** Fases que comprenden el desarrollo de software, metodologías que establecen un funcionamiento óptimo para el equipo, y herramientas y técnicas aplicadas en cada fase.
- **Arquitectura y Diseño:** Introducción a patrones de diseño básicos (Módulo, Singleton, Factory) para estructurar soluciones antes de escribir código.
- **Producto, Requisitos y Comunicación Técnica — núcleo del rol humano:** Extracción y análisis de requisitos, redacción de criterios de aceptación verificables, uso de sintaxis **EARS** (*Easy Approach to Requirements Syntax*), documentación técnica en Markdown, diagramas de flujo arquitectónicos y métodos de comunicación técnica.
- **Capa IA — trabajo asistido:**
    - Agentes de IA como asistente de aprendizaje y pair programming.
    - Estructura de un prompt eficaz: contexto, tarea y criterios de aceptación.
    - Lectura crítica del código generado y verificación mínima por comportamiento.
    - Cuándo no delegar: no pedir código que aún no se comprende.
    - Introducción al flujo plan-then-implement (modo plan) y qué es un `AGENTS.md`.

---

## Bloque 2: Ingeniería, Calidad y Verificación
**Prerrequisitos:** Bloque 1.
- **Entorno, Herramientas de Desarrollo y DevOps:**
    - **Git Best Practices:** Commits semánticos (Conventional Commits), resolución de conflictos, `rebase` interactivo vs `merge` y mantenimiento de un historial limpio. El historial como memoria del sistema y fuente de intención.
    - **Docker (Básico):** Creación de contenedores e imágenes básicas.
- **Ecosistema GitHub:** Gestión ágil del código con **GitHub Projects** (tableros Kanban, issues y vinculación con ramas). Implementación de **GitHub Actions** para Integración Continua (CI) básica (automatizar linters y tests en cada Pull Request). Prácticas de Code Reviews y Trunk-Based Development.
- **Ciencias de la Computación:** Estructuras no lineales (árboles, grafos, hash maps), algoritmos de búsqueda y ordenamiento, y regex (grupos de captura y lookaheads).
- **Lenguajes y Runtimes — lectura primero:**
    - **JS/TS:** Event Loop, Closures y manejo de asincronía (Promesas, `async/await`).
    - **Node.js / Bun.js (Intermedio):** Módulos (CommonJS vs ES Modules), interacción con el sistema de archivos (`fs`) y gestión de variables de entorno.
    - **Rust:** Dominio del sistema de Ownership y Borrowing. Manejo de `Result` y `Option`.
    - **Bash — administración del sistema:** Procesos y señales, servicios con systemd (`systemctl`, units, `journalctl`), timers y cron como mantenimiento del sistema, red (`ip`, `ss`, firewall ufw/nftables, configuración SSH/keys), paquetes (apt/dnf/pacman, actualización segura), usuarios y grupos avanzados (sudoers), discos y filesystems (`lsblk`, `mount`, `fstab`, `df`, `du`), y logs del sistema (`/var/log`, `logrotate`).
- **Arquitectura y Diseño:** Principios SOLID, DRY, KISS. Patrones de diseño complejos (MVC, Observer). Modularidad estricta. Arquitecturas hexagonal, clean y onion.
- **Frontend Core y Ecosistema React (Básico a Intermedio):**
    - Conceptos de SPA (*Single Page Applications*) y manipulación virtual del DOM.
    - Fundamentos de **React**: JSX, componentes funcionales, props, ciclo de vida.
    - **React Hooks** (`useState`, `useEffect`, `useRef`, `useMemo`).
    - Enrutamiento en el cliente (React Router) y gestión de estado global (Context API, Zustand o Redux básico).
    - Maquetación con herramientas modulares (TailwindCSS) y sistemas de diseño anti-fatiga visual.
- **QA y Resolución de Problemas:** Unit Testing (Jest, Cargo test). Test-Driven Development (TDD) inicial. Uso de debuggers integrados y lectura de stack traces.
- **Backend Core y APIs (Básico a Intermedio):**
    - Uso de frameworks de backend (Express.js).
    - Arquitectura de APIs REST: middlewares, enrutamiento (routers), controladores y manejo de peticiones HTTP (GET, POST, PUT, DELETE, PATCH).
    - Implementación de WebSockets para comunicación bidireccional en tiempo real.
- **Datos y Seguridad:** Consultas SQL básicas (CRUD) y uso introductorio de bases de datos NoSQL (colecciones en MongoDB). Conexión del backend a la base de datos (ORMs/ODMs básicos). Hasheo de contraseñas. Autenticación con JWT, configuración de CORS y mitigación de ataques comunes (OWASP).
- **Capa IA — especificación y verificación:**
    - Spec-Driven Development como práctica central: user story + EARS + criterios verificables antes de delegar.
    - TDD asistido: el humano escribe el caso de prueba y la IA implementa para pasarlo.
    - Generación de tests y revisión de la intención del agente.
    - Code review asistido: la IA como primer revisor, el humano valida la intención (checkpoint de comprensión).
    - Agentes en CI/CD y verificación de integraciones.
    - Debugging con IA: análisis asistido de stack traces y errores, con verificación humana de la causa raíz.
    - Detección de alucinaciones y de "vibe code": código aceptado sin revisión.
    - Seguridad del código generado: revisión de dependencias, permisos y superficie de ataque.
    - Flujo estándar plan-then-implement-then-review.

---

## Bloque 3: Sistemas, Agentes e IA Aplicada
**Prerrequisitos:** Bloque 2.
- **Ciencias de la Computación:** Algoritmos de optimización de memoria, estructuras de datos complejas (buffers basados en bloques) y profiling de rendimiento algorítmico.
- **Lenguajes y Runtimes:**
    - **JS/TS:** Prevención de memory leaks y optimización de motores (V8).
    - **Node.js / Bun.js (Avanzado):** Manejo de `Streams` para archivos pesados, concurrencia real con Worker Threads, Clustering, perfiles de rendimiento (profiling) e integración de módulos nativos (FFI).
    - **Rust:** Lifetimes avanzados, Macros y concurrencia segura sin data races (hilos, canales).
    - **Bash — operación de servidores:** `sysctl` y límites del kernel, TTY puro y sesiones remotas persistentes (tmux/screen), red avanzada (rutas, DNS local, `tcpdump`, iptables/nftables), contenedores como procesos del host (operación con podman/docker), boot y recovery (GRUB, single-user), seguridad del host (SELinux/AppArmor, hardening SSH, auditoría), backup y restauración (`rsync`, snapshots) y scripting corto de mantenimiento operativo del sistema (cron/systemd timers, monitoreo).
- **Web Core & APIs:** Motores de renderizado custom, arquitecturas híbridas (Tauri con frontend web y backend Rust), frameworks Meta (Next.js/Remix) para Server-Side Rendering (SSR) y Static Site Generation (SSG), y scroll virtual masivo para grandes conjuntos de datos.
- **Entorno y DevOps:** CI/CD completo con GitHub Actions (pipelines automáticos), despliegue avanzado de contenedores y orquestación, y resiliencia de red.
- **Arquitectura y Diseño:** Microservicios y sistemas distribuidos. Spec-Driven Development riguroso: la especificación como fuente de verdad ejecutable, generación de código y detección de drift. Redacción de Tech Specs, RFCs y ADRs. Colas de mensajes (Pub/Sub) e integración orientada a eventos.
- **Datos y Seguridad:** Estrategias de caching (Redis), bases de datos en memoria, políticas avanzadas de sanitización de datos y tolerancia a fallos.
- **QA y Resolución de Problemas:** Testing End-to-End (E2E). Análisis de métricas, cobertura de código, complejidad ciclomática estática, logging estructurado, observabilidad en producción y pruebas de carga.
- **Capa IA — sistemas y agentes:**
    - Conceptos de LLM para ingenieros: tokens, contexto, embeddings, temperatura y límites.
    - RAG (Retrieval-Augmented Generation): indexado, búsqueda y construcción de contexto.
    - Model Context Protocol (MCP): resources, prompts y tools; seguridad y consentimiento.
    - Agentes ReAct: bucles de razonamiento, uso de herramientas, ground truth y guardrails.
    - Workflows LLM: prompt chaining, routing, parallelization, orchestrator-workers y evaluator-optimizer.
    - Evals de sistemas LLM: datasets, métricas y regresión.
    - Integración de APIs de LLM: streaming, rate limits y costos.
    - SDD aplicado a sistemas con IA: spec como fuente de verdad, generación de código y drift detection.

---

## Bloque 4: Operación, Resiliencia y Producto
**Prerrequisitos:** Bloque 3.
- **Operación y Mantenimiento:** Operación de servicios en producción. Runbooks y documentación de intención (ADRs) como base operativa. El historial git y la documentación como memoria del sistema. Backups y recuperación. Debugging y soporte en incidencias, con y sin asistencia, como red de seguridad operativa.
- **Observabilidad y Telemetría:** Métricas, logs y trazabilidad. Bucles de retroalimentación, experimentación y análisis del comportamiento del producto en producción.
- **Producto AI-first:** Diseño de producto con IA como componente central: UX conversacional y agentic, guardrails y evaluación continua de la experiencia. Telemetría de agentes y calidad de sus entregas.
- **Gobernanza y Costos de LLM:** FinOps de tokens, elección intencional de modelos (costo/calidad/latencia), seguridad y privacidad de datos en LLM, cumplimiento e impacto ambiental.
- **Accountability:** Revisión final de entregas de agentes y responsabilidad del resultado. Comunicación del porqué de cada decisión técnica y de producto.
- **Capa IA — producto y gobierno:**
    - Mentalidad de operador: el ingeniero dirige, decide y verifica; la IA ejecuta.
    - Evaluación de sistemas agentes en producción: evals continuos y detección de regresiones.
    - Gestión del cambio a hipervelocidad: PRs pequeños, revisión asistida y límites explícitos de delegación.
    - Postura operativa: acceso continuo a IA como supuesto base, con operación manual como red de seguridad integrada en runbooks, historial y documentación.
