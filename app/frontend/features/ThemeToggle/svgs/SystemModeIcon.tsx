import React from 'react';

const SystemModeIcon = () => {
  return (
    <svg
      className="w-[18px] h-[18px] text-gray-800 dark:text-white"
      aria-hidden="true"
      xmlns="http://www.w3.org/2000/svg"
      width="24"
      height="24"
      fill="none"
      viewBox="0 0 24 24"
    >
      <path
        stroke="currentColor"
        strokeLinecap="round"
        strokeLinejoin="round"
        strokeWidth="2"
        d="M9 16H5a1 1 0 0 1-1-1V5a1 1 0 0 1 1-1h14a1 1 0 0 1 1 1v10a1 1 0 0 1-1 1h-4m-6 0v4m0-4h6m-6 4h6m0-4v4m-8 0h10"
      />
    </svg>
  );
};

export default SystemModeIcon;
