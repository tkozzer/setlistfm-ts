# Countries Endpoints Examples

This directory contains practical examples demonstrating how to use the setlistfm-ts countries endpoints with the new type-safe client.

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

- **Cleaner syntax**: `client.searchCountries()` instead of `searchCountries(httpClient)`
- **No HTTP client management**: Direct method calls on the client instance
- **Integration methods**: `client.searchCities({ country: "US" })` for cross-endpoint workflows
- **Full type safety**: IDE autocompletion and type checking for all methods
- **Consistent interface**: All endpoint methods follow the same pattern
- **Automatic rate limiting**: Built-in protection against API limits

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

**Purpose**: Basic countries retrieval and data exploration with type-safe client methods

**What it demonstrates**:

- Creating a SetlistFM client with automatic STANDARD rate limiting
- Using the type-safe `client.searchCountries()` method to retrieve all countries
- Real-time rate limiting status monitoring
- Retrieving the complete list of supported countries (250 total)
- Finding specific countries by country code with type safety
- Analyzing country data (name lengths, regional groupings)
- Sorting and filtering country information with typed responses
- Working with ISO 3166-1 alpha-2 country codes
- Rate limiting protection during single endpoint usage
- Basic error handling and data validation

**Run it**:

```bash
pnpm dlx tsx examples/countries/basicCountriesLookup.ts
```

**Key features**: Shows rate limiting status with minimal API calls (1 request total), demonstrates data quality with 250 countries using clean client methods.

### 2. `countriesAnalysis.ts`

**Purpose**: Comprehensive countries data analysis and integration with type-safe client methods

**What it demonstrates**:

- Using the type-safe `client.searchCountries()` method for comprehensive analysis
- Using the type-safe `client.searchCities()` method for integration testing
- Rate limiting status throughout multiple API operations
- Advanced data analysis and statistical insights (250 countries analyzed)
- Regional country groupings and geographic analysis (6 regions, 100% coverage)
- Integration with cities endpoint using unified client interface (26,961 cities across 7 countries)
- Performance measurement and optimization insights
- Localization and international naming patterns
- Real-world data processing with rate limiting consideration
- Multi-endpoint API integration patterns with rate protection

**Run it**:

```bash
pnpm dlx tsx examples/countries/countriesAnalysis.ts
```

**Key features**: Shows rate limiting during complex workflows (8 total requests), demonstrates production-scale data analysis using type-safe methods.

### 3. `completeExample.ts`

**Purpose**: Production-ready workflow with comprehensive testing, validation, and type-safe client methods

**What it demonstrates**:

- Complete countries API workflow using `client.searchCountries()` and `client.searchCities()`
- Data quality validation and integrity checks (100% valid country codes)
- Performance monitoring and optimization strategies (170ms fetch time)
- Integration testing with other API endpoints using unified client interface (5/5 successful cities tests)
- Practical use cases for country data (validation, lookup, mapping) with type safety
- Error handling and resilience patterns with rate limiting awareness
- Production-ready code patterns and best practices using clean client methods
- Comprehensive data analysis with statistical insights and rate limiting management

**Run it**:

```bash
pnpm dlx tsx examples/countries/completeExample.ts
```

**Key features**: Demonstrates enterprise-ready workflows with rate limiting (6 total requests), shows 23,850 cities integration across 5 countries using the new type-safe client API.

## Example Output

When you run these examples, you'll see formatted output with:

- 📊 **Rate limiting status**: Shows profile, current usage, and limits
- 🔍 Type-safe data retrieval operations and results
- ✅ Successful validation confirmations with type safety
- 📊 Statistical analysis and insights from typed responses
- 🌍 Geographic data and regional information
- 🏙️ Integration testing with cities endpoint using unified client interface
- ⚡ Performance metrics and optimization tips
- ⚠️ Rate limiting demonstrations (status throughout workflow)
- ❌ Error handling demonstrations
- 🎯 Practical use case implementations with type safety

## Code Structure

Each example follows a consistent pattern with the new type-safe client and automatic rate limiting:

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
    console.log(`📈 Requests: ${status.requestsThisSecond}/${status.secondLimit} this second`);

    // Use type-safe client methods directly
    const countries = await client.searchCountries();
    const cities = await client.searchCities({ country: "US" });

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

1. **Start with `basicCountriesLookup.ts`** - Learn the type-safe client fundamentals for countries data retrieval and see rate limiting in action
2. **Try `countriesAnalysis.ts`** - Understand advanced analysis with `client.searchCountries()` and rate limiting during multiple requests
3. **Explore `completeExample.ts`** - See production-ready patterns and comprehensive workflows with intelligent rate limiting using type-safe methods

## Key Features Demonstrated

### Type-Safe Client API

The examples show the new type-safe client features:

- **Clean method calls**: Use `client.searchCountries()` instead of raw endpoint functions
- **No HTTP client management**: Direct method calls without getHttpClient()
- **Full type safety**: IDE autocompletion and type checking for all parameters and responses
- **Consistent interface**: All methods follow the same pattern
- **Integration simplicity**: Use `client.searchCities({ country: "US" })` for cross-endpoint workflows

### Rate Limiting Protection

The examples show the automatic rate limiting features:

- **Default STANDARD profile**: 2 requests/second, 1440 requests/day
- **Real-time monitoring**: Current usage vs. limits displayed throughout workflows
- **Automatic protection**: Prevents accidental API limit violations
- **Queue management**: Handles request pacing automatically
- **Status tracking**: Shows rate limiting impact on multi-request workflows

### Country Code Management

The examples show how to work with:

- **ISO 3166-1 alpha-2 codes**: Standard two-letter country codes (US, GB, DE, etc.)
- **Code validation**: Ensuring country codes follow proper format and exist
- **Code-to-name mapping**: Building efficient lookup tables for O(1) access with typed data
- **Regional groupings**: Organizing countries by geographic or political regions

### Data Analysis Techniques

Learn about comprehensive data analysis with rate limiting and type safety:

- Statistical analysis of country names and codes (250 countries total) using typed responses
- Regional coverage and geographic distribution (100% coverage across 6 regions)
- Performance measurement and optimization (170ms fetch times)
- Data quality validation and integrity checks (100% valid data)
- Cross-endpoint integration and correlation with rate limiting awareness using unified client interface

### Integration Capabilities

The examples demonstrate:

- **Cities integration**: Using `client.searchCities({ country: "DE" })` for filtered searches (26,961 cities tested)
- **Cross-reference validation**: Ensuring data consistency across endpoints with type safety
- **Multi-endpoint workflows**: Building complex applications with multiple API calls using unified client
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
- **Response time measurement**: Tracking API call performance (170ms average) using type-safe methods
- **Caching strategies**: Recommendations for optimizing repeated access
- **Memory efficiency**: Best practices for handling country data
- **Rate limiting compliance**: Respectful API usage patterns
- **Optimization insights**: Performance tuning recommendations

## API Characteristics

Through these examples with rate limiting protection and type-safe methods, you'll understand:

- **Endpoint behavior**: How the `client.searchCountries()` method works
- **Response structure**: Complete dataset in single response (250 countries) with full type safety
- **Parameter handling**: Why this method accepts no query parameters
- **Data consistency**: Reliability and stability of country data
- **Integration patterns**: How countries relate to other endpoints using unified client interface
- **Rate limiting impact**: How protection affects workflow design

## Use Cases Demonstrated

### 1. Country Code Validation

```typescript
// Validate if a country code exists using typed responses
const countries = await client.searchCountries();
const validCodes = new Set(countries.country.map(c => c.code));
const isValid = validCodes.has("US"); // true
const isInvalid = validCodes.has("XX"); // false
```

### 2. Country Name Lookup

```typescript
// Build efficient lookup table with type safety
const countries = await client.searchCountries();
const countryMap = new Map(countries.country.map(c => [c.code, c.name]));
const name = countryMap.get("GB"); // "United Kingdom"
```

### 3. Regional Filtering

```typescript
// Filter countries by region with typed data
const countries = await client.searchCountries();
const europeanCodes = ["GB", "DE", "FR", "IT", "ES"];
const europeanCountries = countries.country.filter(c => europeanCodes.includes(c.code));
```

### 4. Cities Integration

```typescript
// Use country codes for city searches with unified client interface
const germanCities = await client.searchCities({
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
// Countries data changes infrequently, cache it with type safety
const CACHE_TTL = 24 * 60 * 60 * 1000; // 24 hours
let cachedCountries: Awaited<ReturnType<typeof client.searchCountries>> | null = null;
let cacheTime = 0;

if (Date.now() - cacheTime > CACHE_TTL) {
  cachedCountries = await client.searchCountries();
  cacheTime = Date.now();
}
```

**Efficient Lookups**:

```typescript
// Use Map for O(1) lookups instead of Array.find() with typed data
const countries = await client.searchCountries();
const countryMap = new Map(countries.country.map(c => [c.code, c]));
const country = countryMap.get("US"); // O(1) lookup with full type safety
```

**Memory Management**:

```typescript
// Process countries in chunks for large datasets with type safety
import type { Country } from "../../src/endpoints/countries";

function processInChunks(countries: Country[], chunkSize: number) {
  for (let i = 0; i < countries.length; i += chunkSize) {
    const chunk = countries.slice(i, i + chunkSize);
    // Process chunk with full type safety
  }
}
```

## Next Steps

After exploring these examples:

1. Try modifying the regional groupings and analysis using type-safe client methods
2. Experiment with different data visualization approaches with rate limiting and type safety
3. Build your own country-based filtering and validation systems using the clean client API
4. Integrate country data into larger applications with rate limiting awareness and unified client interface
5. Implement caching and performance optimization strategies with type safety
6. Understand how rate limiting affects your application design

## Related Documentation

- [Countries Endpoints Documentation](../../src/endpoints/countries/README.md)
- [Rate Limiting Documentation](../../src/utils/rateLimiter.ts)
- [setlist.fm API Documentation](https://api.setlist.fm/docs/1.0/index.html)
- [ISO 3166-1 Country Codes](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2)
- [Cities Examples](../cities/README.md) - Learn about related city data integration using the same type-safe client
