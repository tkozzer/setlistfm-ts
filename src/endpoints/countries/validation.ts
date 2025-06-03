/**
 * @file validation.ts
 * @description Validation schemas specific to countries endpoints.
 * @author tkozzer
 * @module countries
 */

import { NonEmptyStringSchema } from "@shared/validation";

import { z } from "zod";

/**
 * Schema for validating ISO 3166-1 alpha-2 country codes.
 */
export const CountryCodeSchema = z.string()
  .length(2, "Country code must be exactly 2 characters")
  .regex(/^[A-Z]{2}$/, "Country code must be 2 uppercase letters (ISO 3166-1 alpha-2)");

/**
 * Schema for country validation.
 */
export const CountrySchema = z.object({
  /** ISO 3166-1 alpha-2 country code */
  code: CountryCodeSchema,
  /** Localized country name */
  name: NonEmptyStringSchema,
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

/**
 * Schema for search countries parameters.
 * The GET /1.0/search/countries endpoint doesn't accept any query parameters.
 */
export const SearchCountriesParamsSchema = z.object({}).strict();
