import { Button } from "@repo/ui/button";
import { Card } from "@repo/ui/card";

export function App() {
  return (
    <main style={{ padding: "var(--space-6)" }}>
      <h1>Docs</h1>
      <p>Vite + React SPA + @repo/ui</p>
      <Card title="Tokens in action">
        <div
          style={{ display: "flex", gap: "var(--space-3)", flexWrap: "wrap" }}
        >
          <Button variant="primary">Primary</Button>
          <Button variant="ghost" size="sm">
            Ghost
          </Button>
        </div>
      </Card>
    </main>
  );
}
