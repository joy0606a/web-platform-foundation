import { describe, expect, it } from "vitest";

import { formatMoney } from "./money.ts";

describe("formatMoney", () => {
  it("formats a positive USD amount with major/minor unit conversion", () => {
    expect(formatMoney(1050, "USD")).toBe("$10.50");
  });

  it("formats zero as $0.00", () => {
    expect(formatMoney(0, "USD")).toBe("$0.00");
  });

  it("formats a negative amount", () => {
    expect(formatMoney(-1050, "USD")).toBe("-$10.50");
  });

  it("throws a clear error for non-integer input", () => {
    expect(() => formatMoney(10.5, "USD")).toThrow(/integer/);
  });

  it("formats EUR amounts", () => {
    expect(formatMoney(1050, "EUR")).toBe("€10.50");
  });

  it("formats large values with thousands separators", () => {
    expect(formatMoney(123456789, "USD")).toBe("$1,234,567.89");
  });
});
