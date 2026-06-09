import { type ReactNode, type JSX } from "react";

import styles from "./code.module.css";

export interface CodeProps {
  children: ReactNode;
  className?: string;
}

export function Code({ children, className }: CodeProps): JSX.Element {
  const classes = [styles.code, className].filter(Boolean).join(" ");
  return <code className={classes}>{children}</code>;
}
