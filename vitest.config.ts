import { defineConfig } from "vitest/config";
import path from "path";
import { fileURLToPath } from "url";

import { tsConfigFile, compilerOptions } from "./app/frontend/utils/tsConfig";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const { paths } = compilerOptions;

console.debug(`Paths detected in TSConfig file: ${tsConfigFile}`, { paths });

export default defineConfig({
  test: {
    environment: "jsdom", // or 'node'
    // TODO: review the eslint plugin https://github.com/saqqdy/eslint-plugin-vitest-globals#readme
    globals: true,
    // https://vitest.dev/config/#coverage
    coverage: {
      include: ["app/frontend/**/*"],
    },
  },
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./app/frontend"),
      "@/components": path.resolve(__dirname, "./app/frontend/components"),
      "@/features": path.resolve(__dirname, "./app/frontend/features"),
      "@/hooks": path.resolve(__dirname, "./app/frontend/hooks"),
      "@/pages": path.resolve(__dirname, "./app/frontend/pages"),
    },
  },
});
