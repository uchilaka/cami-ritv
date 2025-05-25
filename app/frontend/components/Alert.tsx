import React, { FC } from 'react'
import clsx from 'clsx'

import AlertIcon, { AlertProps } from './Alert/AlertIcon'

const Alert: FC<AlertProps> = ({ children, variant = 'info' }) => {
  const alertClassNames = clsx('flex items-center p-4 mb-4 text-sm border', {
    'text-green-800 border-green-300 rounded-lg bg-green-50 dark:bg-gray-800 dark:text-green-400 dark:border-green-800':
      variant === 'success',
    'text-red-800 border-red-300 rounded-lg bg-red-50 dark:bg-red-800 dark:text-red-400 dark:border-red-800': variant === 'error',
    'text-yellow-800 border-yellow-300 rounded-lg bg-yellow-50 dark:bg-yellow-800 dark:text-yellow-400 dark:border-yellow-800':
      variant === 'warning',
    'text-blue-800 border-blue-300 rounded-lg bg-blue-50 dark:bg-blue-800 dark:text-blue-400 dark:border-blue-800': variant === 'info',
  })

  return (
    <div className={alertClassNames} role="alert">
      <AlertIcon variant={variant} />
      <div>{children}</div>
    </div>
  )
}

export default Alert
