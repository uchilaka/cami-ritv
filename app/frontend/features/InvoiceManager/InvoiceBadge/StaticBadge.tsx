import React, { FC } from 'react'

const StaticBadge: FC<{ isRecurring?: boolean }> = ({ isRecurring }) => {
  return (
    <>
      {isRecurring ? (
        <span className="bg-pink-100 text-pink-800 text-xs font-medium me-2 px-2.5 py-0.5 rounded dark:bg-pink-900 dark:text-pink-300">
          Recurring series
        </span>
      ) : (
        <span className="bg-gray-100 text-gray-800 text-xs font-medium me-2 px-2.5 py-0.5 rounded dark:bg-gray-700 dark:text-gray-300">
          One-time
        </span>
      )}
    </>
  )
}

export default StaticBadge
