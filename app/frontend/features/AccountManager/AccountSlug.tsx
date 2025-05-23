import React, { FC, ReactNode } from 'react'

const AccountSlug: FC<{ children?: ReactNode }> = ({ children }) => {
  return (
    <span className="bg-yellow-100 text-yellow-800 text-xs font-medium me-2 px-2.5 py-0.5 rounded dark:bg-yellow-900 dark:text-yellow-300">
      {children}
    </span>
  )
}

export default AccountSlug
