# Data Type: artist

## Overview

Represents an artist, which can be a musician or a group of musicians. Each artist is uniquely identified by a Musicbrainz Identifier (MBID).

- **Official Docs:** [setlist.fm API: artist Data Type](https://api.setlist.fm/docs/1.0/json_Artist.html)

## Properties

| Name           | Data Type | Description                                                                         |
|----------------|-----------|-------------------------------------------------------------------------------------|
| mbid           | string    | Unique Musicbrainz Identifier (MBID), e.g. `b10bbbfc-cf9e-42e0-be17-e2c3e1d2600d`   |
| name           | string    | The artist's name, e.g. `The Beatles`                                               |
| sortName       | string    | The artist's sort name, e.g. `Beatles, The` or `Springsteen, Bruce`                 |
| disambiguation | string    | Disambiguation to distinguish between artists with the same names                    |
| url            | string    | The attribution URL                                                                 |

> **Note:** The `tmid` (Ticket Master Identifier) property is deprecated and should not be used.

## Example

```json
{
  "mbid": "b10bbbfc-cf9e-42e0-be17-e2c3e1d2600d",
  "name": "The Beatles",
  "sortName": "Beatles, The",
  "disambiguation": "John, Paul, George and Ringo",
  "url": "https://www.setlist.fm/setlists/the-beatles-23d6a88b.html"
}
```

## Usage Notes

- The `mbid` is required to uniquely identify an artist in the setlist.fm API.
- The `disambiguation` field is useful for distinguishing between artists with similar or identical names.
- The `url` provides a direct link to the artist's setlists on setlist.fm.

## References
- [setlist.fm API: artist Data Type](https://api.setlist.fm/docs/1.0/json_Artist.html) 