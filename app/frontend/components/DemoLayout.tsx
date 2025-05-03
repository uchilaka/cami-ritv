import React, { FC, ReactNode } from "react";
import { LayoutProps } from "@/@types";
// import DemoNavbar from "@/features/DemoNavbar";
// import SiteFooter from "./SiteFooter";

const DemoLayout: FC<LayoutProps> = ({ children }) => {
  return (
    <>
      {/* <DemoNavbar /> */}
      {children}
      {/* TODO: Resolve compiled asset URLs to unlock use of frontend SiteFooter */}
      {/* <SiteFooter /> */}
    </>
  );
};

export default (page: ReactNode) => <DemoLayout>{page}</DemoLayout>;
