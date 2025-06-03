/**
 * @file validation.ts
 * @description Validation schemas specific to venues endpoints.
 * @author tkozzer
 * @module venues
 */

import { CityGeoIdParamSchema, CitySchema, CountryCodeSchema } from "@endpoints/cities/validation";
import { NonEmptyStringSchema, PaginationSchema } from "@shared/validation";
import { z } from "zod";

/**
 * Schema for validating venue ID parameter.
 */
export const VenueIdParamSchema = NonEmptyStringSchema.refine(
  value => /^[a-f0-9]{8}$/.test(value),
  "Venue ID must be an 8-character hexadecimal string",
);

/**
 * Schema for search venues parameters.
 */
export const SearchVenuesParamsSchema = PaginationSchema.extend({
  /** The city's geoId */
  cityId: CityGeoIdParamSchema.optional(),
  /** Name of the city where the venue is located */
  cityName: NonEmptyStringSchema.optional(),
  /** The city's country (ISO 3166-1 alpha-2 code) */
  country: CountryCodeSchema.optional(),
  /** Name of the venue */
  name: NonEmptyStringSchema.optional(),
  /** The city's state */
  state: NonEmptyStringSchema.optional(),
  /** The city's state code */
  stateCode: NonEmptyStringSchema.optional(),
});

/**
 * Schema for venue setlists parameters.
 */
export const GetVenueSetlistsParamsSchema = PaginationSchema;

/**
 * Schema for venue response validation.
 */
export const VenueSchema = z.object({
  /** The city in which the venue is located (optional) */
  city: CitySchema.optional(),
  /** The attribution URL to the venue on setlist.fm */
  url: z.string().url("Must be a valid URL"),
  /** Unique identifier for the venue */
  id: NonEmptyStringSchema,
  /** The name of the venue */
  name: NonEmptyStringSchema,
});

/**
 * Schema for venues collection response validation.
 */
export const VenuesSchema = z.object({
  /** Array of venue objects */
  venue: z.array(VenueSchema),
  /** Total number of matching venues */
  total: z.number().int().min(0),
  /** Current page number */
  page: z.number().int().min(1),
  /** Number of items per page */
  itemsPerPage: z.number().int().min(1),
});
