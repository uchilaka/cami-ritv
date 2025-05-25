import { useAppStoreWithDevtools as useStore } from '@/utils/store';
import {
  InvoiceSearchProps,
  InvoicesLoaderFn,
  isValidListOfInvoices,
} from '../types';

export const findInvoices: InvoicesLoaderFn = async (
  payload: Partial<InvoiceSearchProps>,
  { signal, csrfToken = '' } = {}
) => {
  const { setInvoices } = useStore.getState();
  console.debug(`Finding invoices with payload:`, { ...payload });
  const result = await fetch('/invoices/search.json', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': csrfToken,
    },
    body: JSON.stringify(payload),
    signal,
  });
  // eslint-disable-next-line @typescript-eslint/no-unsafe-assignment
  const data = await result.json();
  // TODO: write a spec to ensure this type validation doesn't fail silently
  // eslint-disable-next-line @typescript-eslint/no-unsafe-argument
  if (!isValidListOfInvoices(data)) throw new Error('Invalid invoice data');
  setInvoices(data);
  return data;
};

export default findInvoices;
