/**
 * @file endpoints.test.ts
 * @description Test suite for main endpoints index exports.
 * @author tkozzer
 * @module endpoints
 */

import { describe, expect, it } from "vitest";

describe("endpoints index exports", () => {
  it("should export all venue functions and types", async () => {
    const endpointsModule = await import("../index.js");

    // Test venue function exports
    expect(typeof endpointsModule.getVenue).toBe("function");
    expect(typeof endpointsModule.getVenueSetlists).toBe("function");
    expect(typeof endpointsModule.searchVenues).toBe("function");

    // Test venue validation schema exports
    expect(endpointsModule.VenueIdParamSchema).toBeDefined();
    expect(endpointsModule.VenueSchema).toBeDefined();
    expect(endpointsModule.VenuesSchema).toBeDefined();
  });

  it("should export all setlist functions and types", async () => {
    const endpointsModule = await import("../index.js");

    // Test setlist function exports
    expect(typeof endpointsModule.getSetlist).toBe("function");
    expect(typeof endpointsModule.searchSetlists).toBe("function");

    // Test setlist validation schema exports
    expect(endpointsModule.SetlistIdSchema).toBeDefined();
    expect(endpointsModule.SetlistSchema).toBeDefined();
    expect(endpointsModule.SetlistsSchema).toBeDefined();
  });

  it("should export all artist functions and types", async () => {
    const endpointsModule = await import("../index.js");

    // Test artist function exports
    expect(typeof endpointsModule.getArtist).toBe("function");
    expect(typeof endpointsModule.getArtistSetlists).toBe("function");
    expect(typeof endpointsModule.searchArtists).toBe("function");

    // Test artist validation schema exports
    expect(endpointsModule.ArtistSchema).toBeDefined();
    expect(endpointsModule.ArtistsSchema).toBeDefined();
  });

  it("should export all city functions and types", async () => {
    const endpointsModule = await import("../index.js");

    // Test city function exports
    expect(typeof endpointsModule.getCityByGeoId).toBe("function");
    expect(typeof endpointsModule.searchCities).toBe("function");

    // Test city validation schema exports
    expect(endpointsModule.CitySchema).toBeDefined();
    expect(endpointsModule.CitiesSchema).toBeDefined();
  });

  it("should export all country functions and types", async () => {
    const endpointsModule = await import("../index.js");

    // Test country function exports
    expect(typeof endpointsModule.searchCountries).toBe("function");

    // Test country validation schema exports (primary source)
    expect(endpointsModule.CountrySchema).toBeDefined();
    expect(endpointsModule.CountriesSchema).toBeDefined();
  });

  it("should not have naming conflicts", async () => {
    const endpointsModule = await import("../index.js");

    // Test that we have the expected exports without conflicts
    const exportNames = Object.keys(endpointsModule);

    // Should have unique exports for each endpoint type
    expect(exportNames).toContain("getVenue");
    expect(exportNames).toContain("getSetlist");
    expect(exportNames).toContain("getArtist");
    expect(exportNames).toContain("getCityByGeoId");
    expect(exportNames).toContain("searchCountries");

    // Should have schemas from all modules
    expect(exportNames).toContain("VenueSchema");
    expect(exportNames).toContain("SetlistSchema");
    expect(exportNames).toContain("ArtistSchema");
    expect(exportNames).toContain("CitySchema");
    expect(exportNames).toContain("CountrySchema"); // from countries (primary source)
  });
});
