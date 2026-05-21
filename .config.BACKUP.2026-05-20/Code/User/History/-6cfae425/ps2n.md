# FASE 1: Editor

> **Spec:**  
> **Prioridad:** ✅ SI (Core MVP)  
> **Estado:** Especificado

## Vision

Simple, minimalsta, hacer una cosa y hacerla bien.

## Features

> FASE MVP:

| Features                                 | Descripcion                                                           |
| :--------------------------------------- | :-------------------------------------------------------------------- |
| edicion base (escribir, borrar, guardar) | edicion de codigo funte con soporte multilenguage                     |
| edicion media (copiar, pegar, cortar)    | (Ctrl+C, Ctrl+V, Ctrl+X)                                              |
| syntax highlinting                       | resaltado de sintaxis                                                 |
| Búsqueda y Reemplazo                     | Find & replace (Ctrl+ f)                                              |
| Ir a la linea                            | (Ctrl+G)                                                              |
| Avilitar/Desavilitar edicion             | (Ctrl+E)                                                              |
| lsp (language serever protocol)          | Autocompletado, go-to-definition, hover documentation, signature help |
| linters                                  | Validacion en timepo real (configurable)                              |
| Git Integration                          | Diff, status, blame integrados                                        |
| Configuracion                            | perfiles, ui, texto, keyboard shortcuts                               |

> FASE 2: Implementacion libre

| Features            | Descripcion                                                                                                                      |
| :------------------ | :------------------------------------------------------------------------------------------------------------------------------- |
| Tabs Múltiples      | Múltiples archivos abiertos simultáneamente                                                                                      |
| Git Integration     | Diff, status, blame integrados                                                                                                   |
| Breadcrumb          | Navegación de ruta de archivo                                                                                                    |
| seleccion multiple  | - (Ctrl+D) selecionar siguiente coincidencia con la seleccion actual                                                             |
|                     | - 1 click: posicionar el cursor, 2 click: seleccionar palabra, 3 clicks: selecionar linea completa                               |
| edicion multiple    | - ALt+Shift+ arrastrarcursor para editar multiples lineas en forma de rectangulo                                                 |
| navegacion avanzada | (arow left, arow up, arow down, arow right) mueven el cursor un caracter en la direccion de la flecha                            |
|                     | Ctrl+(arow left, arow up, arow down, arow right) mueven el cursor una palabra en la direccion de la flecha                       |
|                     | Shift+Ctrl+(arow left, arow up, arow down, arow right) mueven el cursor una palabra en la direccion de la flecha y la selecciona |
| Format Code         | Formateo automático por lenguaje                                                                                                 |
| Color Themes        | solporte a color themes persosnalizables y mas configuraciones de composicion (tranparencias y efectos de difuminado)            |
