# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),  

## [0.7.3] - 2025-06-09

### Added

- Introduced a debug-variables.sh script to safely handle special characters in changelog content, preventing shell parsing errors.
- Added support for --version, --changelog, and --verbose parameters in extract-changelog-entry.sh for improved interface compatibility.

### Changed

- Updated the release-pr workflow to utilize scripts for handling special characters instead of inline bash commands, enhancing reliability.
- Refactored automation scripts into modular components for better maintainability and testability, improving the overall CI/CD process.
- Enhanced the release-notes-generate.yml workflow with a four-stage data collection pipeline, improving the integration of changelog data.

### Fixed

- Resolved shell parsing errors in the release-pr workflow caused by special characters and multiline content, ensuring smoother operation.
- Fixed command parsing errors in the release PR workflow by replacing eval-based execution with direct GitHub CLI calls, preventing unexpected failures.
- Corrected the handling of multiline content in the manage-release-pr.sh script, ensuring that complex PR descriptions are processed correctly.
- Addressed issues with debug output in various scripts, ensuring that only necessary output is sent to stdout, preventing workflow failures.

---


## [0.7.2] - 2025-06-09

### Added

- Introduced --body-base64 parameter in manage-release-pr.sh script for safe handling of multiline content in release PRs.
- Enhanced release-notes-generate.yml workflow with a four-stage data collection pipeline for improved changelog generation.

### Changed

- Updated release-pr.yml workflow to utilize base64 encoding for multiline content, improving compatibility with AI-generated PR descriptions.
- Refactored entrypoint.sh to handle multiline variable parsing correctly, ensuring comprehensive variable substitution in templates.
- Updated README.md to reflect accurate script counts and testing status for all automation scripts, enhancing documentation clarity.

### Fixed

- Resolved command parsing errors in release PRs caused by special characters, ensuring PR body text is processed correctly.
- Fixed GitHub Actions workflow failures related to multiline content parsing, preventing generic AI responses in release notes.
- Redirected debug output to stderr in multiple scripts to prevent unexpected output interference during command parsing.

### Security

- Improved error handling and validation in workflows to ensure robustness against malformed input and potential security issues.

---


## [0.7.1] - 2025-06-08

### Added

- Created comprehensive AGENTS.md following OpenAI Codex specification to guide AI agents in the setlistfm-ts codebase.

### Changed

- Enhanced workflow documentation in README.md, detailing development and release automation workflows.
- Restructured GitHub automation into modular scripts for improved maintainability and testability.

### Fixed

- Fixed GitHub Actions workflow failures by redirecting debug output to stderr in various scripts, preventing unexpected errors during the release process.
- Improved testing environment for release PR checkout to ensure reliable workflow execution.
- Added comprehensive tests for release-prepare changelog update logic to validate various scenarios and prevent regressions.

---


and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [0.7.0] - 2025-06-07

### Added

- Introduced a comprehensive 'Automated Workflows' section in the README.md to enhance visibility into CI/CD processes and development workflows.
- Created AGENTS.md for AI agent guidance, detailing project structure, API patterns, and development workflow standards.
- Implemented a structured output system for OpenAI workflows, supporting JSON schema validation and template processing for changelog and PR enhancements.
- Enhanced CI commit detection to recognize scope-based patterns in commit messages, providing educational feedback for improving commit message quality.

### Changed

- Refactored CI workflows to modernize and streamline processes, removing legacy workflows and improving organization with new directories for actions and prompts.
- Updated the CI commit analysis system to provide a detailed summary of PR metrics, including commit types and file changes, enhancing user experience.
- Improved error handling and logging throughout the CI/CD pipeline, ensuring better visibility and maintainability.

### Fixed

- Resolved multiple issues related to handling nested changes in PR enhancement workflows, ensuring proper formatting and readability of AI-generated content.
- Fixed regex patterns for conventional commit detection to ensure accurate analysis and labeling of commits across all types.
- Addressed various bugs in the CI workflows, including handling multi-line content and special characters in commit messages to prevent errors during processing.

---

## [0.6.0] - 2025-06-05

### Added

- Introduced a structured output system for OpenAI workflows, enhancing JSON schema validation and template processing for changelog and PR enhancement workflows.
- Enhanced CI commit detection to recognize scope-based patterns like 'refactor(ci):' and provide educational guidance for conventional commit messages.

### Changed

- Refactored CI workflows to modernize and streamline the CI/CD infrastructure, improving maintainability and organization.
- Updated the commit analysis system to provide a comprehensive summary of PR statistics, including commit types and file changes, enhancing user experience.

### Fixed

- Resolved issues with handling nested changes structures in PR enhancement, ensuring proper formatting of AI-generated content.
- Fixed multiple bugs related to template processing in GitHub Actions, including handling of multi-line content and special characters to prevent errors during changelog generation.
- Addressed inconsistencies in commit counting and regex patterns for conventional commit detection, ensuring accurate analysis and labeling.

---

## [0.5.0] - 2025-06-04

### Fixed
- Completely rewrote the release preparation GitHub Actions workflow to improve robustness, maintainability, and security.
- Resolved multiple shell interpretation issues that caused failures when commit messages or changelog entries contained special characters such as backticks, percent signs, or markdown code blocks.
- Replaced unsafe variable expansions and  commands with safer heredoc and temporary file approaches to prevent command injection and shell execution errors during version bump detection and changelog generation.
- Switched from -based JSON template substitution to direct JSON construction with  to handle special characters safely in OpenAI API payloads.
- Added comprehensive error handling and fallback mechanisms for OpenAI API calls to ensure changelog generation continues gracefully even if the AI service fails or returns invalid responses.
- Fixed SIGPIPE errors in the release workflow by replacing piped commit
- Enhanced logging and debugging output throughout the release workflow for easier troubleshooting.
- Updated the release PR workflow to use a Personal Access Token (PAT) instead of the default GitHub token, preventing permission errors when creating pull requests.
- Added a step to ensure required GitHub labels ( and ) exist before applying them to release PRs, preventing label-not-found errors.
- Fixed changelog extraction logic in the release PR workflow to correctly capture the latest version’s changelog entries.
- Corrected variable expansion issues in PR description templates to ensure dynamic content is rendered properly.

### Changed
- Streamlined environment variable usage and naming conventions in release workflows for better readability and consistency.
- Improved visual clarity of workflow output messages using Unicode arrows and standardized error messages.
- Reduced temporary file creation and simplified cleanup in CI workflows.
- Standardized shell declarations and code organization in workflows following best practices.

These changes make the release process more reliable and secure, especially when commit messages or changelogs contain special characters, and improve the developer experience by reducing manual intervention and errors during automated releases.

---

## [0.4.0] - 2025-06-04

### Changed
- Refactor CI release-preparation workflow with safe file-based commit handling, here-docs, and `jq` templating.
- Prevent shell interpretation and SIGPIPE errors by using `--max-count`, environment variables, and quoted here-docs.
- Improve OpenAI changelog generation with robust error handling, fallbacks, and clearer prompts.
- Streamline logging, variable naming, and use Unicode symbols for readability.

### Fixed
- SIGPIPE errors in commit collection.
- Shell execution failures caused by special characters in commit messages.

## [0.3.0] - 2025-06-04

### Added
- Introduced a comprehensive three-branch development workflow automating pull request creation and release management.
- Added AI-powered PR description enhancement using OpenAI to generate clearer, more informative pull requests.
- Implemented automatic conventional commit analysis and labeling to streamline changelog generation and version bumping.
- Created `pr-template-automation.yml` to automate PR descriptions targeting the `preview` branch.
- Created `create-release-pr.yml` for automated release PR generation from `preview` to `main`.
- Added repository owner auto-assignment for all pull requests to improve review efficiency.
- Provided `.env.act.example` template for local testing of GitHub workflows with OpenAI integration.
- Enhanced documentation with a visual branch structure diagram and detailed explanation of the new three-branch workflow in `CONTRIBUTING.md`.
- Updated `README.md` to reflect the new project structure and contributing workflow.

### Changed
- Updated CI workflow triggers to run on pull requests targeting `preview` and `main` branches instead of `main` and `develop`.
- Removed push triggers from CI workflows to focus on validation during PRs, aligning with the new branching strategy.
- Improved environment file handling by adding `.env.act` to `.gitignore` and providing configuration examples for OpenAI API keys.
- Fixed README build badge URL to correctly point to the CI workflow.
- Improved documentation formatting and clarity throughout the project.

### Fixed
- Resolved GitHub Actions permissions issues by adding `contents:write` permission and enabling `persist-credentials` for proper authentication during release workflows.
- Fixed shell escaping issues in changelog update commands to prevent command interpretation errors during CI runs.

## [0.2.0] - 2025-06-04

### Added
- Introduced a comprehensive GitHub release workflow system that automates version bumping and changelog generation using OpenAI GPT.
- Added a new release-preparation workflow triggered on pushes to the `preview` branch, enabling automated semantic version detection and changelog updates based on conventional commit messages.
- Created a `.env.act.example` template to facilitate local testing of GitHub workflows with proper OpenAI API integration.
  
### Changed
- Updated CI workflow triggers to run on pull requests targeting `preview` and `main` branches instead of `main` and `develop`, aligning with the new three-branch workflow strategy.
- Removed CI triggers on push events to focus validation on pull requests, improving workflow efficiency.
- Enhanced `.gitignore` patterns and removed `.env.act` from version control to prevent accidental exposure of sensitive API keys.
- Improved version bump detection logic to avoid false positives, ensuring accurate semantic versioning based on commit messages.
- Refined changelog update process to safely handle special characters and prevent shell command interpretation errors.
- Configured workflow permissions and authentication to allow automated commits and pushes of version and changelog updates by GitHub Actions.

### Fixed
- Resolved permission issues causing 403 errors when the GitHub Actions bot attempted to push version bump commits.
- Fixed shell escaping problems in changelog updates that previously caused errors with special characters like backticks.
- Corrected version bump detection to prevent incorrect major version increments triggered by "BREAKING CHANGE" text in commit bodies rather than commit headers.

## [0.1.9] - 2025-06-03

### Added

- **Local CI testing infrastructure**: Complete Act-based local CI testing system for GitHub Actions:
  - `ci-local.yml` workflow optimized for nektos/act with production CI mirroring
  - Cross-platform simulation supporting Windows, macOS, and multiple Ubuntu versions
  - Enhanced platform-specific validation steps for comprehensive local testing
  - `.actrc` configuration file with optimized container settings for local development
  - `.env.act` environment template for secure local testing
- **Act integration documentation**: Comprehensive local CI testing guidance:
  - Installation and usage instructions for Act GitHub Actions runner
  - Local workflow testing commands with dry-run options
  - Platform simulation features and cross-platform testing capabilities
  - Act-specific optimizations and GitHub Actions compatibility notes

### Enhanced

- **Production CI pipeline**: Major improvements to GitHub Actions workflow architecture:
  - **Smart test execution strategy**: Separated source tests from build verification tests
  - **Enhanced matrix testing**: Cross-platform testing across Node.js 18.x, 20.x, 22.x on Ubuntu, Windows, macOS
  - **Improved reporting**: Detailed CI summaries with test execution breakdown and platform coverage
  - **Better error handling**: Clear separation prevents confusing failures when build artifacts don't exist
  - **Performance optimization**: Faster feedback with logical test separation and parallel execution
- **Development workflow**: Significantly improved local development experience:
  - **Local CI mirroring**: 95%+ identical local and production CI validation
  - **Platform simulation**: Windows and macOS testing simulation on local Docker containers
  - **Enhanced debugging**: Comprehensive local testing without consuming GitHub Actions minutes
  - **Container optimization**: Multiple Ubuntu versions and container images for thorough testing
- **Project infrastructure**: Enhanced development tooling and configuration:
  - Updated `.gitignore` with Act-specific file patterns and artifact handling
  - Enhanced ESLint configuration with proper regex escaping for filename validation
  - Improved documentation highlighting CI/CD capabilities and local testing features

### Changed

- **CI architecture**: Moved from basic single-job CI to comprehensive multi-job pipeline with:
  - `quick-checks` job for fast developer feedback (source tests only)
  - `test-matrix` job for cross-platform validation (Node versions + OS combinations)
  - `coverage` job for quality metrics and reporting
  - `build-verification` job for package validation (build tests only)
  - `ci-success` job for final validation gate with enhanced reporting
- **Test execution strategy**: Intelligent test separation for optimal developer experience:
  - Source tests (`src/**/*.test.ts`) run in quick-checks and matrix jobs
  - Build verification tests (`tests/**/*.test.ts`) only run after successful build
  - Total test coverage maintained (534 tests) with better execution timing
- **Version**: Bumped to 0.1.9 for enhanced CI/CD infrastructure and local testing capabilities

### Fixed

- **ESLint configuration**: Resolved regex pattern validation error in filename-case rule
- **Dependency installation**: Enhanced lockfile handling for both strict production and flexible local development
- **Test reliability**: Eliminated confusing test failures by running build tests only when artifacts exist
- **Documentation accuracy**: Updated all CI-related documentation to reflect enhanced capabilities

### Infrastructure

- **Local development**: Act integration provides comprehensive local CI testing equivalent to production
- **Cross-platform coverage**: Enhanced testing across 7 environment combinations locally and in production
- **Developer experience**: Significantly reduced feedback cycle for CI changes with local validation
- **Production reliability**: Maintained all existing CI quality while adding comprehensive local testing capabilities

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
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),  
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [0.7.0] - 2025-06-07

### Added

- Introduced a comprehensive 'Automated Workflows' section in the README.md to enhance visibility into CI/CD processes and development workflows.
- Created AGENTS.md for AI agent guidance, detailing project structure, API patterns, and development workflow standards.
- Implemented a structured output system for OpenAI workflows, supporting JSON schema validation and template processing for changelog and PR enhancements.
- Enhanced CI commit detection to recognize scope-based patterns in commit messages, providing educational feedback for improving commit message quality.

### Changed

- Refactored CI workflows to modernize and streamline processes, removing legacy workflows and improving organization with new directories for actions and prompts.
- Updated the CI commit analysis system to provide a detailed summary of PR metrics, including commit types and file changes, enhancing user experience.
- Improved error handling and logging throughout the CI/CD pipeline, ensuring better visibility and maintainability.

### Fixed

- Resolved multiple issues related to handling nested changes in PR enhancement workflows, ensuring proper formatting and readability of AI-generated content.
- Fixed regex patterns for conventional commit detection to ensure accurate analysis and labeling of commits across all types.
- Addressed various bugs in the CI workflows, including handling multi-line content and special characters in commit messages to prevent errors during processing.

---

## [0.6.0] - 2025-06-05

### Added

- Introduced a structured output system for OpenAI workflows, enhancing JSON schema validation and template processing for changelog and PR enhancement workflows.
- Enhanced CI commit detection to recognize scope-based patterns like 'refactor(ci):' and provide educational guidance for conventional commit messages.

### Changed

- Refactored CI workflows to modernize and streamline the CI/CD infrastructure, improving maintainability and organization.
- Updated the commit analysis system to provide a comprehensive summary of PR statistics, including commit types and file changes, enhancing user experience.

### Fixed

- Resolved issues with handling nested changes structures in PR enhancement, ensuring proper formatting of AI-generated content.
- Fixed multiple bugs related to template processing in GitHub Actions, including handling of multi-line content and special characters to prevent errors during changelog generation.
- Addressed inconsistencies in commit counting and regex patterns for conventional commit detection, ensuring accurate analysis and labeling.

---

## [0.5.0] - 2025-06-04

### Fixed
- Completely rewrote the release preparation GitHub Actions workflow to improve robustness, maintainability, and security.
- Resolved multiple shell interpretation issues that caused failures when commit messages or changelog entries contained special characters such as backticks, percent signs, or markdown code blocks.
- Replaced unsafe variable expansions and  commands with safer heredoc and temporary file approaches to prevent command injection and shell execution errors during version bump detection and changelog generation.
- Switched from -based JSON template substitution to direct JSON construction with  to handle special characters safely in OpenAI API payloads.
- Added comprehensive error handling and fallback mechanisms for OpenAI API calls to ensure changelog generation continues gracefully even if the AI service fails or returns invalid responses.
- Fixed SIGPIPE errors in the release workflow by replacing piped commit
- Enhanced logging and debugging output throughout the release workflow for easier troubleshooting.
- Updated the release PR workflow to use a Personal Access Token (PAT) instead of the default GitHub token, preventing permission errors when creating pull requests.
- Added a step to ensure required GitHub labels ( and ) exist before applying them to release PRs, preventing label-not-found errors.
- Fixed changelog extraction logic in the release PR workflow to correctly capture the latest version’s changelog entries.
- Corrected variable expansion issues in PR description templates to ensure dynamic content is rendered properly.

### Changed
- Streamlined environment variable usage and naming conventions in release workflows for better readability and consistency.
- Improved visual clarity of workflow output messages using Unicode arrows and standardized error messages.
- Reduced temporary file creation and simplified cleanup in CI workflows.
- Standardized shell declarations and code organization in workflows following best practices.

These changes make the release process more reliable and secure, especially when commit messages or changelogs contain special characters, and improve the developer experience by reducing manual intervention and errors during automated releases.

---

## [0.4.0] - 2025-06-04

### Changed
- Refactor CI release-preparation workflow with safe file-based commit handling, here-docs, and `jq` templating.
- Prevent shell interpretation and SIGPIPE errors by using `--max-count`, environment variables, and quoted here-docs.
- Improve OpenAI changelog generation with robust error handling, fallbacks, and clearer prompts.
- Streamline logging, variable naming, and use Unicode symbols for readability.

### Fixed
- SIGPIPE errors in commit collection.
- Shell execution failures caused by special characters in commit messages.

## [0.3.0] - 2025-06-04

### Added
- Introduced a comprehensive three-branch development workflow automating pull request creation and release management.
- Added AI-powered PR description enhancement using OpenAI to generate clearer, more informative pull requests.
- Implemented automatic conventional commit analysis and labeling to streamline changelog generation and version bumping.
- Created `pr-template-automation.yml` to automate PR descriptions targeting the `preview` branch.
- Created `create-release-pr.yml` for automated release PR generation from `preview` to `main`.
- Added repository owner auto-assignment for all pull requests to improve review efficiency.
- Provided `.env.act.example` template for local testing of GitHub workflows with OpenAI integration.
- Enhanced documentation with a visual branch structure diagram and detailed explanation of the new three-branch workflow in `CONTRIBUTING.md`.
- Updated `README.md` to reflect the new project structure and contributing workflow.

### Changed
- Updated CI workflow triggers to run on pull requests targeting `preview` and `main` branches instead of `main` and `develop`.
- Removed push triggers from CI workflows to focus on validation during PRs, aligning with the new branching strategy.
- Improved environment file handling by adding `.env.act` to `.gitignore` and providing configuration examples for OpenAI API keys.
- Fixed README build badge URL to correctly point to the CI workflow.
- Improved documentation formatting and clarity throughout the project.

### Fixed
- Resolved GitHub Actions permissions issues by adding `contents:write` permission and enabling `persist-credentials` for proper authentication during release workflows.
- Fixed shell escaping issues in changelog update commands to prevent command interpretation errors during CI runs.

## [0.2.0] - 2025-06-04

### Added
- Introduced a comprehensive GitHub release workflow system that automates version bumping and changelog generation using OpenAI GPT.
- Added a new release-preparation workflow triggered on pushes to the `preview` branch, enabling automated semantic version detection and changelog updates based on conventional commit messages.
- Created a `.env.act.example` template to facilitate local testing of GitHub workflows with proper OpenAI API integration.
  
### Changed
- Updated CI workflow triggers to run on pull requests targeting `preview` and `main` branches instead of `main` and `develop`, aligning with the new three-branch workflow strategy.
- Removed CI triggers on push events to focus validation on pull requests, improving workflow efficiency.
- Enhanced `.gitignore` patterns and removed `.env.act` from version control to prevent accidental exposure of sensitive API keys.
- Improved version bump detection logic to avoid false positives, ensuring accurate semantic versioning based on commit messages.
- Refined changelog update process to safely handle special characters and prevent shell command interpretation errors.
- Configured workflow permissions and authentication to allow automated commits and pushes of version and changelog updates by GitHub Actions.

### Fixed
- Resolved permission issues causing 403 errors when the GitHub Actions bot attempted to push version bump commits.
- Fixed shell escaping problems in changelog updates that previously caused errors with special characters like backticks.
- Corrected version bump detection to prevent incorrect major version increments triggered by "BREAKING CHANGE" text in commit bodies rather than commit headers.

## [0.1.9] - 2025-06-03

### Added

- **Local CI testing infrastructure**: Complete Act-based local CI testing system for GitHub Actions:
  - `ci-local.yml` workflow optimized for nektos/act with production CI mirroring
  - Cross-platform simulation supporting Windows, macOS, and multiple Ubuntu versions
  - Enhanced platform-specific validation steps for comprehensive local testing
  - `.actrc` configuration file with optimized container settings for local development
  - `.env.act` environment template for secure local testing
- **Act integration documentation**: Comprehensive local CI testing guidance:
  - Installation and usage instructions for Act GitHub Actions runner
  - Local workflow testing commands with dry-run options
  - Platform simulation features and cross-platform testing capabilities
  - Act-specific optimizations and GitHub Actions compatibility notes

### Enhanced

- **Production CI pipeline**: Major improvements to GitHub Actions workflow architecture:
  - **Smart test execution strategy**: Separated source tests from build verification tests
  - **Enhanced matrix testing**: Cross-platform testing across Node.js 18.x, 20.x, 22.x on Ubuntu, Windows, macOS
  - **Improved reporting**: Detailed CI summaries with test execution breakdown and platform coverage
  - **Better error handling**: Clear separation prevents confusing failures when build artifacts don't exist
  - **Performance optimization**: Faster feedback with logical test separation and parallel execution
- **Development workflow**: Significantly improved local development experience:
  - **Local CI mirroring**: 95%+ identical local and production CI validation
  - **Platform simulation**: Windows and macOS testing simulation on local Docker containers
  - **Enhanced debugging**: Comprehensive local testing without consuming GitHub Actions minutes
  - **Container optimization**: Multiple Ubuntu versions and container images for thorough testing
- **Project infrastructure**: Enhanced development tooling and configuration:
  - Updated `.gitignore` with Act-specific file patterns and artifact handling
  - Enhanced ESLint configuration with proper regex escaping for filename validation
  - Improved documentation highlighting CI/CD capabilities and local testing features

### Changed

- **CI architecture**: Moved from basic single-job CI to comprehensive multi-job pipeline with:
  - `quick-checks` job for fast developer feedback (source tests only)
  - `test-matrix` job for cross-platform validation (Node versions + OS combinations)
  - `coverage` job for quality metrics and reporting
  - `build-verification` job for package validation (build tests only)
  - `ci-success` job for final validation gate with enhanced reporting
- **Test execution strategy**: Intelligent test separation for optimal developer experience:
  - Source tests (`src/**/*.test.ts`) run in quick-checks and matrix jobs
  - Build verification tests (`tests/**/*.test.ts`) only run after successful build
  - Total test coverage maintained (534 tests) with better execution timing
- **Version**: Bumped to 0.1.9 for enhanced CI/CD infrastructure and local testing capabilities

### Fixed

- **ESLint configuration**: Resolved regex pattern validation error in filename-case rule
- **Dependency installation**: Enhanced lockfile handling for both strict production and flexible local development
- **Test reliability**: Eliminated confusing test failures by running build tests only when artifacts exist
- **Documentation accuracy**: Updated all CI-related documentation to reflect enhanced capabilities

### Infrastructure

- **Local development**: Act integration provides comprehensive local CI testing equivalent to production
- **Cross-platform coverage**: Enhanced testing across 7 environment combinations locally and in production
- **Developer experience**: Significantly reduced feedback cycle for CI changes with local validation
- **Production reliability**: Maintained all existing CI quality while adding comprehensive local testing capabilities

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
