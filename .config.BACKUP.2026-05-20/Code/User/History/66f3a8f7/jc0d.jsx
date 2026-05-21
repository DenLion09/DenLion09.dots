const Btn = ( props ) => {
  const {icon, text, funct } = props
  const handleClick = (event) => {
    event.preventDefault();

    funct()
  };
  return <button onClick={handleClick} type="button">{icon, text}</button>;
};

export default Btn;
