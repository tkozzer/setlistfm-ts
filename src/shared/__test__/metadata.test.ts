/**
 * @file metadata.test.ts
 * @description Tests for metadata utilities.
 * @author tkozzer
 * @module shared/metadata
 */

import { describe, expect, it } from "vitest";

import type { LibraryInfo, ResponseMetadata } from "../metadata";

import {
  createResponseMetadata,
  getLibraryInfo,
} from "../metadata";

describe("Metadata Utilities", () => {
  describe("createResponseMetadata", () => {
    it("should create metadata with default API version", () => {
      const headers = {};

      const result = createResponseMetadata(headers);

      expect(result).toMatchObject({
        apiVersion: "1.0",
        timestamp: expect.any(String),
      });
      expect(result.requestId).toBeUndefined();
    });

    it("should create metadata with custom API version", () => {
      const headers = {};

      const result = createResponseMetadata(headers, "2.0");

      expect(result.apiVersion).toBe("2.0");
    });

    it("should include request ID when available in headers", () => {
      const headers = {
        "x-request-id": "req-123456",
      };

      const result = createResponseMetadata(headers);

      expect(result.requestId).toBe("req-123456");
    });

    it("should include all available metadata", () => {
      const headers = {
        "x-request-id": "req-789",
      };

      const result = createResponseMetadata(headers, "1.5");

      expect(result).toMatchObject({
        apiVersion: "1.5",
        requestId: "req-789",
        timestamp: expect.any(String),
      });
    });

    it("should generate valid ISO timestamp", () => {
      const headers = {};

      const result = createResponseMetadata(headers);

      // Check that timestamp is a valid ISO string
      expect(() => new Date(result.timestamp)).not.toThrow();
      expect(result.timestamp).toMatch(/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z$/);
    });
  });

  describe("getLibraryInfo", () => {
    it("should return library information", () => {
      const result = getLibraryInfo();

      expect(result).toEqual({
        name: "setlistfm-ts",
        version: "0.1.0",
        buildTime: undefined,
        commit: undefined,
      });
    });

    it("should return consistent library info", () => {
      const result1 = getLibraryInfo();
      const result2 = getLibraryInfo();

      expect(result1).toEqual(result2);
    });
  });

  describe("Type definitions", () => {
    it("should work with ResponseMetadata type", () => {
      const metadata: ResponseMetadata = {
        timestamp: "2023-01-01T00:00:00.000Z",
        apiVersion: "1.0",
        requestId: "req-123",
      };

      expect(metadata.timestamp).toBe("2023-01-01T00:00:00.000Z");
      expect(metadata.apiVersion).toBe("1.0");
      expect(metadata.requestId).toBe("req-123");
    });

    it("should work with ResponseMetadata type without optional fields", () => {
      const metadata: ResponseMetadata = {
        timestamp: "2023-01-01T00:00:00.000Z",
        apiVersion: "1.0",
      };

      expect(metadata.timestamp).toBe("2023-01-01T00:00:00.000Z");
      expect(metadata.apiVersion).toBe("1.0");
      expect(metadata.requestId).toBeUndefined();
    });

    it("should work with LibraryInfo type", () => {
      const libraryInfo: LibraryInfo = {
        name: "setlistfm-ts",
        version: "0.1.0",
        buildTime: "2023-01-01T00:00:00.000Z",
        commit: "abc123",
      };

      expect(libraryInfo.name).toBe("setlistfm-ts");
      expect(libraryInfo.version).toBe("0.1.0");
      expect(libraryInfo.buildTime).toBe("2023-01-01T00:00:00.000Z");
      expect(libraryInfo.commit).toBe("abc123");
    });

    it("should work with LibraryInfo type without optional fields", () => {
      const libraryInfo: LibraryInfo = {
        name: "setlistfm-ts",
        version: "0.1.0",
      };

      expect(libraryInfo.name).toBe("setlistfm-ts");
      expect(libraryInfo.version).toBe("0.1.0");
      expect(libraryInfo.buildTime).toBeUndefined();
      expect(libraryInfo.commit).toBeUndefined();
    });
  });
});
