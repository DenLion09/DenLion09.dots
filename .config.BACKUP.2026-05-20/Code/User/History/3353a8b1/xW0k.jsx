import { useState } from "react";

const FromField = () => {
  const [value, setValue] = useState("");

  return (
    <div>
      <input style={{}} type="text" value={value} />
    </div>
  );
};

export default FromField;
