/** @type {import('tailwindcss').Config} */

// // eslint-disable-next-line @typescript-eslint/no-require-imports, @typescript-eslint/no-unsafe-assignment
// const defaultTheme = require("tailwindcss/defaultTheme");

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
    // fontFamily: {
    //   // eslint-disable-next-line @typescript-eslint/no-unsafe-assignment,@typescript-eslint/no-unsafe-member-access
    //   sans: ["Inter var", ...defaultTheme.fontFamily.sans],
    // },
  },
};

export const plugins = [
  import("flowbite/plugin"),
  import("@tailwindcss/forms"),
  import("@tailwindcss/aspect-ratio"),
  import("flowbite-typography"),
  // import("@tailwindcss/typography"),
  import("@tailwindcss/container-queries"),
];

export default {
  content,
  theme,
  plugins,
};
