# Endpoint: GET /1.0/venue/{venueId}

## Overview

Get a venue by its unique id.

- **Official Docs:** [setlist.fm API: /1.0/venue/{venueId}](https://api.setlist.fm/docs/1.0/resource__1.0_venue__venueId_.html)

## Request

- **Method:** GET
- **URL:** `https://api.setlist.fm/1.0/venue/{venueId}`
- **Headers:**
  - `x-api-key: <YOUR_API_KEY>` (required)
  - `Accept: application/json` (recommended)
  - `Accept-Language: <language-code>` (optional)

## Path Parameters

| Name    | Type   | Description      |
|---------|--------|------------------|
| venueId | string | The venue's id   |

## Response

- **Status:** 200 OK (on success)
- **Content-Type:** `application/json` (if requested)
- **Body:** Venue object

### Venue Object (JSON)

| Field   | Type   | Description                        |
|---------|--------|------------------------------------|
| city    | object | City object (id, name, state, etc.)|
| url     | string | URL to the venue on setlist.fm      |
| id      | string | Venue ID                            |
| name    | string | Venue name                          |

#### Example Response

```json
{
  "city": {
    "id": "5357527",
    "name": "Hollywood",
    "stateCode": "CA",
    "state": "California",
    "coords": {
      "long": -118.3267434,
      "lat": 34.0983425
    },
    "country": {
      "code": "US",
      "name": "United States"
    }
  },
  "url": "https://www.setlist.fm/venue/compaq-center-san-jose-ca-usa-6bd6ca6e.html",
  "id": "6bd6ca6e",
  "name": "Compaq Center"
}
```

## Example Request

### HTTP
```http
GET /1.0/venue/6bd6ca6e HTTP/1.1
Host: api.setlist.fm
Accept: application/json
x-api-key: <YOUR_API_KEY>
```

### cURL
```sh
curl -H "Accept: application/json" \
     -H "x-api-key: <YOUR_API_KEY>" \
     "https://api.setlist.fm/1.0/venue/6bd6ca6e"
```

## Error Responses

- **404 Not Found:** If the venueId does not exist or is invalid.
- **401 Unauthorized:** If the API key is missing or invalid.
- **429 Too Many Requests:** If rate limits are exceeded.

Error responses are returned as an `error` object:
```json
{
  "error": "Description of the error"
}
```

## Usage Notes

- The venueId must be a valid setlist.fm venue identifier.
- Always include your API key in the `x-api-key` header.
- Use the `Accept` header to specify JSON for easier parsing.
- For more details, see the [official endpoint documentation](https://api.setlist.fm/docs/1.0/resource__1.0_venue__venueId_.html).

## References
- [setlist.fm API: /1.0/venue/{venueId}](https://api.setlist.fm/docs/1.0/resource__1.0_venue__venueId_.html) 