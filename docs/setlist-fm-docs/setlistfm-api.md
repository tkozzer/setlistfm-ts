# setlist.fm API Comprehensive Documentation

## Overview

The setlist.fm API provides access to setlist data, including artists, venues, cities, countries, and users. It is designed for building applications and websites that require concert setlist information. The API is RESTful and supports both JSON and XML formats.

- **Base URL:** `https://api.setlist.fm/rest`
- **API Version:** 1.0 (all endpoints are prefixed with `/1.0/`)
- **Official Docs:** [setlist.fm API Docs](https://api.setlist.fm/docs/1.0/index.html)

## Authentication

- **API Key:** Required for all requests. Obtain one by registering at setlist.fm and applying for an API key.
- **Header:**
  - `x-api-key: <YOUR_API_KEY>`

## Content Negotiation

- **Supported Content Types:** JSON (recommended), XML (default)
- **Headers:**
  - To receive JSON: `Accept: application/json`
  - To receive XML: `Accept: application/xml`

## Internationalization

- **Header:** `Accept-Language: <language-code>`
- **Supported Languages:** English (en, default), Spanish (es), French (fr), German (de), Portuguese (pt), Turkish (tr), Italian (it), Polish (pl)
- **Effect:** Localizes city and country names in responses.

## Rate Limiting & Terms

- The API is free for non-commercial use. Commercial use requires permission.
- See the [API Terms of Service](https://www.setlist.fm/guidelines) for details.

## Error Handling

- Errors are returned as an `error` object.
- Example (JSON):
  ```json
  {
    "error": "Description of the error"
  }
  ```

## Endpoints

| Path                               | Method | Description                   |
| ---------------------------------- | ------ | ----------------------------- |
| `/1.0/artist/{mbid}`               | GET    | Get artist by Musicbrainz ID  |
| `/1.0/artist/{mbid}/setlists`      | GET    | Get setlists for an artist    |
| `/1.0/city/{geoId}`                | GET    | Get city by GeoNames ID       |
| `/1.0/search/artists`              | GET    | Search for artists            |
| `/1.0/search/cities`               | GET    | Search for cities             |
| `/1.0/search/countries`            | GET    | Search for countries          |
| `/1.0/search/setlists`             | GET    | Search for setlists           |
| `/1.0/search/venues`               | GET    | Search for venues             |
| `/1.0/setlist/version/{versionId}` | GET    | Get setlist by version ID     |
| `/1.0/setlist/{setlistId}`         | GET    | Get setlist by setlist ID     |
| `/1.0/user/{userId}`               | GET    | Get user by user ID           |
| `/1.0/user/{userId}/attended`      | GET    | Get setlists attended by user |
| `/1.0/user/{userId}/edited`        | GET    | Get setlists edited by user   |
| `/1.0/venue/{venueId}`             | GET    | Get venue by venue ID         |
| `/1.0/venue/{venueId}/setlists`    | GET    | Get setlists for a venue      |

## Common Data Types

- **artist**: Represents a musician or group. Identified by MBID.
- **artists**: List of artist objects.
- **city**: Represents a city (GeoNames ID).
- **cities**: List of city objects.
- **country**: Represents a country.
- **countries**: List of country objects.
- **setlist**: Represents a concert setlist (unique ID, versioning supported).
- **setlists**: List of setlist objects.
- **venue**: Represents a concert venue.
- **venues**: List of venue objects.
- **user**: Represents a setlist.fm user.
- **song**: Represents a song in a set.
- **tour**: Represents a tour.
- **error**: Error object (see above).

## Example Request

### Get Setlists for an Artist (JSON)

```http
GET /1.0/artist/{mbid}/setlists HTTP/1.1
Host: api.setlist.fm
Accept: application/json
x-api-key: <YOUR_API_KEY>
```

### Example cURL

```sh
curl -H "Accept: application/json" \
     -H "x-api-key: <YOUR_API_KEY>" \
     "https://api.setlist.fm/rest/1.0/artist/1234-abcd-5678-efgh/setlists"
```

## Usage Tips

- Always include your API key in the `x-api-key` header.
- Use the `Accept` header to specify JSON for easier parsing.
- Use the `Accept-Language` header for localized results.
- Check the [official docs](https://api.setlist.fm/docs/1.0/index.html) for up-to-date endpoint details and data types.
- Respect the API's terms of service and rate limits.

## References

- [setlist.fm API Docs](https://api.setlist.fm/docs/1.0/index.html)
- [Musicbrainz MBID](http://wiki.musicbrainz.org/MBID)
- [GeoNames](http://geonames.org/)
