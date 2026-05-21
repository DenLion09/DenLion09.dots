"use client";

export default function Btn({ fun, icon }) {
  return (
    <botton
      style={{
        background: "var(--color-surface)",
        border: "1px solid var(--color-border)",
        color: "var(--color-secondary-text)",
      }}
      onClick={() => fun()}
    >
      {icon}
    </botton>
  );
}
