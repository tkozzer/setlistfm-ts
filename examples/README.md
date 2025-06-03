# SetlistFM TypeScript Client Examples

This directory contains comprehensive examples demonstrating all endpoints of the setlistfm-ts library with the new type-safe client and automatic rate limiting protection.

## Quick Start

### Run All Examples Automatically

Use the provided bash script to run all examples with proper delays and rate limiting:

```bash
# Run from project root directory
./examples/run-all-examples.sh
```

This script will:

- ✅ Run all 18 example scripts across 5 endpoint categories
- 🕐 Include appropriate delays (1s between scripts, 10s between categories)
- ⏰ Apply 60-second timeouts per script to prevent hanging
- 🎨 Provide colorized output with progress indicators
- 📊 Show execution summary and timing information
- 🔒 Demonstrate rate limiting protection throughout

### Manual Execution

You can also run individual examples manually:

```bash
# From project root
pnpm dlx tsx examples/artists/basicArtistLookup.ts
pnpm dlx tsx examples/venues/searchVenues.ts
# etc.
```

## Prerequisites

Before running any examples:

1. **API Key**: Get a free API key from [setlist.fm](https://api.setlist.fm/docs/1.0/index.html)
2. **Environment Setup**: Create a `.env` file in the project root:

```env
SETLISTFM_API_KEY=your-api-key-here
```

## Examples Overview

### 🎤 Artists (4 examples)

- `basicArtistLookup.ts` - Search and lookup individual artists
- `searchArtists.ts` - Comprehensive artist search patterns
- `getArtistSetlists.ts` - Retrieve artist setlists with pagination
- `completeExample.ts` - Full artist analysis workflow

### 🏙️ Cities (3 examples)

- `basicCityLookup.ts` - Search cities and get details by GeoID
- `searchCities.ts` - Advanced city search with geographic filters
- `completeExample.ts` - Multi-country city analysis workflow

### 🌍 Countries (3 examples)

- `basicCountriesLookup.ts` - Search countries and get country codes
- `countriesAnalysis.ts` - Statistical analysis of countries and venues
- `completeExample.ts` - Global music scene analysis

### 🎵 Setlists (4 examples)

- `basicSetlistLookup.ts` - Individual setlist lookup and details
- `searchSetlists.ts` - Search setlists with various criteria
- `advancedAnalysis.ts` - Deep dive setlist data analysis
- `completeExample.ts` - Complete setlist research workflow

### 🏛️ Venues (4 examples)

- `basicVenueLookup.ts` - Find and lookup venue details
- `searchVenues.ts` - Comprehensive venue search functionality
- `getVenueSetlists.ts` - Venue performance history analysis
- `completeExample.ts` - Multi-phase venue analysis workflow

## Key Features Demonstrated

### 🔒 Rate Limiting Protection

All examples showcase the automatic rate limiting features:

- **STANDARD profile**: 2 requests/second, 1440 requests/day (default)
- **Real-time monitoring**: Shows current usage vs. limits
- **Automatic protection**: Prevents accidental API abuse
- **Queue management**: Handles request throttling automatically

### 🎯 Type-Safe Client API

Examples demonstrate the new clean syntax:

```typescript
// Before: Manual HTTP client extraction
const httpClient = client.getHttpClient();
const artists = await searchArtists(httpClient, params);

// After: Direct type-safe methods
const artists = await client.searchArtists(params);
```

### 📊 Comprehensive Coverage

- **18 total examples** covering all major endpoint patterns
- **Production-ready workflows** for real applications
- **Error handling** and edge case management
- **Data analysis techniques** for insights
- **Geographic filtering** and international support

## Script Configuration

The `run-all-examples.sh` script can be customized by editing these variables:

```bash
DELAY_BETWEEN_SCRIPTS=1      # seconds between individual scripts
DELAY_BETWEEN_CATEGORIES=10  # seconds between endpoint categories
TIMEOUT_DURATION=60          # timeout per script in seconds
```

## Expected Behavior

### Rate Limiting Demonstrations

Many examples will intentionally hit rate limits to demonstrate protection:

- 429 errors are **expected behavior** showing protection working
- Examples include real-time rate limit status monitoring
- Queue activation demonstrates when limits are reached

### Example Output

You'll see colorized output including:

- 📊 Rate limiting status throughout execution
- 🔍 Search operations and data discovery
- ✅ Successful API calls and data retrieval
- 📈 Statistical analysis and insights
- ⚠️ Rate limiting demonstrations (2/2 requests, queue status)
- 🎨 Formatted data presentation

### Performance Data

From testing with rate limiting protection:

- **Artists**: ~2-4 minutes per complete workflow
- **Cities**: ~1-3 minutes per analysis
- **Countries**: ~2-5 minutes for global analysis
- **Setlists**: ~3-6 minutes for deep analysis
- **Venues**: ~4-8 minutes for comprehensive workflows
- **Total runtime**: ~15-30 minutes for all examples

## Troubleshooting

### API Key Issues

```bash
❌ Error: .env file not found in project root
```

- Ensure `.env` file exists in project root (not examples folder)
- Verify your API key is correct: `SETLISTFM_API_KEY=your-key-here`

### Rate Limiting (Expected)

```bash
⚠️ Warning: Script completed with issues
```

- This often indicates rate limiting protection working correctly
- Examples demonstrate hitting 2/2 requests per second limit
- Wait between test runs or consider PREMIUM profile for higher limits

### Script Permissions

```bash
chmod +x examples/run-all-examples.sh
```

### Long-Running Examples

- Some examples analyze thousands of records and may take several minutes
- The 60-second timeout can be increased for deeper analysis
- Rate limiting naturally extends execution time

## Learning Path

**Recommended order for manual exploration:**

1. **Start with basics**: Run `basicArtistLookup.ts` to understand fundamentals
2. **Try search patterns**: Explore `searchArtists.ts` for comprehensive searching
3. **Learn analysis**: Study `advancedAnalysis.ts` for data processing techniques
4. **Experience workflows**: Run `completeExample.ts` files for production patterns
5. **Test everything**: Use `./run-all-examples.sh` for comprehensive testing

## Use Cases

These examples demonstrate patterns for:

- **Music discovery apps** - Search artists, venues, and events
- **Concert tracking** - Monitor artist tours and venue histories
- **Data analysis** - Analyze music industry trends and patterns
- **Fan applications** - Discover concert history and setlist data
- **Market research** - Study venue distribution and activity patterns
- **Geographic analysis** - Understand global music scene distribution

## API Documentation

- [Setlist.fm API Documentation](https://api.setlist.fm/docs/1.0/index.html)
- [TypeScript Client Documentation](../README.md)
- [Rate Limiting Guide](../docs/rate-limiting.md)

The examples showcase production-ready patterns for building music applications with automatic rate limiting protection and full type safety. Happy exploring! 🎵
