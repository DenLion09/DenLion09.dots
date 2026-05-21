import { useState } from "react";

const Spinner = ({ size = 12, color = "#3498db", className = "" }) => {
  return (
    <div
      className={"Wave-spiner ${lasname}"}
      role="status"
      aria-label="Cargando..."
    >
      {[0, 1, 2, 3]}
    </div>
  );
};

export default Spinner;
