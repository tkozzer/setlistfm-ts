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

Use [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) to keep history clean and changelogs automated.

Examples:

- `fix(api): correct pagination metadata`
- `feat(artist): add support for getArtistSetlists`
- `chore(deps): update dev dependencies`

### Branch Naming

Use short, descriptive branch names:

```bash
git checkout -b feat/get-user-events
```

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
pnpm coverage
```

---

## 📚 Documentation

All code must follow our documentation standards:

> See: [`.cursor/rules/documentation-standards.mdc`](.cursor/rules/documentation-standards.mdc)

This includes:

- A JSDoc-formatted header at the top of each `.ts` file
- Comments for functions, interfaces, constants, and complex logic
- Clear, present-tense phrasing
- Examples where appropriate

Even if you don’t use [Cursor](https://cursor.so), the rule file is readable Markdown and reflects our documentation expectations.

---

## 🧼 Before Submitting a PR

✅ Run type-check: `pnpm type-check`
✅ Lint and fix: `pnpm lint --fix`
✅ Run tests: `pnpm test`
✅ Update documentation if applicable
✅ Squash commits if needed

---

## 🗣️ Questions or Feedback?

Open a [discussion](https://github.com/tkozzer/setlistfm-ts/discussions) or file an [issue](https://github.com/tkozzer/setlistfm-ts/issues) — we’d love to hear from you!

Thanks again for contributing! 🎸
