const onClickHandler = (event) => {
  event.preventDefault();

  console.log("clicked");
};

const Btm = (icon) => {
  return (
    <botton
      style={{ borderBottom: "1px solid var(--color-border)" }}
      onClick={() => {
        console.log("clicked");
      }}
    >
      contactame!
    </botton>
  );
};

export default Btm;
