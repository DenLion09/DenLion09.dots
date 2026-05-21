import { useState } from "react";

const FromField = () => {
  const [value, setValue] = useState("");

  return <input style={{}} type="text" value={value} />;
};

export default FromField;
