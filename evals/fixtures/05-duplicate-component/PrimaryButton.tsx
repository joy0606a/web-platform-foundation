import { type ButtonHTMLAttributes, type JSX } from "react";

import styles from "./PrimaryButton.module.css";

// A brand-new button component that re-implements what @repo/ui already
// provides via <Button variant="primary" />. This duplicates styling, variant
// logic, and the public API instead of reusing the design-system component.
export function PrimaryButton({
  children,
  ...props
}: ButtonHTMLAttributes<HTMLButtonElement>): JSX.Element {
  return (
    <button className={styles.primaryButton} type="button" {...props}>
      {children}
    </button>
  );
}
