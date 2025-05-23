import React, { FC, ReactEventHandler, useEffect, useState } from 'react';
import { useFeatureFlagsContext } from '@/components/FeatureFlagsProvider';
import { Invoice } from './types';
import FilterableBadge from './InvoiceBadge/FilterableBadge';
import StaticBadge from './InvoiceBadge/StaticBadge';
import InvoiceDueDate from './InvoiceDueDate';
import InvoiceActionsMenu from './InvoiceActionsMenu';
import InvoiceableInfo from './InvoiceableInfo';
import InvoiceListItemLabel from './InvoiceListItemLabel';

interface InvoiceItemProps {
  invoice: Invoice;
  onToggleSelect: ReactEventHandler<HTMLInputElement>;
  loading?: boolean;
  selected?: boolean;
}

const InvoiceListItem: FC<InvoiceItemProps> = ({
  invoice,
  loading,
  selected: defaultSelected,
  onToggleSelect,
}) => {
  const { isEnabled } = useFeatureFlagsContext();
  const [selected, setSelected] = useState<boolean>(defaultSelected ?? false);
  const { vendorRecordId, status, dueAt } = invoice;

  const handleSelectionChange = (ev: React.ChangeEvent<HTMLInputElement>) => {
    ev.persist();
    setSelected(ev.currentTarget.checked);
    onToggleSelect(ev);
  };

  useEffect(() => {
    if (invoice?.id && defaultSelected !== selected) {
      console.debug(
        `InvoiceListItem ${invoice.id} received change to defaultSelected:`,
        defaultSelected
      );
      setSelected(defaultSelected ?? false);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [defaultSelected]);

  return (
    <tr className="bg-white border-b dark:bg-gray-800 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-600">
      <td className="w-4 p-4">
        <div className="flex items-center">
          <input
            id={`invoice-select-checkbox--${invoice.id}`}
            type="checkbox"
            name="selected_invoices[]"
            value={invoice.id}
            className="w-4 h-4 text-blue-600 bg-gray-100 border-gray-300 rounded focus:ring-blue-500 dark:focus:ring-blue-600 dark:ring-offset-gray-800 dark:focus:ring-offset-gray-800 focus:ring-2 dark:bg-gray-700 dark:border-gray-600"
            data-invoice-id={invoice.id}
            onChange={handleSelectionChange}
            disabled={!!loading}
            checked={selected}
          />
          <label htmlFor="checkbox-table-search-1" className="sr-only">
            checkbox
          </label>
        </div>
      </td>
      <th
        scope="row"
        className="flex items-center px-6 py-4 text-gray-900 whitespace-nowrap dark:text-white"
      >
        <InvoiceListItemLabel
          invoice={invoice}
          filterableBillingType={isEnabled('filterable_billing_type_badge')}
        />
      </th>
      <td className="px-6 py-4">
        <InvoiceableInfo invoice={invoice} />
      </td>
      <td className="px-6 py-4">
        <InvoiceDueDate invoiceId={invoice.id} value={dueAt} />
      </td>
      <td className="px-6 py-4">
        <div className="flex items-center">{status}</div>
      </td>
      <td className="px-6 py-4">
        <div className="flex items-center justify-end">
          {invoice.amount?.formattedValue}
        </div>
      </td>
      <td className="px-6 py-4 text-end">
        <div className="flex justify-end">
          {/* TODO: Show a warning that the re-direct will go to PayPal; Explore implementing this behavior as automatic for external links */}
          <a
            href="#"
            className="text-xs font-medium hover:text-white border dark:hover:text-white focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg px-3 py-1.5 text-center me-2 text-blue-700 border-blue-700 hover:bg-blue-800 dark:border-blue-500 dark:text-blue-500 dark:hover:bg-blue-500 dark:focus:ring-blue-800"
          >
            <i className="fa fa-copy"></i> New deal
          </a>
          <InvoiceActionsMenu invoice={invoice} />
        </div>
      </td>
    </tr>
  );
};

export default InvoiceListItem;
