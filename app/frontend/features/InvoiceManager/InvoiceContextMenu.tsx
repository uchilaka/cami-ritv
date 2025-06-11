import React, { useEffect } from 'react'
import { useInvoiceContext, withInvoiceProvider } from './InvoiceProvider'
import withAllTheProviders from '@/components/withAllTheProviders'
import GroupActionButton from '@/components/Button/GroupActionButton'
import { useAppStateContext } from '@/utils/store/AppStateProvider'

const InvoiceContextMenu = () => {
  const { store } = useAppStateContext()
  const [numberOfSelectedInvoices, setNumberOfSelectedInvoices] = React.useState(0)
  const { listenForInvoiceSelectionEvents } = useInvoiceContext()
  const { invoicesMap, selectedInvoicesMap } = store.getState()

  const calcNumberOfSelectedInvoices = (selectionMap: Record<string, boolean>) => {
    return Object.values(selectionMap).filter((val) => val === true).length
  }

  const invoiceSelectionHandler = (selectionMap: Record<string, boolean>) => {
    const mapFromState = store.getState().selectedInvoicesMap
    console.debug('Selected invoices changed:', { ...selectionMap })
    console.debug('Invoices map from store matches selection event?', mapFromState === selectionMap)
    setNumberOfSelectedInvoices(calcNumberOfSelectedInvoices(mapFromState))
  }

  useEffect(() => {
    const controller = listenForInvoiceSelectionEvents(invoiceSelectionHandler)

    return () => {
      controller.abort()
    }
  })

  useEffect(() => store.subscribe((state) => [state.invoicesMap, state.selectedInvoicesMap], console.warn, { fireImmediately: true }))

  console.debug('Invoice selection map:', { ...selectedInvoicesMap })

  if (numberOfSelectedInvoices < 1) return <></>

  return (
    <div className="max-w-screen-xl px-4 py-3 mx-auto">
      <div className="flex items-center">
        <div className="inline-flex rounded-md shadow-xs" role="group">
          <GroupActionButton
            icon={
              <svg
                className="w-6 h-6 text-gray-800 dark:text-white"
                aria-hidden="true"
                xmlns="http://www.w3.org/2000/svg"
                width="24"
                height="24"
                fill="none"
                viewBox="0 0 24 24"
              >
                <path
                  stroke="currentColor"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth="2"
                  d="M13.213 9.787a3.391 3.391 0 0 0-4.795 0l-3.425 3.426a3.39 3.39 0 0 0 4.795 4.794l.321-.304m-.321-4.49a3.39 3.39 0 0 0 4.795 0l3.424-3.426a3.39 3.39 0 0 0-4.794-4.795l-1.028.961"
                />
              </svg>
            }
            position="first"
            badgeCount={numberOfSelectedInvoices}
          >
            Link Account
          </GroupActionButton>
          {/* <button
              type="button"
              className="px-4 py-2 text-sm font-medium text-gray-900 bg-white border-t border-b border-gray-200 hover:bg-gray-100 hover:text-blue-700 focus:z-10 focus:ring-2 focus:ring-blue-700 focus:text-blue-700 dark:bg-gray-800 dark:border-gray-700 dark:text-white dark:hover:text-white dark:hover:bg-gray-700 dark:focus:ring-blue-500 dark:focus:text-white"
            >
              Middle Item
            </button> */}
          <GroupActionButton
            icon={
              <svg
                className="w-6 h-6 text-gray-800 dark:text-white"
                aria-hidden="true"
                xmlns="http://www.w3.org/2000/svg"
                width="24"
                height="24"
                fill="none"
                viewBox="0 0 24 24"
              >
                <path
                  stroke="currentColor"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth="2"
                  d="M12 11v5m0 0 2-2m-2 2-2-2M3 6v1a1 1 0 0 0 1 1h16a1 1 0 0 0 1-1V6a1 1 0 0 0-1-1H4a1 1 0 0 0-1 1Zm2 2v10a1 1 0 0 0 1 1h12a1 1 0 0 0 1-1V8H5Z"
                />
              </svg>
            }
            position="last"
            badgeCount={numberOfSelectedInvoices}
          >
            Archive
          </GroupActionButton>
        </div>
      </div>
    </div>
  )
}

export default withAllTheProviders(withInvoiceProvider(InvoiceContextMenu))
