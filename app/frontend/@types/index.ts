import { ReactNode, FC, ComponentProps } from "react";

// Temporary type definition, until @inertiajs/react provides one
export type ResolvedComponent = {
  default: ReactNode;
  layout?: (page: ReactNode) => ReactNode;
};

export type ReactNodeWithOptionalLayout = ReactNode & {
  layout?: ResolvedComponent["layout"];
};

export interface FCWithLayout<T = ComponentProps<"div">> extends FC<T> {
  layout?: ResolvedComponent["layout"];
}

export interface NavItem {
  href: string;
  label: string;
  name?: string;
  // new_tab?: boolean;
  // new_window?: boolean;
  // feature_flag?: string;
  // enabled?: boolean;
  submenu?: NavItem[];
}

export interface LayoutProps {
  children: ReactNode;
  navigation?: Array<NavItem>;
}
