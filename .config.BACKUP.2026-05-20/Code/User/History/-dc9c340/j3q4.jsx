const Avatar = () => {
  const fethUserData = () => {
    // esta funcion
  };

  const { name = "Your name" } = fethUserData();

  return (
    <div>
      <img src="avatar.*" alt="img-pleaceholder.jpg" />
      <div></div>
      <button></button>
    </div>
  );
};

export default Avatar;
