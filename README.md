# 🎶 setlistfm-ts

[![npm](https://img.shields.io/npm/v/setlistfm-ts?color=%2300B2FF&label=npm)](https://www.npmjs.com/package/setlistfm-ts)
[![build](https://github.com/tkozzer/setlistfm-ts/actions/workflows/ci.yml/badge.svg)](https://github.com/tkozzer/setlistfm-ts/actions/workflows/test.yml)
[![license](https://img.shields.io/github/license/tkozzer/setlistfm-ts)](./LICENSE)
[![stars](https://img.shields.io/github/stars/tkozzer/setlistfm-ts?style=social)](https://github.com/tkozzer/setlistfm-ts/stargazers)

> A modern, type-safe TypeScript client for the [setlist.fm REST API](https://api.setlist.fm/docs/1.0/index.html).

**setlistfm-ts** provides a lightweight, fully typed interface to the setlist.fm API, enabling easy access to artists, setlists, venues, and more — all in clean, idiomatic TypeScript.

---

## 📦 Installation

```bash
pnpm add setlistfm-ts
# or
npm install setlistfm-ts
# or
yarn add setlistfm-ts
```

---

## 🚧 Project Status

This project is currently in **early development**. The basic structure and scaffolding are in place, but most functionality is not yet implemented.

### Core Infrastructure

- [x] Project scaffolding and TypeScript setup
- [x] Test framework setup (Vitest)
- [x] Linting and formatting (ESLint with @antfu/eslint-config)
- [x] Package.json configuration
- [x] Directory structure for all endpoints
- [ ] Main client implementation
- [ ] HTTP client utilities
- [ ] Error handling system
- [ ] Type definitions
- [ ] Shared utilities (pagination, metadata)

### Development Tools

- [x] TypeScript configuration
- [x] Build scripts
- [x] Test scripts
- [x] Linting scripts
- [x] Git hooks setup (Husky)
- [ ] CI/CD pipeline
- [ ] Documentation generation

### API Coverage

- [ ] All endpoint implementations (0/18 complete)
- [ ] Type definitions for API responses
- [ ] Input validation
- [ ] Rate limiting
- [ ] Caching (optional)

---

## ⚙️ Usage

> **⚠️ Warning:** The usage example below shows the intended API but is not yet functional. Implementation is in progress.

```ts
import { createSetlistFMClient } from "setlistfm-ts";

const client = createSetlistFMClient({
  apiKey: "your-api-key-here",
  userAgent: "your-app-name (your-email@example.com)",
});

// Example: Search artists
const result = await client.artists.search({ artistName: "Radiohead" });

// eslint-disable-next-line no-console
console.log(result.artists);
```

---

## 🧩 Features

- [ ] Fully typed API responses
- [ ] Modern `fetch`-based HTTP client
- [ ] Built-in pagination support
- [x] Minimal dependencies
- [ ] Developer-friendly errors
- [x] Tree-shakable modular endpoints (structure only)

---

## 🔍 Supported Endpoints

### Artists

- [ ] `getArtist` - Get artist by MusicBrainz ID
- [ ] `searchArtists` - Search for artists
- [ ] `getArtistSetlists` - Get setlists for an artist

### Setlists

- [ ] `getSetlist` - Get setlist by ID
- [ ] `getSetlistVersion` - Get specific version of a setlist
- [ ] `searchSetlists` - Search for setlists

### Venues

- [ ] `getVenue` - Get venue by ID
- [ ] `getVenueSetlists` - Get setlists for a venue
- [ ] `searchVenues` - Search for venues

### Cities

- [ ] `searchCities` - Search for cities
- [ ] `getCityByGeoId` - Get city by geographical ID

### Countries

- [ ] `searchCountries` - Search for countries

### Users

- [ ] `getUser` - Get user information
- [ ] `getUserAttended` - Get setlists attended by user
- [ ] `getUserEdited` - Get setlists edited by user

> **Note:** All endpoints have scaffolded files but implementations are pending.

---

## 🧪 Testing

> **Note:** Currently only placeholder tests exist. Real tests will be added as endpoints are implemented.

Run the test suite:

```bash
pnpm test
```

Watch mode:

```bash
pnpm test:watch
```

### Test Coverage

- [x] Test framework setup
- [x] Basic test structure for all endpoints
- [ ] Unit tests for endpoint implementations
- [ ] Integration tests with API
- [ ] Error handling tests
- [ ] Type safety tests

---

## ✅ Type Checking

Ensure your project stays type-safe:

```bash
pnpm type-check
```

Verbose typecheck with file listings and diagnostics:

```bash
pnpm type-check:verbose
```

---

## 📁 Project Structure

```
src/
├── client.ts           # Entry point for creating the API client
├── endpoints/          # Grouped endpoint handlers (artists, venues, etc.)
├── shared/             # Shared utilities like pagination, errors, metadata
├── utils/              # HTTP logic and logger
├── index.ts            # Public exports
```

---

## 📄 Contributing

We welcome contributions! Please read the [CONTRIBUTING.md](./CONTRIBUTING.md) guide before getting started.

---

## 🛡️ License

[MIT](./LICENSE)

---

## 📫 Contact

Created with 💛 by [@tkozzer](https://github.com/tkozzer)
API documentation: [https://api.setlist.fm/docs](https://api.setlist.fm/docs)

---

## 🌟 Star History

[![Star History Chart](https://api.star-history.com/svg?repos=tkozzer/setlistfm-ts&type=Date)](https://star-history.com/#tkozzer/setlistfm-ts&Date)
