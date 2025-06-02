// Run this command to generate base config:
// pnpm dlx @antfu/eslint-config@latest

import antfu from "@antfu/eslint-config";

export default antfu({
  type: "library", // Use 'library' for SDK/client packages
  typescript: true,
  formatters: true,
  stylistic: {
    indent: 2,
    semi: true,
    quotes: "double",
  },
  ignores: [
    "dist/**",
    "coverage/**",
    "node_modules/**",
    ".git/**",
    ".vscode/**",
    "*.env",
    ".env*",
  ],
}, {
  rules: {
    "ts/no-redeclare": "off",
    "ts/consistent-type-definitions": ["error", "type"],
    "no-console": ["warn"],
    "antfu/no-top-level-await": ["off"],
    "node/prefer-global/process": ["off"],
    "node/no-process-env": ["error"],
    "vitest/prefer-lowercase-title": "off",
    "perfectionist/sort-imports": ["error", {
      tsconfigRootDir: ".",
    }],
    "unicorn/filename-case": ["error", {
      case: "camelCase",
      ignore: ["README.md", "CONTRIBUTING.md", "CHANGELOG.md"],
    }],
    // JSDoc rules - Make them TypeScript-friendly
    "jsdoc/check-param-names": ["warn", {
      checkDestructured: false,
    }],
    "jsdoc/require-param": ["warn", {
      checkDestructured: false,
    }],
  },
});
