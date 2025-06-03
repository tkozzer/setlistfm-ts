/**
 * @file validation.ts
 * @description Validation schemas specific to setlists endpoints.
 * @author tkozzer
 * @module setlists
 */

import { ArtistSchema } from "@endpoints/artists/validation";
import { VenueSchema } from "@endpoints/venues/validation";
import { MbidSchema, NonEmptyStringSchema, OptionalStringSchema, PaginationSchema } from "@shared/validation";

import { z } from "zod";

/**
 * Schema for setlist ID validation.
 */
export const SetlistIdSchema = z
  .string()
  .min(1, "Setlist ID is required")
  .regex(/^[a-f0-9]{7,8}$/, "Setlist ID must be a 7-8 character hexadecimal string");

/**
 * Schema for setlist version ID validation.
 */
export const VersionIdSchema = z
  .string()
  .min(1, "Version ID is required")
  .min(7, "Version ID must be at least 7 characters")
  .max(9, "Version ID must be at most 9 characters");

/**
 * Schema for date in dd-MM-yyyy format (setlist.fm format).
 */
export const SetlistDateSchema = z
  .string()
  .regex(
    /^\d{2}-\d{2}-\d{4}$/,
    "Date must be in dd-MM-yyyy format",
  )
  .refine((date) => {
    const [day, month, year] = date.split("-").map(Number);
    const parsed = new Date(year, month - 1, day);
    return parsed.getDate() === day && parsed.getMonth() === month - 1 && parsed.getFullYear() === year;
  }, "Date must be a valid date");

/**
 * Schema for lastUpdated timestamp format (yyyyMMddHHmmss).
 */
export const LastUpdatedSchema = z
  .string()
  .regex(
    /^\d{14}$/,
    "Last updated must be in yyyyMMddHHmmss format",
  )
  .refine((timestamp) => {
    const year = Number.parseInt(timestamp.slice(0, 4), 10);
    const month = Number.parseInt(timestamp.slice(4, 6), 10);
    const day = Number.parseInt(timestamp.slice(6, 8), 10);
    const hour = Number.parseInt(timestamp.slice(8, 10), 10);
    const minute = Number.parseInt(timestamp.slice(10, 12), 10);
    const second = Number.parseInt(timestamp.slice(12, 14), 10);

    const parsed = new Date(year, month - 1, day, hour, minute, second);
    return parsed.getFullYear() === year
      && parsed.getMonth() === month - 1
      && parsed.getDate() === day
      && parsed.getHours() === hour
      && parsed.getMinutes() === minute
      && parsed.getSeconds() === second;
  }, "Last updated must be a valid timestamp");

/**
 * Schema for tour validation.
 */
export const TourSchema = z.object({
  /** The name of the tour */
  name: NonEmptyStringSchema,
});

/**
 * Schema for song validation.
 */
export const SongSchema = z.object({
  /** The name of the song */
  name: NonEmptyStringSchema,
  /** A different artist that joined the stage for this song */
  with: ArtistSchema.optional(),
  /** The original artist of this song, if different to the performing artist */
  cover: ArtistSchema.optional(),
  /** Special incidents or additional information about the song performance */
  info: OptionalStringSchema,
  /** Whether the song came from tape rather than being performed live */
  tape: z.boolean().optional(),
});

/**
 * Schema for set validation.
 */
export const SetSchema = z.object({
  /** The description/name of the set */
  name: OptionalStringSchema,
  /** If the set is an encore, this is the number of the encore */
  encore: z.number().int().min(1).optional(),
  /** This set's songs */
  song: z.array(SongSchema),
});

/**
 * Schema for setlist validation.
 */
export const SetlistSchema = z.object({
  /** The setlist's artist */
  artist: ArtistSchema,
  /** The setlist's venue */
  venue: VenueSchema,
  /** The setlist's tour */
  tour: TourSchema.optional(),
  /** All sets of this setlist wrapped in sets object */
  sets: z.object({
    set: z.array(SetSchema),
  }),
  /** Additional information on the concert */
  info: OptionalStringSchema,
  /** The attribution URL to setlist.fm */
  url: z.string().url(),
  /** Unique identifier for the setlist */
  id: SetlistIdSchema,
  /** Unique identifier of the setlist version */
  versionId: VersionIdSchema,
  /** Date of the concert in dd-MM-yyyy format */
  eventDate: SetlistDateSchema,
  /** Date, time, and time zone of the last update */
  lastUpdated: z.string().regex(
    /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}[+-]\d{4}$/,
    "lastUpdated must be in yyyy-MM-ddTHH:mm:ss.SSSZZZZZ format",
  ),
});

/**
 * Schema for setlists collection response validation.
 */
export const SetlistsSchema = z.object({
  /** Array of setlist objects */
  setlist: z.array(SetlistSchema),
  /** Total number of setlists matching the query */
  total: z.number().int().min(0),
  /** Current page number */
  page: z.number().int().min(1),
  /** Number of items per page */
  itemsPerPage: z.number().int().min(1),
});

/**
 * Schema for search setlists parameters.
 */
export const SearchSetlistsParamsSchema = PaginationSchema.extend({
  /** The artist's Musicbrainz Identifier (mbid) */
  artistMbid: MbidSchema.optional(),
  /** The artist's name */
  artistName: NonEmptyStringSchema.optional(),
  /** The artist's Ticketmaster Identifier (deprecated) */
  artistTmid: z.number().int().positive().optional(),
  /** The city's geoId */
  cityId: NonEmptyStringSchema.optional(),
  /** The name of the city */
  cityName: NonEmptyStringSchema.optional(),
  /** The country code */
  countryCode: z.string().length(2).optional(),
  /** The date of the event in dd-MM-yyyy format */
  date: SetlistDateSchema.optional(),
  /** The event's Last.fm Event ID (deprecated) */
  lastFm: z.number().int().positive().optional(),
  /** The date and time when this setlist was last updated */
  lastUpdated: LastUpdatedSchema.optional(),
  /** The state */
  state: NonEmptyStringSchema.optional(),
  /** The state code */
  stateCode: NonEmptyStringSchema.optional(),
  /** The tour name */
  tourName: NonEmptyStringSchema.optional(),
  /** The venue id */
  venueId: NonEmptyStringSchema.optional(),
  /** The name of the venue */
  venueName: NonEmptyStringSchema.optional(),
  /** The year of the event */
  year: z.number().int().min(1900).max(new Date().getFullYear() + 10).optional(),
}).refine(
  (data) => {
    // At least one search parameter should be provided for meaningful results
    const hasSearchParam = Object.values(data).some(value => value !== undefined && value !== null);
    return hasSearchParam;
  },
  "At least one search parameter must be provided",
);

/**
 * Schema for get setlist parameters.
 */
export const GetSetlistParamsSchema = z.object({
  /** The setlist ID */
  setlistId: SetlistIdSchema,
});
