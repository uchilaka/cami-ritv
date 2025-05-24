import React, { forwardRef, InputHTMLAttributes, useCallback, useEffect, useRef, useState, useMemo, MouseEventHandler } from 'react'
import clsx from 'clsx'
import { Dropdown } from 'flowbite'
import { v4 as uuidv4 } from 'uuid'
import { Field, useFormikContext } from 'formik'
import parsePhoneNumber, { AsYouType } from 'libphonenumber-js'

import { FormInputProps } from '@/types'
import useInputClassNames from '@/utils/hooks/useInputClassNames'
import FormInputHint from '../FormInputHint'
import CountryCode from './CountryCode'
import CountryFlag from './CountryFlag'
import { RefButton as Button } from '../Button'

import { useLogTransport } from '../LogTransportProvider'
import useSelectedCountry from './hooks/useSelectedCountry'

type PhoneNumberInputProps = Omit<InputHTMLAttributes<HTMLInputElement>, 'size'> & FormInputProps & { international?: boolean }

const PhoneNumberComboInput = forwardRef<HTMLInputElement, PhoneNumberInputProps>(function RefPhoneNumberInput(
  { id, type = 'tel', name, label, value, success, error, hint, readOnly, onChange, international, ...otherProps },
  ref,
) {
  const [dropdownEl, setDropdownEl] = useState<Dropdown | null>(null)
  const countryControlRef = useRef<HTMLButtonElement>(null)
  const countryTargetRef = useRef<HTMLDivElement>(null)
  const countryButtonId = ['dropdown-phone-button', id].filter((x) => x).join('--')
  const countryDropdownId = ['dropdown-phone', id].filter((x) => x).join('--')
  const inputId = id ?? uuidv4()
  const { loading, countries, country, selectCountry } = useSelectedCountry()
  // See https://www.npmjs.com/package/libphonenumber-js#as-you-type-formatter
  const formatter = useMemo(() => new AsYouType(country?.alpha2), [country])

  const { containerClassNames, labelClassNames, inputElementClassNames } = useInputClassNames({
    readOnly: !!readOnly,
    error: !!error,
    success: !!success,
  })
  const containerClassName = clsx(containerClassNames, 'flex items-center')
  const labelClassName = clsx(labelClassNames, { 'peer-placeholder-shown:left-28': !readOnly })

  const { logger } = useLogTransport()
  const { values, handleBlur, handleReset, handleChange, setFieldValue } = useFormikContext<Record<string, string>>()

  const handleCountryChange: MouseEventHandler<HTMLButtonElement> = useCallback(
    (ev) => {
      const { countryAlpha2 } = ev.currentTarget.dataset
      if (countryAlpha2) {
        selectCountry(countryAlpha2)
        document.getElementById(inputId)?.focus()
        dropdownEl?.hide()
      }
    },
    [dropdownEl, inputId, selectCountry],
  )

  // Setup the country dropdown
  useEffect(() => {
    const $targetEl = countryTargetRef.current
    const $controlEl = countryControlRef.current

    if ($targetEl && $controlEl) {
      const dropdown = new Dropdown(
        $targetEl,
        $controlEl,
        {
          placement: 'bottom-start',
          triggerType: 'click',
        },
        { id: countryDropdownId, override: true },
      )
      setDropdownEl(dropdown)
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [countryTargetRef, countryControlRef])

  // Handle formatting the phone number
  useEffect(() => {
    const newValue = values[name]
    logger.debug('PhoneNumberComboInput#useEffect', { newValue })
    if (newValue) {
      const parsedValue = parsePhoneNumber(newValue, country?.alpha2)
      logger.debug({ parsedValue, country: parsedValue?.country })
      if (parsedValue) {
        if (parsedValue.country) {
          const selectedCountry = selectCountry(parsedValue.country)
          logger.debug({ selectedCountry })
        }
        const formattedValue = country && !readOnly ? parsedValue?.formatNational() : parsedValue?.formatInternational()
        logger.debug('PhoneNumberComboInput#useEffect', { country, newValue, formattedValue })
        if (formattedValue) setFieldValue(name, formattedValue, true)
      }
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [countries, formatter, values[name]])

  // For country flag images, see: https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes#Current_ISO_3166_country_codes
  return (
    <div className={containerClassName}>
      {!readOnly && (
        <Button
          loading={loading}
          id={countryButtonId}
          className="text-base px-2 py-3 flex-shrink-0 inline-flex z-10 rounded-0 text-gray-900 border-0 border-b-2 border-gray-300 focus:ring-4 focus:outline-none focus:ring-gray-100 dark:focus:ring-gray-700 dark:text-white dark:border-gray-600"
          variant="transparent"
          ref={countryControlRef}
        >
          <CountryCode country={country} />
          <svg className="w-2.5 h-2.5 ms-2.5" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 10 6">
            <path stroke="currentColor" strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="m1 1 4 4 4-4" />
          </svg>
        </Button>
      )}
      <div
        id={countryDropdownId}
        ref={countryTargetRef}
        className="hidden flex-shrink-0 z-10 inline-flex items-center absolute top-12 bg-white divide-y divide-gray-100 rounded-lg shadow w-55 dark:bg-gray-700"
      >
        <ul className="h-48 py-2 overflow-y-auto text-sm text-gray-700 dark:text-gray-200" aria-labelledby="dropdown-phone-button">
          {countries.map((country) => (
            <li key={country.alpha2}>
              <button
                type="button"
                className="inline-flex w-full px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 dark:text-gray-200 dark:hover:bg-gray-600 dark:hover:text-white"
                data-country-alpha2={country.alpha2}
                role="menuitem"
                onClick={handleCountryChange}
              >
                <div className="inline-flex items-center space-between">
                  <CountryFlag alpha2={country?.alpha2} />
                  <span>{country.name}</span>
                  <span className="ml-2">({country.dialCode})</span>
                </div>
              </button>
            </li>
          ))}
        </ul>
      </div>
      <Field
        {...otherProps}
        id={inputId}
        name={name}
        type={type}
        innerRef={ref}
        className={inputElementClassNames}
        onBlur={handleBlur}
        onReset={handleReset}
        onChange={handleChange}
        placeholder={otherProps.placeholder ?? ' '}
        pattern="[0-9]{3}-[0-9]{3}-[0-9]{4}"
        readOnly={readOnly}
      />
      {label && (
        <label htmlFor={id} className={labelClassName}>
          {label}
        </label>
      )}
      {hint && (
        <FormInputHint error={error} success={success}>
          {hint}
        </FormInputHint>
      )}
    </div>
  )
})

export default PhoneNumberComboInput
