# Cities Endpoints Examples

This directory contains practical examples demonstrating how to use the setlistfm-ts cities endpoints with automatic rate limiting protection.

## Prerequisites

Before running these examples, you need:

1. **API Key**: Get a free API key from [setlist.fm](https://api.setlist.fm/docs/1.0/index.html)
2. **Environment Setup**: Create a `.env` file in the project root with your API key

### Environment Setup

Create a `.env` file in the project root (`setlistfm-ts/.env`):

```env
SETLISTFM_API_KEY=your-api-key-here
```

## Rate Limiting Protection

All examples use the new `createSetlistFMClient` which automatically applies **STANDARD rate limiting** (2 requests/second, 1440 requests/day) to protect against accidental API limit violations. The examples display real-time rate limiting status showing:

- Current rate limit profile (STANDARD by default)
- Requests made this second vs. limit
- Requests made today vs. daily limit
- Queue status and retry timing

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

### 1. `basicCityLookup.ts`

**Purpose**: Basic city search and lookup workflow with rate limiting demonstrations

**What it demonstrates**:

- Creating a SetlistFM client with automatic STANDARD rate limiting
- Real-time rate limiting status monitoring
- Searching for cities by name and then looking up specific ones
- Finding specific cities (Paris, London, New York, Los Angeles)
- Handling and displaying city information
- Working with coordinates and geographic data
- Rate limit protection in action (shows 429 errors when limits hit)
- Basic error handling and fallback strategies

**Run it**:

```bash
pnpm dlx tsx examples/cities/basicCityLookup.ts
```

**Key features**: Shows rate limiting in action - demonstrates how STANDARD profile protects against hitting API limits.

### 2. `searchCities.ts`

**Purpose**: Comprehensive city search functionality with rate limiting awareness

**What it demonstrates**:

- Rate limiting status throughout multiple search operations
- Searching cities by name, country code, state, and state code
- Using proper ISO country codes (DE, GB, US) for filtering
- Using pagination parameters with rate limiting consideration
- Combining multiple search criteria efficiently
- Handling empty search results and 404 responses
- Processing search result data with rate limiting protection
- Geographic data analysis within rate limits

**Run it**:

```bash
pnpm dlx tsx examples/cities/searchCities.ts
```

**Key features**: Shows how rate limiting affects multi-request workflows and pagination strategies.

### 3. `completeExample.ts`

**Purpose**: Complete workflow using all cities endpoints with advanced data analysis and rate limiting management

**What it demonstrates**:

- Real-world workflow: search → analyze → lookup details with rate limiting
- Multi-page data collection with intelligent pagination and rate limiting
- Rate limiting status tracking during complex workflows
- Geographic data analysis and statistics with 133 London cities
- Combining multiple API calls efficiently within rate limits
- Advanced data processing and visualization (7 countries, 20 states/provinces)
- Cross-country city comparisons with rate limiting awareness
- Smart request pacing and queue management

**Run it**:

```bash
pnpm dlx tsx examples/cities/completeExample.ts
```

**Key features**: Demonstrates production-ready workflows that respect rate limits while processing large datasets (133 cities across 7 countries).

## Example Output

When you run these examples, you'll see formatted output with:

- 📊 **Rate limiting status**: Shows profile, current usage, and limits
- 🔍 Search operations and city discovery
- ✅ Successful data retrieval confirmations
- 📄 Pagination information and navigation
- 🌍 Geographic and location data
- 📊 Statistical analysis and summaries
- 🗺️ Coordinate analysis and geographic insights
- ⚠️ Rate limiting demonstrations (429 errors when appropriate)
- ❌ Error handling demonstrations

## Code Structure

Each example follows a consistent pattern with automatic rate limiting:

```typescript
import { createSetlistFMClient } from "../../src/client";
import { getCityByGeoId, searchCities } from "../../src/endpoints/cities";
import "dotenv/config";

async function exampleFunction(): Promise<void> {
  // Create client with automatic STANDARD rate limiting
  const client = createSetlistFMClient({

    apiKey: process.env.SETLISTFM_API_KEY!,
    userAgent: "setlistfm-ts-examples (github.com/tkozzer/setlistfm-ts)",
  });

  // Get HTTP client for endpoint functions
  const httpClient = client.getHttpClient();

  try {
    // Display rate limiting status
    const status = client.getRateLimitStatus();

    console.log(`📊 Rate Limiting: ${status.profile.toUpperCase()} profile`);

    console.log(`📈 Requests: ${status.requestsThisSecond}/${status.secondLimit} this second`);

    // Example implementation with rate limiting protection
    const results = await searchCities(httpClient, { name: "Paris" });

    // Show updated rate limiting status
    const updated = client.getRateLimitStatus();

    console.log(`📊 After request: ${updated.requestsThisSecond}/${updated.secondLimit} requests`);
  }
  catch (error) {
    // Error handling including rate limit errors
  }
}
```

## Learning Path

We recommend running the examples in this order:

1. **Start with `basicCityLookup.ts`** - Learn the fundamentals of city lookup and see rate limiting in action
2. **Try `searchCities.ts`** - Understand search capabilities and rate limiting during multiple requests
3. **Explore `completeExample.ts`** - See advanced workflows and data analysis with intelligent rate limiting

## Key Features Demonstrated

### Rate Limiting Protection

The examples show the new automatic rate limiting features:

- **Default STANDARD profile**: 2 requests/second, 1440 requests/day
- **Real-time monitoring**: Current usage vs. limits displayed
- **Automatic protection**: Prevents accidental API limit violations
- **Queue management**: Handles request pacing automatically
- **Status tracking**: Shows rate limiting throughout workflows

### Geographic Data Handling

The examples show how to work with:

- **Coordinates**: Latitude and longitude processing
- **State codes**: Understanding regional identifiers
- **Country codes**: ISO standard country identification
- **Geographic analysis**: Distance, extremes, and distribution

### Search Capabilities

Learn about the flexible search options:

- **Name searches**: Find cities by partial or exact names
- **Geographic filters**: Search by country code (DE, GB, US), state, or state code
- **Combined criteria**: Use multiple parameters together
- **Pagination**: Navigate through large result sets efficiently

### Data Analysis Techniques

The examples demonstrate:

- Collecting data across multiple pages with rate limiting
- Grouping and categorizing results efficiently
- Statistical analysis of geographic data
- Coordinate range and distribution analysis
- Cross-referencing between search and lookup operations

## Error Handling

All examples include comprehensive error handling for:

- **Rate limiting errors** (429 status) - demonstrates protection working
- Validation errors (invalid geoIds, missing parameters)
- API errors (authentication, not found)
- Network errors (connection issues, timeouts)
- Data processing errors

## Real Geographic Data

These examples use real cities from the setlist.fm database, including:

- **Paris cities worldwide** (184 total) - for search and lookup demonstrations
- **London variations** (133 total) - for international city analysis across 7 countries
- **Major music cities** - Nashville, Austin, Los Angeles, New York
- **Country-specific searches** - Germany (5064 cities), UK (3329 cities), US (10000+ cities)
- **Regional examples** - California (936 cities), New York state (920 cities)

## Performance Considerations

The examples include:

- **Automatic rate limiting**: Built-in protection against API limits
- **Smart pagination**: Efficient data collection with rate limiting awareness
- **Request pacing**: Intelligent delays and queue management
- **Memory management**: Efficient data collection and processing
- **API courtesy**: Automatic rate limiting ensures respectful API usage

## Geographic Insights

Through these examples with rate limiting protection, you'll discover:

- How many cities share common names worldwide (133 Londons across 7 countries)
- Geographic distribution patterns (108 London cities in England alone)
- Coordinate system understanding with real data
- State and country code relationships
- International location data variations

## Troubleshooting

**API Key Issues**:

- Ensure your `.env` file is in the project root
- Verify your API key is correct and active
- Check that `SETLISTFM_API_KEY` matches exactly

**Rate Limiting** (Expected Behavior):

- Examples show rate limiting in action with 429 errors
- This demonstrates the STANDARD profile protection working correctly
- Rate limiting prevents accidental API abuse
- Wait a few seconds between runs if testing multiple examples
- Consider using PREMIUM profile for higher limits if you have access

**Geographic Data Issues**:

- Some cities may have unusual coordinate formats
- State codes vary by country and may be numeric or alpha
- Not all cities have complete geographic information
- Use ISO country codes (DE, GB, US) instead of full country names

**Search Tips**:

- Paris searches return 184 cities worldwide, not just Paris, France
- London searches return 133 cities across 7 countries
- Use country codes to filter by specific countries
- Combine name + country code for more precise results

**Network Issues**:

- Ensure you have an active internet connection
- Check if setlist.fm is accessible from your network
- Verify DNS resolution for api.setlist.fm

## Extending the Examples

Try these modifications to learn more:

1. **Search for your hometown** - Modify city names in the examples
2. **Analyze different countries** - Change country filters
3. **Add distance calculations** - Implement geographic distance functions
4. **Create city statistics** - Build your own data analysis
5. **Export data to files** - Save results as JSON or CSV
6. **Test rate limiting** - Try PREMIUM or DISABLED profiles

## Next Steps

After exploring these examples:

1. Try searching for cities in your region
2. Experiment with different geographic filters
3. Build your own city analysis tools with rate limiting
4. Integrate city data with venue or setlist information
5. Create geographic visualizations of music data
6. Understand how rate limiting affects your application design

## Integration Possibilities

Cities data can be combined with other setlist.fm endpoints:

- **Venues**: Find venues in specific cities
- **Setlists**: Analyze performance locations
- **Artists**: Track artist touring patterns
- **Geographic analysis**: Map music scenes by location

All while benefiting from automatic rate limiting protection!

## Related Documentation

- [Cities Endpoints Documentation](../../src/endpoints/cities/README.md)
- [Rate Limiting Documentation](../../src/utils/rateLimiter.ts)
- [setlist.fm API Documentation](https://api.setlist.fm/docs/1.0/index.html)
- [GeoNames Database](http://geonames.org/)
- [ISO 3166-1 Country Codes](https://en.wikipedia.org/wiki/ISO_3166-1)
