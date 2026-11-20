import React, { FC, useEffect, useId, useState } from 'react';
import DarkModeIcon from './svgs/DarkModeIcon';
import LightModeIcon from './svgs/LightModeIcon';
import SystemModeIcon from './svgs/SystemModeIcon';
import {
  ThemePreference,
  applyTheme,
  readPreference,
  resolveTheme,
  subscribeToPreference,
  subscribeToSystemTheme,
  systemPrefersDark,
  writePreference,
} from './themePreference';

const OPTIONS: { value: ThemePreference; label: string; Icon: FC }[] = [
  { value: 'light', label: 'Light', Icon: LightModeIcon },
  { value: 'dark', label: 'Dark', Icon: DarkModeIcon },
  { value: 'system', label: 'System', Icon: SystemModeIcon },
];

/**
 * Light / Dark / System picker. Native radios give arrow-key navigation and a
 * screen reader announcement ("Theme, radio group, Dark, selected") for free;
 * the inputs are visually hidden and the icon tiles are their styled labels.
 */
const ThemePreferenceControl = () => {
  // useId keeps the radio group name unique when the control is mounted twice
  // on one page (navbar and account settings).
  const name = useId();
  const [preference, setPreference] = useState<ThemePreference>(readPreference);
  const [prefersDark, setPrefersDark] = useState<boolean>(systemPrefersDark);

  useEffect(() => subscribeToSystemTheme(setPrefersDark), []);
  useEffect(() => subscribeToPreference(setPreference), []);

  useEffect(() => {
    applyTheme(resolveTheme(preference, prefersDark));
  }, [preference, prefersDark]);

  return (
    <div className="min-w-[200px] flex justify-between items-center text-sm px-4 py-3 text-gray-900 dark:text-white">
      <span aria-hidden="true">Theme</span>
      <fieldset className="flex rounded-lg border border-gray-300 dark:border-gray-600 overflow-hidden">
        <legend className="sr-only">Theme</legend>
        {OPTIONS.map(({ value, label, Icon }) => (
          <label key={value} title={label} className="cursor-pointer">
            <input
              type="radio"
              name={name}
              value={value}
              checked={preference === value}
              onChange={() => writePreference(value)}
              className="sr-only peer"
            />
            <span className="flex px-3 py-2 bg-white hover:bg-gray-100 dark:bg-gray-800 dark:hover:bg-gray-700 peer-checked:bg-gray-200 dark:peer-checked:bg-gray-600 peer-focus-visible:ring-2 peer-focus-visible:ring-inset peer-focus-visible:ring-gray-400">
              <Icon />
              <span className="sr-only">{label}</span>
            </span>
          </label>
        ))}
      </fieldset>
    </div>
  );
};

export default ThemePreferenceControl;
