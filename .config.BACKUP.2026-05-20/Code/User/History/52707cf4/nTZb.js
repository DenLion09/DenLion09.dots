const onClickHandler = (event) => {
  event.preventDefault();

  console.log("clicked");
};

const Btm = (icon) => {
  return <bottom>{icon}</bottom>;
};

export default Btm;
