# Web Design Standards - Diorges Professional Minimalist

## Philosophy

Diseño minimalista centrado en reducir fatiga visual, mejorar elegancia y fortalecer identidad de marca única. Cada decisión cromática y tipográfica debe serving a estos objetivos.

---

## Color System - Soft & Deep Palette

### Principio Fundamental

> **PROHIBIDO**: Uso de colores puros `#000000` (negro) y `#FFFFFF` (blanco).

### Light Mode - "Soft Stone"

```
Fondo principal:     #F2F0E9  (crema desaturado - imita papel premium)
Superficies:         #EAE8E0  (tarjetas, elementos elevados)
Texto principal:     #1A1B1E  (casi negro, no absoluto)
Texto secundario:    #54565B  (descripciones, metadata)
Acento:              #6B705C  (verde musgo grisáceo - CTAs, hover, highlights)
Bordes:              #DCD9D0  (sutiles, apenas visibles)
Status bar:          #E0DDD5  (chrome del navegador)
```

**Rationale**: Base crema que reduce emisión de luz azul vs blanco puro.

### Dark Mode - "Deep Mineral"

```
Fondo principal:     #121214  (gris mineral - NO negro absoluto)
Superficies:         #1E1E21  (tarjetas)
Texto principal:     #E2E2E2  (casi blanco, no absoluto)
Texto secundario:    #A0A0A5  (gris suave)
Acento:              #8B947E  (verde musgo claro)
Bordes:              #2C2C30  (sutiles)
Status bar:          #0D0D0F  (casi negro)
```

**Rationale**: Evita efecto "smearing" en OLED y reduce contraste excesivo que causa fatiga.

---

## CSS Custom Properties (tokens)

```css
:root {
  --color-background: #F2F0E9;
  --color-surface: #EAE8E0;
  --color-primary-text: #1A1B1E;
  --color-secondary-text: #54565B;
  --color-accent: #6B705C;
  --color-border: #DCD9D0;
  --color-status-bar: #E0DDD5;
  
  --shadow-sm: rgba(0, 0, 0, 0.05);
  --shadow-md: rgba(0, 0, 0, 0.08);
  --shadow-lg: rgba(0, 0, 0, 0.12);
  
  --transition-fast: 150ms ease;
  --transition-base: 300ms ease-in-out;
  --transition-slow: 500ms ease-in-out;
}

.dark {
  --color-background: #121214;
  --color-surface: #1E1E21;
  --color-primary-text: #E2E2E2;
  --color-secondary-text: #A0A0A5;
  --color-accent: #8B947E;
  --color-border: #2C2C30;
  --color-status-bar: #0D0D0F;
  
  --shadow-sm: rgba(0, 0, 0, 0.2);
  --shadow-md: rgba(0, 0, 0, 0.3);
  --shadow-lg: rgba(0, 0, 0, 0.4);
}
```

---

## Typography Rules

### Principios

1. **Contraste WCAG AA**: Ratio mínimo 4.5:1 para texto normal, 3:1 para texto grande
2. **Jerarquía clara**: Diferencia visual entre headings y body
3. **Whitespace generoso**: El diseño debe "respirar"

### Implementación

```css
/* Jerarquía tipográfica */
h1 {
  font-size: 2.5rem;      /* 40px */
  font-weight: 600;        /* Bold */
  letter-spacing: -0.02em; /* Tight tracking */
  color: var(--color-primary-text);
}

h2 {
  font-size: 1.5rem;      /* 24px */
  font-weight: 600;
  letter-spacing: -0.01em;
  color: var(--color-primary-text);
}

p, li {
  font-size: 1rem;        /* 16px */
  line-height: 1.6;       /* Leading generoso */
  color: var(--color-secondary-text);
}

/* Sección "Sobre mí" */
.section-label {
  font-size: 0.875rem;    /* 14px */
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.1em;
  color: var(--color-accent);
}
```

---

## Spacing System

### Whitespace Rules

- **Entre secciones**: `2rem` mínimo (`p-8` / `gap-8`)
- **Dentro de tarjetas**: `1.5rem` padding (`p-6`)
- **Entre elementos relacionados**: `1rem` (`gap-4`)
- **Entre elementos secundarios**: `0.5rem` (`gap-2`)

### Ejemplo de estructura

```jsx
<section className="flex flex-col lg:flex-row min-h-[90vh]">
  {/* Hero - 40% */}
  <div className="w-full lg:w-2/5 p-6 lg:p-8">
    <div className="h-full flex flex-col justify-center rounded-xl target" 
         style={{ padding: "1.5rem" }}>
      {/* Contenido con gap-6 entre elementos principales */}
    </div>
  </div>
  
  {/* Projects - 60% */}
  <div className="w-full lg:w-3/5 p-6 lg:p-8">
    <div className="h-full flex flex-col rounded-xl target"
         style={{ padding: "1.5rem" }}>
      {/* Contenido */}
    </div>
  </div>
</section>
```

---

## Component Patterns

### Target Card Pattern

Componente base para secciones principales. Usa `--color-surface` y `--color-border`.

```css
.target {
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: 0.75rem;
  box-shadow: 0 4px 6px -1px var(--shadow-sm);
  transition: box-shadow var(--transition-base), transform var(--transition-base);
}

.target:hover {
  box-shadow: 0 10px 15px -3px var(--shadow-md);
  transform: translateY(-2px);
}
```

### Tech Tags

Tags pequeños que muestran tecnologías/lenguajes.

```css
.tech-tag {
  padding: 0.4rem 0.8rem;
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: 0.5rem;
  font-size: 0.75rem;
  color: var(--color-secondary-text);
  transition: all var(--transition-fast);
}

.tech-tag:hover {
  background: var(--color-accent);
  color: white;
  border-color: var(--color-accent);
}
```

### Buttons - Minimalistas

```jsx
<button
  className="p-2.5 rounded-full transition-all duration-300 hover:scale-110"
  style={{
    background: "var(--color-surface)",
    border: "1px solid var(--color-border)",
    color: "var(--color-secondary-text)",
  }}
>
  <Icon className="w-4 h-4" />
</button>
```

### Indicators (carousel dots)

```jsx
<div className="flex gap-3">
  {items.map((_, idx) => (
    <button
      key={idx}
      className="rounded-full transition-all duration-300"
      style={{
        width: idx === active ? "24px" : "8px",
        height: "8px",
        background: idx === active 
          ? "var(--color-accent)" 
          : "var(--color-border)",
      }}
    />
  ))}
</div>
```

---

## Icon Integration

Iconos deben integrarse cromáticamente con la paleta.

```jsx
// Incorrecto - icono con color hardcodeado
<ArrowUpRight className="w-4 h-4 text-gray-400" />

// Correcto - icono usa token del tema
<ArrowUpRight 
  className="w-4 h-4" 
  style={{ color: "var(--color-accent)" }} 
/>
```

---

## Anti-Patterns (EVITAR)

```css
/* ❌ NO usar colores puros */
color: #000000;
color: #FFFFFF;
background: #000;
background: #FFF;

/* ❌ NO usar grises hardcodeados */
color: gray-500;        /* Tailwind */
color: #888888;
bg-gray-100;

/* ❌ NO usar sombras absolutas */
box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);

/* ❌ NO usar bordes duros */
border: 1px solid #e5e7eb;
border: 1px solid gray-200;

/* ✅ USAR tokens del tema */
color: var(--color-secondary-text);
background: var(--color-surface);
border: 1px solid var(--color-border);
box-shadow: 0 4px 6px var(--shadow-sm);
```

---

## Checklist de Aplicación

Para cada componente nuevo o refactorización:

- [ ] ¿Se usan los tokens del tema en vez de colores hardcodeados?
- [ ] ¿Se evitan colores puros (#000, #FFF)?
- [ ] ¿El contraste cumple WCAG AA?
- [ ] ¿Hay suficiente whitespace?
- [ ] ¿Los iconos están integrados cromáticamente?
- [ ] ¿Los estados hover/focus usan `--color-accent`?
- [ ] ¿Las transiciones usan `--transition-*` tokens?

---

## Theme Metadata

```json
{
  "themeName": "Diorges Professional Minimalist",
  "version": "1.0.0",
  "light": {
    "name": "Soft Stone",
    "rationale": "Base crema desaturada que imita el papel premium, reduciendo la emisión de luz azul."
  },
  "dark": {
    "name": "Deep Mineral", 
    "rationale": "Evita el negro absoluto para prevenir smearing en OLED y reducir fatiga visual."
  }
}
```