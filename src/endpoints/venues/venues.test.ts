/**
 * @file venues.test.ts
 * @description Test suite for venues endpoint functionality.
 * @author tkozzer
 * @module Venues
 */

import type { Setlists } from "@endpoints/setlists/types";

import type { HttpClient } from "@utils/http";
import type { Venue, Venues } from "./types";

import { AuthenticationError, NotFoundError, SetlistFMAPIError, ValidationError } from "@shared/error";

import { beforeEach, describe, expect, it, vi } from "vitest";

import { getVenue } from "./getVenue";
import { getVenueSetlists } from "./getVenueSetlists";
import { searchVenues } from "./searchVenues";

// Test index.ts exports
describe("index exports", () => {
  it("should export all venue functions and types", async () => {
    const indexModule = await import("./index.js");

    // Test function exports
    expect(typeof indexModule.getVenue).toBe("function");
    expect(typeof indexModule.getVenueSetlists).toBe("function");
    expect(typeof indexModule.searchVenues).toBe("function");

    // Test validation schema exports
    expect(indexModule.VenueIdParamSchema).toBeDefined();
    expect(indexModule.SearchVenuesParamsSchema).toBeDefined();
    expect(indexModule.GetVenueSetlistsParamsSchema).toBeDefined();
    expect(indexModule.VenueSchema).toBeDefined();
    expect(indexModule.VenuesSchema).toBeDefined();
  });
});

describe("getVenue", () => {
  let mockHttpClient: HttpClient;
  const validVenueId = "6bd6ca6e";
  const mockVenue: Venue = {
    city: {
      id: "5357527",
      name: "Hollywood",
      stateCode: "CA",
      state: "California",
      coords: {
        long: -118.3267434,
        lat: 34.0983425,
      },
      country: {
        code: "US",
        name: "United States",
      },
    },
    url: "https://www.setlist.fm/venue/compaq-center-san-jose-ca-usa-6bd6ca6e.html",
    id: "6bd6ca6e",
    name: "Compaq Center",
  };

  beforeEach(() => {
    mockHttpClient = {
      get: vi.fn(),
    } as any;
  });

  describe("successful requests", () => {
    it("should return venue data for valid venueId", async () => {
      vi.mocked(mockHttpClient.get).mockResolvedValue(mockVenue);

      const result = await getVenue(mockHttpClient, validVenueId);

      expect(result).toEqual(mockVenue);
      expect(mockHttpClient.get).toHaveBeenCalledWith(`/venue/${validVenueId}`);
    });

    it("should handle venue without city", async () => {
      const venueWithoutCity: Venue = {
        url: "https://www.setlist.fm/venue/unknown-venue-abc12345.html",
        id: "abc12345",
        name: "Unknown Venue",
      };

      vi.mocked(mockHttpClient.get).mockResolvedValue(venueWithoutCity);

      const result = await getVenue(mockHttpClient, "abc12345");

      expect(result).toEqual(venueWithoutCity);
      expect(result.city).toBeUndefined();
    });

    it("should handle venue with different city data", async () => {
      const venueWithDifferentCity: Venue = {
        city: {
          id: "2643743",
          name: "London",
          stateCode: "ENG",
          state: "England",
          coords: {
            long: -0.1276,
            lat: 51.5074,
          },
          country: {
            code: "GB",
            name: "United Kingdom",
          },
        },
        url: "https://www.setlist.fm/venue/wembley-stadium-london-england-def45678.html",
        id: "def45678",
        name: "Wembley Stadium",
      };

      vi.mocked(mockHttpClient.get).mockResolvedValue(venueWithDifferentCity);

      const result = await getVenue(mockHttpClient, "def45678");

      expect(result).toEqual(venueWithDifferentCity);
      expect(result.city?.name).toBe("London");
      expect(result.city?.country.code).toBe("GB");
    });

    it("should handle venue with extreme coordinate values in city", async () => {
      const venueWithExtremeCoords: Venue = {
        city: {
          id: "1234567",
          name: "Test City",
          stateCode: "TC",
          state: "Test State",
          coords: {
            long: 180, // Maximum longitude
            lat: 90, // Maximum latitude
          },
          country: {
            code: "TC",
            name: "Test Country",
          },
        },
        url: "https://www.setlist.fm/venue/test-venue-12345678.html",
        id: "12345678",
        name: "Test Venue",
      };

      vi.mocked(mockHttpClient.get).mockResolvedValue(venueWithExtremeCoords);

      const result = await getVenue(mockHttpClient, "12345678");

      expect(result).toEqual(venueWithExtremeCoords);
      expect(result.city?.coords.long).toBe(180);
      expect(result.city?.coords.lat).toBe(90);
    });

    it("should handle venue with negative coordinates in city", async () => {
      const venueWithNegativeCoords: Venue = {
        city: {
          id: "7890123",
          name: "Buenos Aires",
          stateCode: "C",
          state: "Ciudad Autónoma de Buenos Aires",
          coords: {
            long: -58.3816,
            lat: -34.6037,
          },
          country: {
            code: "AR",
            name: "Argentina",
          },
        },
        url: "https://www.setlist.fm/venue/luna-park-buenos-aires-argentina-87654321.html",
        id: "87654321",
        name: "Luna Park",
      };

      vi.mocked(mockHttpClient.get).mockResolvedValue(venueWithNegativeCoords);

      const result = await getVenue(mockHttpClient, "87654321");

      expect(result).toEqual(venueWithNegativeCoords);
      expect(result.city?.coords.long).toBe(-58.3816);
      expect(result.city?.coords.lat).toBe(-34.6037);
    });
  });

  describe("validation errors", () => {
    it("should throw ValidationError for empty venueId", async () => {
      await expect(getVenue(mockHttpClient, ""))
        .rejects
        .toThrow(ValidationError);

      await expect(getVenue(mockHttpClient, ""))
        .rejects
        .toThrow("Invalid venue ID: Value cannot be empty");
    });

    it("should throw ValidationError for null venueId", async () => {
      await expect(getVenue(mockHttpClient, null as any))
        .rejects
        .toThrow(ValidationError);
    });

    it("should throw ValidationError for undefined venueId", async () => {
      await expect(getVenue(mockHttpClient, undefined as any))
        .rejects
        .toThrow(ValidationError);
    });

    it("should throw ValidationError for invalid venueId format", async () => {
      const invalidVenueIds = [
        "6bd6ca6", // Too short
        "6bd6ca6ee", // Too long
        "6BD6CA6E", // Uppercase
        "6gd6ca6e", // Invalid character 'g'
        "6bd6ca6z", // Invalid character 'z'
        "6bd-ca6e", // Contains hyphen
        "6bd.ca6e", // Contains dot
        "6bd ca6e", // Contains space
        "6bd_ca6e", // Contains underscore
        "#6bd6ca6e", // Contains special character
        "6bd6ca6e!", // Contains exclamation
        "123456789", // Wrong length
        "abcdefgh", // Valid length but contains invalid characters
      ];

      for (const invalidVenueId of invalidVenueIds) {
        await expect(getVenue(mockHttpClient, invalidVenueId))
          .rejects
          .toThrow(ValidationError);

        await expect(getVenue(mockHttpClient, invalidVenueId))
          .rejects
          .toThrow("Invalid venue ID: Venue ID must be an 8-character hexadecimal string");
      }
    });

    it("should accept valid hexadecimal venue IDs", async () => {
      vi.mocked(mockHttpClient.get).mockResolvedValue(mockVenue);

      const validVenueIds = [
        "6bd6ca6e",
        "12345678",
        "abcdef01",
        "fedcba98",
        "0f0f0f0f",
        "a1b2c3d4",
        "00000000",
        "ffffffff",
      ];

      for (const validVenueId of validVenueIds) {
        vi.mocked(mockHttpClient.get).mockClear();

        const result = await getVenue(mockHttpClient, validVenueId);

        expect(result).toEqual(mockVenue);
        expect(mockHttpClient.get).toHaveBeenCalledWith(`/venue/${validVenueId}`);
      }
    });
  });

  describe("API errors", () => {
    it("should throw NotFoundError for non-existent venue", async () => {
      const notFoundError = new NotFoundError("Venue not found", "/venue/deadbeef");
      vi.mocked(mockHttpClient.get).mockRejectedValue(notFoundError);

      await expect(getVenue(mockHttpClient, "deadbeef"))
        .rejects
        .toThrow(NotFoundError);
    });

    it("should throw AuthenticationError for invalid API key", async () => {
      const authError = new AuthenticationError("Invalid API key");
      vi.mocked(mockHttpClient.get).mockRejectedValue(authError);

      await expect(getVenue(mockHttpClient, validVenueId))
        .rejects
        .toThrow(AuthenticationError);
    });

    it("should throw SetlistFMAPIError for rate limiting", async () => {
      const apiError = new SetlistFMAPIError("Rate limit exceeded", 429);
      vi.mocked(mockHttpClient.get).mockRejectedValue(apiError);

      await expect(getVenue(mockHttpClient, validVenueId))
        .rejects
        .toThrow(SetlistFMAPIError);
    });

    it("should handle generic HTTP errors", async () => {
      const genericError = {
        statusCode: 500,
        message: "Internal Server Error",
        response: { data: { error: "Server error" } },
      };
      vi.mocked(mockHttpClient.get).mockRejectedValue(genericError);

      await expect(getVenue(mockHttpClient, validVenueId))
        .rejects
        .toThrow("Internal Server Error");
    });

    it("should handle network errors", async () => {
      const networkError = {
        message: "Network timeout",
      };
      vi.mocked(mockHttpClient.get).mockRejectedValue(networkError);

      await expect(getVenue(mockHttpClient, validVenueId))
        .rejects
        .toThrow("Network timeout");
    });

    it("should handle errors without status code", async () => {
      const unknownError = {
        message: "Unknown error occurred",
      };
      vi.mocked(mockHttpClient.get).mockRejectedValue(unknownError);

      await expect(getVenue(mockHttpClient, validVenueId))
        .rejects
        .toThrow("Unknown error occurred");
    });

    it("should handle errors without message", async () => {
      const errorWithoutMessage = {
        statusCode: 503,
        response: { data: { error: "Service unavailable" } },
      };
      vi.mocked(mockHttpClient.get).mockRejectedValue(errorWithoutMessage);

      await expect(getVenue(mockHttpClient, validVenueId))
        .rejects
        .toThrow("Failed to retrieve venue");
    });
  });
});

describe("getVenueSetlists", () => {
  let mockHttpClient: HttpClient;
  const validVenueId = "6bd6ca6e";
  const mockSetlists: Setlists = {
    setlist: [
      {
        id: "63de4613",
        versionId: "7be1aaa0",
        eventDate: "23-08-1964",
        lastUpdated: "2013-10-20T05:18:08.000+0000",
        artist: {
          mbid: "b10bbbfc-cf9e-42e0-be17-e2c3e1d2600d",
          name: "The Beatles",
          sortName: "Beatles, The",
          disambiguation: "John, Paul, George and Ringo",
          url: "https://www.setlist.fm/setlists/the-beatles-23d6a88b.html",
        },
        venue: {
          id: "6bd6ca6e",
          name: "Compaq Center",
          city: {
            id: "5357527",
            name: "Hollywood",
            state: "California",
            stateCode: "CA",
            coords: { long: -118.3267434, lat: 34.0983425 },
            country: { code: "US", name: "United States" },
          },
          url: "https://www.setlist.fm/venue/compaq-center-san-jose-ca-usa-6bd6ca6e.html",
        },
        sets: {
          set: [
            {
              song: [
                { name: "Twist and Shout" },
                { name: "Please Please Me" },
                { name: "I Want to Hold Your Hand" },
              ],
            },
          ],
        },
        tour: {
          name: "North American Tour 1964",
        },
        info: "Recorded and published as 'The Beatles at the Hollywood Bowl'",
        url: "https://www.setlist.fm/setlist/the-beatles/1964/hollywood-bowl-hollywood-ca-63de4613.html",
      },
    ],
    total: 42,
    page: 1,
    itemsPerPage: 20,
  };

  beforeEach(() => {
    mockHttpClient = {
      get: vi.fn(),
    } as any;
  });

  describe("successful requests", () => {
    it("should return setlists data for valid venueId", async () => {
      vi.mocked(mockHttpClient.get).mockResolvedValue(mockSetlists);

      const result = await getVenueSetlists(mockHttpClient, validVenueId);

      expect(result).toEqual(mockSetlists);
      expect(mockHttpClient.get).toHaveBeenCalledWith(`/venue/${validVenueId}/setlists`, {});
    });

    it("should handle pagination parameters", async () => {
      vi.mocked(mockHttpClient.get).mockResolvedValue(mockSetlists);

      const result = await getVenueSetlists(mockHttpClient, validVenueId, { p: 2 });

      expect(result).toEqual(mockSetlists);
      expect(mockHttpClient.get).toHaveBeenCalledWith(`/venue/${validVenueId}/setlists`, { p: 2 });
    });

    it("should handle empty setlists response", async () => {
      const emptyResponse: Setlists = {
        setlist: [],
        total: 0,
        page: 1,
        itemsPerPage: 20,
      };

      vi.mocked(mockHttpClient.get).mockResolvedValue(emptyResponse);

      const result = await getVenueSetlists(mockHttpClient, validVenueId);

      expect(result).toEqual(emptyResponse);
      expect(result.setlist).toHaveLength(0);
      expect(result.total).toBe(0);
    });

    it("should handle setlists with multiple sets", async () => {
      const setlistsWithMultipleSets: Setlists = {
        setlist: [
          {
            id: "test123",
            versionId: "version1",
            eventDate: "15-06-2023",
            lastUpdated: "2023-06-16T10:00:00.000+0000",
            url: "https://example.com/setlist1",
            artist: {
              mbid: "test-mbid",
              name: "Test Artist",
              sortName: "Artist, Test",
            },
            venue: {
              id: "6bd6ca6e",
              name: "Test Venue",
              url: "https://example.com/venue",
              city: {
                id: "test-city",
                name: "Test City",
                stateCode: "TS",
                state: "Test State",
                coords: { long: 0, lat: 0 },
                country: { code: "US", name: "United States" },
              },
            },
            sets: {
              set: [
                {
                  song: [
                    { name: "Song 1" },
                    { name: "Song 2" },
                  ],
                },
                {
                  name: "Encore",
                  encore: 1,
                  song: [
                    { name: "Encore Song" },
                  ],
                },
              ],
            },
          },
        ],
        total: 1,
        page: 1,
        itemsPerPage: 20,
      };

      vi.mocked(mockHttpClient.get).mockResolvedValue(setlistsWithMultipleSets);

      const result = await getVenueSetlists(mockHttpClient, validVenueId);

      expect(result).toEqual(setlistsWithMultipleSets);
      expect(result.setlist[0].sets.set).toHaveLength(2);
      expect(result.setlist[0].sets.set[1].encore).toBe(1);
    });

    it("should handle setlists with cover songs", async () => {
      const setlistsWithCovers: Setlists = {
        setlist: [
          {
            id: "covers123",
            versionId: "version2",
            eventDate: "20-07-2023",
            lastUpdated: "2023-07-21T10:00:00.000+0000",
            url: "https://example.com/setlist2",
            artist: {
              mbid: "cover-artist-mbid",
              name: "Cover Artist",
              sortName: "Artist, Cover",
            },
            venue: {
              id: "6bd6ca6e",
              name: "Cover Venue",
              url: "https://example.com/cover",
              city: {
                id: "cover-city",
                name: "Cover City",
                stateCode: "CC",
                state: "Cover State",
                coords: { long: 10, lat: 20 },
                country: { code: "GB", name: "United Kingdom" },
              },
            },
            sets: {
              set: [
                {
                  song: [
                    { name: "Original Song" },
                    {
                      name: "Covered Song",
                      cover: {
                        mbid: "original-artist-mbid",
                        name: "Original Artist",
                        sortName: "Artist, Original",
                      },
                    },
                  ],
                },
              ],
            },
          },
        ],
        total: 1,
        page: 1,
        itemsPerPage: 20,
      };

      vi.mocked(mockHttpClient.get).mockResolvedValue(setlistsWithCovers);

      const result = await getVenueSetlists(mockHttpClient, validVenueId);

      expect(result).toEqual(setlistsWithCovers);
      expect(result.setlist[0].sets.set[0].song[1].cover).toBeDefined();
      expect(result.setlist[0].sets.set[0].song[1].cover?.name).toBe("Original Artist");
    });
  });

  describe("validation errors", () => {
    it("should throw ValidationError for empty venueId", async () => {
      await expect(getVenueSetlists(mockHttpClient, ""))
        .rejects
        .toThrow(ValidationError);

      await expect(getVenueSetlists(mockHttpClient, ""))
        .rejects
        .toThrow("Invalid venue ID: Value cannot be empty");
    });

    it("should throw ValidationError for null venueId", async () => {
      await expect(getVenueSetlists(mockHttpClient, null as any))
        .rejects
        .toThrow(ValidationError);
    });

    it("should throw ValidationError for undefined venueId", async () => {
      await expect(getVenueSetlists(mockHttpClient, undefined as any))
        .rejects
        .toThrow(ValidationError);
    });

    it("should throw ValidationError for invalid venueId format", async () => {
      const invalidVenueIds = [
        "6bd6ca6", // Too short
        "6bd6ca6ee", // Too long
        "6BD6CA6E", // Uppercase
        "6gd6ca6e", // Invalid character 'g'
        "6bd6ca6z", // Invalid character 'z'
        "6bd-ca6e", // Contains hyphen
        "6bd.ca6e", // Contains dot
        "6bd ca6e", // Contains space
        "6bd_ca6e", // Contains underscore
        "#6bd6ca6e", // Contains special character
        "6bd6ca6e!", // Contains exclamation
      ];

      for (const invalidVenueId of invalidVenueIds) {
        await expect(getVenueSetlists(mockHttpClient, invalidVenueId))
          .rejects
          .toThrow(ValidationError);

        await expect(getVenueSetlists(mockHttpClient, invalidVenueId))
          .rejects
          .toThrow("Invalid venue ID: Venue ID must be an 8-character hexadecimal string");
      }
    });

    it("should throw ValidationError for invalid pagination parameters", async () => {
      const invalidParams = [
        { p: 0 }, // Invalid page number
        { p: -1 }, // Negative page number
        { p: 1.5 }, // Non-integer page number
        { p: "2" as any }, // String instead of number
      ];

      for (const params of invalidParams) {
        await expect(getVenueSetlists(mockHttpClient, validVenueId, params))
          .rejects
          .toThrow(ValidationError);
      }
    });

    it("should accept valid hexadecimal venue IDs", async () => {
      vi.mocked(mockHttpClient.get).mockResolvedValue(mockSetlists);

      const validVenueIds = [
        "6bd6ca6e",
        "12345678",
        "abcdef01",
        "fedcba98",
        "0f0f0f0f",
        "a1b2c3d4",
        "00000000",
        "ffffffff",
      ];

      for (const validVenueId of validVenueIds) {
        vi.mocked(mockHttpClient.get).mockClear();

        const result = await getVenueSetlists(mockHttpClient, validVenueId);

        expect(result).toEqual(mockSetlists);
        expect(mockHttpClient.get).toHaveBeenCalledWith(`/venue/${validVenueId}/setlists`, {});
      }
    });

    it("should accept valid pagination parameters", async () => {
      vi.mocked(mockHttpClient.get).mockResolvedValue(mockSetlists);

      const validParams = [
        {}, // Empty object
        { p: 1 }, // First page
        { p: 10 }, // High page number
        { p: 999 }, // Very high page number
      ];

      for (const params of validParams) {
        vi.mocked(mockHttpClient.get).mockClear();

        const result = await getVenueSetlists(mockHttpClient, validVenueId, params);

        expect(result).toEqual(mockSetlists);
        expect(mockHttpClient.get).toHaveBeenCalledWith(`/venue/${validVenueId}/setlists`, params);
      }
    });
  });

  describe("API errors", () => {
    it("should throw NotFoundError for non-existent venue", async () => {
      const notFoundError = new NotFoundError("Venue not found", "/venue/deadbeef/setlists");
      vi.mocked(mockHttpClient.get).mockRejectedValue(notFoundError);

      await expect(getVenueSetlists(mockHttpClient, "deadbeef"))
        .rejects
        .toThrow(NotFoundError);
    });

    it("should throw AuthenticationError for invalid API key", async () => {
      const authError = new AuthenticationError("Invalid API key");
      vi.mocked(mockHttpClient.get).mockRejectedValue(authError);

      await expect(getVenueSetlists(mockHttpClient, validVenueId))
        .rejects
        .toThrow(AuthenticationError);
    });

    it("should throw SetlistFMAPIError for rate limiting", async () => {
      const apiError = new SetlistFMAPIError("Rate limit exceeded", 429);
      vi.mocked(mockHttpClient.get).mockRejectedValue(apiError);

      await expect(getVenueSetlists(mockHttpClient, validVenueId))
        .rejects
        .toThrow(SetlistFMAPIError);
    });

    it("should handle generic HTTP errors", async () => {
      const genericError = {
        statusCode: 500,
        message: "Internal Server Error",
        response: { data: { error: "Server error" } },
      };
      vi.mocked(mockHttpClient.get).mockRejectedValue(genericError);

      await expect(getVenueSetlists(mockHttpClient, validVenueId))
        .rejects
        .toThrow("Internal Server Error");
    });

    it("should handle network errors", async () => {
      const networkError = {
        message: "Network timeout",
      };
      vi.mocked(mockHttpClient.get).mockRejectedValue(networkError);

      await expect(getVenueSetlists(mockHttpClient, validVenueId))
        .rejects
        .toThrow("Network timeout");
    });

    it("should handle errors without status code", async () => {
      const unknownError = {
        message: "Unknown error occurred",
      };
      vi.mocked(mockHttpClient.get).mockRejectedValue(unknownError);

      await expect(getVenueSetlists(mockHttpClient, validVenueId))
        .rejects
        .toThrow("Unknown error occurred");
    });

    it("should handle errors without message", async () => {
      const errorWithoutMessage = {
        statusCode: 503,
        response: { data: { error: "Service unavailable" } },
      };
      vi.mocked(mockHttpClient.get).mockRejectedValue(errorWithoutMessage);

      await expect(getVenueSetlists(mockHttpClient, validVenueId))
        .rejects
        .toThrow("Failed to retrieve venue setlists");
    });
  });
});

describe("searchVenues", () => {
  let mockHttpClient: HttpClient;
  const mockVenues: Venues = {
    venue: [
      {
        city: {
          id: "5357527",
          name: "Hollywood",
          stateCode: "CA",
          state: "California",
          coords: {
            long: -118.3267434,
            lat: 34.0983425,
          },
          country: {
            code: "US",
            name: "United States",
          },
        },
        url: "https://www.setlist.fm/venue/compaq-center-san-jose-ca-usa-6bd6ca6e.html",
        id: "6bd6ca6e",
        name: "Compaq Center",
      },
      {
        city: {
          id: "2643743",
          name: "London",
          stateCode: "ENG",
          state: "England",
          coords: {
            long: -0.1276,
            lat: 51.5074,
          },
          country: {
            code: "GB",
            name: "United Kingdom",
          },
        },
        url: "https://www.setlist.fm/venue/wembley-stadium-london-england-def45678.html",
        id: "def45678",
        name: "Wembley Stadium",
      },
    ],
    total: 42,
    page: 1,
    itemsPerPage: 20,
  };

  beforeEach(() => {
    mockHttpClient = {
      get: vi.fn(),
    } as any;
  });

  describe("successful requests", () => {
    it("should search venues with default parameters", async () => {
      vi.mocked(mockHttpClient.get).mockResolvedValue(mockVenues);

      const result = await searchVenues(mockHttpClient);

      expect(result).toEqual(mockVenues);
      expect(mockHttpClient.get).toHaveBeenCalledWith("/search/venues", {});
    });

    it("should search venues by name", async () => {
      vi.mocked(mockHttpClient.get).mockResolvedValue(mockVenues);

      const result = await searchVenues(mockHttpClient, { name: "Madison Square Garden" });

      expect(result).toEqual(mockVenues);
      expect(mockHttpClient.get).toHaveBeenCalledWith("/search/venues", { name: "Madison Square Garden" });
    });

    it("should search venues by city name and country", async () => {
      vi.mocked(mockHttpClient.get).mockResolvedValue(mockVenues);

      const result = await searchVenues(mockHttpClient, {
        cityName: "New York",
        country: "US",
        p: 1,
      });

      expect(result).toEqual(mockVenues);
      expect(mockHttpClient.get).toHaveBeenCalledWith("/search/venues", {
        cityName: "New York",
        country: "US",
        p: 1,
      });
    });

    it("should search venues by state and state code", async () => {
      vi.mocked(mockHttpClient.get).mockResolvedValue(mockVenues);

      const result = await searchVenues(mockHttpClient, {
        state: "California",
        stateCode: "CA",
        p: 2,
      });

      expect(result).toEqual(mockVenues);
      expect(mockHttpClient.get).toHaveBeenCalledWith("/search/venues", {
        state: "California",
        stateCode: "CA",
        p: 2,
      });
    });

    it("should search venues by city geoId", async () => {
      vi.mocked(mockHttpClient.get).mockResolvedValue(mockVenues);

      const result = await searchVenues(mockHttpClient, { cityId: "5128581" });

      expect(result).toEqual(mockVenues);
      expect(mockHttpClient.get).toHaveBeenCalledWith("/search/venues", { cityId: "5128581" });
    });

    it("should handle empty search results", async () => {
      const emptyResults: Venues = {
        venue: [],
        total: 0,
        page: 1,
        itemsPerPage: 20,
      };

      vi.mocked(mockHttpClient.get).mockResolvedValue(emptyResults);

      const result = await searchVenues(mockHttpClient, { name: "Nonexistent Venue" });

      expect(result).toEqual(emptyResults);
      expect(result.venue).toHaveLength(0);
      expect(result.total).toBe(0);
    });

    it("should handle venues without cities", async () => {
      const venuesWithoutCities: Venues = {
        venue: [
          {
            url: "https://www.setlist.fm/venue/unknown-venue-abc12345.html",
            id: "abc12345",
            name: "Unknown Venue",
          },
          {
            url: "https://www.setlist.fm/venue/mystery-venue-xyz98765.html",
            id: "xyz98765",
            name: "Mystery Venue",
          },
        ],
        total: 2,
        page: 1,
        itemsPerPage: 20,
      };

      vi.mocked(mockHttpClient.get).mockResolvedValue(venuesWithoutCities);

      const result = await searchVenues(mockHttpClient, { name: "Unknown" });

      expect(result).toEqual(venuesWithoutCities);
      expect(result.venue[0].city).toBeUndefined();
      expect(result.venue[1].city).toBeUndefined();
    });

    it("should handle mixed search parameters", async () => {
      vi.mocked(mockHttpClient.get).mockResolvedValue(mockVenues);

      const result = await searchVenues(mockHttpClient, {
        name: "Garden",
        cityName: "Boston",
        country: "US",
        state: "Massachusetts",
        stateCode: "MA",
        cityId: "4930956",
        p: 3,
      });

      expect(result).toEqual(mockVenues);
      expect(mockHttpClient.get).toHaveBeenCalledWith("/search/venues", {
        name: "Garden",
        cityName: "Boston",
        country: "US",
        state: "Massachusetts",
        stateCode: "MA",
        cityId: "4930956",
        p: 3,
      });
    });

    it("should handle large page numbers", async () => {
      vi.mocked(mockHttpClient.get).mockResolvedValue(mockVenues);

      const result = await searchVenues(mockHttpClient, { name: "Arena", p: 999 });

      expect(result).toEqual(mockVenues);
      expect(mockHttpClient.get).toHaveBeenCalledWith("/search/venues", { name: "Arena", p: 999 });
    });
  });

  describe("validation errors", () => {
    it("should throw ValidationError for invalid country code", async () => {
      const invalidParams = [
        { country: "USA" }, // 3 characters
        { country: "U" }, // 1 character
        { country: "us" }, // Lowercase
        { country: "U$" }, // Special character
        { country: "12" }, // Numbers
      ];

      for (const params of invalidParams) {
        await expect(searchVenues(mockHttpClient, params))
          .rejects
          .toThrow(ValidationError);
      }
    });

    it("should throw ValidationError for invalid cityId", async () => {
      const invalidParams = [
        { cityId: "" }, // Empty string
        { cityId: "abc" }, // Non-numeric
        { cityId: "123abc" }, // Mixed alphanumeric
        { cityId: "12.34" }, // Decimal
        { cityId: "-123" }, // Negative
      ];

      for (const params of invalidParams) {
        await expect(searchVenues(mockHttpClient, params))
          .rejects
          .toThrow(ValidationError);
      }
    });

    it("should throw ValidationError for empty string parameters", async () => {
      const invalidParams = [
        { name: "" },
        { cityName: "" },
        { state: "" },
        { stateCode: "" },
      ];

      for (const params of invalidParams) {
        await expect(searchVenues(mockHttpClient, params))
          .rejects
          .toThrow(ValidationError);
      }
    });

    it("should throw ValidationError for invalid pagination", async () => {
      const invalidParams = [
        { p: 0 }, // Page number too low
        { p: -1 }, // Negative page number
        { p: 1.5 }, // Non-integer
        { p: "2" as any }, // String instead of number
      ];

      for (const params of invalidParams) {
        await expect(searchVenues(mockHttpClient, params))
          .rejects
          .toThrow(ValidationError);
      }
    });

    it("should accept valid country codes", async () => {
      vi.mocked(mockHttpClient.get).mockResolvedValue(mockVenues);

      const validCountryCodes = ["US", "GB", "DE", "FR", "JP", "AU", "CA", "IT", "ES", "NL"];

      for (const country of validCountryCodes) {
        vi.mocked(mockHttpClient.get).mockClear();

        const result = await searchVenues(mockHttpClient, { country });

        expect(result).toEqual(mockVenues);
        expect(mockHttpClient.get).toHaveBeenCalledWith("/search/venues", { country });
      }
    });

    it("should accept valid cityIds", async () => {
      vi.mocked(mockHttpClient.get).mockResolvedValue(mockVenues);

      const validCityIds = ["5128581", "2643743", "1", "123456789", "0"];

      for (const cityId of validCityIds) {
        vi.mocked(mockHttpClient.get).mockClear();

        const result = await searchVenues(mockHttpClient, { cityId });

        expect(result).toEqual(mockVenues);
        expect(mockHttpClient.get).toHaveBeenCalledWith("/search/venues", { cityId });
      }
    });

    it("should accept valid string parameters", async () => {
      vi.mocked(mockHttpClient.get).mockResolvedValue(mockVenues);

      const validParams = [
        { name: "Madison Square Garden" },
        { cityName: "New York City" },
        { state: "California" },
        { stateCode: "CA" },
        { name: "Arena", cityName: "Los Angeles" },
      ];

      for (const params of validParams) {
        vi.mocked(mockHttpClient.get).mockClear();

        const result = await searchVenues(mockHttpClient, params);

        expect(result).toEqual(mockVenues);
        expect(mockHttpClient.get).toHaveBeenCalledWith("/search/venues", params);
      }
    });

    it("should accept valid pagination parameters", async () => {
      vi.mocked(mockHttpClient.get).mockResolvedValue(mockVenues);

      const validPagination = [1, 2, 10, 50, 100, 999];

      for (const p of validPagination) {
        vi.mocked(mockHttpClient.get).mockClear();

        const result = await searchVenues(mockHttpClient, { p });

        expect(result).toEqual(mockVenues);
        expect(mockHttpClient.get).toHaveBeenCalledWith("/search/venues", { p });
      }
    });
  });

  describe("API errors", () => {
    it("should throw NotFoundError when no venues match", async () => {
      const notFoundError = new NotFoundError("No venues found", "/search/venues");
      vi.mocked(mockHttpClient.get).mockRejectedValue(notFoundError);

      await expect(searchVenues(mockHttpClient, { name: "Nonexistent Venue" }))
        .rejects
        .toThrow(NotFoundError);
    });

    it("should throw AuthenticationError for invalid API key", async () => {
      const authError = new AuthenticationError("Invalid API key");
      vi.mocked(mockHttpClient.get).mockRejectedValue(authError);

      await expect(searchVenues(mockHttpClient, { name: "Arena" }))
        .rejects
        .toThrow(AuthenticationError);
    });

    it("should throw SetlistFMAPIError for rate limiting", async () => {
      const apiError = new SetlistFMAPIError("Rate limit exceeded", 429);
      vi.mocked(mockHttpClient.get).mockRejectedValue(apiError);

      await expect(searchVenues(mockHttpClient, { name: "Stadium" }))
        .rejects
        .toThrow(SetlistFMAPIError);
    });

    it("should handle generic HTTP errors", async () => {
      const genericError = {
        statusCode: 500,
        message: "Internal Server Error",
        response: { data: { error: "Server error" } },
      };
      vi.mocked(mockHttpClient.get).mockRejectedValue(genericError);

      await expect(searchVenues(mockHttpClient, { name: "Test" }))
        .rejects
        .toThrow("Internal Server Error");
    });

    it("should handle network errors", async () => {
      const networkError = {
        message: "Network timeout",
      };
      vi.mocked(mockHttpClient.get).mockRejectedValue(networkError);

      await expect(searchVenues(mockHttpClient, { name: "Test" }))
        .rejects
        .toThrow("Network timeout");
    });

    it("should handle errors without status code", async () => {
      const unknownError = {
        message: "Unknown error occurred",
      };
      vi.mocked(mockHttpClient.get).mockRejectedValue(unknownError);

      await expect(searchVenues(mockHttpClient, { name: "Test" }))
        .rejects
        .toThrow("Unknown error occurred");
    });

    it("should handle errors without message", async () => {
      const errorWithoutMessage = {
        statusCode: 503,
        response: { data: { error: "Service unavailable" } },
      };
      vi.mocked(mockHttpClient.get).mockRejectedValue(errorWithoutMessage);

      await expect(searchVenues(mockHttpClient, { name: "Test" }))
        .rejects
        .toThrow("Failed to search venues");
    });
  });
});

describe("validation schemas", () => {
  describe("VenueIdParamSchema", () => {
    it("should validate correct venue IDs", async () => {
      const { VenueIdParamSchema } = await import("./validation.js");

      const validIds = ["6bd6ca6e", "12345678", "abcdef01", "00000000", "ffffffff"];

      for (const id of validIds) {
        expect(() => VenueIdParamSchema.parse(id)).not.toThrow();
      }
    });

    it("should reject invalid venue IDs", async () => {
      const { VenueIdParamSchema } = await import("./validation.js");

      const invalidIds = [
        "", // Empty
        "6bd6ca6", // Too short
        "6bd6ca6ee", // Too long
        "6BD6CA6E", // Uppercase
        "6gd6ca6e", // Invalid character
        "6bd-ca6e", // Contains hyphen
      ];

      for (const id of invalidIds) {
        expect(() => VenueIdParamSchema.parse(id)).toThrow();
      }
    });
  });

  describe("SearchVenuesParamsSchema", () => {
    it("should validate valid search parameters", async () => {
      const { SearchVenuesParamsSchema } = await import("./validation.js");

      const validParams = [
        { name: "Madison Square Garden" },
        { cityName: "New York", country: "US" },
        { state: "California", stateCode: "CA" },
        { cityId: "5128581", p: 1 },
        { country: "GB", name: "Wembley", p: 2 },
        {}, // Empty object should be valid
      ];

      for (const params of validParams) {
        expect(() => SearchVenuesParamsSchema.parse(params)).not.toThrow();
      }
    });

    it("should reject invalid search parameters", async () => {
      const { SearchVenuesParamsSchema } = await import("./validation.js");

      const invalidParams = [
        { country: "USA" }, // Invalid country code (3 letters)
        { country: "u" }, // Invalid country code (1 letter)
        { country: "us" }, // Invalid country code (lowercase)
        { cityId: "abc" }, // Non-numeric cityId
        { cityId: "" }, // Empty cityId
        { name: "" }, // Empty name
        { p: 0 }, // Invalid page number
        { p: -1 }, // Negative page number
      ];

      for (const params of invalidParams) {
        expect(() => SearchVenuesParamsSchema.parse(params)).toThrow();
      }
    });
  });

  describe("GetVenueSetlistsParamsSchema", () => {
    it("should validate pagination parameters", async () => {
      const { GetVenueSetlistsParamsSchema } = await import("./validation.js");

      const validParams = [
        { p: 1 },
        { p: 10 },
        {}, // Empty object should be valid
      ];

      for (const params of validParams) {
        expect(() => GetVenueSetlistsParamsSchema.parse(params)).not.toThrow();
      }
    });

    it("should reject invalid pagination parameters", async () => {
      const { GetVenueSetlistsParamsSchema } = await import("./validation.js");

      const invalidParams = [
        { p: 0 },
        { p: -1 },
        { p: 1.5 },
        { p: "1" },
      ];

      for (const params of invalidParams) {
        expect(() => GetVenueSetlistsParamsSchema.parse(params)).toThrow();
      }
    });
  });

  describe("VenueSchema", () => {
    it("should validate complete venue objects", async () => {
      const { VenueSchema } = await import("./validation.js");

      const validVenues = [
        {
          city: {
            id: "5357527",
            name: "Hollywood",
            stateCode: "CA",
            state: "California",
            coords: { long: -118.3267434, lat: 34.0983425 },
            country: { code: "US", name: "United States" },
          },
          url: "https://www.setlist.fm/venue/compaq-center-6bd6ca6e.html",
          id: "6bd6ca6e",
          name: "Compaq Center",
        },
        {
          url: "https://www.setlist.fm/venue/unknown-venue-abc12345.html",
          id: "abc12345",
          name: "Unknown Venue",
          // city is optional
        },
      ];

      for (const venue of validVenues) {
        expect(() => VenueSchema.parse(venue)).not.toThrow();
      }
    });

    it("should reject invalid venue objects", async () => {
      const { VenueSchema } = await import("./validation.js");

      const invalidVenues = [
        { url: "invalid-url", id: "6bd6ca6e", name: "Test" }, // Invalid URL
        { url: "https://example.com", id: "", name: "Test" }, // Empty ID
        { url: "https://example.com", id: "6bd6ca6e", name: "" }, // Empty name
        { id: "6bd6ca6e", name: "Test" }, // Missing URL
        { url: "https://example.com", name: "Test" }, // Missing ID
        { url: "https://example.com", id: "6bd6ca6e" }, // Missing name
      ];

      for (const venue of invalidVenues) {
        expect(() => VenueSchema.parse(venue)).toThrow();
      }
    });
  });

  describe("VenuesSchema", () => {
    it("should validate venues collection response", async () => {
      const { VenuesSchema } = await import("./validation.js");

      const validResponse = {
        venue: [
          {
            city: {
              id: "5357527",
              name: "Hollywood",
              stateCode: "CA",
              state: "California",
              coords: { long: -118.3267434, lat: 34.0983425 },
              country: { code: "US", name: "United States" },
            },
            url: "https://www.setlist.fm/venue/compaq-center-6bd6ca6e.html",
            id: "6bd6ca6e",
            name: "Compaq Center",
          },
        ],
        total: 42,
        page: 1,
        itemsPerPage: 20,
      };

      expect(() => VenuesSchema.parse(validResponse)).not.toThrow();
    });

    it("should reject invalid venues collection responses", async () => {
      const { VenuesSchema } = await import("./validation.js");

      const invalidResponses = [
        { venue: [], total: -1, page: 1, itemsPerPage: 20 }, // Negative total
        { venue: [], total: 0, page: 0, itemsPerPage: 20 }, // Invalid page
        { venue: [], total: 0, page: 1, itemsPerPage: 0 }, // Invalid itemsPerPage
        { total: 0, page: 1, itemsPerPage: 20 }, // Missing venue array
        { venue: [], page: 1, itemsPerPage: 20 }, // Missing total
        { venue: [], total: 0, itemsPerPage: 20 }, // Missing page
        { venue: [], total: 0, page: 1 }, // Missing itemsPerPage
      ];

      for (const response of invalidResponses) {
        expect(() => VenuesSchema.parse(response)).toThrow();
      }
    });
  });
});
