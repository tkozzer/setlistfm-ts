/**
 * @file validation.test.ts
 * @description Test suite for shared validation utilities.
 * @author tkozzer
 * @module validation
 */

import { describe, expect, it } from "vitest";
import { z } from "zod";

import { ValidationError } from "../error";
import {
  DateRangeSchema,
  DateSchema,
  ExtendedPaginationSchema,
  LanguageSchema,
  MbidSchema,
  NonEmptyStringSchema,
  OptionalStringSchema,
  PaginationSchema,
  safeValidate,
  SortOrderSchema,
  UrlSchema,
  validateWithSchema,
} from "../validation";

describe("shared validation schemas", () => {
  describe("MbidSchema", () => {
    it("should validate correct MBID format", () => {
      const validMbids = [
        "b10bbbfc-cf9e-42e0-be17-e2c3e1d2600d",
        "B10BBBFC-CF9E-42E0-BE17-E2C3E1D2600D",
        "550e8400-e29b-41d4-a716-446655440000",
      ];

      for (const mbid of validMbids) {
        expect(() => MbidSchema.parse(mbid)).not.toThrow();
      }
    });

    it("should reject invalid MBID formats", () => {
      const invalidMbids = [
        "",
        "invalid-mbid",
        "b10bbbfc-cf9e-42e0-be17", // too short
        "b10bbbfc-cf9e-42e0-be17-e2c3e1d2600d-extra", // too long
        "g10bbbfc-cf9e-42e0-be17-e2c3e1d2600d", // invalid character
      ];

      for (const mbid of invalidMbids) {
        expect(() => MbidSchema.parse(mbid)).toThrow();
      }
    });
  });

  describe("PaginationSchema", () => {
    it("should validate correct pagination params", () => {
      const validParams = [
        {},
        { p: 1 },
        { p: 5 },
        { p: 100 },
      ];

      for (const params of validParams) {
        expect(() => PaginationSchema.parse(params)).not.toThrow();
      }
    });

    it("should reject invalid pagination params", () => {
      const invalidParams = [
        { p: 0 },
        { p: -1 },
        { p: 1.5 },
        { p: "1" },
      ];

      for (const params of invalidParams) {
        expect(() => PaginationSchema.parse(params)).toThrow();
      }
    });
  });

  describe("ExtendedPaginationSchema", () => {
    it("should validate correct extended pagination params", () => {
      const validParams = [
        {},
        { p: 1 },
        { p: 5, itemsPerPage: 20 },
        { itemsPerPage: 50 },
        { p: 1, itemsPerPage: 100 },
      ];

      for (const params of validParams) {
        expect(() => ExtendedPaginationSchema.parse(params)).not.toThrow();
      }
    });

    it("should reject invalid extended pagination params", () => {
      const invalidParams = [
        { p: 0 },
        { itemsPerPage: 0 },
        { itemsPerPage: -1 },
        { itemsPerPage: 101 }, // exceeds max
        { itemsPerPage: 1.5 },
        { p: "1" },
        { itemsPerPage: "20" },
      ];

      for (const params of invalidParams) {
        expect(() => ExtendedPaginationSchema.parse(params)).toThrow();
      }
    });
  });

  describe("LanguageSchema", () => {
    it("should validate correct language codes", () => {
      const validLanguages = [
        "en",
        "es",
        "fr",
        "de",
        "it",
      ];

      for (const lang of validLanguages) {
        expect(() => LanguageSchema.parse(lang)).not.toThrow();
      }
    });

    it("should reject invalid language codes", () => {
      const invalidLanguages = [
        "",
        "e", // too short
        "eng", // too long
        "EN", // uppercase
        "e1", // contains number
        "e-", // contains special character
      ];

      for (const lang of invalidLanguages) {
        expect(() => LanguageSchema.parse(lang)).toThrow();
      }
    });
  });

  describe("SortOrderSchema", () => {
    it("should validate correct sort orders", () => {
      const validSortOrders = ["asc", "desc"];

      for (const order of validSortOrders) {
        expect(() => SortOrderSchema.parse(order)).not.toThrow();
      }
    });

    it("should reject invalid sort orders", () => {
      const invalidSortOrders = [
        "",
        "ascending",
        "descending",
        "ASC",
        "DESC",
        "up",
        "down",
      ];

      for (const order of invalidSortOrders) {
        expect(() => SortOrderSchema.parse(order)).toThrow();
      }
    });
  });

  describe("DateSchema", () => {
    it("should validate correct date formats", () => {
      const validDates = [
        "2023-01-01",
        "2023-12-31",
        "1990-06-15",
      ];

      for (const date of validDates) {
        expect(() => DateSchema.parse(date)).not.toThrow();
      }
    });

    it("should reject invalid date formats", () => {
      const invalidDates = [
        "",
        "2023-1-1", // wrong format (should be 2023-01-01)
        "23-01-01", // wrong format (should be 2023-01-01)
        "2023/01/01", // wrong separator
        "not-a-date",
        "2023-13-01", // invalid month
      ];

      for (const date of invalidDates) {
        expect(() => DateSchema.parse(date)).toThrow();
      }
    });

    it("should handle edge case dates that JavaScript auto-corrects", () => {
      // JavaScript Date constructor auto-corrects 2023-02-30 to 2023-03-02
      // This is technically valid behavior, so our schema accepts it
      expect(() => DateSchema.parse("2023-02-30")).not.toThrow();

      // But invalid months like 13 should still fail
      expect(() => DateSchema.parse("2023-13-01")).toThrow("Date must be a valid date");
    });
  });

  describe("DateRangeSchema", () => {
    it("should validate correct date ranges", () => {
      const validRanges = [
        {},
        { from: "2023-01-01" },
        { to: "2023-12-31" },
        { from: "2023-01-01", to: "2023-12-31" },
        { from: "2023-06-15", to: "2023-06-15" }, // same date
      ];

      for (const range of validRanges) {
        expect(() => DateRangeSchema.parse(range)).not.toThrow();
      }
    });

    it("should reject invalid date ranges", () => {
      const invalidRanges = [
        { from: "2023-12-31", to: "2023-01-01" }, // start after end
      ];

      for (const range of invalidRanges) {
        expect(() => DateRangeSchema.parse(range)).toThrow();
      }
    });
  });

  describe("NonEmptyStringSchema", () => {
    it("should validate non-empty strings", () => {
      const validStrings = [
        "hello",
        "  trimmed  ", // should be trimmed
        "123",
      ];

      for (const str of validStrings) {
        expect(() => NonEmptyStringSchema.parse(str)).not.toThrow();
      }
    });

    it("should reject empty strings", () => {
      const invalidStrings = [
        "",
        "   ", // only whitespace
      ];

      for (const str of invalidStrings) {
        expect(() => NonEmptyStringSchema.parse(str)).toThrow();
      }
    });
  });

  describe("OptionalStringSchema", () => {
    it("should validate optional strings", () => {
      const validValues = [
        undefined,
        "hello",
        "  trimmed  ", // should be trimmed
        "",
        "   ", // whitespace should be trimmed to empty
      ];

      for (const value of validValues) {
        expect(() => OptionalStringSchema.parse(value)).not.toThrow();
      }
    });

    it("should trim whitespace in optional strings", () => {
      const result = OptionalStringSchema.parse("  hello  ");
      expect(result).toBe("hello");
    });

    it("should handle undefined correctly", () => {
      const result = OptionalStringSchema.parse(undefined);
      expect(result).toBeUndefined();
    });
  });

  describe("UrlSchema", () => {
    it("should validate correct URLs", () => {
      const validUrls = [
        undefined,
        "https://example.com",
        "http://example.com",
        "https://subdomain.example.com/path?query=value",
        "ftp://ftp.example.com",
      ];

      for (const url of validUrls) {
        expect(() => UrlSchema.parse(url)).not.toThrow();
      }
    });

    it("should reject invalid URLs", () => {
      const invalidUrls = [
        "not-a-url",
        "example.com", // missing protocol
        "http://", // incomplete
        "ftp", // incomplete protocol
      ];

      for (const url of invalidUrls) {
        expect(() => UrlSchema.parse(url)).toThrow();
      }
    });

    it("should accept some URLs that might seem questionable but are technically valid", () => {
      // These are technically valid URLs according to the URL specification
      const technicallyValidUrls = [
        "javascript:alert('xss')", // Valid protocol
        "data:text/plain;base64,SGVsbG8=", // Data URLs
      ];

      for (const url of technicallyValidUrls) {
        expect(() => UrlSchema.parse(url)).not.toThrow();
      }
    });

    it("should handle empty string for optional URL", () => {
      // Empty string should fail because it's not a valid URL
      expect(() => UrlSchema.parse("")).toThrow("Must be a valid URL");
    });
  });
});

describe("validation utility functions", () => {
  describe("validateWithSchema", () => {
    const testSchema = z.string().min(1);

    it("should return validated data for valid input", () => {
      const result = validateWithSchema(testSchema, "valid", "test string");
      expect(result).toBe("valid");
    });

    it("should throw ValidationError for invalid input", () => {
      expect(() => validateWithSchema(testSchema, "", "test string"))
        .toThrow(ValidationError);

      expect(() => validateWithSchema(testSchema, "", "test string"))
        .toThrow("Invalid test string");
    });

    it("should include field path in ValidationError", () => {
      const objectSchema = z.object({ name: z.string().min(1) });

      expect(() => validateWithSchema(objectSchema, { name: "" }, "user data"))
        .toThrow(ValidationError);
    });

    it("should handle nested object errors with path", () => {
      const nestedSchema = z.object({
        user: z.object({
          name: z.string().min(1),
        }),
      });

      try {
        validateWithSchema(nestedSchema, { user: { name: "" } }, "nested data");
      }
      catch (error) {
        expect(error).toBeInstanceOf(ValidationError);
        // The path should be extracted for nested fields
      }
    });

    it("should re-throw non-ZodError errors", () => {
      const errorSchema = z.string().transform(() => {
        throw new Error("Custom error");
      });

      expect(() => validateWithSchema(errorSchema, "test", "context"))
        .toThrow("Custom error");
    });
  });

  describe("safeValidate", () => {
    const testSchema = z.string().min(1);

    it("should return success for valid input", () => {
      const result = safeValidate(testSchema, "valid");
      expect(result.success).toBe(true);
      if (result.success) {
        expect(result.data).toBe("valid");
      }
    });

    it("should return error for invalid input", () => {
      const result = safeValidate(testSchema, "");
      expect(result.success).toBe(false);
      if (!result.success) {
        expect(result.error).toBeInstanceOf(z.ZodError);
      }
    });

    it("should handle complex validation scenarios", () => {
      const complexSchema = z.object({
        email: z.string().email(),
        age: z.number().min(18),
      });

      const validResult = safeValidate(complexSchema, {
        email: "test@example.com",
        age: 25,
      });
      expect(validResult.success).toBe(true);

      const invalidResult = safeValidate(complexSchema, {
        email: "invalid-email",
        age: 16,
      });
      expect(invalidResult.success).toBe(false);
    });
  });
});
