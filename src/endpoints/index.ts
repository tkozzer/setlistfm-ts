/**
 * @file index.ts
 * @description Main export file for all endpoint modules.
 * @author tkozzer
 * @module endpoints
 */

// Export artists (excluding conflicting Setlists types exported from setlists)
export {
  ArtistMbidParamSchema,
  ArtistSchema,
  ArtistsSchema,
  getArtist,
  getArtistSetlists,
  GetArtistSetlistsParamsSchema,
  searchArtists,
  SearchArtistsParamsSchema,
} from "./artists";

export type {
  Artists,
  GetArtistSetlistsParams,
  SearchArtistsParams,
} from "./artists";

// Export cities (excluding conflicting Country types exported from countries)
export {
  CitiesSchema,
  CityGeoIdParamSchema,
  CitySchema,
  CoordsSchema,
  getCityByGeoId,
  searchCities,
  SearchCitiesParamsSchema,
} from "./cities";

export type {
  Cities,
  City,
  Coords,
  SearchCitiesParams,
} from "./cities";

// Export countries (primary source for Country types)
export * from "./countries";

// Export setlists (primary source for Setlists types)
export * from "./setlists";

// Export venues
export * from "./venues";
