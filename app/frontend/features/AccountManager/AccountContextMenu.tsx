import React from 'react'
import { withAccountProvider } from './AccountProvider'
import withAllTheProviders from '@/components/withAllTheProviders'

const AccountContextMenu = () => {
  return (
    <div className="max-w-screen-xl px-4 py-3 mx-auto">
      <div className="flex items-center">
        <div className="inline-flex rounded-md shadow-xs" role="group">
          <button
            type="button"
            className="inline-flex items-center px-4 py-2 text-sm font-medium text-gray-900 bg-white border border-gray-200 rounded-s-lg hover:bg-gray-100 hover:text-blue-700 focus:z-10 focus:ring-2 focus:ring-blue-700 focus:text-blue-700 dark:bg-gray-800 dark:border-gray-700 dark:text-white dark:hover:text-white dark:hover:bg-gray-700 dark:focus:ring-blue-500 dark:focus:text-white"
          >
            <i className="fa fa-people-group mr-1"></i> Combine Accounts
          </button>
          {/* <button
              type="button"
              className="inline-flex items-center px-4 py-2 text-sm font-medium text-gray-900 bg-white border-t border-b border-gray-200 hover:bg-gray-100 hover:text-blue-700 focus:z-10 focus:ring-2 focus:ring-blue-700 focus:text-blue-700 dark:bg-gray-800 dark:border-gray-700 dark:text-white dark:hover:text-white dark:hover:bg-gray-700 dark:focus:ring-blue-500 dark:focus:text-white"
            >
              Middle Item
            </button> */}
          <button
            type="button"
            className="inline-flex items-center px-4 py-2 text-sm font-medium text-gray-900 bg-white border border-gray-200 rounded-e-lg hover:bg-gray-100 hover:text-blue-700 focus:z-10 focus:ring-2 focus:ring-blue-700 focus:text-blue-700 dark:bg-gray-800 dark:border-gray-700 dark:text-white dark:hover:text-white dark:hover:bg-gray-700 dark:focus:ring-blue-500 dark:focus:text-white"
          >
            <i className="fa fa-box-archive mr-1"></i> Archive
          </button>
        </div>{' '}
      </div>
    </div>
  )
}

export default withAllTheProviders(withAccountProvider(AccountContextMenu))
