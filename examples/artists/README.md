# Artist Endpoints Examples

This directory contains practical examples demonstrating how to use the setlistfm-ts artist endpoints.

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

- **Cleaner syntax**: `client.getArtist(mbid)` instead of `getArtist(httpClient, mbid)`
- **No HTTP client management**: Direct method calls on the client instance
- **Simplified pagination**: `client.getArtistSetlists(mbid, 2)` instead of `getArtistSetlists(httpClient, mbid, { p: 2 })`
- **Full type safety**: IDE autocompletion and type checking for all methods
- **Consistent interface**: All endpoint methods follow the same pattern

## Rate Limiting

All examples automatically use **STANDARD rate limiting** (2 requests/second, 1440 requests/day) by default. This protects you from accidentally hitting API rate limits while exploring the examples.

The examples display rate limiting information to help you understand current usage:

- Profile type (standard, premium, or disabled)
- Requests made in the current second and daily limits
- Real-time tracking of API usage

## Available Examples

### 1. `basicArtistLookup.ts`

**Purpose**: Basic artist lookup by MusicBrainz MBID

**What it demonstrates**:

- Creating a SetlistFM client with default rate limiting
- Using the type-safe `client.getArtist()` method to lookup artists by MBID
- Using the type-safe `client.searchArtists()` method to search for artists
- Handling and displaying artist information
- Viewing rate limiting status
- Basic error handling

**Run it**:

```bash
pnpm dlx tsx examples/artists/basicArtistLookup.ts
```

### 2. `searchArtists.ts`

**Purpose**: Comprehensive artist search functionality

**What it demonstrates**:

- Using the type-safe `client.searchArtists()` method with various criteria
- Using pagination and sorting parameters
- Searching by MBID for validation
- Handling empty search results and expected 404 responses
- Processing search result data
- Rate limiting information display

**Run it**:

```bash
pnpm dlx tsx examples/artists/searchArtists.ts
```

### 3. `getArtistSetlists.ts`

**Purpose**: Retrieving and analyzing artist setlists

**What it demonstrates**:

- Using the type-safe `client.getArtistSetlists()` method with pagination
- Navigating through multiple pages of results
- Analyzing setlist data (venues, countries, years)
- Working with complex nested data structures
- Performance statistics and analytics
- Rate limiting tracking with multiple API calls

**Run it**:

```bash
pnpm dlx tsx examples/artists/getArtistSetlists.ts
```

### 4. `completeExample.ts`

**Purpose**: Complete workflow using all artist endpoints

**What it demonstrates**:

- Real-world workflow using type-safe client methods: `searchArtists()` → `getArtist()` → `getArtistSetlists()`
- Data analysis and statistics across multiple API calls
- Combining multiple API calls efficiently
- Advanced data processing and presentation
- Rate limiting behavior with complex workflows

**Run it**:

```bash
pnpm dlx tsx examples/artists/completeExample.ts
```

## Example Output

When you run these examples, you'll see formatted output with:

- 🔍 Type-safe search operations and results
- ✅ Successful data retrieval confirmations
- 📄 Pagination information with clean client method calls
- 🎵 Setlist and performance data
- 📊 Statistical analysis and rate limiting information
- ❌ Error handling demonstrations

## Code Structure

Each example follows a consistent pattern using the type-safe client with automatic rate limiting:

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
    const artists = await client.searchArtists({ artistName: "Radiohead" });
    const artist = await client.getArtist("some-mbid");
    const setlists = await client.getArtistSetlists("some-mbid");
    const page2 = await client.getArtistSetlists("some-mbid", 2);

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

1. **Start with `basicArtistLookup.ts`** - Learn the type-safe client fundamentals and rate limiting
2. **Try `searchArtists.ts`** - Understand search capabilities with `client.searchArtists()` and error handling
3. **Explore `getArtistSetlists.ts`** - Work with complex data and simplified pagination using `client.getArtistSetlists()`
4. **Run `completeExample.ts`** - See all type-safe methods working together in a real workflow

## Rate Limiting Features

All examples demonstrate:

- **Type-safe API calls**: Use client methods instead of raw endpoint functions
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

// All clients use the same type-safe methods
const artists = await premiumClient.searchArtists({ artistName: "Tool" });
const setlists = await unlimitedClient.getArtistSetlists("some-mbid");
```

## Error Handling

All examples include comprehensive error handling demonstrating:

- Validation errors (invalid MBIDs, missing parameters)
- API errors (authentication, rate limiting, not found)
- Network errors (connection issues, timeouts)
- Expected 404s (no search results) vs unexpected errors

## Data Analysis Features

The examples show practical data analysis techniques using type-safe client responses:

- Counting unique venues, cities, and countries from typed setlist data
- Sorting performances by date with full type safety
- Grouping setlists by year using clean API responses
- Statistical summaries and trends with auto-completion support
- Performance analytics across different time periods

## Real API Data

These examples use real data from the setlist.fm API, including:

- **The Beatles** (`b10bbbfc-cf9e-42e0-be17-e2c3e1d2600d`) - for basic lookup
- **Radiohead** - for search examples
- **Metallica** - for search and lookup workflows
- **Pink Floyd** - for comprehensive analysis

## Troubleshooting

**API Key Issues**:

- Ensure your `.env` file is in the project root
- Verify your API key is correct and active
- Check that `SETLISTFM_API_KEY` matches exactly

**Rate Limiting**:

- The examples use automatic STANDARD rate limiting by default
- Rate limit information is displayed in example output
- If you need higher limits, consider the PREMIUM profile
- Rate limiting protects you from accidentally hitting API limits

**Network Issues**:

- Ensure you have an active internet connection
- Check if setlist.fm is accessible from your network
- Rate limiting helps prevent network timeouts from too many rapid requests

## Next Steps

After exploring these examples:

1. Try modifying the search terms and MBIDs using the type-safe client methods
2. Experiment with different pagination parameters (note the simplified `getArtistSetlists(mbid, page)` syntax)
3. Test different rate limiting profiles (PREMIUM or DISABLED)
4. Add your own data analysis logic using the clean API responses
5. Integrate the type-safe client patterns into your own applications

## Related Documentation

- [Artist Endpoints Documentation](../../src/endpoints/artists/README.md)
- [Rate Limiting Documentation](../../src/utils/rateLimiter.ts)
- [setlist.fm API Documentation](https://api.setlist.fm/docs/1.0/index.html)
- [MusicBrainz MBID Reference](http://wiki.musicbrainz.org/MBID)
