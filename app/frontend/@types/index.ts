import { ReactNode, FC } from "react";

// Temporary type definition, until @inertiajs/react provides one
export type ResolvedComponent = {
  default: ReactNode;
  layout?: (page: ReactNode) => ReactNode;
};

export type ReactNodeWithOptionalLayout = ReactNode & {
  layout?: ResolvedComponent["layout"];
};

export interface FCWithLayout<T> extends FC<T> {
  layout?: ResolvedComponent["layout"];
}

export interface NavItem {
  name: string;
  href: string;
  submenu?: NavItem[];
}

export interface LayoutProps {
  children: ReactNode;
  navigation?: Array<NavItem>;
}
