# Setlist Endpoints Examples

This directory contains practical examples demonstrating how to use the setlistfm-ts setlist endpoints with the new type-safe client.

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

- **Cleaner syntax**: `client.searchSetlists(params)` instead of `searchSetlists(httpClient, params)`
- **Direct method calls**: `client.getSetlist(id)` instead of managing HTTP clients
- **No HTTP client management**: Direct method calls on the client instance
- **Full type safety**: IDE autocompletion and type checking for all methods and parameters
- **Consistent interface**: All endpoint methods follow the same pattern
- **Automatic rate limiting**: Built-in protection against API limits
- **Simplified pagination**: Clean parameter handling for multi-page workflows

## Rate Limiting

All examples automatically use **STANDARD rate limiting** (2 requests/second, 1440 requests/day) by default. This protects you from accidentally hitting API rate limits while exploring the examples.

The examples display rate limiting information to help you understand current usage:

- Profile type (standard, premium, or disabled)
- Requests made in the current second and daily limits
- Real-time tracking of API usage

## Available Examples

### 1. `basicSetlistLookup.ts`

**Purpose**: Basic setlist retrieval by ID with type-safe client methods

**What it demonstrates**:

- Creating a SetlistFM client with automatic STANDARD rate limiting
- Using the type-safe `client.getSetlist(id)` method to look up a specific setlist
- Parsing and displaying setlist information with full type safety
- Working with sets, songs, and venue data using typed responses
- Handling song metadata (covers, guest appearances, tape) with type checking
- Viewing rate limiting status during single endpoint usage
- Basic error handling with typed error responses

**Run it**:

```bash
pnpm dlx tsx examples/setlists/basicSetlistLookup.ts
```

**Key features**: Shows clean setlist retrieval with one API call, demonstrates comprehensive data parsing using type-safe methods.

### 2. `searchSetlists.ts`

**Purpose**: Comprehensive setlist search functionality with type-safe client methods

**What it demonstrates**:

- Using the type-safe `client.searchSetlists(params)` method for various search criteria
- Searching setlists by artist name with full parameter type checking
- Filtering by venue, city, and year using typed search parameters
- Using specific date searches with proper date format validation
- Handling pagination with multiple pages using clean client methods
- Processing and grouping search results with typed responses
- Working with complex search criteria and type-safe parameter validation
- Rate limiting with multiple API calls using automatic protection

**Run it**:

```bash
pnpm dlx tsx examples/setlists/searchSetlists.ts
```

**Key features**: Demonstrates comprehensive search functionality (6 total requests) with full type safety and automatic rate limiting.

### 3. `completeExample.ts`

**Purpose**: Complete workflow combining search and analysis with type-safe client methods

**What it demonstrates**:

- Real-world workflow: search → analyze → detailed lookup using unified client interface
- Cross-referencing data from multiple searches with type-safe methods
- Statistical analysis of tour data using typed responses
- Year-over-year comparisons with consistent API patterns
- Advanced data processing and presentation using clean client methods
- Rate limiting behavior with complex workflows and automatic protection
- Integration of `client.searchSetlists()` and `client.getSetlist()` methods

**Run it**:

```bash
pnpm dlx tsx examples/setlists/completeExample.ts
```

**Key features**: Shows production-ready workflows (4 total requests) with comprehensive analysis using the new type-safe client API.

### 4. `advancedAnalysis.ts`

**Purpose**: Advanced data analysis and statistics with type-safe client methods

**What it demonstrates**:

- Multi-year tour data collection using `client.searchSetlists()` with year parameters
- Geographic analysis (countries, cities, venues) from typed API responses
- Song frequency and popularity analysis using `client.getSetlist()` for detailed data
- Cover song and guest appearance tracking with full type safety
- Temporal pattern analysis (monthly, yearly trends) from structured data
- Venue repeat analysis and statistics with typed responses
- Complex data aggregation and statistics using clean client methods
- Large-scale data processing techniques with automatic rate limiting protection

**Run it**:

```bash
pnpm dlx tsx examples/setlists/advancedAnalysis.ts
```

**Key features**: Demonstrates enterprise-scale data analysis (12+ total requests) with comprehensive statistics using type-safe methods and automatic rate limiting.

## Example Output

When you run these examples, you'll see formatted output with:

- 🔍 Search operations and criteria with type-safe parameter validation
- ✅ Successful data retrieval confirmations using clean client methods
- 📄 Pagination and result summaries with typed responses
- 🎵 Detailed setlist information with song lists and full type safety
- 📊 Statistical analysis and data insights from structured API responses
- 🗺️ Geographic and venue analysis using typed venue and city data
- 🎯 Song frequency and popularity metrics with type-safe processing
- 📅 Temporal patterns and touring trends from date-structured data
- 📊 Rate limiting information and tracking throughout workflows
- ❌ Error handling demonstrations with typed error responses

## Code Structure

Each example follows a consistent pattern using the high-level client with automatic rate limiting:

```typescript
import { createSetlistFMClient } from "../../src/client";
import "dotenv/config";

async function exampleFunction(): Promise<void> {
  // Create SetlistFM client with automatic STANDARD rate limiting
  const client = createSetlistFMClient({
    apiKey: process.env.SETLISTFM_API_KEY!,
    userAgent: "setlistfm-ts-examples (github.com/tkozzer/setlistfm-ts)",
  });

  try {
    // Use type-safe client methods directly
    const setlist = await client.getSetlist("setlist-id");

    const searchResults = await client.searchSetlists({
      artistName: "Artist Name",
      year: 2023,
    });

    // Display rate limiting information
    const rateLimitStatus = client.getRateLimitStatus();
    console.log(`Profile: ${rateLimitStatus.profile}`);
    console.log(`Requests: ${rateLimitStatus.requestsThisSecond}/${rateLimitStatus.secondLimit}`);
  }
  catch (error) {
    // Error handling with typed responses
  }
}
```

## Learning Path

We recommend running the examples in this order:

1. **Start with `basicSetlistLookup.ts`** - Learn setlist data structure and basic retrieval using type-safe methods
2. **Try `searchSetlists.ts`** - Understand search capabilities and filtering options with full type safety
3. **Explore `completeExample.ts`** - See integrated workflows and data analysis using clean client methods
4. **Run `advancedAnalysis.ts`** - Learn advanced data processing and statistics with type-safe API calls

## Data Types

The examples work with these core setlist data types with full type safety:

### Setlist Structure

```typescript
type Setlist = {
  artist: Artist; // Performing artist information
  venue: Venue; // Venue and location details
  tour?: Tour; // Tour information (optional)
  set: Set[]; // Array of sets (main set, encores)
  info?: string; // Additional concert information
  url: string; // Attribution URL to setlist.fm
  id: string; // Unique setlist identifier
  versionId: string; // Version identifier for edits
  eventDate: string; // Date in dd-MM-yyyy format
  lastUpdated: string; // Last modification timestamp
};
```

### Set and Song Structure

```typescript
type Set = {
  name?: string; // Set name/description
  encore?: number; // Encore number (if applicable)
  song: Song[]; // Array of songs in the set
};

type Song = {
  name: string; // Song title
  with?: Artist; // Guest artist (if any)
  cover?: Artist; // Original artist (for covers)
  info?: string; // Special performance notes
  tape: boolean; // True if from tape/backing track
};
```

## Search Capabilities

The search examples demonstrate various filtering options with full type safety:

- **Artist**: Search by name or MusicBrainz ID using `client.searchSetlists({ artistName: "..." })`
- **Geographic**: Filter by country, state, city, or venue with typed parameters
- **Temporal**: Search by specific date or year using validated date formats
- **Tour**: Filter by tour name with string parameter validation
- **Pagination**: Navigate through large result sets using clean pagination parameters

## Rate Limiting Features

All examples demonstrate:

- **Automatic rate limiting**: STANDARD profile (2 req/sec, 1440 req/day) applied by default
- **Real-time tracking**: See current request counts and limits throughout workflows
- **Transparent handling**: Rate limiting works behind the scenes with type-safe methods
- **Status information**: Examples show current rate limit status after each API call

To use different rate limiting profiles:

```typescript
// Premium rate limiting (16 req/sec, 50,000 req/day)
const premiumClient = createSetlistFMClient({
  apiKey: process.env.SETLISTFM_API_KEY!,
  userAgent: "your-app-name",
  rateLimit: { profile: RateLimitProfile.PREMIUM }
});

// Disable rate limiting (advanced users only)
const unlimitedClient = createSetlistFMClient({
  apiKey: process.env.SETLISTFM_API_KEY!,
  userAgent: "your-app-name",
  rateLimit: { profile: RateLimitProfile.DISABLED }
});
```

## Analysis Features

The advanced examples show how to analyze data with full type safety:

- **Geographic Analysis**: Track touring patterns across countries, states, and cities using typed venue data
- **Venue Analysis**: Identify frequently played venues and repeat locations with structured responses
- **Song Statistics**: Calculate song frequency, popularity, and performance rates using typed song data
- **Cover Analysis**: Track cover songs and original artists with type-safe processing
- **Guest Tracking**: Monitor guest appearances and collaborations using structured guest data
- **Temporal Patterns**: Analyze touring seasons and year-over-year trends from date-structured responses
- **Show Metrics**: Calculate average show lengths and set structures using typed setlist data

## Error Handling

All examples include comprehensive error handling demonstrating:

- Validation errors (invalid setlist IDs, search parameters) with typed error responses
- API errors (authentication, rate limiting, not found) with structured error handling
- Network errors (connection issues, timeouts) with graceful degradation
- Data processing errors (malformed responses) with type-safe error checking
- Expected vs unexpected error scenarios with comprehensive error types

## Performance Considerations

The examples demonstrate best practices for:

- **Efficient pagination**: Handling large result sets with type-safe pagination parameters
- **Rate limit respect**: Staying within API limits using automatic protection
- **Data aggregation**: Processing multiple API responses with typed data structures
- **Memory management**: Handling large datasets with efficient typed processing
- **Error recovery**: Graceful handling of failed requests with typed error responses

## Real-World Applications

These examples provide patterns for building:

- **Tour analysis tools**: Track artist touring patterns and statistics using type-safe methods
- **Setlist databases**: Collect and analyze performance data with structured responses
- **Music research**: Study song popularity and performance trends using typed data processing
- **Fan applications**: Provide setlist search and discovery features with clean client methods
- **Statistical analysis**: Generate insights from concert data using type-safe analytics

## Type-Safe Client Benefits

The new client API provides several advantages:

### Clean Method Calls

**Before** (old endpoint approach):

```typescript
import { getSetlist, searchSetlists } from "../../src/endpoints/setlists";

const httpClient = client.getHttpClient();
const setlist = await getSetlist(httpClient, "setlist-id");
const results = await searchSetlists(httpClient, { artistName: "..." });
```

**After** (new type-safe client):

```typescript
// No imports needed, no HTTP client management
const setlist = await client.getSetlist("setlist-id");
const results = await client.searchSetlists({ artistName: "..." });
```

### Full Type Safety

- **Parameter validation**: IDE shows valid parameter names and types
- **Response typing**: Full autocomplete for response data structures
- **Error handling**: Typed error responses with specific error information
- **Method discovery**: IDE autocomplete shows all available methods

### Consistent Interface

- **Unified patterns**: All methods follow the same calling convention
- **Predictable naming**: Method names directly correspond to API operations
- **Rate limiting**: Automatic protection applied consistently across all methods
- **Error handling**: Consistent error response format across all endpoints

## References

- [setlist.fm API: GET /1.0/setlist/{setlistId}](https://api.setlist.fm/docs/1.0/resource__1.0_setlist__setlistId_.html)
- [setlist.fm API: GET /1.0/search/setlists](https://api.setlist.fm/docs/1.0/resource__1.0_search_setlists.html)
- [setlist.fm API Documentation](https://api.setlist.fm/docs/1.0/index.html)
- [Type-Safe Client Documentation](../../src/client.ts)
- [Rate Limiting Guide](../../src/utils/rateLimiter.ts)
