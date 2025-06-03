# Endpoint: GET /1.0/search/venues

## Overview

Search for venues by name, city, country, state, or state code. Returns a paginated list of matching venues.

- **Official Docs:** [setlist.fm API: /1.0/search/venues](https://api.setlist.fm/docs/1.0/resource__1.0_search_venues.html)

## Request

- **Method:** GET
- **URL:** `https://api.setlist.fm/1.0/search/venues`
- **Headers:**
  - `x-api-key: <YOUR_API_KEY>` (required)
  - `Accept: application/json` (recommended)
  - `Accept-Language: <language-code>` (optional)

## Query Parameters

| Name      | Type   | Description                                      | Default | Constraints |
|-----------|--------|--------------------------------------------------|---------|-------------|
| cityId    | string | The city's geoId                                 |         |             |
| cityName  | string | Name of the city where the venue is located      |         |             |
| country   | string | The city's country                               |         |             |
| name      | string | Name of the venue                                |         |             |
| p         | int    | The number of the result page you'd like to have | 1       | int         |
| state     | string | The city's state                                 |         |             |
| stateCode | string | The city's state code                            |         |             |

## Response

- **Status:** 200 OK (on success)
- **Content-Type:** `application/json` (if requested)
- **Body:** Venues object (paginated)

### Venues Object (JSON)

| Field         | Type    | Description                        |
|-------------- |---------|------------------------------------|
| venue         | array   | Array of venue objects             |
| total         | int     | Total number of venues             |
| page          | int     | Current page number                |
| itemsPerPage  | int     | Number of items per page           |

#### Example Response

```json
{
  "venue": [
    {
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
    {
      "city": {
        "id": "...",
        "name": "...",
        "stateCode": "...",
        "state": "...",
        "coords": {},
        "country": {}
      },
      "url": "...",
      "id": "...",
      "name": "..."
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
GET /1.0/search/venues?name=Compaq%20Center&cityName=Hollywood&country=US&p=1 HTTP/1.1
Host: api.setlist.fm
Accept: application/json
x-api-key: <YOUR_API_KEY>
```

### cURL
```sh
curl -H "Accept: application/json" \
     -H "x-api-key: <YOUR_API_KEY>" \
     "https://api.setlist.fm/1.0/search/venues?name=Compaq%20Center&cityName=Hollywood&country=US&p=1"
```

## Error Responses

- **404 Not Found:** If no venues match the search criteria.
- **401 Unauthorized:** If the API key is missing or invalid.
- **429 Too Many Requests:** If rate limits are exceeded.

Error responses are returned as an `error` object:
```json
{
  "error": "Description of the error"
}
```

## Usage Notes

- At least one of `name`, `cityId`, `cityName`, `country`, `state`, or `stateCode` should be provided for meaningful results.
- The `p` query parameter is used for pagination (default is 1).
- Always include your API key in the `x-api-key` header.
- Use the `Accept` header to specify JSON for easier parsing.
- For more details, see the [official endpoint documentation](https://api.setlist.fm/docs/1.0/resource__1.0_search_venues.html).

## References
- [setlist.fm API: /1.0/search/venues](https://api.setlist.fm/docs/1.0/resource__1.0_search_venues.html) 