import React, { FC } from 'react'

import { Invoice } from './types'
import FilterableBadge from './InvoiceBadge/FilterableBadge'
import StaticBadge from './InvoiceBadge/StaticBadge'

interface InvoiceListItemLabelProps {
  invoice: Invoice
  filterableBillingType?: boolean
}

const InvoiceListItemLabel: FC<InvoiceListItemLabelProps> = ({ invoice, filterableBillingType }) => {
  return (
    <div className="flex flex-col">
      <div className="text-xl font-normal">
        <a href={invoice.actions.show.url}>{invoice.number || invoice.vendorRecordId}</a>
      </div>
      {filterableBillingType ? <FilterableBadge invoice={invoice} /> : <StaticBadge isRecurring={invoice.isRecurring} />}
    </div>
  )
}

export default InvoiceListItemLabel
