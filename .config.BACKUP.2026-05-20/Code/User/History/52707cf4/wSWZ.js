"use client";

export default function Btn(fun) {
  return (
    <botton
      style={{
        background: "var(--color-surface)",
        border: "1px solid var(--color-border)",
        color: "var(--color-secondary-text)",
      }}
      onClick={() => fun()}
    ></botton>
  );
}
