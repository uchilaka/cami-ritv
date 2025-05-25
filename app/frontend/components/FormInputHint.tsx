import React, { FC, HTMLAttributes, ReactNode } from 'react'
import clsx from 'clsx'
import { ValidationFeedbackProps } from '@/types'

const FormInputHint: FC<HTMLAttributes<HTMLParagraphElement> & ValidationFeedbackProps & { children: ReactNode }> = ({
  children,
  error,
  success,
  ...otherProps
}) => {
  const labelStyle = clsx('mt-2 text-sm', {
    'text-gray-500 dark:text-gray-400': !error && !success,
    'text-green-600 dark:text-green-400': success,
    'text-red-600 dark:text-red-400': error,
  })
  return (
    <p {...otherProps} className={labelStyle}>
      {children}
    </p>
  )
}

export default FormInputHint
