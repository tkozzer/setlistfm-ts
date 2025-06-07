// Run this command to generate base config:
// pnpm dlx @antfu/eslint-config@latest

import antfu from "@antfu/eslint-config";

const config = antfu(
  {
    type: "lib", // Use 'library' for SDK/client packages
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
      "pnpm-lock.yaml",
      ".git/**",
      ".vscode/**",
      "*.env",
      ".env*",
      "docs/**",
      "README.md",
    ],
  },
  {
    rules: {
      "ts/no-redeclare": "off",
      "ts/consistent-type-definitions": ["error", "type"],
      "no-console": ["warn"],
      "antfu/no-top-level-await": "off",
      "node/prefer-global/process": "off",
      "node/no-process-env": ["error"],
      "vitest/prefer-lowercase-title": "off",
      "unicorn/filename-case": [
        "error",
        {
          case: "camelCase",
          ignore: ["README.md", "CONTRIBUTING.md", "CHANGELOG.md", "AGENTS.md", /.*\.ya?ml$/, /.*\.user\.md$/, /.*\.sys\.md$/, /.*\.tmpl\.md$/, /.*\.json$/],
        },
      ],
      "jsdoc/check-param-names": [
        "warn",
        {
          checkDestructured: false,
        },
      ],
      "jsdoc/require-param": [
        "warn",
        {
          checkDestructured: false,
        },
      ],
    },
  },
  {
    files: ["docs/**/*"],
    rules: {
      "unicorn/filename-case": "off",
    },
  },
  {
    files: ["examples/**/*"],
    rules: {
      "no-console": "off", // Allow console.log in examples
      "node/no-process-env": "off", // Allow process.env in examples
      "jsdoc/require-jsdoc": "off", // Don't require JSDoc in examples
      "jsdoc/require-param": "off", // Don't require JSDoc params in examples
      "jsdoc/require-returns": "off", // Don't require JSDoc returns in examples
    },
  },
  {
    files: ["**/*.md", "**/*.md/*.ts", "README.md"],
    rules: {
      "no-console": "off", // Allow console.log in markdown examples
      "node/no-process-env": "off",
    },
  },
  {
    files: ["rollup.config.ts", "rollup.config.js", "vitest.config.ts"],
    rules: {
      "node/no-process-env": "off", // Allow process.env in build configs
    },
  },
);

export default config;
