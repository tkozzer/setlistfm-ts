/**
 * @file countries.test.ts
 * @description Test suite for countries endpoint functionality.
 * @author tkozzer
 * @module Countries
 */

import type { HttpClient } from "@utils/http";

import type { Countries, Country, SearchCountriesParams } from "./types";

import { AuthenticationError, NotFoundError, SetlistFMAPIError, ValidationError } from "@shared/error";

import { beforeEach, describe, expect, it, vi } from "vitest";

import { searchCountries } from "./searchCountries";

import {
  CountriesSchema,
  CountryCodeSchema,
  CountrySchema,
  SearchCountriesParamsSchema,
} from "./validation";

// Test index.ts exports
describe("index exports", () => {
  it("should export all country functions and types", async () => {
    const indexModule = await import("./index.js");

    // Test function exports
    expect(typeof indexModule.searchCountries).toBe("function");

    // Test validation schema exports
    expect(indexModule.CountryCodeSchema).toBeDefined();
    expect(indexModule.CountrySchema).toBeDefined();
    expect(indexModule.CountriesSchema).toBeDefined();
    expect(indexModule.SearchCountriesParamsSchema).toBeDefined();
  });
});

describe("countries types and validation", () => {
  describe("CountryCodeSchema", () => {
    it("should validate valid country codes", () => {
      expect(() => CountryCodeSchema.parse("US")).not.toThrow();
      expect(() => CountryCodeSchema.parse("GB")).not.toThrow();
      expect(() => CountryCodeSchema.parse("DE")).not.toThrow();
      expect(() => CountryCodeSchema.parse("CA")).not.toThrow();
      expect(() => CountryCodeSchema.parse("FR")).not.toThrow();
      expect(() => CountryCodeSchema.parse("IT")).not.toThrow();
      expect(() => CountryCodeSchema.parse("JP")).not.toThrow();
      expect(() => CountryCodeSchema.parse("AU")).not.toThrow();
    });

    it("should reject invalid country codes", () => {
      const invalidCodes = [
        "usa", // lowercase
        "U", // too short
        "USA", // too long
        "123", // numbers
        "us", // lowercase
        "gb", // lowercase
        "U1", // mixed alphanumeric
        "1S", // number first
        "U-", // special characters
        "U S", // space
        "", // empty
        "   ", // whitespace only
      ];

      for (const code of invalidCodes) {
        expect(() => CountryCodeSchema.parse(code)).toThrow();
      }
    });

    it("should reject non-string types", () => {
      expect(() => CountryCodeSchema.parse(123)).toThrow();
      expect(() => CountryCodeSchema.parse(null)).toThrow();
      expect(() => CountryCodeSchema.parse(undefined)).toThrow();
      expect(() => CountryCodeSchema.parse({})).toThrow();
      expect(() => CountryCodeSchema.parse([])).toThrow();
    });
  });

  describe("CountrySchema", () => {
    it("should validate valid country objects", () => {
      const validCountries: Country[] = [
        { code: "US", name: "United States" },
        { code: "GB", name: "United Kingdom" },
        { code: "DE", name: "Germany" },
        { code: "FR", name: "France" },
        { code: "CA", name: "Canada" },
        { code: "AU", name: "Australia" },
        { code: "JP", name: "Japan" },
      ];

      for (const country of validCountries) {
        expect(() => CountrySchema.parse(country)).not.toThrow();
      }
    });

    it("should validate country with special characters in name", () => {
      const countriesWithSpecialChars: Country[] = [
        { code: "CI", name: "Côte d'Ivoire" },
        { code: "CF", name: "Central African Republic" },
        { code: "BF", name: "Burkina Faso" },
        { code: "BA", name: "Bosnia and Herzegovina" },
        { code: "TT", name: "Trinidad & Tobago" },
      ];

      for (const country of countriesWithSpecialChars) {
        expect(() => CountrySchema.parse(country)).not.toThrow();
      }
    });

    it("should reject invalid country objects", () => {
      const invalidCountries = [
        { code: "usa", name: "United States" }, // invalid code
        { code: "US", name: "" }, // empty name
        { code: "US" }, // missing name
        { name: "United States" }, // missing code
        { code: "", name: "United States" }, // empty code
        { code: "U", name: "United States" }, // code too short
        { code: "USA", name: "United States" }, // code too long
        { code: "US", name: "   " }, // whitespace only name
        {}, // empty object
      ];

      for (const country of invalidCountries) {
        expect(() => CountrySchema.parse(country)).toThrow();
      }
    });

    it("should reject non-object types", () => {
      const invalidTypes = [
        "US",
        123,
        null,
        undefined,
        [],
        "string",
        true,
      ];

      for (const invalid of invalidTypes) {
        expect(() => CountrySchema.parse(invalid)).toThrow();
      }
    });
  });

  describe("CountriesSchema", () => {
    it("should validate valid countries response", () => {
      const validCountries: Countries = {
        country: [
          { code: "US", name: "United States" },
          { code: "GB", name: "United Kingdom" },
          { code: "DE", name: "Germany" },
        ],
        total: 3,
        page: 1,
        itemsPerPage: 20,
      };
      expect(() => CountriesSchema.parse(validCountries)).not.toThrow();
    });

    it("should validate countries response with empty array", () => {
      const emptyCountries: Countries = {
        country: [],
        total: 0,
        page: 1,
        itemsPerPage: 20,
      };
      expect(() => CountriesSchema.parse(emptyCountries)).not.toThrow();
    });

    it("should validate countries response with pagination", () => {
      const paginatedCountries: Countries = {
        country: [
          { code: "US", name: "United States" },
        ],
        total: 195,
        page: 5,
        itemsPerPage: 50,
      };
      expect(() => CountriesSchema.parse(paginatedCountries)).not.toThrow();
    });

    it("should reject invalid countries response", () => {
      const invalidResponses = [
        { country: [] }, // missing required fields
        {
          country: [{ code: "US", name: "United States" }],
          total: -1, // negative total
          page: 1,
          itemsPerPage: 20,
        },
        {
          country: [{ code: "US", name: "United States" }],
          total: 1,
          page: 0, // page less than 1
          itemsPerPage: 20,
        },
        {
          country: [{ code: "US", name: "United States" }],
          total: 1,
          page: 1,
          itemsPerPage: 0, // itemsPerPage less than 1
        },
        {
          country: [{ code: "usa", name: "United States" }], // invalid country
          total: 1,
          page: 1,
          itemsPerPage: 20,
        },
        {
          country: "not an array", // country should be array
          total: 1,
          page: 1,
          itemsPerPage: 20,
        },
      ];

      for (const response of invalidResponses) {
        expect(() => CountriesSchema.parse(response)).toThrow();
      }
    });

    it("should reject non-object types", () => {
      const invalidTypes = [
        "string",
        123,
        null,
        undefined,
        [],
        true,
      ];

      for (const invalid of invalidTypes) {
        expect(() => CountriesSchema.parse(invalid)).toThrow();
      }
    });
  });

  describe("SearchCountriesParamsSchema", () => {
    it("should validate empty search params", () => {
      const params: SearchCountriesParams = {};
      expect(() => SearchCountriesParamsSchema.parse(params)).not.toThrow();
    });

    it("should reject non-empty objects", () => {
      const invalidParams = [
        { name: "test" },
        { country: "US" },
        { p: 1 },
        { randomField: "value" },
      ];

      for (const params of invalidParams) {
        expect(() => SearchCountriesParamsSchema.parse(params)).toThrow();
      }
    });

    it("should reject non-object types", () => {
      const invalidTypes = [
        "string",
        123,
        null,
        undefined,
        [],
        true,
      ];

      for (const invalid of invalidTypes) {
        expect(() => SearchCountriesParamsSchema.parse(invalid)).toThrow();
      }
    });
  });
});

describe("searchCountries", () => {
  let mockHttpClient: HttpClient;

  const mockCountry: Country = {
    code: "US",
    name: "United States",
  };

  const mockCountriesResponse: Countries = {
    country: [mockCountry],
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
    it("should return countries for default empty parameters", async () => {
      vi.mocked(mockHttpClient.get).mockResolvedValue(mockCountriesResponse);

      const result = await searchCountries(mockHttpClient);

      expect(result).toEqual(mockCountriesResponse);
      expect(mockHttpClient.get).toHaveBeenCalledWith("/search/countries", {});
    });

    it("should return countries for explicit empty parameters", async () => {
      vi.mocked(mockHttpClient.get).mockResolvedValue(mockCountriesResponse);

      const result = await searchCountries(mockHttpClient, {});

      expect(result).toEqual(mockCountriesResponse);
      expect(mockHttpClient.get).toHaveBeenCalledWith("/search/countries", {});
    });

    it("should handle multiple countries in response", async () => {
      const multipleCountriesResponse: Countries = {
        country: [
          { code: "US", name: "United States" },
          { code: "GB", name: "United Kingdom" },
          { code: "DE", name: "Germany" },
          { code: "FR", name: "France" },
          { code: "CA", name: "Canada" },
        ],
        total: 5,
        page: 1,
        itemsPerPage: 20,
      };

      vi.mocked(mockHttpClient.get).mockResolvedValue(multipleCountriesResponse);

      const result = await searchCountries(mockHttpClient, {});

      expect(result).toEqual(multipleCountriesResponse);
      expect(result.country).toHaveLength(5);
      expect(result.total).toBe(5);
    });

    it("should handle paginated response", async () => {
      const paginatedResponse: Countries = {
        country: [
          { code: "AD", name: "Andorra" },
          { code: "AE", name: "United Arab Emirates" },
        ],
        total: 195,
        page: 2,
        itemsPerPage: 50,
      };

      vi.mocked(mockHttpClient.get).mockResolvedValue(paginatedResponse);

      const result = await searchCountries(mockHttpClient, {});

      expect(result).toEqual(paginatedResponse);
      expect(result.page).toBe(2);
      expect(result.total).toBe(195);
      expect(result.itemsPerPage).toBe(50);
    });

    it("should handle empty countries response", async () => {
      const emptyResponse: Countries = {
        country: [],
        total: 0,
        page: 1,
        itemsPerPage: 20,
      };

      vi.mocked(mockHttpClient.get).mockResolvedValue(emptyResponse);

      const result = await searchCountries(mockHttpClient, {});

      expect(result).toEqual(emptyResponse);
      expect(result.country).toHaveLength(0);
      expect(result.total).toBe(0);
    });

    it("should handle countries with localized names", async () => {
      const localizedResponse: Countries = {
        country: [
          { code: "DE", name: "Deutschland" },
          { code: "ES", name: "España" },
          { code: "FR", name: "France" },
          { code: "IT", name: "Italia" },
        ],
        total: 4,
        page: 1,
        itemsPerPage: 20,
      };

      vi.mocked(mockHttpClient.get).mockResolvedValue(localizedResponse);

      const result = await searchCountries(mockHttpClient, {});

      expect(result).toEqual(localizedResponse);
      expect(result.country.find(c => c.code === "DE")?.name).toBe("Deutschland");
      expect(result.country.find(c => c.code === "ES")?.name).toBe("España");
    });
  });

  describe("validation errors", () => {
    it("should throw ValidationError for invalid parameter object", async () => {
      const invalidParams = [
        { name: "test" },
        { country: "US" },
        { p: 1 },
        { invalidField: "value" },
      ];

      for (const params of invalidParams) {
        await expect(searchCountries(mockHttpClient, params as any))
          .rejects
          .toThrow(ValidationError);

        await expect(searchCountries(mockHttpClient, params as any))
          .rejects
          .toThrow("Invalid search parameters");
      }
    });

    it("should throw ValidationError for non-object parameters", async () => {
      const invalidTypes = [
        "string",
        123,
        null,
        [],
        true,
      ];

      for (const invalid of invalidTypes) {
        await expect(searchCountries(mockHttpClient, invalid as any))
          .rejects
          .toThrow(ValidationError);
      }
    });

    it("should validate parameters before making HTTP request", async () => {
      // Should not call httpClient.get for invalid parameters
      await expect(searchCountries(mockHttpClient, { invalid: "param" } as any))
        .rejects
        .toThrow(ValidationError);

      expect(mockHttpClient.get).not.toHaveBeenCalled();
    });
  });

  describe("HTTP errors", () => {
    it("should handle 404 Not Found error", async () => {
      const notFoundError = new NotFoundError("countries", "search query");
      vi.mocked(mockHttpClient.get).mockRejectedValue(notFoundError);

      await expect(searchCountries(mockHttpClient, {}))
        .rejects
        .toThrow(NotFoundError);

      await expect(searchCountries(mockHttpClient, {}))
        .rejects
        .toThrow("countries with identifier 'search query' not found");
    });

    it("should handle 401 Authentication error", async () => {
      const authError = new AuthenticationError("Invalid API key");
      vi.mocked(mockHttpClient.get).mockRejectedValue(authError);

      await expect(searchCountries(mockHttpClient, {}))
        .rejects
        .toThrow(AuthenticationError);

      await expect(searchCountries(mockHttpClient, {}))
        .rejects
        .toThrow("Invalid API key");
    });

    it("should handle SetlistFM API errors", async () => {
      const apiError = new SetlistFMAPIError("API rate limit exceeded", 429);
      vi.mocked(mockHttpClient.get).mockRejectedValue(apiError);

      await expect(searchCountries(mockHttpClient, {}))
        .rejects
        .toThrow(SetlistFMAPIError);

      await expect(searchCountries(mockHttpClient, {}))
        .rejects
        .toThrow("API rate limit exceeded");
    });

    it("should handle unexpected errors", async () => {
      const unexpectedError = new Error("Network error");
      vi.mocked(mockHttpClient.get).mockRejectedValue(unexpectedError);

      await expect(searchCountries(mockHttpClient, {}))
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

      await expect(searchCountries(mockHttpClient, {}))
        .rejects
        .toThrow("Internal server error");
    });

    it("should handle errors without status code (fallback to 500)", async () => {
      const errorWithoutStatus = {
        message: "Connection failed",
        response: { error: "Network failure" },
      };
      vi.mocked(mockHttpClient.get).mockRejectedValue(errorWithoutStatus);

      await expect(searchCountries(mockHttpClient, {}))
        .rejects
        .toThrow("Connection failed");
    });

    it("should handle errors without message (fallback to default)", async () => {
      const errorWithoutMessage = {
        statusCode: 503,
        response: { error: "Service unavailable" },
      };
      vi.mocked(mockHttpClient.get).mockRejectedValue(errorWithoutMessage);

      await expect(searchCountries(mockHttpClient, {}))
        .rejects
        .toThrow("Failed to search countries");
    });

    it("should handle errors without status code or message", async () => {
      const minimalError = {
        response: { error: "Unknown error" },
      };
      vi.mocked(mockHttpClient.get).mockRejectedValue(minimalError);

      await expect(searchCountries(mockHttpClient, {}))
        .rejects
        .toThrow("Failed to search countries");
    });

    it("should handle errors without any properties", async () => {
      const emptyError = {};
      vi.mocked(mockHttpClient.get).mockRejectedValue(emptyError);

      await expect(searchCountries(mockHttpClient, {}))
        .rejects
        .toThrow("Failed to search countries");
    });
  });

  describe("error propagation", () => {
    it("should re-throw known SetlistFM errors without modification", async () => {
      const knownErrors = [
        new NotFoundError("countries", "search"),
        new AuthenticationError("Invalid API key"),
        new SetlistFMAPIError("Rate limit exceeded", 429),
        new ValidationError("Invalid parameter"),
      ];

      for (const error of knownErrors) {
        vi.mocked(mockHttpClient.get).mockRejectedValue(error);

        await expect(searchCountries(mockHttpClient, {}))
          .rejects
          .toThrow(error);
      }
    });

    it("should transform unknown errors to SetlistFM errors", async () => {
      const unknownError = new TypeError("Cannot read property 'data' of undefined");
      vi.mocked(mockHttpClient.get).mockRejectedValue(unknownError);

      await expect(searchCountries(mockHttpClient, {}))
        .rejects
        .toThrow("Cannot read property 'data' of undefined");
    });
  });

  describe("endpoint construction", () => {
    it("should construct correct endpoint URL", async () => {
      vi.mocked(mockHttpClient.get).mockResolvedValue(mockCountriesResponse);

      await searchCountries(mockHttpClient, {});

      expect(mockHttpClient.get).toHaveBeenCalledWith("/search/countries", {});
    });

    it("should always use empty parameters object", async () => {
      vi.mocked(mockHttpClient.get).mockResolvedValue(mockCountriesResponse);

      // Test multiple calls to ensure consistency
      await searchCountries(mockHttpClient);
      await searchCountries(mockHttpClient, {});

      expect(mockHttpClient.get).toHaveBeenNthCalledWith(1, "/search/countries", {});
      expect(mockHttpClient.get).toHaveBeenNthCalledWith(2, "/search/countries", {});
    });
  });

  describe("response data integrity", () => {
    it("should return response data without modification", async () => {
      const originalResponse = {
        country: [
          { code: "US", name: "United States" },
          { code: "CA", name: "Canada" },
        ],
        total: 2,
        page: 1,
        itemsPerPage: 20,
      };

      vi.mocked(mockHttpClient.get).mockResolvedValue(originalResponse);

      const result = await searchCountries(mockHttpClient, {});

      expect(result).toEqual(originalResponse);
      expect(result).toBe(originalResponse); // Should be the exact same object reference
    });

    it("should preserve all country properties", async () => {
      const complexResponse: Countries = {
        country: [
          { code: "US", name: "United States of America" },
          { code: "GB", name: "United Kingdom of Great Britain and Northern Ireland" },
          { code: "CI", name: "Côte d'Ivoire" },
        ],
        total: 195,
        page: 1,
        itemsPerPage: 50,
      };

      vi.mocked(mockHttpClient.get).mockResolvedValue(complexResponse);

      const result = await searchCountries(mockHttpClient, {});

      expect(result.country).toHaveLength(3);
      expect(result.country[0]).toEqual({ code: "US", name: "United States of America" });
      expect(result.country[1]).toEqual({ code: "GB", name: "United Kingdom of Great Britain and Northern Ireland" });
      expect(result.country[2]).toEqual({ code: "CI", name: "Côte d'Ivoire" });
      expect(result.total).toBe(195);
      expect(result.page).toBe(1);
      expect(result.itemsPerPage).toBe(50);
    });
  });
});
