# Endpoint: GET /1.0/artist/{mbid}

## Overview

Retrieves an artist for a given Musicbrainz MBID (unique identifier for artists in the Musicbrainz database).

- **Official Docs:** [setlist.fm API: /1.0/artist/{mbid}](https://api.setlist.fm/docs/1.0/resource__1.0_artist__mbid_.html)

## Request

- **Method:** GET
- **URL:** `https://api.setlist.fm/1.0/artist/{mbid}`
- **Headers:**
  - `x-api-key: <YOUR_API_KEY>` (required)
  - `Accept: application/json` (recommended)
  - `Accept-Language: <language-code>` (optional)

## Path Parameters

| Name | Type   | Description                                                      |
|------|--------|------------------------------------------------------------------|
| mbid | string | Musicbrainz MBID (e.g. `0bfba3d3-6a04-4779-bb0a-df07df5b0558`)   |

## Response

- **Status:** 200 OK (on success)
- **Content-Type:** `application/json` (if requested)
- **Body:** Artist object

### Artist Object (JSON)

| Field           | Type   | Description                                   |
|-----------------|--------|-----------------------------------------------|
| mbid            | string | Musicbrainz MBID of the artist                |
| name            | string | Name of the artist                            |
| sortName        | string | Sortable name (e.g., "Beatles, The")         |
| disambiguation  | string | Additional info to distinguish the artist      |
| url             | string | URL to the artist's setlists on setlist.fm     |

#### Example Response

```json
{
  "mbid": "b10bbbfc-cf9e-42e0-be17-e2c3e1d2600d",
  "name": "The Beatles",
  "sortName": "Beatles, The",
  "disambiguation": "John, Paul, George and Ringo",
  "url": "https://www.setlist.fm/setlists/the-beatles-23d6a88b.html"
}
```

## Example Request

### HTTP
```http
GET /1.0/artist/b10bbbfc-cf9e-42e0-be17-e2c3e1d2600d HTTP/1.1
Host: api.setlist.fm
Accept: application/json
x-api-key: <YOUR_API_KEY>
```

### cURL
```sh
curl -H "Accept: application/json" \
     -H "x-api-key: <YOUR_API_KEY>" \
     "https://api.setlist.fm/1.0/artist/b10bbbfc-cf9e-42e0-be17-e2c3e1d2600d"
```

## Error Responses

- **404 Not Found:** If the MBID does not exist or is invalid.
- **401 Unauthorized:** If the API key is missing or invalid.
- **429 Too Many Requests:** If rate limits are exceeded.

Error responses are returned as an `error` object:
```json
{
  "error": "Description of the error"
}
```

## Usage Notes

- The MBID must be a valid Musicbrainz identifier.
- Always include your API key in the `x-api-key` header.
- Use the `Accept` header to specify JSON for easier parsing.
- For more details, see the [official endpoint documentation](https://api.setlist.fm/docs/1.0/resource__1.0_artist__mbid_.html).

## References
- [setlist.fm API: /1.0/artist/{mbid}](https://api.setlist.fm/docs/1.0/resource__1.0_artist__mbid_.html)
- [Musicbrainz MBID](http://wiki.musicbrainz.org/MBID) 