# Data Type: song

## Overview

Represents a song that is part of a set in a setlist. Includes information about the song, guest artists, covers, special performance notes, and whether it was played from tape.

- **Official Docs:** [setlist.fm API: song Data Type](https://api.setlist.fm/docs/1.0/json_Song.html)

## Properties

| Name  | Data Type                        | Description                                                                                                                                                                                                           |
|-------|----------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| name  | string                           | The name of the song. E.g. _Yesterday_ or _"Wish You Were Here"_                                                                                                              |
| with  | [artist](json_Artist.html)       | A different Artist than the performing one that joined the stage for this song.                                                                                                |
| cover | [artist](json_Artist.html)       | The original Artist of this song, if different to the performing artist.                                                                                                        |
| info  | string                           | Special incidents or additional information about the way the song was performed at this specific concert. See the [setlist.fm guidelines](https://www.setlist.fm/guidelines) for a complete list of allowed content. |
| tape  | boolean                          | The song came from tape rather than being performed live. See the [tape section of the guidelines](https://www.setlist.fm/guidelines#tape-songs) for valid usage.                |

## Example

```json
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
}
```

## Usage Notes

- The `with` property is used when a guest artist joins the main artist for this song.
- The `cover` property is used when the song is originally by a different artist.
- The `info` property may contain special incidents or performance notes, as per the [setlist.fm guidelines](https://www.setlist.fm/guidelines).
- The `tape` property is `true` if the song was played from tape, not performed live. See the [tape section of the guidelines](https://www.setlist.fm/guidelines#tape-songs).

## References
- [setlist.fm API: song Data Type](https://api.setlist.fm/docs/1.0/json_Song.html)
- [setlist.fm guidelines](https://www.setlist.fm/guidelines) 