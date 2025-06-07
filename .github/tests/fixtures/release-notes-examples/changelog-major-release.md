## [2.0.0] - 2024-12-15

### Added
- New authentication system with OAuth2 support
- Advanced caching layer for improved performance
- TypeScript strict mode compliance
- GraphQL query builder integration

### Changed  
- Complete API redesign for better developer experience
- Updated all dependencies to latest stable versions
- Migrated from Jest to Vitest for testing

### Breaking Changes
- Removed deprecated `setlist.get()` method - use `setlists.getById()` instead
- Authentication now required for all API calls
- Response format changed from snake_case to camelCase
- Minimum Node.js version is now 18+

### Fixed
- Memory leaks in long-running processes
- Race conditions in concurrent requests
- Unicode handling in venue names
