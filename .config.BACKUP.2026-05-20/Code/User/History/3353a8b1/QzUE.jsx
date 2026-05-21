import { useState } from "react";

const FromField = ({ text }) => {
  const [value, setValue] = useState("");

  fun;

  return (
    <div>
      <form
        onSubmit={(event) => {
          event.preventDefault();
          submitHandler();
        }}
      >
        <button>{text}</button>
      </form>
    </div>
  );
};

export default FromField;
