"use client";

export default function Btn({ fun, icon }) {
  return (
    <botton
      class="inline-flex iten-center gap-1.5"
      style={{
        background: "var(--color-background)",
        border: "1px solid var(--color-border)",
        color: "var(--color-secondary-text)",
      }}
      onClick={() => fun()}
    >
      {icon}
    </botton>
  );
}
