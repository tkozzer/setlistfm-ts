/**
 * @file cities.test.ts
 * @description Test suite for cities endpoint functionality.
 * @author tkozzer
 * @module Cities
 */

import type { HttpClient } from "@utils/http";

import type { Cities, City, SearchCitiesParams } from "./types";

import { AuthenticationError, NotFoundError, SetlistFMAPIError, ValidationError } from "@shared/error";

import { beforeEach, describe, expect, it, vi } from "vitest";

import { getCityByGeoId } from "./getCityByGeoId";
import { searchCities } from "./searchCities";

// Test index.ts exports
describe("index exports", () => {
  it("should export all city functions and types", async () => {
    const indexModule = await import("./index.js");

    // Test function exports
    expect(typeof indexModule.getCityByGeoId).toBe("function");
    expect(typeof indexModule.searchCities).toBe("function");

    // Test validation schema exports
    expect(indexModule.CityGeoIdParamSchema).toBeDefined();
    expect(indexModule.CitySchema).toBeDefined();
    expect(indexModule.CitiesSchema).toBeDefined();
    expect(indexModule.CountriesSchema).toBeDefined();
    expect(indexModule.SearchCitiesParamsSchema).toBeDefined();
  });
});

describe("getCityByGeoId", () => {
  let mockHttpClient: HttpClient;
  const validGeoId = "5357527";
  const mockCity: City = {
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
  };

  beforeEach(() => {
    mockHttpClient = {
      get: vi.fn(),
    } as any;
  });

  describe("successful requests", () => {
    it("should return city data for valid geoId", async () => {
      vi.mocked(mockHttpClient.get).mockResolvedValue(mockCity);

      const result = await getCityByGeoId(mockHttpClient, validGeoId);

      expect(result).toEqual(mockCity);
      expect(mockHttpClient.get).toHaveBeenCalledWith(`/city/${validGeoId}`);
    });

    it("should handle city with different coordinate values", async () => {
      const cityWithDifferentCoords: City = {
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
      };

      vi.mocked(mockHttpClient.get).mockResolvedValue(cityWithDifferentCoords);

      const result = await getCityByGeoId(mockHttpClient, "2643743");

      expect(result).toEqual(cityWithDifferentCoords);
      expect(result.coords.long).toBe(-0.1276);
      expect(result.coords.lat).toBe(51.5074);
    });

    it("should handle city with extreme coordinate values", async () => {
      const cityWithExtremeCoords: City = {
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
      };

      vi.mocked(mockHttpClient.get).mockResolvedValue(cityWithExtremeCoords);

      const result = await getCityByGeoId(mockHttpClient, "1234567");

      expect(result).toEqual(cityWithExtremeCoords);
      expect(result.coords.long).toBe(180);
      expect(result.coords.lat).toBe(90);
    });

    it("should handle city with negative coordinates", async () => {
      const cityWithNegativeCoords: City = {
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
      };

      vi.mocked(mockHttpClient.get).mockResolvedValue(cityWithNegativeCoords);

      const result = await getCityByGeoId(mockHttpClient, "7890123");

      expect(result).toEqual(cityWithNegativeCoords);
      expect(result.coords.long).toBe(-58.3816);
      expect(result.coords.lat).toBe(-34.6037);
    });
  });

  describe("validation errors", () => {
    it("should throw ValidationError for empty geoId", async () => {
      await expect(getCityByGeoId(mockHttpClient, ""))
        .rejects
        .toThrow(ValidationError);

      await expect(getCityByGeoId(mockHttpClient, ""))
        .rejects
        .toThrow("Invalid city geoId: Value cannot be empty");
    });

    it("should throw ValidationError for null geoId", async () => {
      await expect(getCityByGeoId(mockHttpClient, null as any))
        .rejects
        .toThrow(ValidationError);
    });

    it("should throw ValidationError for undefined geoId", async () => {
      await expect(getCityByGeoId(mockHttpClient, undefined as any))
        .rejects
        .toThrow(ValidationError);
    });

    it("should throw ValidationError for non-numeric geoId", async () => {
      const invalidGeoIds = [
        "abc123",
        "5357527a",
        "a5357527",
        "535-7527",
        "535.7527",
        "535 7527",
        "535_7527",
        "#5357527",
        "5357527!",
      ];

      for (const invalidGeoId of invalidGeoIds) {
        await expect(getCityByGeoId(mockHttpClient, invalidGeoId))
          .rejects
          .toThrow(ValidationError);

        await expect(getCityByGeoId(mockHttpClient, invalidGeoId))
          .rejects
          .toThrow("Invalid city geoId: GeoId must be a numeric string");
      }
    });

    it("should accept valid numeric strings", async () => {
      vi.mocked(mockHttpClient.get).mockResolvedValue(mockCity);

      const validGeoIds = [
        "5357527",
        "1",
        "123456789",
        "0",
        "999999999999",
      ];

      for (const geoId of validGeoIds) {
        const result = await getCityByGeoId(mockHttpClient, geoId);
        expect(result).toEqual(mockCity);
        expect(mockHttpClient.get).toHaveBeenCalledWith(`/city/${geoId}`);
      }
    });
  });

  describe("HTTP errors", () => {
    it("should handle 404 Not Found error", async () => {
      const notFoundError = new NotFoundError("city", validGeoId);
      vi.mocked(mockHttpClient.get).mockRejectedValue(notFoundError);

      await expect(getCityByGeoId(mockHttpClient, validGeoId))
        .rejects
        .toThrow(NotFoundError);

      await expect(getCityByGeoId(mockHttpClient, validGeoId))
        .rejects
        .toThrow("city with identifier '5357527' not found");
    });

    it("should handle 401 Authentication error", async () => {
      const authError = new AuthenticationError("Invalid API key");
      vi.mocked(mockHttpClient.get).mockRejectedValue(authError);

      await expect(getCityByGeoId(mockHttpClient, validGeoId))
        .rejects
        .toThrow(AuthenticationError);

      await expect(getCityByGeoId(mockHttpClient, validGeoId))
        .rejects
        .toThrow("Invalid API key");
    });

    it("should handle SetlistFM API errors", async () => {
      const apiError = new SetlistFMAPIError("API rate limit exceeded", 429);
      vi.mocked(mockHttpClient.get).mockRejectedValue(apiError);

      await expect(getCityByGeoId(mockHttpClient, validGeoId))
        .rejects
        .toThrow(SetlistFMAPIError);

      await expect(getCityByGeoId(mockHttpClient, validGeoId))
        .rejects
        .toThrow("API rate limit exceeded");
    });

    it("should handle unexpected errors", async () => {
      const unexpectedError = new Error("Network error");
      vi.mocked(mockHttpClient.get).mockRejectedValue(unexpectedError);

      await expect(getCityByGeoId(mockHttpClient, validGeoId))
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

      await expect(getCityByGeoId(mockHttpClient, validGeoId))
        .rejects
        .toThrow("Internal server error");
    });

    it("should handle errors without status code (fallback to 500)", async () => {
      const errorWithoutStatus = {
        message: "Connection failed",
        response: { error: "Network failure" },
      };
      vi.mocked(mockHttpClient.get).mockRejectedValue(errorWithoutStatus);

      await expect(getCityByGeoId(mockHttpClient, validGeoId))
        .rejects
        .toThrow("Connection failed");
    });

    it("should handle errors without message (fallback to default)", async () => {
      const errorWithoutMessage = {
        statusCode: 503,
        response: { error: "Service unavailable" },
      };
      vi.mocked(mockHttpClient.get).mockRejectedValue(errorWithoutMessage);

      await expect(getCityByGeoId(mockHttpClient, validGeoId))
        .rejects
        .toThrow("Failed to retrieve city");
    });

    it("should handle errors without status code or message", async () => {
      const minimalError = {
        response: { error: "Unknown error" },
      };
      vi.mocked(mockHttpClient.get).mockRejectedValue(minimalError);

      await expect(getCityByGeoId(mockHttpClient, validGeoId))
        .rejects
        .toThrow("Failed to retrieve city");
    });

    it("should handle errors without any properties", async () => {
      const emptyError = {};
      vi.mocked(mockHttpClient.get).mockRejectedValue(emptyError);

      await expect(getCityByGeoId(mockHttpClient, validGeoId))
        .rejects
        .toThrow("Failed to retrieve city");
    });
  });

  describe("error propagation", () => {
    it("should re-throw known SetlistFM errors without modification", async () => {
      const knownErrors = [
        new NotFoundError("city", validGeoId),
        new AuthenticationError("Invalid API key"),
        new SetlistFMAPIError("Rate limit exceeded", 429),
        new ValidationError("Invalid parameter"),
      ];

      for (const error of knownErrors) {
        vi.mocked(mockHttpClient.get).mockRejectedValue(error);

        await expect(getCityByGeoId(mockHttpClient, validGeoId))
          .rejects
          .toThrow(error);
      }
    });

    it("should transform unknown errors to SetlistFM errors", async () => {
      const unknownError = new TypeError("Cannot read property 'data' of undefined");
      vi.mocked(mockHttpClient.get).mockRejectedValue(unknownError);

      await expect(getCityByGeoId(mockHttpClient, validGeoId))
        .rejects
        .toThrow("Cannot read property 'data' of undefined");
    });
  });

  describe("endpoint construction", () => {
    it("should construct correct endpoint URL for different geoIds", async () => {
      vi.mocked(mockHttpClient.get).mockResolvedValue(mockCity);

      const testGeoIds = ["5357527", "1", "999999"];

      for (const geoId of testGeoIds) {
        await getCityByGeoId(mockHttpClient, geoId);
        expect(mockHttpClient.get).toHaveBeenCalledWith(`/city/${geoId}`);
      }
    });

    it("should validate geoId before constructing endpoint", async () => {
      // Should not call httpClient.get for invalid geoId
      await expect(getCityByGeoId(mockHttpClient, "invalid"))
        .rejects
        .toThrow(ValidationError);

      expect(mockHttpClient.get).not.toHaveBeenCalled();
    });
  });
});

describe("searchCities", () => {
  let mockHttpClient: HttpClient;
  const mockCity: City = {
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
  };

  const mockCitiesResponse: Cities = {
    cities: [mockCity],
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
    it("should return cities for search by name", async () => {
      vi.mocked(mockHttpClient.get).mockResolvedValue(mockCitiesResponse);

      const result = await searchCities(mockHttpClient, { name: "Hollywood" });

      expect(result).toEqual(mockCitiesResponse);
      expect(mockHttpClient.get).toHaveBeenCalledWith("/search/cities", { name: "Hollywood" });
    });

    it("should return cities for search by country", async () => {
      vi.mocked(mockHttpClient.get).mockResolvedValue(mockCitiesResponse);

      const result = await searchCities(mockHttpClient, { country: "US" });

      expect(result).toEqual(mockCitiesResponse);
      expect(mockHttpClient.get).toHaveBeenCalledWith("/search/cities", { country: "US" });
    });

    it("should return cities for search by state", async () => {
      vi.mocked(mockHttpClient.get).mockResolvedValue(mockCitiesResponse);

      const result = await searchCities(mockHttpClient, { state: "California" });

      expect(result).toEqual(mockCitiesResponse);
      expect(mockHttpClient.get).toHaveBeenCalledWith("/search/cities", { state: "California" });
    });

    it("should return cities for search by state code", async () => {
      vi.mocked(mockHttpClient.get).mockResolvedValue(mockCitiesResponse);

      const result = await searchCities(mockHttpClient, { stateCode: "CA" });

      expect(result).toEqual(mockCitiesResponse);
      expect(mockHttpClient.get).toHaveBeenCalledWith("/search/cities", { stateCode: "CA" });
    });

    it("should handle search with multiple parameters", async () => {
      const searchParams: SearchCitiesParams = {
        name: "Hollywood",
        country: "US",
        state: "California",
        p: 2,
      };

      vi.mocked(mockHttpClient.get).mockResolvedValue(mockCitiesResponse);

      const result = await searchCities(mockHttpClient, searchParams);

      expect(result).toEqual(mockCitiesResponse);
      expect(mockHttpClient.get).toHaveBeenCalledWith("/search/cities", searchParams);
    });

    it("should handle search with pagination", async () => {
      const paginatedResponse: Cities = {
        cities: [mockCity],
        total: 42,
        page: 3,
        itemsPerPage: 20,
      };

      vi.mocked(mockHttpClient.get).mockResolvedValue(paginatedResponse);

      const result = await searchCities(mockHttpClient, { name: "Test", p: 3 });

      expect(result).toEqual(paginatedResponse);
      expect(result.page).toBe(3);
      expect(result.total).toBe(42);
    });

    it("should handle empty search results", async () => {
      const emptyResponse: Cities = {
        cities: [],
        total: 0,
        page: 1,
        itemsPerPage: 20,
      };

      vi.mocked(mockHttpClient.get).mockResolvedValue(emptyResponse);

      const result = await searchCities(mockHttpClient, { name: "NonExistentCity" });

      expect(result).toEqual(emptyResponse);
      expect(result.cities).toHaveLength(0);
      expect(result.total).toBe(0);
    });

    it("should handle search with default empty parameters", async () => {
      vi.mocked(mockHttpClient.get).mockResolvedValue(mockCitiesResponse);

      const result = await searchCities(mockHttpClient);

      expect(result).toEqual(mockCitiesResponse);
      expect(mockHttpClient.get).toHaveBeenCalledWith("/search/cities", {});
    });

    it("should handle multiple cities in response", async () => {
      const multipleCitiesResponse: Cities = {
        cities: [
          mockCity,
          {
            id: "2643743",
            name: "London",
            stateCode: "ENG",
            state: "England",
            coords: { long: -0.1276, lat: 51.5074 },
            country: { code: "GB", name: "United Kingdom" },
          },
        ],
        total: 2,
        page: 1,
        itemsPerPage: 20,
      };

      vi.mocked(mockHttpClient.get).mockResolvedValue(multipleCitiesResponse);

      const result = await searchCities(mockHttpClient, { name: "London" });

      expect(result).toEqual(multipleCitiesResponse);
      expect(result.cities).toHaveLength(2);
    });
  });

  describe("validation errors", () => {
    it("should throw ValidationError for invalid pagination", async () => {
      await expect(searchCities(mockHttpClient, { p: 0 }))
        .rejects
        .toThrow(ValidationError);

      await expect(searchCities(mockHttpClient, { p: -1 }))
        .rejects
        .toThrow(ValidationError);
    });

    it("should throw ValidationError for empty string parameters", async () => {
      const invalidParams = [
        { name: "" },
        { country: "" },
        { state: "" },
        { stateCode: "" },
      ];

      for (const params of invalidParams) {
        await expect(searchCities(mockHttpClient, params))
          .rejects
          .toThrow(ValidationError);
      }
    });

    it("should throw ValidationError for null parameters", async () => {
      await expect(searchCities(mockHttpClient, { name: null as any }))
        .rejects
        .toThrow(ValidationError);

      await expect(searchCities(mockHttpClient, { country: null as any }))
        .rejects
        .toThrow(ValidationError);
    });

    it("should throw ValidationError for non-string parameters", async () => {
      await expect(searchCities(mockHttpClient, { name: 123 as any }))
        .rejects
        .toThrow(ValidationError);

      await expect(searchCities(mockHttpClient, { p: "not-a-number" as any }))
        .rejects
        .toThrow(ValidationError);
    });

    it("should accept valid pagination values", async () => {
      vi.mocked(mockHttpClient.get).mockResolvedValue(mockCitiesResponse);

      const validPageNumbers = [1, 2, 10, 100];

      for (const pageNumber of validPageNumbers) {
        const result = await searchCities(mockHttpClient, { name: "Test", p: pageNumber });
        expect(result).toEqual(mockCitiesResponse);
        expect(mockHttpClient.get).toHaveBeenCalledWith("/search/cities", { name: "Test", p: pageNumber });
      }
    });
  });

  describe("HTTP errors", () => {
    it("should handle 404 Not Found error", async () => {
      const notFoundError = new NotFoundError("cities", "search query");
      vi.mocked(mockHttpClient.get).mockRejectedValue(notFoundError);

      await expect(searchCities(mockHttpClient, { name: "NonExistent" }))
        .rejects
        .toThrow(NotFoundError);
    });

    it("should handle 401 Authentication error", async () => {
      const authError = new AuthenticationError("Invalid API key");
      vi.mocked(mockHttpClient.get).mockRejectedValue(authError);

      await expect(searchCities(mockHttpClient, { name: "Test" }))
        .rejects
        .toThrow(AuthenticationError);
    });

    it("should handle SetlistFM API errors", async () => {
      const apiError = new SetlistFMAPIError("API rate limit exceeded", 429);
      vi.mocked(mockHttpClient.get).mockRejectedValue(apiError);

      await expect(searchCities(mockHttpClient, { name: "Test" }))
        .rejects
        .toThrow(SetlistFMAPIError);
    });

    it("should handle unexpected errors", async () => {
      const unexpectedError = new Error("Network error");
      vi.mocked(mockHttpClient.get).mockRejectedValue(unexpectedError);

      await expect(searchCities(mockHttpClient, { name: "Test" }))
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

      await expect(searchCities(mockHttpClient, { name: "Test" }))
        .rejects
        .toThrow("Internal server error");
    });

    it("should handle errors without status code (fallback to 500)", async () => {
      const errorWithoutStatus = {
        message: "Connection failed",
        response: { error: "Network failure" },
      };
      vi.mocked(mockHttpClient.get).mockRejectedValue(errorWithoutStatus);

      await expect(searchCities(mockHttpClient, { name: "Test" }))
        .rejects
        .toThrow("Connection failed");
    });

    it("should handle errors without message (fallback to default)", async () => {
      const errorWithoutMessage = {
        statusCode: 503,
        response: { error: "Service unavailable" },
      };
      vi.mocked(mockHttpClient.get).mockRejectedValue(errorWithoutMessage);

      await expect(searchCities(mockHttpClient, { name: "Test" }))
        .rejects
        .toThrow("Failed to search cities");
    });

    it("should handle errors without status code or message", async () => {
      const minimalError = {
        response: { error: "Unknown error" },
      };
      vi.mocked(mockHttpClient.get).mockRejectedValue(minimalError);

      await expect(searchCities(mockHttpClient, { name: "Test" }))
        .rejects
        .toThrow("Failed to search cities");
    });

    it("should handle errors without any properties", async () => {
      const emptyError = {};
      vi.mocked(mockHttpClient.get).mockRejectedValue(emptyError);

      await expect(searchCities(mockHttpClient, { name: "Test" }))
        .rejects
        .toThrow("Failed to search cities");
    });
  });

  describe("error propagation", () => {
    it("should re-throw known SetlistFM errors without modification", async () => {
      const knownErrors = [
        new NotFoundError("cities", "search"),
        new AuthenticationError("Invalid API key"),
        new SetlistFMAPIError("Rate limit exceeded", 429),
        new ValidationError("Invalid parameter"),
      ];

      for (const error of knownErrors) {
        vi.mocked(mockHttpClient.get).mockRejectedValue(error);

        await expect(searchCities(mockHttpClient, { name: "Test" }))
          .rejects
          .toThrow(error);
      }
    });

    it("should transform unknown errors to SetlistFM errors", async () => {
      const unknownError = new TypeError("Cannot read property 'data' of undefined");
      vi.mocked(mockHttpClient.get).mockRejectedValue(unknownError);

      await expect(searchCities(mockHttpClient, { name: "Test" }))
        .rejects
        .toThrow("Cannot read property 'data' of undefined");
    });
  });

  describe("endpoint construction", () => {
    it("should construct correct endpoint URL", async () => {
      vi.mocked(mockHttpClient.get).mockResolvedValue(mockCitiesResponse);

      await searchCities(mockHttpClient, { name: "Test" });
      expect(mockHttpClient.get).toHaveBeenCalledWith("/search/cities", { name: "Test" });
    });

    it("should pass parameters correctly to httpClient", async () => {
      vi.mocked(mockHttpClient.get).mockResolvedValue(mockCitiesResponse);

      const searchParams: SearchCitiesParams = {
        name: "Hollywood",
        country: "US",
        state: "California",
        stateCode: "CA",
        p: 2,
      };

      await searchCities(mockHttpClient, searchParams);
      expect(mockHttpClient.get).toHaveBeenCalledWith("/search/cities", searchParams);
    });

    it("should validate parameters before making HTTP request", async () => {
      // Should not call httpClient.get for invalid parameters
      await expect(searchCities(mockHttpClient, { p: -1 }))
        .rejects
        .toThrow(ValidationError);

      expect(mockHttpClient.get).not.toHaveBeenCalled();
    });
  });

  describe("parameter combinations", () => {
    it("should handle all valid parameter combinations", async () => {
      vi.mocked(mockHttpClient.get).mockResolvedValue(mockCitiesResponse);

      const paramCombinations = [
        { name: "Test" },
        { country: "US" },
        { state: "California" },
        { stateCode: "CA" },
        { name: "Test", country: "US" },
        { country: "US", state: "California" },
        { state: "California", stateCode: "CA" },
        { name: "Test", country: "US", state: "California", stateCode: "CA" },
        { name: "Test", p: 2 },
        { country: "US", p: 3 },
      ];

      for (const params of paramCombinations) {
        const result = await searchCities(mockHttpClient, params);
        expect(result).toEqual(mockCitiesResponse);
        expect(mockHttpClient.get).toHaveBeenCalledWith("/search/cities", params);
      }
    });
  });
});
