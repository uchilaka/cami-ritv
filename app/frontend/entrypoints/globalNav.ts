console.debug('<<< globalNav.ts entrypoint loaded! >>>');

// Light or dark?
const getCurrentScheme = () => {
  const setColorScheme = localStorage.getItem('color-theme');
  const prefersDarkScheme = window.matchMedia('(prefers-color-scheme: dark)');
  // If the user has set a color scheme in localStorage, use that
  if (setColorScheme) return setColorScheme;
  // If the user has not set a color scheme, use the system preference
  if (prefersDarkScheme.matches) return 'dark';
  return 'light';
};

const applyColorScheme = () => {
  if (getCurrentScheme() == 'dark') {
    console.debug('<<< dark mode >>>');
    document.documentElement.classList.add('dark');
  } else {
    console.debug('<<< light mode >>>');
    document.documentElement.classList.remove('dark');
  }
};

document.addEventListener('turbo:load', () => {
  console.debug('<<< globalNav.ts (turbo:load) event >>>');

  // Set up theme toggle button(s)
  const themeToggles =
    document.querySelectorAll<HTMLButtonElement>('.theme-toggle');
  themeToggles.forEach(toggle => {
    toggle.addEventListener('click', () => {
      const currentScheme = getCurrentScheme();
      const newScheme = currentScheme === 'dark' ? 'light' : 'dark';
      localStorage.setItem('color-theme', newScheme);
      applyColorScheme();
    });
  });

  applyColorScheme();
});
