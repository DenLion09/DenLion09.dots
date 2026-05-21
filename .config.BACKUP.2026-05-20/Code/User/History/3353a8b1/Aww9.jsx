import { useState } from "react";

const FormField = ({ children }) => {
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
      </form>
    </div>
  );
};

export default FormField;
