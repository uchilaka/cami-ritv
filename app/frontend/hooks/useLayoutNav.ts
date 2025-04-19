import { usePage } from "@inertiajs/react";
import { NavItem } from "@/@types";

type Logo = {
  aria_label: string;
  url: string;
};

const useLayoutNav = () => {
  const { props } = usePage();

  console.debug({ props });

  const navigation = props?.navigation as Array<NavItem> | null;
  const footerResourceLinks = props?.footer_resource_links as Array<
    [label: string, href: string]
  > | null;
  const footerCompanyLinks =
    props?.footer_company_links as Array<NavItem> | null;
  const siteLogo = props?.logo as Logo | null;

  return {
    navigation,
    footerCompanyLinks,
    footerResourceLinks,
    siteLogo,
  };
};

export default useLayoutNav;
