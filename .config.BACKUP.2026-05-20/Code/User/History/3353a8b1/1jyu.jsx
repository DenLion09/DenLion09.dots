import { useState } from "react";

const FromField = ({ text, children }) => {
  const submitHandler = () => {};

  return (
    <div>
      <form
        onSubmit={(event) => {
          event.preventDefault();
          submitHandler();
        }}
      >
        {children}
        <button type="submit">{text}</button>
      </form>
    </div>
  );
};

export default FromField;
