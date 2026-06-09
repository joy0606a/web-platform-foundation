import { Button } from "@repo/ui/button";

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
    <main>
      <h1>Web</h1>
      <p>React Router v7 (framework mode, SSR) + @repo/ui</p>
      <Button appName="web">Click me</Button>
    </main>
  );
}
