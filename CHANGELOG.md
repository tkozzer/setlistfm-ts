# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),  
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [0.1.8] - 2025-06-03

### Added

- **Enhanced client architecture**: Major improvements to the SetlistFM client implementation:
  - Type-safe interface definition with comprehensive method signatures and JSDoc documentation
  - Factory pattern implementation for creating configured client instances
  - Endpoint delegation system connecting client methods to individual endpoint functions
  - Integration layer between high-level client interface and low-level endpoint implementations
- **Examples automation system**: Complete automation infrastructure for running all examples:
  - `examples/run-all-examples.sh` script for executing all endpoint examples with proper environment setup
  - `examples/README.md` with comprehensive documentation for the examples system and automation
  - Unified examples execution with rate limiting awareness and error handling
- **Enhanced client testing**: Expanded test coverage for client functionality:
  - Factory pattern validation and configuration testing
  - Client interface method delegation verification
  - Integration testing between client methods and endpoint functions

### Enhanced

- **Documentation improvements**: Major updates to project documentation:
  - Updated main `README.md` with Quick Start section, enhanced usage examples, and comprehensive features list
  - Enhanced examples README files across all endpoints with consistent formatting and better code examples
  - Improved client usage documentation with factory pattern examples and configuration options
- **Code organization**: Improved separation of concerns and maintainability:
  - Clear distinction between client interface, implementation, and endpoint delegation
  - Enhanced type safety across all client methods with proper TypeScript interface definitions
  - Standardized error handling and response patterns across all endpoint integrations
- **Examples consistency**: Standardized example code across all endpoints:
  - Consistent client instantiation patterns using factory methods
  - Unified error handling and logging approaches
  - Improved code readability and documentation across all example files

### Changed

- **Version**: Bumped to 0.1.8 for enhanced client architecture and examples automation
- **Client initialization**: Updated from direct constructor usage to factory pattern for better configuration management
- **Examples structure**: Enhanced organization with centralized automation and documentation
- **Development workflow**: Improved development experience with comprehensive examples system and better client interface

### Fixed

- **Client interface consistency**: Resolved inconsistencies in client method signatures and return types
- **Examples execution**: Fixed path resolution and environment setup issues in example scripts
- **Documentation accuracy**: Updated all documentation to reflect current implementation patterns and best practices

---

## [0.1.7] - 2025-06-03

### Added

- **Setlists endpoints**: Complete implementation of both setlists endpoints with comprehensive functionality:
  - `getSetlist()` - Retrieve setlist details by setlist ID with full artist, venue, and song information
  - `searchSetlists()` - Search setlists by artist, venue, city, date, year, and other criteria with pagination
- **Setlists examples directory**: Four comprehensive example files demonstrating real-world usage:
  - `basicSetlistLookup.ts` - Basic setlist retrieval and search with Beatles example data
  - `searchSetlists.ts` - Advanced search functionality with filtering, pagination, and Beatles historical data
  - `completeExample.ts` - Comprehensive setlist analysis with Radiohead tour data and statistical insights
  - `advancedAnalysis.ts` - Complex multi-year setlist analytics with rate limiting and detailed performance metrics
- **Enhanced data validation**: Robust setlist and version ID validation with flexible format support for real API data
- **Comprehensive testing**: 69 unit tests covering all setlists functionality, validation, error handling, and edge cases
- **Real-world API integration**: Examples handle actual setlist.fm API responses including sets structure and song metadata
- **100% test coverage**: Achieved complete test coverage across all implemented endpoints with 515+ tests

### Enhanced

- **API structure compatibility**: Updated validation to match actual setlist.fm API response format with `sets: { set: [...] }` structure
- **Documentation**: Updated main README.md with setlists examples, usage patterns, and complete endpoint coverage tracking
- **API coverage**: Completed setlists endpoints implementation (2/2) bringing total coverage to 11/12 implemented endpoints
- **Type safety**: Complete TypeScript types for setlists data, songs, sets, tours, and validation schemas
- **Error handling**: Comprehensive error handling patterns for setlists endpoints with proper validation feedback
- **Index exports**: Enhanced main endpoints export with conflict resolution for shared types across modules

### Changed

- **Version**: Bumped to 0.1.7 for setlists endpoints implementation
- **Project status**: Updated to reflect setlists endpoints as fully implemented alongside artists, cities, countries, and venues
- **Examples structure**: Added setlists examples following established patterns with comprehensive real-world scenarios
- **Validation schemas**: Updated setlist ID validation to support 7-8 character format and version ID validation for deprecated fields

### Removed

- **Deprecated endpoint**: Removed `getSetlistVersion` endpoint as it is deprecated by setlist.fm API
- **Unused validation**: Cleaned up obsolete validation schemas and test data for deprecated functionality

### Fixed

- **API response structure**: Fixed setlists data structure to match actual API format with proper sets nesting
- **Validation edge cases**: Resolved test failures for setlist ID and version ID validation with realistic data constraints
- **Test coverage gaps**: Added comprehensive endpoint exports testing to achieve 100% coverage milestone
- **Documentation consistency**: Updated all endpoint README files to remove eslint-disable directives and maintain consistent examples

---

## [0.1.6] - 2025-06-03

### Enhanced

- **Development configuration**: Comprehensive enhancement of TypeScript and ESLint configurations to support examples directory:
  - Updated `tsconfig.json` to include examples directory with proper path mappings for full IDE support
  - Created separate `tsconfig.build.json` for production builds that excludes examples from distribution
  - Enhanced `eslint.config.ts` with examples-specific rules allowing console.log and process.env usage
  - Updated package.json scripts to lint and type-check both src and examples directories
- **Examples directory support**: Full TypeScript and ESLint integration for all example files:
  - Fixed TypeScript parameter type errors in venue examples
  - Automatic lint fixing to remove unused eslint-disable directives
  - Complete IDE support with proper import resolution and type checking
- **Documentation improvements**: Major README.md updates highlighting enhanced development experience:
  - Added comprehensive Rate Limiting section with STANDARD/PREMIUM profile documentation
  - Enhanced examples section emphasizing TypeScript support and rate limiting monitoring
  - Restructured Development Tools section with separate guidance for type-checking, linting, and building
  - Updated usage examples to highlight automatic rate limiting features

### Changed

- **Build process**: Separated development and production configurations for optimal developer experience
- **Linting rules**: Examples directory now has relaxed rules appropriate for demonstration code
- **Version**: Bumped to 0.1.6 for development configuration enhancements

### Fixed

- **TypeScript compilation**: Resolved parameter type issues in examples/venues/getVenueSetlists.ts
- **Configuration consistency**: Unified approach to handling both library code and examples with appropriate tooling

---

## [0.1.5] - 2025-06-03

### Added

- **Venues endpoints**: Complete implementation of all three venues endpoints with comprehensive functionality:
  - `getVenue()` - Retrieve venue details by venue ID with full geographic and contact information
  - `getVenueSetlists()` - Get paginated setlists for a specific venue with artist and date metadata
  - `searchVenues()` - Search venues by name, city, country, state, and state code with advanced filtering
- **Venues examples directory**: Four comprehensive example files demonstrating real-world usage:
  - `basicVenueLookup.ts` - Basic venue search and lookup workflow with famous venues (MSG, Wembley, Red Rocks)
  - `searchVenues.ts` - Advanced search functionality with 8 different scenarios and geographic filtering
  - `getVenueSetlists.ts` - Venue setlist analysis with multi-page data collection and artist statistics
  - `completeExample.ts` - Comprehensive 4-phase workflow with city discovery and statistical insights
- **Enhanced data validation**: Robust venue ID validation using 8-character hexadecimal format with regex filtering
- **Comprehensive testing**: 52 unit tests covering all venues functionality, validation, error handling, and edge cases
- **Real-world data handling**: Examples handle API data quality issues including invalid venue IDs and empty venue names
- **Rate limiting integration**: Removed manual delays in favor of built-in SDK rate limiting capabilities

### Enhanced

- **Documentation**: Updated main README.md with venues examples, usage patterns, and complete API coverage tracking
- **API coverage**: Increased completion from 6/18 to 9/18 endpoints (50% API coverage)
- **Type safety**: Complete TypeScript types for venues data, responses, and validation schemas with proper geographic data types
- **Error handling**: Comprehensive error handling patterns for venues endpoint edge cases and data quality issues
- **Performance optimization**: Efficient venue data processing with filtering for valid records and rate limiting respect

### Changed

- **Version**: Bumped to 0.1.5 for venues endpoints implementation
- **Project status**: Updated to reflect venues endpoints as fully implemented and tested alongside artists, cities, and countries
- **Examples structure**: Added venues examples following established patterns with enhanced real-world data handling
- **Main exports**: Enhanced src/endpoints/index.ts to include all venues endpoints for easy importing

### Fixed

- **Rate limiting**: Replaced manual delay() functions with proper SDK rate limiting configuration support
- **Data validation**: Added venue ID format validation to handle real setlist.fm API data inconsistencies
- **Example reliability**: Enhanced examples to gracefully handle invalid venue data and API rate limits

---

## [0.1.4] - 2025-06-03

### Added

- **Countries endpoint**: Complete implementation of the countries endpoint with comprehensive functionality:
  - `searchCountries()` - Retrieve complete list of all supported countries from setlist.fm API
- **Countries examples directory**: Three comprehensive example files demonstrating real-world usage:
  - `basicCountriesLookup.ts` - Countries retrieval and data exploration with regional groupings
  - `countriesAnalysis.ts` - Advanced analysis with cities integration and statistical insights
  - `completeExample.ts` - Production-ready workflow with data validation and performance testing
- **Enhanced validation**: ISO 3166-1 alpha-2 country code validation with strict schema enforcement
- **Comprehensive testing**: 40 unit tests covering all countries functionality, validation, error handling, and edge cases
- **Cross-endpoint integration**: Examples demonstrate integration with cities endpoint for geographic analysis
- **Performance optimization**: Caching strategies and efficiency recommendations for country data usage

### Enhanced

- **Documentation**: Updated main README.md with countries examples, usage patterns, and progress tracking
- **API coverage**: Increased completion from 5/18 to 6/18 endpoints (33% API coverage)
- **Type safety**: Complete TypeScript types for countries data, responses, and validation schemas
- **Error handling**: Comprehensive error handling patterns for countries endpoint edge cases

### Changed

- **Version**: Bumped to 0.1.4 for countries endpoint implementation
- **Project status**: Updated to reflect countries endpoint as fully implemented and tested
- **Examples structure**: Added countries examples following established patterns from artists and cities

---

## [0.1.3] - 2025-06-03

### Added

- **Cities endpoints**: Complete implementation of both cities endpoints with comprehensive functionality:
  - `getCityByGeoId()` - Retrieve city details by GeoNames geographical ID
  - `searchCities()` - Search cities by name, country, state, and state code with pagination support
- **Cities examples directory**: Three comprehensive example files demonstrating real-world usage:
  - `basicCityLookup.ts` - City search and lookup workflow with fallback strategies
  - `searchCities.ts` - Geographic search using ISO country codes and pagination navigation
  - `completeExample.ts` - Advanced geographic data analysis with statistics and coordinate processing
- **Enhanced validation**: ISO 3166-1 alpha-2 country code validation for improved API compatibility
- **Comprehensive testing**: 52 unit tests covering all cities endpoints, validation, error handling, and edge cases
- **Geographic data analysis**: Examples demonstrate working with real setlist.fm database containing:
  - 184 Paris cities worldwide
  - 5064+ cities in Germany
  - 3329+ cities in UK
  - 10000+ cities in US across 200+ pages

### Enhanced

- **Validation schemas**: Improved `CountryCodeSchema` with strict 2-letter uppercase format validation
- **Error handling**: Comprehensive error handling for geographic data edge cases and API limitations
- **Documentation**: Updated README.md with cities examples, usage patterns, and progress tracking
- **Type safety**: Enhanced TypeScript types for geographic coordinates, country codes, and pagination

### Changed

- **Project status**: Updated API coverage from 3/18 to 5/18 completed endpoints
- **README examples**: Added cities usage examples with proper ISO country code format
- **Feature list**: Added ISO standard validation and comprehensive examples documentation

---

## [0.1.2] - 2025-06-02

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

