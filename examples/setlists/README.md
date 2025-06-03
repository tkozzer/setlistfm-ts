# Setlist Endpoints Examples

This directory contains practical examples demonstrating how to use the setlistfm-ts setlist endpoints.

## Prerequisites

Before running these examples, you need:

1. **API Key**: Get a free API key from [setlist.fm](https://api.setlist.fm/docs/1.0/index.html)
2. **Environment Setup**: Create a `.env` file in the project root with your API key

### Environment Setup

Create a `.env` file in the project root (`setlistfm-ts/.env`):

```env
SETLISTFM_API_KEY=your-api-key-here
```

## Rate Limiting

All examples automatically use **STANDARD rate limiting** (2 requests/second, 1440 requests/day) by default. This protects you from accidentally hitting API rate limits while exploring the examples.

The examples display rate limiting information to help you understand current usage:

- Profile type (standard, premium, or disabled)
- Requests made in the current second and daily limits
- Real-time tracking of API usage

## Available Examples

### 1. `basicSetlistLookup.ts`

**Purpose**: Basic setlist retrieval by ID

**What it demonstrates**:

- Creating a SetlistFM client with default rate limiting
- Looking up a specific setlist using its ID
- Parsing and displaying setlist information
- Working with sets, songs, and venue data
- Handling song metadata (covers, guest appearances, tape)
- Viewing rate limiting status
- Basic error handling

**Run it**:

```bash
pnpm dlx tsx examples/setlists/basicSetlistLookup.ts
```

### 2. `searchSetlists.ts`

**Purpose**: Comprehensive setlist search functionality

**What it demonstrates**:

- Searching setlists by artist name
- Filtering by venue, city, and year
- Using specific date searches
- Handling pagination with multiple pages
- Processing and grouping search results
- Working with complex search criteria
- Rate limiting with multiple API calls

**Run it**:

```bash
pnpm dlx tsx examples/setlists/searchSetlists.ts
```

### 3. `completeExample.ts`

**Purpose**: Complete workflow combining search and analysis

**What it demonstrates**:

- Real-world workflow: search → analyze → detailed lookup
- Cross-referencing data from multiple searches
- Statistical analysis of tour data
- Year-over-year comparisons
- Advanced data processing and presentation
- Rate limiting behavior with complex workflows

**Run it**:

```bash
pnpm dlx tsx examples/setlists/completeExample.ts
```

### 4. `advancedAnalysis.ts`

**Purpose**: Advanced data analysis and statistics

**What it demonstrates**:

- Multi-year tour data collection
- Geographic analysis (countries, cities, venues)
- Song frequency and popularity analysis
- Cover song and guest appearance tracking
- Temporal pattern analysis (monthly, yearly trends)
- Venue repeat analysis
- Complex data aggregation and statistics
- Large-scale data processing techniques

**Run it**:

```bash
pnpm dlx tsx examples/setlists/advancedAnalysis.ts
```

## Example Output

When you run these examples, you'll see formatted output with:

- 🔍 Search operations and criteria
- ✅ Successful data retrieval confirmations
- 📄 Pagination and result summaries
- 🎵 Detailed setlist information with song lists
- 📊 Statistical analysis and data insights
- 🗺️ Geographic and venue analysis
- 🎯 Song frequency and popularity metrics
- 📅 Temporal patterns and touring trends
- 📊 Rate limiting information and tracking
- ❌ Error handling demonstrations

## Code Structure

Each example follows a consistent pattern using the high-level client with automatic rate limiting:

```typescript
import { createSetlistFMClient } from "../../src/client";
import { getSetlist, searchSetlists } from "../../src/endpoints/setlists";
import "dotenv/config";

async function exampleFunction(): Promise<void> {
  // Create SetlistFM client with automatic STANDARD rate limiting
  const client = createSetlistFMClient({
    apiKey: process.env.SETLISTFM_API_KEY!,
    userAgent: "setlistfm-ts-examples (github.com/tkozzer/setlistfm-ts)",
  });

  // Get the HTTP client for making requests
  const httpClient = client.getHttpClient();

  try {
    // Example implementation with API calls
    const setlist = await getSetlist(httpClient, "setlist-id");

    const searchResults = await searchSetlists(httpClient, {
      artistName: "Artist Name",
      year: 2023,
    });

    // Display rate limiting information
    const rateLimitStatus = client.getRateLimitStatus();
    console.log(`Profile: ${rateLimitStatus.profile}`);
    console.log(`Requests: ${rateLimitStatus.requestsThisSecond}/${rateLimitStatus.secondLimit}`);
  }
  catch (error) {
    // Error handling
  }
}
```

## Learning Path

We recommend running the examples in this order:

1. **Start with `basicSetlistLookup.ts`** - Learn setlist data structure and basic retrieval
2. **Try `searchSetlists.ts`** - Understand search capabilities and filtering options
3. **Explore `completeExample.ts`** - See integrated workflows and data analysis
4. **Run `advancedAnalysis.ts`** - Learn advanced data processing and statistics

## Data Types

The examples work with these core setlist data types:

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

The search examples demonstrate various filtering options:

- **Artist**: Search by name or MusicBrainz ID
- **Geographic**: Filter by country, state, city, or venue
- **Temporal**: Search by specific date or year
- **Tour**: Filter by tour name
- **Pagination**: Navigate through large result sets

## Rate Limiting Features

All examples demonstrate:

- **Automatic rate limiting**: STANDARD profile (2 req/sec, 1440 req/day) applied by default
- **Real-time tracking**: See current request counts and limits
- **Transparent handling**: Rate limiting works behind the scenes
- **Status information**: Examples show current rate limit status

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

The advanced examples show how to:

- **Geographic Analysis**: Track touring patterns across countries, states, and cities
- **Venue Analysis**: Identify frequently played venues and repeat locations
- **Song Statistics**: Calculate song frequency, popularity, and performance rates
- **Cover Analysis**: Track cover songs and original artists
- **Guest Tracking**: Monitor guest appearances and collaborations
- **Temporal Patterns**: Analyze touring seasons and year-over-year trends
- **Show Metrics**: Calculate average show lengths and set structures

## Error Handling

All examples include comprehensive error handling demonstrating:

- Validation errors (invalid setlist IDs, search parameters)
- API errors (authentication, rate limiting, not found)
- Network errors (connection issues, timeouts)
- Data processing errors (malformed responses)
- Expected vs unexpected error scenarios

## Performance Considerations

The examples demonstrate best practices for:

- **Efficient pagination**: Handling large result sets
- **Rate limit respect**: Staying within API limits
- **Data aggregation**: Processing multiple API responses
- **Memory management**: Handling large datasets
- **Error recovery**: Graceful handling of failed requests

## Real-World Applications

These examples provide patterns for building:

- **Tour analysis tools**: Track artist touring patterns and statistics
- **Setlist databases**: Collect and analyze performance data
- **Music research**: Study song popularity and performance trends
- **Fan applications**: Provide setlist search and discovery features
- **Statistical analysis**: Generate insights from concert data

## References

- [setlist.fm API: GET /1.0/setlist/{setlistId}](https://api.setlist.fm/docs/1.0/resource__1.0_setlist__setlistId_.html)
- [setlist.fm API: GET /1.0/search/setlists](https://api.setlist.fm/docs/1.0/resource__1.0_search_setlists.html)
- [setlist.fm API Documentation](https://api.setlist.fm/docs/1.0/index.html)
