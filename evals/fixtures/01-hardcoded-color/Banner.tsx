import { type JSX } from "react";

import styles from "./Banner.module.css";

export function Banner({ message }: { message: string }): JSX.Element {
  return (
    <div className={styles.banner}>
      <span>{message}</span>
      <button className={styles.dismiss} type="button">
        Dismiss
      </button>
    </div>
  );
}
