import React, { FC, ComponentProps, useEffect, useState } from 'react';
import FilterForInvoiceStatus from '../FilterForInvoiceStatus';
import FilterForInvoiceDueDate from '../FilterForInvoiceDueDate';
import withAllTheProviders from '@/components/withAllTheProviders';
import { useInvoiceContext, withInvoiceProvider } from '../InvoiceProvider';
import ThDueDate from '../ThDueDate';
import ThStatus from '../ThStatus';
import ThAmount from '../ThAmount';
import InvoiceListItem from '../InvoiceListItem';
import ThAccount from '../ThAccount';
import InvoiceSearchInput from './InvoiceSearchInput';
import InvoicingVendorPicker from '../InvoicingVendorPicker';
import { VendorType } from '../types';
import { useFeatureFlagsContext } from '@/components/FeatureFlagsProvider';
import LoadingAnimation from '@/components/LoadingAnimation';
import ButtonLink from '@/components/Button/ButtonLink';
import { emitInvoiceSelectedEvent } from '@/utils/events';
import { useAppStateContext } from '@/utils/store/AppStateProvider';

const InvoiceSearch: FC<ComponentProps<'div'>> = () => {
  let { store } = useAppStateContext();
  let {
    invoicesMap,
    selectedInvoicesMap: initialSelectedMap,
    setInvoices,
    handleInvoiceSelectionChange,
  } = store.getState();
  const [selectedMap, setSelectedMap] = useState(initialSelectedMap);
  const { loading, invoices } = useInvoiceContext();
  const { isEnabled } = useFeatureFlagsContext();
  const isInvoiceStatusFilterEnabled = isEnabled('invoice_filtering_by_status');
  const isInvoiceDueDateFilterEnabled = isEnabled(
    'invoice_filtering_by_due_date'
  );

  console.debug({ invoices, invoicesMap });

  const vendorSelectionHandler = (vendor: VendorType) => {
    console.debug(`Vendor changed @InvoiceSearch: ${vendor}`);
  };

  useEffect(() =>
    store.subscribe(
      ({ selectedInvoicesMap: latestSelectedMap }) => {
        emitInvoiceSelectedEvent(latestSelectedMap);
        setSelectedMap(latestSelectedMap);
        return latestSelectedMap;
      },
      console.warn,
      { fireImmediately: true }
    )
  );

  useEffect(() => {
    if (invoices.length > 0) setInvoices(invoices);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [invoices]);

  console.debug('Selected invoices map @InvoiceSearch:', { ...selectedMap });

  return (
    <>
      {/* <div className="flex justify-between items-center mb-6">
        <h1 className="font-bold text-4xl">Invoices</h1>
        <ButtonLink variant="primary" href="/invoices/new">
          New Invoice
        </ButtonLink>
      </div> */}
      <InvoicingVendorPicker onChange={vendorSelectionHandler} />
      <div className="flex items-center justify-between flex-column flex-wrap md:flex-row space-y-4 md:space-y-0 p-4 dark:bg-gray-900">
        <div className="flex flex-row space-x-4">
          <FilterForInvoiceStatus
            defaultValue=""
            disabled={!isInvoiceStatusFilterEnabled}
          />
          <FilterForInvoiceDueDate
            defaultValue=""
            disabled={!isInvoiceDueDateFilterEnabled}
          />
        </div>
        <InvoiceSearchInput />
      </div>

      {loading ? (
        <LoadingAnimation variant="text" />
      ) : (
        <table className="w-full text-sm text-left rtl:text-right text-gray-500 dark:text-gray-400">
          <thead className="text-xs text-gray-700 uppercase bg-gray-50 dark:bg-gray-700 dark:text-gray-400">
            <tr>
              <th scope="col" className="p-4">
                <div className="flex items-center">
                  <input
                    id="checkbox-all-search"
                    type="checkbox"
                    className="w-4 h-4 text-blue-600 bg-gray-100 border-gray-300 rounded focus:ring-blue-500 dark:focus:ring-blue-600 dark:ring-offset-gray-800 dark:focus:ring-offset-gray-800 focus:ring-2 dark:bg-gray-700 dark:border-gray-600"
                    data-invoice-id="all"
                    onChange={handleInvoiceSelectionChange}
                  />
                  <label htmlFor="checkbox-all-search" className="sr-only">
                    checkbox
                  </label>
                </div>
              </th>
              <th scope="col" className="px-6 py-3">
                Invoice #
              </th>
              <ThAccount />
              <ThDueDate />
              <ThStatus />
              <ThAmount />
              <th scope="col" className="px-6 py-3 flex justify-end">
                <div className="flex justify-end">Action</div>
              </th>
            </tr>
          </thead>
          <tbody>
            {invoices.map(invoice => (
              <InvoiceListItem
                key={`row--${invoice.id}`}
                invoice={invoice}
                onToggleSelect={handleInvoiceSelectionChange}
                loading={loading}
                selected={selectedMap[invoice.id]}
              />
            ))}
            {invoices.length === 0 && (
              <tr>
                <td
                  colSpan={6}
                  className="p-6 text-center text-lg text-gray-400 dark:text-gray-200"
                >
                  No invoices found
                </td>
              </tr>
            )}
          </tbody>
        </table>
      )}
    </>
  );
};

export default withAllTheProviders(withInvoiceProvider(InvoiceSearch));
