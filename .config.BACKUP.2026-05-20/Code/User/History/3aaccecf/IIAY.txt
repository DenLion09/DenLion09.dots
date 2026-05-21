planifica la inplementacion de las caracteristicas faltantes para poder compilar un mvp funcional: iasdk para proveedores reales,
filtro de modelos no compatibles con las necesidades del sistema usando models.dev (tools, rasoning),
ui (tauiri), 

Parcial ⚠️ (6 items)
- Receive Input (orchestrator tiene send_message pero sin UI)
- Respond streaming (MockLlmClient devuelve todo junto, no es streaming real)
- Preserve Recent / Eviction (FIFO básica)
- Error handling de tools
No implementado ❌ (22 items)
Lo más crítico:
- UI completa (chat window, message list, input box, markdown)
- Integración real con LLM (solo MockLlmClient)
- GlobTool, SearchTool
- Validación de entrada (mensaje vacío, mensaje largo)
- Manejo de errores (timeout, retry, conexión)
- Selector de modelo
- Eventos de estado / streaming
---
🏆 Recomendaciones Prioritarias
1. ALTA Arreglar compilación: Mover tests/chat_state.rs a tests unitarios o agregar getter público
2. ALTA Capturar system prompt: Modificar AgentConfig para incluir system_prompt
3. ALTA Implementar provider real: Cliente HTTP contra Ollama API
4. MEDIA Endurecer seguridad: canonicalize en GrepTool, límite de tamaño en ReadTool
5. MEDIA Implementar GlobTool y SearchTool: 2 de 4 herramientas MVP faltan
6. MEDIA Eliminar doble locking: Simplificar Orchestrator
7. BAJA Reemplazar assert! por Result en constructores
8. BAJA Mejorar cobertura de tests: edge cases de herramientas, path traversal, state machine completa