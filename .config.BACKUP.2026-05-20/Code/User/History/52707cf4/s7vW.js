const Btn = (icon) => {
  return (
    <botton
      style={{ borderBottom: "1px solid var(--color-border)" }}
      onClick={() => {
        console.log("clicked");
      }}
    >
      {icon}
    </botton>
  );
};

export default Btn;
