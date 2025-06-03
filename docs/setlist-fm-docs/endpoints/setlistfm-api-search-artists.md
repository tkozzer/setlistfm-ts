# Endpoint: GET /1.0/search/artists

## Overview

Search for artists by name, Musicbrainz MBID, or Ticketmaster ID (deprecated).

- **Official Docs:** [setlist.fm API: /1.0/search/artists](https://api.setlist.fm/docs/1.0/resource__1.0_search_artists.html)

## Request

- **Method:** GET
- **URL:** `https://api.setlist.fm/1.0/search/artists`
- **Headers:**
  - `x-api-key: <YOUR_API_KEY>` (required)
  - `Accept: application/json` (recommended)
  - `Accept-Language: <language-code>` (optional)

## Query Parameters

| Name       | Type   | Description                                                    | Default  | Constraints |
|------------|--------|----------------------------------------------------------------|----------|-------------|
| artistMbid | string | The artist's Musicbrainz Identifier (mbid)                    |          |             |
| artistName | string | The artist's name                                              |          |             |
| artistTmid | int    | The artist's Ticketmaster Identifier (deprecated)              |          |             |
| p          | int    | The number of the result page you'd like to have               | 1        | >= 1        |
| sort       | string | The sort of the result, either sortName (default) or relevance | sortName |             |

## Response

- **Status:** 200 OK (on success)
- **Content-Type:** `application/json` (if requested)
- **Body:** Artists object (paginated)

### Artists Object (JSON)

| Field         | Type    | Description                        |
|-------------- |---------|------------------------------------|
| artist        | array   | Array of artist objects            |
| total         | int     | Total number of artists            |
| page          | int     | Current page number                |
| itemsPerPage  | int     | Number of items per page           |

#### Example Response

```json
{
  "artist": [
    {
      "mbid": "b10bbbfc-cf9e-42e0-be17-e2c3e1d2600d",
      "name": "The Beatles",
      "sortName": "Beatles, The",
      "disambiguation": "John, Paul, George and Ringo",
      "url": "https://www.setlist.fm/setlists/the-beatles-23d6a88b.html"
    },
    {
      "mbid": "...",
      "name": "...",
      "sortName": "...",
      "disambiguation": "...",
      "url": "..."
    }
  ],
  "total": 42,
  "page": 1,
  "itemsPerPage": 20
}
```

## Example Request

### HTTP
```http
GET /1.0/search/artists?artistName=The%20Beatles&p=1 HTTP/1.1
Host: api.setlist.fm
Accept: application/json
x-api-key: <YOUR_API_KEY>
```

### cURL
```sh
curl -H "Accept: application/json" \
     -H "x-api-key: <YOUR_API_KEY>" \
     "https://api.setlist.fm/1.0/search/artists?artistName=The%20Beatles&p=1"
```

## Error Responses

- **404 Not Found:** If no artists match the search criteria.
- **401 Unauthorized:** If the API key is missing or invalid.
- **429 Too Many Requests:** If rate limits are exceeded.

Error responses are returned as an `error` object:
```json
{
  "error": "Description of the error"
}
```

## Usage Notes

- At least one of `artistMbid`, `artistName`, or `artistTmid` should be provided.
- The `p` query parameter is used for pagination (default is 1).
- The `sort` parameter can be `sortName` (default) or `relevance`.
- Always include your API key in the `x-api-key` header.
- Use the `Accept` header to specify JSON for easier parsing.
- For more details, see the [official endpoint documentation](https://api.setlist.fm/docs/1.0/resource__1.0_search_artists.html).

## References
- [setlist.fm API: /1.0/search/artists](https://api.setlist.fm/docs/1.0/resource__1.0_search_artists.html)
- [Musicbrainz MBID](http://wiki.musicbrainz.org/MBID) 