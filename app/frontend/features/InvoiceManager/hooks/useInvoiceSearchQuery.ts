import { findInvoices } from '@/utils/api'
import { Invoice, InvoiceSearchProps } from '../types'
import { useQuery } from '@tanstack/react-query'
import { useState } from 'react'

export const useInvoiceSearchQuery = (props?: Partial<InvoiceSearchProps>) => {
  const [invoices, setInvoices] = useState<Invoice[]>([])
  const queryKey = ['invoiceSearch']

  const query = useQuery({
    queryKey,
    queryFn: async ({ signal }) => {
      if (!props) return []

      const data = await findInvoices(props, { signal })
      setInvoices(data)
      return data
    },
  })

  return { query, invoices }
}
