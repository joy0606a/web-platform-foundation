import { type JSX, type ReactNode } from "react";

import styles from "./card.module.css";

export interface CardProps {
  children: ReactNode;
  className?: string;
  title?: string;
}

export function Card({ children, className, title }: CardProps): JSX.Element {
  const classes = [styles.card, className].filter(Boolean).join(" ");

  return (
    <div className={classes}>
      {title ? <h2 className={styles.title}>{title}</h2> : null}
      {children}
    </div>
  );
}
