# **Inicio** - Eleccion del stack

- **Tech Radar:** Es una estrategia que permite visualizar y evaluar las tecnologias emergentes y consolidadas. Facilita la toma de desiciones informadas y adoptar, experimentar, mantener o dejar segun la nesecidades actuales y futuras.

- **Adopt:** Tecnologías probadas y recomendadas para su uso generalizado.
- **Trial:** Tecnologías que vale la pena probar en proyectos piloto.
- **Eval:** Tecnologías que se deben investigar para entender su potencial.
- **Hold:** Tecnologías que no se recomiendan en este momento.

**¿Cómo se hace?**

Se crea una serie de capas, cada una representa un una tag (Adopt, Trial, Eval, Hold) en estas se situan las tegnologias segun la ovservacion y se van moviendo en dependencia de la necesidad y la inovacion que representa. y adoptar son las tecnonologias adoptadas para su uso en produccion.

## **Harnes Ingeniering** - Sistemas robustos desde el diseño

Conoser y identificar las **amenazas** y **riesgos** potenciales:

- **Vulneravilidades de seguridad:** Fallos en el codigo que pueden ser explotados y comprometen la seguridad.
- **Errores de configuracion:** Configuraciones incorrectas que pueden afectar el correcto funconamiento.
- **Prevencion de agentes externos y monitoreo:** Preconsiderar la infraestructura y diseñar la infraestructura necesaria.
- **Fallos humanos:** Reciliencia ante acciones involuntarias humanas o automatizadas.

### **Recilieancia**

La `reciliencia` es la la capacidad de un sistema para recuperarse de fallos y seguir funcionando. Considerando:

- **Redundasncia:** Duplicar componentes criticos para que, si uno falla, el otro tome el control
- **Aislamiento:** Separar componentes para que si uno falla no afecte a los demas.
- **Monitorizacio:** Supervisar el sistema para detectar y responder problemas rapidamente
- **Mecanismos de recuperacion:** Implementar procesos automaticos para restaurar el sistema a un estado funcional.

### Diseño de seguridad controlada

Los controles de seguridad son medidas que se implementan para proteger el sistema contra amenazas. se diseñan sistemas seguros con:

- **autenticacion:** Verifioca la identidad del usuario antes de brindar acceso al sistema.
- **Autorizacion:** Denine y controla niveles de acceso a recursos y funciones del sistema.
- **Cifrado y encriptacion:** Protege los datos y conexiones.
- **Sistemas de detecion de intruciones:** Identifican y responden ante actividades sospechosas
