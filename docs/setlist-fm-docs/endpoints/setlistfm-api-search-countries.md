# Endpoint: GET /1.0/search/countries

## Overview

Get a complete list of all supported countries.

- **Official Docs:** [setlist.fm API: /1.0/search/countries](https://api.setlist.fm/docs/1.0/resource__1.0_search_countries.html)

## Request

- **Method:** GET
- **URL:** `https://api.setlist.fm/1.0/search/countries`
- **Headers:**
  - `x-api-key: <YOUR_API_KEY>` (required)
  - `Accept: application/json` (recommended)
  - `Accept-Language: <language-code>` (optional)

## Query Parameters

This endpoint does not accept any query parameters.

## Response

- **Status:** 200 OK (on success)
- **Content-Type:** `application/json` (if requested)
- **Body:** Countries object (paginated)

### Countries Object (JSON)

| Field         | Type    | Description                        |
|-------------- |---------|------------------------------------|
| country       | array   | Array of country objects           |
| total         | int     | Total number of countries          |
| page          | int     | Current page number                |
| itemsPerPage  | int     | Number of items per page           |

#### Example Response

```json
{
  "country": [
    {
      "code": "US",
      "name": "United States"
    },
    {
      "code": "...",
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
GET /1.0/search/countries HTTP/1.1
Host: api.setlist.fm
Accept: application/json
x-api-key: <YOUR_API_KEY>
```

### cURL
```sh
curl -H "Accept: application/json" \
     -H "x-api-key: <YOUR_API_KEY>" \
     "https://api.setlist.fm/1.0/search/countries"
```

## Error Responses

- **401 Unauthorized:** If the API key is missing or invalid.
- **429 Too Many Requests:** If rate limits are exceeded.

Error responses are returned as an `error` object:
```json
{
  "error": "Description of the error"
}
```

## Usage Notes

- Always include your API key in the `x-api-key` header.
- Use the `Accept` header to specify JSON for easier parsing.
- For more details, see the [official endpoint documentation](https://api.setlist.fm/docs/1.0/resource__1.0_search_countries.html).

## References
- [setlist.fm API: /1.0/search/countries](https://api.setlist.fm/docs/1.0/resource__1.0_search_countries.html) 