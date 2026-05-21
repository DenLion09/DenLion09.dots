# Spec Headless Guardian — Zero Trust Motor

## 1. Propósito

**Máxima prioridad.** Sistema central de validación, verificación y control del comportamiento de todos los agentes. Implementa _arquitectura cero confianza_ donde ningún componente confía ciegamente en otro.

## 2. Responsabilidades

| Función                       | Descripción                                    |
| :---------------------------- | :--------------------------------------------- |
| **Input Validation**          | Valida y sanitiza requests del usuario         |
| **Output Validation**         | Valida respuestas antes de mostrar             |
| **Inter-Agent Communication** | Monitorea y controla comunicación inter-agente |
| **Code Validation**           | Verifica compilación, tests,coverage           |
| **Security Audit**            | Detecta vulnerabilidades y secrets expuestos   |
| **Loop Detection**            | Bloquea ciclos infinitos                       |
| **Compliance Check**          | Verifica adherencia a specs                    |

## 3. Arquitectura de Componentes

```
┌─────────────────────────────────────────────────────────────┐
│                    HEADLESS GUARDIAN                        │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐   │
│  │ INPUT GUARD   │  │ OUTPUT GUARD │  │ CODE SCAN   │   │
│  │              │  │              │  │            │   │
│  │ • Sanitize   │  │ • Validate  │  │ • Compile  │   │
│  │ • Validate  │  │ • Filter    │  │ • Lint     │   │
│  │ • Classify  │  │ • Format    │  │ • Test     │   │
│  │ • Route     │  │ • Reject    │  │ • Coverage │   │
│  └──────────────┘  └──────────────┘  └──────────────┘   │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │ SECURITY    │  │ LOOP        │  │ SPEC       │     │
│  │ SCANNER     │  │ SENTINEL   │  │ ENFORCER   │     │
│  │              │  │              │  │            │     │
│  │ • Secrets   │  │ • Detect   │  │ • Validate │     │
│  │ • Vulns     │  │ • Block    │  │ • Reject   │     │
│  │ • Patterns  │  │ • Warn     │  │ • Enforce  │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐      │
│  │              DESIGN INSPECTOR                      │      │
│  │  • Anti-fatiga validation                        │      │
│  │  • Stack validation (MERN + FlyonUI only)    │      │
│  └──────────────────────────────────────────────────────┘      │
��                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              AGENT COMM MANAGER                        │  │
│  │  • Message routing    • State management              │  │
│  │  • Deadlock detection  • Timeout management        │  │
│  └──────────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────────┘
```

## 4. Estados del Sistema

| Estado         | Descripción                     |
| :------------- | :------------------------------ |
| **INIT**       | Inicializando                   |
| **READY**      | Operativo, esperando requests   |
| **PROCESSING** | Procesando request              |
| **BLOCKED**    | Bloqueado por detectar anomalía |
| **ERROR**      | Estado de error                 |
| **DEGRADED**   | Operando con limitaciones       |

## 5. Subsistemas

### 5.1 Input Guard

**Responsabilidad:** Validar y sanitizar todo input antes de procesarlo.

#### Flujo

```
1. Receive raw input from user
     ↓
2. Sanitize: remove injections, XSS, etc.
     ↓
3. Validate: type, size, format
     ↓
4. Classify: intent detection
     ↓
5. Route: send to appropriate handler
```

#### Reglas de Sanitization

| Tipo                   | Acción                     |
| :--------------------- | :------------------------- |
| **SQL Injection**      | Block + log                |
| **XSS**                | Escape HTML entities       |
| **Command Injection**  | Block + log                |
| **Path Traversal**     | Normalize path + validate  |
| **Prompt Injection**   | Detectar y marcar contexto |
| **Special Characters** | Escapar según contexto     |

#### Validación de Input

| Campo       | Validación                           |
| :---------- | :----------------------------------- |
| **Mensaje** | Max 10KB, reject si excede           |
| **Archivo** | Max 5MB, tipos permitidos            |
| **URL**     | Allowlist de dominios (configurable) |
| **Código**  | Max 100KB                            |

### 5.2 Output Guard

**Responsabilidad:** Validar todo output antes de mostrar al usuario.

#### Flujo

```
1. Receive raw output from agent
     ↓
2. Filter: remove sensitive data (keys, tokens)
     ↓
3. Validate: format, completeness
     ↓
4. Format: markdown, highlights
     ↓
5. Return to user OR block
```

#### Reglas de Filtering

| Tipo             | Patrón                                      | Acción         |
| :--------------- | :------------------------------------------ | :------------- |
| **API Keys**     | `/api[kK]ey.*[:=]["\'][\w-]+["\']/`         | Mask + warning |
| **Tokens**       | `/Bearer [\w-]+/`                           | Mask           |
| **Passwords**    | `/pass(word)?[\w]*.*[:=]["\'][^"\']+["\']/` | Mask           |
| **Private Keys** | `-----BEGIN.*PRIVATE KEY-----`              | Block + alert  |
| **IPs Personal** | IP del sistema local                        | Mask           |

### 5.3 Code Guardian

**Responsabilidad:** Validar código generado antes de aceptarlo.

#### Flujo

```
1. Receive code from Coder agent
     ↓
2. Syntax validation (parse)
     ↓
3. Compile check (invoca compiler)
     ↓
4. Lint run (configurable linters)
     ↓
5. Test run (unit tests)
     ↓
6. Coverage check (min % configurable)
     ↓
7. Security scan
```

#### Thresholds por Defecto

| Check             | Threshold | Acción                |
| :---------------- | :-------- | :-------------------- |
| **Compile**       | Must pass | Block si falla        |
| **Lint errors**   | 0         | Block si hay errors   |
| **Lint warnings** | < 10      | Warning si excede     |
| **Test pass**     | 100%      | Block si falla alguno |
| **Coverage**      | >= 70%    | Warning si bajo       |

### 5.4 Security Scanner

**Responsabilidad:** Detectar vulnerabilidades de seguridad.

#### Vulnerabilidades Detectadas

| Categoría             | Patterns                                             |
| :-------------------- | :--------------------------------------------------- |
| **Hardcoded Secrets** | API keys, passwords, tokens en código                |
| **SQL Injection**     | Concatenación directa en queries                     |
| **XSS**               | `innerHTML`, `dangerouslySetInnerHTML` sin sanitizar |
| **Command Injection** | `exec`, `system`, `shell_exec` con input externo     |
| **Path Traversal**    | `open`, `readFile` sin sanitizar path                |
| **Weak Crypto**       | MD5, SHA1 para passwords                             |
| **Insecure Random**   | `Math.random` para seguridad                         |

#### Acciones por Severity

| Severity     | Acción                      |
| :----------- | :-------------------------- |
| **CRITICAL** | Block + no permitir merge   |
| **HIGH**     | Block + requerir fix manual |
| **MEDIUM**   | Warning + sugerir fix       |
| **LOW**      | Warning + informational     |

### 5.5 Loop Sentinel

**Responsabilidad:** Detectar y bloquear ciclos infinitos.

#### Tipos de Loops Detectados

| Tipo                    | Descripción                             |
| :---------------------- | :-------------------------------------- |
| **Retry Loop**          | Mismo agente falla N veces consecutivas |
| **Circular Dependency** | Agente A llama B, B llama A             |
| **Infinite Generation** | Output no converge dopo N iteraciones   |
| **Same Output**         | Mismo output N veces consecutively      |

#### Thresholds por Defecto

| Tipo            | Threshold      | Acción               |
| :-------------- | :------------- | :------------------- |
| **Retry Loop**  | 3 intentos     | Block + notify user  |
| **Circular**    | Detectado      | Block + unwind stack |
| **Generation**  | 50 iteraciones | Block + rollback     |
| **Same Output** | 5 consecutive  | Block + prompt user  |

### 5.6 Spec Enforcer

**Responsabilidad:** Verificar adherencia a specs.

#### Flujo

```
1. Receive deliverable from agent
     ↓
2. Load relevant spec (buscar por entidad)
     ↓
3. Parse requirements de spec
     ↓
4. Validate deliverable contra requirements
     ↓
5. If pass → allow continue
   If fail → block + report gaps
```

#### Validaciones

| Requirement Type    | Check                               |
| :------------------ | :---------------------------------- |
| **File created**    | Archivo existe en path especificado |
| **Function exists** | Función definida con firma correcta |
| **Test exists**     | Test coverage para la feature       |
| **Import correct**  | Dependencies correctas              |
| **Config present**  | Config keys presentes               |

### 5.7 Design Inspector (NUEVO)

**Responsabilidad:** Validar que el código generado cumpla con las reglas de diseño.

#### Protocolo Anti-Fatiga

- **Rechaza** cualquier código CSS/Tailwind que incluya:
  - Negro puro: `#000` o `black` o `rgb(0,0,0)`
  - Blanco puro: `#FFF` o `white` o `rgb(255,255,255)`

#### Validación de Stack

- **Bloquea** si se intenta usar librerías fuera de:
  - MERN (MongoDB, Express, React, Node.js)
  - FlyonUI
  - Tailwind CSS

#### Thresholds por Defecto

| Check              | Threshold       | Acción              |
| :----------------- | :-------------- | :------------------ |
| **Colors**         | 0 blacks/whites | Block si se detecta |
| **Stack**          | MERN+FlyonUI    | Block si no match   |
| **Contrast Ratio** | >= 4.5:1        | Warning si bajo     |

### 5.8 Agent Comm Manager

**Responsabilidad:** Gestionar comunicación entre agentes.

#### Responsabilidades

- **Message Routing:** Enviar mensaje al agente correcto
- **State Management:** Mantener estado de cada agente
- **Deadlock Detection:** Detectar agentes blockage mutuo
- **Timeout Management:** Bloquear agentes stuck
- **Message Queue:** Manejar cola de mensajes

#### Estados de Agente

| Estado         | Descripción                        |
| :------------- | :--------------------------------- |
| **IDLE**       | Esperando input                    |
| **PROCESSING** | Trabajando en request              |
| **WAITING**    | Esperando respuesta de otro agente |
| **BLOCKED**    | Bloqueado por validación           |
| **DONE**       | Completado exitosamente            |
| **ERRORED**    | Terminado con error                |

## 6. Integración con NTO Pipeline

```
┌─────────────────────────────────────────────────────────────┐
│              FLUJO COMPLETO NTO + GUARDIAN                  │
└─────────────────────────────────────────────────────────────┘

1. Usuario: "crea un login con JWT"
     ↓
2. INPUT GUARD: Valida y detecta intent
     ↓
3. SPEC ENFORCER: Carga spec para "auth/login"
     ↓
4. → ARQUITECTO (diseña solución)
     ↓
5. SPEC ENFORCER: Valida spec generada
     ↓
6. → CODER (implementa código)
     ↓
7. CODE GUARDIAN: Valida compilación + tests
     ↓
8. SECURITY SCANNER: Scan vulnerabilidades
     ↓
9. DESIGN INSPECTOR: Valida estético y stack
     ↓
10. → REVISOR (revis calidad)
     ↓
11. OUTPUT GUARD: Filtra información sensible
     ↓
12. Context Flush: Borra KV Cache
     ↓
13. Reload: Carga STRACT.md + grafo de tareas
     ↓
14. Usuario: Respuesta final

DURANTE TODO EL PROCESO:
   - LOOP SENTINEL: Monitorea ciclos
   - AGENT COMM MANAGER: Estado de agentes
```

## 7. Logging y Observabilidad

### 7.1 Logs Generados

| Nivel     | Cuándo                     |
| :-------- | :------------------------- |
| **DEBUG** | Cada validación individual |
| **INFO**  | Transiciones de estado     |
| **WARN**  | Warnings emitidos          |
| **ERROR** | Errores detectados         |
| **ALERT** | Bloqueos de seguridad      |

### 7.2 Métricas

| Métrica               | Descripción                   |
| :-------------------- | :---------------------------- |
| **Validation Rate**   | % de inputs que pasan         |
| **Block Rate**        | % de requests bloqueados      |
| **Avg Latency**       | Tiempo promedio de validación |
| **Loop Count**        | # de loops detectados         |
| **Security Alerts**   | # de alertas de seguridad     |
| **Design Violations** | # de violate anti-fatiga      |

## 8. Configuración

### 8.1 Variables de Entorno

```bash
# Habilitar/deshabilitar guards
GUARDIAN_INPUT_ENABLED=true
GUARDIAN_OUTPUT_ENABLED=true
GUARDIAN_CODE_ENABLED=true
GUARDIAN_SECURITY_ENABLED=true
GUARDIAN_LOOP_ENABLED=true
GUARDIAN_DESIGN_ENABLED=true

# Thresholds
GUARDIAN_MAX_RETRIES=3
GUARDIAN_MAX_ITERATIONS=50
GUARDIAN_MIN_COVERAGE=70

# Logging
GUARDIAN_LOG_LEVEL=info
```

### 8.2 allowlists/Blocklists

```yaml
input:
  allowed_urls:
    - "github.com/*"
    - "gitlab.com/*"
  blocked_domains:
    - "malicious.com"

output:
  filter_patterns:
    - "/api[keyK]ey.*[:=]/"
    - "/Bearer /"

security:
  critical_vulns:
    - "sql_injection"
    - "command_injection"

design:
  allowed_stacks:
    - mern
    - flyonui
    - tailwind
  blocked_colors:
    - "#000"
    - "#FFF"
    - "black"
    - "white"
```

## 9. Casos Edge

| Escenario                  | Comportamiento                                     |
| :------------------------- | :------------------------------------------------- |
| Input muy largo            | Chunking + validación por partes                   |
| Validacióntimeout          | Block + retry con backoff                          |
| Múltiples vulnerabilidades | Reportar todas, no solo la primera                 |
| Conflicto entre guards     | Input > Code > Security > Design > Output priority |
| Agent crash                | Aísla agente, continua pipeline                    |
| Circular dependency        | Detectar + unwind + alert                          |
| Design violation           | Block + mostrar color/stack no válido              |

## 10. API de Comunicación

### 10.1 Commands

```
// Input → Guardian
guard:validate:input { input }
guard:block:agent { agent_id, reason }
guard:get:state

// Guardian → Output
guard:validated { valid, sanitized_input }
guard:validation_failed { reason, details }
guard:blocked { blocked_item, reason, type }
guard:state_update { state }
```

### 10.2 Events

```
guard:input:validated
guard:input:blocked
guard:output:validated
guard:output:blocked
guard:code:validated
guard:code:failed
guard:security:alert
guard:loop:detected
guard:design:violated
guard:agent:blocked
```

## 11. Pendientes

- [ ] Definir reglas específicas de sanitization
- [ ] Configurar allowlists iniciales
- [ ] Definir qué linters incluir por lenguaje
- [ ] Configurar thresholds finales
- [ ] Definir formato de logs para integración
- [ ] Implementar Diseño Inspector anti-fatiga
- [ ] Configurar validación de stack MERN + FlyonUI
- [ ] Implementar protocolo Context Flush & Reload
- [ ] Configurar Auditoría de Git Log
