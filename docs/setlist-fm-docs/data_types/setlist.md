# Data Type: setlist

## Overview

A setlist represents a concert's set of performed songs, including artist, venue, tour, sets, and metadata. Each setlist has a unique id and can have multiple versions (each edit creates a new version with a unique versionId).

- **Official Docs:** [setlist.fm API: setlist Data Type](https://api.setlist.fm/docs/1.0/json_Setlist.html)

## Properties

| Name         | Data Type                              | Description                                                                                                                                        |
|--------------|----------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------|
| artist       | [artist](json_Artist.html)             | The setlist's artist                                                                                                                               |
| venue        | [venue](json_Venue.html)               | The setlist's venue                                                                                                                                |
| tour         | [tour](json_Tour.html)                 | The setlist's tour                                                                                                                                 |
| set          | array of [set](json_Set.html)          | All sets of this setlist                                                                                                                           |
| info         | string                                 | Additional information on the concert. See the [setlist.fm guidelines](https://www.setlist.fm/guidelines) for allowed content.                     |
| url          | string                                 | The attribution URL to which you must link wherever you use data from this setlist in your application                                             |
| id           | string                                 | Unique identifier for the setlist                                                                                                                  |
| versionId    | string                                 | Unique identifier of the setlist version                                                                                                           |
| eventDate    | string                                 | Date of the concert in the format "dd-MM-yyyy"                                                                                                   |
| lastUpdated  | string                                 | Date, time, and time zone of the last update to this setlist in the format "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"                                      |

> **Deprecated:** `lastFmEventId` is deprecated and should not be used.

## Example

```json
{
  "artist": {
    "mbid": "b10bbbfc-cf9e-42e0-be17-e2c3e1d2600d",
    "name": "The Beatles",
    "sortName": "Beatles, The",
    "disambiguation": "John, Paul, George and Ringo",
    "url": "https://www.setlist.fm/setlists/the-beatles-23d6a88b.html"
  },
  "venue": {
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
  "tour": {
    "name": "North American Tour 1964"
  },
  "set": [
    {
      "name": "...",
      "encore": 12345,
      "song": [
        {
          "name": "Yesterday",
          "with": {},
          "cover": {},
          "info": "...",
          "tape": false
        },
        {
          "name": "...",
          "with": {},
          "cover": {},
          "info": "...",
          "tape": true
        }
      ]
    },
    {
      "name": "...",
      "encore": 12345,
      "song": [
        {
          "name": "...",
          "with": {},
          "cover": {},
          "info": "...",
          "tape": true
        },
        {
          "name": "...",
          "with": {},
          "cover": {},
          "info": "...",
          "tape": true
        }
      ]
    }
  ],
  "info": "Recorded and published as 'The Beatles at the Hollywood Bowl'",
  "url": "https://www.setlist.fm/setlist/the-beatles/1964/hollywood-bowl-hollywood-ca-63de4613.html",
  "id": "63de4613",
  "versionId": "7be1aaa0",
  "eventDate": "23-08-1964",
  "lastUpdated": "2013-10-20T05:18:08.000+0000"
}
```

## Usage Notes

- The `id` property uniquely identifies a setlist, but different versions of the same setlist have different `versionId` values.
- The `set` property is an array of [set](https://api.setlist.fm/docs/1.0/json_Set.html) objects, representing main sets and encores.
- The `info` property may contain additional concert details as per the [setlist.fm guidelines](https://www.setlist.fm/guidelines).
- The `url` property must be used for attribution wherever setlist data is displayed.

## References
- [setlist.fm API: setlist Data Type](https://api.setlist.fm/docs/1.0/json_Setlist.html)
- [setlist.fm API: set Data Type](https://api.setlist.fm/docs/1.0/json_Set.html)
- [setlist.fm API: artist Data Type](https://api.setlist.fm/docs/1.0/json_Artist.html)
- [setlist.fm API: venue Data Type](https://api.setlist.fm/docs/1.0/json_Venue.html)
- [setlist.fm API: tour Data Type](https://api.setlist.fm/docs/1.0/json_Tour.html) 