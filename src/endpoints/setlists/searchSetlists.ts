/**
 * @file searchSetlists.ts
 * @description Searches for setlists using various criteria.
 * @author tkozzer
 * @module setlists
 */

import type { HttpClient } from "@utils/http";

import type { SearchSetlistsParams, Setlists } from "./types";
import { createErrorFromResponse } from "@shared/error";

import { validateWithSchema } from "@shared/validation";
import { SearchSetlistsParamsSchema, SetlistsSchema } from "./validation";

/**
 * Searches for setlists using a wide range of filters, including artist, city, country, date, venue, and more.
 * Returns a paginated list of matching setlists.
 *
 * @param {HttpClient} httpClient - The HTTP client instance.
 * @param {SearchSetlistsParams} params - Search parameters (at least one required).
 * @returns {Promise<Setlists>} A promise that resolves to the setlists search results.
 * @throws {ValidationError} If the search parameters are invalid or missing.
 * @throws {NotFoundError} If no setlists are found matching the criteria.
 * @throws {AuthenticationError} If the API key is invalid.
 * @throws {SetlistFMAPIError} For other API errors.
 *
 * @example
 * ```ts
 * // Search by artist name
 * const results = await searchSetlists(httpClient, { artistName: "The Beatles" });
 * console.log(results.total); // Total number of matching setlists
 * console.log(results.setlist.length); // Number of setlists on this page
 *
 * // Search by artist and city
 * const shows = await searchSetlists(httpClient, {
 *   artistName: "The Beatles",
 *   cityName: "Hollywood"
 * });
 *
 * // Search by date and venue
 * const concert = await searchSetlists(httpClient, {
 *   artistMbid: "b10bbbfc-cf9e-42e0-be17-e2c3e1d2600d",
 *   date: "23-08-1964",
 *   venueName: "Hollywood Bowl"
 * });
 *
 * // Search with pagination
 * const page2 = await searchSetlists(httpClient, {
 *   artistName: "Beatles",
 *   year: 1964,
 *   p: 2
 * });
 * ```
 */
export async function searchSetlists(
  httpClient: HttpClient,
  params: SearchSetlistsParams,
): Promise<Setlists> {
  // Validate search parameters using Zod schema
  const validatedParams = validateWithSchema(
    SearchSetlistsParamsSchema,
    params,
    "search parameters",
  );

  try {
    const endpoint = "/search/setlists";
    const response = await httpClient.get<Setlists>(endpoint, validatedParams);

    // Validate the response structure
    const validatedResponse = validateWithSchema(
      SetlistsSchema,
      response,
      "setlists search response",
    );

    return validatedResponse;
  }
  catch (error: any) {
    // Re-throw known SetlistFM errors
    if (error.name?.includes("SetlistFM") || error.name?.includes("Error")) {
      throw error;
    }

    // Handle unexpected errors
    throw createErrorFromResponse(
      error.statusCode || 500,
      error.message || "Failed to search setlists",
      "/search/setlists",
      error.response,
    );
  }
}
