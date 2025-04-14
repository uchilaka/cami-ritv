import { defineConfig } from "vite";
import RailsPlugin from "vite-plugin-rails";
import ReactPlugin from "@vitejs/plugin-react";
import tailwindcss from "@tailwindcss/vite";
import { viteAliasConfigFromFactory } from "./app/frontend/utils/aliasFactory";

export default defineConfig({
  plugins: [
    RailsPlugin({
      fullReload: {
        additionalPaths: ["app/frontend/**/*"],
        delay: 250,
      },
    }),
    ReactPlugin(),
    tailwindcss(),
  ],
  resolve: {
    alias: viteAliasConfigFromFactory(),
  },
});
