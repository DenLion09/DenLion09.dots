export default function Btn() {
  return (
    <botton
      style={{
        background: "var(--color-surface)",
        border: "1px solid var(--color-border)",
        color: "var(--color-secondary-text)",
      }}
      onClick={() => {
        console.log("clicked");
      }}
    ></botton>
  );
}
