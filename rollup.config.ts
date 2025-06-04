import type { OutputOptions, RollupOptions } from "rollup";
import commonjs from "@rollup/plugin-commonjs";
import resolve from "@rollup/plugin-node-resolve";
import terser from "@rollup/plugin-terser";
import typescript from "@rollup/plugin-typescript";
import dts from "rollup-plugin-dts";

const isProduction = process.env.NODE_ENV === "production";

const buildFormat = process.env.BUILD_FORMAT;

const basePlugins = [
  resolve(),
  commonjs(),
  typescript({
    tsconfig: "./tsconfig.rollup.json",
    declaration: false, // We'll generate .d.ts separately
    declarationMap: false,
    sourceMap: !isProduction,
  }),
];

const baseConfig: Partial<RollupOptions> = {
  input: "src/index.ts",
  external: ["axios", "zod"], // Don't bundle dependencies
  plugins: basePlugins,
};

// Determine output configuration based on build format
function getOutputConfig(): OutputOptions[] {
  if (buildFormat === "umd") {
    return [
      {
        file: isProduction ? "dist/index.umd.min.js" : "dist/index.umd.js",
        format: "umd",
        name: "SetlistFM",
        sourcemap: !isProduction,
        globals: {
          axios: "axios",
          zod: "Zod",
        },
      },
    ];
  }

  return [
    {
      file: "dist/index.js",
      format: "es",
      sourcemap: !isProduction,
    },
    // Also create a CommonJS build for better compatibility
    {
      file: "dist/index.cjs",
      format: "cjs",
      sourcemap: !isProduction,
    },
  ];
}

const builds: RollupOptions[] = [
  // Main build (ES/CJS or UMD)
  {
    ...baseConfig,
    output: getOutputConfig(),
    plugins: [
      ...basePlugins,
      // Apply minification only in production
      ...(isProduction
        ? [terser({
            compress: {
              drop_console: false, // Keep console for error logging
              drop_debugger: true,
              pure_funcs: ["console.debug"], // Remove debug logs only
              passes: 2, // Multiple passes for better compression
              unsafe: false, // Keep safe for API compatibility
              unsafe_comps: false,
              unsafe_Function: false,
              unsafe_math: false,
              unsafe_symbols: false,
              unsafe_methods: false,
              unsafe_proto: false,
              unsafe_regexp: false,
              unsafe_undefined: false,
              dead_code: true,
              unused: true, // Remove unused code
            },
            mangle: {
              properties: false, // Don't mangle property names for API compatibility
              keep_fnames: true, // Keep function names for debugging
            },
            format: {
              comments: false, // Remove comments
              semicolons: false, // Use ASI when possible
            },
          })]
        : []),
    ],
  },
];

// Only generate TypeScript declarations for ES/CJS builds, not UMD
if (buildFormat !== "umd") {
  builds.push({
    input: "src/index.ts",
    output: {
      file: "dist/index.d.ts",
      format: "es",
    },
    plugins: [dts()],
  });
}

export default builds;
