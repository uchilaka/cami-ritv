export * from '../../features/AccountManager/api';
export * from '@/features/InvoiceManager/api/findInvoices';
export * from '@/features/InvoiceManager/api/getInvoices';

export const getFeatureFlags = async () => {
  const params = new URLSearchParams({ format: 'json' });
  const result = await fetch(`/api/v1/features?${params.toString()}`);
  const data: { features: Record<string, boolean>; flags: string[] } =
    await result.json();
  return data.features;
};
