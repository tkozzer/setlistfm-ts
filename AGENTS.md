# AGENTS.md - setlistfm-ts

This file provides comprehensive guidance for AI agents working with the **setlistfm-ts** codebase - a modern, type-safe TypeScript client for the setlist.fm REST API.

## Project Overview

**setlistfm-ts** is a production-ready TypeScript SDK that provides fully typed access to the setlist.fm API. The project emphasizes type safety, comprehensive testing, intelligent rate limiting, and developer experience.

### Core Values

- **Type Safety**: All API responses are fully typed with comprehensive validation
- **Developer Experience**: Clean, intuitive APIs with extensive examples and documentation
- **Production Ready**: Built-in rate limiting, error handling, and comprehensive testing
- **Modern TypeScript**: Latest ES modules, strict type checking, and best practices

## Project Structure for AI Agents

```
setlistfm-ts/
├── src/                           # Main source code
│   ├── client.ts                  # Type-safe client with direct method calls
│   ├── client.types.ts            # Client interface definitions
│   ├── index.ts                   # Public API exports
│   ├── endpoints/                 # API endpoint implementations
│   │   ├── artists/               # Artist search and retrieval
│   │   ├── cities/                # City search and geographic data
│   │   ├── countries/             # Country listings and validation
│   │   ├── setlists/              # Setlist search and retrieval
│   │   ├── users/                 # User data (pending implementation)
│   │   └── venues/                # Venue search and setlist data
│   ├── shared/                    # Shared utilities and types
│   │   ├── pagination.ts          # Pagination handling utilities
│   │   ├── metadata.ts            # API response metadata types
│   │   └── errors.ts              # Error handling and custom types
│   └── utils/                     # Core HTTP and rate limiting
│       ├── http.ts                # HTTP client with rate limiting
│       └── rateLimiter.ts         # Smart rate limiting implementation
├── examples/                      # Comprehensive usage examples
│   ├── run-all-examples.sh        # Automated example runner
│   ├── artists/                   # Artist API examples (4 files)
│   ├── cities/                    # Cities API examples (3 files)
│   ├── countries/                 # Countries API examples (3 files)
│   ├── setlists/                  # Setlists API examples (4 files)
│   └── venues/                    # Venues API examples (4 files)
├── docs/                          # API documentation
├── tests/                         # Test files (100% coverage achieved)
└── scripts/                       # Build and utility scripts
```

## Documentation Standards for AI Agents

### JSDoc Documentation Requirements

**All TypeScript files must include comprehensive JSDoc documentation:**

#### File Headers

```typescript
/**
 * @file filename.ts
 * @description Brief description of the file's role in the SDK.
 * @author tkozzer
 * @module moduleName
 */
```

#### Functions & Methods

````typescript
/**
 * Fetches data from the Setlist.fm API using the given parameters.
 *
 * @param {string} mbid - MusicBrainz ID of the artist.
 * @returns {Promise<Setlist[]>} A promise that resolves to an array of setlists.
 * @throws {APIError} If the request fails or returns an unexpected response.
 * @example
 * ```ts
 * const setlists = await getSetlistsByArtist("1234-mbid");
 * console.log(setlists.length);
 * ```
 */
````

#### Type Definitions

```typescript
/**
 * Represents an artist object returned by the Setlist.fm API.
 */
export type Artist = {
  /** Unique MusicBrainz identifier */
  mbid: string;
  /** Display name of the artist */
  name: string;
};
```

### Code Style Guidelines for AI Agents

#### TypeScript Standards

- **Strict type checking**: All code must pass `pnpm type-check`
- **No `any` types**: Use proper typing for all variables and function parameters
- **Import conventions**: Use `@` path aliases for internal imports
- **Interface vs Type**: Prefer `type` over `interface` in documentation examples
- **Export patterns**: Use named exports for better tree-shaking

#### Formatting Standards

- **Double quotes**: Always use double quotes for strings in code examples
- **Comment spacing**: Single space after `//` in inline comments
- **Consistent indentation**: 2 spaces for TypeScript files
- **Trailing commas**: Include trailing commas in multi-line objects/arrays

#### Example Code Format

```typescript
import type { Artist } from "@endpoints/artists/types";
import { createSetlistFMClient } from "./client";

const client = createSetlistFMClient({
  apiKey: "your-api-key",
  userAgent: "MyApp (contact@example.com)",
});

const artist: Artist = await client.getArtist("artist-mbid");
```

## Git Commit Message Standards for AI Agents

### Commit Message Format

```
<type>(<scope>): <short summary>

Detailed description of what changed, why, and how.
Mention any implementation details, refactoring decisions, or linked issues.

Refs: #issue-number (if applicable)
BREAKING CHANGE: <description> (if applicable)
```

### Commit Types

- `feat`: New features or endpoint implementations
- `fix`: Bug fixes and corrections
- `docs`: Documentation updates
- `test`: Test additions or modifications
- `refactor`: Code refactoring without functional changes
- `perf`: Performance improvements
- `style`: Code style/formatting changes
- `build`: Build system or dependency changes
- `ci`: CI/CD pipeline changes
- `chore`: Maintenance tasks

### Scope Guidelines

- `client`: Main client implementation
- `artists`: Artist endpoints
- `cities`: Cities endpoints
- `countries`: Countries endpoints
- `setlists`: Setlists endpoints
- `venues`: Venues endpoints
- `users`: Users endpoints
- `shared`: Shared utilities
- `utils`: HTTP and rate limiting utilities
- `examples`: Example files
- `docs`: Documentation

## API Implementation Guidelines for AI Agents

### Endpoint Structure Pattern

Each endpoint group follows this consistent pattern:

```
// endpoints/{group}/
├── index.ts              // Main endpoint exports
├── types.ts              // Type definitions
├── {group}.test.ts       // Comprehensive tests
├── {specific}.ts         // Individual endpoint implementations
└── __test__/             # Additional test files
```

### Implementation Requirements

#### 1. Type Safety

- All API responses must be validated with Zod schemas
- Comprehensive TypeScript interfaces for all data structures
- Proper error typing with custom error classes

#### 2. Rate Limiting

- All HTTP requests go through the rate limiter
- Default STANDARD profile (2 req/sec, 1440 req/day)
- Premium profile support (16 req/sec, 50,000 req/day)

#### 3. Error Handling

- Custom error classes for different failure scenarios
- Proper HTTP status code handling
- Meaningful error messages with context

#### 4. Testing Requirements

- **100% test coverage** for all new code
- Unit tests for individual functions
- Integration tests with mocked API responses
- Error scenario testing

### Client API Pattern

The client provides direct methods for clean, type-safe usage:

```typescript
// ✅ Preferred: Type-safe client methods
const client = createSetlistFMClient({
  apiKey: "your-api-key",
  userAgent: "MyApp (contact@example.com)",
});

const artist = await client.getArtist("mbid");
const setlists = await client.getArtistSetlists("mbid");
```

## Testing Guidelines for AI Agents

### Test Organization

- Tests live adjacent to implementation files: `{module}.test.ts`
- Additional tests in `__test__/` subdirectories when needed
- 100% coverage requirement for all new features

### Test Categories

1. **Unit Tests**: Individual function testing
2. **Integration Tests**: API endpoint testing with mocks
3. **Type Tests**: TypeScript compilation and type safety
4. **Error Tests**: Error handling and edge cases

### Testing Commands

```bash
# Run all tests
pnpm test

# Watch mode for development
pnpm test:watch

# Type checking
pnpm type-check

# Linting
pnpm lint

# Full validation
pnpm check  # Runs type-check + lint + test
```

## Rate Limiting Implementation for AI Agents

### Rate Limiting Profiles

- **STANDARD** (default): 2 requests/second, 1,440 requests/day
- **PREMIUM**: 16 requests/second, 50,000 requests/day
- **DISABLED**: No rate limiting (advanced users)

### Rate Limiting Features

- Automatic request queuing when limits approached
- Real-time status monitoring with detailed metrics
- Intelligent retry logic with proper backoff
- Per-second and per-day limit tracking

## Examples and Documentation for AI Agents

### Example Structure

- **18 comprehensive examples** across 5 endpoint categories
- Full TypeScript support with proper type checking
- Rate limiting demonstrations in all examples
- Production-ready patterns and error handling

### Example Categories

1. **Artists** (4 examples): Search, lookup, setlist analysis
2. **Cities** (3 examples): Geographic search and validation
3. **Countries** (3 examples): Country data and analysis
4. **Setlists** (4 examples): Search, analysis, statistics
5. **Venues** (4 examples): Search, lookup, setlist analysis

### Running Examples

```bash
# Automated runner for all examples
./examples/run-all-examples.sh

# Individual examples
pnpm dlx tsx examples/artists/basicArtistLookup.ts
```

## Security and API Key Management for AI Agents

### Security Guidelines

- **Never expose API keys** in frontend code or examples
- Store API keys in environment variables only
- Use `.env` files for local development
- Proxy API calls through backend for web applications

### Environment Setup

```bash
# Required for examples and development
SETLISTFM_API_KEY=your-api-key-here
```

## Development Workflow for AI Agents

### Build Commands

```bash
# Development (includes examples in type checking)
pnpm type-check

# Production build (library only)
pnpm build

# Full validation pipeline
pnpm check
```

### Pre-commit Requirements

1. All tests must pass: `pnpm test`
2. Type checking must pass: `pnpm type-check`
3. Linting must pass: `pnpm lint`
4. Code must be formatted: `pnpm format`

### Branch Strategy

- **Development branches** → `preview` → `main`
- Feature branches for new implementations
- Comprehensive PR reviews required
- Automated CI/CD pipeline validation

## Programmatic Checks for AI Agents

Before submitting any changes, **ALL** of these checks must pass:

```bash
# Type checking (includes examples)
pnpm type-check

# Linting (src + examples)
pnpm lint

# Auto-fix linting issues
pnpm lint:fix

# Full test suite
pnpm test

# Complete validation
pnpm check  # Runs all above checks
```

### CI/CD Validation

- Cross-platform testing (Windows, macOS, Ubuntu)
- Multiple Node.js versions
- 100% test coverage enforcement
- Type safety validation
- Linting compliance

## API Coverage Status for AI Agents

### ✅ Implemented Endpoints (100% Complete)

- **Artists**: `getArtist`, `searchArtists`, `getArtistSetlists`
- **Cities**: `searchCities`, `getCityByGeoId`
- **Countries**: `searchCountries`
- **Setlists**: `getSetlist`, `searchSetlists`
- **Venues**: `getVenue`, `searchVenues`, `getVenueSetlists`

### 🚧 Pending Implementation

- **Users**: `getUser`, `getUserAttended`, `getUserEdited`

## Key Dependencies for AI Agents

### Runtime Dependencies

- **axios**: HTTP client for API requests
- **zod**: Runtime type validation and schema parsing

### Development Dependencies

- **TypeScript**: Static type checking
- **Vitest**: Testing framework
- **ESLint**: Code linting with @antfu/eslint-config
- **Rollup**: Build system for distribution

## AI Agent Guidelines Summary

When working with this codebase:

1. **Follow TypeScript best practices** with comprehensive JSDoc documentation
2. **Maintain 100% test coverage** for all new features
3. **Use the established patterns** for endpoint implementations
4. **Include comprehensive examples** for any new functionality
5. **Respect rate limiting** in all API interactions
6. **Follow git commit standards** with semantic prefixes
7. **Ensure all programmatic checks pass** before submitting changes
8. **Use double quotes** and consistent formatting in all code
9. **Leverage the type-safe client API** for clean, modern usage patterns
10. **Prioritize developer experience** in all implementations

This codebase represents a **production-ready TypeScript SDK** with modern development practices, comprehensive testing, and excellent developer experience. All contributions should maintain these high standards.
