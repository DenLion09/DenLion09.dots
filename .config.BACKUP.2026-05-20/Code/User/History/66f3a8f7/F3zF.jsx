const Btn = (props) => {
  const { icon, text, funct } = props;
  const handleClick = (event) => {
    event.preventDefault();

    funct();
  };
  return (
    <button onClick={handleClick} type="button">
      {icon} {text}
    </button>
  );
};

export default Btn;

/**
 * Como regla general: NO abstraigas hasta que el tercer uso repita el patrón.
Este componente actual no merece existir todavía. ¿Por qué?
---
Por qué NO (como está ahora):
1. Es un wrapper demasiado fino — solo agrega un espacio entre icon y text y llama a preventDefault(). No gana nada sobre el botón nativo.
2. preventDefault() con type="button" es innecesario — type="button" ya NO envía formularios. Solo tendría sentido si el botón vive dentro de un <form> con comportamiento custom o si previenes otro evento (como un tooltip padre).
3. funct debería ser onClick — estás reinventando una prop que ya existe en el DOM. Quien use tu componente espera pasar onClick.
4. No encapsula comportamiento real — si mañana necesitas un botón variante, un botón loading, un botón con tooltip... este componente no te ayuda.
---
Cuándo SÍ merece un componente Button:
Criterio
Variantes consistentes
Estado compartido
Lógica de negocio
Accesibilidad centralizada
3+ usos con el mismo patrón
---
Ejemplo de un Button que SÍ merece existir:
const Button = ({
  variant = "primary",
  isLoading = false,
  icon,
  children,
  onClick,
  disabled,
  ...rest // pasa todo lo demás al <button> nativo
}) => {
  const classes = `btn btn-${variant} ${isLoading ? "btn-loading" : ""}`;
  return (
    <button
      type="button"
      className={classes}
      onClick={onClick}
      disabled={disabled || isLoading}
      aria-busy={isLoading}
      {...rest}
    >
      {isLoading ? <Spinner /> : icon}
      {children}
    </button>
  );
};
 */
