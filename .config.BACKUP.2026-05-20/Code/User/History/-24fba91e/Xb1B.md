# Control de Flujo y Manejo de Errores

## El block statement

El block ESatement (Sentencia de bloque) es la estructura mas basica de javascript para agrupar multiples sentencias. Se delimita con llaves {}.

```javascript
{
  sentencia1;
  sentencia2;
  //....
  senteciaN;
}
```

**¿Para qué sirve realmente?**

En javascript, donde esperas una sola sentencia, podes poner una- Pero cuando necesitas varias, las agrupas con un bloque. Esto pasa TODO el tiempo con if, for, while, finction, etc.

```javascript
while (x < 10) {
  x++;
  console.log(x);
}
```

Sin las llaves, while (x < 10) x++; ejecutaria solo el x++. Con las llaves, ejecutaras todo loque esta adentro.

> LA TRAMPA QUE TENES QUE SABER!

```javascript
// var NO respeta el bloque.
var x = 1;
{
  var x = 2;
}
console.log(x); // -> 2, no 1
```

En C, Java, o cualquier lenguaje con block-scoping real, el x de adentro seria una varianble DISTINTA y afuera valdria 1.
Pero var ignora las llaves. El bloque no crea un nuevo scope para var.

> **¿La solucion?** Usa let y const. Ellos SI respetan el bloque

## If ... else - Toma de Decisiones

**La estructura base**

```javascript
if (condition) {
  sentencia1;
} else {
  sentencia2;
}
```

**Asi funciona:** JavaScript evalua condicion. Si da true, ejecuta centecia1. Si da false, ejecuta sentencia2.
Simple, ¿no?

Pero:
**Los 6 valores falsy (esto te va a ahorrar horas de debugging)**

Javascript NO pregunta "¿Esto es exactamente true?".
Pregunta **¿esto es trusty o falsy?**

| Valor     | ¿Por qué es falsy?                               |
| :-------- | :----------------------------------------------- |
| false     | El booleano false literal                        |
| undefined | Variable sin valor                               |
| null      | Ausencia intencional de valor                    |
| 0         | El número cero                                   |
| NaN       | "Not a Number" — resultado de operación inválida |
| ""        | String vacío                                     |

**TODO lo demas es truthy.** Y cuando digo todo, es todo:

- Objetos ({}, [], new Date()) -> truthy
- String no vacio ("False", "0") -> truthy
- Numeross destintos de cero -> truthy
- Infinito -> truthy

**La trampa CLASICA:** new Boolean(false) es truthy

```javascript
const b = new Boolean(false);
if (b) {
  // Esto se ejecuta porque es un objeto no el valor primitivo false
}
if (b == true) {
  // Esto no se ejcuta
}
```

### else if - Multiples condiciones

```javascript
if (condicion1) {
  statement1;
} else if (condicion2) {
  statement2;
} else if (condicionN) {
  statementN;
} else {
  statementLast;
}
```

> IMPORTANTE: Solo se cumple el primer bloque culla condicion sea true. Una vez que una se cumple,
> el resto se salta

### buenas practicas

1. SIEMPRE usa blowues - incluso para una sola linea

```javascript
if (condicion) hacerHalgo(); // MAL - confuso y propenso a errores
```

2. NUNCA uses asiignaciones como condidicion

```javascript
if ((x = y)) {
  // MAl esto ASIGNA, no compara
  // Siempre truthy a menos que sea falsy
}

if (x === y) {
  // BIEN - esto compara
  // ...
}
```

Es UN error tan común que tiene nombre: "assignment vs equality". Si alguna vez ves que un if siempre se ejecuta y no sabés por qué, revisá si usaste = en vez de ===.

## Switches - Multiples caminos

**¿que es y para que sirve?**

Switch es una alternativa a if...else if...else cuando evaluas una sola exprecion frente a multiples valores posibles.

```javascript
weitch (exprecion) {
  case valor1:
    sentencia1
    break;
  case valor2:
    sentencia2;
    break;
  case valor3:
    sentencia3;
    break;
  default:
    sentenciaDefault;
}
```

**¿Como funciona?**

1. Javascript evalua exprecion UNA VEZ
2. Busca un case cuyo valor coincida estrictamente (como con ===)
3. Si encuentra match ejecuta desdde ahí hasta que encuentre un break
4. Si No encuentra match -> ejecuta default
5. Si no hay match y no hay default no pasa nada y sige el codigo.

> LA TRAMPA MORTAL: el break (o "fall-through").

Esto es lo que separa a los que saben de los que no:

```javascript
let msg = "Hola";

switch (msg) {
  case "Hola":
    console.log("Saludo");
  // No hay break
  case "Chau":
    console.log("Despedida");
    break;
  default:
    console.log("Default");
    break;
}
```

**¿Qué imprime?** -> "Saludo" Y LUEGO "Despedida".

**¿Por que?** Porque cuando encontro "Hola", empezo a ejecutar desde ahi y hasta que encontro el primer break
y no es un bug en una faeature pero si no lo sabes, te vuelve loco debuggeabdo

**¿Cuándo USARÍAS el fall-through a propósito?**
Cuando varios casos comparten la misma lógica:

```javascript
switch (dia) {
  case "sabado":
  case "domingo":
    console.log("Fin de semana 🎉");
    break;
  case "lunes":
    console.log("Ánimo!");
    break;
  default:
    console.log("Día laboral");
}
```

Acá "sabado" y "domingo" hacen lo mismo — el fall-through evita repetir código.

**La regla de oro**

Cada case DEBE terminar con break (o return, o throw), A MENOS que quieras explícitamente fall-through al siguiente caso. Y si querés fall-through, dejalo EXPLÍCITAMENTE comentado:

```javascript
case "lunes":
  hacerAlgo();
  // 🟡 fall-through intencional — no hay break a propósito
case "martes":
  hacerOtraCosa();
  break;
```

default no necesita ir al final a menos que tengas unas sentencnias que quieras que se ejecuten en caso que ningun case coincida

Por convención va al final, pero puede ir donde quieras. El problema es que si va al medio y no tiene break, también hace fall-through:

```javascript
switch (x) {
  case 1:
    console.log("uno");
    break; // si aqui no uviese break tambien hace fall-through y sige al default
  default:
    console.log("default");
  // ← si no hay break, sigue al case 2
  case 2:
    console.log("dos");
    break;
}
```

## MAnejo de Errores

### Lanzar errores - throw

**¿Qué es?**

throw es la forma de decirle a JavaScript "Aquí pasó algo anormal, detén todo"

```javascript
throw expresion;
// **¿Qué puede lanzar? CUALQUIER COSA JavaScript no te limita;
throw "Error2"; // string
throw 42; // número
throw true; // booleano
throw {
  toString() {
    return "Soy un objeto!"; // objeto
  },
};
```

> [!warning] Pero **SOLO** porque **PUEDES** no significa que **DEBAS**

Comunmente se usa whle para lanzar throw de nuneros o string, esto es mas efectivo que crear cada throw para cada caso de forma independiente

Es decir:

```javascript
// Esto es pobre - pierdes informacion
throw "Algo salio mal";

// Esto es lo Correcto - Tienes nombre, mensaje, stack trace
throw new Error("Algo salio mal");
```

**¿Qué hace throw realmente?**
Cuando ejecutas throw:

1. La funcion actual se detienen inmediatamente (nada despues del throw se ejecuta)
2. La excepcíon "sube" por el call stack hacia la función que lo llamó a esta función.
3. Si en algún lugar del stack hay un try...catch, ahí se atrapa.
4. Si NO hay try...catch en ningun lado -> el programa crashea.

```javascript
function nivel1() {
  console.log("nivel1: antes");
  nivel2();
  console.log();
  console.log("nivel1: despues"); // <- esto NO se ejecuta si nivel2 lanza
}

function nivel2() {
  throw new Error("boom!");
  console.log("nivel2: esto nunca se ejecuta");
}

nivel1(); // ->la excepcion sube: nivel2 -> nivel1 -> programa crashea.
```

| Constructor    | Significado          | Cuándo usarlo                       |
| :------------- | :------------------- | :---------------------------------- |
| Error          | Error genérico       | Cuando no encaja en los demás       |
| SyntaxError    | Error de sintaxis    | El motor lo lanza automáticamente   |
| TypeError      | Tipo incorrecto      | Ej: llamar a algo que no es función |
| RangeError     | Valor fuera de rango | Ej: array con largo negativo        |
| ReferenceError | Variable no existe   | El motor lo lanza automáticamente   |
| URIError       | URI mal formada      | decodeURIComponent('%')             |

Patrón correcto para errores propios

```javascript
function dividir(a, b) {
  if (b === 0) {
    throw new Error("No se puede dividir por cero");
  }
  return a / b;
}
```

### try...catch - Atrapar Errores

**¿Qué es?**

Es el salvavidads de tu programa. MArcas un bloque de codigo que "intenta ejecutar" , y si algo falla en lugar de crashear, atrapas el erros y decides que hacer.

```javascript
try {
  console.log("2. detro de try");
  JSON.parse("JSON invalido{{{");
  console.log("3. Esto no ejecuta");
} catch {
  console.log("4. atrapé el error:", err.message);
}

console.log("5. despúes del try - el programa sigue vivo");
```

Salida:

1. antes del try
2. dentro del try
3. atrapé el error: Expected property name or '}' ...
4. después del try — el programa SIGUE VIVO

Fijate que el programa no cracheó lo retuvo en el catch y continuó.
ese es el poder del tr...catch

> [!warning] **¿Qué pasa si NO hay try...catch?**

JSON.parse("JSON invalido {{{"); // -> SyntaxError: Expected property name or '}' ...
El programa muere. Nada despues de esto se ejecuta.

Sin try...catch, los errores no atrapados matan tu programa.
