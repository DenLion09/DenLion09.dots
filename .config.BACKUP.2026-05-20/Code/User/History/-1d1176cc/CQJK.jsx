import { useState } from "react";

const Spinner = ({ size = 12, color = "#3498db", className = "" }) => {
  return (
    <div
      className={"wave-spinner ${lasname}"}
      role="status"
      aria-label="Cargando..."
    >
      {[0, 1, 2, 3].map((index) => (
        <div
          key={index}
          className="wave-spinner__dot"
          style={{
            width: "${size}",
            height: "${size}",
            backgroundColor: color,
          }}
        ></div>
      ))}
    </div>
  );
};

export default Spinner;
