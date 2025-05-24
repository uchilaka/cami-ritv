import React, { FC } from 'react'

const CountryCodeBadge: FC<{ code?: string }> = ({ code = '--' }) => {
  return (
    <>
      <span className="bg-gray-100 text-gray-800 text-xs font-medium me-2 px-2.5 py-0.5 rounded-sm dark:bg-gray-700 dark:text-gray-300">
        {code}
      </span>
    </>
  )
}

export default CountryCodeBadge
