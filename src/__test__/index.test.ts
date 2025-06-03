/**
 * @file index.test.ts
 * @description Tests for the main library exports.
 * @author tkozzer
 * @module index
 */

import { describe, expect, it } from "vitest";

describe("Library Exports", () => {
  it("should export client functions and types", async () => {
    const { createSetlistFMClient, SetlistFMClient } = await import("../index.js");

    expect(createSetlistFMClient).toBeDefined();
    expect(typeof createSetlistFMClient).toBe("function");
    expect(SetlistFMClient).toBeDefined();
    expect(typeof SetlistFMClient).toBe("function");
  });

  it("should export HTTP utilities", async () => {
    const { SetlistFMError, HttpClient, API_BASE_URL, DEFAULT_TIMEOUT } = await import("../index.js");

    expect(SetlistFMError).toBeDefined();
    expect(HttpClient).toBeDefined();
    expect(API_BASE_URL).toBeDefined();
    expect(DEFAULT_TIMEOUT).toBeDefined();
  });

  it("should export rate limiting utilities", async () => {
    const { RateLimiter, RateLimitProfile } = await import("../index.js");

    expect(RateLimiter).toBeDefined();
    expect(RateLimitProfile).toBeDefined();
    expect(typeof RateLimitProfile.STANDARD).toBe("string");
    expect(typeof RateLimitProfile.PREMIUM).toBe("string");
    expect(typeof RateLimitProfile.DISABLED).toBe("string");
  });

  it("should export shared utilities", async () => {
    const exports = await import("../index.js");

    // Check some shared utilities are exported
    expect(exports.extractPaginationInfo).toBeDefined();
    expect(exports.createErrorFromResponse).toBeDefined();
    expect(exports.createLogger).toBeDefined();
  });

  it("should export types from shared module", async () => {
    // This tests that the export * from './shared' works
    const exports = await import("../index.js");

    // Even though these are types, we can check that the module exports them
    // by checking if the values that depend on them are exported
    expect(exports.LogLevel).toBeDefined();
  });
});
