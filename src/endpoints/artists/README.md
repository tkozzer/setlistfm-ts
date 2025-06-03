# Artists Endpoints

This module provides methods for interacting with artist-related endpoints in the setlist.fm API.

## Overview

Artists in the setlist.fm API represent musicians or groups of musicians. Each artist is uniquely identified by a MusicBrainz Identifier (MBID).

## Available Functions

### `getArtist(httpClient: HttpClient, mbid: MBID)`

Retrieves an artist for a given MusicBrainz MBID.

**Parameters:**

- `httpClient` (HttpClient): The HTTP client instance
- `mbid` (MBID): MusicBrainz MBID, e.g., `"b10bbbfc-cf9e-42e0-be17-e2c3e1d2600d"`

**Returns:** `Promise<Artist>`

**Example:**

```typescript
import type { HttpClient } from "@utils/http";
import { getArtist } from "./getArtist";

const artist = await getArtist(httpClient, "b10bbbfc-cf9e-42e0-be17-e2c3e1d2600d");

console.log(artist.name); // "The Beatles"

console.log(artist.sortName); // "Beatles, The"
```

**API Reference:** [GET /1.0/artist/{mbid}](https://api.setlist.fm/docs/1.0/resource__1.0_artist__mbid_.html)

### `searchArtists(httpClient: HttpClient, params: SearchArtistsParams)`

Searches for artists using various criteria. At least one search parameter must be provided.

**Parameters:**

- `httpClient` (HttpClient): The HTTP client instance
- `params` (SearchArtistsParams): Search parameters object containing:
  - `artistName` (string, optional): Name of the artist to search for
  - `artistMbid` (MBID, optional): MusicBrainz MBID of the artist
  - `artistTmid` (number, optional): Ticketmaster ID (deprecated)
  - `p` (number, optional): Page number for pagination (default: 1)
  - `sort` ("sortName" | "relevance", optional): Sort order for results

**Returns:** `Promise<Artists>`

**Example:**

```typescript
import { searchArtists } from "./searchArtists";

// Search by artist name
const results = await searchArtists(httpClient, {
  artistName: "The Beatles"
});

console.log(results.total); // Total number of matching artists

console.log(results.artist); // Array of artist objects

// Search with pagination and sorting
const page2 = await searchArtists(httpClient, {
  artistName: "Beatles",
  p: 2,
  sort: "relevance"
});

// Search by MBID
const artistByMbid = await searchArtists(httpClient, {
  artistMbid: "b10bbbfc-cf9e-42e0-be17-e2c3e1d2600d"
});
```

### `getArtistSetlists(httpClient: HttpClient, mbid: MBID, params?: GetArtistSetlistsParams)`

Retrieves setlists for a specific artist.

**Parameters:**

- `httpClient` (HttpClient): The HTTP client instance
- `mbid` (MBID): MusicBrainz MBID of the artist
- `params` (GetArtistSetlistsParams, optional): Pagination parameters:
  - `p` (number, optional): Page number for pagination (default: 1)

**Returns:** `Promise<Setlists>`

**Example:**

```typescript
import { getArtistSetlists } from "./getArtistSetlists";

// Get first page of setlists
const setlists = await getArtistSetlists(httpClient, "b10bbbfc-cf9e-42e0-be17-e2c3e1d2600d");

console.log(setlists.total); // Total number of setlists

console.log(setlists.setlist.length); // Number of setlists on this page

// Get specific page
const page2 = await getArtistSetlists(httpClient, "b10bbbfc-cf9e-42e0-be17-e2c3e1d2600d", { p: 2 });
```

**API Reference:** [GET /1.0/artist/{mbid}/setlists](https://api.setlist.fm/docs/1.0/resource__1.0_artist__mbid__setlists.html)

## Data Types

### Artist

Represents an individual artist or group.

```typescript
type Artist = {
  /** MusicBrainz identifier */
  mbid: MBID;
  /** Artist name */
  name: string;
  /** Sort name for the artist (e.g., "Beatles, The" or "Springsteen, Bruce") */
  sortName: string;
  /** Disambiguation string to distinguish between artists with same names */
  disambiguation?: string;
  /** URL to the artist's setlists on setlist.fm */
  url?: string;
};
```

### Artists

Represents a paginated response containing artists from the search endpoint.

```typescript
type Artists = {
  /** Array of artist objects */
  artist: Artist[];
  /** Total number of matching artists */
  total: number;
  /** Current page number (starts at 1) */
  page: number;
  /** Number of items per page */
  itemsPerPage: number;
};
```

### Setlists

Represents a paginated response containing setlists for an artist.

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

### SearchArtistsParams

Parameters for searching artists.

```typescript
type SearchArtistsParams = PaginationParams & {
  /** The artist's name */
  artistName?: string;
  /** The artist's Musicbrainz Identifier (mbid) */
  artistMbid?: string;
  /** The artist's Ticketmaster Identifier (deprecated) */
  artistTmid?: number;
  /** The sort of the result, either sortName (default) or relevance */
  sort?: "sortName" | "relevance";
};
```

### GetArtistSetlistsParams

Parameters for retrieving setlists for a specific artist.

```typescript
type GetArtistSetlistsParams = PaginationParams;
```

## Validation

All functions use Zod schemas for input validation:

- **MBID validation**: Ensures MBIDs are valid UUIDs
- **Parameter validation**: Validates pagination parameters and search criteria
- **Required fields**: `searchArtists` requires at least one search parameter

## Usage Notes

- **MusicBrainz MBID**: All artist identification uses MusicBrainz MBIDs, which are unique identifiers in UUID format.
- **Pagination**: Search results are paginated. Use the `p` parameter to navigate through results.
- **Search Requirements**: `searchArtists` requires at least one of `artistName`, `artistMbid`, or `artistTmid`.
- **Disambiguation**: The `disambiguation` field helps distinguish between artists with identical or similar names.
- **Rate Limiting**: Be mindful of API rate limits when making multiple requests.

## Error Handling

All functions can throw the following errors:

- **`ValidationError`**: When input parameters are invalid or missing
- **`NotFoundError`**: When the requested resource is not found (404)
- **`AuthenticationError`**: When the API key is invalid (401)
- **`SetlistFMAPIError`**: For other API errors (rate limiting, server errors, etc.)

## Complete Usage Example

```typescript
import type { HttpClient } from "@utils/http";
import { getArtist, getArtistSetlists, searchArtists } from "./index";

// Assume you have an httpClient instance configured with API key and user agent

async function demonstrateArtistEndpoints(httpClient: HttpClient) {
  try {
    // 1. Search for artists by name
    const searchResults = await searchArtists(httpClient, {
      artistName: "The Beatles",
      p: 1,
      sort: "relevance"
    });

    console.log(`Found ${searchResults.total} artists matching "The Beatles"`);

    if (searchResults.artist.length > 0) {
      const firstArtist = searchResults.artist[0];

      console.log(`First result: ${firstArtist.name} (${firstArtist.mbid})`);

      // 2. Get detailed artist information
      const artist = await getArtist(httpClient, firstArtist.mbid);

      console.log(`Artist details: ${artist.name} - ${artist.sortName}`);

      // 3. Get artist's setlists
      const setlists = await getArtistSetlists(httpClient, artist.mbid, { p: 1 });

      console.log(`Found ${setlists.total} setlists for ${artist.name}`);

      if (setlists.setlist.length > 0) {
        const latestSetlist = setlists.setlist[0];

        console.log(`Latest setlist: ${latestSetlist.eventDate} at ${latestSetlist.venue.name}`);
      }
    }
  }
  catch (error) {
    console.error("Error fetching artist data:", error);
  }
}
```

## API Reference

- [setlist.fm API: artist Data Type](https://api.setlist.fm/docs/1.0/json_Artist.html)
- [setlist.fm API: artists Data Type](https://api.setlist.fm/docs/1.0/json_Artists.html)
- [setlist.fm API: GET /1.0/artist/{mbid}](https://api.setlist.fm/docs/1.0/resource__1.0_artist__mbid_.html)
- [setlist.fm API: GET /1.0/search/artists](https://api.setlist.fm/docs/1.0/resource__1.0_search_artists.html)
- [setlist.fm API: GET /1.0/artist/{mbid}/setlists](https://api.setlist.fm/docs/1.0/resource__1.0_artist__mbid__setlists.html)
- [MusicBrainz MBID Reference](http://wiki.musicbrainz.org/MBID)
