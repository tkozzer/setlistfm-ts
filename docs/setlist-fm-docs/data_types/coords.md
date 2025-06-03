# Data Type: coords

## Overview

Represents the coordinates of a point on the globe. Mostly used for cities.

- **Official Docs:** [setlist.fm API: coords Data Type](https://api.setlist.fm/docs/1.0/json_Coords.html)

## Properties

| Name | Data Type | Description                            |
|------|-----------|----------------------------------------|
| long | number    | The longitude part of the coordinates. |
| lat  | number    | The latitude part of the coordinates.  |

## Example

```json
{
  "long": -118.3267434,
  "lat": 34.0983425
}
```

## Usage Notes

- Longitude values range from -180 to 180.
- Latitude values range from -90 to 90.
- Used primarily in the `coords` property of the [city](https://api.setlist.fm/docs/1.0/json_City.html) data type.

## References
- [setlist.fm API: coords Data Type](https://api.setlist.fm/docs/1.0/json_Coords.html) 