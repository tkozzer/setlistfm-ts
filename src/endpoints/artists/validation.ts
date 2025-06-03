/**
 * @file validation.ts
 * @description Validation schemas specific to artist endpoints.
 * @author tkozzer
 * @module artists
 */

import { MbidSchema, NonEmptyStringSchema, PaginationSchema } from "@shared/validation";

import { z } from "zod";

/**
 * Schema for artist search parameters.
 */
export const SearchArtistsParamsSchema = PaginationSchema.extend({
  /** The artist's name */
  artistName: NonEmptyStringSchema.optional(),
  /** The artist's Musicbrainz Identifier (mbid) */
  artistMbid: MbidSchema.optional(),
  /** The artist's Ticketmaster Identifier (deprecated) */
  artistTmid: z
    .number()
    .int("Ticketmaster ID must be an integer")
    .positive("Ticketmaster ID must be positive")
    .optional(),
  /** Sort order for results */
  sort: z.enum(["sortName", "relevance"]).optional(),
}).refine(
  data => data.artistName || data.artistMbid || data.artistTmid,
  "At least one of artistName, artistMbid, or artistTmid must be provided",
);

/**
 * Schema for get artist setlists parameters.
 */
export const GetArtistSetlistsParamsSchema = PaginationSchema;

/**
 * Schema for validating artist MBID parameter.
 */
export const ArtistMbidParamSchema = MbidSchema;

/**
 * Schema for artist response validation.
 */
export const ArtistSchema = z.object({
  /** MusicBrainz identifier */
  mbid: MbidSchema,
  /** Artist name */
  name: NonEmptyStringSchema,
  /** Sort name for the artist */
  sortName: NonEmptyStringSchema,
  /** Disambiguation string */
  disambiguation: z.string().optional(),
  /** URL to setlist.fm page */
  url: z.string().url().optional(),
});

/**
 * Schema for artists collection response validation.
 */
export const ArtistsSchema = z.object({
  /** Array of artist objects */
  artist: z.array(ArtistSchema),
  /** Total number of matching artists */
  total: z.number().int().min(0),
  /** Current page number */
  page: z.number().int().min(1),
  /** Number of items per page */
  itemsPerPage: z.number().int().min(1),
});

/**
 * Schema for setlists collection response validation.
 */
export const SetlistsSchema = z.object({
  /** Array of setlist objects */
  setlist: z.array(z.any()), // Will be replaced with proper Setlist schema when available
  /** Total number of setlists */
  total: z.number().int().min(0),
  /** Current page number */
  page: z.number().int().min(1),
  /** Number of items per page */
  itemsPerPage: z.number().int().min(1),
});
