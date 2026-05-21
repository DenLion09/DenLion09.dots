# Aqui documentos ideas de isues

## Ssitema de egestion de memoria de agente

- En lugar de almacenar contexto de las tareas anteriores guardar datos de errores, soluciones, metodos de hacer ls cosas
  que funcione como un almacen de skills automatico
- El modelo puede crear un archivo estracto de la funcionalidad/app (STRACT.md) y la informacion que necesita sin nececidad de gurardarlo en un sistema de memoria y es mas rapido al no tener que usar un mcp
- sistema de auto gestion de skills y mcp
- sistema de auto gestion de documentacion oficial tanto para el modelo como el usuario usando contex7 para informacion especifica y replicas
  de las docs oficiales para el usuario
- si tema de specificaciones preestablecidas en el sistema de memoria que dote al agente de no inventar logica nueva siono de usar un componente conosido
  y probado
- preparar el sistema de memoria para dotar al agente de:
  1. informacion de la infraestructura personal
  2. informacion del marco de dependencias aprobadas
  3. informacion del sistema de build y sistemas propios
  4. informacion del plataformas

## filosofia de refuerso humano

- el usuario debe tener el control total de cada funcion - recurso - componente base - componente complejo - hilo y demas
- pensar la construccion de software como la construccion civil

**SDD flow**:

1. Planificacion
   - ¿Que es lo?
   - ¿Para que?
   - ¿para quien o quienes?
   - ¿por que?
   - ¿que deve hacer para?
   - ¿como lo haremos realidad?
   - ¿como probaremos que funciona?
   - ¿como evitar nunca estar satisfecho?
2. validacion y especificacion
   - diseño base de la interfaz (si es necesaria)
   - definicion de las capasidades funcionales basicas
   - diseño de la implementacion de las capasidades funcionales
   - definicion de las teecnologias, herramientas y sistemas para hacerlo realidad
   - diseño del testeo de las capacidades funncionales asi como de la implementacion de esta
   - documentar lista en forma de tareas para consolidar un punto de partida valido y seguro
3. Codificacion
   - al iniciar una tarea en modo cordinador/orquestador este carga automaticamente todos los archivos _.md_
     - en base a los _.md_ cargar todo lo necesario para empesar a trabajar para ello requiere una skill
   - siempre delegar a subajentes
   - un agente por tarea un git worktree por agente
   - el agente autotestea su respuesta y genera un STRACT.md
   - combersacion directa con el agente cordinador/orquestador via audio (avilitar un switch en el teclado para activar o desactivar la comversacion via audio)
   - el cordinador/orquestador puede generar automatizaciones para tareas repetitivas
   - git log como documentacion funte de documentacion

## contextos de trabajo

1. el sistema de navegador require una configuracion de prompting diferente dependiendo de si se esta desarrollando un proyecto
