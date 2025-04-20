/** @type {import('tailwindcss').Config} */

/* eslint-disable no-undef */
/* eslint-disable @typescript-eslint/no-require-imports */

const defaultTheme = require("tailwindcss/defaultTheme");

export const content = [
  "./public/*.html",
  "./node_modules/flowbite/**/*.js",
  "./app/helpers/**/*.rb",
  "./app/views/**/*.{html,html.erb,erb}",
  "./app/views/devise/**/*.{html,html.erb,erb}",
  "./config/locales/ctas/*.rb",
  "./config/locales/defaults/*.rb",
  "./config/locales/devise.*.{yml,yaml}",
];

export const theme = {
  extend: {
    fontFamily: {
      // eslint-disable-next-line @typescript-eslint/no-unsafe-assignment,@typescript-eslint/no-unsafe-member-access
      sans: ["Inter var", ...defaultTheme.fontFamily.sans],
    },
  },
};

export const plugins = [
  require("flowbite/plugin"),
  require("@tailwindcss/forms"),
  require("@tailwindcss/aspect-ratio"),
  // require("flowbite-typography"),
  require("@tailwindcss/typography"),
  require("@tailwindcss/container-queries"),
];

export default {
  content,
  theme,
  plugins,
};
