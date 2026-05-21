# FASE 1: Editor

> **Spec:**  
> **Prioridad:** ✅ SI (Core MVP)  
> **Estado:** Especificado

## Vision

Simple, minimalsta, hacer una cosa y hacerla bien.

## Features

> FASE MVP:

| Features                                     | Descripcion                                                           | Secundario   |
| :------------------------------------------- | :-------------------------------------------------------------------- | :----------- |
| edicion de codio (escribir, borrar, guardar) | edicion de codigo funte con soporte multilenguage                     |              |
| syntax highlinting                           | resaltado de sintaxis                                                 |              |
| Búsqueda y Reemplazo                         | Find & replace (Ctrl+ f)                                              |              |
| ir a la linea                                | (Ctrl+G)                                                              |              |
| lsp (language serever protocol)              | Autocompletado, go-to-definition, hover documentation, signature help |              |
| linters                                      | Validacion en timepo real                                             | Configurable |
| Git Integration                              | Diff, status, blame integrados                                        |              |

> FASE 2: Implementacion libre

| Features            | Descripcion                                                                                                                      | Secundario |
| :------------------ | :------------------------------------------------------------------------------------------------------------------------------- | :--------- |
| **Tabs Múltiples**  | Múltiples archivos abiertos simultáneamente                                                                                      |
| **Git Integration** | Diff, status, blame integrados                                                                                                   |
| **Breadcrumb**      | Navegación de ruta de archivo                                                                                                    |
| seleccion multiple  | - (Ctrl+D) selecionar siguiente coincidencia con la seleccion actual                                                             |
|                     | - 1 click, posicionar el cursor, 2 click seleccionar palabra, 3 clicks selecionar linea completa                                 |
| navegacion avanzada | (arow left, arow up, arow down, arow right) mueven el cursor un caracter en la direccion de la flecha                            |
|                     | Ctrl+(arow left, arow up, arow down, arow right) mueven el cursor una palabra en la direccion de la flecha                       |
|                     | Shift+Ctrl+(arow left, arow up, arow down, arow right) mueven el cursor una palabra en la direccion de la flecha y la selecciona |
| Format Code         | Formateo automático por lenguaje                                                                                                 |
| **Breadcrumb**      | Navegación de ruta de archivo                                                                                                    |
