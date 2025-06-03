/**
 * @file client.types.ts
 * @description Type definitions for the SetlistFM client public interface.
 * @author tkozzer
 * @module client
 */

import type {
  Artists,
  Setlists as ArtistSetlists,
  // Artist types
  SearchArtistsParams,
} from "./endpoints/artists";

import type {
  Cities,
  City,
  // City types
  SearchCitiesParams,
} from "./endpoints/cities";

import type {
  Countries,
} from "./endpoints/countries";

import type {
  // Setlist types
  SearchSetlistsParams,
  Setlist,
  Setlists,
} from "./endpoints/setlists";

import type {
  // Venue types
  SearchVenuesParams,
  Venue,
  Venues,
} from "./endpoints/venues";

import type { Artist } from "./shared/types";

/**
 * Public interface for the SetlistFM client.
 *
 * This interface defines all the methods available to users of the SDK,
 * providing type-safe access to all setlist.fm API endpoints.
 */
export type SetlistFMClientPublic = {
  // Artist methods

  /**
   * Searches for artists based on provided criteria.
   *
   * @param {SearchArtistsParams} params - Search parameters for finding artists.
   * @returns {Promise<Artists>} A promise that resolves to a paginated list of artists.
   */
  searchArtists: (params: SearchArtistsParams) => Promise<Artists>;

  /**
   * Gets detailed information about a specific artist.
   *
   * @param {string} mbid - MusicBrainz ID of the artist.
   * @returns {Promise<Artist>} A promise that resolves to the artist details.
   */
  getArtist: (mbid: string) => Promise<Artist>;

  /**
   * Gets setlists for a specific artist.
   *
   * @param {string} mbid - MusicBrainz ID of the artist.
   * @param {number} [page] - Page number for pagination (optional).
   * @returns {Promise<ArtistSetlists>} A promise that resolves to a paginated list of setlists.
   */
  getArtistSetlists: (mbid: string, page?: number) => Promise<ArtistSetlists>;

  // Setlist methods

  /**
   * Gets a specific setlist by its ID.
   *
   * @param {string} id - The setlist ID.
   * @returns {Promise<Setlist>} A promise that resolves to the setlist details.
   */
  getSetlist: (id: string) => Promise<Setlist>;

  /**
   * Searches for setlists based on provided criteria.
   *
   * @param {SearchSetlistsParams} params - Search parameters for finding setlists.
   * @returns {Promise<Setlists>} A promise that resolves to a paginated list of setlists.
   */
  searchSetlists: (params: SearchSetlistsParams) => Promise<Setlists>;

  // Venue methods

  /**
   * Gets detailed information about a specific venue.
   *
   * @param {string} id - The venue ID.
   * @returns {Promise<Venue>} A promise that resolves to the venue details.
   */
  getVenue: (id: string) => Promise<Venue>;

  /**
   * Searches for venues based on provided criteria.
   *
   * @param {SearchVenuesParams} params - Search parameters for finding venues.
   * @returns {Promise<Venues>} A promise that resolves to a paginated list of venues.
   */
  searchVenues: (params: SearchVenuesParams) => Promise<Venues>;

  /**
   * Gets setlists for a specific venue.
   *
   * @param {string} id - The venue ID.
   * @returns {Promise<ArtistSetlists>} A promise that resolves to a paginated list of setlists.
   */
  getVenueSetlists: (id: string) => Promise<ArtistSetlists>;

  // City methods

  /**
   * Searches for cities based on provided criteria.
   *
   * @param {SearchCitiesParams} params - Search parameters for finding cities.
   * @returns {Promise<Cities>} A promise that resolves to a paginated list of cities.
   */
  searchCities: (params: SearchCitiesParams) => Promise<Cities>;

  /**
   * Gets a city by its GeoNames ID.
   *
   * @param {string} geoId - The GeoNames ID of the city.
   * @returns {Promise<City>} A promise that resolves to the city details.
   */
  getCityByGeoId: (geoId: string) => Promise<City>;

  // Country methods

  /**
   * Gets a list of all available countries.
   *
   * @returns {Promise<Countries>} A promise that resolves to a paginated list of countries.
   */
  searchCountries: () => Promise<Countries>;

  // Utility methods

  /**
   * Updates the language for subsequent API requests.
   *
   * @param {string} language - Language code for internationalization.
   */
  setLanguage: (language: string) => void;

  /**
   * Gets the base URL being used for API requests.
   *
   * @returns {string} The base URL of the setlist.fm API.
   */
  getBaseUrl: () => string;

  /**
   * Gets the underlying HTTP client for advanced usage.
   *
   * @returns {HttpClient} The HTTP client instance.
   */
  getHttpClient: () => any; // Using 'any' to avoid exposing internal HttpClient type

  /**
   * Gets the current rate limit status.
   *
   * @returns {object} Rate limit status information.
   */
  getRateLimitStatus: () => any; // Using 'any' to avoid exposing internal rate limit types
};
