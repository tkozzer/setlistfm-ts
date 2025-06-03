# Data Type: artists

## Overview

Represents a paginated result consisting of a list of artists.

- **Official Docs:** [setlist.fm API: artists Data Type](https://api.setlist.fm/docs/1.0/json_Artists.html)

## Properties

| Name         | Data Type                        | Description                                      |
|--------------|----------------------------------|--------------------------------------------------|
| artist       | array of [artist](json_Artist.html) | Result list of artists                        |
| total        | number                           | The total amount of items matching the query      |
| page         | number                           | The current page (starts at 1)                    |
| itemsPerPage | number                           | The amount of items you get per page              |

## Example

```json
{
  "artist": [
    {
      "mbid": "b10bbbfc-cf9e-42e0-be17-e2c3e1d2600d",
      "name": "The Beatles",
      "sortName": "Beatles, The",
      "disambiguation": "John, Paul, George and Ringo",
      "url": "https://www.setlist.fm/setlists/the-beatles-23d6a88b.html"
    },
    {
      "mbid": "...",
      "name": "...",
      "sortName": "...",
      "disambiguation": "...",
      "url": "..."
    }
  ],
  "total": 42,
  "page": 1,
  "itemsPerPage": 20
}
```

## Usage Notes

- The `artist` property is an array of [artist](https://api.setlist.fm/docs/1.0/json_Artist.html) objects.
- Pagination is supported via the `page` and `itemsPerPage` properties.
- The `total` property indicates the total number of matching artists for the query.

## References
- [setlist.fm API: artists Data Type](https://api.setlist.fm/docs/1.0/json_Artists.html)
- [setlist.fm API: artist Data Type](https://api.setlist.fm/docs/1.0/json_Artist.html) 