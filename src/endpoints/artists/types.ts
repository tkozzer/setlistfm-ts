/**
 * @file types.ts
 * @description Type definitions specific to artist endpoints.
 * @author tkozzer
 * @module artists
 */

import type { Artist, PaginationParams, Setlist } from "@shared/types";

/**
 * Parameters for searching artists via GET /1.0/search/artists.
 */
export type SearchArtistsParams = PaginationParams & {
  /** The artist's name */
  artistName?: string;
  /** The artist's Musicbrainz Identifier (mbid) */
  artistMbid?: string;
  /** The artist's Ticketmaster Identifier (deprecated) */
  artistTmid?: number;
  /** The sort of the result, either sortName (default) or relevance */
  sort?: "sortName" | "relevance";
};

/**
 * Parameters for retrieving setlists for a specific artist via GET /1.0/artist/{mbid}/setlists.
 */
export type GetArtistSetlistsParams = PaginationParams;

/**
 * Represents a paginated response containing artists from the search endpoint.
 */
export type Artists = {
  /** Array of artist objects */
  artist: Artist[];
  /** Total number of matching artists */
  total: number;
  /** Current page number (starts at 1) */
  page: number;
  /** Number of items per page */
  itemsPerPage: number;
};

/**
 * Represents a paginated response containing setlists for an artist.
 */
export type Setlists = {
  /** Array of setlist objects */
  setlist: Setlist[];
  /** Total number of setlists */
  total: number;
  /** Current page number (starts at 1) */
  page: number;
  /** Number of items per page */
  itemsPerPage: number;
};
