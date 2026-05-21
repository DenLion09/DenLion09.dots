import { useEffect, useState } from "react";
import axios from "axios";

const DB_URL = "http://ejemplo/api"

const Avatar = () => {
  const [name, setName] = useState();
  const [img, setImage] = useState();

  useEffect(() => {
    axios.get("${ DB_URL }/usr" request, response).then((response) => {
      setName(response.name);
      setImage(response.img);
    });
  }, []);

  return (
    <div style={}>
      <img style={} src={img} alt="img-pleaceholder.jpg" />
      <div>{name}</div>
      <button>upload img</button>
    </div>
  );
};

export default Avatar;
