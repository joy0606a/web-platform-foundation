import { useEffect, useState, type JSX } from "react";

interface Invoice {
  id: string;
  amountCents: number;
  paidCents: number;
  dueDate: string;
}

// This component mixes data fetching, business rules (tax, balance, overdue
// calculation), and rendering. It also renders straight into the data path
// with no loading state and no error state.
export function UserDashboard({ userId }: { userId: string }): JSX.Element {
  const [invoices, setInvoices] = useState<Invoice[]>([]);

  useEffect(() => {
    // Business logic + fetching living directly inside the component.
    fetch(`/api/users/${userId}/invoices`)
      .then((r) => r.json())
      .then((data: Invoice[]) => setInvoices(data));
  }, [userId]);

  // Business rules embedded in the view layer.
  const TAX_RATE = 0.0825;
  const withTax = invoices.map((inv) => ({
    ...inv,
    total: inv.amountCents * (1 + TAX_RATE),
    balance: inv.amountCents * (1 + TAX_RATE) - inv.paidCents,
    overdue: new Date(inv.dueDate).getTime() < Date.now(),
  }));
  const totalOwed = withTax.reduce((sum, inv) => sum + inv.balance, 0);

  // No loading state, no error state — renders an empty/incorrect UI while
  // the request is in flight or if it fails.
  return (
    <div>
      <h1>Balance: ${(totalOwed / 100).toFixed(2)}</h1>
      <ul>
        {withTax.map((inv) => (
          <li key={inv.id}>
            {inv.id}: {inv.overdue ? "OVERDUE" : "ok"}
          </li>
        ))}
      </ul>
    </div>
  );
}
