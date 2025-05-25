import React, { ChangeEvent, FC, forwardRef, InputHTMLAttributes, useEffect } from 'react'
import PhoneLibInput, { isValidPhoneNumber, formatPhoneNumberIntl } from 'react-phone-number-input'
import { useFormikContext } from 'formik'
import clsx from 'clsx'
import { FormInputProps } from '@/types'
import useInputClassNames from '@/utils/hooks/useInputClassNames'
import FormInputHint from '../FormInputHint'

import 'react-phone-number-input/style.css'
import { useLogTransport } from '../LogTransportProvider'

type PhoneNumberInputProps = InputHTMLAttributes<HTMLInputElement> & FormInputProps & { international?: boolean }

const StyledInput = forwardRef<HTMLInputElement, PhoneNumberInputProps>(function StyledPhoneInput(
  { id, name, value, onChange, ...otherProps },
  ref,
) {
  const { logger } = useLogTransport()
  const { handleBlur, handleReset, setFieldValue } = useFormikContext<Record<string, string>>()

  const classNames = clsx('border-0 w-full bg-transparent', {
    'cursor-not-allowed': otherProps.readOnly || otherProps.disabled,
  })

  const handleChange = (ev: ChangeEvent<HTMLInputElement>) => {
    const newValue = ev.target.value
    logger.debug({ ev, newValue })
    if (onChange) onChange(ev)
    if (isValidPhoneNumber(newValue)) {
      logger.info(`Valid phone number input: "${newValue}"`)
      const intlValue = formatPhoneNumberIntl(newValue)
      const e164Value = intlValue.replace(/\s/g, '')
      setFieldValue(name, e164Value, isValidPhoneNumber(newValue))
    } else {
      logger.warn(`Invalid phone number input: ${newValue}`)
    }
  }

  logger.debug({ id, name, value })

  return (
    <input
      id={id}
      ref={ref}
      name={name}
      {...otherProps}
      className={classNames}
      placeholder={otherProps.placeholder ?? ' '}
      defaultValue={value}
      onChange={handleChange}
      onBlur={handleBlur}
      onReset={handleReset}
    />
  )
})

const PhoneLibNumberInput: FC<PhoneNumberInputProps> = ({ id, type = 'tel', label, success, error, hint, readOnly, ...otherProps }) => {
  const { containerClassNames, labelClassNames, inputElementClassNames } = useInputClassNames({
    readOnly: !!readOnly,
    error: !!error,
    success: !!success,
  })
  const inputClassName = clsx(inputElementClassNames, 'pb-0', { 'cursor-not-allowed': readOnly || otherProps.disabled })
  const { handleChange, errors, values = {} } = useFormikContext<Record<string, string>>()
  const message = errors[otherProps.name] ?? hint

  useEffect(() => {
    console.debug('PhoneLibNumberInput values:', { ...values })
  }, [values])

  return (
    <div className={containerClassNames}>
      <PhoneLibInput
        {...otherProps}
        id={id}
        inputComponent={StyledInput}
        className={inputClassName}
        defaultCountry="US"
        value={values[otherProps.name]}
        onChange={handleChange}
        readOnly={readOnly}
      />
      {label && (
        <label htmlFor={id} className={labelClassNames}>
          {label}
        </label>
      )}
      {message && (
        <FormInputHint error={error} success={success}>
          {message}
        </FormInputHint>
      )}
    </div>
  )
}

export default PhoneLibNumberInput
