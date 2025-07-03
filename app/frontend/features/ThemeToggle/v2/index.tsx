import React from 'react';
import { useThemeMode } from 'flowbite-react';
import ControlWrapper from '../ControlWrapper';
import ToggleButton from '../ToggleButton';
import DarkModeIcon from '../svgs/DarkModeIcon';
import LightModeIcon from '../svgs/LightModeIcon';

const ThemeToggle = () => {
  const { computedMode, toggleMode } = useThemeMode();
  console.debug({ computedMode });
  return (
    <ControlWrapper>
      <ToggleButton onClick={toggleMode}>
        {computedMode === 'dark' ? <DarkModeIcon /> : <LightModeIcon />}
      </ToggleButton>
    </ControlWrapper>
  );
};

export default ThemeToggle;
