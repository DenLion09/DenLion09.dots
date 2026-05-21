## Componentes de UI Atómica (Atomic Design)

1. **Button** — El clásico. Variantes (primary, secondary, ghost), estados (loading, disabled), y tamaños. Si ves botones duplicados con estilos inline, EXTRAE.

2. **Input / FormField** — Inputs con label, mensajes de error, iconos, y validación visual. El patrón Container-Presentational brilla aquí.

3. **Modal / Dialog** — Gestión de portal, focus trap, ESC para cerrar, y accessibility. No lo reinventes en cada vista.

4. **Typography** — Componentes para headings (h1-h6) y texto de cuerpo que respeten la escala tipográfica del diseño.

5. **Icon** — Wrapper para SVG/icons que maneje tamaño, color, y accesibilidad (aria-hidden).

## Componentes de Layout

6. **Container / Wrapper** — Limitador de ancho máximo, padding horizontal, y centrado del contenido.

7. **Stack / Spacer** — Componente que maneja espaciado vertical/horizontal entre elementos hijos (margin-bottom automático o gap).

8. **Grid / Flex** — Abstracciones sobre CSS Grid o Flexbox con props para breakpoints responsivos.

## Componentes de Navegación

9. **Link / NavLink** — Enlaces que manejan estados activos (especialmente con React Router), prefetching, y accesibilidad.

10. **Breadcrumb** — Navegación jerárquica basada en la ruta actual, extraída para no duplicar lógica de parseo de paths.

11. **Menu / Dropdown** — Menús desplegables con keyboard navigation y gestión de click outside.

## Componentes de Feedback

12. **Toast / Notification** — Sistema de notificaciones que se apila, se auto-destruye, y maneja tipos (success, error, warning).

13. **Skeleton / LoadingState** — Placeholders animados para estados de carga, específicos para cada tipo de contenido (texto, imagen, card).

14. **EmptyState** — Vista cuando no hay datos, con ilustración, mensaje, y acción sugerida.

15. **ErrorBoundary** — Componente de orden superior (o hook) que atrapa errores de renderizado y muestra UI de fallback.

## Componentes de Datos

16. **Avatar** — Imagen con fallback (iniciales), tamaños, y estados (online, away).

17. **Badge / Tag** — Etiquetas con colores semánticos, iconos opcionales, y estados (removable).

18. **Tooltip** — Texto flotante con posicionamiento dinámico (arriba, abajo, izquierda, derecha) según viewport.

19. **DataTable** — Tabla con sorting, pagination, row selection, y columnas configurables. Si tienes tablas en 3 vistas distintas, EXTRAE.

## Componentes de Formularios Complejos

20. **DatePicker / Calendar** — Selector de fechas con rangos, localization, y disable de días específicos.

21. **Select / MultiSelect** — Dropdown con búsqueda, selección múltiple, y chips visuales para elementos seleccionados.

22. **FileUpload** — Área de drag-and-drop, preview de archivos, validación de tamaño/tipo, y progreso de subida.

## Componentes de Composición

23. **Card** — Contenedor con header, body, footer, y sombras/elevación. Base para listas de items.

24. **Tabs** — Pestañas con estado activo, scroll horizontal en móvil, y contenido lazy-loaded.

25. **Accordion / Collapsible** — Secciones expandibles/colapsables con animación de altura.

---

## El Criterio de Oro

Un componente merece ser extraído cuando:

- **Se repite 2+ veces** con la misma estructura visual
- **Tiene lógica de UI compleja** (focus management, keyboard navigation, portal rendering)
- **Es parte de tu Design System** — si el diseñador lo nombra, tú lo extraes
- **Oculta complejidad** — el consumidor debería escribir `<Button>` no `<button className="px-4 py-2 bg-blue-600...">`

¿Vas a aplicar esto a un proyecto específico? Si me das el contexto del dominio (e-commerce, dashboard, formularios pesados), puedo darte una lista más afilada.
