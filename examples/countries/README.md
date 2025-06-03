# Countries Endpoints Examples

This directory contains practical examples demonstrating how to use the setlistfm-ts countries endpoints with automatic rate limiting protection.

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

### 1. `basicCountriesLookup.ts`

**Purpose**: Basic countries retrieval and data exploration with rate limiting demonstrations

**What it demonstrates**:

- Creating a SetlistFM client with automatic STANDARD rate limiting
- Real-time rate limiting status monitoring
- Retrieving the complete list of supported countries (250 total)
- Finding specific countries by country code
- Analyzing country data (name lengths, regional groupings)
- Sorting and filtering country information
- Working with ISO 3166-1 alpha-2 country codes
- Rate limiting protection during single endpoint usage
- Basic error handling and data validation

**Run it**:

```bash
pnpm dlx tsx examples/countries/basicCountriesLookup.ts
```

**Key features**: Shows rate limiting status with minimal API calls (1 request total), demonstrates data quality with 250 countries.

### 2. `countriesAnalysis.ts`

**Purpose**: Comprehensive countries data analysis and integration with rate limiting awareness

**What it demonstrates**:

- Rate limiting status throughout multiple API operations
- Advanced data analysis and statistical insights (250 countries analyzed)
- Regional country groupings and geographic analysis (6 regions, 100% coverage)
- Integration with cities endpoint for cross-reference data (26,961 cities across 7 countries)
- Performance measurement and optimization insights
- Localization and international naming patterns
- Real-world data processing with rate limiting consideration
- Multi-endpoint API integration patterns with rate protection

**Run it**:

```bash
pnpm dlx tsx examples/countries/countriesAnalysis.ts
```

**Key features**: Shows rate limiting during complex workflows (8 total requests), demonstrates production-scale data analysis.

### 3. `completeExample.ts`

**Purpose**: Production-ready workflow with comprehensive testing, validation, and rate limiting management

**What it demonstrates**:

- Complete countries API workflow from basic to advanced usage with rate limiting
- Data quality validation and integrity checks (100% valid country codes)
- Performance monitoring and optimization strategies (170ms fetch time)
- Integration testing with other API endpoints (5/5 successful cities tests)
- Practical use cases for country data (validation, lookup, mapping)
- Error handling and resilience patterns with rate limiting awareness
- Production-ready code patterns and best practices
- Comprehensive data analysis with statistical insights and rate limiting management

**Run it**:

```bash
pnpm dlx tsx examples/countries/completeExample.ts
```

**Key features**: Demonstrates enterprise-ready workflows with rate limiting (6 total requests), shows 23,850 cities integration across 5 countries.

## Example Output

When you run these examples, you'll see formatted output with:

- 📊 **Rate limiting status**: Shows profile, current usage, and limits
- 🔍 Data retrieval operations and results
- ✅ Successful validation confirmations
- 📊 Statistical analysis and insights
- 🌍 Geographic data and regional information
- 🏙️ Integration testing with cities endpoint
- ⚡ Performance metrics and optimization tips
- ⚠️ Rate limiting demonstrations (status throughout workflow)
- ❌ Error handling demonstrations
- 🎯 Practical use case implementations

## Code Structure

Each example follows a consistent pattern with automatic rate limiting:

```typescript
import { createSetlistFMClient } from "../../src/client";
import { searchCountries } from "../../src/endpoints/countries";
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
    const countries = await searchCountries(httpClient);

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

1. **Start with `basicCountriesLookup.ts`** - Learn the fundamentals of countries data retrieval and see rate limiting in action
2. **Try `countriesAnalysis.ts`** - Understand advanced analysis and rate limiting during multiple requests
3. **Explore `completeExample.ts`** - See production-ready patterns and comprehensive workflows with intelligent rate limiting

## Key Features Demonstrated

### Rate Limiting Protection

The examples show the new automatic rate limiting features:

- **Default STANDARD profile**: 2 requests/second, 1440 requests/day
- **Real-time monitoring**: Current usage vs. limits displayed throughout workflows
- **Automatic protection**: Prevents accidental API limit violations
- **Queue management**: Handles request pacing automatically
- **Status tracking**: Shows rate limiting impact on multi-request workflows

### Country Code Management

The examples show how to work with:

- **ISO 3166-1 alpha-2 codes**: Standard two-letter country codes (US, GB, DE, etc.)
- **Code validation**: Ensuring country codes follow proper format and exist
- **Code-to-name mapping**: Building efficient lookup tables for O(1) access
- **Regional groupings**: Organizing countries by geographic or political regions

### Data Analysis Techniques

Learn about comprehensive data analysis with rate limiting:

- Statistical analysis of country names and codes (250 countries total)
- Regional coverage and geographic distribution (100% coverage across 6 regions)
- Performance measurement and optimization (170ms fetch times)
- Data quality validation and integrity checks (100% valid data)
- Cross-endpoint integration and correlation with rate limiting awareness

### Integration Capabilities

The examples demonstrate:

- **Cities integration**: Using country codes to filter city searches (26,961 cities tested)
- **Cross-reference validation**: Ensuring data consistency across endpoints
- **Multi-endpoint workflows**: Building complex applications with multiple API calls
- **Performance optimization**: Caching strategies and efficient data access patterns

## Error Handling

All examples include comprehensive error handling for:

- **Rate limiting errors** (429 status) - demonstrates protection working
- API authentication errors (invalid API key)
- Network connectivity issues
- Data validation errors
- API response parsing errors
- Timeout and connection errors

## Real Country Data

These examples use real data from the setlist.fm API, including:

- **Complete country list** - All 250 countries supported by setlist.fm
- **ISO standard codes** - Proper ISO 3166-1 alpha-2 country codes (100% valid)
- **Localized names** - Country names that may vary by language/locale
- **Regional analysis** - Real geographic and political groupings (EU: 27 countries, G7: 7 countries, NATO: 30 countries)
- **Integration data** - Actual city counts (US: 10,000 cities, DE: 5,064 cities, FR: 4,230 cities)

## Performance Considerations

The examples include:

- **Automatic rate limiting**: Built-in protection against API limits
- **Response time measurement**: Tracking API call performance (170ms average)
- **Caching strategies**: Recommendations for optimizing repeated access
- **Memory efficiency**: Best practices for handling country data
- **Rate limiting compliance**: Respectful API usage patterns
- **Optimization insights**: Performance tuning recommendations

## API Characteristics

Through these examples with rate limiting protection, you'll understand:

- **Endpoint behavior**: How the `/search/countries` endpoint works
- **Response structure**: Complete dataset in single response (250 countries)
- **Parameter handling**: Why this endpoint accepts no query parameters
- **Data consistency**: Reliability and stability of country data
- **Integration patterns**: How countries relate to other endpoints
- **Rate limiting impact**: How protection affects workflow design

## Use Cases Demonstrated

### 1. Country Code Validation

```typescript
// Validate if a country code exists
const validCodes = new Set(countries.map(c => c.code));
const isValid = validCodes.has("US"); // true
const isInvalid = validCodes.has("XX"); // false
```

### 2. Country Name Lookup

```typescript
// Build efficient lookup table
const countryMap = new Map(countries.map(c => [c.code, c.name]));
const name = countryMap.get("GB"); // "United Kingdom"
```

### 3. Regional Filtering

```typescript
// Filter countries by region
const europeanCodes = ["GB", "DE", "FR", "IT", "ES"];
const europeanCountries = countries.filter(c => europeanCodes.includes(c.code));
```

### 4. Cities Integration

```typescript
// Use country codes for city searches with rate limiting
const germanCities = await searchCities(httpClient, {
  country: "DE",
  p: 1
});
```

## Troubleshooting

**API Key Issues**:

- Ensure your `.env` file is in the project root
- Verify your API key is correct and active
- Check that `SETLISTFM_API_KEY` matches exactly

**Rate Limiting** (Expected Behavior):

- Examples show rate limiting in action with status updates
- This demonstrates the STANDARD profile protection working correctly
- Rate limiting prevents accidental API abuse
- Wait a few seconds between runs if testing multiple examples
- Consider using PREMIUM profile for higher limits if you have access

**Network Issues**:

- Ensure you have an active internet connection
- Check if setlist.fm is accessible from your network
- Verify firewall settings allow HTTPS connections

**Data Issues**:

- Countries data is relatively static but can change
- Consider implementing cache invalidation strategies
- Monitor for API response format changes

## Optimization Tips

**Caching Strategies**:

```typescript
// Countries data changes infrequently, cache it
const CACHE_TTL = 24 * 60 * 60 * 1000; // 24 hours
let cachedCountries: Countries | null = null;
let cacheTime = 0;

if (Date.now() - cacheTime > CACHE_TTL) {
  cachedCountries = await searchCountries(httpClient);
  cacheTime = Date.now();
}
```

**Efficient Lookups**:

```typescript
// Use Map for O(1) lookups instead of Array.find()
const countryMap = new Map(countries.map(c => [c.code, c]));
const country = countryMap.get("US"); // O(1) lookup
```

**Memory Management**:

```typescript
// Process countries in chunks for large datasets
function processInChunks(countries: Country[], chunkSize: number) {
  for (let i = 0; i < countries.length; i += chunkSize) {
    const chunk = countries.slice(i, i + chunkSize);
    // Process chunk
  }
}
```

## Next Steps

After exploring these examples:

1. Try modifying the regional groupings and analysis
2. Experiment with different data visualization approaches with rate limiting
3. Build your own country-based filtering and validation systems
4. Integrate country data into larger applications with rate limiting awareness
5. Implement caching and performance optimization strategies
6. Understand how rate limiting affects your application design

## Related Documentation

- [Countries Endpoints Documentation](../../src/endpoints/countries/README.md)
- [Rate Limiting Documentation](../../src/utils/rateLimiter.ts)
- [setlist.fm API Documentation](https://api.setlist.fm/docs/1.0/index.html)
- [ISO 3166-1 Country Codes](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2)
- [Cities Examples](../cities/README.md) - Learn about related city data integration
