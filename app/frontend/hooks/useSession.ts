import { usePage } from "@inertiajs/react";

type IdentityProvider = "google" | "apple";
type IdentityProviderIds = Record<IdentityProvider, string>;

interface SessionUser {
  id: string;
  email: string;
  family_name: string;
  given_name: string;
  profile?: {
    image_url: string;
  };
  uids: IdentityProviderIds;
}

const useSession = () => {
  const { props } = usePage();

  console.debug({ props });

  const currentUser = props?.current_user as SessionUser | null;

  const isAuthenticated = !!currentUser;

  return {
    currentUser,
    isAuthenticated,
    isGoogleUser: !!currentUser?.uids?.google,
    isAppleUser: !!currentUser?.uids?.apple,
    isEmailUser: !currentUser?.uids?.google && !currentUser?.uids?.apple,
  };
};

export default useSession;
