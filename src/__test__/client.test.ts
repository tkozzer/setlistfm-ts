/**
 * @file client.test.ts
 * @description Tests for the SetlistFM client.
 * @author tkozzer
 * @module client
 */

import { RateLimitProfile } from "@utils/rateLimiter";

import { describe, expect, it } from "vitest";
import { createSetlistFMClient, SetlistFMClient } from "@/client";

describe("SetlistFM Client", () => {
  const validConfig = {
    apiKey: "test-api-key",
    userAgent: "test-app (test@example.com)",
  };

  describe("createSetlistFMClient", () => {
    it("should create a client with valid configuration", () => {
      const client = createSetlistFMClient(validConfig);
      expect(client).toBeInstanceOf(SetlistFMClient);
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

    it("should have a setLanguage method", () => {
      expect(typeof client.setLanguage).toBe("function");
      // Should not throw when called
      client.setLanguage("fr");
    });

    it("should have a getBaseUrl method", () => {
      expect(typeof client.getBaseUrl).toBe("function");
      const baseUrl = client.getBaseUrl();
      expect(typeof baseUrl).toBe("string");
      expect(baseUrl).toContain("setlist.fm");
    });

    it("should have a getHttpClient method", () => {
      expect(typeof client.getHttpClient).toBe("function");
      const httpClient = client.getHttpClient();
      expect(httpClient).toBeDefined();
    });
  });
});
