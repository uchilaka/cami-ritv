import React, { FC, useEffect, useRef } from 'react'
import { formatDistanceToNow, formatRelative } from 'date-fns'
import { Tooltip } from 'flowbite'

interface InvoiceDueDateProps {
  invoiceId: string
  value: Date
  pastDue?: boolean
  overDue?: boolean
}

const InvoiceDueDate: FC<InvoiceDueDateProps> = ({ invoiceId, value }) => {
  const dueDateDetailId = `due-date-detail--tooltip-${invoiceId}`
  const relativeDueAt = value ? formatDistanceToNow(value, { addSuffix: true }) : ''
  const dueDateDetail = value ? formatRelative(value, new Date(), { weekStartsOn: 0 }) : ''

  const tooltipRef = useRef<HTMLDivElement>(null)
  const controlRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    if (!tooltipRef.current || !controlRef.current || !value) return

    const control = controlRef.current
    const tooltip = tooltipRef.current

    new Tooltip(tooltip, control, { placement: 'left', triggerType: 'hover' }, { id: dueDateDetailId, override: true })
  }, [tooltipRef, controlRef, dueDateDetailId, value])

  return (
    <>
      <div ref={controlRef} className="flex items-center hover:cursor">
        {/* TODO: Make sure date is formatted in BE jbuilder template */}
        {relativeDueAt}
      </div>
      {dueDateDetail && (
        <div
          id={dueDateDetailId}
          ref={tooltipRef}
          role="tooltip"
          className="absolute z-10 invisible inline-block px-3 py-2 text-sm font-medium text-white transition-opacity duration-300 bg-gray-900 rounded-lg shadow-sm opacity-0 tooltip dark:bg-gray-700"
        >
          {dueDateDetail}
          <div className="tooltip-arrow" data-popper-arrow></div>
        </div>
      )}
    </>
  )
}

export default InvoiceDueDate
