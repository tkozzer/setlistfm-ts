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

## Available Examples

### 1. `basicArtistLookup.ts`

**Purpose**: Basic artist lookup by MusicBrainz MBID

**What it demonstrates**:

- Creating an HTTP client with API credentials
- Looking up an artist using their MBID
- Handling and displaying artist information
- Basic error handling

**Run it**:

```bash
pnpm dlx tsx examples/artists/basicArtistLookup.ts
```

### 2. `searchArtists.ts`

**Purpose**: Comprehensive artist search functionality

**What it demonstrates**:

- Searching artists by name
- Using pagination and sorting parameters
- Searching by MBID for validation
- Handling empty search results
- Processing search result data

**Run it**:

```bash
pnpm dlx tsx examples/artists/searchArtists.ts
```

### 3. `getArtistSetlists.ts`

**Purpose**: Retrieving and analyzing artist setlists

**What it demonstrates**:

- Getting paginated setlist data for an artist
- Navigating through multiple pages of results
- Analyzing setlist data (venues, countries, years)
- Working with complex nested data structures

**Run it**:

```bash
pnpm dlx tsx examples/artists/getArtistSetlists.ts
```

### 4. `completeExample.ts`

**Purpose**: Complete workflow using all artist endpoints

**What it demonstrates**:

- Real-world workflow: search → get details → get setlists
- Data analysis and statistics
- Combining multiple API calls
- Advanced data processing and presentation

**Run it**:

```bash
pnpm dlx tsx examples/artists/completeExample.ts
```

## Example Output

When you run these examples, you'll see formatted output with:

- 🔍 Search operations and results
- ✅ Successful data retrieval confirmations
- 📄 Pagination information
- 🎵 Setlist and performance data
- 📊 Statistical analysis
- ❌ Error handling demonstrations

## Code Structure

Each example follows a consistent pattern:

```typescript
import { /* endpoint functions */ } from "../../src/endpoints/artists";
import { HttpClient } from "../../src/utils/http";
import "dotenv/config";

async function exampleFunction(): Promise<void> {
  const httpClient = new HttpClient({
    // eslint-disable-next-line node/no-process-env
    apiKey: process.env.SETLISTFM_API_KEY!,
    userAgent: "setlistfm-ts-examples (github.com/tkozzer/setlistfm-ts)",
  });

  try {
    // Example implementation
  }
  catch (error) {
    // Error handling
  }
}
```

## Learning Path

We recommend running the examples in this order:

1. **Start with `basicArtistLookup.ts`** - Learn the fundamentals
2. **Try `searchArtists.ts`** - Understand search capabilities
3. **Explore `getArtistSetlists.ts`** - Work with complex data
4. **Run `completeExample.ts`** - See everything working together

## Error Handling

All examples include comprehensive error handling demonstrating:

- Validation errors (invalid MBIDs, missing parameters)
- API errors (authentication, rate limiting, not found)
- Network errors (connection issues, timeouts)

## Data Analysis Features

The examples show practical data analysis techniques:

- Counting unique venues, cities, and countries
- Sorting performances by date
- Grouping setlists by year
- Statistical summaries and trends

## Real API Data

These examples use real data from the setlist.fm API, including:

- **The Beatles** (`b10bbbfc-cf9e-42e0-be17-e2c3e1d2600d`) - for basic lookup
- **Radiohead** - for search examples
- **Pink Floyd** - for comprehensive analysis

## Troubleshooting

**API Key Issues**:

- Ensure your `.env` file is in the project root
- Verify your API key is correct and active
- Check that `SETLISTFM_API_KEY` matches exactly

**Rate Limiting**:

- The examples include built-in delays between requests
- If you get rate limit errors, wait a few minutes before retrying

**Network Issues**:

- Ensure you have an active internet connection
- Check if setlist.fm is accessible from your network

## Next Steps

After exploring these examples:

1. Try modifying the search terms and MBIDs
2. Experiment with different pagination parameters
3. Add your own data analysis logic
4. Integrate the patterns into your own applications

## Related Documentation

- [Artist Endpoints Documentation](../../src/endpoints/artists/README.md)
- [setlist.fm API Documentation](https://api.setlist.fm/docs/1.0/index.html)
- [MusicBrainz MBID Reference](http://wiki.musicbrainz.org/MBID)
