import React, { ComponentType } from 'react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import FeatureFlagsProvider from '@/components/FeatureFlagsProvider';
import LogTransportProvider from '@/components/LogTransportProvider';
import AppStateProvider from '@/utils/store/AppStateProvider';
import { createAppStoreWithDevtools } from '@/utils/store';

export const withAllTheProviders = <P extends {}>(
  WrappedComponent: ComponentType<P>
) => {
  const displayName =
    WrappedComponent.displayName ?? WrappedComponent.name ?? 'Component';
  const ComponentWithAllTheProviders = (props: any) => {
    const queryClient = new QueryClient();
    const store = createAppStoreWithDevtools();

    return (
      <LogTransportProvider>
        <AppStateProvider store={store}>
          <QueryClientProvider client={queryClient}>
            <FeatureFlagsProvider>
              <WrappedComponent {...props} />
            </FeatureFlagsProvider>
          </QueryClientProvider>
        </AppStateProvider>
      </LogTransportProvider>
    );
  };
  ComponentWithAllTheProviders.displayName = `withAllTheProviders(${displayName})`;
  return ComponentWithAllTheProviders;
};

export default withAllTheProviders;
