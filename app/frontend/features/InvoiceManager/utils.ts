import { Invoice, InvoiceSearchProps } from './types'

/**
 * @deprecated Perhaps too much ad-hoc complexity. The goal is to implement an abstraction for Ransack search (instead).
 */
export function composeQueryParams(searchProps: Partial<InvoiceSearchProps>, otherParams?: URLSearchParams): URLSearchParams {
  const params = otherParams ?? new URLSearchParams()
  for (const [key, value] of Object.entries(searchProps)) {
    if (value) {
      if (typeof value === 'object') {
        Object.entries(value).forEach(([filterKey, direction]) => {
          if (direction) {
            switch (key) {
              case 's':
                params.append(`s[][field]`, filterKey)
                params.append(`s[][direction]`, direction)
                break
              case 'f':
                params.append(`f[][field]`, filterKey)
                params.append(`f[][value]`, direction)
                break
              default:
                throw new Error(`Unsupported search key: ${key}`)
            }
          } else {
            // TODO: Perhaps clear the filter from params (instead of doing nothing)
          }
        })
      } else {
        params.append(key, value)
      }
    }
  }
  return params
}

export const reduceInvoiceListToMap: (invoices: Invoice[], mapOfInvoicesById?: Record<string, Invoice>) => Record<string, Invoice> = (
  invoices,
  mapById = {},
) => {
  return invoices.reduce(
    (map, invoice) => ({
      ...map,
      [invoice.id]: invoice,
    }),
    mapById,
  )
}
