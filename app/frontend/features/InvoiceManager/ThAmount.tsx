import React from 'react'
import { useFeatureFlagsContext } from '@/components/FeatureFlagsProvider'

export default function ThAmount() {
  const labelText = 'Amount'
  const { isEnabled } = useFeatureFlagsContext()
  return (
    <th scope="col" className="px-6 py-3">
      {isEnabled('sortable_invoice_index', 'invoice_filtering_by_amount') ? (
        <>
          <div className="flex justify-end">
            <a href="?s[][field]=amount&s[][direction]=desc" data-tooltip-target="tooltip-sort-by-amount">
              {labelText}
              <i className="fa-solid fa-caret-down px-2"></i>
            </a>
          </div>
          <div
            id="tooltip-sort-by-amount"
            role="tooltip"
            className="absolute z-10 invisible inline-block px-3 py-2 text-sm font-medium text-white transition-opacity duration-300 bg-gray-900 rounded-lg shadow-sm opacity-0 tooltip dark:bg-gray-700 normal-case"
          >
            Sort by amount
            <div className="tooltip-arrow" data-popper-arrow></div>
          </div>
        </>
      ) : (
        <div className="flex justify-end">{labelText}</div>
      )}
    </th>
  )
}
