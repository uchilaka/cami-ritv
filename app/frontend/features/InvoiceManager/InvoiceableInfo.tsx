import React, { FC, useRef, useEffect } from 'react'
import { Tooltip } from 'flowbite'

import { Invoice } from './types'

const InvoiceableInfo: FC<{ invoice: Invoice }> = ({ invoice }) => {
  const { account } = invoice
  const slugTooltipId = `invoiceable-slug--${account?.id}`
  const tooltipRef = useRef<HTMLDivElement>(null)
  const controlRef = useRef<HTMLAnchorElement>(null)

  useEffect(() => {
    if (!tooltipRef.current || !controlRef.current) return

    const control = controlRef.current
    const tooltip = tooltipRef.current

    new Tooltip(tooltip, control, { placement: 'left', triggerType: 'hover' }, { id: slugTooltipId, override: true })
  }, [tooltipRef, controlRef, slugTooltipId])

  if (!account) {
    return <></>
  }

  return (
    <div className="flex flex-col">
      {/* Slug tooltip */}
      <div
        id={slugTooltipId}
        ref={tooltipRef}
        role="tooltip"
        className="absolute z-10 invisible inline-block px-3 py-2 text-sm font-medium text-white transition-opacity duration-300 bg-gray-900 rounded-lg shadow-sm opacity-0 tooltip dark:bg-gray-700"
      >
        {account.slug}
        <div className="tooltip-arrow" data-popper-arrow></div>
      </div>
      <div className="max-sm:flex max-sm:justify-start md:block items-center">
        {/* Display name */}
        <a ref={controlRef} href={`/accounts/${account.id}`} target="_blank" rel="noreferrer">
          <h6 className="text-semibold">{account.displayName}</h6>
        </a>
        {/* Email address */}
        {account?.email && <div className="max-sm:hidden">{account?.email}</div>}
      </div>
    </div>
  )
}

export default InvoiceableInfo
