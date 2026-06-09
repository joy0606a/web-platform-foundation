import { Button } from "@repo/ui/button";
import { Card } from "@repo/ui/card";

export function meta() {
  return [
    { title: "Web — React Router v7" },
    {
      name: "description",
      content: "Web app running React Router v7 in framework mode (SSR).",
    },
  ];
}

export default function Home() {
  return (
    <main style={{ padding: "var(--space-6)" }}>
      <h1>Web</h1>
      <p>React Router v7 (framework mode, SSR) + @repo/ui</p>
      <Card title="Button showcase">
        <div
          style={{ display: "flex", gap: "var(--space-3)", flexWrap: "wrap" }}
        >
          <Button variant="primary">Primary</Button>
          <Button variant="secondary">Secondary</Button>
          <Button variant="ghost">Ghost</Button>
        </div>
        <div
          style={{
            display: "flex",
            gap: "var(--space-3)",
            alignItems: "center",
            flexWrap: "wrap",
            marginTop: "var(--space-4)",
          }}
        >
          <Button size="sm">Small</Button>
          <Button size="md">Medium</Button>
          <Button size="lg">Large</Button>
        </div>
      </Card>
    </main>
  );
}
