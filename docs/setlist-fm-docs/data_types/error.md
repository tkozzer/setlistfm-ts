# Data Type: error

## Overview

Returned in case of an error from the setlist.fm API.

- **Official Docs:** [setlist.fm API: error Data Type](https://api.setlist.fm/docs/1.0/json_Error.html)

## Properties

| Name      | Data Type | Description                 |
|-----------|-----------|-----------------------------|
| code      | number    | The HTTP status code        |
| status    | string    | The HTTP status message     |
| message   | string    | An additional error message |
| timestamp | string    | Current timestamp           |

## Example

```json
{
  "code": 404,
  "status": "Not Found",
  "message": "unknown mbid",
  "timestamp": "2016-12-08T17:52:48.817+0000"
}
```

## Usage Notes

- The `code` property matches the HTTP status code of the error.
- The `status` property is a short description of the error type.
- The `message` property provides additional details about the error.
- The `timestamp` property indicates when the error occurred.

## References
- [setlist.fm API: error Data Type](https://api.setlist.fm/docs/1.0/json_Error.html) 