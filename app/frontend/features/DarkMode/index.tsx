import React, { useEffect, useCallback, useState } from 'react';
import LightModeIcon from './svgs/LightModeIcon';
import DarkModeIcon from './svgs/DarkModeIcon';

type THEME = 'dark' | 'light';

const ThemeLabel: Record<THEME, string> = {
  dark: 'Light Mode',
  light: 'Dark Mode',
};

const getCurrentScheme = (): THEME => {
  const savedTheme = localStorage.getItem('color-theme');
  const prefersDarkScheme = window.matchMedia('(prefers-color-scheme: dark)');
  console.debug({ prefersDarkScheme: prefersDarkScheme.matches, savedTheme });
  // If the user has set a color scheme in localStorage, use that
  if (savedTheme) return savedTheme as THEME;
  // If the user has not set a color scheme, use the system preference
  if (prefersDarkScheme.matches) return 'dark';
  console.warn('No saved or preferred theme, using light');
  return 'light';
};

const DarkModeApp = () => {
  const [currentScheme, setCurrentScheme] = useState<THEME>(getCurrentScheme());

  const toggleTheme = useCallback(() => {
    const newScheme: THEME = getCurrentScheme() === 'dark' ? 'light' : 'dark';
    localStorage.setItem('color-theme', newScheme);
    console.debug(`New color scheme: ${newScheme}`);
    setCurrentScheme(newScheme);
  }, []);

  useEffect(() => {
    document.documentElement.classList.toggle('dark', currentScheme === 'dark');
  }, [currentScheme]);

  return (
    <div className="min-w-[200px] flex justify-between content-center text-sm px-4 py-3 dark:text-white">
      <label className="content-center">{ThemeLabel[currentScheme]}</label>
      <button
        type="button"
        onClick={toggleTheme}
        className="theme-toggle px-3 py-2 text-gray-900 bg-white border border-gray-300 focus:outline-none hover:bg-gray-100 focus:ring-2 focus:ring-gray-100 font-medium rounded-lg dark:bg-gray-800 dark:text-white dark:border-gray-600 dark:hover:bg-gray-700 dark:hover:border-gray-600 dark:focus:ring-gray-700"
      >
        {currentScheme === 'dark' ? <DarkModeIcon /> : <LightModeIcon />}
      </button>
    </div>
  );
};

export default DarkModeApp;
