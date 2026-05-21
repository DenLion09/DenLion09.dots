# Gramar and types

## Fundmaentos y sintaxis

> [!Warning:] Siempre usa ; al final de cada statement. El ASI existe pero tiene edge cases que pueden generar bugs.

```javascript
// Bien
let x = 42;
console.log(x);

// Mal - mas de un statement en la misma linea sin ;
let a = 1 let b = 2 // SyntaxError
```

---

## Comentarios

```javascript
// Comentario en una linea

/* comentario
multilinea */
#!/usr/bin/env node    // Hasbang - solo para sripts de Node.js
```

> [!Warning:] Los comentarios multilinea `NO se pueden anidar`

```javascript
/*Esto /* no funciona */ SyntaxError */
```

---

## Declaracion de Variables

| Keywrok | Scope           | Reasignacion | Hoisting    |
| :------ | :-------------- | :----------- | :---------- | ------------------------------ |
| var     | Function/Global | Si           | Opcional    | SI (inicializa como undefined) |
| let     | Bloque {}       | No           | Opcional    | No Temporal Dead Zone          |
| const   | Bloque {}       | No           | Obligatoria | NO Temporal Dead Zone          |

### Scope - La diferencia clave

```javascript
// var NO respeta Bloques
If (true) {
    var x = 5;
}
console.log(x); // 5 - Se filtra fuera del bloque

// var NO respeta Bloques
If (true) {
    let y = 5;
}
console.log(y) // ReferenceError: y is not defined
```

### Hoisting -Como realmente funciona

var: LA declaracion se eleva al inicio del scope, pero la asignacion NO.

```javascript
console.log(x); undefined (NO da error)
var x = 3;
```

> TDZ: El periodo desde que entra al bloque hasta que se ejecuta la declatacion. Durante TDZ, la variable existe pero es innecesaria

### Const - La trampa

```javascript
const // NO significa inmutable. Significa no reasignable.
const PI = 3.14;
PI = 3 // TypeError - esto SI falla

const obj = {key: "value};
obj.key = "otro"; // Permitido - mutacio, no reacignacion

const arr = [1, 2, 4];
arr.push(5) // permitido
```

## Tipos de datos

### 7 Primitivos + Object

| Tipo      | Ejemplo            | Notas                                                          |
| :-------- | :----------------- | :------------------------------------------------------------- |
| Boolean   | true, false        | Ojo: el objeto Boolean es diferente                            |
| null      | null               | Es intencionalmente vacío. ¡Es de tipo object! (bug histórico) |
| undefined | undefined          | Valor por defecto de variables no inicializadas                |
| Number    | 42, 3.14           | Punto flotante de 64 bits (IEEE 754)                           |
| BigInt    | 9007199254740992n  | Enteros de precisión arbitraria. Se marca con n al final       |
| String    | "Hola", 'Hola'     | Secuencia de caracteres                                        |
| Symbol    | Symbol("id")       | Valor único e inmutable — para propiedades privadas            |
| Object    | { clave: "valor" } | Colección de pares clave-valor                                 |

### Tipado Dinamico

javascript es dinamicamente tipado - una variable puede cambiar de tipo:

```javascript
let respuesta = 42; // Number
respuesta = "Gracias"; // ahora es String - sin errores
```

#### Coercion co `+` (el operador mas traicionero)

```javascript
"La respuesta es " + 42; // "La respuesta es 42" - Number -> String
42 + " es la respuesta"; // "42 es la respueta"
"37" + 7; // "377" - contcatenacion (7) Number -> String
"37" - 7; // 30 - Number
"37" * 7; // 259 - Number
```

> Memoriza esto: `+` cons Strings -> concatena. Los demas operadores (combierten a numero).

### Literes (como escrivir valores en crudo)

#### Arrays Literales

```javascript
const cafes = ["French Roast", "Colombian", "Kona"];
const peces = ["Lion", , "Angel"]; // <- Elemento vacio en indice 1
```

**comas extras:** Dejan "huecos" (empty slots), NO undefined. Lod metodos como map()
saltan los huecos.

```javascript
const lista = ["home", , "school", ,]; // length: 4 la ultima como se ignora.
```

**Bunenas practicas:** Usa strailing commas oara diffs mas limpios den git.

#### Boolean Literales

solo dos: `true` y `false`

#### Numeros literales

| ejemplo             | tipo                 |
| :------------------ | :------------------- |
| 0, 117, 42          | Decimal (base 10)    |
| 0x77, 0x1A          | Exadecimal (base 16) |
| 0ob77, 0o123        | Octal (base 8)       |
| 0b1010, 0b1111      | Binario (base 2)     |
| 123456789n          | Punto flotante       |
| 3.14, .123, 3.1E+12 | Punto flonte         |
