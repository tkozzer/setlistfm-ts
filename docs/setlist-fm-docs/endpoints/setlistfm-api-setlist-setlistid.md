# Endpoint: GET /1.0/setlist/{setlistId}

## Overview

Returns the current version of a setlist for the provided setlist ID. If the setlist has been edited since you last accessed it, you'll get the most recent version.

- **Official Docs:** [setlist.fm API: /1.0/setlist/{setlistId}](https://api.setlist.fm/docs/1.0/resource__1.0_setlist__setlistId_.html)

## Request

- **Method:** GET
- **URL:** `https://api.setlist.fm/1.0/setlist/{setlistId}`
- **Headers:**
  - `x-api-key: <YOUR_API_KEY>` (required)
  - `Accept: application/json` (recommended)
  - `Accept-Language: <language-code>` (optional)

## Path Parameters

| Name      | Type   | Description         |
|-----------|--------|---------------------|
| setlistId | string | The setlist id      |

## Response

- **Status:** 200 OK (on success)
- **Content-Type:** `application/json` (if requested)
- **Body:** Setlist object

### Setlist Object (JSON)

| Field        | Type    | Description                        |
|------------- |---------|------------------------------------|
| artist       | object  | Artist object                      |
| venue        | object  | Venue object                       |
| tour         | object  | Tour object                        |
| set          | array   | Array of set objects               |
| info         | string  | Additional info                    |
| url          | string  | URL to the setlist on setlist.fm   |
| id           | string  | Setlist ID                         |
| versionId    | string  | Version ID of the setlist          |
| eventDate    | string  | Date of the event (dd-MM-yyyy)     |
| lastUpdated  | string  | Last updated timestamp             |

#### Example Response

```json
{
  "artist": {
    "mbid": "b10bbbfc-cf9e-42e0-be17-e2c3e1d2600d",
    "name": "The Beatles",
    "sortName": "Beatles, The",
    "disambiguation": "John, Paul, George and Ringo",
    "url": "https://www.setlist.fm/setlists/the-beatles-23d6a88b.html"
  },
  "venue": {
    "city": {
      "id": "5357527",
      "name": "Hollywood",
      "stateCode": "CA",
      "state": "California",
      "coords": {},
      "country": {}
    },
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
      "song": [
        {
          "name": "Yesterday",
          "with": {},
          "cover": {},
          "info": "...",
          "tape": false
        },
        {
          "name": "...",
          "with": {},
          "cover": {},
          "info": "...",
          "tape": true
        }
      ]
    },
    {
      "name": "...",
      "encore": 12345,
      "song": [
        {
          "name": "...",
          "with": {},
          "cover": {},
          "info": "...",
          "tape": true
        },
        {
          "name": "...",
          "with": {},
          "cover": {},
          "info": "...",
          "tape": true
        }
      ]
    }
  ],
  "info": "Recorded and published as 'The Beatles at the Hollywood Bowl'",
  "url": "https://www.setlist.fm/setlist/the-beatles/1964/hollywood-bowl-hollywood-ca-63de4613.html",
  "id": "63de4613",
  "versionId": "7be1aaa0",
  "eventDate": "23-08-1964",
  "lastUpdated": "2013-10-20T05:18:08.000+0000"
}
```

## Example Request

### HTTP
```http
GET /1.0/setlist/63de4613 HTTP/1.1
Host: api.setlist.fm
Accept: application/json
x-api-key: <YOUR_API_KEY>
```

### cURL
```sh
curl -H "Accept: application/json" \
     -H "x-api-key: <YOUR_API_KEY>" \
     "https://api.setlist.fm/1.0/setlist/63de4613"
```

## Error Responses

- **404 Not Found:** If the setlistId does not exist or is invalid.
- **401 Unauthorized:** If the API key is missing or invalid.
- **429 Too Many Requests:** If rate limits are exceeded.

Error responses are returned as an `error` object:
```json
{
  "error": "Description of the error"
}
```

## Usage Notes

- The setlistId must be a valid setlist identifier.
- Always include your API key in the `x-api-key` header.
- Use the `Accept` header to specify JSON for easier parsing.
- For more details, see the [official endpoint documentation](https://api.setlist.fm/docs/1.0/resource__1.0_setlist__setlistId_.html).

## References
- [setlist.fm API: /1.0/setlist/{setlistId}](https://api.setlist.fm/docs/1.0/resource__1.0_setlist__setlistId_.html) 