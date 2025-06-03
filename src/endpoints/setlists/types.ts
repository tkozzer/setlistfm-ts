/**
 * @file types.ts
 * @description Type definitions specific to setlists endpoints.
 * @author tkozzer
 * @module setlists
 */

import type { Venue } from "@endpoints/venues/types";
import type { Artist, PaginationParams } from "@shared/types";

/**
 * Represents a tour a setlist was part of.
 */
export type Tour = {
  /** The name of the tour */
  name: string;
};

/**
 * Represents a song in a setlist with performance details.
 */
export type Song = {
  /** The name of the song */
  name: string;
  /** A different artist than the performing one that joined the stage for this song */
  with?: Artist;
  /** The original artist of this song, if different to the performing artist */
  cover?: Artist;
  /** Special incidents or additional information about the way the song was performed */
  info?: string;
  /** Whether the song came from tape rather than being performed live */
  tape?: boolean;
};

/**
 * Represents a set in a setlist (e.g., main set, encore).
 */
export type Set = {
  /** The description/name of the set (e.g., "Acoustic set" or "Paul McCartney solo") */
  name?: string;
  /** If the set is an encore, this is the number of the encore, starting with 1 */
  encore?: number;
  /** This set's songs */
  song: Song[];
};

/**
 * Represents a complete setlist from the setlist.fm API.
 */
export type Setlist = {
  /** The setlist's artist */
  artist: Artist;
  /** The setlist's venue */
  venue: Venue;
  /** The setlist's tour */
  tour?: Tour;
  /** All sets of this setlist wrapped in sets object */
  sets: {
    set: Set[];
  };
  /** Additional information on the concert */
  info?: string;
  /** The attribution URL to which you must link wherever you use data from this setlist */
  url: string;
  /** Unique identifier for the setlist */
  id: string;
  /** Unique identifier of the setlist version */
  versionId: string;
  /** Date of the concert in the format "dd-MM-yyyy" */
  eventDate: string;
  /** Date, time, and time zone of the last update in format "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ" */
  lastUpdated: string;
};

/**
 * Represents a paginated response containing setlists.
 */
export type Setlists = {
  /** Array of setlist objects */
  setlist: Setlist[];
  /** Total number of setlists matching the query */
  total: number;
  /** Current page number (starts at 1) */
  page: number;
  /** Number of items per page */
  itemsPerPage: number;
};

/**
 * Parameters for searching setlists via GET /1.0/search/setlists.
 */
export type SearchSetlistsParams = PaginationParams & {
  /** The artist's Musicbrainz Identifier (mbid) */
  artistMbid?: string;
  /** The artist's name */
  artistName?: string;
  /** The artist's Ticketmaster Identifier (deprecated) */
  artistTmid?: number;
  /** The city's geoId */
  cityId?: string;
  /** The name of the city */
  cityName?: string;
  /** The country code */
  countryCode?: string;
  /** The date of the event (format dd-MM-yyyy) */
  date?: string;
  /** The event's Last.fm Event ID (deprecated) */
  lastFm?: number;
  /** The date and time (UTC) when this setlist was last updated (format yyyyMMddHHmmss) */
  lastUpdated?: string;
  /** The state */
  state?: string;
  /** The state code */
  stateCode?: string;
  /** The tour name */
  tourName?: string;
  /** The venue id */
  venueId?: string;
  /** The name of the venue */
  venueName?: string;
  /** The year of the event */
  year?: number;
};

/**
 * Parameters for getting a setlist by ID via GET /1.0/setlist/{setlistId}.
 */
export type GetSetlistParams = {
  /** The setlist ID */
  setlistId: string;
};
