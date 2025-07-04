import React, { FC, HTMLAttributes } from 'react';
import clsx from 'clsx';

const ToggleButton: FC<HTMLAttributes<HTMLButtonElement>> = ({
  className,
  ...props
}) => {
  return (
    <button
      type="button"
      className={clsx(
        'theme-toggle px-3 py-2 text-gray-900 bg-white border border-gray-300 focus:outline-none hover:bg-gray-100 focus:ring-2 focus:ring-gray-100 font-medium rounded-lg dark:bg-gray-800 dark:text-white dark:border-gray-600 dark:hover:bg-gray-700 dark:hover:border-gray-600 dark:focus:ring-gray-700',
        className
      )}
      {...props}
    ></button>
  );
};

export default ToggleButton;
