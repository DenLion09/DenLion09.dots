import { React } from "react";
import { ReactDOM } from "react-dom/client";
import { createStore } from "redux";

const counterReducer = (state, action) => {
  switch (action.type) {
    case "INCREMENT":
      return state + 1;
    case "DECREMENT":
      return state - 1;
    case "ZERO":
      return 0;

    default:
      return state;
  }

  return state;
};

const store = createStore(counterReducer);

function App() {
  return (
    <div className="main.conteiner">
      <div className="counter-card"></div>
    </div>
  );
}

export default App;
