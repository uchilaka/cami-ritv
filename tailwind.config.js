// Import rails tailwind config
import { content, theme, plugins } from "./config/tailwind.config";

export default {
  content: [
    ...content,
    "./app/frontend/components/**/*.{vue,js,ts,jsx,tsx}",
    "./app/frontend/**/*.{vue,js,ts,jsx,tsx}",
    "./app/**/*.{js,ts,jsx,tsx}",
  ],
  theme,
  plugins,
};
