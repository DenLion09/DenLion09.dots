# Teotria

## ¿Que es la ia?

- IA debil / estrecha
  - Artificial Narow Inteligence
- IA debil
- IA general

## Machine learning

_NOTA_ a diferencia de la programacion tradicional dode se defenin las capacidades de un programa mediante ordenes directa
los algoritmos de machine learning son capases de mediante cientos de datos de entrenamiento derectar patranes predecibles

## ¿Que es un LLM?

_large lenguage model (LLM)_ es un modelo de generacion de texto que mediante estadistica predice la ciguiente palabra en una cadena de texto

## ¿Como funciona un LLM?

- arquitectura transformer
  - funcinamiento por capa
    - _Decoder:_ cada capa realiza un analisis de cada tokens analizando correspondecia
    - cada palabra es separadas en tokens y estos se les asigna una enumeraciones llamadas Embeddings y estos son relacionales
  - mecanismo de atencion
    - el modelo analiza toda la entadra wn cada una de las capas:
      - Relaciones sintacticas
      - Relaciones semanticas
      - Referencias porpronombres
      - contexto general
  - Vocabulario
    - el vocabulario es finito

### Fases de funcionamiento

1. tokenizacion - transforma el texto a tokens y estos a numeros
2. procesamiento - procesa todos los tokens de manera simultanea
3. prediccion - el modelo calcula las probavilidades para cada token en du vocabulario
4. seleccion - selecciona el token mas probable
5. repeticion - repite el proceso hata tener un token de salida

## ¿Como se entrenan los modelos?

1. pre-entrenamiento - (aprende lenguaje general _gramatica, hechos, patrones de texto, estructura de conosimiento humano_)
2. Finetuning (refinamiento)
   2.1 finetunning supervisado - es una pregunta al llm y una respuesta a dicha pregunta para que el modelo aprenda a responder adecuadamente
3. RLHF (reinforced learning from human feedback) - humanos califican las respuestas de un llm para condicionar estas

## ¿Como apende a programar?

aprenden como benimos comentando asicnando a cada token una puntuacion en base a el anterior, estos no saben programar o entender directamente en codigo que escriben

## Parametros

- parametros
  - son la cantidad de tokens distintos y la densidad del dataset de entrenamiento
  - aumenta la presicion
  - el contexto
  - tareas mas sofisticadas
  - require mas recursos
