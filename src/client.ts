/**
 * @file client.ts
 * @description Main SetlistFM client for accessing the setlist.fm API.
 * @author tkozzer
 * @module client
 */

import type { SetlistFMClientPublic } from "./client.types";
// Import types for clean type annotations
import type {
  Artists,
  Setlists as ArtistSetlists,
  SearchArtistsParams,
} from "./endpoints/artists";
import type {
  Cities,
  City,
  SearchCitiesParams,
} from "./endpoints/cities";

import type {
  Countries,
} from "./endpoints/countries";
import type {
  SearchSetlistsParams,
  Setlist,
  Setlists,
} from "./endpoints/setlists";

import type {
  SearchVenuesParams,
  Venue,
  Venues,
} from "./endpoints/venues";

import type { Artist } from "./shared/types";

import type { HttpClientConfig } from "./utils/http";

import type { RateLimitConfig } from "./utils/rateLimiter";
// Import all endpoint functions
import {
  getArtist,
  getArtistSetlists,
  searchArtists,
} from "./endpoints/artists";

import {
  getCityByGeoId,
  searchCities,
} from "./endpoints/cities";

import {
  searchCountries,
} from "./endpoints/countries";

import {
  getSetlist,
  searchSetlists,
} from "./endpoints/setlists";

import {
  getVenue,
  getVenueSetlists,
  searchVenues,
} from "./endpoints/venues";

import { HttpClient } from "./utils/http";

import { RateLimitProfile } from "./utils/rateLimiter";

/**
 * Configuration options for the SetlistFM client.
 */
export type SetlistFMClientConfig = {
  /** API key for authentication with setlist.fm */
  apiKey: string;
  /** User agent string for identifying your application */
  userAgent: string;
  /** Request timeout in milliseconds */
  timeout?: number;
  /** Language code for internationalization (e.g., 'en', 'es', 'fr', 'de', 'pt', 'tr', 'it', 'pl') */
  language?: string;
  /** Rate limiting configuration (defaults to STANDARD profile if not provided) */
  rateLimit?: RateLimitConfig;
};

/**
 * Main client for interacting with the setlist.fm API.
 *
 * Provides access to all API endpoints through organized modules for artists,
 * setlists, venues, cities, countries, and users.
 *
 * Rate limiting is enabled by default using the STANDARD profile (2 req/sec, 1440 req/day).
 * To use a different profile or disable rate limiting, explicitly set the rateLimit configuration.
 */
export class SetlistFMClient implements SetlistFMClientPublic {
  private readonly httpClient: HttpClient;

  constructor(config: SetlistFMClientConfig) {
    // Apply default STANDARD rate limiting if none provided
    const rateLimit = config.rateLimit ?? {
      profile: RateLimitProfile.STANDARD,
    };

    const httpConfig: HttpClientConfig = {
      apiKey: config.apiKey,
      userAgent: config.userAgent,
      timeout: config.timeout,
      language: config.language,
      rateLimit,
    };

    this.httpClient = new HttpClient(httpConfig);
  }

  /**
   * Updates the language for subsequent API requests.
   *
   * @param {string} language - Language code for internationalization.
   *
   * @example
   * ```ts
   * client.setLanguage('es'); // Switch to Spanish
   * ```
   */
  setLanguage(language: string): void {
    this.httpClient.setLanguage(language);
  }

  /**
   * Gets the base URL being used for API requests.
   *
   * @returns {string} The base URL of the setlist.fm API.
   */
  getBaseUrl(): string {
    return this.httpClient.getBaseUrl();
  }

  /**
   * Gets the underlying HTTP client for advanced usage.
   *
   * @returns {HttpClient} The HTTP client instance.
   */
  getHttpClient(): HttpClient {
    return this.httpClient;
  }

  /**
   * Gets the current rate limit status.
   *
   * @returns {object} Rate limit status information.
   */
  getRateLimitStatus(): ReturnType<HttpClient["getRateLimitStatus"]> {
    return this.httpClient.getRateLimitStatus();
  }

  // Artist methods

  /**
   * Searches for artists based on provided criteria.
   *
   * @param {SearchArtistsParams} params - Search parameters for finding artists.
   * @returns {Promise<Artists>} A promise that resolves to a paginated list of artists.
   */
  searchArtists(params: SearchArtistsParams): Promise<Artists> {
    return searchArtists(this.httpClient, params);
  }

  /**
   * Gets detailed information about a specific artist.
   *
   * @param {string} mbid - MusicBrainz ID of the artist.
   * @returns {Promise<Artist>} A promise that resolves to the artist details.
   */
  getArtist(mbid: string): Promise<Artist> {
    return getArtist(this.httpClient, mbid);
  }

  /**
   * Gets setlists for a specific artist.
   *
   * @param {string} mbid - MusicBrainz ID of the artist.
   * @param {number} [page] - Page number for pagination (optional).
   * @returns {Promise<ArtistSetlists>} A promise that resolves to a paginated list of setlists.
   */
  getArtistSetlists(mbid: string, page?: number): Promise<ArtistSetlists> {
    const params = page ? { p: page } : {};
    return getArtistSetlists(this.httpClient, mbid, params);
  }

  // Setlist methods

  /**
   * Gets a specific setlist by its ID.
   *
   * @param {string} id - The setlist ID.
   * @returns {Promise<Setlist>} A promise that resolves to the setlist details.
   */
  getSetlist(id: string): Promise<Setlist> {
    return getSetlist(this.httpClient, id);
  }

  /**
   * Searches for setlists based on provided criteria.
   *
   * @param {SearchSetlistsParams} params - Search parameters for finding setlists.
   * @returns {Promise<Setlists>} A promise that resolves to a paginated list of setlists.
   */
  searchSetlists(params: SearchSetlistsParams): Promise<Setlists> {
    return searchSetlists(this.httpClient, params);
  }

  // Venue methods

  /**
   * Gets detailed information about a specific venue.
   *
   * @param {string} id - The venue ID.
   * @returns {Promise<Venue>} A promise that resolves to the venue details.
   */
  getVenue(id: string): Promise<Venue> {
    return getVenue(this.httpClient, id);
  }

  /**
   * Searches for venues based on provided criteria.
   *
   * @param {SearchVenuesParams} params - Search parameters for finding venues.
   * @returns {Promise<Venues>} A promise that resolves to a paginated list of venues.
   */
  searchVenues(params: SearchVenuesParams): Promise<Venues> {
    return searchVenues(this.httpClient, params);
  }

  /**
   * Gets setlists for a specific venue.
   *
   * @param {string} id - The venue ID.
   * @returns {Promise<ArtistSetlists>} A promise that resolves to a paginated list of setlists.
   */
  getVenueSetlists(id: string): Promise<ArtistSetlists> {
    return getVenueSetlists(this.httpClient, id);
  }

  // City methods

  /**
   * Searches for cities based on provided criteria.
   *
   * @param {SearchCitiesParams} params - Search parameters for finding cities.
   * @returns {Promise<Cities>} A promise that resolves to a paginated list of cities.
   */
  searchCities(params: SearchCitiesParams): Promise<Cities> {
    return searchCities(this.httpClient, params);
  }

  /**
   * Gets a city by its GeoNames ID.
   *
   * @param {string} geoId - The GeoNames ID of the city.
   * @returns {Promise<City>} A promise that resolves to the city details.
   */
  getCityByGeoId(geoId: string): Promise<City> {
    return getCityByGeoId(this.httpClient, geoId);
  }

  // Country methods

  /**
   * Gets a list of all available countries.
   *
   * @returns {Promise<Countries>} A promise that resolves to a paginated list of countries.
   */
  searchCountries(): Promise<Countries> {
    return searchCountries(this.httpClient);
  }
}

/**
 * Creates a new SetlistFM client instance.
 *
 * Rate limiting is enabled by default using the STANDARD profile (2 req/sec, 1440 req/day).
 * To use a different profile, explicitly provide a rateLimit configuration.
 *
 * @param {SetlistFMClientConfig} config - Configuration options for the client.
 * @returns {SetlistFMClientPublic} A new SetlistFM client instance with public API.
 * @throws {Error} If required configuration is missing or invalid.
 *
 * @example
 * ```ts
 * // Default rate limiting (STANDARD profile)
 * const client = createSetlistFMClient({
 *   apiKey: 'your-api-key-here',
 *   userAgent: 'your-app-name (your-email@example.com)',
 * });
 *
 * // Premium rate limiting
 * const premiumClient = createSetlistFMClient({
 *   apiKey: 'your-api-key-here',
 *   userAgent: 'your-app-name (your-email@example.com)',
 *   rateLimit: { profile: RateLimitProfile.PREMIUM }
 * });
 *
 * // Disable rate limiting
 * const noLimitClient = createSetlistFMClient({
 *   apiKey: 'your-api-key-here',
 *   userAgent: 'your-app-name (your-email@example.com)',
 *   rateLimit: { profile: RateLimitProfile.DISABLED }
 * });
 * ```
 */
export function createSetlistFMClient(config: SetlistFMClientConfig): SetlistFMClientPublic {
  if (!config.apiKey) {
    throw new Error("API key is required");
  }
  if (!config.userAgent) {
    throw new Error("User agent is required");
  }

  return new SetlistFMClient(config);
}

// Re-export for convenience
export { RateLimitProfile } from "./utils/rateLimiter";
