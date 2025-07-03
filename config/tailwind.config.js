/** @type {import('tailwindcss').Config} */

/* eslint-disable no-undef */
/* eslint-disable @typescript-eslint/no-require-imports */

// Demo Emerald theme, customized @ https://www.subframe.com/library/theme
const theme = {
  darkMode: 'selector',
  extend: {
    colors: {
      brand: {
        50: 'rgb(15, 41, 30)',
        100: 'rgb(17, 49, 35)',
        200: 'rgb(19, 57, 41)',
        300: 'rgb(22, 68, 48)',
        400: 'rgb(27, 84, 58)',
        500: 'rgb(35, 110, 74)',
        600: 'rgb(48, 164, 108)',
        700: 'rgb(60, 177, 121)',
        800: 'rgb(76, 195, 138)',
        900: 'rgb(229, 251, 235)',
      },
      neutral: {
        0: 'rgb(10, 10, 10)',
        50: 'rgb(23, 23, 23)',
        100: 'rgb(38, 38, 38)',
        200: 'rgb(64, 64, 64)',
        300: 'rgb(82, 82, 82)',
        400: 'rgb(115, 115, 115)',
        500: 'rgb(163, 163, 163)',
        600: 'rgb(212, 212, 212)',
        700: 'rgb(229, 229, 229)',
        800: 'rgb(245, 245, 245)',
        900: 'rgb(250, 250, 250)',
        950: 'rgb(255, 255, 255)',
      },
      error: {
        50: 'rgb(60, 24, 26)',
        100: 'rgb(72, 26, 29)',
        200: 'rgb(84, 27, 31)',
        300: 'rgb(103, 30, 34)',
        400: 'rgb(130, 32, 37)',
        500: 'rgb(170, 36, 41)',
        600: 'rgb(229, 72, 77)',
        700: 'rgb(242, 85, 90)',
        800: 'rgb(255, 99, 105)',
        900: 'rgb(254, 236, 238)',
      },
      warning: {
        50: 'rgb(44, 33, 0)',
        100: 'rgb(53, 40, 0)',
        200: 'rgb(62, 48, 0)',
        300: 'rgb(73, 60, 0)',
        400: 'rgb(89, 74, 5)',
        500: 'rgb(112, 94, 0)',
        600: 'rgb(245, 217, 10)',
        700: 'rgb(255, 239, 92)',
        800: 'rgb(240, 192, 0)',
        900: 'rgb(255, 250, 209)',
      },
      success: {
        50: 'rgb(19, 40, 25)',
        100: 'rgb(22, 48, 29)',
        200: 'rgb(25, 57, 33)',
        300: 'rgb(29, 68, 39)',
        400: 'rgb(36, 85, 48)',
        500: 'rgb(47, 110, 59)',
        600: 'rgb(70, 167, 88)',
        700: 'rgb(85, 180, 103)',
        800: 'rgb(99, 193, 116)',
        900: 'rgb(229, 251, 235)',
      },
      'brand-primary': 'rgb(47, 110, 59)',
      'default-font': 'rgb(250, 250, 250)',
      'subtext-color': 'rgb(163, 163, 163)',
      'neutral-border': 'rgb(64, 64, 64)',
      black: 'rgb(10, 10, 10)',
      'default-background': 'rgb(10, 10, 10)',
    },
    fontSize: {
      caption: [
        '12px',
        {
          lineHeight: '16px',
          fontWeight: '400',
          letterSpacing: '0em',
        },
      ],
      'caption-bold': [
        '12px',
        {
          lineHeight: '16px',
          fontWeight: '500',
          letterSpacing: '0em',
        },
      ],
      body: [
        '14px',
        {
          lineHeight: '20px',
          fontWeight: '400',
          letterSpacing: '0em',
        },
      ],
      'body-bold': [
        '14px',
        {
          lineHeight: '20px',
          fontWeight: '500',
          letterSpacing: '0em',
        },
      ],
      'heading-3': [
        '16px',
        {
          lineHeight: '20px',
          fontWeight: '500',
          letterSpacing: '0em',
        },
      ],
      'heading-2': [
        '20px',
        {
          lineHeight: '24px',
          fontWeight: '500',
          letterSpacing: '0em',
        },
      ],
      'heading-1': [
        '30px',
        {
          lineHeight: '36px',
          fontWeight: '500',
          letterSpacing: '0em',
        },
      ],
      'monospace-body': [
        '14px',
        {
          lineHeight: '20px',
          fontWeight: '400',
          letterSpacing: '0em',
        },
      ],
    },
    fontFamily: {
      caption: 'Inter',
      'caption-bold': 'Inter',
      body: 'Inter',
      'body-bold': 'Inter',
      'heading-3': 'Inter',
      'heading-2': 'Inter',
      'heading-1': 'Inter',
      'monospace-body': 'monospace',
    },
    boxShadow: {
      sm: '0px 1px 2px 0px rgba(0, 0, 0, 0.05)',
      default: '0px 1px 2px 0px rgba(0, 0, 0, 0.05)',
      md: '0px 4px 16px -2px rgba(0, 0, 0, 0.08), 0px 2px 4px -1px rgba(0, 0, 0, 0.08)',
      lg: '0px 12px 32px -4px rgba(0, 0, 0, 0.08), 0px 4px 8px -2px rgba(0, 0, 0, 0.08)',
      overlay:
        '0px 12px 32px -4px rgba(0, 0, 0, 0.08), 0px 4px 8px -2px rgba(0, 0, 0, 0.08)',
    },
    borderRadius: {
      sm: '2px',
      md: '4px',
      DEFAULT: '4px',
      lg: '8px',
      full: '9999px',
    },
    container: {
      padding: {
        DEFAULT: '16px',
        sm: 'calc((100vw + 16px - 640px) / 2)',
        md: 'calc((100vw + 16px - 768px) / 2)',
        lg: 'calc((100vw + 16px - 1024px) / 2)',
        xl: 'calc((100vw + 16px - 1280px) / 2)',
        '2xl': 'calc((100vw + 16px - 1536px) / 2)',
      },
    },
    spacing: {
      112: '28rem',
      144: '36rem',
      192: '48rem',
      256: '64rem',
      320: '80rem',
    },
    screens: {
      mobile: {
        max: '767px',
      },
    },
  },
};

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

export default {
  content,
  theme,
  plugins,
};
