import { useState } from "react";

const FromField = ({ text }) => {
  const [value, setValue] = useState("");

  return (
    <div>
      <form type="submit">
        <button>{text}</button>
      </form>
    </div>
  );
};

export default FromField;
