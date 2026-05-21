# REVISION.md — Cambios Propuestos

> Propuestas para resolver los problemas de UI/UX

---

## PROBLEMAS IDENTIFICADOS

### 1. Hero + Projects: Diferentes estilos

**Problema:** Ambos containers tienen estilos distintos. No hay consistencia visual.

**Propuesta:**

- Usar mismo estilo de "target" para ambos
- Fondo más claro en light mode
- Sombre subtle (box-shadow)
- Animación sutil en hover y en carousel

### 2. ProjectTarget: Demasiado padding

**Problema:** Excessivo espacio en los bordes del target.

**Propuesta:**

- Reducir padding: `p-4` → `p-2`
- Reducir gap: `gap-4` → `gap-2`
- Image 60% → 50%

### 3. Empty space en main

**Problema:** Gran espacio vacío abajo del contenido.

**Propuesta:**

- Extender height: `min-h-[60vh]` → `min-h-[80vh]` o `h-full`
- Usar `flex-1` para que ocupen el espacio disponible

### 4. Hero: Sin foto

**Problema:** No hay foto de perfil.

**Propuesta:**

- Obtener avatar de GitHub: `https://avatars.githubusercontent.com/DenLion09`
- Mostrar en el Hero, tamaño 150x150 o similar
- Borde redondeado (circle)

### 5. Theme toggle sin sentido

**Problema:** Toggle solo cambia color en el área de la imágen.

**Propuesta:**

- El toggle DEBERÍA cambiar el tema completo (dark/light)
- Verificar que next-themes esté funcionando bien

---

## RESUMEN DE CAMBIOS

| #   | Problema           | Solución                                    |
| --- | ------------------ | ------------------------------------------- |
| 1   | Estilos不一致      | Unificar estilo target + sombra + animación |
| 2   | Mucho padding      | Reducir p-2, gap-2, image 50%               |
| 3   | Espacio vacío      | min-h-[80vh] + flex-1                       |
| 4   | Sin foto           | Obtener avatar de GitHub                    |
| 5   | Toggle no funciona | Verificar next-themes config                |

---

## WIREFRAME PROPUESTO (Home)

```
┌─────────────────────────────────────────────────┐
│                 HEADER                        │
│              (Navbar + Theme)               │
├─────────────────────────────────────────────┤
│                 MAIN                        │
│  ┌────────────────┬────────────────────┐  │
│  │                │                    │  │
│  │     HERO       │   PROJECTS         │  │
│  │   (target)    │   (carousel)      │  │
│  │   - Avatar    │   - Target       │  │
│  │   - Bio       │   - Nav buttons   │  │
│  │   - Skills   │   - Dots          │  │
│  │               │                    │  │
│  └────────────────┴────────────────────┘  │
└─────────────────────────────────────────────────┘
```

---

**¿Apruebas estos cambios o hay modificaciones?**
