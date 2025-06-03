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

This project is currently in **early development**. The core infrastructure is now in place, including the main client implementation and foundational utilities. API endpoint implementations are the next priority.

### Core Infrastructure

- [x] Project scaffolding and TypeScript setup
- [x] Test framework setup (Vitest)
- [x] Linting and formatting (ESLint with @antfu/eslint-config)
- [x] Package.json configuration
- [x] Directory structure for all endpoints
- [x] Main client implementation
- [x] HTTP client utilities
- [x] Error handling system
- [x] Type definitions
- [x] Shared utilities (pagination, metadata)

### Development Tools

- [x] TypeScript configuration
- [x] Build scripts
- [x] Test scripts
- [x] Linting scripts
- [x] Git hooks setup (Husky)
- [x] Test coverage reporting
- [x] Rate limiting utilities
- [ ] CI/CD pipeline
- [ ] Documentation generation

### API Coverage

- [x] Artist endpoints (3/3 complete) - **WORKING**
- [ ] Remaining endpoint implementations (3/18 complete)
- [x] Type definitions for API responses
- [x] Input validation (Zod schemas)
- [x] Rate limiting
- [ ] Caching (optional)

---

## ⚙️ Usage

```ts
import { createSetlistFMClient } from "setlistfm-ts";
import { getArtist, getArtistSetlists, searchArtists } from "setlistfm-ts/endpoints/artists";

const client = createSetlistFMClient({
  apiKey: "your-api-key-here",
  userAgent: "your-app-name (your-email@example.com)",
});

// Example: Search artists
const searchResults = await searchArtists(client.getHttpClient(), {
  artistName: "Radiohead"
});

// Example: Get artist details
const artist = await getArtist(client.getHttpClient(), "a74b1b7f-71a5-4011-9441-d0b5e4122711");

// Example: Get artist setlists
const setlists = await getArtistSetlists(client.getHttpClient(), "a74b1b7f-71a5-4011-9441-d0b5e4122711");

// eslint-disable-next-line no-console
console.log(searchResults.artist);
// eslint-disable-next-line no-console
console.log(artist.name);
// eslint-disable-next-line no-console
console.log(setlists.setlist);
```

---

## 🧩 Features

- [x] Fully typed API responses
- [x] Modern `axios`-based HTTP client
- [x] Built-in pagination support
- [x] Minimal dependencies
- [x] Developer-friendly errors
- [x] Tree-shakable modular endpoints
- [x] Rate limiting support
- [x] Comprehensive logging utilities

---

## 🔍 Supported Endpoints

### Artists

- [x] `getArtist` - Get artist by MusicBrainz ID ✅
- [x] `searchArtists` - Search for artists ✅
- [x] `getArtistSetlists` - Get setlists for an artist ✅

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
