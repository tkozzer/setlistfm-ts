# Endpoint: GET /1.0/setlist/version/{versionId}

## Overview

**Deprecated** — This endpoint always returns _Not Found (404)_.

Returns a setlist for the given versionId. The setlist returned isn't necessarily the most recent version. If you pass the versionId of a setlist that got edited since you last accessed it, you'll get the same version as last time.

- **Official Docs:** [setlist.fm API: /1.0/setlist/version/{versionId}](https://api.setlist.fm/docs/1.0/resource__1.0_setlist_version__versionId_.html)

## Request

- **Method:** GET
- **URL:** `https://api.setlist.fm/1.0/setlist/version/{versionId}`
- **Headers:**
  - `x-api-key: <YOUR_API_KEY>` (required)
  - `Accept: application/json` (recommended)
  - `Accept-Language: <language-code>` (optional)

## Path Parameters

| Name      | Type   | Description         |
|-----------|--------|---------------------|
| versionId | string | The setlist version id |

## Response

- **Status:** 404 Not Found (deprecated, always returns 404)
- **Content-Type:** `application/json` (if requested)
- **Body:** Error object

### Example (Deprecated, but for reference)

#### Example Request

```http
GET /1.0/setlist/version/7be1aaa0 HTTP/1.1
Host: api.setlist.fm
Accept: application/json
x-api-key: <YOUR_API_KEY>
```

#### Example cURL

```sh
curl -H "Accept: application/json" \
     -H "x-api-key: <YOUR_API_KEY>" \
     "https://api.setlist.fm/1.0/setlist/version/7be1aaa0"
```

#### Example Response (Deprecated)

```json
{
  "error": "Not Found"
}
```

## Usage Notes

- This endpoint is deprecated and always returns 404 Not Found.
- Use other setlist endpoints for current data.
- For more details, see the [official endpoint documentation](https://api.setlist.fm/docs/1.0/resource__1.0_setlist_version__versionId_.html).

## References
- [setlist.fm API: /1.0/setlist/version/{versionId}](https://api.setlist.fm/docs/1.0/resource__1.0_setlist_version__versionId_.html) 