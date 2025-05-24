import React, {
  FC,
  createContext,
  ComponentType,
  Dispatch,
  ReactNode,
  SetStateAction,
  useCallback,
  useContext,
  useEffect,
  useState,
} from 'react'
import merge from 'lodash.merge'
import { LoadInvoiceEventDetail, nsEventName } from '@/utils'
import { useInvoiceSearchQuery } from './hooks/useInvoiceSearchQuery'
import { Invoice, InvoiceSearchProps } from './types'

type InvoiceSelectionEventCallback = (selections: Record<string, boolean>) => void

interface InvoiceContextProps {
  listenForInvoiceLoadEvents: () => AbortController
  listenForInvoiceSelectionEvents: (callback?: InvoiceSelectionEventCallback) => AbortController
  setInvoiceId: Dispatch<SetStateAction<string | undefined>>
  selectedInvoicesMap: Record<string, boolean>
  setSearchParams: Dispatch<SetStateAction<Partial<InvoiceSearchProps>>>
  updateSearchParams: (newParams: Partial<InvoiceSearchProps>) => void
  toggleInvoiceSelections: (...invoiceIds: string[]) => Promise<Record<string, boolean>>
  reload: () => Promise<void>
  numberOfSelectedInvoices?: number
  searchParams?: Partial<InvoiceSearchProps>
  loading?: boolean
  invoice?: Invoice | null
  invoices: Invoice[]
}

const InvoiceContext = createContext<InvoiceContextProps>(null!)

export const useInvoiceContext = () => useContext(InvoiceContext)

export const InvoiceProvider: FC<{ children: ReactNode }> = ({ children }) => {
  const [searchParams, setSearchParams] = useState<Partial<InvoiceSearchProps>>({})
  const [queryParams] = useState<Partial<InvoiceSearchProps>>({ s: { dueAt: 'asc' } })
  const [invoiceId, setInvoiceId] = useState<string>()
  const [loading, setLoading] = useState<boolean>()
  const { invoices, query } = useInvoiceSearchQuery(merge(queryParams, searchParams))
  const [selectedInvoicesMap, setSelectedInvoicesMap] = useState<Record<string, boolean>>({})

  const reload = useCallback(async () => {
    console.debug(`Loading invoices:`, { query })
    setLoading(true)
    const result = await query.refetch()
    console.debug({ result })
    if (result.isSuccess) setLoading(false)
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [query, searchParams])

  const listenForInvoiceLoadEvents = () => {
    const invoiceLoader = new AbortController()
    document.addEventListener(
      nsEventName('invoice:load'),
      (ev) => {
        const { detail } = ev as CustomEvent<LoadInvoiceEventDetail>
        console.debug(`Received request to load invoice: ${detail.invoiceId}`)
        setInvoiceId(detail.invoiceId)
      },
      /**
       * https://developer.mozilla.org/en-US/docs/Web/API/EventTarget/addEventListener#options
       */
      { capture: true, passive: true, signal: invoiceLoader.signal },
    )
    return invoiceLoader
  }

  const listenForInvoiceSelectionEvents = (callback?: InvoiceSelectionEventCallback) => {
    const invoiceSelectionListener = new AbortController()
    document.addEventListener(
      nsEventName('invoice:selected'),
      (ev) => {
        const { target, detail } = ev as CustomEvent<{ selectionMap: Record<string, boolean> }>
        console.debug(`Received invoice selection event:`, { target, detail })
        setSelectedInvoicesMap(detail.selectionMap)
        if (callback) {
          console.debug(`Invoking callback with invoice selection map:`, { ...detail.selectionMap })
          callback(detail.selectionMap)
        }
      },
      /**
       * https://developer.mozilla.org/en-US/docs/Web/API/EventTarget/addEventListener#options
       */
      { capture: true, passive: true, signal: invoiceSelectionListener.signal },
    )
    return invoiceSelectionListener
  }

  const updateSearchParams = ({ s, f, q }: Partial<InvoiceSearchProps>) => {
    const latestSearchParams = {
      s: merge(searchParams.s, s),
      f: merge(searchParams.f, f),
      q: q ?? searchParams.q,
    }
    console.debug(`Updating search params:`, { ...latestSearchParams })
    console.warn(`Check query params (deprecate?):`, { ...queryParams })
    setSearchParams(latestSearchParams)
  }

  const toggleInvoiceSelections = async (...invoiceIds: string[]) => {
    console.debug(`Toggling selection for invoice IDs:`, { invoiceIds })
    if (invoiceIds[0] === 'all' && invoices.length > 0) {
      const allMap = invoices.reduce((selectedInvoiceIds, invoice) => {
        selectedInvoiceIds[invoice.id] = !selectedInvoiceIds[invoice.id]
        return selectedInvoiceIds
      }, selectedInvoicesMap)
      setSelectedInvoicesMap(allMap)
      return allMap
    } else {
      const updatedInvoiceSelectionMap = invoiceIds.reduce((selectedInvoiceIds, invoiceId) => {
        selectedInvoiceIds[invoiceId] = !selectedInvoiceIds[invoiceId]
        return selectedInvoiceIds
      }, selectedInvoicesMap)
      setSelectedInvoicesMap(updatedInvoiceSelectionMap)
      return selectedInvoicesMap
    }
  }

  useEffect(() => {
    if (invoiceId || !!searchParams.q || !!searchParams.s || !!searchParams.f) {
      console.debug(`Reloading invoices with search params:`, { ...searchParams })
      reload()
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [invoiceId, searchParams])

  return (
    <InvoiceContext.Provider
      value={{
        searchParams,
        invoices,
        loading,
        reload,
        listenForInvoiceLoadEvents,
        listenForInvoiceSelectionEvents,
        selectedInvoicesMap,
        setInvoiceId,
        setSearchParams,
        updateSearchParams,
        toggleInvoiceSelections,
      }}
    >
      {children}
    </InvoiceContext.Provider>
  )
}

export const withInvoiceProvider = <P extends {}>(WrappedComponent: ComponentType<P>) => {
  const displayName = WrappedComponent.displayName ?? WrappedComponent.name ?? 'Component'
  /**
   * TODO: Should the ComponentWithInvoiceProvider props be typed as `P` instead of `any`?
   */
  const ComponentWithInvoiceProvider = (props: any) => (
    <InvoiceProvider>
      <WrappedComponent {...props} />
    </InvoiceProvider>
  )
  ComponentWithInvoiceProvider.displayName = `withInvoiceProvider(${displayName})`
  return ComponentWithInvoiceProvider
}
