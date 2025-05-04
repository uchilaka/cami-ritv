import React from "react";
import {
  ArrowPathIcon,
  CloudArrowUpIcon,
  FingerPrintIcon,
  LockClosedIcon,
} from "@heroicons/react/24/outline";
import { FCWithLayout } from "@/@types";
import DemoLayout from "@/components/MinimalLayout";
import { FeatureConfig, FeatureProps, GenericHeroIcon } from "./@types";

const featureIcons: Record<string, GenericHeroIcon> = {
  "cloud-arrow-up-icon": CloudArrowUpIcon,
  "lock-closed-icon": LockClosedIcon,
  "fingerprint-icon": FingerPrintIcon,
  "arrow-path-icon": ArrowPathIcon,
};

const buildFeatures = (
  features: FeatureProps["features"]
): Array<Omit<FeatureConfig, "iconKey"> & { icon: GenericHeroIcon }> => {
  return features.map(({ iconKey, ...feature }) => ({
    ...feature,
    icon: featureIcons[iconKey],
  }));
};

const FeatureWith2x2Grid: FCWithLayout<FeatureProps> = ({
  features: featureConfigs,
}) => {
  const features = buildFeatures(featureConfigs);
  console.debug({ features });
  return (
    <div className="py-24 sm:py-32 bg-[radial-gradient(45rem_50rem_at_top,theme(colors.indigo.100),white)]">
      <div className="mx-auto max-w-7xl px-6 lg:px-8">
        <div className="mx-auto max-w-2xl lg:text-center">
          <h2 className="text-base/7 font-semibold text-indigo-600">
            Deploy faster
          </h2>
          <p className="mt-2 text-4xl font-semibold tracking-tight text-pretty text-gray-900 sm:text-5xl lg:text-balance">
            Everything you need to deploy your app
          </p>
          <p className="mt-6 text-lg/8 text-gray-600">
            Quis tellus eget adipiscing convallis sit sit eget aliquet quis.
            Suspendisse eget egestas a elementum pulvinar et feugiat blandit at.
            In mi viverra elit nunc.
          </p>
        </div>
        <div className="mx-auto mt-16 max-w-2xl sm:mt-20 lg:mt-24 lg:max-w-4xl">
          <dl className="grid max-w-xl grid-cols-1 gap-x-8 gap-y-10 lg:max-w-none lg:grid-cols-2 lg:gap-y-16">
            {features.map((feature) => (
              <div key={feature.name} className="relative pl-16">
                <dt className="text-base/7 font-semibold text-gray-900">
                  <div className="absolute top-0 left-0 flex size-10 items-center justify-center rounded-lg bg-indigo-600">
                    <feature.icon
                      aria-hidden="true"
                      className="size-6 text-white"
                    />
                  </div>
                  {feature.name}
                </dt>
                <dd className="mt-2 text-base/7 text-gray-600">
                  {feature.description}
                </dd>
              </div>
            ))}
          </dl>
        </div>
      </div>
    </div>
  );
};

FeatureWith2x2Grid.layout = DemoLayout;

export default FeatureWith2x2Grid;
