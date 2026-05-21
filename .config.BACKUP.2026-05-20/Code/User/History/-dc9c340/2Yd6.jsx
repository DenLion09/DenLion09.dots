const Avatar = () => {
  const fethUserData = () => {
    // esta funcion busca y retorna un objeto con la info del usuarion
    // aun no hay nada porque es solo para practicar
  };

  const { name } = fethUserData();

  return (
    <div>
      <img src="avatar.*" alt="img-pleaceholder.jpg" />
      <div>{name}</div>
      <button>upload img</button>
    </div>
  );
};

export default Avatar;
