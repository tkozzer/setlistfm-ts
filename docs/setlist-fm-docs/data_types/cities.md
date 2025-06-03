# Data Type: cities

## Overview

Represents a paginated result consisting of a list of cities.

- **Official Docs:** [setlist.fm API: cities Data Type](https://api.setlist.fm/docs/1.0/json_Cities.html)

## Properties

| Name         | Data Type                        | Description                                      |
|--------------|----------------------------------|--------------------------------------------------|
| cities       | array of [city](json_City.html)  | Result list of cities                            |
| total        | number                           | The total amount of items matching the query      |
| page         | number                           | The current page (starts at 1)                    |
| itemsPerPage | number                           | The amount of items you get per page              |

## Example

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

## Usage Notes

- The `cities` property is an array of [city](https://api.setlist.fm/docs/1.0/json_City.html) objects.
- Pagination is supported via the `page` and `itemsPerPage` properties.
- The `total` property indicates the total number of matching cities for the query.

## References
- [setlist.fm API: cities Data Type](https://api.setlist.fm/docs/1.0/json_Cities.html)
- [setlist.fm API: city Data Type](https://api.setlist.fm/docs/1.0/json_City.html) 