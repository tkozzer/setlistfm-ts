/**
 * @file searchCountries.ts
 * @description Get a complete list of all supported countries.
 * @author tkozzer
 * @module countries
 */

import type { HttpClient } from "@utils/http";

import type { Countries, SearchCountriesParams } from "./types";
import { createErrorFromResponse } from "@shared/error";

import { validateWithSchema } from "@shared/validation";
import { SearchCountriesParamsSchema } from "./validation";

/**
 * Get a complete list of all supported countries.
 *
 * @param {HttpClient} httpClient - The HTTP client instance.
 * @param {SearchCountriesParams} params - Search parameters object (currently empty).
 * @returns {Promise<Countries>} A promise that resolves to the countries results.
 * @throws {ValidationError} If the search parameters are invalid.
 * @throws {AuthenticationError} If the API key is invalid.
 * @throws {SetlistFMAPIError} For other API errors.
 *
 * @example
 * ```ts
 * // Get all countries
 * const results = await searchCountries(httpClient, {});
 * console.log(results.total); // Total number of countries
 * console.log(results.country.length); // Number of countries on this page
 *
 * // Countries are automatically paginated by the API
 * for (const country of results.country) {
 *   console.log(`${country.code}: ${country.name}`);
 * }
 * ```
 */
export async function searchCountries(
  httpClient: HttpClient,
  params: SearchCountriesParams = {},
): Promise<Countries> {
  // Validate search parameters using Zod schema
  const validatedParams = validateWithSchema(SearchCountriesParamsSchema, params, "search parameters");

  try {
    const endpoint = "/search/countries";
    const response = await httpClient.get<Countries>(endpoint, validatedParams);
    return response;
  }
  catch (error: any) {
    // Re-throw known SetlistFM errors
    if (error.name?.includes("SetlistFM") || error.name?.includes("Error")) {
      throw error;
    }

    // Handle unexpected errors
    throw createErrorFromResponse(
      error.statusCode || 500,
      error.message || "Failed to search countries",
      "/search/countries",
      error.response,
    );
  }
}
