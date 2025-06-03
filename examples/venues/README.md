# Venues Endpoints Examples

This directory contains practical examples demonstrating how to use the setlistfm-ts venues endpoints.

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

### 1. `basicVenueLookup.ts`

**Purpose**: Basic venue search and lookup workflow

**What it demonstrates**:

- Creating an HTTP client with API credentials
- Searching for venues by name and then looking up specific ones
- Finding famous venues (Madison Square Garden, Wembley Stadium, Red Rocks)
- Working with venue information and geographic data
- Searching venues by city and location criteria
- Basic error handling and venue data processing

**Run it**:

```bash
pnpm dlx tsx examples/venues/basicVenueLookup.ts
```

### 2. `searchVenues.ts`

**Purpose**: Comprehensive venue search functionality

**What it demonstrates**:

- Searching venues by name, city, country, state, and state code
- Using proper ISO country codes (US, GB, DE, CA) for filtering
- Using pagination parameters for large result sets
- Combining multiple search criteria for precise results
- Handling empty search results and venues without cities
- Processing search result data and geographic analysis
- International venue comparisons across countries

**Run it**:

```bash
pnpm dlx tsx examples/venues/searchVenues.ts
```

### 3. `getVenueSetlists.ts`

**Purpose**: Venue setlist retrieval and analysis

**What it demonstrates**:

- Getting setlists for specific venues by venue ID
- Pagination through large setlist collections
- Analyzing venue performance data and artist statistics
- Processing setlist data for insights (years, artists, song counts)
- Comparing setlist activity between famous venues
- Multi-page data collection and analysis
- Recent venue activity discovery

**Run it**:

```bash
pnpm dlx tsx examples/venues/getVenueSetlists.ts
```

### 4. `completeExample.ts`

**Purpose**: Complete workflow using all venues endpoints with advanced analysis

**What it demonstrates**:

- Real-world workflow: search → analyze → deep dive
- Multi-city venue discovery across major music markets
- Venue type categorization and statistical analysis
- Famous venue deep-dive with comprehensive setlist analysis
- Geographic insights and venue distribution patterns
- Advanced data processing and cross-referencing
- Performance metrics and venue activity comparisons

**Run it**:

```bash
pnpm dlx tsx examples/venues/completeExample.ts
```

## Example Output

When you run these examples, you'll see formatted output with:

- 🔍 Search operations and venue discovery
- ✅ Successful data retrieval confirmations
- 📄 Pagination information and navigation
- 🏛️ Venue information and geographic data
- 🎵 Setlist counts and music activity statistics
- 📊 Statistical analysis and venue comparisons
- 🌍 Geographic insights and location data
- ❌ Error handling demonstrations

## Code Structure

Each example follows a consistent pattern:

```typescript
import { getVenue, getVenueSetlists, searchVenues } from "../../src/endpoints/venues";
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

1. **Start with `basicVenueLookup.ts`** - Learn the fundamentals of venue search and lookup
2. **Try `searchVenues.ts`** - Understand search capabilities and parameter combinations
3. **Explore `getVenueSetlists.ts`** - See setlist retrieval and analysis techniques
4. **Complete with `completeExample.ts`** - Experience advanced workflows and comprehensive analysis

## Key Features Demonstrated

### Venue Discovery

The examples show how to work with:

- **Name searches**: Find venues by partial or exact names
- **Geographic filters**: Search by city name, country code (US, GB, DE), state, or state code
- **City ID searches**: Use GeoNames IDs for precise city-based searches
- **Combined criteria**: Use multiple parameters together for refined results
- **Pagination**: Navigate through large result sets efficiently

### Venue Information

Learn about venue data structure:

- **Basic info**: Name, ID, setlist.fm URL for attribution
- **Geographic data**: City information with coordinates and country details
- **Optional fields**: Some venues may not have city information attached
- **Venue types**: Theaters, arenas, stadiums, clubs, halls, amphitheaters

### Setlist Analysis

The examples demonstrate:

- Retrieving setlists for specific venues with pagination
- Analyzing artist performance patterns and frequency
- Processing temporal data (years, dates, tours)
- Song count statistics and show length analysis
- Comparing venues by activity levels and historical data

### Data Analysis Techniques

Advanced processing includes:

- Grouping and categorizing venues by type and location
- Statistical analysis of venue distribution and activity
- Cross-referencing between search and detailed lookup operations
- Multi-page data collection for comprehensive analysis
- Geographic distribution and market analysis

## Error Handling

All examples include comprehensive error handling for:

- Validation errors (invalid venue IDs, missing parameters)
- API errors (authentication, rate limiting, not found)
- Network errors (connection issues, timeouts)
- Data processing errors and empty result sets

## Real Venue Data

These examples use real venues from the setlist.fm database, including:

- **Famous venues** - Madison Square Garden, Wembley Stadium, Red Rocks, Royal Albert Hall
- **Music cities** - Nashville (music capital), Austin (live music), New York (cultural hub)
- **Venue types** - Theaters (2000+ venues), Arenas (1500+ venues), Stadiums (800+ venues)
- **International venues** - UK venues (3000+), German venues (2500+), Canadian venues (1000+)
- **Geographic diversity** - Major cities worldwide with comprehensive venue coverage

## Performance Considerations

The examples include:

- **Rate limiting respect**: Built-in delays and reasonable request patterns
- **Pagination efficiency**: Smart page collection strategies for large datasets
- **Memory management**: Efficient data collection and processing techniques
- **API courtesy**: Reasonable request limits and timing considerations

## Venue Insights

Through these examples, you'll discover:

- How venue types are distributed globally (theaters vs. arenas vs. stadiums)
- Geographic concentration of venues in major music markets
- Activity patterns and performance frequency at famous venues
- International venue naming patterns and geographic data
- Setlist data availability and depth across different venue types

## Use Cases

These examples demonstrate patterns useful for:

- **Event planning**: Finding venues in specific cities or regions
- **Market research**: Analyzing venue distribution and activity patterns
- **Fan applications**: Discovering venue history and artist performance data
- **Geographic analysis**: Understanding music venue distribution globally
- **Performance tracking**: Monitoring artist activity at specific venues

## Troubleshooting

**API Key Issues**:

- Ensure your `.env` file is in the project root
- Verify your API key is correct and active
- Check that `SETLISTFM_API_KEY` matches exactly

**Search Issues**:

- Use ISO 3166-1 alpha-2 country codes (US, GB, DE, not USA, UK, GER)
- Venue IDs are 8-character hexadecimal strings
- Some venues may not have city information attached
- Empty results may indicate overly restrictive search criteria

**Data Considerations**:

- Venue data quality varies; some venues may lack complete information
- Setlist availability depends on community contributions
- Recent venues may have fewer historical setlists
- Geographic coordinates may not be available for all venues

## API References

- [setlist.fm API: venue Data Type](https://api.setlist.fm/docs/1.0/json_Venue.html)
- [setlist.fm API: venues Data Type](https://api.setlist.fm/docs/1.0/json_Venues.html)
- [GET /1.0/venue/{venueId}](https://api.setlist.fm/docs/1.0/resource__1.0_venue__venueId_.html)
- [GET /1.0/venue/{venueId}/setlists](https://api.setlist.fm/docs/1.0/resource__1.0_venue__venueId__setlists.html)
- [GET /1.0/search/venues](https://api.setlist.fm/docs/1.0/resource__1.0_search_venues.html)
