# Setlists Endpoints

This module provides functions for interacting with setlist.fm's setlist endpoints, allowing you to retrieve individual setlists and search for setlists using various criteria.

## Available Functions

- **[`getSetlist`](#getsetlist)** - Get a setlist by ID
- **[`searchSetlists`](#searchsetlists)** - Search for setlists using filters

## Types

### Core Types

```typescript
/**
 * Represents a complete setlist from the setlist.fm API.
 */
type Setlist = {
  artist: Artist; // The setlist's artist
  venue: Venue; // The setlist's venue
  tour?: Tour; // The setlist's tour (optional)
  set: Set[]; // All sets of this setlist
  info?: string; // Additional information on the concert
  url: string; // The attribution URL to setlist.fm
  id: string; // Unique identifier for the setlist
  versionId: string; // Unique identifier of the setlist version
  eventDate: string; // Date of the concert in dd-MM-yyyy format
  lastUpdated: string; // Date and time of the last update
};

/**
 * Represents a paginated response containing setlists.
 */
type Setlists = {
  setlist: Setlist[]; // Array of setlist objects
  total: number; // Total number of setlists matching the query
  page: number; // Current page number (starts at 1)
  itemsPerPage: number; // Number of items per page
};

/**
 * Represents a set in a setlist (e.g., main set, encore).
 */
type Set = {
  name?: string; // The description/name of the set
  encore?: number; // If the set is an encore, this is the number
  song: Song[]; // This set's songs
};

/**
 * Represents a song in a setlist with performance details.
 */
type Song = {
  name: string; // The name of the song
  with?: Artist; // Guest artist that joined for this song
  cover?: Artist; // Original artist if different from performer
  info?: string; // Special incidents or additional information
  tape: boolean; // Whether the song came from tape
};

/**
 * Represents a tour a setlist was part of.
 */
type Tour = {
  name: string; // The name of the tour
};
```

### Parameter Types

```typescript
/**
 * Parameters for getting a setlist by ID.
 */
type GetSetlistParams = {
  setlistId: string; // The setlist ID (8-character hex string)
};

/**
 * Parameters for searching setlists with various filters.
 */
type SearchSetlistsParams = PaginationParams & {
  artistMbid?: string; // The artist's Musicbrainz Identifier
  artistName?: string; // The artist's name
  artistTmid?: number; // The artist's Ticketmaster ID (deprecated)
  cityId?: string; // The city's geoId
  cityName?: string; // The name of the city
  countryCode?: string; // The country code (2 characters)
  date?: string; // The date of the event (dd-MM-yyyy format)
  lastFm?: number; // The event's Last.fm Event ID (deprecated)
  lastUpdated?: string; // Last updated timestamp (yyyyMMddHHmmss)
  state?: string; // The state
  stateCode?: string; // The state code
  tourName?: string; // The tour name
  venueId?: string; // The venue id
  venueName?: string; // The name of the venue
  year?: number; // The year of the event (1900-current+10)
};
```

## Functions

### getSetlist

Retrieves a specific setlist by its ID.

```typescript
import type { Setlist } from "./setlists";
import { getSetlist } from "./setlists";

// Get a specific setlist
const setlist: Setlist = await getSetlist(httpClient, "63de4613");

console.log(setlist.artist.name); // "The Beatles"
console.log(setlist.venue.name); // "Hollywood Bowl"
console.log(setlist.eventDate); // "23-08-1964"
console.log(setlist.set.length); // Number of sets
```

**Parameters:**

- `httpClient: HttpClient` - The HTTP client instance
- `setlistId: string` - The setlist ID (8-character hexadecimal string)

**Returns:** `Promise<Setlist>` - The setlist data

**Throws:**

- `ValidationError` - If the setlist ID is invalid
- `NotFoundError` - If the setlist doesn't exist
- `AuthenticationError` - If the API key is invalid
- `SetlistFMAPIError` - For other API errors

### searchSetlists

Searches for setlists using a wide range of filters.

```typescript
import type { SearchSetlistsParams, Setlists } from "./setlists";
import { searchSetlists } from "./setlists";

// Search by artist name
const results: Setlists = await searchSetlists(httpClient, {
  artistName: "The Beatles"
});

console.log(results.total); // Total number of matching setlists
console.log(results.setlist.length); // Number of setlists on this page

// Search with multiple criteria
const filteredResults: Setlists = await searchSetlists(httpClient, {
  artistName: "The Beatles",
  cityName: "Hollywood",
  year: 1964,
  p: 1 // First page
});

// Search by date and venue
const concert: Setlists = await searchSetlists(httpClient, {
  artistMbid: "b10bbbfc-cf9e-42e0-be17-e2c3e1d2600d",
  date: "23-08-1964",
  venueName: "Hollywood Bowl"
});

// Search with pagination
const page2: Setlists = await searchSetlists(httpClient, {
  artistName: "Beatles",
  year: 1964,
  p: 2 // Second page
});
```

**Parameters:**

- `httpClient: HttpClient` - The HTTP client instance
- `params: SearchSetlistsParams` - Search parameters (at least one required)

**Returns:** `Promise<Setlists>` - Paginated setlists search results

**Throws:**

- `ValidationError` - If search parameters are invalid
- `NotFoundError` - If no setlists match the criteria
- `AuthenticationError` - If the API key is invalid
- `SetlistFMAPIError` - For other API errors

## Usage Examples

### Basic Setlist Retrieval

```typescript
import { createSetlistFMClient } from "setlistfm-ts";

const client = createSetlistFMClient({
  apiKey: "your-api-key",
  userAgent: "YourApp/1.0.0"
});

try {
  // Get a specific setlist
  const setlist = await client.setlists.getSetlist("63de4613");

  console.log(`${setlist.artist.name} at ${setlist.venue.name}`);
  console.log(`Date: ${setlist.eventDate}`);
  console.log(`Sets: ${setlist.set.length}`);

  // Display songs from first set
  if (setlist.set[0]?.song) {
    console.log("Songs:");
    setlist.set[0].song.forEach((song, index) => {
      const guestInfo = song.with ? ` (with ${song.with.name})` : "";
      const coverInfo = song.cover ? ` (${song.cover.name} cover)` : "";
      const tapeInfo = song.tape ? " [TAPE]" : "";

      console.log(`${index + 1}. ${song.name}${guestInfo}${coverInfo}${tapeInfo}`);
    });
  }
}
catch (error) {
  console.error("Error fetching setlist:", error.message);
}
```

### Advanced Search

```typescript
import { createSetlistFMClient } from "setlistfm-ts";

const client = createSetlistFMClient({
  apiKey: "your-api-key",
  userAgent: "YourApp/1.0.0"
});

try {
  // Search for recent setlists in a specific city
  const recentSetlists = await client.setlists.searchSetlists({
    cityName: "New York",
    year: 2024,
    p: 1
  });

  console.log(`Found ${recentSetlists.total} setlists in New York for 2024`);

  // Process each setlist
  for (const setlist of recentSetlists.setlist) {
    console.log(`${setlist.artist.name} - ${setlist.eventDate}`);
    console.log(`Venue: ${setlist.venue.name}`);

    if (setlist.tour?.name) {
      console.log(`Tour: ${setlist.tour.name}`);
    }

    console.log(`Songs played: ${setlist.set.reduce((total, set) => total + set.song.length, 0)}`);
    console.log("---");
  }

  // Get next page if available
  if (recentSetlists.page * recentSetlists.itemsPerPage < recentSetlists.total) {
    const nextPage = await client.setlists.searchSetlists({
      cityName: "New York",
      year: 2024,
      p: recentSetlists.page + 1
    });

    console.log(`Page ${nextPage.page} has ${nextPage.setlist.length} more setlists`);
  }
}
catch (error) {
  console.error("Error searching setlists:", error.message);
}
```

### Finding Setlists by Artist and Tour

```typescript
import { createSetlistFMClient } from "setlistfm-ts";

const client = createSetlistFMClient({
  apiKey: "your-api-key",
  userAgent: "YourApp/1.0.0"
});

async function findTourSetlists(artistName: string, tourName: string) {
  try {
    const results = await client.setlists.searchSetlists({
      artistName,
      tourName
    });

    console.log(`Found ${results.total} setlists for ${artistName} - ${tourName}`);

    // Group setlists by year
    const setlistsByYear = results.setlist.reduce((acc, setlist) => {
      const year = setlist.eventDate.split("-")[2]; // Extract year from dd-MM-yyyy
      if (!acc[year])
        acc[year] = [];
      acc[year].push(setlist);
      return acc;
    }, {} as Record<string, typeof results.setlist>);

    // Display results by year
    Object.entries(setlistsByYear).forEach(([year, setlists]) => {
      console.log(`\n${year} (${setlists.length} shows):`);
      setlists.forEach((setlist) => {
        console.log(`  ${setlist.eventDate} - ${setlist.venue.name}, ${setlist.venue.city?.name}`);
      });
    });

    return results;
  }
  catch (error) {
    console.error("Error finding tour setlists:", error.message);
    throw error;
  }
}

// Usage
findTourSetlists("Radiohead", "A Moon Shaped Pool Tour");
```

## Validation

All functions include comprehensive input validation:

- **Setlist IDs** must be 8-character hexadecimal strings
- **Dates** must be in dd-MM-yyyy format
- **Years** must be between 1900 and current year + 10
- **Page numbers** must be positive integers
- **Search parameters** require at least one filter to be provided

## Error Handling

The functions throw specific error types for different scenarios:

```typescript
import {
  AuthenticationError,
  NotFoundError,
  SetlistFMAPIError,
  ValidationError
} from "setlistfm-ts";

try {
  const setlist = await client.setlists.getSetlist("invalid-id");
}
catch (error) {
  if (error instanceof ValidationError) {
    console.error("Invalid input:", error.message);
  }
  else if (error instanceof NotFoundError) {
    console.error("Setlist not found:", error.message);
  }
  else if (error instanceof AuthenticationError) {
    console.error("Authentication failed:", error.message);
  }
  else if (error instanceof SetlistFMAPIError) {
    console.error("API error:", error.message, "Status:", error.statusCode);
  }
  else {
    console.error("Unexpected error:", error.message);
  }
}
```

## References

- [setlist.fm API: GET /1.0/setlist/{setlistId}](https://api.setlist.fm/docs/1.0/resource__1.0_setlist__setlistId_.html)
- [setlist.fm API: GET /1.0/search/setlists](https://api.setlist.fm/docs/1.0/resource__1.0_search_setlists.html)
- [setlist.fm API Documentation](https://api.setlist.fm/docs/1.0/index.html)
