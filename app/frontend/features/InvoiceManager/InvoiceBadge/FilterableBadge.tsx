import React, { FC } from 'react'
import InvoiceBadge, { composeTooltipId } from '.'
import { Invoice } from '../types'

interface InvoiceFilterableBadgeProps {
  invoice: Invoice
  recurring?: boolean
}

export const FilterableBadge: FC<InvoiceFilterableBadgeProps> = ({ invoice }) => {
  const tooltipId = composeTooltipId(invoice)

  return (
    <>
      {invoice.isRecurring ? (
        <>
          <a href="?f[][billingType]=recurring" data-tooltip-target={tooltipId}>
            <span className="bg-pink-100 text-pink-800 text-xs font-medium me-2 px-2.5 py-0.5 rounded dark:bg-pink-900 dark:text-pink-300">
              Recurring series
            </span>
          </a>
          <InvoiceBadge id={tooltipId}>
            Filter by recurring series payments
            <div className="tooltip-arrow" data-popper-arrow></div>
          </InvoiceBadge>
        </>
      ) : (
        <>
          <a href="?f[][billingType]=one_time" data-tooltip-target={tooltipId}>
            <span className="bg-green-100 text-green-800 text-xs font-medium me-2 px-2.5 py-0.5 rounded dark:bg-green-900 dark:text-green-300">
              One-time
            </span>
          </a>
          <InvoiceBadge id={tooltipId}>
            Filter by one-time payments
            <div className="tooltip-arrow" data-popper-arrow></div>
          </InvoiceBadge>
        </>
      )}
    </>
  )
}

export default FilterableBadge
