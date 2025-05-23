// import { useAppStoreWithDevtools as useStore } from '@/utils/store'
import { InvoiceSearchProps, InvoicesLoaderFn } from '../types'
import { composeQueryParams } from '../utils'

export const getInvoices: InvoicesLoaderFn = async (payload?: Partial<InvoiceSearchProps>) => {
  // const { setInvoices } = useStore.getState()
  console.debug(`Fetching invoices with payload:`, { ...payload })
  const params = composeQueryParams(payload ?? {}, new URLSearchParams({ format: 'json' }))
  const result = await fetch(`/invoices?${params.toString()}`)
  const data = await result.json()
  // setInvoices(data)
  return data
}

export default getInvoices
