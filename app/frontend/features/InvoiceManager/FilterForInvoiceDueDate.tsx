import React, { useState, useRef, useEffect, ChangeEventHandler, FC } from 'react'
import clsx from 'clsx'
import { Dropdown } from 'flowbite'

import FilterDropdown from './FilterDropdown'

const filterOptions = [
  ['', '(Filter by Due Date)'],
  ['past_due_7_days', 'Past due 7 days'],
  ['past_due_30_days', 'Past due 30 days'],
  ['past_due_later_than_30_days', 'Past due later'],
  ['due_today', 'Due today'],
  ['due_this_week', 'Due this week'],
  ['due_this_month', 'Due this month'],
  ['due_next_month', 'Due next month'],
  ['due_later_than_next_month', 'Due later'],
]

type DueDateFilterOption = (typeof filterOptions)[number][0]

interface FilterForInvoiceDueDateProps {
  defaultValue: DueDateFilterOption
  disabled: boolean
}

const FilterForInvoiceDueDate: FC<Partial<FilterForInvoiceDueDateProps>> = ({ defaultValue, disabled }) => {
  const triggerClassNames = clsx(
    'inline-flex items-center text-gray-500 border border-gray-300 focus:outline-none focus:ring-4 focus:ring-gray-100 font-medium rounded-lg text-sm px-3 py-1.5 dark:bg-gray-800 dark:text-white dark:border-gray-600',
    !disabled && 'bg-white hover:bg-gray-100 dark:hover:bg-gray-700 dark:hover:border-gray-600 dark:focus:ring-gray-700',
    disabled && 'bg-gray-200 hover:cursor-not-allowed',
  )
  const [selectedFilter, setSelectedFilter] = useState(defaultValue ?? '')
  const optionsLabelHash = Object.fromEntries(filterOptions)
  const targetRef = useRef(null)
  const controlRef = useRef(null)

  const onChange: ChangeEventHandler<HTMLInputElement> = ({ target }) => {
    setSelectedFilter(target.value)
    console.warn({ newValue: target.value })
  }

  useEffect(() => {
    /**
     * See Tailwind CSS documentation for more information
     * on how to use the Dropdown component:
     * https://flowbite.com/docs/components/dropdowns/#example
     */
    const $targetEl = targetRef.current
    const $controlEl = controlRef.current

    if ($targetEl && $controlEl) {
      new Dropdown(
        $targetEl,
        $controlEl,
        {
          placement: 'bottom-start',
        },
        { id: 'dueDateDropdownRadio' },
      )
    }
  }, [targetRef, controlRef])

  return (
    <div className="list-filter">
      <button
        ref={controlRef}
        id="dueDateDropdownRadioButton"
        data-dropdown-toggle="dueDateDropdownRadio"
        className={triggerClassNames}
        type="button"
        disabled={disabled}
      >
        <i className="mr-2.5 fa-sharp fa-solid fa-filter"></i>
        {optionsLabelHash[selectedFilter] ?? 'Due Date'}
        <svg className="w-2.5 h-2.5 ms-2.5" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 10 6">
          <path stroke="currentColor" strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="m1 1 4 4 4-4" />
        </svg>
      </button>

      {/*<!-- Dropdown menu -->*/}
      <FilterDropdown
        ref={targetRef}
        id="dueDateDropdownRadio"
        className="z-10 hidden w-48 bg-white divide-y divide-gray-100 rounded-lg shadow dark:bg-gray-700 dark:divide-gray-600"
        data-popper-reference-hidden=""
        data-popper-escaped=""
        data-popper-placement="top"
      >
        <ul className="p-3 space-y-1 text-sm text-gray-700 dark:text-gray-200" aria-labelledby="dueDateDropdownRadioButton">
          {filterOptions.map(([value, label], index) => (
            <li key={`due-date-filter-option-${index + 1}`}>
              <div className="flex items-center p-2 rounded hover:bg-gray-100 dark:hover:bg-gray-600">
                <input
                  id={`filter-due-date-radio-${value}`}
                  type="radio"
                  value={value}
                  defaultChecked={selectedFilter === value}
                  name="invoice-due-date-filter-radio"
                  className="w-4 h-4 text-blue-600 bg-gray-100 border-gray-300 focus:ring-blue-500 dark:focus:ring-blue-600 dark:ring-offset-gray-800 dark:focus:ring-offset-gray-800 focus:ring-2 dark:bg-gray-700 dark:border-gray-600"
                  onChange={onChange}
                />
                <label
                  htmlFor={`filter-due-date-radio-${value}`}
                  className="w-full ms-2 text-sm font-medium text-gray-900 rounded dark:text-gray-300"
                >
                  {label}
                </label>
              </div>
            </li>
          ))}
        </ul>
      </FilterDropdown>
    </div>
  )
}

export default FilterForInvoiceDueDate
