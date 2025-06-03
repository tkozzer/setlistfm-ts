# Endpoint: GET /1.0/search/cities

## Overview

Search for a city by name, country, state, or state code. Returns a paginated list of matching cities.

- **Official Docs:** [setlist.fm API: /1.0/search/cities](https://api.setlist.fm/docs/1.0/resource__1.0_search_cities.html)

## Request

- **Method:** GET
- **URL:** `https://api.setlist.fm/1.0/search/cities`
- **Headers:**
  - `x-api-key: <YOUR_API_KEY>` (required)
  - `Accept: application/json` (recommended)
  - `Accept-Language: <language-code>` (optional)

## Query Parameters

| Name      | Type   | Description                                      | Default | Constraints |
|-----------|--------|--------------------------------------------------|---------|-------------|
| country   | string | The city's country                               |         |             |
| name      | string | Name of the city                                 |         |             |
| p         | int    | The number of the result page you'd like to have | 1       | >= 1        |
| state     | string | State the city lies in                           |         |             |
| stateCode | string | State code the city lies in                      |         |             |

## Response

- **Status:** 200 OK (on success)
- **Content-Type:** `application/json` (if requested)
- **Body:** Cities object (paginated)

### Cities Object (JSON)

| Field         | Type    | Description                        |
|-------------- |---------|------------------------------------|
| cities        | array   | Array of city objects              |
| total         | int     | Total number of cities             |
| page          | int     | Current page number                |
| itemsPerPage  | int     | Number of items per page           |

#### Example Response

```json
{
  "cities": [
    {
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
    {
      "id": "...",
      "name": "...",
      "stateCode": "...",
      "state": "...",
      "coords": {
        "long": 12345.0,
        "lat": 12345.0
      },
      "country": {
        "code": "...",
        "name": "..."
      }
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
GET /1.0/search/cities?name=Hollywood&country=US&p=1 HTTP/1.1
Host: api.setlist.fm
Accept: application/json
x-api-key: <YOUR_API_KEY>
```

### cURL
```sh
curl -H "Accept: application/json" \
     -H "x-api-key: <YOUR_API_KEY>" \
     "https://api.setlist.fm/1.0/search/cities?name=Hollywood&country=US&p=1"
```

## Error Responses

- **404 Not Found:** If no cities match the search criteria.
- **401 Unauthorized:** If the API key is missing or invalid.
- **429 Too Many Requests:** If rate limits are exceeded.

Error responses are returned as an `error` object:
```json
{
  "error": "Description of the error"
}
```

## Usage Notes

- At least one of `name`, `country`, `state`, or `stateCode` should be provided for meaningful results.
- The `p` query parameter is used for pagination (default is 1).
- Always include your API key in the `x-api-key` header.
- Use the `Accept` header to specify JSON for easier parsing.
- For more details, see the [official endpoint documentation](https://api.setlist.fm/docs/1.0/resource__1.0_search_cities.html).

## References
- [setlist.fm API: /1.0/search/cities](https://api.setlist.fm/docs/1.0/resource__1.0_search_cities.html)
- [GeoNames](http://geonames.org/) 