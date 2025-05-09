import React from 'react';
import LightModeIcon from './svgs/LightModeIcon';
import DarkModeIcon from './svgs/DarkModeIcon';

const DarkModeApp = () => {
  const [darkMode, setDarkMode] = React.useState(false);

  return (
    <div className="min-w-[200px] flex justify-between content-center text-sm px-4 py-3 dark:text-white">
      <label className="content-center">Light Mode</label>
      <button
        type="button"
        onClick={() => setDarkMode(!darkMode)}
        className="theme-toggle px-3 py-2 text-gray-900 bg-white border border-gray-300 focus:outline-none hover:bg-gray-100 focus:ring-2 focus:ring-gray-100 font-medium rounded-lg dark:bg-gray-800 dark:text-white dark:border-gray-600 dark:hover:bg-gray-700 dark:hover:border-gray-600 dark:focus:ring-gray-700"
      >
        {darkMode ? <LightModeIcon /> : <DarkModeIcon />}
      </button>
    </div>
  );
};

export default DarkModeApp;
