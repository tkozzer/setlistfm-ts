# Endpoint: GET /1.0/city/{geoId}

## Overview

Retrieves a city by its unique GeoNames geoId.

- **Official Docs:** [setlist.fm API: /1.0/city/{geoId}](https://api.setlist.fm/docs/1.0/resource__1.0_city__geoId_.html)

## Request

- **Method:** GET
- **URL:** `https://api.setlist.fm/1.0/city/{geoId}`
- **Headers:**
  - `x-api-key: <YOUR_API_KEY>` (required)
  - `Accept: application/json` (recommended)
  - `Accept-Language: <language-code>` (optional)

## Path Parameters

| Name  | Type   | Description                |
|-------|--------|----------------------------|
| geoId | string | The city's GeoNames geoId  |

## Response

- **Status:** 200 OK (on success)
- **Content-Type:** `application/json` (if requested)
- **Body:** City object

### City Object (JSON)

| Field      | Type     | Description                        |
|------------|----------|------------------------------------|
| id         | string   | GeoNames ID of the city            |
| name       | string   | Name of the city                   |
| stateCode  | string   | State code (if applicable)         |
| state      | string   | State name (if applicable)         |
| coords     | object   | Coordinates (lat, long)            |
| country    | object   | Country object (code, name)        |

#### Example Response

```json
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
}
```

## Example Request

### HTTP
```http
GET /1.0/city/5357527 HTTP/1.1
Host: api.setlist.fm
Accept: application/json
x-api-key: <YOUR_API_KEY>
```

### cURL
```sh
curl -H "Accept: application/json" \
     -H "x-api-key: <YOUR_API_KEY>" \
     "https://api.setlist.fm/1.0/city/5357527"
```

## Error Responses

- **404 Not Found:** If the geoId does not exist or is invalid.
- **401 Unauthorized:** If the API key is missing or invalid.
- **429 Too Many Requests:** If rate limits are exceeded.

Error responses are returned as an `error` object:
```json
{
  "error": "Description of the error"
}
```

## Usage Notes

- The geoId must be a valid GeoNames identifier.
- Always include your API key in the `x-api-key` header.
- Use the `Accept` header to specify JSON for easier parsing.
- For more details, see the [official endpoint documentation](https://api.setlist.fm/docs/1.0/resource__1.0_city__geoId_.html).

## References
- [setlist.fm API: /1.0/city/{geoId}](https://api.setlist.fm/docs/1.0/resource__1.0_city__geoId_.html)
- [GeoNames](http://geonames.org/) 