import { createElement } from 'react';
import { createRoot } from 'react-dom/client';
import DarkModeApp from '@/features/DarkMode';

const container = document.querySelector<HTMLDivElement>('#user-dropdown');
if (container) {
  const globalNavId = 'global-nav';
  const existingGlobalNav = document.querySelector<HTMLDivElement>(
    `${globalNavId}`
  );
  if (existingGlobalNav) {
    console.debug(`Found existing global nav with id ${globalNavId}`);
    existingGlobalNav.remove();
  }
  const globalNavContainer = document.createElement<'div'>('div');
  globalNavContainer.id = 'global-nav';
  container.prepend(globalNavContainer);
  const root = createRoot(globalNavContainer);
  root.render(createElement(DarkModeApp));
  console.debug('<<< dark_mode_app.tsx entrypoint loaded! >>>');
}
