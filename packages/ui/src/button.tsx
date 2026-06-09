import { type ButtonHTMLAttributes, type JSX } from "react";

import styles from "./button.module.css";

export interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: "primary" | "secondary" | "ghost";
  size?: "sm" | "md" | "lg";
}

function variantClass(
  variant: NonNullable<ButtonProps["variant"]>,
): string | undefined {
  switch (variant) {
    case "secondary":
      return styles.secondary;
    case "ghost":
      return styles.ghost;
    default:
      return styles.primary;
  }
}

function sizeClass(size: NonNullable<ButtonProps["size"]>): string | undefined {
  switch (size) {
    case "sm":
      return styles.sm;
    case "lg":
      return styles.lg;
    default:
      return styles.md;
  }
}

export function Button({
  variant = "primary",
  size = "md",
  className,
  type = "button",
  ...props
}: ButtonProps): JSX.Element {
  const classes = [
    styles.button,
    variantClass(variant),
    sizeClass(size),
    className,
  ]
    .filter(Boolean)
    .join(" ");

  return <button className={classes} type={type} {...props} />;
}
