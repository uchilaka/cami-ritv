import React, { FC, HTMLAttributes, InputHTMLAttributes, ReactNode } from 'react'
import clsx from 'clsx'
import { Field } from 'formik'
import { FormInputProps } from '@/types'
import FormInputHint from './FormInputHint'
import useInputClassNames from '@/utils/hooks/useInputClassNames'

export const InputRow: FC<HTMLAttributes<HTMLDivElement> & { children: ReactNode }> = ({ children, ...otherProps }) => {
  return (
    <div {...otherProps} className="relative z-0 w-full mb-5 group">
      {children}
    </div>
  )
}

export const InputGrid: FC<HTMLAttributes<HTMLDivElement> & { children: ReactNode; cols?: Number }> = ({ children, ...otherProps }) => {
  const childrenAsList = React.Children.toArray(children)
  const cols = otherProps.cols ?? childrenAsList.length
  const containerStyle = clsx('grid md:gap-6', `md:grid-cols-${cols}`)

  return (
    <div {...otherProps} className={containerStyle}>
      {childrenAsList.map((item) => item)}
    </div>
  )
}

export const FloatingFormInput: FC<InputHTMLAttributes<HTMLInputElement> & FormInputProps> = ({
  label,
  type,
  id,
  className,
  error,
  success,
  hint,
  readOnly,
  ...otherProps
}) => {
  const { containerClassNames, labelClassNames, inputElementClassNames } = useInputClassNames({
    readOnly: !!readOnly,
    error: !!error,
    success: !!success,
  })
  return (
    <div className={containerClassNames}>
      <Field
        {...otherProps}
        id={id}
        type={type ?? 'text'}
        className={inputElementClassNames}
        placeholder={otherProps.placeholder ?? ' '}
        readOnly={readOnly}
      />
      {label && (
        <label htmlFor={id} className={labelClassNames}>
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
}

export default FloatingFormInput
