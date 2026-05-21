import { useState } from "react";

const Avatar = () => {
  const { name, setname } = useState;
  const { name, setname } = useState;

  return (
    <div>
      <img src="avatar.*" alt="img-pleaceholder.jpg" />
      <div>{name}</div>
      <button>upload img</button>
    </div>
  );
};

export default Avatar;
