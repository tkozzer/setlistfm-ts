# Data Type: country

## Overview

Represents a country on earth, identified by its ISO code and name. The name can be localized depending on the requested language.

- **Official Docs:** [setlist.fm API: country Data Type](https://api.setlist.fm/docs/1.0/json_Country.html)

## Properties

| Name | Data Type | Description                                                                                                                   |
|------|-----------|-------------------------------------------------------------------------------------------------------------------------------|
| code | string    | The country's [ISO code](http://www.iso.org/iso/english_country_names_and_code_elements). E.g. "ie" for Ireland              |
| name | string    | The country's name. Can be a localized name, e.g. "Austria" or "Österreich" for Austria if the German name was requested. |

## Example

```json
{
  "code": "US",
  "name": "United States"
}
```

## Usage Notes

- The `code` property is the standard ISO country code (usually two lowercase letters).
- The `name` property may be localized depending on the `Accept-Language` header in the API request.

## References
- [setlist.fm API: country Data Type](https://api.setlist.fm/docs/1.0/json_Country.html)
- [ISO country codes](http://www.iso.org/iso/english_country_names_and_code_elements) 