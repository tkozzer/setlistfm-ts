# Countries Endpoints

This module provides methods for interacting with countries-related endpoints in the setlist.fm API.

## Overview

Countries in the setlist.fm API represent all nations supported by the platform. Each country is identified by its ISO 3166-1 alpha-2 country code and includes localized names that can vary based on the requested language. The countries endpoint provides a complete list of all supported countries.

## Available Functions

### `searchCountries(httpClient: HttpClient, params?: SearchCountriesParams)`

Retrieves a complete list of all supported countries from the setlist.fm API.

**Parameters:**

- `httpClient` (HttpClient): The HTTP client instance
- `params` (SearchCountriesParams, optional): Search parameters object (currently empty as endpoint accepts no parameters)

**Returns:** `Promise<Countries>`

**Example:**

```typescript
import type { HttpClient } from "@utils/http";
import { searchCountries } from "./searchCountries";

// Get all supported countries
const results = await searchCountries(httpClient, {});

console.log(results.total); // Total number of countries

console.log(results.country.length); // Number of countries on this page

// Countries are automatically paginated by the API
for (const country of results.country) {
  console.log(`${country.code}: ${country.name}`);
}

// You can also call without parameters
const allCountries = await searchCountries(httpClient);

console.log(`${allCountries.country.length} countries available`);
```

**API Reference:** [GET /1.0/search/countries](https://api.setlist.fm/docs/1.0/resource__1.0_search_countries.html)

## Data Types

### Country

Represents a country supported by the setlist.fm API.

```typescript
type Country = {
  /** ISO 3166-1 alpha-2 country code (e.g., "US", "GB", "DE") */
  code: string;
  /** Localized name of the country (e.g., "United States", "United Kingdom", "Germany") */
  name: string;
};
```

### Countries

Represents a paginated response containing countries from the search endpoint.

```typescript
type Countries = {
  /** Array of country objects */
  country: Country[];
  /** Total number of countries available */
  total: number;
  /** Current page number (starts at 1) */
  page: number;
  /** Number of items per page */
  itemsPerPage: number;
};
```

### SearchCountriesParams

Parameters for searching countries. Currently empty as the endpoint accepts no query parameters.

```typescript
type SearchCountriesParams = Record<string, never>;
```

## Validation

All functions use Zod schemas for input validation:

- **Parameter validation**: Ensures only empty objects are passed as parameters
- **Country code validation**: Validates ISO 3166-1 alpha-2 country codes (2 uppercase letters)
- **Response validation**: Validates API responses against expected schemas
- **Strict validation**: Rejects any unexpected parameters to maintain API compliance

## Usage Notes

- **No query parameters**: The `/search/countries` endpoint doesn't accept any query parameters
- **Pagination**: Results are automatically paginated by the API
- **Localization**: Country names can be localized based on the `Accept-Language` header set in the HTTP client
- **ISO codes**: All country codes follow the ISO 3166-1 alpha-2 standard (two uppercase letters)
- **Complete list**: This endpoint returns all countries supported by setlist.fm

## Error Handling

The `searchCountries` function can throw the following errors:

- **`ValidationError`**: When input parameters are invalid (non-empty object)
- **`AuthenticationError`**: When the API key is invalid (401)
- **`SetlistFMAPIError`**: For other API errors (rate limiting, server errors, etc.)

## Complete Usage Example

```typescript
import type { HttpClient } from "@utils/http";
import { searchCountries } from "./index";

// Assume you have an httpClient instance configured with API key and user agent

async function demonstrateCountriesEndpoint(httpClient: HttpClient) {
  try {
    // Get all supported countries
    const results = await searchCountries(httpClient);

    console.log(`Total countries available: ${results.total}`);

    console.log(`Countries on this page: ${results.country.length}`);

    console.log(`Current page: ${results.page}`);

    console.log(`Items per page: ${results.itemsPerPage}`);

    // Display all countries
    results.country.forEach((country) => {
      console.log(`${country.code}: ${country.name}`);
    });

    // Example with specific countries
    const unitedStates = results.country.find(c => c.code === "US");
    if (unitedStates) {
      console.log(`Found: ${unitedStates.name} (${unitedStates.code})`);
    }

    const unitedKingdom = results.country.find(c => c.code === "GB");
    if (unitedKingdom) {
      console.log(`Found: ${unitedKingdom.name} (${unitedKingdom.code})`);
    }
  }
  catch (error) {
    if (error instanceof ValidationError) {
      console.error("Invalid parameters:", error.message);
    }
    else if (error instanceof AuthenticationError) {
      console.error("Authentication failed:", error.message);
    }
    else {
      console.error("API error:", error.message);
    }
  }
}
```

## Integration with Other Endpoints

Countries are used throughout the setlist.fm API as reference data:

```typescript
// Countries are referenced in city data
// Countries can be used to filter city searches
import { searchCities } from "../cities/searchCities";

type CityCountryReference = {
  coords: {
    lat: number; // Latitude
    long: number; // Longitude
  };
  country: Country; // References the Country type
  id: string; // City ID
  name: string; // City name
  state: string; // State/province name
  stateCode: string; // State/province code
};

const usaCities = await searchCities(httpClient, {
  country: "US", // Uses country code from countries endpoint
  p: 1
});
```

## API Compliance

This implementation strictly follows the official setlist.fm API specification:

- **Endpoint**: `GET /1.0/search/countries`
- **Parameters**: None accepted
- **Authentication**: Requires valid API key in `x-api-key` header
- **Response format**: JSON with paginated country list
- **Rate limiting**: Subject to API rate limits

For complete API documentation, visit: [setlist.fm API Documentation](https://api.setlist.fm/docs/1.0/index.html)
