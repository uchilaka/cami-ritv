import React, { FC, ReactNode, ComponentProps } from 'react'
import clsx from 'clsx'

type TabLinkProps = ComponentProps<'a'> & {
  children: ReactNode
  disabled?: boolean
  active?: boolean
}

const TabLink: FC<TabLinkProps> = ({ children, active, disabled, ...props }) => {
  const linkClassNames = clsx(
    'inline-flex w-24 rounded-t-lg justify-center p-2 items-center inline-flex group space-x-2',
    active ? 'active border-b-2 text-blue-600 border-blue-600 dark:text-blue-500 dark:border-blue-500' : 'border-transparent',
    disabled ? 'cursor-not-allowed text-gray-400 dark:text-gray-500' : 'hover:cursor-pointer',
    !(active || disabled) && 'hover:text-gray-600 hover:border-gray-300 dark:hover:text-gray-300',
  )
  return (
    <a {...props} aria-current={active ? 'page' : false} className={linkClassNames}>
      {children}
    </a>
  )
}

export default TabLink
