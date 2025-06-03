/// <reference types="vitest" />

import path from "node:path";
import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    globals: true,
    environment: "node",
    include: ["src/**/*.test.ts"],
    exclude: ["node_modules", "dist", "coverage", "scripts"],
    coverage: {
      provider: "v8",
      reportsDirectory: "./coverage",
      reporter: ["text", "html", "lcov"],
      exclude: [
        "**/*.test.ts",
        "**/__test__/**",
        "**/__tests__/**",
        "**/types.ts",
        "**/*.types.ts",
        "examples/**/*",
        "**/node_modules/**",
        "**/dist/**",
        "**/coverage/**",
        "vitest.config.ts",
        "eslint.config.ts",
      ],
    },
    watch: false,
    logHeapUsage: true,
  },
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"),
      "@shared": path.resolve(__dirname, "./src/shared"),
      "@utils": path.resolve(__dirname, "./src/utils"),
      "@endpoints": path.resolve(__dirname, "./src/endpoints"),
    },
  },
  esbuild: {
    target: "esnext",
  },
});
