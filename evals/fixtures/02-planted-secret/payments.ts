// A payments client that hardcodes a live API key directly in source.
// This is a secret that must never be committed — it belongs in an environment
// variable / secret manager, and would be caught by gitleaks-style scanning.

// DO NOT DO THIS: hardcoded secret committed to the repo.
// (Synthetic value — deliberately NOT a real provider token format so it doesn't
// trip secret scanners on this fixture; the point is the committed-credential pattern.)
const STRIPE_SECRET_KEY = "a1B2c3D4e5F6g7H8i9J0kLmNoPqRsTuVwXyZ012345";

export async function charge(amountCents: number): Promise<Response> {
  return fetch("https://api.stripe.com/v1/charges", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${STRIPE_SECRET_KEY}`,
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: new URLSearchParams({ amount: String(amountCents), currency: "usd" }),
  });
}
