/* eslint-disable @typescript-eslint/no-unsafe-return */
import React, { createContext, FC, useEffect } from 'react';
import { AppGlobalProps } from '../types';

const AppStateContext = createContext<{ store: AppGlobalProps['appStore'] }>(
  null!
);

export const useAppStateContext = () => React.useContext(AppStateContext);

interface AppStateProviderProps {
  store: AppGlobalProps['appStore'];
  children: React.ReactNode;
}

const AppStateProvider: FC<AppStateProviderProps> = ({ store, children }) => {
  useEffect(
    () =>
      store.subscribe(state => [state.invoicesMap], console.debug, {
        fireImmediately: true,
      }),
    []
  );

  return (
    <AppStateContext.Provider value={{ store }}>
      {children}
    </AppStateContext.Provider>
  );
};

export default AppStateProvider;
