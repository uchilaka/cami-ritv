const defaultTheme = require('tailwindcss/defaultTheme')

export const content = [
  './public/*.html',
  './app/helpers/**/*.rb',
  './app/frontend/**/*.js',
  './app/views/**/*.{erb,haml,html,slim}'
]

export const theme = {
  extend: {
    fontFamily: {
      sans: ['Inter var', ...defaultTheme.fontFamily.sans],
    },
  },
}

export const plugins = [
  require('@tailwindcss/forms'),
  require('@tailwindcss/typography'),
  require('@tailwindcss/container-queries'),
]

export default {
  content,
  theme,
  plugins
}
