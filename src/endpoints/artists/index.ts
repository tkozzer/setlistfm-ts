/**
 * @file index.ts
 * @description Public exports for artist endpoints.
 * @author tkozzer
 * @module artists
 */

// Export all artist functions
export { getArtist } from "./getArtist";
export { getArtistSetlists } from "./getArtistSetlists";
export { searchArtists } from "./searchArtists";

// Export all artist types
export type {
  Artists,
  GetArtistSetlistsParams,
  SearchArtistsParams,
  Setlists,
} from "./types";

// Export validation schemas for advanced usage
export {
  ArtistMbidParamSchema,
  ArtistSchema,
  ArtistsSchema,
  GetArtistSetlistsParamsSchema,
  SearchArtistsParamsSchema,
  SetlistsSchema,
} from "./validation";
