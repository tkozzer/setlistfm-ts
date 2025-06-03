/**
 * @file validation.ts
 * @description Validation schemas specific to cities endpoints.
 * @author tkozzer
 * @module cities
 */

import { NonEmptyStringSchema, PaginationSchema } from "@shared/validation";

import { z } from "zod";

/**
 * Schema for validating city geoId parameter (GeoNames ID).
 */
export const CityGeoIdParamSchema = NonEmptyStringSchema.refine(
  value => /^\d+$/.test(value),
  "GeoId must be a numeric string",
);

/**
 * Schema for validating ISO 3166-1 alpha-2 country codes.
 */
export const CountryCodeSchema = z.string()
  .length(2, "Country code must be exactly 2 characters")
  .regex(/^[A-Z]{2}$/, "Country code must be 2 uppercase letters (ISO 3166-1 alpha-2)");

/**
 * Schema for search cities parameters.
 */
export const SearchCitiesParamsSchema = PaginationSchema.extend({
  /** The city's country (ISO 3166-1 alpha-2 code, e.g., "US", "GB", "DE") */
  country: CountryCodeSchema.optional(),
  /** Name of the city */
  name: NonEmptyStringSchema.optional(),
  /** State the city lies in */
  state: NonEmptyStringSchema.optional(),
  /** State code the city lies in */
  stateCode: NonEmptyStringSchema.optional(),
});

/**
 * Schema for coordinates validation.
 */
export const CoordsSchema = z.object({
  /** Longitude (-180 to 180) */
  long: z.number().min(-180).max(180),
  /** Latitude (-90 to 90) */
  lat: z.number().min(-90).max(90),
});

/**
 * Schema for country validation.
 */
export const CountrySchema = z.object({
  /** Two-letter country code (ISO 3166-1 alpha-2) */
  code: CountryCodeSchema,
  /** Full country name */
  name: NonEmptyStringSchema,
});

/**
 * Schema for city response validation.
 */
export const CitySchema = z.object({
  /** Unique identifier for the city (GeoNames ID) */
  id: NonEmptyStringSchema,
  /** City name */
  name: NonEmptyStringSchema,
  /** State/province code */
  stateCode: NonEmptyStringSchema,
  /** State/province name */
  state: NonEmptyStringSchema,
  /** Geographic coordinates */
  coords: CoordsSchema,
  /** Country information */
  country: CountrySchema,
});

/**
 * Schema for cities collection response validation.
 */
export const CitiesSchema = z.object({
  /** Array of city objects */
  cities: z.array(CitySchema),
  /** Total number of matching cities */
  total: z.number().int().min(0),
  /** Current page number */
  page: z.number().int().min(1),
  /** Number of items per page */
  itemsPerPage: z.number().int().min(1),
});

/**
 * Schema for countries collection response validation.
 */
export const CountriesSchema = z.object({
  /** Array of country objects */
  country: z.array(CountrySchema),
  /** Total number of countries */
  total: z.number().int().min(0),
  /** Current page number */
  page: z.number().int().min(1),
  /** Number of items per page */
  itemsPerPage: z.number().int().min(1),
});
