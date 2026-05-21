// Ejemplo de un Button que SÍ merece existir:
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
