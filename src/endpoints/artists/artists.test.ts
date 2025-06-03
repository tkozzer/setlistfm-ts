/**
 * @file artists.test.ts
 * @description Test suite for artists endpoint functionality.
 * @author tkozzer
 * @module Artists
 */

// Temporary test stub for initial scaffolding.
// Replace with real test cases for endpoint logic.

import type { Artist, MBID } from "@shared/types";

import type { HttpClient } from "@utils/http";
import type { Artists, GetArtistSetlistsParams, SearchArtistsParams, Setlists } from "./types";

import { AuthenticationError, NotFoundError, SetlistFMAPIError, ValidationError } from "@shared/error";

import { beforeEach, describe, expect, it, vi } from "vitest";

import { getArtist } from "./getArtist";
import { getArtistSetlists } from "./getArtistSetlists";
import { searchArtists } from "./searchArtists";

// Test index.ts exports
describe("index exports", () => {
  it("should export all artist functions and types", async () => {
    const indexModule = await import("./index.js");

    // Test function exports
    expect(typeof indexModule.getArtist).toBe("function");
    expect(typeof indexModule.getArtistSetlists).toBe("function");
    expect(typeof indexModule.searchArtists).toBe("function");

    // Test validation schema exports
    expect(indexModule.ArtistMbidParamSchema).toBeDefined();
    expect(indexModule.ArtistSchema).toBeDefined();
    expect(indexModule.ArtistsSchema).toBeDefined();
    expect(indexModule.GetArtistSetlistsParamsSchema).toBeDefined();
    expect(indexModule.SearchArtistsParamsSchema).toBeDefined();
    expect(indexModule.SetlistsSchema).toBeDefined();
  });
});

describe("getArtist", () => {
  let mockHttpClient: HttpClient;
  const validMbid: MBID = "b10bbbfc-cf9e-42e0-be17-e2c3e1d2600d";
  const mockArtist: Artist = {
    mbid: validMbid,
    name: "The Beatles",
    sortName: "Beatles, The",
    disambiguation: "John, Paul, George and Ringo",
    url: "https://www.setlist.fm/setlists/the-beatles-23d6a88b.html",
  };

  beforeEach(() => {
    mockHttpClient = {
      get: vi.fn(),
    } as any;
  });

  describe("successful requests", () => {
    it("should return artist data for valid MBID", async () => {
      vi.mocked(mockHttpClient.get).mockResolvedValue(mockArtist);

      const result = await getArtist(mockHttpClient, validMbid);

      expect(result).toEqual(mockArtist);
      expect(mockHttpClient.get).toHaveBeenCalledWith(`/artist/${validMbid}`);
    });

    it("should handle artist with minimal data", async () => {
      const minimalArtist: Artist = {
        mbid: validMbid,
        name: "Test Artist",
        sortName: "Artist, Test",
      };

      vi.mocked(mockHttpClient.get).mockResolvedValue(minimalArtist);

      const result = await getArtist(mockHttpClient, validMbid);

      expect(result).toEqual(minimalArtist);
      expect(result.disambiguation).toBeUndefined();
      expect(result.url).toBeUndefined();
    });
  });

  describe("validation errors", () => {
    it("should throw ValidationError for missing MBID", async () => {
      await expect(getArtist(mockHttpClient, "" as MBID))
        .rejects
        .toThrow(ValidationError);

      await expect(getArtist(mockHttpClient, "" as MBID))
        .rejects
        .toThrow("Invalid artist MBID: MBID is required");
    });

    it("should throw ValidationError for null MBID", async () => {
      await expect(getArtist(mockHttpClient, null as any))
        .rejects
        .toThrow(ValidationError);
    });

    it("should throw ValidationError for invalid MBID format", async () => {
      const invalidMbids = [
        "invalid-mbid",
        "1234567890",
        "b10bbbfc-cf9e-42e0-be17", // too short
        "b10bbbfc-cf9e-42e0-be17-e2c3e1d2600d-extra", // too long
        "g10bbbfc-cf9e-42e0-be17-e2c3e1d2600d", // invalid character
      ];

      for (const invalidMbid of invalidMbids) {
        await expect(getArtist(mockHttpClient, invalidMbid as MBID))
          .rejects
          .toThrow(ValidationError);

        await expect(getArtist(mockHttpClient, invalidMbid as MBID))
          .rejects
          .toThrow("Invalid artist MBID: MBID must be a valid UUID format");
      }
    });
  });

  describe("HTTP errors", () => {
    it("should handle 404 Not Found error", async () => {
      const notFoundError = new NotFoundError("artist", validMbid);
      vi.mocked(mockHttpClient.get).mockRejectedValue(notFoundError);

      await expect(getArtist(mockHttpClient, validMbid))
        .rejects
        .toThrow(NotFoundError);
    });

    it("should handle 401 Authentication error", async () => {
      const authError = new AuthenticationError("Invalid API key");
      vi.mocked(mockHttpClient.get).mockRejectedValue(authError);

      await expect(getArtist(mockHttpClient, validMbid))
        .rejects
        .toThrow(AuthenticationError);
    });

    it("should handle SetlistFM API errors", async () => {
      const apiError = new SetlistFMAPIError("API rate limit exceeded", 429);
      vi.mocked(mockHttpClient.get).mockRejectedValue(apiError);

      await expect(getArtist(mockHttpClient, validMbid))
        .rejects
        .toThrow(SetlistFMAPIError);
    });

    it("should handle unexpected errors", async () => {
      const unexpectedError = new Error("Network error");
      vi.mocked(mockHttpClient.get).mockRejectedValue(unexpectedError);

      await expect(getArtist(mockHttpClient, validMbid))
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

      await expect(getArtist(mockHttpClient, validMbid))
        .rejects
        .toThrow("Internal server error");
    });

    it("should handle errors without status code (fallback to 500)", async () => {
      const errorWithoutStatus = {
        message: "Connection failed",
        response: { error: "Network failure" },
      };
      vi.mocked(mockHttpClient.get).mockRejectedValue(errorWithoutStatus);

      await expect(getArtist(mockHttpClient, validMbid))
        .rejects
        .toThrow("Connection failed");
    });

    it("should handle errors without message (fallback to default)", async () => {
      const errorWithoutMessage = {
        statusCode: 503,
        response: { error: "Service unavailable" },
      };
      vi.mocked(mockHttpClient.get).mockRejectedValue(errorWithoutMessage);

      await expect(getArtist(mockHttpClient, validMbid))
        .rejects
        .toThrow("Failed to retrieve artist");
    });

    it("should handle errors without status code or message", async () => {
      const minimalError = {
        response: { error: "Unknown error" },
      };
      vi.mocked(mockHttpClient.get).mockRejectedValue(minimalError);

      await expect(getArtist(mockHttpClient, validMbid))
        .rejects
        .toThrow("Failed to retrieve artist");
    });

    it("should handle errors with name containing 'SetlistFM'", async () => {
      const setlistFMError = {
        name: "SetlistFMTimeoutError",
        message: "Request timed out",
      };
      vi.mocked(mockHttpClient.get).mockRejectedValue(setlistFMError);

      await expect(getArtist(mockHttpClient, validMbid))
        .rejects
        .toThrow("Request timed out");
    });

    it("should handle errors with name containing 'Error' but not SetlistFM", async () => {
      const namedError = {
        name: "CustomError",
        message: "Custom error message",
      };
      vi.mocked(mockHttpClient.get).mockRejectedValue(namedError);

      await expect(getArtist(mockHttpClient, validMbid))
        .rejects
        .toThrow("Custom error message");
    });

    it("should handle errors with falsy name property", async () => {
      const errorWithFalsyName = {
        name: "",
        statusCode: 400,
        message: "Bad request",
      };
      vi.mocked(mockHttpClient.get).mockRejectedValue(errorWithFalsyName);

      await expect(getArtist(mockHttpClient, validMbid))
        .rejects
        .toThrow("Bad request");
    });

    it("should handle errors with null name property", async () => {
      const errorWithNullName = {
        name: null,
        statusCode: 502,
        message: "Bad gateway",
      };
      vi.mocked(mockHttpClient.get).mockRejectedValue(errorWithNullName);

      await expect(getArtist(mockHttpClient, validMbid))
        .rejects
        .toThrow("Bad gateway");
    });
  });

  describe("edge cases", () => {
    it("should handle MBID with uppercase letters", async () => {
      const uppercaseMbid = "B10BBBFC-CF9E-42E0-BE17-E2C3E1D2600D";
      vi.mocked(mockHttpClient.get).mockResolvedValue(mockArtist);

      const result = await getArtist(mockHttpClient, uppercaseMbid as MBID);

      expect(result).toEqual(mockArtist);
      expect(mockHttpClient.get).toHaveBeenCalledWith(`/artist/${uppercaseMbid}`);
    });

    it("should handle artist with empty optional fields", async () => {
      const artistWithEmptyFields: Artist = {
        mbid: validMbid,
        name: "Test Artist",
        sortName: "Artist, Test",
        disambiguation: "",
        url: "",
      };

      vi.mocked(mockHttpClient.get).mockResolvedValue(artistWithEmptyFields);

      const result = await getArtist(mockHttpClient, validMbid);

      expect(result).toEqual(artistWithEmptyFields);
      expect(result.disambiguation).toBe("");
      expect(result.url).toBe("");
    });
  });
});

describe("searchArtists", () => {
  let mockHttpClient: HttpClient;
  const validMbid: MBID = "b10bbbfc-cf9e-42e0-be17-e2c3e1d2600d";
  const mockArtists: Artists = {
    artist: [
      {
        mbid: validMbid,
        name: "The Beatles",
        sortName: "Beatles, The",
        disambiguation: "John, Paul, George and Ringo",
        url: "https://www.setlist.fm/setlists/the-beatles-23d6a88b.html",
      },
      {
        mbid: "other-mbid-123",
        name: "Beatles Tribute Band",
        sortName: "Beatles Tribute Band",
      },
    ],
    total: 25,
    page: 1,
    itemsPerPage: 20,
  };

  beforeEach(() => {
    mockHttpClient = {
      get: vi.fn(),
    } as any;
  });

  describe("successful requests", () => {
    it("should search artists by name", async () => {
      const params: SearchArtistsParams = { artistName: "The Beatles" };
      vi.mocked(mockHttpClient.get).mockResolvedValue(mockArtists);

      const result = await searchArtists(mockHttpClient, params);

      expect(result).toEqual(mockArtists);
      expect(mockHttpClient.get).toHaveBeenCalledWith("/search/artists", params);
    });

    it("should search artists by MBID", async () => {
      const params: SearchArtistsParams = { artistMbid: validMbid };
      const singleArtist: Artists = {
        artist: [mockArtists.artist[0]],
        total: 1,
        page: 1,
        itemsPerPage: 20,
      };
      vi.mocked(mockHttpClient.get).mockResolvedValue(singleArtist);

      const result = await searchArtists(mockHttpClient, params);

      expect(result).toEqual(singleArtist);
      expect(mockHttpClient.get).toHaveBeenCalledWith("/search/artists", params);
    });

    it("should search artists by Ticketmaster ID", async () => {
      const params: SearchArtistsParams = { artistTmid: 123456 };
      vi.mocked(mockHttpClient.get).mockResolvedValue(mockArtists);

      const result = await searchArtists(mockHttpClient, params);

      expect(result).toEqual(mockArtists);
      expect(mockHttpClient.get).toHaveBeenCalledWith("/search/artists", params);
    });

    it("should handle pagination parameters", async () => {
      const params: SearchArtistsParams = { artistName: "Beatles", p: 2 };
      const page2Artists: Artists = {
        ...mockArtists,
        page: 2,
      };
      vi.mocked(mockHttpClient.get).mockResolvedValue(page2Artists);

      const result = await searchArtists(mockHttpClient, params);

      expect(result).toEqual(page2Artists);
      expect(result.page).toBe(2);
      expect(mockHttpClient.get).toHaveBeenCalledWith("/search/artists", params);
    });

    it("should handle sort parameters", async () => {
      const params: SearchArtistsParams = { artistName: "Beatles", sort: "relevance" };
      vi.mocked(mockHttpClient.get).mockResolvedValue(mockArtists);

      const result = await searchArtists(mockHttpClient, params);

      expect(result).toEqual(mockArtists);
      expect(mockHttpClient.get).toHaveBeenCalledWith("/search/artists", params);
    });

    it("should handle multiple search criteria", async () => {
      const params: SearchArtistsParams = {
        artistName: "Beatles",
        artistMbid: validMbid,
        p: 1,
        sort: "sortName",
      };
      vi.mocked(mockHttpClient.get).mockResolvedValue(mockArtists);

      const result = await searchArtists(mockHttpClient, params);

      expect(result).toEqual(mockArtists);
      expect(mockHttpClient.get).toHaveBeenCalledWith("/search/artists", params);
    });

    it("should handle empty search results", async () => {
      const emptyResults: Artists = {
        artist: [],
        total: 0,
        page: 1,
        itemsPerPage: 20,
      };
      const params: SearchArtistsParams = { artistName: "NonexistentArtist" };
      vi.mocked(mockHttpClient.get).mockResolvedValue(emptyResults);

      const result = await searchArtists(mockHttpClient, params);

      expect(result).toEqual(emptyResults);
      expect(result.artist).toHaveLength(0);
      expect(result.total).toBe(0);
    });

    it("should handle artists with minimal data", async () => {
      const minimalArtists: Artists = {
        artist: [
          {
            mbid: validMbid,
            name: "Simple Artist",
            sortName: "Artist, Simple",
          },
        ],
        total: 1,
        page: 1,
        itemsPerPage: 20,
      };
      const params: SearchArtistsParams = { artistName: "Simple Artist" };
      vi.mocked(mockHttpClient.get).mockResolvedValue(minimalArtists);

      const result = await searchArtists(mockHttpClient, params);

      expect(result).toEqual(minimalArtists);
      expect(result.artist[0].disambiguation).toBeUndefined();
      expect(result.artist[0].url).toBeUndefined();
    });
  });

  describe("validation errors", () => {
    it("should throw ValidationError when no search criteria provided", async () => {
      const emptyParams = {};

      await expect(searchArtists(mockHttpClient, emptyParams as SearchArtistsParams))
        .rejects
        .toThrow(ValidationError);

      await expect(searchArtists(mockHttpClient, emptyParams as SearchArtistsParams))
        .rejects
        .toThrow("At least one of artistName, artistMbid, or artistTmid must be provided");
    });

    it("should throw ValidationError for invalid artist name", async () => {
      const invalidParams = [
        { artistName: "" },
        { artistName: "   " }, // only whitespace
      ];

      for (const params of invalidParams) {
        await expect(searchArtists(mockHttpClient, params as SearchArtistsParams))
          .rejects
          .toThrow(ValidationError);
      }
    });

    it("should throw ValidationError for invalid MBID", async () => {
      const invalidParams = [
        { artistMbid: "" },
        { artistMbid: "invalid-mbid" },
        { artistMbid: "b10bbbfc-cf9e-42e0-be17" }, // too short
        { artistMbid: "g10bbbfc-cf9e-42e0-be17-e2c3e1d2600d" }, // invalid character
      ];

      for (const params of invalidParams) {
        await expect(searchArtists(mockHttpClient, params as SearchArtistsParams))
          .rejects
          .toThrow(ValidationError);

        if (params.artistMbid !== "") {
          await expect(searchArtists(mockHttpClient, params as SearchArtistsParams))
            .rejects
            .toThrow("MBID must be a valid UUID format");
        }
      }
    });

    it("should throw ValidationError for invalid Ticketmaster ID", async () => {
      const invalidParams = [
        { artistTmid: 0 },
        { artistTmid: -1 },
        { artistTmid: 1.5 },
        { artistTmid: "123" as any },
      ];

      for (const params of invalidParams) {
        await expect(searchArtists(mockHttpClient, params as SearchArtistsParams))
          .rejects
          .toThrow(ValidationError);
      }
    });

    it("should throw ValidationError for invalid sort parameter", async () => {
      const invalidParams = [
        { artistName: "Beatles", sort: "invalid" as any },
        { artistName: "Beatles", sort: "name" as any },
        { artistName: "Beatles", sort: "" as any },
      ];

      for (const params of invalidParams) {
        await expect(searchArtists(mockHttpClient, params))
          .rejects
          .toThrow(ValidationError);
      }
    });

    it("should throw ValidationError for invalid pagination", async () => {
      const invalidParams = [
        { artistName: "Beatles", p: 0 },
        { artistName: "Beatles", p: -1 },
        { artistName: "Beatles", p: 1.5 },
        { artistName: "Beatles", p: "1" as any },
      ];

      for (const params of invalidParams) {
        await expect(searchArtists(mockHttpClient, params))
          .rejects
          .toThrow(ValidationError);
      }
    });
  });

  describe("HTTP errors", () => {
    const validParams: SearchArtistsParams = { artistName: "The Beatles" };

    it("should handle 404 Not Found error", async () => {
      const notFoundError = new NotFoundError("artist", "The Beatles");
      vi.mocked(mockHttpClient.get).mockRejectedValue(notFoundError);

      await expect(searchArtists(mockHttpClient, validParams))
        .rejects
        .toThrow(NotFoundError);
    });

    it("should handle 401 Authentication error", async () => {
      const authError = new AuthenticationError("Invalid API key");
      vi.mocked(mockHttpClient.get).mockRejectedValue(authError);

      await expect(searchArtists(mockHttpClient, validParams))
        .rejects
        .toThrow(AuthenticationError);
    });

    it("should handle SetlistFM API errors", async () => {
      const apiError = new SetlistFMAPIError("API rate limit exceeded", 429);
      vi.mocked(mockHttpClient.get).mockRejectedValue(apiError);

      await expect(searchArtists(mockHttpClient, validParams))
        .rejects
        .toThrow(SetlistFMAPIError);
    });

    it("should handle unexpected errors", async () => {
      const unexpectedError = new Error("Network error");
      vi.mocked(mockHttpClient.get).mockRejectedValue(unexpectedError);

      await expect(searchArtists(mockHttpClient, validParams))
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

      await expect(searchArtists(mockHttpClient, validParams))
        .rejects
        .toThrow("Internal server error");
    });

    it("should handle errors without status code (fallback to 500)", async () => {
      const errorWithoutStatus = {
        message: "Connection failed",
        response: { error: "Network failure" },
      };
      vi.mocked(mockHttpClient.get).mockRejectedValue(errorWithoutStatus);

      await expect(searchArtists(mockHttpClient, validParams))
        .rejects
        .toThrow("Connection failed");
    });

    it("should handle errors without message (fallback to default)", async () => {
      const errorWithoutMessage = {
        statusCode: 503,
        response: { error: "Service unavailable" },
      };
      vi.mocked(mockHttpClient.get).mockRejectedValue(errorWithoutMessage);

      await expect(searchArtists(mockHttpClient, validParams))
        .rejects
        .toThrow("Failed to search artists");
    });

    it("should handle errors without status code or message", async () => {
      const minimalError = {
        response: { error: "Unknown error" },
      };
      vi.mocked(mockHttpClient.get).mockRejectedValue(minimalError);

      await expect(searchArtists(mockHttpClient, validParams))
        .rejects
        .toThrow("Failed to search artists");
    });

    it("should handle errors with name containing 'SetlistFM'", async () => {
      const setlistFMError = {
        name: "SetlistFMTimeoutError",
        message: "Request timed out",
      };
      vi.mocked(mockHttpClient.get).mockRejectedValue(setlistFMError);

      await expect(searchArtists(mockHttpClient, validParams))
        .rejects
        .toThrow("Request timed out");
    });

    it("should handle errors with name containing 'Error' but not SetlistFM", async () => {
      const namedError = {
        name: "CustomError",
        message: "Custom error message",
      };
      vi.mocked(mockHttpClient.get).mockRejectedValue(namedError);

      await expect(searchArtists(mockHttpClient, validParams))
        .rejects
        .toThrow("Custom error message");
    });

    it("should handle errors with falsy name property", async () => {
      const errorWithFalsyName = {
        name: "",
        statusCode: 400,
        message: "Bad request",
      };
      vi.mocked(mockHttpClient.get).mockRejectedValue(errorWithFalsyName);

      await expect(searchArtists(mockHttpClient, validParams))
        .rejects
        .toThrow("Bad request");
    });

    it("should handle errors with null name property", async () => {
      const errorWithNullName = {
        name: null,
        statusCode: 502,
        message: "Bad gateway",
      };
      vi.mocked(mockHttpClient.get).mockRejectedValue(errorWithNullName);

      await expect(searchArtists(mockHttpClient, validParams))
        .rejects
        .toThrow("Bad gateway");
    });
  });

  describe("edge cases", () => {
    it("should handle MBID search with uppercase letters", async () => {
      const uppercaseMbid = "B10BBBFC-CF9E-42E0-BE17-E2C3E1D2600D";
      const params: SearchArtistsParams = { artistMbid: uppercaseMbid };
      vi.mocked(mockHttpClient.get).mockResolvedValue(mockArtists);

      const result = await searchArtists(mockHttpClient, params);

      expect(result).toEqual(mockArtists);
      expect(mockHttpClient.get).toHaveBeenCalledWith("/search/artists", params);
    });

    it("should handle large page numbers", async () => {
      const params: SearchArtistsParams = { artistName: "Beatles", p: 999 };
      vi.mocked(mockHttpClient.get).mockResolvedValue(mockArtists);

      const result = await searchArtists(mockHttpClient, params);

      expect(result).toEqual(mockArtists);
      expect(mockHttpClient.get).toHaveBeenCalledWith("/search/artists", params);
    });

    it("should handle large Ticketmaster IDs", async () => {
      const params: SearchArtistsParams = { artistTmid: 999999999 };
      vi.mocked(mockHttpClient.get).mockResolvedValue(mockArtists);

      const result = await searchArtists(mockHttpClient, params);

      expect(result).toEqual(mockArtists);
      expect(mockHttpClient.get).toHaveBeenCalledWith("/search/artists", params);
    });

    it("should handle artists with special characters in names", async () => {
      const specialArtists: Artists = {
        artist: [
          {
            mbid: "special-mbid",
            name: "Björk",
            sortName: "Björk",
          },
          {
            mbid: "special-mbid-2",
            name: "Mötley Crüe",
            sortName: "Mötley Crüe",
          },
        ],
        total: 2,
        page: 1,
        itemsPerPage: 20,
      };
      const params: SearchArtistsParams = { artistName: "Björk" };
      vi.mocked(mockHttpClient.get).mockResolvedValue(specialArtists);

      const result = await searchArtists(mockHttpClient, params);

      expect(result).toEqual(specialArtists);
      expect(result.artist[0].name).toBe("Björk");
      expect(result.artist[1].name).toBe("Mötley Crüe");
    });

    it("should handle search with all possible parameters", async () => {
      const params: SearchArtistsParams = {
        artistName: "Beatles",
        artistMbid: validMbid,
        artistTmid: 123456,
        p: 1,
        sort: "relevance",
      };
      vi.mocked(mockHttpClient.get).mockResolvedValue(mockArtists);

      const result = await searchArtists(mockHttpClient, params);

      expect(result).toEqual(mockArtists);
      expect(mockHttpClient.get).toHaveBeenCalledWith("/search/artists", params);
    });
  });
});

describe("getArtistSetlists", () => {
  let mockHttpClient: HttpClient;
  const validMbid: MBID = "b10bbbfc-cf9e-42e0-be17-e2c3e1d2600d";
  const mockSetlists: Setlists = {
    setlist: [
      {
        id: "1bd6f5a0",
        versionId: "1bd6f5a0",
        eventDate: "2023-06-15",
        lastUpdated: "2023-06-16T10:30:00.000Z",
        artist: {
          mbid: validMbid,
          name: "The Beatles",
          sortName: "Beatles, The",
        },
        venue: {
          id: "venue123",
          name: "Abbey Road Studios",
          city: {
            id: "london-uk",
            name: "London",
            country: {
              code: "GB",
              name: "United Kingdom",
            },
            coords: {
              lat: 51.5074,
              long: -0.1278,
            },
          },
        },
        sets: {
          set: [],
        },
      },
    ],
    total: 150,
    page: 1,
    itemsPerPage: 20,
  };

  beforeEach(() => {
    mockHttpClient = {
      get: vi.fn(),
    } as any;
  });

  describe("successful requests", () => {
    it("should return setlists data for valid MBID", async () => {
      vi.mocked(mockHttpClient.get).mockResolvedValue(mockSetlists);

      const result = await getArtistSetlists(mockHttpClient, validMbid);

      expect(result).toEqual(mockSetlists);
      expect(mockHttpClient.get).toHaveBeenCalledWith(`/artist/${validMbid}/setlists`, {});
    });

    it("should handle pagination parameters", async () => {
      const params: GetArtistSetlistsParams = { p: 2 };
      vi.mocked(mockHttpClient.get).mockResolvedValue(mockSetlists);

      const result = await getArtistSetlists(mockHttpClient, validMbid, params);

      expect(result).toEqual(mockSetlists);
      expect(mockHttpClient.get).toHaveBeenCalledWith(`/artist/${validMbid}/setlists`, params);
    });

    it("should handle empty setlists response", async () => {
      const emptySetlists: Setlists = {
        setlist: [],
        total: 0,
        page: 1,
        itemsPerPage: 20,
      };
      vi.mocked(mockHttpClient.get).mockResolvedValue(emptySetlists);

      const result = await getArtistSetlists(mockHttpClient, validMbid);

      expect(result).toEqual(emptySetlists);
      expect(result.setlist).toHaveLength(0);
      expect(result.total).toBe(0);
    });

    it("should use default empty params when none provided", async () => {
      vi.mocked(mockHttpClient.get).mockResolvedValue(mockSetlists);

      await getArtistSetlists(mockHttpClient, validMbid);

      expect(mockHttpClient.get).toHaveBeenCalledWith(`/artist/${validMbid}/setlists`, {});
    });
  });

  describe("validation errors", () => {
    it("should throw ValidationError for missing MBID", async () => {
      await expect(getArtistSetlists(mockHttpClient, "" as MBID))
        .rejects
        .toThrow(ValidationError);

      await expect(getArtistSetlists(mockHttpClient, "" as MBID))
        .rejects
        .toThrow("Invalid artist MBID: MBID is required");
    });

    it("should throw ValidationError for null MBID", async () => {
      await expect(getArtistSetlists(mockHttpClient, null as any))
        .rejects
        .toThrow(ValidationError);
    });

    it("should throw ValidationError for invalid MBID format", async () => {
      const invalidMbids = [
        "invalid-mbid",
        "1234567890",
        "b10bbbfc-cf9e-42e0-be17", // too short
        "b10bbbfc-cf9e-42e0-be17-e2c3e1d2600d-extra", // too long
      ];

      for (const invalidMbid of invalidMbids) {
        await expect(getArtistSetlists(mockHttpClient, invalidMbid as MBID))
          .rejects
          .toThrow(ValidationError);

        await expect(getArtistSetlists(mockHttpClient, invalidMbid as MBID))
          .rejects
          .toThrow("Invalid artist MBID: MBID must be a valid UUID format");
      }
    });

    it("should throw ValidationError for invalid pagination parameters", async () => {
      const invalidParams = [
        { p: 0 },
        { p: -1 },
        { p: 1.5 },
        { p: "1" as any },
      ];

      for (const params of invalidParams) {
        await expect(getArtistSetlists(mockHttpClient, validMbid, params))
          .rejects
          .toThrow(ValidationError);
      }
    });
  });

  describe("HTTP errors", () => {
    it("should handle 404 Not Found error", async () => {
      const notFoundError = new NotFoundError("artist", validMbid);
      vi.mocked(mockHttpClient.get).mockRejectedValue(notFoundError);

      await expect(getArtistSetlists(mockHttpClient, validMbid))
        .rejects
        .toThrow(NotFoundError);
    });

    it("should handle 401 Authentication error", async () => {
      const authError = new AuthenticationError("Invalid API key");
      vi.mocked(mockHttpClient.get).mockRejectedValue(authError);

      await expect(getArtistSetlists(mockHttpClient, validMbid))
        .rejects
        .toThrow(AuthenticationError);
    });

    it("should handle SetlistFM API errors", async () => {
      const apiError = new SetlistFMAPIError("API rate limit exceeded", 429);
      vi.mocked(mockHttpClient.get).mockRejectedValue(apiError);

      await expect(getArtistSetlists(mockHttpClient, validMbid))
        .rejects
        .toThrow(SetlistFMAPIError);
    });

    it("should handle unexpected errors", async () => {
      const unexpectedError = new Error("Network error");
      vi.mocked(mockHttpClient.get).mockRejectedValue(unexpectedError);

      await expect(getArtistSetlists(mockHttpClient, validMbid))
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

      await expect(getArtistSetlists(mockHttpClient, validMbid))
        .rejects
        .toThrow("Internal server error");
    });

    it("should handle errors without status code (fallback to 500)", async () => {
      const errorWithoutStatus = {
        message: "Connection failed",
        response: { error: "Network failure" },
      };
      vi.mocked(mockHttpClient.get).mockRejectedValue(errorWithoutStatus);

      await expect(getArtistSetlists(mockHttpClient, validMbid))
        .rejects
        .toThrow("Connection failed");
    });

    it("should handle errors without message (fallback to default)", async () => {
      const errorWithoutMessage = {
        statusCode: 503,
        response: { error: "Service unavailable" },
      };
      vi.mocked(mockHttpClient.get).mockRejectedValue(errorWithoutMessage);

      await expect(getArtistSetlists(mockHttpClient, validMbid))
        .rejects
        .toThrow("Failed to retrieve artist setlists");
    });

    it("should handle errors without status code or message", async () => {
      const minimalError = {
        response: { error: "Unknown error" },
      };
      vi.mocked(mockHttpClient.get).mockRejectedValue(minimalError);

      await expect(getArtistSetlists(mockHttpClient, validMbid))
        .rejects
        .toThrow("Failed to retrieve artist setlists");
    });

    it("should handle errors with name containing 'SetlistFM'", async () => {
      const setlistFMError = {
        name: "SetlistFMTimeoutError",
        message: "Request timed out",
      };
      vi.mocked(mockHttpClient.get).mockRejectedValue(setlistFMError);

      await expect(getArtistSetlists(mockHttpClient, validMbid))
        .rejects
        .toThrow("Request timed out");
    });

    it("should handle errors with name containing 'Error' but not SetlistFM", async () => {
      const namedError = {
        name: "CustomError",
        message: "Custom error message",
      };
      vi.mocked(mockHttpClient.get).mockRejectedValue(namedError);

      await expect(getArtistSetlists(mockHttpClient, validMbid))
        .rejects
        .toThrow("Custom error message");
    });

    it("should handle errors with falsy name property", async () => {
      const errorWithFalsyName = {
        name: "",
        statusCode: 400,
        message: "Bad request",
      };
      vi.mocked(mockHttpClient.get).mockRejectedValue(errorWithFalsyName);

      await expect(getArtistSetlists(mockHttpClient, validMbid))
        .rejects
        .toThrow("Bad request");
    });

    it("should handle errors with null name property", async () => {
      const errorWithNullName = {
        name: null,
        statusCode: 502,
        message: "Bad gateway",
      };
      vi.mocked(mockHttpClient.get).mockRejectedValue(errorWithNullName);

      await expect(getArtistSetlists(mockHttpClient, validMbid))
        .rejects
        .toThrow("Bad gateway");
    });
  });

  describe("edge cases", () => {
    it("should handle MBID with uppercase letters", async () => {
      const uppercaseMbid = "B10BBBFC-CF9E-42E0-BE17-E2C3E1D2600D";
      vi.mocked(mockHttpClient.get).mockResolvedValue(mockSetlists);

      const result = await getArtistSetlists(mockHttpClient, uppercaseMbid as MBID);

      expect(result).toEqual(mockSetlists);
      expect(mockHttpClient.get).toHaveBeenCalledWith(`/artist/${uppercaseMbid}/setlists`, {});
    });

    it("should handle large page numbers", async () => {
      const params: GetArtistSetlistsParams = { p: 999 };
      vi.mocked(mockHttpClient.get).mockResolvedValue(mockSetlists);

      const result = await getArtistSetlists(mockHttpClient, validMbid, params);

      expect(result).toEqual(mockSetlists);
      expect(mockHttpClient.get).toHaveBeenCalledWith(`/artist/${validMbid}/setlists`, params);
    });

    it("should handle setlists with complex nested data", async () => {
      const complexSetlists: Setlists = {
        setlist: [
          {
            id: "complex123",
            versionId: "complex123",
            eventDate: "2023-12-25",
            lastUpdated: "2023-12-26T00:00:00.000Z",
            artist: {
              mbid: validMbid,
              name: "The Beatles",
              sortName: "Beatles, The",
              disambiguation: "British rock band",
              url: "https://www.setlist.fm/setlists/the-beatles-23d6a88b.html",
            },
            venue: {
              id: "venue456",
              name: "Cavern Club",
              city: {
                id: "liverpool-uk",
                name: "Liverpool",
                state: "England",
                stateCode: "ENG",
                country: {
                  code: "GB",
                  name: "United Kingdom",
                },
                coords: {
                  lat: 53.4084,
                  long: -2.9916,
                },
              },
              url: "https://www.setlist.fm/venue/cavern-club-liverpool-england-43d6a88b.html",
            },
            tour: {
              name: "Abbey Road Tour",
            },
            sets: {
              set: [
                {
                  name: "Set 1",
                  song: [
                    {
                      name: "Come Together",
                    },
                    {
                      name: "Yesterday",
                      info: "Acoustic version",
                    },
                  ],
                },
                {
                  name: "Encore",
                  encore: true,
                  song: [
                    {
                      name: "Hey Jude",
                    },
                  ],
                },
              ],
            },
            info: "Historic performance",
            url: "https://www.setlist.fm/setlist/the-beatles/2023/cavern-club-liverpool-england-complex123.html",
          },
        ],
        total: 1,
        page: 1,
        itemsPerPage: 20,
      };

      vi.mocked(mockHttpClient.get).mockResolvedValue(complexSetlists);

      const result = await getArtistSetlists(mockHttpClient, validMbid);

      expect(result).toEqual(complexSetlists);
      expect(result.setlist[0]).toHaveProperty("tour");
      expect(result.setlist[0]).toHaveProperty("info");
      expect(result.setlist[0].sets.set).toHaveLength(2);
    });
  });
});
