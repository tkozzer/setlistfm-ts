/**
 * @file types.ts
 * @description TypeScript type definitions for cities, countries, and coordinates from the setlist.fm API.
 * @author tkozzer
 * @module cities
 */

/**
 * Represents the coordinates of a point on the globe. Mostly used for cities.
 */
export type Coords = {
  /** The longitude part of the coordinates (range: -180 to 180) */
  long: number;
  /** The latitude part of the coordinates (range: -90 to 90) */
  lat: number;
};

/**
 * Represents a country with its code and name.
 */
export type Country = {
  /** Two-letter country code (e.g., "US", "DE") */
  code: string;
  /** Full name of the country (e.g., "United States", "Germany") */
  name: string;
};

/**
 * Represents a city where venues are located. Most of the original city data was taken from GeoNames.org.
 */
export type City = {
  /** Unique identifier for the city (GeoNames ID) */
  id: string;
  /** The city's name, depending on the language (e.g., "München" or "Munich") */
  name: string;
  /** The code of the city's state. Can be two-digit numeric code or string (e.g., "CA", "02") */
  stateCode: string;
  /** The name of the city's state (e.g., "Bavaria", "California") */
  state: string;
  /** The city's coordinates, usually of the city centre */
  coords: Coords;
  /** The city's country */
  country: Country;
};

/**
 * Represents a paginated result consisting of a list of cities.
 */
export type Cities = {
  /** Result list of cities */
  cities: City[];
  /** The total amount of items matching the query */
  total: number;
  /** The current page (starts at 1) */
  page: number;
  /** The amount of items you get per page */
  itemsPerPage: number;
};

/**
 * Represents a paginated result consisting of a list of countries.
 */
export type Countries = {
  /** Result list of countries */
  country: Country[];
  /** The total amount of items matching the query */
  total: number;
  /** The current page (starts at 1) */
  page: number;
  /** The amount of items you get per page */
  itemsPerPage: number;
};

/**
 * Query parameters for searching cities.
 */
export type SearchCitiesParams = {
  /** The city's country */
  country?: string;
  /** Name of the city */
  name?: string;
  /** The number of the result page you'd like to have (default: 1) */
  p?: number;
  /** State the city lies in */
  state?: string;
  /** State code the city lies in */
  stateCode?: string;
};
