import React, { ButtonHTMLAttributes, FC, ReactNode } from 'react'
import clsx from 'clsx'
import { ButtonBaseProps, ButtonLoader } from '.'
import useButtonClassNames from '@/utils/hooks/useButtonClassNames'

type GroupActionButtonProps = ButtonHTMLAttributes<HTMLButtonElement> &
  Pick<ButtonBaseProps, 'loading' | 'size'> & {
    icon?: ReactNode
    badgeCount?: number
    position?: 'first' | 'last'
  }

const TallyBadge: FC<{ count: number }> = ({ count = 0 }) => {
  return (
    <span className="inline-flex items-center justify-center w-4 h-4 ms-2 text-xs font-semibold text-blue-800 bg-blue-200 rounded-full">
      {count}
    </span>
  )
}

const GroupActionButton: FC<GroupActionButtonProps> = ({
  id,
  children,
  loading,
  icon,
  position,
  badgeCount,
  size = 'base',
  className = 'inline-flex items-center font-medium text-gray-900 bg-white border border-gray-200 hover:bg-gray-100 hover:text-blue-700 focus:z-10 focus:ring-2 focus:ring-blue-700 focus:text-blue-700 dark:bg-gray-800 dark:border-gray-700 dark:text-white dark:hover:text-white dark:hover:bg-gray-700 dark:focus:ring-blue-500 dark:focus:text-white',
  ...otherProps
}) => {
  const { buttonClassNames } = useButtonClassNames({ size, loading, disabled: otherProps.disabled })
  const buttonStyle = clsx(className, buttonClassNames, {
    'rounded-e-lg': position === 'last',
    'rounded-s-lg': position === 'first',
    'border-t border-b': !position,
  })

  return (
    <button type="button" {...otherProps} className={buttonStyle}>
      {loading ? (
        <ButtonLoader />
      ) : (
        <>
          {icon} {children} {badgeCount !== undefined && <TallyBadge count={badgeCount} />}
        </>
      )}
    </button>
  )
}

export default GroupActionButton
