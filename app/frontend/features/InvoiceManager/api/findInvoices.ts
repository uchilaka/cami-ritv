import { useAppStoreWithDevtools as useStore } from '@/utils/store'
import { InvoiceSearchProps, InvoicesLoaderFn } from '../types'

export const findInvoices: InvoicesLoaderFn = async (payload: Partial<InvoiceSearchProps>, { signal } = {}) => {
  const { setInvoices } = useStore.getState()
  console.debug(`Finding invoices with payload:`, { ...payload })
  const result = await fetch('/invoices/search.json', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(payload),
    signal,
  })
  const data = await result.json()
  setInvoices(data)
  return data
}

export default findInvoices
