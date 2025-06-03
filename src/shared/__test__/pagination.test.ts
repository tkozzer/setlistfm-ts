/**
 * @file pagination.test.ts
 * @description Tests for pagination utilities.
 * @author tkozzer
 * @module shared/pagination
 */

import { describe, expect, it } from "vitest";

import type { ExtendedPaginationParams, PaginationInfo } from "../pagination";
import type { PaginatedResponse } from "../types";

import {
  delay,
  extractPaginationInfo,
  getNextPageParams,
  getPrevPageParams,
  validatePaginationParams,
} from "../pagination";

describe("Pagination Utilities", () => {
  describe("extractPaginationInfo", () => {
    it("should extract pagination info from response", () => {
      const response: PaginatedResponse<any> = {
        page: 2,
        total: 150,
        itemsPerPage: 25,
        data: [],
      };

      const result = extractPaginationInfo(response);

      expect(result).toEqual({
        currentPage: 2,
        totalItems: 150,
        itemsPerPage: 25,
        totalPages: 6,
        hasNextPage: true,
        hasPrevPage: true,
      });
    });

    it("should handle first page correctly", () => {
      const response: PaginatedResponse<any> = {
        page: 1,
        total: 50,
        itemsPerPage: 10,
        data: [],
      };

      const result = extractPaginationInfo(response);

      expect(result).toEqual({
        currentPage: 1,
        totalItems: 50,
        itemsPerPage: 10,
        totalPages: 5,
        hasNextPage: true,
        hasPrevPage: false,
      });
    });

    it("should handle last page correctly", () => {
      const response: PaginatedResponse<any> = {
        page: 5,
        total: 50,
        itemsPerPage: 10,
        data: [],
      };

      const result = extractPaginationInfo(response);

      expect(result).toEqual({
        currentPage: 5,
        totalItems: 50,
        itemsPerPage: 10,
        totalPages: 5,
        hasNextPage: false,
        hasPrevPage: true,
      });
    });

    it("should handle single page correctly", () => {
      const response: PaginatedResponse<any> = {
        page: 1,
        total: 5,
        itemsPerPage: 10,
        data: [],
      };

      const result = extractPaginationInfo(response);

      expect(result).toEqual({
        currentPage: 1,
        totalItems: 5,
        itemsPerPage: 10,
        totalPages: 1,
        hasNextPage: false,
        hasPrevPage: false,
      });
    });

    it("should handle empty results correctly", () => {
      const response: PaginatedResponse<any> = {
        page: 1,
        total: 0,
        itemsPerPage: 20,
        data: [],
      };

      const result = extractPaginationInfo(response);

      expect(result).toEqual({
        currentPage: 1,
        totalItems: 0,
        itemsPerPage: 20,
        totalPages: 0,
        hasNextPage: false,
        hasPrevPage: false,
      });
    });
  });

  describe("getNextPageParams", () => {
    it("should return next page params when next page exists", () => {
      const info: PaginationInfo = {
        currentPage: 2,
        totalItems: 150,
        itemsPerPage: 25,
        totalPages: 6,
        hasNextPage: true,
        hasPrevPage: true,
      };

      const result = getNextPageParams(info);

      expect(result).toEqual({ p: 3 });
    });

    it("should return null when no next page exists", () => {
      const info: PaginationInfo = {
        currentPage: 5,
        totalItems: 100,
        itemsPerPage: 20,
        totalPages: 5,
        hasNextPage: false,
        hasPrevPage: true,
      };

      const result = getNextPageParams(info);

      expect(result).toBeNull();
    });
  });

  describe("getPrevPageParams", () => {
    it("should return previous page params when previous page exists", () => {
      const info: PaginationInfo = {
        currentPage: 3,
        totalItems: 150,
        itemsPerPage: 25,
        totalPages: 6,
        hasNextPage: true,
        hasPrevPage: true,
      };

      const result = getPrevPageParams(info);

      expect(result).toEqual({ p: 2 });
    });

    it("should return null when no previous page exists", () => {
      const info: PaginationInfo = {
        currentPage: 1,
        totalItems: 100,
        itemsPerPage: 20,
        totalPages: 5,
        hasNextPage: true,
        hasPrevPage: false,
      };

      const result = getPrevPageParams(info);

      expect(result).toBeNull();
    });
  });

  describe("validatePaginationParams", () => {
    it("should not throw for valid parameters", () => {
      expect(() => validatePaginationParams({ p: 1 })).not.toThrow();
      expect(() => validatePaginationParams({ p: 5 })).not.toThrow();
      expect(() => validatePaginationParams({})).not.toThrow();
    });

    it("should throw for page number less than 1", () => {
      expect(() => validatePaginationParams({ p: 0 })).toThrow("Page number must be greater than 0");
      expect(() => validatePaginationParams({ p: -1 })).toThrow("Page number must be greater than 0");
    });

    it("should throw for non-integer page number", () => {
      expect(() => validatePaginationParams({ p: 1.5 })).toThrow("Page number must be an integer");
      expect(() => validatePaginationParams({ p: 2.7 })).toThrow("Page number must be an integer");
    });
  });

  describe("delay", () => {
    it("should resolve after specified time", async () => {
      const start = Date.now();
      await delay(50);
      const end = Date.now();

      expect(end - start).toBeGreaterThanOrEqual(45); // Allow some margin for timing
    });
  });

  describe("ExtendedPaginationParams type", () => {
    it("should extend basic pagination params", () => {
      // This is a type test - if it compiles, the type is working
      const params: ExtendedPaginationParams = {
        p: 1,
        maxPages: 10,
        delay: 500,
      };

      expect(params.p).toBe(1);
      expect(params.maxPages).toBe(10);
      expect(params.delay).toBe(500);
    });
  });
});
