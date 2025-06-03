# Data Type: countries

## Overview

Represents a paginated result consisting of a list of countries.

- **Official Docs:** [setlist.fm API: countries Data Type](https://api.setlist.fm/docs/1.0/json_Countries.html)

## Properties

| Name         | Data Type                          | Description                                      |
|--------------|------------------------------------|--------------------------------------------------|
| country      | array of [country](json_Country.html) | Result list of countries                     |
| total        | number                             | The total amount of items matching the query      |
| page         | number                             | The current page (starts at 1)                    |
| itemsPerPage | number                             | The amount of items you get per page              |

## Example

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

## Usage Notes

- The `country` property is an array of [country](https://api.setlist.fm/docs/1.0/json_Country.html) objects.
- Pagination is supported via the `page` and `itemsPerPage` properties.
- The `total` property indicates the total number of matching countries for the query.

## References
- [setlist.fm API: countries Data Type](https://api.setlist.fm/docs/1.0/json_Countries.html)
- [setlist.fm API: country Data Type](https://api.setlist.fm/docs/1.0/json_Country.html) 