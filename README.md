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

This project is in **active development** with working implementations for core endpoints. The infrastructure is complete and several endpoint groups are fully functional with comprehensive tests and examples.

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

- [x] TypeScript configuration (src + examples support)
- [x] Build scripts (separate configs for development vs distribution)
- [x] Test scripts
- [x] Linting scripts (includes examples directory)
- [x] Git hooks setup (Husky)
- [x] Test coverage reporting
- [x] Rate limiting utilities with automatic STANDARD profile
- [x] Examples directory with full IDE support
- [ ] CI/CD pipeline
- [ ] Documentation generation

### API Coverage

- [x] Artist endpoints (3/3 complete) - **WORKING**
- [x] Cities endpoints (2/2 complete) - **WORKING**
- [x] Countries endpoints (1/1 complete) - **WORKING**
- [x] Setlists endpoints (2/2 complete) - **WORKING**
- [x] Venues endpoints (3/3 complete) - **WORKING**
- [ ] Users endpoints (0/3 complete) - **PENDING**
- [x] Type definitions for API responses
- [x] Input validation (Zod schemas)
- [x] Rate limiting
- [ ] Caching (optional)

---

## ⚙️ Usage

**setlistfm-ts** includes automatic rate limiting using the STANDARD profile (2 req/sec, 1440 req/day) by default. For premium users, you can configure higher limits.

```ts
import { createSetlistFMClient } from "setlistfm-ts";
import { getArtist, getArtistSetlists, searchArtists } from "setlistfm-ts/endpoints/artists";
import { getCityByGeoId, searchCities } from "setlistfm-ts/endpoints/cities";
import { searchCountries } from "setlistfm-ts/endpoints/countries";
import { getSetlist, searchSetlists } from "setlistfm-ts/endpoints/setlists";
import { getVenue, getVenueSetlists, searchVenues } from "setlistfm-ts/endpoints/venues";

// Default client with STANDARD rate limiting (2 req/sec, 1440 req/day)
const client = createSetlistFMClient({
  apiKey: "your-api-key-here",
  userAgent: "your-app-name (your-email@example.com)",
});

// Optional: Configure premium rate limiting
const premiumClient = createSetlistFMClient({
  apiKey: "your-api-key-here",
  userAgent: "your-app-name (your-email@example.com)",
  rateLimit: { profile: RateLimitProfile.PREMIUM } // 16 req/sec, 50,000 req/day
});

// Example: Search artists
const searchResults = await searchArtists(client.getHttpClient(), {
  artistName: "Radiohead"
});

// Example: Get artist details
const artist = await getArtist(client.getHttpClient(), "a74b1b7f-71a5-4011-9441-d0b5e4122711");

// Example: Get artist setlists
const setlists = await getArtistSetlists(client.getHttpClient(), "a74b1b7f-71a5-4011-9441-d0b5e4122711");

// Example: Search cities
const cityResults = await searchCities(client.getHttpClient(), {
  name: "London",
  country: "GB" // ISO 3166-1 alpha-2 country code
});

// Example: Get city details
const city = await getCityByGeoId(client.getHttpClient(), "2643743");

// Example: Get all supported countries
const countries = await searchCountries(client.getHttpClient());

// Example: Search venues
const venueResults = await searchVenues(client.getHttpClient(), {
  name: "Madison Square Garden",
  cityName: "New York",
  country: "US"
});

// Example: Get venue details
const venue = await getVenue(client.getHttpClient(), "6bd6ca6e");

// Example: Get venue setlists
const venueSetlists = await getVenueSetlists(client.getHttpClient(), "6bd6ca6e");

// Example: Get specific setlist
const setlist = await getSetlist(client.getHttpClient(), "63de4613");

// Example: Search setlists
const setlistResults = await searchSetlists(client.getHttpClient(), {
  artistMbid: "a74b1b7f-71a5-4011-9441-d0b5e4122711", // Radiohead
  year: 2023
});

console.log(searchResults.artist);
console.log(artist.name);
console.log(setlists.setlist);
console.log(cityResults.cities);
console.log(city.name, city.country.name);
console.log(countries.country.length, "countries available");
console.log(venueResults.venue);
console.log(venue.name, venue.city?.name);
console.log(venueSetlists.setlist);
console.log(setlist.artist.name, setlist.venue.name);
console.log(setlistResults.setlist.length, "setlists found");
```

---

## 🧩 Features

- [x] Fully typed API responses
- [x] Modern `axios`-based HTTP client with automatic rate limiting
- [x] Built-in pagination support
- [x] Minimal dependencies
- [x] Developer-friendly errors
- [x] Tree-shakable modular endpoints
- [x] Intelligent rate limiting with STANDARD/PREMIUM profiles
- [x] Comprehensive logging utilities
- [x] ISO standard validation (country codes, etc.)
- [x] Comprehensive examples with full IDE support
- [x] Production-ready configuration (TypeScript, ESLint, testing)

---

## 🔍 Supported Endpoints

### Artists

- [x] `getArtist` - Get artist by MusicBrainz ID ✅
- [x] `searchArtists` - Search for artists ✅
- [x] `getArtistSetlists` - Get setlists for an artist ✅

### Setlists

- [x] `getSetlist` - Get setlist by ID ✅
- [x] `searchSetlists` - Search for setlists ✅

### Venues

- [x] `getVenue` - Get venue by ID ✅
- [x] `getVenueSetlists` - Get setlists for a venue ✅
- [x] `searchVenues` - Search for venues ✅

### Cities

- [x] `searchCities` - Search for cities ✅
- [x] `getCityByGeoId` - Get city by geographical ID ✅

### Countries

- [x] `searchCountries` - Get all supported countries ✅

### Users

- [ ] `getUser` - Get user information
- [ ] `getUserAttended` - Get setlists attended by user
- [ ] `getUserEdited` - Get setlists edited by user

> **Note:** Artists, Cities, Countries, Setlists, and Venues endpoints are fully implemented with comprehensive tests and examples. Users endpoints have scaffolded files with implementations pending.

---

## 📖 Examples

Comprehensive examples are available for all implemented endpoints with **full TypeScript support**, **rate limiting monitoring**, and **production-ready patterns**:

### Artists Examples

- `basicArtistLookup.ts` - Search and retrieve artist information with rate limiting
- `searchArtists.ts` - Advanced artist search with filtering and pagination
- `getArtistSetlists.ts` - Artist setlist analysis with intelligent batching
- `completeExample.ts` - Full workflow with setlist analysis and statistics

### Cities Examples

- `basicCityLookup.ts` - City search and lookup workflow with geographic validation
- `searchCities.ts` - Geographic search with country codes and rate-limited pagination
- `completeExample.ts` - Advanced geographic data analysis with real-world examples

### Countries Examples

- `basicCountriesLookup.ts` - Countries retrieval and data exploration
- `countriesAnalysis.ts` - Comprehensive analysis and integration with cities
- `completeExample.ts` - Production-ready workflow with validation and testing

### Setlists Examples

- `basicSetlistLookup.ts` - Setlist search and retrieval with Beatles example
- `searchSetlists.ts` - Advanced setlist search with filtering and pagination
- `completeExample.ts` - Comprehensive setlist analysis with Radiohead data
- `advancedAnalysis.ts` - Complex multi-year setlist statistics and insights

### Venues Examples

- `basicVenueLookup.ts` - Venue search and lookup workflow with location filtering
- `searchVenues.ts` - Advanced venue search with geographic and rate limiting demonstrations
- `getVenueSetlists.ts` - Venue setlist analysis and statistics with multi-page processing
- `completeExample.ts` - Comprehensive venue data exploration and insights

**All examples feature:**

- ✅ Automatic STANDARD rate limiting (2 req/sec, 1440 req/day)
- ✅ Real-time rate limiting status monitoring
- ✅ Production-ready error handling
- ✅ Full TypeScript type checking and IDE support
- ✅ ESLint compliance with examples-specific rules

Run examples:

```bash
# Artists examples
pnpm dlx tsx examples/artists/basicArtistLookup.ts
pnpm dlx tsx examples/artists/searchArtists.ts
pnpm dlx tsx examples/artists/completeExample.ts

# Artists examples
pnpm dlx tsx examples/artists/getArtistSetlists.ts

# Cities examples
pnpm dlx tsx examples/cities/basicCityLookup.ts
pnpm dlx tsx examples/cities/searchCities.ts
pnpm dlx tsx examples/cities/completeExample.ts

# Countries examples
pnpm dlx tsx examples/countries/basicCountriesLookup.ts
pnpm dlx tsx examples/countries/countriesAnalysis.ts
pnpm dlx tsx examples/countries/completeExample.ts

# Setlists examples
pnpm dlx tsx examples/setlists/basicSetlistLookup.ts
pnpm dlx tsx examples/setlists/searchSetlists.ts
pnpm dlx tsx examples/setlists/completeExample.ts
pnpm dlx tsx examples/setlists/advancedAnalysis.ts

# Venues examples
pnpm dlx tsx examples/venues/basicVenueLookup.ts
pnpm dlx tsx examples/venues/searchVenues.ts
pnpm dlx tsx examples/venues/getVenueSetlists.ts
pnpm dlx tsx examples/venues/completeExample.ts
```

> **Note:** Examples require a valid API key in `.env` file. See example README files for setup instructions.

---

## 🧪 Testing

**setlistfm-ts** has achieved **100% test coverage** with comprehensive testing across all implemented endpoints.

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
- [x] 100% code coverage achieved (515 tests across 16 test files)
- [x] Unit tests for artists endpoints (74 tests)
- [x] Unit tests for cities endpoints (52 tests)
- [x] Unit tests for countries endpoints (40 tests)
- [x] Unit tests for setlists endpoints (69 tests)
- [x] Unit tests for venues endpoints (71 tests)
- [x] Unit tests for core utilities (142 tests)
- [x] Error handling tests
- [x] Validation tests
- [x] Integration tests with real API responses
- [x] Complete type safety validation

---

## ✅ Development Tools

### Type Checking

Full TypeScript checking for both library code and examples:

```bash
pnpm type-check           # Check src + examples directories
pnpm type-check:verbose   # Verbose output with file listings
```

### Linting

ESLint with examples-specific rules (allows console.log, process.env in examples):

```bash
pnpm lint                 # Lint src + examples directories
pnpm lint:fix             # Auto-fix issues
```

### Building

Separate configurations for development vs distribution:

```bash
pnpm build                # Build library only (excludes examples)
pnpm check                # Full validation (type-check + lint + test)
```

**Configuration Files:**

- `tsconfig.json` - Development config (includes examples)
- `tsconfig.build.json` - Production build config (excludes examples)
- `eslint.config.ts` - Unified linting with examples-specific rules

---

## ⚡ Rate Limiting

**setlistfm-ts** includes intelligent rate limiting to protect against API limits and ensure reliable operation:

### Automatic Protection

- **STANDARD Profile** (default): 2 requests/second, 1,440 requests/day
- **PREMIUM Profile**: 16 requests/second, 50,000 requests/day
- **DISABLED Profile**: No rate limiting (advanced users only)

### Smart Features

- ✅ **Automatic request queuing** when limits are approached
- ✅ **Real-time status monitoring** with detailed metrics
- ✅ **Intelligent retry logic** with proper backoff
- ✅ **Per-second and per-day limit tracking**
- ✅ **Configurable queue sizes** and timeout handling

### Usage Examples

```ts
import { createSetlistFMClient, RateLimitProfile } from "setlistfm-ts";

// Default STANDARD rate limiting
const client = createSetlistFMClient({
  apiKey: "your-api-key",
  userAgent: "your-app-name (email@example.com)"
});

// Premium rate limiting
const premiumClient = createSetlistFMClient({
  apiKey: "your-api-key",
  userAgent: "your-app-name (email@example.com)",
  rateLimit: { profile: RateLimitProfile.PREMIUM }
});

// Check rate limit status
const status = client.getRateLimitStatus();

console.log(`Requests: ${status.requestsThisSecond}/${status.secondLimit} this second`);
console.log(`Daily usage: ${status.requestsThisDay}/${status.dayLimit} today`);
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
