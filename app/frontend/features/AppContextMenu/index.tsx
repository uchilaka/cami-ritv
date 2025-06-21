import { AppGlobalProps } from '@/utils';
import useFeatureFlags from '@/utils/hooks/useFeatureFlags';
import AppStateProvider from '@/utils/store/AppStateProvider';
import React, { FC, lazy } from 'react';
import { BrowserRouter, Routes, Route } from 'react-router-dom';

const AccountContextMenu = lazy(
  () => import('@/features/AccountManager/AccountContextMenu')
);
const InvoiceContextMenu = lazy(
  () => import('@/features/InvoiceManager/InvoiceContextMenu')
);

const AppContextMenu: FC<AppGlobalProps> = ({ appStore }) => {
  const { isEnabled } = useFeatureFlags();

  return (
    <React.StrictMode>
      <AppStateProvider store={appStore}>
        <BrowserRouter>
          <Routes>
            {isEnabled('account_context_menu') && (
              <Route path="/accounts" element={<AccountContextMenu />} />
            )}
            <Route path="/app">
              <Route path="invoices" element={<InvoiceContextMenu />} />
              <Route path="*" element={<></>} />
            </Route>
            <Route path="*" element={<></>} />
          </Routes>
        </BrowserRouter>
      </AppStateProvider>
    </React.StrictMode>
  );
};

export default AppContextMenu;
