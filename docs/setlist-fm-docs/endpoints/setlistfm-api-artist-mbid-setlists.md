# Endpoint: GET /1.0/artist/{mbid}/setlists

## Overview

Retrieves a paginated list of setlists for a given artist, identified by their Musicbrainz MBID.

- **Official Docs:** [setlist.fm API: /1.0/artist/{mbid}/setlists](https://api.setlist.fm/docs/1.0/resource__1.0_artist__mbid__setlists.html)

## Request

- **Method:** GET
- **URL:** `https://api.setlist.fm/1.0/artist/{mbid}/setlists`
- **Headers:**
  - `x-api-key: <YOUR_API_KEY>` (required)
  - `Accept: application/json` (recommended)
  - `Accept-Language: <language-code>` (optional)

## Path Parameters

| Name | Type   | Description                                                      |
|------|--------|------------------------------------------------------------------|
| mbid | string | Musicbrainz MBID (e.g. `0bfba3d3-6a04-4779-bb0a-df07df5b0558`)   |

## Query Parameters

| Name | Type | Description                        | Default | Constraints |
|------|------|------------------------------------|---------|-------------|
| p    | int  | The number of the result page      | 1       | >= 1        |

## Response

- **Status:** 200 OK (on success)
- **Content-Type:** `application/json` (if requested)
- **Body:** Setlists object (paginated)

### Setlists Object (JSON)

| Field         | Type    | Description                        |
|-------------- |---------|------------------------------------|
| setlist       | array   | Array of setlist objects           |
| total         | int     | Total number of setlists           |
| page          | int     | Current page number                |
| itemsPerPage  | int     | Number of items per page           |

#### Example Response

```json
{
  "setlist": [
    {
      "artist": {
        "mbid": "b10bbbfc-cf9e-42e0-be17-e2c3e1d2600d",
        "name": "The Beatles",
        "sortName": "Beatles, The",
        "disambiguation": "John, Paul, George and Ringo",
        "url": "https://www.setlist.fm/setlists/the-beatles-23d6a88b.html"
      },
      "venue": {
        "city": {},
        "url": "https://www.setlist.fm/venue/compaq-center-san-jose-ca-usa-6bd6ca6e.html",
        "id": "6bd6ca6e",
        "name": "Compaq Center"
      },
      "tour": {
        "name": "North American Tour 1964"
      },
      "set": [
        {
          "name": "...",
          "encore": 12345,
          "song": [{}, {}]
        }
      ],
      "info": "Recorded and published as 'The Beatles at the Hollywood Bowl'",
      "url": "https://www.setlist.fm/setlist/the-beatles/1964/hollywood-bowl-hollywood-ca-63de4613.html",
      "id": "63de4613",
      "versionId": "7be1aaa0",
      "eventDate": "23-08-1964",
      "lastUpdated": "2013-10-20T05:18:08.000+0000"
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
GET /1.0/artist/b10bbbfc-cf9e-42e0-be17-e2c3e1d2600d/setlists?p=1 HTTP/1.1
Host: api.setlist.fm
Accept: application/json
x-api-key: <YOUR_API_KEY>
```

### cURL
```sh
curl -H "Accept: application/json" \
     -H "x-api-key: <YOUR_API_KEY>" \
     "https://api.setlist.fm/1.0/artist/b10bbbfc-cf9e-42e0-be17-e2c3e1d2600d/setlists?p=1"
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
- The `p` query parameter is used for pagination (default is 1).
- Always include your API key in the `x-api-key` header.
- Use the `Accept` header to specify JSON for easier parsing.
- For more details, see the [official endpoint documentation](https://api.setlist.fm/docs/1.0/resource__1.0_artist__mbid__setlists.html).

## References
- [setlist.fm API: /1.0/artist/{mbid}/setlists](https://api.setlist.fm/docs/1.0/resource__1.0_artist__mbid__setlists.html)
- [Musicbrainz MBID](http://wiki.musicbrainz.org/MBID) 