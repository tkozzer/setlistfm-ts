# Venues Endpoints

This module provides methods for interacting with venues-related endpoints in the setlist.fm API.

## Overview

Venues in the setlist.fm API represent places where concerts take place. They usually consist of a venue name and a city, but some venues may not have a city attached yet. In such cases, the city and country may be included in the venue name. Each venue is uniquely identified by an 8-character hexadecimal ID.

## Available Functions

### `getVenue(httpClient: HttpClient, venueId: string)`

Retrieves a venue by its unique venue ID.

**Parameters:**

- `httpClient` (HttpClient): The HTTP client instance
- `venueId` (string): The venue's unique identifier (8-character hexadecimal string)

**Returns:** `Promise<Venue>`

**Example:**

```typescript
import type { HttpClient } from "@utils/http";
import { getVenue } from "./getVenue";

const venue = await getVenue(httpClient, "6bd6ca6e");
// eslint-disable-next-line no-console
console.log(venue.name); // "Compaq Center"
// eslint-disable-next-line no-console
console.log(venue.city?.name); // "Hollywood"
// eslint-disable-next-line no-console
console.log(venue.city?.country.name); // "United States"
```

**API Reference:** [GET /1.0/venue/{venueId}](https://api.setlist.fm/docs/1.0/resource__1.0_venue__venueId_.html)

### `getVenueSetlists(httpClient: HttpClient, venueId: string, params?: GetVenueSetlistsParams)`

Retrieves setlists for a venue by its unique venue ID with pagination support.

**Parameters:**

- `httpClient` (HttpClient): The HTTP client instance
- `venueId` (string): The venue's unique identifier (8-character hexadecimal string)
- `params` (GetVenueSetlistsParams, optional): Pagination parameters containing:
  - `p` (number, optional): Page number for pagination (default: 1)

**Returns:** `Promise<Setlists>`

**Example:**

```typescript
import { getVenueSetlists } from "./getVenueSetlists";

// Get first page of setlists for a venue
const setlists = await getVenueSetlists(httpClient, "6bd6ca6e");
// eslint-disable-next-line no-console
console.log(setlists.total); // Total number of setlists
// eslint-disable-next-line no-console
console.log(setlists.setlist.length); // Number of setlists on this page

// Get specific page
const page2 = await getVenueSetlists(httpClient, "6bd6ca6e", { p: 2 });

// Process setlist data
setlists.setlist.forEach((setlist) => {
  // eslint-disable-next-line no-console
  console.log(`${setlist.artist.name} at ${setlist.venue.name} on ${setlist.eventDate}`);
});
```

**API Reference:** [GET /1.0/venue/{venueId}/setlists](https://api.setlist.fm/docs/1.0/resource__1.0_venue__venueId__setlists.html)

### `searchVenues(httpClient: HttpClient, params?: SearchVenuesParams)`

Search for venues by name, city, country, state, or state code. Returns a paginated list of matching venues.

**Parameters:**

- `httpClient` (HttpClient): The HTTP client instance
- `params` (SearchVenuesParams, optional): Search parameters object containing:
  - `name` (string, optional): Name of the venue
  - `cityId` (string, optional): The city's geoId
  - `cityName` (string, optional): Name of the city where the venue is located
  - `country` (string, optional): The city's country (ISO 3166-1 alpha-2 code)
  - `state` (string, optional): The city's state
  - `stateCode` (string, optional): The city's state code
  - `p` (number, optional): Page number for pagination (default: 1)

**Returns:** `Promise<Venues>`

**Example:**

```typescript
import { searchVenues } from "./searchVenues";

// Search by venue name
const results = await searchVenues(httpClient, { name: "Madison Square Garden" });
// eslint-disable-next-line no-console
console.log(results.total); // Total number of matching venues
// eslint-disable-next-line no-console
console.log(results.venue.length); // Number of venues on this page

// Search by city and country
const nyResults = await searchVenues(httpClient, {
  cityName: "New York",
  country: "US",
  p: 1
});

// Search by state
const californiaResults = await searchVenues(httpClient, {
  state: "California",
  stateCode: "CA",
  p: 2
});

// Search by city geoId
const geoResults = await searchVenues(httpClient, {
  cityId: "5128581"
});

// Complex search with multiple criteria
const complexSearch = await searchVenues(httpClient, {
  name: "Arena",
  cityName: "Los Angeles",
  country: "US",
  state: "California"
});
```

**API Reference:** [GET /1.0/search/venues](https://api.setlist.fm/docs/1.0/resource__1.0_search_venues.html)

## Data Types

### Venue

Represents a venue where concerts take place.

```typescript
type Venue = {
  /** The city in which the venue is located (may be omitted if not available) */
  city?: City;
  /** The attribution URL to the venue on setlist.fm */
  url: string;
  /** Unique identifier for the venue */
  id: string;
  /** The name of the venue, usually without city and country */
  name: string;
};
```

### Venues

Represents a paginated response containing venues from the search endpoint.

```typescript
type Venues = {
  /** Array of venue objects */
  venue: Venue[];
  /** Total number of matching venues */
  total: number;
  /** Current page number (starts at 1) */
  page: number;
  /** Number of items per page */
  itemsPerPage: number;
};
```

### SearchVenuesParams

Parameters for searching venues.

```typescript
type SearchVenuesParams = {
  /** The city's geoId */
  cityId?: string;
  /** Name of the city where the venue is located */
  cityName?: string;
  /** The city's country (ISO 3166-1 alpha-2 code) */
  country?: string;
  /** Name of the venue */
  name?: string;
  /** The number of the result page you'd like to have (default: 1) */
  p?: number;
  /** The city's state */
  state?: string;
  /** The city's state code */
  stateCode?: string;
};
```

### GetVenueSetlistsParams

Parameters for retrieving venue setlists.

```typescript
type GetVenueSetlistsParams = {
  /** The number of the result page you'd like to have (default: 1) */
  p?: number;
};
```

### Setlists

Represents a paginated response containing setlists (imported from artists module).

```typescript
type Setlists = {
  /** Array of setlist objects */
  setlist: Setlist[];
  /** Total number of setlists */
  total: number;
  /** Current page number (starts at 1) */
  page: number;
  /** Number of items per page */
  itemsPerPage: number;
};
```

## Validation

All functions use Zod schemas for input validation:

- **Venue ID validation**: Ensures venue IDs are 8-character hexadecimal strings
- **Country code validation**: Validates ISO 3166-1 alpha-2 country codes (e.g., "US", "GB", "DE")
- **City ID validation**: Ensures city IDs are numeric strings (GeoNames IDs)
- **Parameter validation**: Validates search parameters and pagination
- **Response validation**: Validates API responses against expected schemas

## Usage Notes

- **Venue IDs**: All venue identification uses 8-character hexadecimal strings (e.g., "6bd6ca6e")
- **Country codes**: Use ISO 3166-1 alpha-2 country codes (e.g., "US", "GB", "DE", "FR")
- **City references**: Some venues may not have a city attached; in such cases, city and country information may be included in the venue name
- **Pagination**: All paginated endpoints start at page 1 and return 20 items per page by default
- **Attribution**: Always use the `url` property for attribution when displaying venue data
- **Search flexibility**: The search endpoint supports multiple criteria and can be combined for more specific results

## Complete Usage Example

```typescript
import type { HttpClient } from "@utils/http";
import { getVenue, getVenueSetlists, searchVenues } from "./index";

async function exploreVenues(httpClient: HttpClient) {
  try {
    // Search for venues in New York
    const searchResults = await searchVenues(httpClient, {
      cityName: "New York",
      country: "US"
    });

    // eslint-disable-next-line no-console
    console.log(`Found ${searchResults.total} venues in New York`);

    // Get details for the first venue
    if (searchResults.venue.length > 0) {
      const firstVenue = searchResults.venue[0];
      const venueDetails = await getVenue(httpClient, firstVenue.id);

      // eslint-disable-next-line no-console
      console.log(`Venue: ${venueDetails.name}`);
      if (venueDetails.city) {
        // eslint-disable-next-line no-console
        console.log(`Location: ${venueDetails.city.name}, ${venueDetails.city.state}`);
      }

      // Get setlists for this venue
      const setlists = await getVenueSetlists(httpClient, firstVenue.id, { p: 1 });
      // eslint-disable-next-line no-console
      console.log(`Found ${setlists.total} setlists for this venue`);

      // Display recent setlists
      setlists.setlist.slice(0, 3).forEach((setlist) => {
        // eslint-disable-next-line no-console
        console.log(`- ${setlist.artist.name} (${setlist.eventDate})`);
      });
    }
  }
  catch (error) {
    console.error("Error exploring venues:", error);
  }
}
```

## Error Handling

All functions may throw the following errors:

- **ValidationError**: When input parameters are invalid
- **NotFoundError**: When the requested venue or search yields no results
- **AuthenticationError**: When the API key is invalid
- **SetlistFMAPIError**: For rate limiting and other API-specific errors
- **Network errors**: For connectivity issues

## API References

- [setlist.fm API: venue Data Type](https://api.setlist.fm/docs/1.0/json_Venue.html)
- [setlist.fm API: venues Data Type](https://api.setlist.fm/docs/1.0/json_Venues.html)
- [GET /1.0/venue/{venueId}](https://api.setlist.fm/docs/1.0/resource__1.0_venue__venueId_.html)
- [GET /1.0/venue/{venueId}/setlists](https://api.setlist.fm/docs/1.0/resource__1.0_venue__venueId__setlists.html)
- [GET /1.0/search/venues](https://api.setlist.fm/docs/1.0/resource__1.0_search_venues.html)
