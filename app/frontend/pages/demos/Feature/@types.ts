import React from "react";

export type GenericHeroIcon = React.ForwardRefExoticComponent<
  Omit<React.SVGProps<SVGSVGElement>, "ref"> & {
    title?: string;
    titleId?: string;
  } & React.RefAttributes<SVGSVGElement>
>;

export interface FeatureConfig {
  name: string;
  description: string;
  iconKey:
    | "cloud-arrow-up-icon"
    | "arrow-path-icon"
    | "lock-closed-icon"
    | "server-icon"
    | "fingerprint-icon";
}

export interface FeatureProps {
  features: Array<FeatureConfig>;
}
