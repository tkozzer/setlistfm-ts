/**
 * @file searchCities.ts
 * @description Search for cities by name, country, state, or state code.
 * @author tkozzer
 * @module cities
 */

import type { HttpClient } from "@utils/http";

import type { Cities, SearchCitiesParams } from "./types";
import { createErrorFromResponse } from "@shared/error";

import { validateWithSchema } from "@shared/validation";
import { SearchCitiesParamsSchema } from "./validation";

/**
 * Search for cities by name, country, state, or state code.
 *
 * @param {HttpClient} httpClient - The HTTP client instance.
 * @param {SearchCitiesParams} params - Search parameters object.
 * @returns {Promise<Cities>} A promise that resolves to the cities search results.
 * @throws {ValidationError} If the search parameters are invalid.
 * @throws {NotFoundError} If no cities are found matching the criteria.
 * @throws {AuthenticationError} If the API key is invalid.
 * @throws {SetlistFMAPIError} For other API errors.
 *
 * @example
 * ```ts
 * // Search by city name
 * const results = await searchCities(httpClient, { name: "Hollywood" });
 * console.log(results.total); // Total number of matching cities
 * console.log(results.cities.length); // Number of cities on this page
 *
 * // Search by country and state
 * const californiaResults = await searchCities(httpClient, {
 *   country: "US",
 *   state: "California",
 *   p: 1
 * });
 *
 * // Search by state code
 * const stateCodeResults = await searchCities(httpClient, {
 *   stateCode: "CA",
 *   p: 2
 * });
 * ```
 */
export async function searchCities(
  httpClient: HttpClient,
  params: SearchCitiesParams = {},
): Promise<Cities> {
  // Validate search parameters using Zod schema
  const validatedParams = validateWithSchema(SearchCitiesParamsSchema, params, "search parameters");

  try {
    const endpoint = "/search/cities";
    const response = await httpClient.get<Cities>(endpoint, validatedParams);
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
      error.message || "Failed to search cities",
      "/search/cities",
      error.response,
    );
  }
}
