import { useState } from "react";

const Spinner = ({ size = 12, color = "#3498db", className = "" }) => {
  return (
    <div
      className={"Wave-spiner ${lasname}"}
      role="status"
      aria-label="Cargando..."
    ></div>
  );
};

export default Spinner;
