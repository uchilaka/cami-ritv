import React, { FC, ReactNode } from 'react';
import { ThemeProvider } from 'styled-components';
import { LayoutProps } from '@/@types';
import emeraldTheme from '@/utils/emeraldTheme';
// import DemoNavbar from "@/features/DemoNavbar";
// import SiteFooter from "./SiteFooter";

const BasicLayout: FC<LayoutProps> = ({ children }) => {
  return (
    <>
      {/* <DemoNavbar /> */}
      {children}
      {/* TODO: Resolve compiled asset URLs to unlock use of frontend SiteFooter */}
      {/* <SiteFooter /> */}
    </>
  );
};

const InertiaBasicLayout = (page: ReactNode) => (
  <ThemeProvider theme={emeraldTheme}>
    <BasicLayout>{page}</BasicLayout>
  </ThemeProvider>
);
InertiaBasicLayout.displayName = 'BasicLayout';

export default InertiaBasicLayout;
