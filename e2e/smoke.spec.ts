import { expect, test } from "@playwright/test";

test("home page renders the Web heading and a button", async ({ page }) => {
  await page.goto("/");

  await expect(page.getByRole("heading", { name: "Web" })).toBeVisible();
  await expect(page.getByRole("button").first()).toBeVisible();
});
