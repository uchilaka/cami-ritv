/** @type {import('tailwindcss').Config} */

// eslint-disable-next-line @typescript-eslint/no-require-imports, @typescript-eslint/no-unsafe-assignment
const defaultTheme = require("tailwindcss/defaultTheme");

export default {
  content: [
    "./public/*.html",
    "./node_modules/flowbite/**/*.js",
    "./app/helpers/**/*.rb",
    "./app/views/**/*.{html,html.erb,erb}",
    "./app/views/devise/**/*.{html,html.erb,erb}",
    "./app/frontend/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      fontFamily: {
        // eslint-disable-next-line @typescript-eslint/no-unsafe-assignment,@typescript-eslint/no-unsafe-member-access
        sans: ["Inter var", ...defaultTheme.fontFamily.sans],
      },
    },
  },
  plugins: [
    require("flowbite/plugin"),
    require("@tailwindcss/forms"),
    require("@tailwindcss/aspect-ratio"),
    require("@tailwindcss/typography"),
    require("@tailwindcss/container-queries"),
  ],
};
