import { useEffect, useState } from "react";

const Avatar = () => {
  const { name, setName } = useState();
  const { img, setImage } = useState();

  useEffect(() => {
    axios.get({ DB_URL }, usr);
  }, []);

  return (
    <div>
      <img src={img} alt="img-pleaceholder.jpg" />
      <div>{name}</div>
      <button>upload img</button>
    </div>
  );
};

export default Avatar;
