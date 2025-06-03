/**
 * @file setlists.test.ts
 * @description Test suite for setlists endpoint functionality.
 * @author tkozzer
 * @module Setlists
 */

import type { HttpClient } from "@utils/http";

import type { Setlist, Setlists } from "./types";

import { AuthenticationError, NotFoundError, SetlistFMAPIError, ValidationError } from "@shared/error";

import { beforeEach, describe, expect, it, vi } from "vitest";
import { getSetlist } from "./getSetlist";
import { searchSetlists } from "./searchSetlists";
import {
  GetSetlistParamsSchema,
  SearchSetlistsParamsSchema,
  SetlistIdSchema,
  SetlistSchema,
  SetlistsSchema,
  VersionIdSchema,
} from "./validation";

describe("setlists validation schemas", () => {
  describe("SetlistIdSchema", () => {
    it("validates correct setlist ID format", () => {
      const validId = "63de4613";
      expect(() => SetlistIdSchema.parse(validId)).not.toThrow();
    });

    it("rejects invalid setlist ID format", () => {
      expect(() => SetlistIdSchema.parse("invalid")).toThrow();
      expect(() => SetlistIdSchema.parse("63de46")).toThrow(); // too short (6 chars)
      expect(() => SetlistIdSchema.parse("63de46133")).toThrow(); // too long (9 chars)
      expect(() => SetlistIdSchema.parse("63de461G")).toThrow(); // invalid character
    });
  });

  describe("VersionIdSchema", () => {
    it("validates correct version ID format", () => {
      const validVersionId = "7be1aaa0";
      expect(() => VersionIdSchema.parse(validVersionId)).not.toThrow();
    });

    it("rejects invalid version ID format", () => {
      expect(() => VersionIdSchema.parse("")).toThrow(); // empty string
      expect(() => VersionIdSchema.parse("7be1aa")).toThrow(); // too short (6 chars)
      expect(() => VersionIdSchema.parse("7be1aaa012345")).toThrow(); // too long (13 chars)
      expect(() => VersionIdSchema.parse("abc")).toThrow(); // too short (3 chars)
    });
  });

  describe("SearchSetlistsParamsSchema", () => {
    it("validates search parameters with artist name", () => {
      const params = { artistName: "The Beatles" };
      expect(() => SearchSetlistsParamsSchema.parse(params)).not.toThrow();
    });

    it("validates search parameters with multiple filters", () => {
      const params = {
        artistName: "The Beatles",
        cityName: "Hollywood",
        year: 1964,
        p: 1,
      };
      expect(() => SearchSetlistsParamsSchema.parse(params)).not.toThrow();
    });

    it("validates search parameters with date filter", () => {
      const params = {
        artistName: "The Beatles",
        date: "23-08-1964",
      };
      expect(() => SearchSetlistsParamsSchema.parse(params)).not.toThrow();
    });

    it("rejects invalid date format", () => {
      const params = {
        artistName: "The Beatles",
        date: "1964-08-23", // wrong format, should be dd-MM-yyyy
      };
      expect(() => SearchSetlistsParamsSchema.parse(params)).toThrow();
    });

    it("rejects invalid year", () => {
      const params = {
        artistName: "The Beatles",
        year: 1800, // too early
      };
      expect(() => SearchSetlistsParamsSchema.parse(params)).toThrow();
    });

    it("rejects empty search parameters", () => {
      const params = {};
      expect(() => SearchSetlistsParamsSchema.parse(params)).toThrow();
    });
  });

  describe("GetSetlistParamsSchema", () => {
    it("validates correct setlist ID parameter", () => {
      const params = { setlistId: "63de4613" };
      expect(() => GetSetlistParamsSchema.parse(params)).not.toThrow();
    });

    it("rejects invalid setlist ID parameter", () => {
      const params = { setlistId: "invalid" };
      expect(() => GetSetlistParamsSchema.parse(params)).toThrow();
    });
  });
});

describe("setlists response schemas", () => {
  describe("SetlistSchema", () => {
    const validSetlist = {
      artist: {
        mbid: "b10bbbfc-cf9e-42e0-be17-e2c3e1d2600d",
        name: "The Beatles",
        sortName: "Beatles, The",
        disambiguation: "John, Paul, George and Ringo",
        url: "https://www.setlist.fm/setlists/the-beatles-23d6a88b.html",
      },
      venue: {
        city: {
          id: "5357527",
          name: "Hollywood",
          stateCode: "CA",
          state: "California",
          coords: { lat: 34.0928, long: -118.3287 },
          country: { code: "US", name: "United States" },
        },
        url: "https://www.setlist.fm/venue/compaq-center-san-jose-ca-usa-6bd6ca6e.html",
        id: "6bd6ca6e",
        name: "Compaq Center",
      },
      tour: {
        name: "North American Tour 1964",
      },
      sets: {
        set: [
          {
            name: "Set 1",
            song: [
              {
                name: "Yesterday",
                tape: false,
              },
            ],
          },
        ],
      },
      info: "Recorded and published as 'The Beatles at the Hollywood Bowl'",
      url: "https://www.setlist.fm/setlist/the-beatles/1964/hollywood-bowl-hollywood-ca-63de4613.html",
      id: "63de4613",
      versionId: "7be1aaa0",
      eventDate: "23-08-1964",
      lastUpdated: "2013-10-20T05:18:08.000+0000",
    };

    it("validates a complete setlist object", () => {
      expect(() => SetlistSchema.parse(validSetlist)).not.toThrow();
    });

    it("validates setlist without optional fields", () => {
      const minimalSetlist = {
        ...validSetlist,
        tour: undefined,
        info: undefined,
      };
      expect(() => SetlistSchema.parse(minimalSetlist)).not.toThrow();
    });
  });

  describe("SetlistsSchema", () => {
    it("validates paginated setlists response", () => {
      const setlistsResponse = {
        setlist: [],
        total: 42,
        page: 1,
        itemsPerPage: 20,
      };
      expect(() => SetlistsSchema.parse(setlistsResponse)).not.toThrow();
    });

    it("rejects invalid pagination values", () => {
      const invalidResponse = {
        setlist: [],
        total: -1, // negative total
        page: 0, // page starts at 1
        itemsPerPage: 0, // must be at least 1
      };
      expect(() => SetlistsSchema.parse(invalidResponse)).toThrow();
    });
  });
});

// Test index.ts exports
describe("index exports", () => {
  it("should export all setlists functions and types", async () => {
    const indexModule = await import("./index.js");

    // Test function exports
    expect(typeof indexModule.getSetlist).toBe("function");
    expect(typeof indexModule.searchSetlists).toBe("function");

    // Test validation schema exports
    expect(indexModule.SetlistIdSchema).toBeDefined();
    expect(indexModule.VersionIdSchema).toBeDefined();
    expect(indexModule.SetlistDateSchema).toBeDefined();
    expect(indexModule.LastUpdatedSchema).toBeDefined();
    expect(indexModule.TourSchema).toBeDefined();
    expect(indexModule.SongSchema).toBeDefined();
    expect(indexModule.SetSchema).toBeDefined();
    expect(indexModule.SetlistSchema).toBeDefined();
    expect(indexModule.SetlistsSchema).toBeDefined();
    expect(indexModule.SearchSetlistsParamsSchema).toBeDefined();
    expect(indexModule.GetSetlistParamsSchema).toBeDefined();
  });
});

describe("getSetlist", () => {
  let mockHttpClient: HttpClient;
  const validSetlistId = "63de4613";
  const mockSetlist: Setlist = {
    artist: {
      mbid: "b10bbbfc-cf9e-42e0-be17-e2c3e1d2600d",
      name: "The Beatles",
      sortName: "Beatles, The",
      disambiguation: "John, Paul, George and Ringo",
      url: "https://www.setlist.fm/setlists/the-beatles-23d6a88b.html",
    },
    venue: {
      city: {
        id: "5357527",
        name: "Hollywood",
        stateCode: "CA",
        state: "California",
        coords: { lat: 34.0928, long: -118.3287 },
        country: { code: "US", name: "United States" },
      },
      url: "https://www.setlist.fm/venue/compaq-center-san-jose-ca-usa-6bd6ca6e.html",
      id: "6bd6ca6e",
      name: "Compaq Center",
    },
    tour: {
      name: "North American Tour 1964",
    },
    sets: {
      set: [
        {
          name: "Set 1",
          song: [
            {
              name: "Yesterday",
              tape: false,
            },
            {
              name: "Hey Jude",
              tape: false,
              info: "Extended version",
            },
          ],
        },
        {
          name: "Encore",
          encore: 1,
          song: [
            {
              name: "Let It Be",
              tape: false,
            },
          ],
        },
      ],
    },
    info: "Recorded and published as 'The Beatles at the Hollywood Bowl'",
    url: "https://www.setlist.fm/setlist/the-beatles/1964/hollywood-bowl-hollywood-ca-63de4613.html",
    id: "63de4613",
    versionId: "7be1aaa0",
    eventDate: "23-08-1964",
    lastUpdated: "2013-10-20T05:18:08.000+0000",
  };

  beforeEach(() => {
    mockHttpClient = {
      get: vi.fn(),
    } as any;
  });

  describe("successful requests", () => {
    it("should return setlist data for valid setlist ID", async () => {
      vi.mocked(mockHttpClient.get).mockResolvedValue(mockSetlist);

      const result = await getSetlist(mockHttpClient, validSetlistId);

      expect(result).toEqual(mockSetlist);
      expect(mockHttpClient.get).toHaveBeenCalledWith(`/setlist/${validSetlistId}`);
    });

    it("should handle setlist with minimal data", async () => {
      const minimalSetlist: Setlist = {
        artist: {
          mbid: "b10bbbfc-cf9e-42e0-be17-e2c3e1d2600d",
          name: "Test Artist",
          sortName: "Artist, Test",
        },
        venue: {
          id: "6bd6ca6e",
          name: "Test Venue",
          url: "https://www.setlist.fm/venue/test-venue.html",
        },
        sets: {
          set: [
            {
              song: [
                {
                  name: "Test Song",
                  tape: false,
                },
              ],
            },
          ],
        },
        url: "https://www.setlist.fm/setlist/test.html",
        id: validSetlistId,
        versionId: "7be1aaa0",
        eventDate: "01-01-2024",
        lastUpdated: "2024-01-01T00:00:00.000+0000",
      };

      vi.mocked(mockHttpClient.get).mockResolvedValue(minimalSetlist);

      const result = await getSetlist(mockHttpClient, validSetlistId);

      expect(result).toEqual(minimalSetlist);
      expect(result.tour).toBeUndefined();
      expect(result.info).toBeUndefined();
    });

    it("should handle setlist with song featuring guest artist", async () => {
      const setlistWithGuest: Setlist = {
        ...mockSetlist,
        sets: {
          set: [
            {
              song: [
                {
                  name: "Yesterday",
                  tape: false,
                  with: {
                    mbid: "a74b1b7f-71a5-4011-9441-d0b5e4122711",
                    name: "Guest Artist",
                    sortName: "Artist, Guest",
                  },
                },
              ],
            },
          ],
        },
      };

      vi.mocked(mockHttpClient.get).mockResolvedValue(setlistWithGuest);

      const result = await getSetlist(mockHttpClient, validSetlistId);

      expect(result.sets.set[0].song[0].with).toEqual({
        mbid: "a74b1b7f-71a5-4011-9441-d0b5e4122711",
        name: "Guest Artist",
        sortName: "Artist, Guest",
      });
    });

    it("should handle setlist with cover songs", async () => {
      const setlistWithCover: Setlist = {
        ...mockSetlist,
        sets: {
          set: [
            {
              song: [
                {
                  name: "Twist and Shout",
                  tape: false,
                  cover: {
                    mbid: "1f0e3dad-99cb-40d6-b755-72ba85c6a56b",
                    name: "The Isley Brothers",
                    sortName: "Isley Brothers, The",
                  },
                },
              ],
            },
          ],
        },
      };

      vi.mocked(mockHttpClient.get).mockResolvedValue(setlistWithCover);

      const result = await getSetlist(mockHttpClient, validSetlistId);

      expect(result.sets.set[0].song[0].cover).toEqual({
        mbid: "1f0e3dad-99cb-40d6-b755-72ba85c6a56b",
        name: "The Isley Brothers",
        sortName: "Isley Brothers, The",
      });
    });

    it("should handle setlist with tape songs", async () => {
      const setlistWithTape: Setlist = {
        ...mockSetlist,
        sets: {
          set: [
            {
              song: [
                {
                  name: "Recorded Intro",
                  tape: true,
                },
              ],
            },
          ],
        },
      };

      vi.mocked(mockHttpClient.get).mockResolvedValue(setlistWithTape);

      const result = await getSetlist(mockHttpClient, validSetlistId);

      expect(result.sets.set[0].song[0].tape).toBe(true);
    });
  });

  describe("validation errors", () => {
    it("should throw ValidationError for missing setlist ID", async () => {
      await expect(getSetlist(mockHttpClient, ""))
        .rejects
        .toThrow(ValidationError);

      await expect(getSetlist(mockHttpClient, ""))
        .rejects
        .toThrow("Invalid setlist ID parameter: Setlist ID is required");
    });

    it("should throw ValidationError for null setlist ID", async () => {
      await expect(getSetlist(mockHttpClient, null as any))
        .rejects
        .toThrow(ValidationError);
    });

    it("should throw ValidationError for invalid setlist ID format", async () => {
      const invalidSetlistIds = [
        "invalid-id",
        "1234567890",
        "63de46", // too short (6 chars)
        "63de46133", // too long (9 chars)
        "63de461G", // invalid character (G)
        "XXXXXXXX", // invalid characters
        "63DE4613", // uppercase (should be lowercase hex)
      ];

      for (const invalidId of invalidSetlistIds) {
        await expect(getSetlist(mockHttpClient, invalidId))
          .rejects
          .toThrow(ValidationError);

        await expect(getSetlist(mockHttpClient, invalidId))
          .rejects
          .toThrow("Invalid setlist ID parameter: Setlist ID must be a 7-8 character hexadecimal string");
      }
    });

    it("should throw ValidationError for invalid response data", async () => {
      const invalidResponse = {
        // missing required fields
        id: validSetlistId,
      };

      vi.mocked(mockHttpClient.get).mockResolvedValue(invalidResponse);

      await expect(getSetlist(mockHttpClient, validSetlistId))
        .rejects
        .toThrow(ValidationError);

      await expect(getSetlist(mockHttpClient, validSetlistId))
        .rejects
        .toThrow("Invalid setlist response");
    });
  });

  describe("HTTP errors", () => {
    it("should handle 404 Not Found error", async () => {
      const notFoundError = new NotFoundError("setlist", validSetlistId);
      vi.mocked(mockHttpClient.get).mockRejectedValue(notFoundError);

      await expect(getSetlist(mockHttpClient, validSetlistId))
        .rejects
        .toThrow(NotFoundError);
    });

    it("should handle 401 Authentication error", async () => {
      const authError = new AuthenticationError("Invalid API key");
      vi.mocked(mockHttpClient.get).mockRejectedValue(authError);

      await expect(getSetlist(mockHttpClient, validSetlistId))
        .rejects
        .toThrow(AuthenticationError);
    });

    it("should handle SetlistFM API errors", async () => {
      const apiError = new SetlistFMAPIError("API rate limit exceeded", 429);
      vi.mocked(mockHttpClient.get).mockRejectedValue(apiError);

      await expect(getSetlist(mockHttpClient, validSetlistId))
        .rejects
        .toThrow(SetlistFMAPIError);
    });

    it("should handle unexpected errors", async () => {
      const unexpectedError = new Error("Network error");
      vi.mocked(mockHttpClient.get).mockRejectedValue(unexpectedError);

      await expect(getSetlist(mockHttpClient, validSetlistId))
        .rejects
        .toThrow("Network error");
    });

    it("should handle errors with status codes", async () => {
      const errorWithStatus = {
        statusCode: 500,
        message: "Internal server error",
        response: { error: "Server failure" },
      };
      vi.mocked(mockHttpClient.get).mockRejectedValue(errorWithStatus);

      await expect(getSetlist(mockHttpClient, validSetlistId))
        .rejects
        .toThrow("Internal server error");
    });

    it("should handle errors without status code (fallback to 500)", async () => {
      const errorWithoutStatus = {
        message: "Connection failed",
        response: { error: "Network failure" },
      };
      vi.mocked(mockHttpClient.get).mockRejectedValue(errorWithoutStatus);

      await expect(getSetlist(mockHttpClient, validSetlistId))
        .rejects
        .toThrow("Connection failed");
    });

    it("should handle errors without message (fallback to default)", async () => {
      const errorWithoutMessage = {
        statusCode: 503,
        response: { error: "Service unavailable" },
      };
      vi.mocked(mockHttpClient.get).mockRejectedValue(errorWithoutMessage);

      await expect(getSetlist(mockHttpClient, validSetlistId))
        .rejects
        .toThrow("Failed to retrieve setlist");
    });

    it("should handle errors without status code or message", async () => {
      const minimalError = {
        response: { error: "Unknown error" },
      };
      vi.mocked(mockHttpClient.get).mockRejectedValue(minimalError);

      await expect(getSetlist(mockHttpClient, validSetlistId))
        .rejects
        .toThrow("Failed to retrieve setlist");
    });

    it("should re-throw known SetlistFM errors by name", async () => {
      const customError = new Error("Custom error");
      customError.name = "SetlistFMCustomError";
      vi.mocked(mockHttpClient.get).mockRejectedValue(customError);

      await expect(getSetlist(mockHttpClient, validSetlistId))
        .rejects
        .toThrow("Custom error");
    });

    it("should re-throw errors with 'Error' in the name", async () => {
      const customError = new Error("Custom error");
      customError.name = "CustomError";
      vi.mocked(mockHttpClient.get).mockRejectedValue(customError);

      await expect(getSetlist(mockHttpClient, validSetlistId))
        .rejects
        .toThrow("Custom error");
    });
  });
});

describe("searchSetlists", () => {
  let mockHttpClient: HttpClient;
  const mockSetlistsResponse: Setlists = {
    setlist: [
      {
        artist: {
          mbid: "b10bbbfc-cf9e-42e0-be17-e2c3e1d2600d",
          name: "The Beatles",
          sortName: "Beatles, The",
          disambiguation: "John, Paul, George and Ringo",
          url: "https://www.setlist.fm/setlists/the-beatles-23d6a88b.html",
        },
        venue: {
          city: {
            id: "5357527",
            name: "Hollywood",
            stateCode: "CA",
            state: "California",
            coords: { lat: 34.0928, long: -118.3287 },
            country: { code: "US", name: "United States" },
          },
          url: "https://www.setlist.fm/venue/compaq-center-san-jose-ca-usa-6bd6ca6e.html",
          id: "6bd6ca6e",
          name: "Compaq Center",
        },
        tour: {
          name: "North American Tour 1964",
        },
        sets: {
          set: [
            {
              name: "Set 1",
              song: [
                {
                  name: "Yesterday",
                  tape: false,
                },
              ],
            },
          ],
        },
        info: "Recorded and published as 'The Beatles at the Hollywood Bowl'",
        url: "https://www.setlist.fm/setlist/the-beatles/1964/hollywood-bowl-hollywood-ca-63de4613.html",
        id: "63de4613",
        versionId: "7be1aaa0",
        eventDate: "23-08-1964",
        lastUpdated: "2013-10-20T05:18:08.000+0000",
      },
    ],
    total: 1,
    page: 1,
    itemsPerPage: 20,
  };

  beforeEach(() => {
    mockHttpClient = {
      get: vi.fn(),
    } as any;
  });

  describe("successful requests", () => {
    it("should search setlists by artist name", async () => {
      vi.mocked(mockHttpClient.get).mockResolvedValue(mockSetlistsResponse);

      const result = await searchSetlists(mockHttpClient, { artistName: "The Beatles" });

      expect(result).toEqual(mockSetlistsResponse);
      expect(mockHttpClient.get).toHaveBeenCalledWith("/search/setlists", { artistName: "The Beatles" });
    });

    it("should search setlists by artist MBID", async () => {
      const params = { artistMbid: "b10bbbfc-cf9e-42e0-be17-e2c3e1d2600d" };
      vi.mocked(mockHttpClient.get).mockResolvedValue(mockSetlistsResponse);

      const result = await searchSetlists(mockHttpClient, params);

      expect(result).toEqual(mockSetlistsResponse);
      expect(mockHttpClient.get).toHaveBeenCalledWith("/search/setlists", params);
    });

    it("should search setlists with multiple criteria", async () => {
      const params = {
        artistName: "The Beatles",
        cityName: "Hollywood",
        year: 1964,
        venueName: "Hollywood Bowl",
      };
      vi.mocked(mockHttpClient.get).mockResolvedValue(mockSetlistsResponse);

      const result = await searchSetlists(mockHttpClient, params);

      expect(result).toEqual(mockSetlistsResponse);
      expect(mockHttpClient.get).toHaveBeenCalledWith("/search/setlists", params);
    });

    it("should search setlists by date", async () => {
      const params = {
        artistName: "The Beatles",
        date: "23-08-1964",
      };
      vi.mocked(mockHttpClient.get).mockResolvedValue(mockSetlistsResponse);

      const result = await searchSetlists(mockHttpClient, params);

      expect(result).toEqual(mockSetlistsResponse);
      expect(mockHttpClient.get).toHaveBeenCalledWith("/search/setlists", params);
    });

    it("should search setlists with pagination", async () => {
      const params = {
        artistName: "The Beatles",
        p: 2,
      };
      vi.mocked(mockHttpClient.get).mockResolvedValue({
        ...mockSetlistsResponse,
        page: 2,
      });

      const result = await searchSetlists(mockHttpClient, params);

      expect(result.page).toBe(2);
      expect(mockHttpClient.get).toHaveBeenCalledWith("/search/setlists", params);
    });

    it("should search setlists by venue ID", async () => {
      const params = { venueId: "6bd6ca6e" };
      vi.mocked(mockHttpClient.get).mockResolvedValue(mockSetlistsResponse);

      const result = await searchSetlists(mockHttpClient, params);

      expect(result).toEqual(mockSetlistsResponse);
      expect(mockHttpClient.get).toHaveBeenCalledWith("/search/setlists", params);
    });

    it("should search setlists by country and state", async () => {
      const params = {
        countryCode: "US",
        stateCode: "CA",
        artistName: "The Beatles",
      };
      vi.mocked(mockHttpClient.get).mockResolvedValue(mockSetlistsResponse);

      const result = await searchSetlists(mockHttpClient, params);

      expect(result).toEqual(mockSetlistsResponse);
      expect(mockHttpClient.get).toHaveBeenCalledWith("/search/setlists", params);
    });

    it("should search setlists by tour name", async () => {
      const params = {
        tourName: "North American Tour 1964",
        artistName: "The Beatles",
      };
      vi.mocked(mockHttpClient.get).mockResolvedValue(mockSetlistsResponse);

      const result = await searchSetlists(mockHttpClient, params);

      expect(result).toEqual(mockSetlistsResponse);
      expect(mockHttpClient.get).toHaveBeenCalledWith("/search/setlists", params);
    });

    it("should search setlists by last updated", async () => {
      const params = {
        artistName: "The Beatles",
        lastUpdated: "20131020051808",
      };
      vi.mocked(mockHttpClient.get).mockResolvedValue(mockSetlistsResponse);

      const result = await searchSetlists(mockHttpClient, params);

      expect(result).toEqual(mockSetlistsResponse);
      expect(mockHttpClient.get).toHaveBeenCalledWith("/search/setlists", params);
    });

    it("should handle empty search results", async () => {
      const emptyResponse: Setlists = {
        setlist: [],
        total: 0,
        page: 1,
        itemsPerPage: 20,
      };
      vi.mocked(mockHttpClient.get).mockResolvedValue(emptyResponse);

      const result = await searchSetlists(mockHttpClient, { artistName: "Nonexistent Artist" });

      expect(result).toEqual(emptyResponse);
      expect(result.setlist).toHaveLength(0);
      expect(result.total).toBe(0);
    });

    it("should handle deprecated parameters (artistTmid, lastFm)", async () => {
      const params = {
        artistName: "The Beatles",
        artistTmid: 12345,
        lastFm: 67890,
      };
      vi.mocked(mockHttpClient.get).mockResolvedValue(mockSetlistsResponse);

      const result = await searchSetlists(mockHttpClient, params);

      expect(result).toEqual(mockSetlistsResponse);
      expect(mockHttpClient.get).toHaveBeenCalledWith("/search/setlists", params);
    });
  });

  describe("validation errors", () => {
    it("should throw ValidationError for empty search parameters", async () => {
      await expect(searchSetlists(mockHttpClient, {}))
        .rejects
        .toThrow(ValidationError);

      await expect(searchSetlists(mockHttpClient, {}))
        .rejects
        .toThrow("Invalid search parameters: At least one search parameter must be provided");
    });

    it("should throw ValidationError for invalid date format", async () => {
      const invalidParams = {
        artistName: "The Beatles",
        date: "1964-08-23", // wrong format, should be dd-MM-yyyy
      };

      await expect(searchSetlists(mockHttpClient, invalidParams))
        .rejects
        .toThrow(ValidationError);

      await expect(searchSetlists(mockHttpClient, invalidParams))
        .rejects
        .toThrow("Invalid search parameters: Date must be in dd-MM-yyyy format");
    });

    it("should throw ValidationError for invalid year", async () => {
      const invalidParams = {
        artistName: "The Beatles",
        year: 1800, // too early
      };

      await expect(searchSetlists(mockHttpClient, invalidParams))
        .rejects
        .toThrow(ValidationError);

      await expect(searchSetlists(mockHttpClient, invalidParams))
        .rejects
        .toThrow("Invalid search parameters: Number must be greater than or equal to 1900");
    });

    it("should throw ValidationError for future year", async () => {
      const currentYear = new Date().getFullYear();
      const futureYear = currentYear + 20;
      const invalidParams = {
        artistName: "The Beatles",
        year: futureYear,
      };

      await expect(searchSetlists(mockHttpClient, invalidParams))
        .rejects
        .toThrow(ValidationError);
    });

    it("should throw ValidationError for invalid page number", async () => {
      const invalidParams = {
        artistName: "The Beatles",
        p: 0, // page must be at least 1
      };

      await expect(searchSetlists(mockHttpClient, invalidParams))
        .rejects
        .toThrow(ValidationError);

      await expect(searchSetlists(mockHttpClient, invalidParams))
        .rejects
        .toThrow("Invalid search parameters: Page number must be greater than 0");
    });

    it("should throw ValidationError for invalid lastUpdated format", async () => {
      const invalidParams = {
        artistName: "The Beatles",
        lastUpdated: "2013-10-20", // wrong format, should be yyyyMMddHHmmss
      };

      await expect(searchSetlists(mockHttpClient, invalidParams))
        .rejects
        .toThrow(ValidationError);

      await expect(searchSetlists(mockHttpClient, invalidParams))
        .rejects
        .toThrow("Invalid search parameters: Last updated must be in yyyyMMddHHmmss format");
    });

    it("should throw ValidationError for invalid response structure", async () => {
      const invalidResponse = {
        // missing required fields
        total: 1,
      };

      vi.mocked(mockHttpClient.get).mockResolvedValue(invalidResponse);

      await expect(searchSetlists(mockHttpClient, { artistName: "The Beatles" }))
        .rejects
        .toThrow(ValidationError);

      await expect(searchSetlists(mockHttpClient, { artistName: "The Beatles" }))
        .rejects
        .toThrow("Invalid setlists search response");
    });

    it("should throw ValidationError for negative total", async () => {
      const invalidResponse = {
        setlist: [],
        total: -1, // negative total
        page: 1,
        itemsPerPage: 20,
      };

      vi.mocked(mockHttpClient.get).mockResolvedValue(invalidResponse);

      await expect(searchSetlists(mockHttpClient, { artistName: "The Beatles" }))
        .rejects
        .toThrow(ValidationError);
    });

    it("should throw ValidationError for invalid page in response", async () => {
      const invalidResponse = {
        setlist: [],
        total: 0,
        page: 0, // page must be at least 1
        itemsPerPage: 20,
      };

      vi.mocked(mockHttpClient.get).mockResolvedValue(invalidResponse);

      await expect(searchSetlists(mockHttpClient, { artistName: "The Beatles" }))
        .rejects
        .toThrow(ValidationError);
    });

    it("should throw ValidationError for invalid itemsPerPage in response", async () => {
      const invalidResponse = {
        setlist: [],
        total: 0,
        page: 1,
        itemsPerPage: 0, // must be at least 1
      };

      vi.mocked(mockHttpClient.get).mockResolvedValue(invalidResponse);

      await expect(searchSetlists(mockHttpClient, { artistName: "The Beatles" }))
        .rejects
        .toThrow(ValidationError);
    });
  });

  describe("HTTP errors", () => {
    it("should handle 404 Not Found error", async () => {
      const notFoundError = new NotFoundError("setlists", "search criteria");
      vi.mocked(mockHttpClient.get).mockRejectedValue(notFoundError);

      await expect(searchSetlists(mockHttpClient, { artistName: "Nonexistent Artist" }))
        .rejects
        .toThrow(NotFoundError);
    });

    it("should handle 401 Authentication error", async () => {
      const authError = new AuthenticationError("Invalid API key");
      vi.mocked(mockHttpClient.get).mockRejectedValue(authError);

      await expect(searchSetlists(mockHttpClient, { artistName: "The Beatles" }))
        .rejects
        .toThrow(AuthenticationError);
    });

    it("should handle SetlistFM API errors", async () => {
      const apiError = new SetlistFMAPIError("API rate limit exceeded", 429);
      vi.mocked(mockHttpClient.get).mockRejectedValue(apiError);

      await expect(searchSetlists(mockHttpClient, { artistName: "The Beatles" }))
        .rejects
        .toThrow(SetlistFMAPIError);
    });

    it("should handle unexpected errors", async () => {
      const unexpectedError = new Error("Network error");
      vi.mocked(mockHttpClient.get).mockRejectedValue(unexpectedError);

      await expect(searchSetlists(mockHttpClient, { artistName: "The Beatles" }))
        .rejects
        .toThrow("Network error");
    });

    it("should handle errors with status codes", async () => {
      const errorWithStatus = {
        statusCode: 500,
        message: "Internal server error",
        response: { error: "Server failure" },
      };
      vi.mocked(mockHttpClient.get).mockRejectedValue(errorWithStatus);

      await expect(searchSetlists(mockHttpClient, { artistName: "The Beatles" }))
        .rejects
        .toThrow("Internal server error");
    });

    it("should handle errors without status code (fallback to 500)", async () => {
      const errorWithoutStatus = {
        message: "Connection failed",
        response: { error: "Network failure" },
      };
      vi.mocked(mockHttpClient.get).mockRejectedValue(errorWithoutStatus);

      await expect(searchSetlists(mockHttpClient, { artistName: "The Beatles" }))
        .rejects
        .toThrow("Connection failed");
    });

    it("should handle errors without message (fallback to default)", async () => {
      const errorWithoutMessage = {
        statusCode: 503,
        response: { error: "Service unavailable" },
      };
      vi.mocked(mockHttpClient.get).mockRejectedValue(errorWithoutMessage);

      await expect(searchSetlists(mockHttpClient, { artistName: "The Beatles" }))
        .rejects
        .toThrow("Failed to search setlists");
    });

    it("should handle errors without status code or message", async () => {
      const minimalError = {
        response: { error: "Unknown error" },
      };
      vi.mocked(mockHttpClient.get).mockRejectedValue(minimalError);

      await expect(searchSetlists(mockHttpClient, { artistName: "The Beatles" }))
        .rejects
        .toThrow("Failed to search setlists");
    });

    it("should re-throw known SetlistFM errors by name", async () => {
      const customError = new Error("Custom error");
      customError.name = "SetlistFMCustomError";
      vi.mocked(mockHttpClient.get).mockRejectedValue(customError);

      await expect(searchSetlists(mockHttpClient, { artistName: "The Beatles" }))
        .rejects
        .toThrow("Custom error");
    });

    it("should re-throw errors with 'Error' in the name", async () => {
      const customError = new Error("Custom error");
      customError.name = "CustomError";
      vi.mocked(mockHttpClient.get).mockRejectedValue(customError);

      await expect(searchSetlists(mockHttpClient, { artistName: "The Beatles" }))
        .rejects
        .toThrow("Custom error");
    });

    it("should handle timeout errors", async () => {
      const timeoutError = new Error("Request timeout");
      timeoutError.name = "TimeoutError";
      vi.mocked(mockHttpClient.get).mockRejectedValue(timeoutError);

      await expect(searchSetlists(mockHttpClient, { artistName: "The Beatles" }))
        .rejects
        .toThrow("Request timeout");
    });

    it("should handle network connection errors", async () => {
      const connectionError = new Error("Connection refused");
      connectionError.name = "ConnectionError";
      vi.mocked(mockHttpClient.get).mockRejectedValue(connectionError);

      await expect(searchSetlists(mockHttpClient, { artistName: "The Beatles" }))
        .rejects
        .toThrow("Connection refused");
    });
  });
});
