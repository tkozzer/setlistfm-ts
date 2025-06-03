# Venues Endpoints Examples

This directory contains practical examples demonstrating how to use the setlistfm-ts venues endpoints with the new type-safe client and automatic rate limiting protection.

## Prerequisites

Before running these examples, you need:

1. **API Key**: Get a free API key from [setlist.fm](https://api.setlist.fm/docs/1.0/index.html)
2. **Environment Setup**: Create a `.env` file in the project root with your API key

### Environment Setup

Create a `.env` file in the project root (`setlistfm-ts/.env`):

```env
SETLISTFM_API_KEY=your-api-key-here
```

## Key Features

These examples showcase the **new type-safe client API** with significant improvements:

- **Cleaner syntax**: `client.searchVenues(params)` instead of `searchVenues(httpClient, params)`
- **Type safety**: Full TypeScript intellisense and compile-time validation
- **Simplified setup**: No need to manually extract `httpClient`
- **Better error handling**: More descriptive error messages and validation
- **Automatic rate limiting**: Built-in protection with real-time status monitoring

## Rate Limiting Protection

All examples use the new `createSetlistFMClient` which automatically applies **STANDARD rate limiting** (2 requests/second, 1440 requests/day) to protect against accidental API limit violations. The examples display real-time rate limiting status showing:

- Current rate limit profile (STANDARD by default)
- Requests made this second vs. limit
- Requests made today vs. daily limit
- Queue status and rate limiting demonstrations

### Rate Limiting Features

**Default Protection** (used in all examples):

```typescript
const client = createSetlistFMClient({
  apiKey: process.env.SETLISTFM_API_KEY!,
  userAgent: "your-app-name (your-email@example.com)",
  // Automatically uses STANDARD profile: 2 req/sec, 1440 req/day
});
```

**Premium Users** (16 req/sec, 50,000 req/day):

```typescript
const client = createSetlistFMClient({
  apiKey: process.env.SETLISTFM_API_KEY!,
  userAgent: "your-app-name (your-email@example.com)",
  rateLimit: { profile: RateLimitProfile.PREMIUM }
});
```

**Advanced Users** (no rate limiting):

```typescript
const client = createSetlistFMClient({
  apiKey: process.env.SETLISTFM_API_KEY!,
  userAgent: "your-app-name (your-email@example.com)",
  rateLimit: { profile: RateLimitProfile.DISABLED }
});
```

## Available Examples

### 1. `basicVenueLookup.ts`

**Purpose**: Basic venue search and lookup workflow with rate limiting demonstrations

**What it demonstrates**:

- Creating a SetlistFM client with automatic STANDARD rate limiting
- Real-time rate limiting status monitoring throughout operations
- **Type-safe venue search**: `client.searchVenues(params)` with full IntelliSense
- **Type-safe venue lookup**: `client.getVenue(id)` with compile-time validation
- Finding famous venues (Madison Square Garden, Wembley Stadium, Red Rocks)
- Working with venue geographic data and city information
- Filtering venues by location criteria (city, state, country)
- Rate limiting protection during multi-step workflows
- Basic error handling and venue data validation

**Run it**:

```bash
pnpm dlx tsx examples/venues/basicVenueLookup.ts
```

**Key features**: Shows rate limiting status progression (6-7 total requests), demonstrates famous venue lookup workflows with clean syntax.

### 2. `searchVenues.ts`

**Purpose**: Comprehensive venue search functionality with rate limiting awareness

**What it demonstrates**:

- Rate limiting monitoring during extensive search operations
- **Type-safe search parameters**: Full TypeScript support for all search criteria
- Searching venues by name, city, country, state, and state code
- Using proper ISO country codes (US, GB, DE, CA) for filtering
- Using pagination parameters for large result sets (1,000+ venues)
- Combining multiple search criteria for precise results
- Handling empty search results and venues without cities
- Processing search result data and geographic analysis
- International venue comparisons across countries
- Rate limiting demonstrations when hitting per-second limits

**Run it**:

```bash
pnpm dlx tsx examples/venues/searchVenues.ts
```

**Key features**: Shows rate limiting protection in action (12+ requests, hitting 2/2 limit), demonstrates comprehensive search patterns with type safety.

### 3. `getVenueSetlists.ts`

**Purpose**: Venue setlist retrieval and analysis with rate limiting management

**What it demonstrates**:

- Rate limiting awareness during multi-endpoint workflows
- **Type-safe setlist retrieval**: `client.getVenueSetlists(id)` with full type information
- Getting setlists for specific venues by venue ID
- Analyzing venue performance data and artist statistics
- Processing setlist data for insights (years, artists, song counts)
- Comparing setlist activity between famous venues
- Recent venue activity discovery and analysis
- Rate limiting status during intensive data processing

**Run it**:

```bash
pnpm dlx tsx examples/venues/getVenueSetlists.ts
```

**Key features**: Shows complex workflows with rate limiting, analyzes thousands of setlists with type-safe methods.

### 4. `completeExample.ts`

**Purpose**: Production-ready workflow with comprehensive analysis and intelligent rate limiting

**What it demonstrates**:

- Complete venue API workflow with automatic rate limiting
- Multi-city venue discovery across major music markets (5 cities)
- Venue type categorization and statistical analysis (9 venue types)
- Famous venue deep-dive with comprehensive setlist analysis (5 venues)
- Geographic insights and venue distribution patterns
- Advanced data processing and cross-referencing with rate limiting
- Performance metrics and venue activity comparisons
- Rate limiting demonstrations throughout complex workflows
- Production-scale data analysis with automatic protection

**Run it**:

```bash
pnpm dlx tsx examples/venues/completeExample.ts
```

**Key features**: Demonstrates enterprise workflows with rate limiting (30+ requests), analyzes thousands of venues and setlists with type-safe client methods.

## Example Output

When you run these examples, you'll see formatted output with:

- 📊 **Rate limiting status**: Shows profile, current usage, and limits throughout
- 🔍 Search operations and venue discovery
- ✅ Successful data retrieval confirmations
- 🏛️ Venue information and geographic data
- 🎵 Setlist counts and music activity statistics
- 📊 Statistical analysis and venue comparisons
- 🌍 Geographic insights and location data
- ⚠️ Rate limiting demonstrations (2/2 requests, queue status)
- ❌ Error handling demonstrations

## Code Structure

Each example follows a consistent pattern with the type-safe client:

```typescript
import { createSetlistFMClient } from "../../src/client";
import "dotenv/config";

async function exampleFunction(): Promise<void> {
  // Create client with automatic STANDARD rate limiting
  const client = createSetlistFMClient({
    apiKey: process.env.SETLISTFM_API_KEY!,
    userAgent: "setlistfm-ts-examples (github.com/tkozzer/setlistfm-ts)",
  });

  try {
    // Display rate limiting status
    const status = client.getRateLimitStatus();
    console.log(`📊 Rate Limiting: ${status.profile.toUpperCase()} profile`);

    // Type-safe venue search
    const venues = await client.searchVenues({
      name: "Arena",
      country: "US",
    });

    // Type-safe venue lookup
    if (venues.venue.length > 0) {
      const venueDetails = await client.getVenue(venues.venue[0].id);
      console.log(`Found: ${venueDetails.name}`);

      // Type-safe setlist retrieval
      const setlists = await client.getVenueSetlists(venues.venue[0].id);
      console.log(`Setlists: ${setlists.total}`);
    }
  }
  catch (error) {
    console.error("Error:", error);
  }
}
```

## API Methods Used

The examples demonstrate these type-safe client methods:

### Venue Search

- `client.searchVenues(params)` - Search venues with type-safe parameters
- Full TypeScript intellisense for search criteria
- Automatic validation of country codes and parameters

### Venue Details

- `client.getVenue(id)` - Get detailed venue information
- Type-safe venue response with city, coordinates, and metadata
- Compile-time validation of venue ID format

### Venue Setlists

- `client.getVenueSetlists(id)` - Get setlists for a venue
- Returns paginated setlist data with full type information
- Note: Client method returns first page only (use direct endpoint for pagination)

### Rate Limiting

- `client.getRateLimitStatus()` - Get current rate limiting status
- Real-time monitoring of request counts and limits
- Automatic queue management and request throttling

## Running the Examples

To run any example:

1. Set up your environment with API key
2. Navigate to the project root
3. Run with tsx:

```bash
# Basic venue lookup
pnpm dlx tsx examples/venues/basicVenueLookup.ts

# Comprehensive search
pnpm dlx tsx examples/venues/searchVenues.ts

# Setlist analysis
pnpm dlx tsx examples/venues/getVenueSetlists.ts

# Complete workflow
pnpm dlx tsx examples/venues/completeExample.ts
```

## Learn More

- [Setlist.fm API Documentation](https://api.setlist.fm/docs/1.0/index.html)
- [TypeScript Client Documentation](../../README.md)
- [Rate Limiting Documentation](../../docs/rate-limiting.md)
- [Other Examples](../README.md)

The venue examples demonstrate production-ready patterns for building music discovery applications, venue analysis tools, and concert data processors with automatic rate limiting protection and full type safety.
