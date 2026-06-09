// Format an integer amount of minor units (e.g. cents) as a currency string.
// Works in integer cents to avoid floating-point drift — the kind of subtle bug
// that makes money logic worth unit-testing.
export function formatMoney(
  amountInMinorUnits: number,
  currency: string,
): string {
  if (!Number.isInteger(amountInMinorUnits)) {
    throw new Error(
      `formatMoney expects an integer amount of minor units, received: ${amountInMinorUnits}`,
    );
  }

  const amountInMajorUnits = amountInMinorUnits / 100;

  return new Intl.NumberFormat(undefined, {
    style: "currency",
    currency,
  }).format(amountInMajorUnits);
}
