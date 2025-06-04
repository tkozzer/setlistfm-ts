# 📦 NPM Publishing Guide

This guide covers the complete workflow for publishing `setlistfm-ts` to npm with the optimized build system and verification processes.

## 🔄 Publishing Workflow Overview

The new build system includes automated safeguards to ensure only properly built and tested packages are published:

```bash
# 1. Development & Testing
pnpm check                  # Type-check, lint, and test source code
pnpm build:verify           # Build and verify artifacts

# 2. Publishing (automatic verification)
pnpm publish               # Triggers prepack & prepublishOnly hooks
```

## 🛡️ Automated Safeguards

### Pre-Pack Hook (`prepack`)

Runs automatically before creating the npm package:

```bash
pnpm build:verify          # Builds minified version + runs build tests
```

### Pre-Publish Hook (`prepublishOnly`)

Runs automatically before publishing to npm:

```bash
pnpm check                 # Full source code verification
pnpm build:verify          # Build artifacts verification
```

## 📋 Step-by-Step Publishing Process

### 1. Pre-Publishing Checklist

```bash
# Ensure clean working directory
git status

# Update version in package.json (if needed)
npm version patch|minor|major

# Verify all tests pass
pnpm test

# Verify build system works
pnpm build:all

# Run complete verification
pnpm check && pnpm build:verify
```

### 2. What Gets Published

The `files` field in `package.json` specifies what's included:

```json
"files": [
  "LICENSE",
  "README.md",
  "dist"
]
```

This includes:

- **`dist/index.js`** - ES Modules (19KB minified)
- **`dist/index.cjs`** - CommonJS (20KB minified)
- **`dist/index.d.ts`** - TypeScript definitions (42KB)
- **`dist/index.*.map`** - Source maps for debugging
- **Optional UMD builds** (if present from `pnpm build:all`)

### 3. Package.json Configuration

The optimized `package.json` ensures proper module resolution:

```json
{
  "type": "module",
  "main": "./dist/index.cjs", // CommonJS entry
  "module": "./dist/index.js", // ES Modules entry
  "types": "./dist/index.d.ts", // TypeScript definitions
  "exports": {
    ".": {
      "types": "./dist/index.d.ts",
      "import": "./dist/index.js",
      "require": "./dist/index.cjs"
    }
  }
}
```

### 4. Publishing Commands

```bash
# Standard publishing (recommended)
pnpm publish

# Dry run (see what would be published)
pnpm publish --dry-run

# Publish with specific tag
pnpm publish --tag beta

# Publish to specific registry
pnpm publish --registry https://registry.npmjs.org/
```

## 🧪 Post-Build Verification

The build verification tests ensure:

### ✅ File Existence

- All required build artifacts are present
- Optional UMD builds (when applicable)

### ✅ Module Format Validation

- ES modules use proper `export` syntax
- CommonJS uses proper `exports.*` syntax
- TypeScript definitions are valid

### ✅ Bundle Size Compliance

- ES modules: < 25KB
- CommonJS: < 25KB
- Automatic size regression detection

### ✅ Runtime Import Testing

- ES modules can be imported with `import`
- CommonJS can be required with `require()`
- All APIs are accessible and functional

### ✅ API Surface Verification

- Core client factory function works
- All endpoint methods are available on client instances
- Type definitions are parseable by TypeScript

## 🚀 Consumer Usage After Publishing

### Node.js ES Modules

```typescript
import { createSetlistFMClient } from "setlistfm-ts";

const client = createSetlistFMClient({
  apiKey: "your-api-key",
  userAgent: "your-app (your-email@example.com)"
});
```

### Node.js CommonJS

```javascript
const { createSetlistFMClient } = require("setlistfm-ts");

const client = createSetlistFMClient({
  apiKey: "your-api-key",
  userAgent: "your-app (your-email@example.com)"
});
```

### Browser ES Modules

```html
<script type="module">
  import { createSetlistFMClient } from "https://unpkg.com/setlistfm-ts/dist/index.js";

  const client = createSetlistFMClient({
    apiKey: "your-api-key",
    userAgent: "your-app",
  });
</script>
```

### Browser UMD (Universal)

```html
<script src="https://unpkg.com/axios/dist/axios.min.js"></script>
<script src="https://unpkg.com/zod/lib/index.umd.js"></script>
<script src="https://unpkg.com/setlistfm-ts/dist/index.umd.min.js"></script>
<script>
  const client = SetlistFM.createSetlistFMClient({
    apiKey: "your-api-key",
    userAgent: "your-app",
  });
</script>
```

## 🔍 Troubleshooting

### Build Verification Failures

If `pnpm build:verify` fails:

1. **Missing Build Artifacts**: Run `pnpm build:minified` manually
2. **Bundle Size Issues**: Check if new dependencies were added
3. **Import/Export Issues**: Verify TypeScript configuration
4. **API Surface Changes**: Update build verification tests

### Publishing Issues

1. **Authentication**: Ensure you're logged in with `npm login`
2. **Permissions**: Verify package ownership with `npm owner ls setlistfm-ts`
3. **Version Conflicts**: Use `npm version` to bump version properly
4. **Registry Issues**: Specify registry with `--registry` flag

### Size Regression

If bundle sizes exceed targets:

```bash
# Analyze bundle composition
pnpm build:analyze

# Check for new dependencies
npm ls --depth=0

# Review import statements for tree-shaking issues
```

## 📊 Metrics & Monitoring

### Bundle Size Tracking

```bash
# Current sizes after build
📊 Bundle Size Analysis:
-rw-r--r--@ 1 user staff    19K dist/index.js      # ES Modules (minified)
-rw-r--r--@ 1 user staff    20K dist/index.cjs     # CommonJS (minified)
-rw-r--r--@ 1 user staff    20K dist/index.umd.min.js # UMD (minified)
```

### CI/CD Integration

Add to GitHub Actions:

```yaml
- name: Verify Build
  run: pnpm build:verify

- name: Check Bundle Size
  run: pnpm build:analyze
```

## 🔄 Version Management

### Semantic Versioning

- **Patch** (0.1.x): Bug fixes, internal improvements
- **Minor** (0.x.0): New features, backwards compatible
- **Major** (x.0.0): Breaking changes

### Release Process

```bash
# Bug fix
npm version patch        # 0.1.8 → 0.1.9
pnpm publish

# New feature
npm version minor        # 0.1.8 → 0.2.0
pnpm publish

# Breaking change
npm version major        # 0.1.8 → 1.0.0
pnpm publish
```

---

This publishing workflow ensures that every published version is:

- ✅ Properly built and minified
- ✅ Functionally tested across module formats
- ✅ Size-optimized and regression-free
- ✅ Compatible with all target environments
