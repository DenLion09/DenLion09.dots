import { useReducer } from "react";

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
};

const App = () => {
  const [count, dispatch] = useReducer(counterReducer, 0);

  return (
    <div>
      <div>{count}</div>
      <button onClick={() => dispatch({ type: "INCREMENT" })}>plus</button>
      <button onClick={() => dispatch({ type: "DECREMENT" })}>minus</button>
      <button onClick={() => dispatch({ type: "ZERO" })}>zero</button>
    </div>
  );
};

export default App;
