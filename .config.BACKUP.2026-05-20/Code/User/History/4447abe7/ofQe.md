# Ejercicios de HTML, CSS y JavaScript

Estos 10 ejercicios cubren los fundamentos básicos de cada tecnología. Cada uno incluye un prompt específico con los requisitos claros.

---

## [ ] Ejercicio 1: Portafolio Personal

**Prompt:**
Crea una página HTML que funcione como tu portafolio personal. La página debe tener:

- Un header con tu nombre y una navegación con 3 enlaces (Inicio, Proyectos, Contacto)
- Una sección "Sobre mí" con un breve párrafo descriptivo
- Una sección "Proyectos" con 3 cards que muestren: título del proyecto, descripción corta, y un botón "Ver más"
- Un footer con tus redes sociales (usa iconos o texto)
- Usa etiquetas semánticas (`header`, `nav`, `section`, `footer`)
- Agrega un estilo básico: fuente sans-serif, colores coherentes, padding consistente

**Archivos esperados:** `index.html`, `style.css`

---

## Ejercicio 2: Formulario de Registro

**Prompt:**
Construye un formulario de registro con los siguientes campos:

- Nombre completo (input type="text")
- Email (input type="email")
- Contraseña (input type="password")
- Confirmar contraseña (input type="password")
- Fecha de nacimiento (input type="date")
- Género (select con opciones: Masculino, Femenino, Otro)
- Acepto términos y condiciones (checkbox)
- Botón "Registrarse"

**Requisitos:**

- Usa etiquetas `<label>` asociadas correctamente a cada input mediante el atributo `for`
- El formulario debe tener validación HTML nativa (`required`, `minlength`)
- Estiliza los inputs para que sean consistentes y el botón tenga un color de fondo destacado
- Agrega un mensaje de error que se muestre solo cuando el formulario se envíe vacío

**Archivos esperados:** `register.html`, `register.css`

---

## Ejercicio 3: Tarjeta de Producto (Flexbox)

**Prompt:**
Crea una tarjeta de producto usando **Flexbox** para el layout. La tarjeta debe mostrar:

- Imagen del producto (puede ser un placeholder de 200x200px)
- Título del producto
- Precio (resaltado visualmente)
- Descripción corta
- Botón "Agregar al carrito"

**Requisitos:**

- La tarjeta debe estar centrada en la página
- El contenido dentro de la tarjeta debe distribuirse verticalmente con espacio uniforme
- El botón debe estar al final de la tarjeta
- Agrega una animación sutil al hacer hover sobre la tarjeta (sombra o escala)
- Haz la tarjeta responsive: en móviles ocupa todo el ancho, en desktop max-width de 300px

**Archivos esperados:** `product-card.html`, `product-card.css`

---

## Ejercicio 4: Galería Grid con Lightbox

**Prompt:**
Implementa una galería de imágenes usando **CSS Grid** con al menos 6 imágenes (puede usar placeholders de picsum.photos).

**Requisitos:**

- La grille debe ser responsive: 3 columnas en desktop, 2 en tablet, 1 en móvil
- Cada imagen debe tener un caption que aparezca al hacer hover
- Al hacer click en una imagen, debe abrirse un "lightbox" (modal) que muestre la imagen en tamaño grande con un botón para cerrar
- El lightbox debe tener un fondo semitransparente oscuro
- Usa JavaScript para manejar los clicks y mostrar/ocultar el modal

**Archivos esperados:** `gallery.html`, `gallery.css`, `gallery.js`

---

## Ejercicio 5: Reloj Digital con JavaScript

**Prompt:**
Crea un reloj digital que muestre la hora actual en tiempo real.

**Requisitos:**

- Muestra horas, minutos y segundos en formato HH:MM:SS
- El reloj debe actualizarse cada segundo automáticamente
- Estiliza el reloj para que sea legible y atractivo (tamaño grande, fuente monospace)
- Agrega una funcionalidad de "modo 12h / 24h" con un botón toggle
- Debajo del reloj, muestra la fecha actual formateada (ej: "Domingo, 17 de Mayo de 2026")

**Archivos esperados:** `clock.html`, `clock.css`, `clock.js`

---

## Ejercicio 6: Lista de Tareas (To-Do List)

**Prompt:**
Construye una aplicación de lista de tareas interactiva.

**Requisitos:**

- Un input de texto y un botón "Agregar" para crear nuevas tareas
- Las tareas aparecen en una lista debajo
- Cada tarea debe tener:
  - Checkbox para marcar como completada
  - Texto de la tarea
  - Botón para eliminar la tarea
- Las tareas completadas deben verse differentes (tachadas, color diferente)
- Las tareas deben persistir en `localStorage` - al recargar la página deben aparecer las tareas guardadas
- Agrega un contador de tareas pendientes

**Archivos esperados:** `todo.html`, `todo.css`, `todo.js`

---

## Ejercicio 7: Calculadora Básica

**Prompt:**
Crea una calculadora funcional con interfaz similar a las calculadoras tradicionales.

**Requisitos:**

- Display que muestre el número actual y el resultado anterior
- Botones numéricos del 0-9
- Botones de operaciones: suma, resta, multiplicación, división
- Botones: limpiar (C), igual (=), borrar último dígito (DEL)
- La calculadora debe realizar las operaciones correctamente
- Maneja el caso de división por cero (muestra "Error")
- Estiliza los botones en una grille 4x4
- Agrega efectos visuales al presionar botones (active state)

**Archivos esperados:** `calculator.html`, `calculator.css`, `calculator.js`

---

## Ejercicio 8: Menú Hamburguesa Responsive

**Prompt:**
Implementa un menú de navegación que se convierta en menú hamburguesa en dispositivos móviles.

**Requisitos:**

- Desktop: menú horizontal visible con 4 enlaces
- Mobile (menos de 768px): menú hamburguesa con icono de 3 líneas
- Al hacer click en el icono, el menú se despliega con animación (slide down)
- El menú móvil debe tener fondo oscuro y enlaces grandes y táctiles
- El cambio de diseño debe usar **Media Queries**, NO JavaScript para el layout
- Usa una transición suave para la apertura/cierre del menú
- El menú debe ser accesible (funcionar con teclado)

**Archivos esperados:** `menu.html`, `menu.css`, `menu.js` (solo para toggle)

---

## Ejercicio 9: Carrusel de Testimonios

**Prompt:**
Crea un carrusel automático de testimonios con controles manuales.

**Requisitos:**

- Muestra un testimonio a la vez con:
  - Foto del cliente (placeholder circular)
  - Nombre y cargo
  - Texto del testimonio
  - Estrellas de valoración (5 estrellas)
- Navega automáticamente cada 5 segundos
- Agrega botones de "anterior" y "siguiente"
- Agrega indicadores de puntos (dots) para ver en qué slide estás
- Los testimonios deben estar en un array de objetos en JavaScript
- La transición entre testimonios debe ser suave (fade o slide)

**Archivos esperados:** `testimonials.html`, `testimonials.css`, `testimonials.js`

---

## Ejercicio 10: Juego "Adivina el Número"

**Prompt:**
Crea un juego interactivo donde el usuario debe adivinar un número aleatorio entre 1 y 100.

**Requisitos:**

- El sistema genera un número secreto aleatorio al cargar la página
- El usuario introduce un número en un input
- Al presionar "Adivinar":
  - Si es correcto: mostrar mensaje de éxito en verde, número de intentos y opción de reiniciar
  - Si es mayor: mostrar "El número es menor" en rojo
  - Si es menor: mostrar "El número es mayor" en rojo
- Mostrar un historial de los intentos del usuario (lista de números intentados)
- Mostrar el número de intentos actuales
- Limitar a 10 intentos - si se agotan, mostrar "Perdiste" con el número correcto
- Agregar opción de "nuevo juego" para reiniciar

**Archivos esperados:** `guess-number.html`, `guess-number.css`, `guess-number.js`

---

## Cómo usar estos ejercicios

1. **Lee el prompt completo** antes de empezar a codear
2. **Planifica** qué estructura de archivos necesitas
3. **Implementa** el HTML primero, luego el CSS, luego el JavaScript
4. **Prueba** cada funcionalidad antes de continuar
5. **Compara** tu resultado con los requisitos del prompt
6. **Refactoriza** si tu código puede mejorarse

¡Éxitos practicando! 🚀
