/** @type {import('tailwindcss').Config} */

// Demo Emerald theme, customized @ https://www.subframe.com/library/theme
import emeraldTheme from '../app/frontend/utils/emeraldTheme';

/* eslint-disable no-undef */
/* eslint-disable @typescript-eslint/no-require-imports */

// const defaultTheme = require('tailwindcss/defaultTheme');

export const content = [
  './public/*.html',
  './node_modules/flowbite/**/*.js',
  './app/helpers/**/*.rb',
  './app/views/**/*.{html,html.erb,erb}',
  './app/views/devise/**/*.{html,html.erb,erb}',
  './config/locales/ctas/*.rb',
  './config/locales/defaults/*.rb',
  './config/locales/devise.*.{yml,yaml}',
];

// export const theme = {
//   extend: {
//     fontFamily: {
//       // eslint-disable-next-line @typescript-eslint/no-unsafe-assignment,@typescript-eslint/no-unsafe-member-access
//       sans: ['Inter var', ...defaultTheme.fontFamily.sans],
//     },
//   },
// };

export const plugins = [
  require('flowbite/plugin'),
  require('@tailwindcss/forms'),
  require('@tailwindcss/aspect-ratio'),
  require('flowbite-typography'),
  require('@tailwindcss/container-queries'),
];

// darkMode is a top-level option, not a theme key. Nested under `theme` it is
// silently ignored and Tailwind falls back to 'media', which makes every dark:
// utility follow the OS and ignore the .dark class the theme control sets.
// Exported so the Vite build (../tailwind.config.js) uses the same strategy.
export const darkMode = 'selector';

export default {
  content,
  darkMode,
  theme: {
    extend: {
      ...emeraldTheme,
    },
  },
  plugins,
};
