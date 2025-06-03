/**
 * @file searchVenues.ts
 * @description Search for venues by name, city, country, state, or state code.
 * @author tkozzer
 * @module venues
 */

import type { HttpClient } from "@utils/http";

import type { SearchVenuesParams, Venues } from "./types";
import { createErrorFromResponse } from "@shared/error";

import { validateWithSchema } from "@shared/validation";
import { SearchVenuesParamsSchema } from "./validation";

/**
 * Search for venues by name, city, country, state, or state code.
 *
 * @param {HttpClient} httpClient - The HTTP client instance.
 * @param {SearchVenuesParams} params - Search parameters object.
 * @returns {Promise<Venues>} A promise that resolves to the venues search results.
 * @throws {ValidationError} If the search parameters are invalid.
 * @throws {NotFoundError} If no venues are found matching the criteria.
 * @throws {AuthenticationError} If the API key is invalid.
 * @throws {SetlistFMAPIError} For other API errors.
 *
 * @example
 * ```ts
 * // Search by venue name
 * const results = await searchVenues(httpClient, { name: "Madison Square Garden" });
 * console.log(results.total); // Total number of matching venues
 * console.log(results.venue.length); // Number of venues on this page
 *
 * // Search by city and country
 * const nyResults = await searchVenues(httpClient, {
 *   cityName: "New York",
 *   country: "US",
 *   p: 1
 * });
 *
 * // Search by state
 * const californiaResults = await searchVenues(httpClient, {
 *   state: "California",
 *   stateCode: "CA",
 *   p: 2
 * });
 *
 * // Search by city geoId
 * const geoResults = await searchVenues(httpClient, {
 *   cityId: "5128581"
 * });
 * ```
 */
export async function searchVenues(
  httpClient: HttpClient,
  params: SearchVenuesParams = {},
): Promise<Venues> {
  // Validate search parameters using Zod schema
  const validatedParams = validateWithSchema(SearchVenuesParamsSchema, params, "search parameters");

  try {
    const endpoint = "/search/venues";
    const response = await httpClient.get<Venues>(endpoint, validatedParams);
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
      error.message || "Failed to search venues",
      "/search/venues",
      error.response,
    );
  }
}
