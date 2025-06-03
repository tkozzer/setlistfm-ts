# Cities Endpoints

This module provides methods for interacting with cities-related endpoints in the setlist.fm API.

## Overview

Cities in the setlist.fm API represent geographic locations where venues are located. Each city is uniquely identified by a GeoNames ID and includes location data, coordinates, and country information. Most city data originates from GeoNames.org.

## Available Functions

### `getCityByGeoId(httpClient: HttpClient, geoId: string)`

Retrieves a city by its unique GeoNames geoId.

**Parameters:**

- `httpClient` (HttpClient): The HTTP client instance
- `geoId` (string): The city's GeoNames geoId (must be numeric string)

**Returns:** `Promise<City>`

**Example:**

```typescript
import type { HttpClient } from "@utils/http";
import { getCityByGeoId } from "./getCityByGeoId";

const city = await getCityByGeoId(httpClient, "5357527");
// eslint-disable-next-line no-console
console.log(city.name); // "Hollywood"
// eslint-disable-next-line no-console
console.log(city.state); // "California"
// eslint-disable-next-line no-console
console.log(city.country.name); // "United States"
```

**API Reference:** [GET /1.0/city/{geoId}](https://api.setlist.fm/docs/1.0/resource__1.0_city__geoId_.html)

### `searchCities(httpClient: HttpClient, params?: SearchCitiesParams)`

Search for cities by name, country, state, or state code. Returns a paginated list of matching cities.

**Parameters:**

- `httpClient` (HttpClient): The HTTP client instance
- `params` (SearchCitiesParams, optional): Search parameters object containing:
  - `name` (string, optional): Name of the city to search for
  - `country` (string, optional): The city's country
  - `state` (string, optional): State the city lies in
  - `stateCode` (string, optional): State code the city lies in
  - `p` (number, optional): Page number for pagination (default: 1)

**Returns:** `Promise<Cities>`

**Example:**

```typescript
import { searchCities } from "./searchCities";

// Search by city name
const results = await searchCities(httpClient, { name: "Hollywood" });
// eslint-disable-next-line no-console
console.log(results.total); // Total number of matching cities
// eslint-disable-next-line no-console
console.log(results.cities.length); // Number of cities on this page

// Search by country and state
const californiaResults = await searchCities(httpClient, {
  country: "US",
  state: "California",
  p: 1
});

// Search with pagination
const page2 = await searchCities(httpClient, {
  name: "London",
  p: 2
});

// Search by state code
const stateCodeResults = await searchCities(httpClient, {
  stateCode: "CA"
});
```

**API Reference:** [GET /1.0/search/cities](https://api.setlist.fm/docs/1.0/resource__1.0_search_cities.html)

## Data Types

### City

Represents a city where venues are located.

```typescript
type City = {
  /** Unique identifier for the city (GeoNames ID) */
  id: string;
  /** The city's name, depending on the language */
  name: string;
  /** The code of the city's state */
  stateCode: string;
  /** The name of the city's state */
  state: string;
  /** The city's coordinates, usually of the city centre */
  coords: Coords;
  /** The city's country */
  country: Country;
};
```

### Cities

Represents a paginated response containing cities from the search endpoint.

```typescript
type Cities = {
  /** Array of city objects */
  cities: City[];
  /** Total number of matching cities */
  total: number;
  /** Current page number (starts at 1) */
  page: number;
  /** Number of items per page */
  itemsPerPage: number;
};
```

### Country

Represents a country with its code and name.

```typescript
type Country = {
  /** Two-letter country code (ISO 3166-1) */
  code: string;
  /** Full country name */
  name: string;
};
```

### Countries

Represents a paginated response containing countries.

```typescript
type Countries = {
  /** Array of country objects */
  country: Country[];
  /** Total number of countries */
  total: number;
  /** Current page number (starts at 1) */
  page: number;
  /** Number of items per page */
  itemsPerPage: number;
};
```

### Coords

Represents geographic coordinates (latitude and longitude).

```typescript
type Coords = {
  /** Longitude (-180 to 180) */
  long: number;
  /** Latitude (-90 to 90) */
  lat: number;
};
```

### SearchCitiesParams

Parameters for searching cities.

```typescript
type SearchCitiesParams = {
  /** The city's country */
  country?: string;
  /** Name of the city */
  name?: string;
  /** The number of the result page you'd like to have (default: 1) */
  p?: number;
  /** State the city lies in */
  state?: string;
  /** State code the city lies in */
  stateCode?: string;
};
```

## Validation

All functions use Zod schemas for input validation:

- **GeoId validation**: Ensures geoIds are numeric strings
- **Parameter validation**: Validates search parameters and pagination
- **Response validation**: Validates API responses against expected schemas

## Usage Notes

- **GeoNames ID**: All city identification uses GeoNames IDs, which are numeric string identifiers
- **Pagination**: Search results are paginated. Use the `p` parameter to navigate through results
- **Search flexibility**: `searchCities` accepts any combination of search parameters or none at all
- **State codes**: The `stateCode` is only unique when combined with the country code
- **Coordinates**: Represent the city center location, with longitude range -180 to 180 and latitude range -90 to 90
- **Rate Limiting**: Be mindful of API rate limits when making multiple requests

## Error Handling

All functions can throw the following errors:

- **`ValidationError`**: When input parameters are invalid or missing
- **`NotFoundError`**: When the requested resource is not found (404)
- **`AuthenticationError`**: When the API key is invalid (401)
- **`SetlistFMAPIError`**: For other API errors (rate limiting, server errors, etc.)

## Complete Usage Example

```typescript
import type { HttpClient } from "@utils/http";
import { getCityByGeoId, searchCities } from "./index";

// Assume you have an httpClient instance configured with API key and user agent

async function demonstrateCityEndpoints(httpClient: HttpClient) {
  try {
    // 1. Search for cities by name
    const searchResults = await searchCities(httpClient, {
      name: "Hollywood",
      p: 1
    });

    // eslint-disable-next-line no-console
    console.log(`Found ${searchResults.total} cities matching "Hollywood"`);

    if (searchResults.cities.length > 0) {
      const firstCity = searchResults.cities[0];
      // eslint-disable-next-line no-console
      console.log(`First result: ${firstCity.name}, ${firstCity.state} (${firstCity.id})`);

      // 2. Get detailed city information
      const city = await getCityByGeoId(httpClient, firstCity.id);
      // eslint-disable-next-line no-console
      console.log(`City details: ${city.name} - ${city.state}, ${city.country.name}`);
      // eslint-disable-next-line no-console
      console.log(`Coordinates: ${city.coords.lat}, ${city.coords.long}`);
    }

    // 3. Search by country and state
    const californiaResults = await searchCities(httpClient, {
      country: "US",
      state: "California",
      p: 1
    });
    // eslint-disable-next-line no-console
    console.log(`Found ${californiaResults.total} cities in California`);

    // 4. Search by state code
    const stateCodeResults = await searchCities(httpClient, {
      stateCode: "CA",
      p: 1
    });
    // eslint-disable-next-line no-console
    console.log(`Found ${stateCodeResults.total} cities with state code CA`);

    // 5. Handle pagination
    if (searchResults.total > searchResults.itemsPerPage) {
      const totalPages = Math.ceil(searchResults.total / searchResults.itemsPerPage);
      // eslint-disable-next-line no-console
      console.log(`Results span ${totalPages} pages`);

      // Get next page
      const page2 = await searchCities(httpClient, {
        name: "Hollywood",
        p: 2
      });
      // eslint-disable-next-line no-console
      console.log(`Page 2 has ${page2.cities.length} cities`);
    }
  }
  catch (error) {
    console.error("Error fetching city data:", error);
  }
}
```

## API Reference

- [setlist.fm API: city Data Type](https://api.setlist.fm/docs/1.0/json_City.html)
- [setlist.fm API: cities Data Type](https://api.setlist.fm/docs/1.0/json_Cities.html)
- [setlist.fm API: country Data Type](https://api.setlist.fm/docs/1.0/json_Country.html)
- [setlist.fm API: countries Data Type](https://api.setlist.fm/docs/1.0/json_Countries.html)
- [setlist.fm API: coords Data Type](https://api.setlist.fm/docs/1.0/json_Coords.html)
- [setlist.fm API: GET /1.0/city/{geoId}](https://api.setlist.fm/docs/1.0/resource__1.0_city__geoId_.html)
- [setlist.fm API: GET /1.0/search/cities](https://api.setlist.fm/docs/1.0/resource__1.0_search_cities.html)
- [GeoNames.org](http://geonames.org/)
- [ISO 3166-1 Country Codes](https://en.wikipedia.org/wiki/ISO_3166-1)
