# Data Type: venues

## Overview

A result consisting of a list of venues, typically returned from a paginated API response.

- **Official Docs:** [setlist.fm API: venues Data Type](https://api.setlist.fm/docs/1.0/json_Venues.html)

## Properties

| Name         | Data Type                                 | Description                                  |
|--------------|-------------------------------------------|----------------------------------------------|
| venue        | array of [venue](json_Venue.html)         | Result list of venues                        |
| total        | number                                    | The total amount of items matching the query |
| page         | number                                    | The current page (starts at 1)               |
| itemsPerPage | number                                    | The amount of items you get per page         |

## Example

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

## Usage Notes

- The `venue` property is an array of [venue](https://api.setlist.fm/docs/1.0/json_Venue.html) objects.
- Pagination is supported via the `page` and `itemsPerPage` properties.
- The `total` property indicates the total number of matching venues for the query.

## References
- [setlist.fm API: venues Data Type](https://api.setlist.fm/docs/1.0/json_Venues.html)
- [setlist.fm API: venue Data Type](https://api.setlist.fm/docs/1.0/json_Venue.html) 