# 📦 Build Optimization Guide

This document outlines the comprehensive build optimization setup for `setlistfm-ts`, including minification, multiple output formats, and bundle size analysis.

## 🎯 Build System Overview

The library now uses **Rollup** with **Terser** for advanced minification and multiple output formats, replacing the basic TypeScript compiler for production builds.

### Build Targets

| Format           | File                    | Size     | Use Case                           |
| ---------------- | ----------------------- | -------- | ---------------------------------- |
| **ES Modules**   | `dist/index.js`         | **19KB** | Modern bundlers (Vite, Webpack 5+) |
| **CommonJS**     | `dist/index.cjs`        | **20KB** | Node.js, older bundlers            |
| **UMD**          | `dist/index.umd.js`     | **80KB** | Browser `<script>` tags            |
| **UMD Minified** | `dist/index.umd.min.js` | **20KB** | Browser production                 |
| **TypeScript**   | `dist/index.d.ts`       | **42KB** | Type definitions                   |

## 🚀 Available Build Scripts

```bash
# Standard builds
pnpm build                 # ES + CJS (development)
pnpm build:minified        # ES + CJS (production, minified)

# UMD builds for browsers
pnpm build:umd             # UMD (development)
pnpm build:umd:minified    # UMD (production, minified)

# Comprehensive builds
pnpm build:all             # All formats (dev + minified + UMD)
pnpm build:analyze         # Minified build + size analysis

# Legacy TypeScript build (has module resolution issues)
pnpm build:tsc             # Direct TypeScript compilation
```

## ⚙️ Optimization Features

### 🔧 Terser Minification Settings

The production builds use advanced Terser configuration for optimal compression:

```javascript
{
  compress: {
    drop_console: false,      // Keep console for error logging
    drop_debugger: true,      // Remove debugger statements
    pure_funcs: ["console.debug"], // Remove debug logs only
    passes: 2,                // Multiple compression passes
    dead_code: true,          // Remove unreachable code
    unused: true,             // Remove unused variables
    // Safe compression settings for API compatibility
  },
  mangle: {
    properties: false,        // Don't mangle property names
    keep_fnames: true,        // Keep function names for debugging
  },
  format: {
    comments: false,          // Remove comments
    semicolons: false,        // Use ASI when possible
  }
}
```

### 📦 Bundle Configuration

- **Tree-shaking enabled**: Unused code is automatically removed
- **External dependencies**: `axios` and `zod` are marked as external (not bundled)
- **Source maps**: Generated for development builds, excluded from production
- **TypeScript declarations**: Generated separately for optimal performance

## 📊 Size Comparison

### Before Optimization (TypeScript only)

- Single output format (ES modules)
- No minification
- Larger bundle size
- No browser compatibility

### After Optimization (Rollup + Terser)

- **75% size reduction** for production builds
- Multiple output formats for different environments
- Advanced minification with safety guarantees
- Browser-ready UMD builds

## 🌐 Browser Usage

### ES Modules (Modern)

```html
<script type="module">
  import { createSetlistFMClient } from "./dist/index.js";
  // Your code here
</script>
```

### UMD (Universal)

```html
<script src="https://unpkg.com/axios/dist/axios.min.js"></script>
<script src="https://unpkg.com/zod/lib/index.umd.js"></script>
<script src="./dist/index.umd.min.js"></script>
<script>
  const client = SetlistFM.createSetlistFMClient({
    apiKey: "your-api-key",
    userAgent: "your-app",
  });
</script>
```

## 🔍 Bundle Analysis

Run `pnpm build:analyze` to get detailed size information:

```bash
📊 Bundle Size Analysis:
-rw-r--r--@ 1 user staff    19K dist/index.js      # ES Modules (minified)
-rw-r--r--@ 1 user staff    20K dist/index.cjs     # CommonJS (minified)
-rw-r--r--@ 1 user staff    20K dist/index.umd.min.js # UMD (minified)
```

## 🎛️ Configuration Files

### `rollup.config.ts`

- Main build configuration
- Handles multiple output formats
- Conditional minification based on environment
- TypeScript compilation with path resolution

### `tsconfig.rollup.json`

- Rollup-specific TypeScript configuration
- Optimized for bundling (ESNext modules)
- Resolves module resolution conflicts

### `package.json` Updates

- New build scripts for different targets
- Updated exports for proper module resolution
- Added `"type": "module"` for ES module support

## 🚀 Performance Benefits

1. **Smaller Bundle Size**: 19-20KB minified (down from ~30KB+)
2. **Better Tree Shaking**: Unused code automatically removed
3. **Multiple Formats**: Optimal format for each environment
4. **Browser Ready**: UMD builds work directly in browsers
5. **Development Experience**: Source maps for debugging
6. **Type Safety**: Comprehensive TypeScript definitions

## 🔧 Customization

To modify minification settings, edit the Terser configuration in `rollup.config.js`:

```javascript
// For even more aggressive minification (use with caution):
compress: {
  passes: 3,                // More compression passes
  drop_console: true,       // Remove all console statements
  pure_funcs: ["console.*"] // Remove all console methods
}
```

## 📈 Future Enhancements

Potential additional optimizations:

1. **Brotli Compression**: Pre-compressed files for CDN delivery
2. **Code Splitting**: Separate chunks for different endpoint groups
3. **Bundle Analyzer**: Visual bundle composition analysis
4. **Performance Budgets**: Automated size limit enforcement
5. **CDN Optimization**: Optimized builds for popular CDNs

---

This build system provides a production-ready, optimized distribution of the setlistfm-ts library with excellent performance characteristics and broad compatibility.
