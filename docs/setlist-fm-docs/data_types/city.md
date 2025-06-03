# Data Type: city

## Overview

Represents a city where venues are located. Most of the original city data was taken from GeoNames.org.

- **Official Docs:** [setlist.fm API: city Data Type](https://api.setlist.fm/docs/1.0/json_City.html)

## Properties

| Name      | Data Type                        | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
|-----------|----------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| id        | string                           | Unique identifier for the city.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| name      | string                           | The city's name, depending on the language. Valid values are e.g. "München" or "Munich".                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| stateCode | string                           | The code of the city's state. For most countries this is a two-digit numeric code, with which the state can be identified uniquely in the specific country. The code can also be a string for other cities. Valid examples are "CA" or "02". This code is only unique when combined with the city's country. For a complete list of available states, see [GeoNames admin1CodesASCII.txt](http://download.geonames.org/export/dump/admin1CodesASCII.txt). |
| state     | string                           | The name of the city's state, e.g. "Bavaria" or "California".                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| coords    | [coords](json_Coords.html)       | The city's coordinates. Usually the coordinates of the city centre are used.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| country   | [country](json_Country.html)     | The city's country.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |

## Example

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

## Usage Notes

- The `stateCode` is only unique when combined with the city's country code.
- The `coords` property provides the latitude and longitude of the city centre.
- The `country` property is a [country](https://api.setlist.fm/docs/1.0/json_Country.html) object.
- For a complete list of available states, see [GeoNames admin1CodesASCII.txt](http://download.geonames.org/export/dump/admin1CodesASCII.txt).

## References
- [setlist.fm API: city Data Type](https://api.setlist.fm/docs/1.0/json_City.html)
- [GeoNames admin1CodesASCII.txt](http://download.geonames.org/export/dump/admin1CodesASCII.txt)
- [setlist.fm API: country Data Type](https://api.setlist.fm/docs/1.0/json_Country.html)
- [setlist.fm API: coords Data Type](https://api.setlist.fm/docs/1.0/json_Coords.html) 