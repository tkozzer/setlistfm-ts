/**
 * @file types.ts
 * @description TypeScript type definitions for venues from the setlist.fm API.
 * @author tkozzer
 * @module venues
 */

import type { City } from "@endpoints/cities/types";

/**
 * Represents a venue where concerts take place. Venues usually consist of a venue name
 * and a city, but some venues may not have a city attached yet.
 */
export type Venue = {
  /** The city in which the venue is located (may be omitted if not available) */
  city?: City;
  /** The attribution URL to the venue on setlist.fm */
  url: string;
  /** Unique identifier for the venue */
  id: string;
  /** The name of the venue, usually without city and country (e.g., "Madison Square Garden") */
  name: string;
};

/**
 * Represents a paginated result consisting of a list of venues.
 */
export type Venues = {
  /** Result list of venues */
  venue: Venue[];
  /** The total amount of items matching the query */
  total: number;
  /** The current page (starts at 1) */
  page: number;
  /** The amount of items you get per page */
  itemsPerPage: number;
};

/**
 * Query parameters for searching venues.
 */
export type SearchVenuesParams = {
  /** The city's geoId */
  cityId?: string;
  /** Name of the city where the venue is located */
  cityName?: string;
  /** The city's country (ISO 3166-1 alpha-2 code) */
  country?: string;
  /** Name of the venue */
  name?: string;
  /** The number of the result page you'd like to have (default: 1) */
  p?: number;
  /** The city's state */
  state?: string;
  /** The city's state code */
  stateCode?: string;
};

/**
 * Query parameters for getting setlists by venue.
 */
export type GetVenueSetlistsParams = {
  /** The number of the result page you'd like to have (default: 1) */
  p?: number;
};
