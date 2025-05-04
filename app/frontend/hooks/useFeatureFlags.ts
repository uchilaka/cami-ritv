import { usePage } from "@inertiajs/react";

type FeatureFlag =
  | "feat__showcase"
  | "feat__marketing_announcements"
  | "feat_first_contact_consultation";

type FeatureFlags = Record<FeatureFlag, boolean>;

const useFeatureFlags = () => {
  const { props } = usePage();

  const featureFlags = (props?.feature_flags ?? {}) as FeatureFlags;

  return {
    isEnabled: (featureName: FeatureFlag) => {
      return !!featureFlags[featureName];
    },
    featureFlags,
  };
};

export default useFeatureFlags;
