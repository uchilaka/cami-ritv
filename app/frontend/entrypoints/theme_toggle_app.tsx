import { createElement } from 'react';
import { createRoot } from 'react-dom/client';
import ThemePreferenceControl from '@/features/ThemeToggle/ThemePreferenceControl';
import {
  applyTheme,
  readPreference,
  resolveTheme,
} from '@/features/ThemeToggle/themePreference';

// Apply the stored preference before React mounts. The layout keeps <html>
// hidden until the stylesheet reveals it, so doing this at module load avoids
// a light-to-dark flash without an inline script.
applyTheme(resolveTheme(readPreference()));

const mount = (container: HTMLElement) =>
  createRoot(container).render(createElement(ThemePreferenceControl));

// Profile menu: the control is prepended into the dropdown.
const profileMenu = document.querySelector<HTMLDivElement>('#user-dropdown');
if (profileMenu) {
  const globalNavId = 'global-nav';
  document.getElementById(globalNavId)?.remove();
  const globalNavContainer = document.createElement('div');
  globalNavContainer.id = globalNavId;
  profileMenu.prepend(globalNavContainer);
  mount(globalNavContainer);
}

// Any other page that wants the control (e.g. account settings) marks a slot.
document
  .querySelectorAll<HTMLElement>('[data-theme-preference-control]')
  .forEach(mount);
