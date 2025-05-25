import { Invoice } from '../types'
import React, { ComponentProps, FC } from 'react'

export const composeTooltipId = (invoice: Invoice) => {
  return `filter-by-recurring--${invoice.tooltipId || `-tooltip-${invoice.id}`}`
}

const InvoiceBadge: FC<ComponentProps<'div'>> = ({ id, children, ...props }) => {
  return (
    <div
      id={id}
      {...props}
      role="tooltip"
      className="absolute z-10 invisible inline-block px-3 py-2 text-sm font-medium text-white transition-opacity duration-300 bg-gray-900 rounded-lg shadow-sm opacity-0 tooltip dark:bg-gray-700 normal-case"
    >
      {children}
    </div>
  )
}

export default InvoiceBadge
