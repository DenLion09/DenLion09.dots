1. what is "javascript" ?

javascript is a lightweight interpreted programing language with _first-class functions_.
while it is most well-knows as the scripting language for a Webs pages, many non-browser environment. Javascript is a _protopype based_, _garbage collected_, _dynamic_ language, suporting multiplws paradigms such as imperactive, functional, and object-oriented

1.1. Whats is a _first-class function_ ?

A programing language is said to have _Firs-Class functions_ when functions in hat language are trated like any other variable.
For axaple in such a language:

- a function can be passsed as an argument to other functions
- can be returned by another function
- can be assigned as a value to a variable.

```javascript
const foo = () => {
  console.log("foobar");
};
foo(); // Invoke it using the variable
```

> note: using () invoke a variable ej: "foo()", else, if we typing "foo" only, we can referencing the variable and not they invoked

_Passing function as an argumrnt_

```javascript
function seyHello() {
  return "Hello, ";
}
function greeting(helloMessage, name) {
  console.log(helloMessage(), +name);
}
//Pass seyHello as an argument to greeting function
greeting(sayHello, "JavaScript!");
//Hello, JavaScript
```

1.2. What is a _prototype bassed_ language ?

Protototype bassed language is a style of object oriented progrsming in whicth classes are not explicitly defined, but rether derived by adding properties and methods to an instance of another class or, less frequently, adding them to an object

in simples words: this type of srtyle allows the creation of an object without first defining its class

```javascript
prototype: {
  name: string,
  first_last_name: string,
  seccond_last_name: string,
  age: int,

  {
  {const greeting = () => {
    //...
  }}
  const program = () => {
    //...
  }
  }
}
```
