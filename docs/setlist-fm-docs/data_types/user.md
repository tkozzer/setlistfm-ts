# Data Type: user

## Overview

Represents a user on setlist.fm.

- **Official Docs:** [setlist.fm API: user Data Type](https://api.setlist.fm/docs/1.0/json_User.html)

## Properties

| Name     | Data Type | Description                |
|----------|-----------|----------------------------|
| userId   | string    | The user's unique ID       |
| fullname | string    | Never set (deprecated)     |
| lastFm   | string    | Never set (deprecated)     |
| mySpace  | string    | Never set (deprecated)     |
| twitter  | string    | Never set (deprecated)     |
| flickr   | string    | Never set (deprecated)     |
| website  | string    | Never set (deprecated)     |
| about    | string    | Never set (deprecated)     |
| url      | string    | The user's profile URL     |

## Example

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

## Usage Notes

- Only `userId` and `url` are meaningful; all other properties are deprecated and never set.
- Used in endpoints that return user information or reference users.

## References
- [setlist.fm API: user Data Type](https://api.setlist.fm/docs/1.0/json_User.html) 