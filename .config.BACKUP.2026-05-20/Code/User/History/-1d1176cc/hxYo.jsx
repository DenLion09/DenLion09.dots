// import { useState } from "react";

// const Spinner = ({ size = 12, color = "#3498db", className = "" }) => {
//   return (
//     <div
//       className={"wave-spinner ${lasname}"}
//       role="status"
//       aria-label="Cargando..."
//     >
//       {[0, 1, 2, 3].map((index) => (
//         <div
//           key={index}
//           className="wave-spinner__dot"
//           style={{
//             width: "${size}",
//             height: "${size}",
//             backgroundColor: color,
//             animationDelay: "${index * 0.1}s",
//           }}
//         ></div>
//       ))}
//     </div>
//   );
// };

// export default Spinner;

const WaveSpinner = ({ size = 12, color = "#3498db", className = "" }) => {
  return (
    <div
      className={`wave-spinner ${className}`}
      role="status"
      aria-label="Cargando..."
    >
      {/* 
        Mapeamos un array de 4 elementos para crear los puntos.
        ¿Por qué no escribirlos a mano? 
        Porque si mañana quieres 5 puntos, cambias el '4' por '5'.
        Eso es ESCALABILIDAD.
      */}
      {[0, 1, 2, 3].map((index) => (
        <div
          key={index}
          className="wave-spinner__dot"
          style={{
            width: `${size}px`,
            height: `${size}px`,
            backgroundColor: color,
            // El desfase (delay) se calcula dinámicamente
            animationDelay: `${index * 0.1}s`,
          }}
        />
      ))}
    </div>
  );
};
export default WaveSpinner;
