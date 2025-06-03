# Data Type: venue

## Overview

Venues are places where concerts take place. They usually consist of a venue name and a city, but some venues may not have a city attached yet. In such cases, the city and country may be included in the name.

- **Official Docs:** [setlist.fm API: venue Data Type](https://api.setlist.fm/docs/1.0/json_Venue.html)

## Properties

| Name | Data Type                  | Description                                                                                                   |
|------|----------------------------|---------------------------------------------------------------------------------------------------------------|
| city | [city](json_City.html)     | The city in which the venue is located                                                                        |
| url  | string                     | The attribution URL                                                                                           |
| id   | string                     | Unique identifier                                                                                            |
| name | string                     | The name of the venue, usually without city and country. E.g. "Madison Square Garden" or "Royal Albert Hall" |

## Example

```json
{
  "city": {
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
  "url": "https://www.setlist.fm/venue/compaq-center-san-jose-ca-usa-6bd6ca6e.html",
  "id": "6bd6ca6e",
  "name": "Compaq Center"
}
```

## Usage Notes

- The `city` property may be omitted if the venue does not have a city attached; in such cases, city and country may be included in the `name`.
- The `url` property must be used for attribution wherever venue data is displayed.

## References
- [setlist.fm API: venue Data Type](https://api.setlist.fm/docs/1.0/json_Venue.html)
- [setlist.fm API: city Data Type](https://api.setlist.fm/docs/1.0/json_City.html) 