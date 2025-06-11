import { useState } from 'react';
import { findInvoices } from '@/utils/api';
import { useQuery } from '@tanstack/react-query';
import useCsrfToken from '@/utils/hooks/useCsrfToken';
import { Invoice, InvoiceSearchProps } from '../types';

export const useInvoiceSearchQuery = (props?: Partial<InvoiceSearchProps>) => {
  const { csrfToken } = useCsrfToken();
  const [invoices, setInvoices] = useState<Invoice[]>([]);
  const queryKey = ['invoiceSearch'];

  const query = useQuery({
    queryKey,
    queryFn: async ({ signal }) => {
      if (!props) return [];

      const data = await findInvoices(props, { signal, csrfToken });
      setInvoices(data);
      return data;
    },
  });

  return { query, invoices };
};
