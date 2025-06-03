/**
 * @file types.ts
 * @description TypeScript type definitions for countries from the setlist.fm API.
 * @author tkozzer
 * @module countries
 */

import type { Country } from "@shared/types";

// Re-export Country type for convenience
export type { Country };

/**
 * Represents a paginated result consisting of a list of countries.
 * This is the response format for the GET /1.0/search/countries endpoint.
 */
export type Countries = {
  /** Result list of countries */
  country: Country[];
  /** The total amount of countries available */
  total: number;
  /** The current page (starts at 1) */
  page: number;
  /** The amount of items you get per page */
  itemsPerPage: number;
};

/**
 * Query parameters for searching countries.
 * The GET /1.0/search/countries endpoint doesn't accept any query parameters.
 */
export type SearchCountriesParams = Record<string, never>;
