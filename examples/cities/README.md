# Cities Endpoints Examples

This directory contains practical examples demonstrating how to use the setlistfm-ts cities endpoints.

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

### 1. `basicCityLookup.ts`

**Purpose**: Basic city search and lookup workflow

**What it demonstrates**:

- Creating an HTTP client with API credentials
- Searching for cities by name and then looking up specific ones
- Finding specific cities (Paris, London, New York, Los Angeles)
- Handling and displaying city information
- Working with coordinates and geographic data
- Basic error handling and fallback strategies

**Run it**:

```bash
pnpm dlx tsx examples/cities/basicCityLookup.ts
```

### 2. `searchCities.ts`

**Purpose**: Comprehensive city search functionality

**What it demonstrates**:

- Searching cities by name, country code, state, and state code
- Using proper ISO country codes (DE, GB, US) for filtering
- Using pagination parameters
- Combining multiple search criteria
- Handling empty search results
- Processing search result data
- Geographic data analysis

**Run it**:

```bash
pnpm dlx tsx examples/cities/searchCities.ts
```

### 3. `completeExample.ts`

**Purpose**: Complete workflow using all cities endpoints with advanced data analysis

**What it demonstrates**:

- Real-world workflow: search → analyze → lookup details
- Multi-page data collection with pagination
- Geographic data analysis and statistics
- Combining multiple API calls efficiently
- Advanced data processing and visualization
- Cross-country city comparisons

**Run it**:

```bash
pnpm dlx tsx examples/cities/completeExample.ts
```

## Example Output

When you run these examples, you'll see formatted output with:

- 🔍 Search operations and city discovery
- ✅ Successful data retrieval confirmations
- 📄 Pagination information and navigation
- 🌍 Geographic and location data
- 📊 Statistical analysis and summaries
- 🗺️ Coordinate analysis and geographic insights
- ❌ Error handling demonstrations

## Code Structure

Each example follows a consistent pattern:

```typescript
import { getCityByGeoId, searchCities } from "../../src/endpoints/cities";
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

1. **Start with `basicCityLookup.ts`** - Learn the fundamentals of city lookup
2. **Try `searchCities.ts`** - Understand search capabilities and parameters
3. **Explore `completeExample.ts`** - See advanced workflows and data analysis

## Key Features Demonstrated

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
- **Pagination**: Navigate through large result sets

### Data Analysis Techniques

The examples demonstrate:

- Collecting data across multiple pages
- Grouping and categorizing results
- Statistical analysis of geographic data
- Coordinate range and distribution analysis
- Cross-referencing between search and lookup operations

## Error Handling

All examples include comprehensive error handling for:

- Validation errors (invalid geoIds, missing parameters)
- API errors (authentication, rate limiting, not found)
- Network errors (connection issues, timeouts)
- Data processing errors

## Real Geographic Data

These examples use real cities from the setlist.fm database, including:

- **Paris cities worldwide** (184 total) - for search and lookup demonstrations
- **London variations** (133 total) - for international city analysis
- **Major music cities** - Nashville, Austin, Los Angeles, New York
- **Country-specific searches** - Germany (5064 cities), UK (3329 cities), US (10000+ cities)
- **Regional examples** - California (936 cities), New York state (920 cities)

## Performance Considerations

The examples include:

- **Rate limiting respect**: Built-in delays between requests
- **Pagination efficiency**: Smart page collection strategies
- **Memory management**: Efficient data collection and processing
- **API courtesy**: Reasonable request limits and timing

## Geographic Insights

Through these examples, you'll discover:

- How many cities share common names worldwide
- Geographic distribution patterns
- Coordinate system understanding
- State and country code relationships
- International location data variations

## Troubleshooting

**API Key Issues**:

- Ensure your `.env` file is in the project root
- Verify your API key is correct and active
- Check that `SETLISTFM_API_KEY` matches exactly

**Rate Limiting**:

- The examples include built-in delays between requests
- If you get rate limit errors, wait a few minutes before retrying
- Consider reducing pagination limits for testing

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

## Next Steps

After exploring these examples:

1. Try searching for cities in your region
2. Experiment with different geographic filters
3. Build your own city analysis tools
4. Integrate city data with venue or setlist information
5. Create geographic visualizations of music data

## Integration Possibilities

Cities data can be combined with other setlist.fm endpoints:

- **Venues**: Find venues in specific cities
- **Setlists**: Analyze performance locations
- **Artists**: Track artist touring patterns
- **Geographic analysis**: Map music scenes by location

## Related Documentation

- [Cities Endpoints Documentation](../../src/endpoints/cities/README.md)
- [setlist.fm API Documentation](https://api.setlist.fm/docs/1.0/index.html)
- [GeoNames Database](http://geonames.org/)
- [ISO 3166-1 Country Codes](https://en.wikipedia.org/wiki/ISO_3166-1)
