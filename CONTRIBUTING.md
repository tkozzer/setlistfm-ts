# Contributing to `setlistfm-ts`

Welcome! 👋 Thank you for considering contributing to **setlistfm-ts**, a modern TypeScript client for the [setlist.fm](https://www.setlist.fm/) API.

This document provides guidelines and best practices to help you contribute effectively and make the process smooth for everyone involved.

---

## 🚀 Getting Started

1. **Fork the repository**

2. **Clone your fork**

   ```bash
   git clone https://github.com/tkozzer/setlistfm-ts.git
   cd setlistfm-ts
   ```

3. **Install dependencies**

   ```bash
   pnpm install
   ```

4. **Run the type checker**

   ```bash
   pnpm type-check
   ```

5. **Run tests**

   ```bash
   pnpm test
   ```

---

## 🔄 Development Workflow

We use a **three-branch strategy** with automated release preparation:

### Branch Structure

```
main ← preview ← your-feature-branch
 ↑         ↑            ↑
 │         │            └── Your development work
 │         └────────────── Automated release preparation
 └──────────────────────── Production releases
```

- **`main`** - Production-ready releases only
- **`preview`** - Release staging and preparation
- **Development branches** - Feature work (any naming convention)

### Development Process

1. **Create a feature branch** from `main` (any descriptive name):

   ```bash
   git checkout main
   git pull origin main
   git checkout -b feat/new-feature
   # or fix/bug-description, chore/task-name, etc.
   ```

2. **Make your changes** with proper documentation and tests

3. **Create a PR** from your branch → `preview`

   - Our CI will validate your changes
   - AI will enhance your PR description automatically
   - Request review if needed

4. **Manual merge to `preview`** (after CI passes and review approval)

   - This triggers our automated release preparation workflow
   - Version bump and changelog generation happen automatically

5. **Automated PR creation** `preview` → `main`

   - An automated PR is created with AI-generated description
   - Contains the changelog and version bump

6. **Manual release** (maintainer reviews and merges the auto-generated PR)
   - Final quality check before production release
   - Maintains human oversight of releases

### Automated Workflows

Our GitHub Actions handle:

- **PR Enhancement** - AI-powered description improvements for PRs to `preview` (`.github/workflows/pr-enhance.yml`)
- **Release Preparation** - Automatic version bumping and changelog generation using OpenAI (`.github/workflows/release-prepare.yml`)
- **PR Creation** - Automated PRs from `preview` to `main` with professional descriptions (`.github/workflows/release-pr.yml`)
- **CI Validation** - Linting, type-checking, and testing on all PRs (`.github/workflows/ci.yml`)
- **Local CI Testing** - Act-optimized workflow for local testing (`.github/workflows/ci-local.yml`)

---

## 🧠 Guidelines

### Code Style

- Use **TypeScript** best practices.

- Follow the existing **project structure** and naming conventions.

- Format with Prettier and lint with ESLint:

  ```bash
  pnpm lint
  ```

- Prefer functional, composable utilities when possible.

### Commit Messages

Use [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) to keep history clean and enable automated changelog generation.

Our release automation understands these patterns:

- **Breaking changes**: `feat!:` or `BREAKING CHANGE:` in commit body
- **New features**: `feat:`
- **Bug fixes**: `fix:`
- **Documentation**: `docs:`
- **Chores**: `chore:`

Examples:

- `fix(api): correct pagination metadata`
- `feat(artist): add support for getArtistSetlists`
- `feat!: change API response format` (breaking change)
- `chore(deps): update dev dependencies`

**Important**: The automated changelog generation reads your commit messages, so write them clearly and descriptively!

### Branch Naming

Use short, descriptive branch names - any convention works:

```bash
# All of these are fine:
git checkout -b feat/get-user-events
git checkout -b fix-pagination-bug
git checkout -b update-docs
git checkout -b tkozzer/new-feature
```

The key is making it clear what the branch does.

---

## 🧪 Testing

We use **Vitest** for unit testing.

- All new features must include test coverage.
- Place tests alongside source files in `.test.ts` files.

To run the test suite:

```bash
pnpm test
```

To run in watch mode:

```bash
pnpm test:watch
```

To view coverage:

```bash
pnpm test:coverage
```

---

## 📚 Documentation

All code must follow our documentation standards:

> See: [`.cursor/rules/documentation-standards.mdc`](./.cursor/rules/documentation-standards.mdc)

This includes:

- A JSDoc-formatted header at the top of each `.ts` file
- Comments for functions, interfaces, constants, and complex logic
- Clear, present-tense phrasing
- Examples where appropriate

Even if you don't use [Cursor](https://cursor.so), the rule file is readable Markdown and reflects our documentation expectations.

---

## 🤖 Release Process

Our release process is **mostly automated** but maintains human oversight:

### For Contributors

1. **Focus on your feature** - Create PR to `preview`
2. **Wait for CI** - Ensure all checks pass
3. **That's it!** - Maintainers handle the rest

### For Maintainers

1. **Review and merge** development PRs to `preview`
2. **Automated release prep** runs (version bump + changelog)
3. **Review the auto-generated** `preview` → `main` PR
4. **Merge when ready** to publish the release

### What's Automated

- ✅ **PR descriptions** - AI enhances your PR when targeting `preview`
- ✅ **Version bumping** - Follows semantic versioning based on commits
- ✅ **Changelog generation** - Uses OpenAI to analyze commits
- ✅ **Release PR creation** - Automated PRs from `preview` to `main`
- ✅ **CI validation** - Linting, type-checking, and testing

### What Requires Human Review

- 🧑‍💻 **Development PRs** - Merging your feature to `preview`
- 🧑‍💻 **Release approval** - Final review of `preview` → `main` PR
- 🧑‍💻 **Emergency fixes** - Special releases outside normal flow

---

## 🧼 Before Submitting a PR

✅ **Type-check**: `pnpm type-check`
✅ **Lint and fix**: `pnpm lint --fix`
✅ **Run tests**: `pnpm test`
✅ **Update docs** if applicable
✅ **Write clear commit messages** (they become part of the changelog!)
✅ **Squash commits** if needed

---

## 🔧 Local Development Tips

### Environment Setup

Create a `.env` file for local testing:

```bash
# Optional: for testing API endpoints locally
SETLISTFM_API_KEY=your_api_key_here
```

### Build and Verify

```bash
# Build the library
pnpm build

# Verify the build works
pnpm test:build

# Check bundle size
pnpm build:analyze
```

### Testing with Examples

Run the example scripts to test your changes:

```bash
# Test artist endpoints
cd examples/artists
pnpm tsx getArtist.ts

# Test other endpoints
cd examples/setlists
pnpm tsx getSetlist.ts
```

---

## 🛠️ Troubleshooting

### Common Issues

**CI failing on type errors:**

```bash
pnpm type-check
# Fix any TypeScript issues
```

**Linting errors:**

```bash
pnpm lint --fix
# Review and commit the fixes
```

**Tests failing:**

```bash
pnpm test:watch
# Debug in watch mode
```

**Build verification failing:**

```bash
pnpm build:verify
# Ensure the built package works correctly
```

---

## 🗣️ Questions or Feedback?

- **Bug reports**: [Create an issue](https://github.com/tkozzer/setlistfm-ts/issues)
- **Feature requests**: [Start a discussion](https://github.com/tkozzer/setlistfm-ts/discussions)
- **Questions**: [Ask in discussions](https://github.com/tkozzer/setlistfm-ts/discussions)

We'd love to hear from you!

Thanks again for contributing! 🎸
