/**
 * @file types.ts
 * @description Core type definitions for the setlist.fm API.
 * @author tkozzer
 * @module types
 */

/**
 * Represents a MusicBrainz identifier.
 */
export type MBID = string;

/**
 * Represents a GeoNames identifier for cities.
 */
export type GeoId = string;

/**
 * Represents a setlist.fm user identifier.
 */
export type UserId = string;

/**
 * Represents a venue identifier.
 */
export type VenueId = string;

/**
 * Represents a setlist identifier.
 */
export type SetlistId = string;

/**
 * Represents a setlist version identifier.
 */
export type VersionId = string;

/**
 * Represents coordinates for geographical locations.
 */
export type Coordinates = {
  /** Latitude in decimal degrees */
  lat: number;
  /** Longitude in decimal degrees */
  long: number;
};

/**
 * Represents a country in the setlist.fm API.
 */
export type Country = {
  /** ISO 3166-1 alpha-2 country code */
  code: string;
  /** Localized name of the country */
  name: string;
};

/**
 * Represents a city in the setlist.fm API.
 */
export type City = {
  /** GeoNames identifier */
  id: GeoId;
  /** Name of the city */
  name: string;
  /** State or province (if applicable) */
  state?: string;
  /** State code (if applicable) */
  stateCode?: string;
  /** Country information */
  country: Country;
  /** Geographical coordinates */
  coords: Coordinates;
};

/**
 * Represents an artist in the setlist.fm API.
 */
export type Artist = {
  /** MusicBrainz identifier */
  mbid: MBID;
  /** Artist name */
  name: string;
  /** Sort name for the artist (e.g., "Beatles, The" or "Springsteen, Bruce") */
  sortName: string;
  /** Disambiguation string to distinguish between artists with same names */
  disambiguation?: string;
  /** URL to the artist's setlists on setlist.fm */
  url?: string;
};

/**
 * Represents a venue in the setlist.fm API.
 */
export type Venue = {
  /** Venue identifier */
  id: VenueId;
  /** Venue name */
  name: string;
  /** City where the venue is located */
  city: City;
  /** URL to setlist.fm page */
  url?: string;
};

/**
 * Represents a tour in the setlist.fm API.
 */
export type Tour = {
  /** Tour name */
  name: string;
};

/**
 * Represents a song in a setlist.
 */
export type Song = {
  /** Song name */
  name: string;
  /** Artist who originally performed the song (for covers) */
  cover?: Artist;
  /** Additional info about the song */
  info?: string;
  /** Whether this is a tape/recording */
  tape?: boolean;
};

/**
 * Represents a set in a setlist (e.g., main set, encore).
 */
export type Set = {
  /** Name of the set (e.g., "Encore", "Set 1") */
  name?: string;
  /** Songs in this set */
  song: Song[];
  /** Whether this is an encore */
  encore?: boolean;
};

/**
 * Represents a complete setlist.
 */
export type Setlist = {
  /** Setlist identifier */
  id: SetlistId;
  /** Version identifier */
  versionId: VersionId;
  /** Date of the event (YYYY-MM-DD format) */
  eventDate: string;
  /** Last update timestamp */
  lastUpdated: string;
  /** Artist who performed */
  artist: Artist;
  /** Venue where the performance took place */
  venue: Venue;
  /** Tour information (if applicable) */
  tour?: Tour;
  /** Sets in the setlist */
  sets: {
    /** Array of sets */
    set: Set[];
  };
  /** Additional info about the setlist */
  info?: string;
  /** URL to setlist.fm page */
  url?: string;
};

/**
 * Represents a setlist.fm user.
 */
export type User = {
  /** User identifier */
  userId: UserId;
  /** Username */
  username: string;
  /** Full name */
  fullname?: string;
  /** Last FM username */
  lastFm?: string;
  /** MySpace username */
  mySpace?: string;
  /** Twitter username */
  twitter?: string;
  /** Flickr username */
  flickr?: string;
  /** Website URL */
  website?: string;
  /** About text */
  about?: string;
  /** URL to setlist.fm page */
  url?: string;
};

/**
 * Common pagination parameters for API requests.
 */
export type PaginationParams = {
  /** Page number (1-based) */
  p?: number;
};

/**
 * Represents a paginated response from the API.
 */
export type PaginatedResponse<T> = {
  /** Current page number */
  page: number;
  /** Total number of items */
  total: number;
  /** Items per page */
  itemsPerPage: number;
  /** The data items */
  data: T;
};
