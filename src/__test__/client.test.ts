/**
 * @file client.test.ts
 * @description Tests for the SetlistFM client.
 * @author tkozzer
 * @module client
 */

import type { SetlistFMClientPublic } from "@/client.types";

import { RateLimitProfile } from "@utils/rateLimiter";
import { describe, expect, it, vi } from "vitest";
import { createSetlistFMClient, SetlistFMClient } from "@/client";

// Mock the endpoint functions to avoid actual HTTP calls in coverage tests
vi.mock("@/endpoints/artists", () => ({
  searchArtists: vi.fn().mockResolvedValue({ artist: [], total: 0, page: 1, itemsPerPage: 20 }),
  getArtist: vi.fn().mockResolvedValue({ mbid: "test", name: "Test Artist", sortName: "Artist, Test" }),
  getArtistSetlists: vi.fn().mockResolvedValue({ setlist: [], total: 0, page: 1, itemsPerPage: 20 }),
}));

vi.mock("@/endpoints/setlists", () => ({
  getSetlist: vi.fn().mockResolvedValue({ id: "test", artist: {}, venue: {}, eventDate: "2023-01-01", sets: { set: [] } }),
  searchSetlists: vi.fn().mockResolvedValue({ setlist: [], total: 0, page: 1, itemsPerPage: 20 }),
}));

vi.mock("@/endpoints/venues", () => ({
  getVenue: vi.fn().mockResolvedValue({ id: "test", name: "Test Venue", url: "test" }),
  searchVenues: vi.fn().mockResolvedValue({ venue: [], total: 0, page: 1, itemsPerPage: 20 }),
  getVenueSetlists: vi.fn().mockResolvedValue({ setlist: [], total: 0, page: 1, itemsPerPage: 20 }),
}));

vi.mock("@/endpoints/cities", () => ({
  searchCities: vi.fn().mockResolvedValue({ cities: [], total: 0, page: 1, itemsPerPage: 20 }),
  getCityByGeoId: vi.fn().mockResolvedValue({ id: "test", name: "Test City", country: { code: "US", name: "United States" }, coords: { lat: 0, long: 0 } }),
}));

vi.mock("@/endpoints/countries", () => ({
  searchCountries: vi.fn().mockResolvedValue({ country: [], total: 0, page: 1, itemsPerPage: 20 }),
}));

describe("SetlistFM Client", () => {
  const validConfig = {
    apiKey: "test-api-key",
    userAgent: "test-app (test@example.com)",
  };

  describe("createSetlistFMClient", () => {
    it("should create a client with valid configuration", () => {
      const client = createSetlistFMClient(validConfig);
      expect(client).toBeInstanceOf(SetlistFMClient);

      // Test that the factory function returns the public interface type
      const publicClient: SetlistFMClientPublic = client;
      expect(publicClient).toBeDefined();
    });

    it("should throw an error when API key is missing", () => {
      expect(() => {
        createSetlistFMClient({
          apiKey: "",
          userAgent: "test-app (test@example.com)",
        });
      }).toThrow("API key is required");
    });

    it("should throw an error when user agent is missing", () => {
      expect(() => {
        createSetlistFMClient({
          apiKey: "test-api-key",
          userAgent: "",
        });
      }).toThrow("User agent is required");
    });

    it("should accept optional configuration parameters", () => {
      const client = createSetlistFMClient({
        ...validConfig,
        timeout: 5000,
        language: "es",
      });
      expect(client).toBeInstanceOf(SetlistFMClient);
    });

    it("should accept rate limiting configuration", () => {
      const client = createSetlistFMClient({
        ...validConfig,
        rateLimit: {
          profile: RateLimitProfile.STANDARD,
        },
      });
      expect(client).toBeInstanceOf(SetlistFMClient);

      const rateLimitStatus = client.getRateLimitStatus();
      expect(rateLimitStatus).toBeDefined();
      expect(rateLimitStatus?.profile).toBe(RateLimitProfile.STANDARD);
    });
  });

  describe("SetlistFMClient instance", () => {
    const client = createSetlistFMClient(validConfig);

    it("should have utility methods", () => {
      expect(typeof client.setLanguage).toBe("function");
      // Should not throw when called
      client.setLanguage("fr");

      expect(typeof client.getBaseUrl).toBe("function");
      const baseUrl = client.getBaseUrl();
      expect(typeof baseUrl).toBe("string");
      expect(baseUrl).toContain("setlist.fm");

      expect(typeof client.getHttpClient).toBe("function");
      const httpClient = client.getHttpClient();
      expect(httpClient).toBeDefined();

      expect(typeof client.getRateLimitStatus).toBe("function");
      const rateLimitStatus = client.getRateLimitStatus();
      expect(rateLimitStatus).toBeDefined();
    });

    it("should have artist endpoint methods", () => {
      expect(typeof client.searchArtists).toBe("function");
      expect(typeof client.getArtist).toBe("function");
      expect(typeof client.getArtistSetlists).toBe("function");
    });

    it("should have setlist endpoint methods", () => {
      expect(typeof client.getSetlist).toBe("function");
      expect(typeof client.searchSetlists).toBe("function");
    });

    it("should have venue endpoint methods", () => {
      expect(typeof client.getVenue).toBe("function");
      expect(typeof client.searchVenues).toBe("function");
      expect(typeof client.getVenueSetlists).toBe("function");
    });

    it("should have city endpoint methods", () => {
      expect(typeof client.searchCities).toBe("function");
      expect(typeof client.getCityByGeoId).toBe("function");
    });

    it("should have country endpoint methods", () => {
      expect(typeof client.searchCountries).toBe("function");
    });
  });

  describe("SetlistFMClient endpoint method calls", () => {
    const client = createSetlistFMClient(validConfig);

    it("should call artist endpoint methods successfully", async () => {
      await expect(client.searchArtists({ artistName: "Test" })).resolves.toBeDefined();
      await expect(client.getArtist("test-mbid")).resolves.toBeDefined();
      await expect(client.getArtistSetlists("test-mbid")).resolves.toBeDefined();
      await expect(client.getArtistSetlists("test-mbid", 2)).resolves.toBeDefined();
    });

    it("should call setlist endpoint methods successfully", async () => {
      await expect(client.getSetlist("test-id")).resolves.toBeDefined();
      await expect(client.searchSetlists({ artistName: "Test" })).resolves.toBeDefined();
    });

    it("should call venue endpoint methods successfully", async () => {
      await expect(client.getVenue("test-id")).resolves.toBeDefined();
      await expect(client.searchVenues({ name: "Test" })).resolves.toBeDefined();
      await expect(client.getVenueSetlists("test-id")).resolves.toBeDefined();
    });

    it("should call city endpoint methods successfully", async () => {
      await expect(client.searchCities({ name: "Test" })).resolves.toBeDefined();
      await expect(client.getCityByGeoId("test-id")).resolves.toBeDefined();
    });

    it("should call country endpoint methods successfully", async () => {
      await expect(client.searchCountries()).resolves.toBeDefined();
    });
  });
});
