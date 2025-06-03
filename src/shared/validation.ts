/**
 * @file validation.ts
 * @description Shared validation schemas using Zod for the setlist.fm API.
 * @author tkozzer
 * @module validation
 */

import { z } from "zod";

import { ValidationError } from "./error";

/**
 * Schema for MusicBrainz MBID validation.
 * MBIDs are UUIDs in the format: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
 */
export const MbidSchema = z
  .string()
  .min(1, "MBID is required")
  .regex(
    /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i,
    "MBID must be a valid UUID format",
  );

/**
 * Schema for pagination parameters.
 */
export const PaginationSchema = z.object({
  /** Page number (1-based) */
  p: z
    .number()
    .int("Page number must be an integer")
    .min(1, "Page number must be greater than 0")
    .optional(),
});

/**
 * Schema for extended pagination with items per page.
 */
export const ExtendedPaginationSchema = PaginationSchema.extend({
  /** Number of items per page */
  itemsPerPage: z
    .number()
    .int("Items per page must be an integer")
    .min(1, "Items per page must be greater than 0")
    .max(100, "Items per page cannot exceed 100")
    .optional(),
});

/**
 * Schema for language codes (ISO 639-1).
 */
export const LanguageSchema = z
  .string()
  .length(2, "Language code must be exactly 2 characters")
  .regex(/^[a-z]{2}$/, "Language code must contain only lowercase letters");

/**
 * Schema for sort order options.
 */
export const SortOrderSchema = z.enum(["asc", "desc"]);

/**
 * Schema for date strings in YYYY-MM-DD format.
 */
export const DateSchema = z
  .string()
  .regex(
    /^\d{4}-\d{2}-\d{2}$/,
    "Date must be in YYYY-MM-DD format",
  )
  .refine((date) => {
    const parsed = new Date(date);
    return !Number.isNaN(parsed.getTime());
  }, "Date must be a valid date");

/**
 * Schema for date range parameters.
 */
export const DateRangeSchema = z.object({
  /** Start date */
  from: DateSchema.optional(),
  /** End date */
  to: DateSchema.optional(),
}).refine((data) => {
  if (data.from && data.to) {
    return new Date(data.from) <= new Date(data.to);
  }
  return true;
}, "Start date must be before or equal to end date");

/**
 * Schema for basic string validation with trimming.
 */
export const NonEmptyStringSchema = z
  .string()
  .trim()
  .min(1, "Value cannot be empty");

/**
 * Schema for optional string that can be empty.
 */
export const OptionalStringSchema = z
  .string()
  .trim()
  .optional();

/**
 * Schema for URL validation.
 */
export const UrlSchema = z
  .string()
  .url("Must be a valid URL")
  .optional();

/**
 * Validates and parses data using a Zod schema.
 *
 * @param {z.ZodSchema<T>} schema - The Zod schema to validate against.
 * @param {unknown} data - The data to validate.
 * @param {string} context - Context for error messages (e.g., "MBID parameter").
 * @returns {T} The validated and parsed data.
 * @throws {ValidationError} If validation fails.
 *
 * @example
 * ```ts
 * const validMbid = validateWithSchema(MbidSchema, userInput, "artist MBID");
 * ```
 */
export function validateWithSchema<T>(
  schema: z.ZodSchema<T>,
  data: unknown,
  context: string,
): T {
  try {
    return schema.parse(data);
  }
  catch (error) {
    if (error instanceof z.ZodError) {
      const firstError = error.errors[0];
      const message = `Invalid ${context}: ${firstError.message}`;

      throw new ValidationError(message, firstError.path?.[0]?.toString());
    }
    throw error;
  }
}

/**
 * Safely validates data and returns either the parsed result or an error.
 *
 * @param {z.ZodSchema<T>} schema - The Zod schema to validate against.
 * @param {unknown} data - The data to validate.
 * @returns {{ success: true; data: T } | { success: false; error: z.ZodError }} Validation result.
 */
export function safeValidate<T>(
  schema: z.ZodSchema<T>,
  data: unknown,
): { success: true; data: T } | { success: false; error: z.ZodError } {
  const result = schema.safeParse(data);
  if (result.success) {
    return { success: true, data: result.data };
  }
  return { success: false, error: result.error };
}
