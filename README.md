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
- [x] Cities endpoints (2/2 complete) - **WORKING**
- [x] Countries endpoints (1/1 complete) - **WORKING**
- [x] Venues endpoints (3/3 complete) - **WORKING**
- [ ] Remaining endpoint implementations (9/18 complete)
- [x] Type definitions for API responses
- [x] Input validation (Zod schemas)
- [x] Rate limiting
- [ ] Caching (optional)

---

## ⚙️ Usage

```ts
import { createSetlistFMClient } from "setlistfm-ts";
import { getArtist, getArtistSetlists, searchArtists } from "setlistfm-ts/endpoints/artists";
import { getCityByGeoId, searchCities } from "setlistfm-ts/endpoints/cities";
import { searchCountries } from "setlistfm-ts/endpoints/countries";
import { getVenue, getVenueSetlists, searchVenues } from "setlistfm-ts/endpoints/venues";

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

// eslint-disable-next-line no-console
console.log(searchResults.artist);
// eslint-disable-next-line no-console
console.log(artist.name);
// eslint-disable-next-line no-console
console.log(setlists.setlist);
// eslint-disable-next-line no-console
console.log(cityResults.cities);
// eslint-disable-next-line no-console
console.log(city.name, city.country.name);
// eslint-disable-next-line no-console
console.log(countries.country.length, "countries available");
// eslint-disable-next-line no-console
console.log(venueResults.venue);
// eslint-disable-next-line no-console
console.log(venue.name, venue.city?.name);
// eslint-disable-next-line no-console
console.log(venueSetlists.setlist);
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
- [x] ISO standard validation (country codes, etc.)
- [x] Comprehensive examples and documentation

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

> **Note:** Artists, Cities, Countries, and Venues endpoints are fully implemented with comprehensive tests and examples. Remaining endpoints have scaffolded files with implementations pending.

---

## 📖 Examples

Comprehensive examples are available for all implemented endpoints:

### Artists Examples

- `basicArtistLookup.ts` - Search and retrieve artist information
- `searchArtists.ts` - Advanced artist search with filtering
- `completeExample.ts` - Full workflow with setlist analysis

### Cities Examples

- `basicCityLookup.ts` - City search and lookup workflow
- `searchCities.ts` - Geographic search with country codes and pagination
- `completeExample.ts` - Advanced geographic data analysis

### Countries Examples

- `basicCountriesLookup.ts` - Countries retrieval and data exploration
- `countriesAnalysis.ts` - Comprehensive analysis and integration with cities
- `completeExample.ts` - Production-ready workflow with validation and testing

### Venues Examples

- `basicVenueLookup.ts` - Venue search and lookup workflow
- `searchVenues.ts` - Advanced venue search with geographic filtering
- `getVenueSetlists.ts` - Venue setlist analysis and statistics
- `completeExample.ts` - Comprehensive venue data exploration and insights

Run examples:

```bash
# Artists examples
pnpm dlx tsx examples/artists/basicArtistLookup.ts
pnpm dlx tsx examples/artists/searchArtists.ts
pnpm dlx tsx examples/artists/completeExample.ts

# Cities examples
pnpm dlx tsx examples/cities/basicCityLookup.ts
pnpm dlx tsx examples/cities/searchCities.ts
pnpm dlx tsx examples/cities/completeExample.ts

# Countries examples
pnpm dlx tsx examples/countries/basicCountriesLookup.ts
pnpm dlx tsx examples/countries/countriesAnalysis.ts
pnpm dlx tsx examples/countries/completeExample.ts

# Venues examples
pnpm dlx tsx examples/venues/basicVenueLookup.ts
pnpm dlx tsx examples/venues/searchVenues.ts
pnpm dlx tsx examples/venues/getVenueSetlists.ts
pnpm dlx tsx examples/venues/completeExample.ts
```

> **Note:** Examples require a valid API key in `.env` file. See example README files for setup instructions.

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
- [x] Unit tests for artists endpoints (52 tests)
- [x] Unit tests for cities endpoints (52 tests)
- [x] Unit tests for countries endpoints (40 tests)
- [x] Unit tests for venues endpoints (52 tests)
- [x] Error handling tests
- [x] Validation tests
- [ ] Integration tests with live API
- [ ] Type safety tests for remaining endpoints

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
