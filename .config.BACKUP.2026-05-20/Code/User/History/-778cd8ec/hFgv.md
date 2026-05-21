# PROPOSE.md — Página "Sobre mí"

> Propuesta de cambio para el feature P1

---

## 1. INTENT

**Problem statement:**
El portfolio actual tiene la información personal ("Sobre mí") hardcodeada en el componente `Hero.js`. Esta información es limitada (sólo 4 líneas) y no existe una ruta separada para ver más detalles del perfil profesional.

**User story:**
Como visitante del portfolio, quiero poder acceder a una página dedicada "Sobre mí" para ver la biografía extendida, experiencia profesional, habilidades técnicas y logros, para entender mejor el background y capacidades del desarrollador.

**Why ahora:**

- La información actual está incompleta y no extensible
- Es una feature de prioridad MEDIA en el roadmap
- Es prerequisito para la página de contacto

---

## 2. SCOPE

### In Scope

- Crear ruta `/about` con información completa
- Extraer bio a datos externos (data/bio.json)
- Mostrar experiencia profesional por año
- Mostrar habilidades técnicas por categoría
- Mostrar logros (GDE, MVP)
- Actualizar navbar con link a /about

### Out of Scope

- Formulario de contacto (P2)
- Detalle de proyectos (P3)
- Animaciones (P4)
- Testing (P5)
- Deploy

### Dependencies

- Ninguna dependencia externa nueva

---

## 3. APPROACH

### Opción A: Nueva ruta /app/about (Elegida)

```
/app/about/page.js  → Server Component
/components/AboutHero.js
/components/Skills.js
/components/Experience.js
/components/Achievements.js
/data/bio.json
```

**Pros:**

- Separación clara de concerns
- SEO friendly
- ISR capability para futuro
- Componentes reutilizables

**Cons:**

- Más archivos

### Opción B: Componente en Home

- Implementar como sección en page.js existente
- **Con:** No es scalable, no hay ruta separada

---

## 4. SUCCESS CRITERIA

| Criterio              | Métrica            |
| --------------------- | ------------------ |
| Ruta /about accesible | 200 OK             |
| Bio visible           | Texto renderizado  |
| Experiencia visible   | Lista de roles     |
| Habilidades visibles  | Tags por categoría |
| Logros visibles       | Badges/texto       |
| Navbar link funciona  | Click → /about     |
| Build pasa            | Sin errores        |

---

## 5.Timeline

- **Estimate:** 2-3 horas
- **Tasks:** 7 tareas
- **Risk:** Bajo

---

## 6. RELATED

- DESIGN.md — Arquitectura completa
- P2: Página de Contacto (próximo)
- P5: Testing (pendiente)

---

_Documento de propuesta creado para SDD workflow._
