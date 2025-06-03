# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),  
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [0.1.2] - 2025-01-19

### Fixed

- **API Base URL**: Corrected setlist.fm API base URL from `https://api.setlist.fm/1.0` to `https://api.setlist.fm/rest/1.0` to match the actual API endpoint structure
- **Parameter passing bug**: Fixed artist endpoints incorrectly wrapping parameters in `{ params: }` object when calling HTTP client
- **Test assertions**: Updated HTTP client test to expect the corrected base URL

### Added

- **Working artist endpoints**: All three artist endpoints are now fully functional with real API integration:
  - `getArtist()` - Retrieve artist details by MusicBrainz ID
  - `searchArtists()` - Search for artists with various criteria  
  - `getArtistSetlists()` - Get setlists for a specific artist
- **Enhanced examples**: Updated `basicArtistLookup.ts` example to demonstrate both search and direct lookup functionality
- **Comprehensive validation**: Zod schema validation for all artist endpoint parameters and responses

### Changed

- Updated documentation to reflect correct API URL structure in setlist.fm API docs
- Enhanced README.md usage examples with working code snippets
- Updated project status to show artist endpoints as completed (3/18 endpoints done)

---

## [0.1.1] - 2025-06-02

### Added

- **Core client implementation**: Complete SetlistFM client with configuration options for API key, user agent, timeout, language, and rate limiting
- **HTTP client utilities**: Robust HTTP client with authentication, error handling, response interceptors, and rate limiting support
- **Comprehensive error handling**: Custom error classes for different API scenarios (authentication, not found, rate limiting, validation, server errors)
- **Type definitions**: Core TypeScript types for pagination, responses, and client configuration
- **Pagination utilities**: Helper functions for extracting pagination info, navigating pages, and validating parameters
- **Metadata utilities**: Functions for creating response metadata and library information
- **Rate limiting system**: Configurable rate limiter with different profiles (conservative, balanced, aggressive) and status tracking
- **Logging utilities**: Comprehensive logging system with configurable levels, timestamps, and location tracking
- **Test coverage reporting**: Added Vitest coverage configuration with V8 provider and comprehensive reporting

### Changed

- Updated project status in README to reflect completed core infrastructure
- Enhanced feature list to show implemented functionality
- Updated TypeScript configuration to include all test files
- Added test coverage script and configuration

---

## [0.1.0] - 2025-06-02

### Added

- Initial project scaffold for `setlistfm-ts`, a fully typed SDK for the [setlist.fm](https://www.setlist.fm/) API
- Structured directory layout by API domain:
  - `artists/`, `venues/`, `setlists/`, `users/`, `cities/`, `countries/`
- Endpoint-specific modules:
  - Stub functions and type definitions co-located with endpoint logic
  - Per-folder `README.md` documentation for clarity and onboarding
- Testing infrastructure:
  - Configured `vitest` with support for coverage reporting, module aliasing, and watch mode
- Linting and formatting:
  - ESLint with `@antfu/eslint-config` for modern TypeScript style rules and import sorting
  - Preconfigured `pnpm` scripts for `lint`, `lint:fix`, and `type-check`
- TypeScript configuration:
  - Strict mode, declaration outputs, ESM module resolution, and path aliasing
- Contribution support:
  - `CONTRIBUTING.md` including standards for commits, documentation, testing, and PR flow
  - `.cursor/rules` for enforced documentation and commit conventions
- GitHub Actions workflow for linting, type-checking, and test runs
- Project metadata and licensing:
  - MIT license, keywords, `README.md`, and repository metadata for npm visibility


---

