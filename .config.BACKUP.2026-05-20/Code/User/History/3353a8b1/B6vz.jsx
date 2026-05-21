import { useState } from "react";

const FromField = ({ text }) => {
  const submitHandler = () => {};

  return (
    <div>
      <form
        onSubmit={(event) => {
          event.preventDefault();
          submitHandler();
        }}
      >
        <button type="submit">{text}</button>
      </form>
    </div>
  );
};

export default FromField;
