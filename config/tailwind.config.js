/** @type {import('tailwindcss').Config} */

// // eslint-disable-next-line @typescript-eslint/no-require-imports, @typescript-eslint/no-unsafe-assignment
// const defaultTheme = require("tailwindcss/defaultTheme");

export const content = [
  "./public/*.html",
  "./node_modules/flowbite/**/*.js",
  "./app/helpers/**/*.rb",
  "./app/views/**/*.{html,html.erb,erb}",
  "./app/views/devise/**/*.{html,html.erb,erb}",
];

export const theme = {
  extend: {
    // fontFamily: {
    //   // eslint-disable-next-line @typescript-eslint/no-unsafe-assignment,@typescript-eslint/no-unsafe-member-access
    //   sans: ["Inter var", ...defaultTheme.fontFamily.sans],
    // },
  },
};

export const plugins = [
  "flowbite/plugin",
  "@tailwindcss/forms",
  "@tailwindcss/aspect-ratio",
  "@tailwindcss/typography",
  "@tailwindcss/container-queries",
];

export default {
  content,
  theme,
  plugins,
};
