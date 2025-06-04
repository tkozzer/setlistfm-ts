# 🎶 setlistfm-ts

[![npm](https://img.shields.io/npm/v/setlistfm-ts?color=%2300B2FF&label=npm)](https://www.npmjs.com/package/setlistfm-ts)
[![build](https://github.com/tkozzer/setlistfm-ts/actions/workflows/ci.yml/badge.svg)](https://github.com/tkozzer/setlistfm-ts/actions/workflows/ci.yml)
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

## ⚠️ Security Notice

**Important: Browser Usage and API Key Safety**

This library includes UMD builds for browser environments, but **exposing API keys in frontend applications is a security risk**. Your setlist.fm API key should be treated as sensitive credentials.

### ❌ Avoid These Patterns

```js
// DON'T: Hardcode API keys in frontend code
const client = createSetlistFMClient({
  apiKey: "your-actual-api-key-here", // ❌ Exposed to all users
  userAgent: "MyApp"
});

// DON'T: Store API keys in client-side storage
localStorage.setItem("apiKey", "your-api-key"); // ❌ Accessible to any script
```

### ✅ Safe Browser Usage Scenarios

The browser builds are appropriate for:

- **Browser Extensions**: Users provide their own API keys stored securely in extension storage
- **Electron Applications**: API keys stored in main process, not renderer
- **Internal Corporate Tools**: Behind authentication, no public key exposure
- **Development/Prototyping**: Local testing with non-production keys
- **Educational Projects**: Learning environments with temporary keys

### 🛡️ Recommended Approach

For production web applications, proxy API calls through your backend:

```js
// ✅ Frontend calls your backend
const response = await fetch("/api/setlists/search", {
  method: "POST",
  headers: { Authorization: `Bearer ${userToken}` },
  body: JSON.stringify({ artistName: "Radiohead" })
});

// ✅ Backend handles setlist.fm API with secure key storage
// server.js
const client = createSetlistFMClient({
  apiKey: process.env.SETLISTFM_API_KEY, // ✅ Server-side only
  userAgent: "MyApp Backend"
});
```

### 🔑 API Key Best Practices

- Store API keys in environment variables
- Use different keys for development/production
- Never commit keys to version control
- Rotate keys periodically
- Monitor usage through setlist.fm dashboard

---

## 🚀 Quick Start

Get started instantly with our comprehensive examples:

```bash
# 1. Install the package
pnpm add setlistfm-ts

# 2. Set up your API key
echo "SETLISTFM_API_KEY=your-api-key-here" > .env

# 3. Run all 18 examples automatically
./examples/run-all-examples.sh
```

This will demonstrate all endpoints with rate limiting protection, showing you exactly how to use the library in production.

---

## 🚧 Project Status

This project is in **active development** with working implementations for core endpoints. The infrastructure is complete and several endpoint groups are fully functional with comprehensive tests and examples.

### Core Infrastructure

- [x] Project scaffolding and TypeScript setup
- [x] Test framework setup (Vitest)
- [x] Linting and formatting (ESLint with @antfu/eslint-config)
- [x] Package.json configuration
- [x] Directory structure for all endpoints
- [x] **Type-safe client implementation with direct method calls**
- [x] HTTP client utilities with rate limiting
- [x] Error handling system
- [x] Type definitions and validation
- [x] Shared utilities (pagination, metadata)

### Development Tools

- [x] TypeScript configuration (src + examples support)
- [x] Build scripts (separate configs for development vs distribution)
- [x] Test scripts with 100% coverage
- [x] Linting scripts (includes examples directory)
- [x] Git hooks setup (Husky)
- [x] Test coverage reporting
- [x] **Rate limiting utilities with automatic STANDARD profile**
- [x] **Examples directory with full IDE support and automated runner**
- [x] **Enhanced CI/CD pipeline with cross-platform testing**
- [x] **Local CI testing with Act support and platform simulation**
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

### New Type-Safe Client API (Recommended)

The modern, type-safe client provides direct methods for cleaner code:

```ts
import { createSetlistFMClient, RateLimitProfile } from "setlistfm-ts";

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

// Example: Search artists with direct method
const searchResults = await client.searchArtists({
  artistName: "Radiohead"
});

// Example: Get artist details
const artist = await client.getArtist("a74b1b7f-71a5-4011-9441-d0b5e4122711");

// Example: Get artist setlists
const setlists = await client.getArtistSetlists("a74b1b7f-71a5-4011-9441-d0b5e4122711");

// Example: Search cities
const cityResults = await client.searchCities({
  name: "London",
  country: "GB" // ISO 3166-1 alpha-2 country code
});

// Example: Get city details
const city = await client.getCityByGeoId("2643743");

// Example: Get all supported countries
const countries = await client.searchCountries();

// Example: Search venues
const venueResults = await client.searchVenues({
  name: "Madison Square Garden",
  cityName: "New York",
  country: "US"
});

// Example: Get venue details
const venue = await client.getVenue("6bd6ca6e");

// Example: Get venue setlists
const venueSetlists = await client.getVenueSetlists("6bd6ca6e");

// Example: Get specific setlist
const setlist = await client.getSetlist("63de4613");

// Example: Search setlists
const setlistResults = await client.searchSetlists({
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

- [x] **Type-safe client API** with direct method calls for all endpoints
- [x] **Modern axios-based HTTP client** with automatic rate limiting
- [x] **Intelligent rate limiting** with STANDARD/PREMIUM profiles and queue management
- [x] **Fully typed API responses** with comprehensive validation
- [x] **Built-in pagination support** with type-safe parameters
- [x] **Developer-friendly errors** with detailed context and debugging
- [x] **Tree-shakable modular endpoints** for optimal bundle size
- [x] **Production-ready configuration** (TypeScript, ESLint, testing)
- [x] **Comprehensive examples** with automated testing script
- [x] **Real-time rate limiting monitoring** with detailed status reporting
- [x] **ISO standard validation** (country codes, geographic data)
- [x] **Enhanced CI/CD pipeline** with cross-platform matrix testing
- [x] **Local CI testing support** with Act integration and platform simulation
- [x] **Minimal dependencies** (only axios and zod)
- [x] **100% test coverage** with comprehensive validation
- [x] **Full IDE support** with examples directory integration

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

### 🚀 Run All Examples Automatically

Use the provided bash script to run all 18 examples across 5 endpoint categories:

```bash
# Run from project root directory
./examples/run-all-examples.sh
```

This automated script provides:

- ✅ **18 comprehensive examples** across all endpoint categories
- 🕐 **Smart rate limiting** with 1s between scripts, 10s between categories
- ⏰ **60-second timeouts** per script to prevent hanging
- 🎨 **Colorized output** with progress indicators and status monitoring
- 📊 **Execution summary** with timing and statistics
- 🔒 **Rate limiting demonstrations** showing protection in action

### 📁 Example Categories

### 🎤 Artists Examples (4 examples)

- `basicArtistLookup.ts` - Search and retrieve artist information with rate limiting
- `searchArtists.ts` - Advanced artist search with filtering and pagination
- `getArtistSetlists.ts` - Artist setlist analysis with intelligent batching
- `completeExample.ts` - Full workflow with setlist analysis and statistics

### 🏙️ Cities Examples (3 examples)

- `basicCityLookup.ts` - City search and lookup workflow with geographic validation
- `searchCities.ts` - Geographic search with country codes and rate-limited pagination
- `completeExample.ts` - Advanced geographic data analysis with real-world examples

### 🌍 Countries Examples (3 examples)

- `basicCountriesLookup.ts` - Countries retrieval and data exploration
- `countriesAnalysis.ts` - Comprehensive analysis and integration with cities
- `completeExample.ts` - Production-ready workflow with validation and testing

### 🎵 Setlists Examples (4 examples)

- `basicSetlistLookup.ts` - Setlist search and retrieval with Beatles example
- `searchSetlists.ts` - Advanced setlist search with filtering and pagination
- `advancedAnalysis.ts` - Complex multi-year setlist statistics and insights
- `completeExample.ts` - Comprehensive setlist analysis with Radiohead data

### 🏛️ Venues Examples (4 examples)

- `basicVenueLookup.ts` - Venue search and lookup workflow with location filtering
- `searchVenues.ts` - Advanced venue search with geographic and rate limiting demonstrations
- `getVenueSetlists.ts` - Venue setlist analysis and statistics with multi-page processing
- `completeExample.ts` - Comprehensive venue data exploration and insights

### 🎯 Example Features

**All examples showcase:**

- ✅ **New type-safe client API** with direct method calls
- ✅ **Automatic STANDARD rate limiting** (2 req/sec, 1440 req/day)
- ✅ **Real-time rate limiting status** monitoring and queue demonstrations
- ✅ **Production-ready error handling** and edge case management
- ✅ **Full TypeScript type checking** and IDE support
- ✅ **ESLint compliance** with examples-specific rules

### 📊 Expected Performance

From comprehensive testing with rate limiting protection:

- **Artists workflows**: ~2-4 minutes per complete analysis
- **Cities analysis**: ~1-3 minutes per geographic workflow
- **Countries research**: ~2-5 minutes for global analysis
- **Setlists deep-dive**: ~3-6 minutes for multi-year analysis
- **Venues comprehensive**: ~4-8 minutes for full workflows
- **Total automated run**: ~15-30 minutes for all 18 examples

### 🔧 Manual Execution

Run individual examples manually:

```bash
# Artists examples
pnpm dlx tsx examples/artists/basicArtistLookup.ts
pnpm dlx tsx examples/artists/searchArtists.ts
pnpm dlx tsx examples/artists/getArtistSetlists.ts
pnpm dlx tsx examples/artists/completeExample.ts

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
pnpm dlx tsx examples/setlists/advancedAnalysis.ts
pnpm dlx tsx examples/setlists/completeExample.ts

# Venues examples
pnpm dlx tsx examples/venues/basicVenueLookup.ts
pnpm dlx tsx examples/venues/searchVenues.ts
pnpm dlx tsx examples/venues/getVenueSetlists.ts
pnpm dlx tsx examples/venues/completeExample.ts
```

### 📋 Prerequisites

Before running any examples:

1. **API Key**: Get a free API key from [setlist.fm](https://api.setlist.fm/docs/1.0/index.html)
2. **Environment Setup**: Create a `.env` file in the project root:

```env
SETLISTFM_API_KEY=your-api-key-here
```

> **Note:** Examples require a valid API key in `.env` file. The automated script includes comprehensive setup validation and helpful error messages.

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

### Local CI Testing

Test the full CI pipeline locally using [Act](https://github.com/nektos/act):

```bash
# Install Act (macOS)
brew install act

# Test quick checks
act -j quick-checks -W .github/workflows/ci-local.yml

# Test full local CI pipeline
act -W .github/workflows/ci-local.yml

# Test with dry run first
act -W .github/workflows/ci-local.yml --dryrun
```

The `ci-local.yml` workflow mirrors the production CI with Act-optimized features:
- ✅ **Cross-platform simulation** (Windows, macOS, multiple Ubuntu versions)
- ✅ **Same validation steps** as production CI
- ✅ **Enhanced platform-specific testing**
- ✅ **Smart test separation** for optimal local experience
- ✅ **Local-only execution** (prevents accidental GitHub Actions runs)

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
├── client.ts           # Main API client with type-safe methods
├── endpoints/          # API endpoint implementations
│   ├── artists/        # Artist search and retrieval
│   ├── cities/         # City search and geographic data
│   ├── countries/      # Country listings and validation
│   ├── setlists/       # Setlist search and retrieval
│   ├── users/          # User data (pending implementation)
│   └── venues/         # Venue search and setlist data
├── shared/             # Shared utilities and types
│   ├── pagination.ts   # Pagination handling
│   ├── metadata.ts     # API response metadata
│   └── errors.ts       # Error handling and types
├── utils/              # Core HTTP and rate limiting
│   ├── httpClient.ts   # HTTP client with rate limiting
│   └── rateLimiter.ts  # Smart rate limiting implementation
└── index.ts            # Public API exports
```

---

## 📄 Contributing

We welcome contributions! This project uses a **three-branch workflow** with AI-powered automation:

- **Development branches** → `preview` → `main`
- **Automated release preparation** and changelog generation
- **AI-enhanced PR descriptions** and professional release notes

Please read our [CONTRIBUTING.md](./CONTRIBUTING.md) guide for the complete workflow and guidelines.

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
