/**
 * @file index.ts
 * @description Setlists endpoints module exports.
 * @author tkozzer
 * @module setlists
 */

// Export functions
export { getSetlist } from "./getSetlist";
export { searchSetlists } from "./searchSetlists";

// Export types
export type {
  GetSetlistParams,
  SearchSetlistsParams,
  Set,
  Setlist,
  Setlists,
  Song,
  Tour,
} from "./types";

// Export validation schemas
export {
  GetSetlistParamsSchema,
  LastUpdatedSchema,
  SearchSetlistsParamsSchema,
  SetlistDateSchema,
  SetlistIdSchema,
  SetlistSchema,
  SetlistsSchema,
  SetSchema,
  SongSchema,
  TourSchema,
  VersionIdSchema,
} from "./validation";
