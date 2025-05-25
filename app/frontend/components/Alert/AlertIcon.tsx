import React, { FC, ReactNode } from 'react'
import clsx from 'clsx'

const accessibilityLabel = {
  success: 'Success',
  error: 'Error',
  warning: 'Warning',
  info: 'Info',
}

const alertIconClass = {
  success: 'fa-circle-check',
  error: 'fa-circle-exclamation',
  warning: 'fa-circle-question',
  info: 'fa-circle-info',
}

export interface AlertProps {
  variant?: 'success' | 'error' | 'warning' | 'info'
  children: ReactNode
}

const AlertIcon: FC<Pick<AlertProps, 'variant'>> = ({ variant = 'info' }) => {
  return (
    <>
      <i className={clsx('fa-regular', alertIconClass[variant])}>&nbsp;</i>
      <span className="sr-only">{accessibilityLabel[variant]}</span>
    </>
  )
}

export default AlertIcon
