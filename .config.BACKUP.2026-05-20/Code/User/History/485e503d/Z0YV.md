# Aqui documentos ideas de isues

## Sistema de Memoria Atómico (Sustitución de Engram/Vectores)

### DB Relacional de Micro-Skills

- Inventario de documentos pequeños (JSON/Markdown) con "instrucciones de montaje" y soluciones a errores previos
- El modelo no "recuerda" la charla, sino que "consulta el manual" de la skill necesaria
- Base de datos relacional/grafo para almacenar conocimientos estructurados

### Context7 Local (Biblioteca de Materiales)

- Réplicas locales de documentaciones oficiales (MERN, FlyonUI, etc.)
- Elimina dependencia de red y evita que la IA invente lógica
- Obliga a usar componentes ya probados

### Protocolo de Consulta

- El modelo pide "Materiales para [área]" y la DB devuelve el grafo de skills relacionado
- Cada nueva skill añadida debe ser validada por el Humano antes de considerarse "bloque listo"

## Protocolo "Context Flush & Reload" (Limpieza de Obra)

Para maximizar el rendimiento del Celeron N4500:

### Flush

- Tras cada tarea validada, se borra todo el historial de chat (KV Cache)
- Inmunidad a la alucinación por acumulación de contexto

### Reload

- El modelo se reinicia cargando únicamente los "activos estáticos" actualizados:
  - El STRACT.md (estado funcional)
  - El grafo de tareas
- Consumo mínimo de RAM

## Orquestación por Grafo No Lineal

### Main como Director de Obra

- El perfil único (Main) visualiza el grafo completo de dependencias
- Sabe qué "columnas" deben construirse antes de tirar la "losa"

### Nodos Atómicos

- Cada nodo del grafo es una tarea delegada a un subagente
- El subagente recibe un kit de información específico
- Evita que el subagente tenga que entender todo el proyecto

## Seguridad de Síntesis (Programa Estricto)

### Sintetizador Estricto

- Valida la unión entre la intención del usuario y la ejecución de la IA
- No es una IA juzgando a otra, sino un protocolo que verifica estructuras

### Auditoría de Git Log

- Se ha definido el mensaje de commit como una "caja negra"
- Si el modelo pierde contexto en el Flush, el sistema puede reconstruir la lógica técnica leyendo los mensajes de commit de los subagentes

## El Guardián como Inspector de Diseño

### Protocolo Anti-Fatiga

- El Guardián rechaza cualquier código CSS/Tailwind que incluya negros puros (#000) o blancos puros (#FFF)
- Asegura que la interfaz de la suite y los proyectos creados sigan reglas de salud visual

### Validación de Stack

- Bloqueo inmediato si se intenta usar librerías fuera del ecosistema MERN + FlyonUI

## Perfil Único (Main) vs. Multi-agentes

### Definición

- Un solo perfil de alta jerarquía que "dota" a subagentes temporales de las capacidades necesarias
- Inyección de contexto bajo demanda

### Características

- No se necesita múltiples perfiles complejos
- Main dota a subagentes con micro-skills específicas según la tarea del grafo

## contextos de trabajo

1. el sistema de navegador require una configuracion de prompting diferente dependiendo de si se esta desarrollando un proyecto

## Resumen de Archivos de Información Actualizados

El flujo SDD ahora exige la actualización obligatoria y sincronizada de:

    SPECS.md: El "Qué".

    PROPOSE.md: El "Cómo".

    DESIGN.md: El "Por qué" visual.

    STRACT.md: El "Estado" actual.
