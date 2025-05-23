import React, { FC, HTMLAttributes } from 'react'
import { Field } from 'formik'
import { FormInputProps } from '@/types'
import FormInputHint from '../FormInputHint'
import useInputClassNames from '@/utils/hooks/useInputClassNames'

export type TextareaInputProps = HTMLAttributes<HTMLTextAreaElement> & FormInputProps & { readOnly?: boolean }

const TextareaInput: FC<TextareaInputProps> = ({ id, label, placeholder, hint, error, success, readOnly, ...otherProps }) => {
  const { containerClassNames, labelClassNames, inputElementClassNames } = useInputClassNames({
    readOnly: !!readOnly,
    error: !!error,
    success: !!success,
  })

  return (
    <div className={containerClassNames}>
      <Field
        as="textarea"
        {...otherProps}
        id={id}
        rows={4}
        className={inputElementClassNames}
        placeholder={placeholder ?? ' '}
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

export default TextareaInput
