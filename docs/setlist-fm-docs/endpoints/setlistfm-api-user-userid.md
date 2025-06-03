# Endpoint: GET /1.0/user/{userId}

## Overview

Get a user by userId. **Deprecated:** This endpoint always returns a result, even if the user doesn't exist.

- **Official Docs:** [setlist.fm API: /1.0/user/{userId}](https://api.setlist.fm/docs/1.0/resource__1.0_user__userId_.html)

## Request

- **Method:** GET
- **URL:** `https://api.setlist.fm/1.0/user/{userId}`
- **Headers:**
  - `x-api-key: <YOUR_API_KEY>` (required)
  - `Accept: application/json` (recommended)
  - `Accept-Language: <language-code>` (optional)

## Path Parameters

| Name   | Type   | Description      |
|--------|--------|------------------|
| userId | string | The user's userId|

## Response

- **Status:** 200 OK (on success)
- **Content-Type:** `application/json` (if requested)
- **Body:** User object

### User Object (JSON)

| Field     | Type   | Description                |
|-----------|--------|----------------------------|
| userId    | string | The user's userId          |
| fullname  | string | The user's full name       |
| lastFm    | string | Last.fm profile URL        |
| mySpace   | string | MySpace profile URL        |
| twitter   | string | Twitter profile URL        |
| flickr    | string | Flickr profile URL         |
| website   | string | Personal website URL       |
| about     | string | About text                 |
| url       | string | setlist.fm profile URL     |

#### Example Response

```json
{
  "userId": "...",
  "fullname": "...",
  "lastFm": "...",
  "mySpace": "...",
  "twitter": "...",
  "flickr": "...",
  "website": "...",
  "about": "...",
  "url": "..."
}
```

## Example Request

### HTTP
```http
GET /1.0/user/someuser HTTP/1.1
Host: api.setlist.fm
Accept: application/json
x-api-key: <YOUR_API_KEY>
```

### cURL
```sh
curl -H "Accept: application/json" \
     -H "x-api-key: <YOUR_API_KEY>" \
     "https://api.setlist.fm/1.0/user/someuser"
```

## Error Responses

- **200 OK:** This endpoint always returns a result, even if the user does not exist (deprecated behavior).
- **401 Unauthorized:** If the API key is missing or invalid.
- **429 Too Many Requests:** If rate limits are exceeded.

Error responses are returned as an `error` object (for 401/429):
```json
{
  "error": "Description of the error"
}
```

## Usage Notes

- This endpoint is deprecated and always returns a result, even for non-existent users.
- Always include your API key in the `x-api-key` header.
- Use the `Accept` header to specify JSON for easier parsing.
- For more details, see the [official endpoint documentation](https://api.setlist.fm/docs/1.0/resource__1.0_user__userId_.html).

## References
- [setlist.fm API: /1.0/user/{userId}](https://api.setlist.fm/docs/1.0/resource__1.0_user__userId_.html) 