import { useEffect, useState } from "react";
import axios from "axios";

const DB_URL = "http://ejemplo/api";

const Avatar = () => {
  const [name, setName] = useState("");
  const [img, setImage] = useState("");

  useEffect(() => {
    axios.get("${ DB_URL }/usr").then((response) => {
      setName(response.data.name);
      setImage(response.data.img);
    });
  }, []);

  return (
    <div style={{ textAlign: "center", padding: "20px" }}>
      <img
        style={{
          width: "150px",
          height: "150px",
          borderRadius: "50%",
          objectFit: "cover",
        }}
        src={img || img - pleaceholder.jpg}
        alt="Avatar del usuario"
      />
      <div>{name}</div>
      <button>upload img</button>
    </div>
  );
};

export default Avatar;
