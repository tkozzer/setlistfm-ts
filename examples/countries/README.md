# Countries Endpoints Examples

This directory contains practical examples demonstrating how to use the setlistfm-ts countries endpoints.

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

### 1. `basicCountriesLookup.ts`

**Purpose**: Basic countries retrieval and data exploration

**What it demonstrates**:

- Creating an HTTP client with API credentials
- Retrieving the complete list of supported countries
- Finding specific countries by country code
- Analyzing country data (name lengths, regional groupings)
- Sorting and filtering country information
- Working with ISO 3166-1 alpha-2 country codes
- Basic error handling and data validation

**Run it**:

```bash
pnpm dlx tsx examples/countries/basicCountriesLookup.ts
```

### 2. `countriesAnalysis.ts`

**Purpose**: Comprehensive countries data analysis and integration

**What it demonstrates**:

- Advanced data analysis and statistical insights
- Regional country groupings and geographic analysis
- Integration with cities endpoint for cross-reference data
- Performance measurement and optimization insights
- Localization and international naming patterns
- Real-world data processing and visualization
- Multi-endpoint API integration patterns

**Run it**:

```bash
pnpm dlx tsx examples/countries/countriesAnalysis.ts
```

### 3. `completeExample.ts`

**Purpose**: Production-ready workflow with comprehensive testing and validation

**What it demonstrates**:

- Complete countries API workflow from basic to advanced usage
- Data quality validation and integrity checks
- Performance monitoring and optimization strategies
- Integration testing with other API endpoints
- Practical use cases for country data (validation, lookup, mapping)
- Error handling and resilience patterns
- Production-ready code patterns and best practices
- Comprehensive data analysis with statistical insights

**Run it**:

```bash
pnpm dlx tsx examples/countries/completeExample.ts
```

## Example Output

When you run these examples, you'll see formatted output with:

- 🔍 Data retrieval operations and results
- ✅ Successful validation confirmations
- 📊 Statistical analysis and insights
- 🌍 Geographic data and regional information
- 🏙️ Integration testing with cities endpoint
- ⚡ Performance metrics and optimization tips
- ❌ Error handling demonstrations
- 🎯 Practical use case implementations

## Code Structure

Each example follows a consistent pattern:

```typescript
import { searchCountries } from "../../src/endpoints/countries";
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

1. **Start with `basicCountriesLookup.ts`** - Learn the fundamentals of countries data retrieval
2. **Try `countriesAnalysis.ts`** - Understand advanced analysis and integration capabilities
3. **Explore `completeExample.ts`** - See production-ready patterns and comprehensive workflows

## Key Features Demonstrated

### Country Code Management

The examples show how to work with:

- **ISO 3166-1 alpha-2 codes**: Standard two-letter country codes (US, GB, DE, etc.)
- **Code validation**: Ensuring country codes follow proper format and exist
- **Code-to-name mapping**: Building efficient lookup tables for O(1) access
- **Regional groupings**: Organizing countries by geographic or political regions

### Data Analysis Techniques

Learn about comprehensive data analysis:

- Statistical analysis of country names and codes
- Regional coverage and geographic distribution
- Performance measurement and optimization
- Data quality validation and integrity checks
- Cross-endpoint integration and correlation

### Integration Capabilities

The examples demonstrate:

- **Cities integration**: Using country codes to filter city searches
- **Cross-reference validation**: Ensuring data consistency across endpoints
- **Multi-endpoint workflows**: Building complex applications with multiple API calls
- **Performance optimization**: Caching strategies and efficient data access patterns

## Error Handling

All examples include comprehensive error handling for:

- API authentication errors (invalid API key)
- Network connectivity issues
- Rate limiting and throttling
- Data validation errors
- API response parsing errors
- Timeout and connection errors

## Real Country Data

These examples use real data from the setlist.fm API, including:

- **Complete country list** - All countries supported by setlist.fm
- **ISO standard codes** - Proper ISO 3166-1 alpha-2 country codes
- **Localized names** - Country names that may vary by language/locale
- **Regional analysis** - Real geographic and political groupings (EU, G7, NATO, etc.)
- **Integration data** - Actual city counts and geographic relationships

## Performance Considerations

The examples include:

- **Response time measurement**: Tracking API call performance
- **Caching strategies**: Recommendations for optimizing repeated access
- **Memory efficiency**: Best practices for handling country data
- **Rate limiting compliance**: Respectful API usage patterns
- **Optimization insights**: Performance tuning recommendations

## API Characteristics

Through these examples, you'll understand:

- **Endpoint behavior**: How the `/search/countries` endpoint works
- **Response structure**: Paginated results with country arrays
- **Parameter handling**: Why this endpoint accepts no query parameters
- **Data consistency**: Reliability and stability of country data
- **Integration patterns**: How countries relate to other endpoints

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
// Use country codes for city searches
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

**Rate Limiting**:

- The examples include built-in delays between requests
- If you get rate limit errors, wait a few minutes before retrying
- Consider implementing exponential backoff for production use

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
2. Experiment with different data visualization approaches
3. Build your own country-based filtering and validation systems
4. Integrate country data into larger applications
5. Implement caching and performance optimization strategies

## Related Documentation

- [Countries Endpoints Documentation](../../src/endpoints/countries/README.md)
- [setlist.fm API Documentation](https://api.setlist.fm/docs/1.0/index.html)
- [ISO 3166-1 Country Codes](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2)
- [Cities Examples](../cities/README.md) - Learn about related city data integration
