"use client";

export default function Btn({ fun, icon, ref }) {
  return (
    <a
      class="inline-flex iten-center gap-1.5 px-2 py-1 rounded-md text-sm"
      style={{
        background: "var(--color-background)",
        border: "1px solid var(--color-border)",
        color: "var(--color-secondary-text)",
      }}
      onClick={() => fun()}
      target="blank"
      href={ref}
    >
      {icon}
    </a>
  );
}
