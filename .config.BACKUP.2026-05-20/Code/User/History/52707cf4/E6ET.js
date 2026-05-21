const onClickHandler = (event) => {
  event.preventDefault();

  console.log("clicked");
};

const Btm = (icon) => {
  return <bottom onClick={onClickHandler}>{icon}</bottom>;
};

export default Btm;
