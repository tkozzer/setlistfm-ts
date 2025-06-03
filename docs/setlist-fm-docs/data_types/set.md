# Data Type: set

## Overview

A setlist consists of different (at least one) sets. Sets can either be sets as defined in the Guidelines or encores.

- **Official Docs:** [setlist.fm API: set Data Type](https://api.setlist.fm/docs/1.0/json_Set.html)

## Properties

| Name   | Data Type                         | Description                                                                                                                  |
|--------|------------------------------------|------------------------------------------------------------------------------------------------------------------------------|
| name   | string                            | The description/name of the set. E.g. "Acoustic set" or "Paul McCartney solo"                                              |
| encore | number                            | If the set is an encore, this is the number of the encore, starting with 1 for the first encore, 2 for the second, etc.      |
| song   | array of [song](json_Song.html)   | This set's songs                                                                                                             |

## Example

```json
{
  "name": "...",
  "encore": 12345,
  "song": [
    {
      "name": "Yesterday",
      "with": {
        "mbid": "b10bbbfc-cf9e-42e0-be17-e2c3e1d2600d",
        "name": "The Beatles",
        "sortName": "Beatles, The",
        "disambiguation": "John, Paul, George and Ringo",
        "url": "https://www.setlist.fm/setlists/the-beatles-23d6a88b.html"
      },
      "cover": {
        "mbid": "b10bbbfc-cf9e-42e0-be17-e2c3e1d2600d",
        "name": "The Beatles",
        "sortName": "Beatles, The",
        "disambiguation": "John, Paul, George and Ringo",
        "url": "https://www.setlist.fm/setlists/the-beatles-23d6a88b.html"
      },
      "info": "...",
      "tape": false
    },
    {
      "name": "...",
      "with": {
        "mbid": "...",
        "name": "...",
        "sortName": "...",
        "disambiguation": "...",
        "url": "..."
      },
      "cover": {
        "mbid": "...",
        "name": "...",
        "sortName": "...",
        "disambiguation": "...",
        "url": "..."
      },
      "info": "...",
      "tape": true
    }
  ]
}
```

## Usage Notes

- The `encore` property is only present if the set is an encore; otherwise, it may be omitted.
- The `song` property is an array of [song](https://api.setlist.fm/docs/1.0/json_Song.html) objects.
- Sets are used to group songs in a setlist, including main sets and encores.

## References
- [setlist.fm API: set Data Type](https://api.setlist.fm/docs/1.0/json_Set.html)
- [setlist.fm API: song Data Type](https://api.setlist.fm/docs/1.0/json_Song.html) 