import { useState } from "react";

const FromField = ({ text }) => {
  const [value, setValue] = useState("");

  return (
    <div>
      <form onSubmit={submitHandler}>
        <button
          onClick={(event) => {
            event.preventDefault();
          }}
        >
          {text}
        </button>
      </form>
    </div>
  );
};

export default FromField;
