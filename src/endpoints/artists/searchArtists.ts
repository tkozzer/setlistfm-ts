/**
 * @file searchArtists.ts
 * @description Searches for artists using various criteria.
 * @author tkozzer
 * @module artists
 */

import type { HttpClient } from "@utils/http";

import type { Artists, SearchArtistsParams } from "./types";
import { createErrorFromResponse } from "@shared/error";

import { validateWithSchema } from "@shared/validation";

import { SearchArtistsParamsSchema } from "./validation";

/**
 * Searches for artists using various criteria.
 *
 * @param {HttpClient} httpClient - The HTTP client instance.
 * @param {SearchArtistsParams} params - Search parameters (at least one required).
 * @returns {Promise<Artists>} A promise that resolves to the artists search results.
 * @throws {ValidationError} If the search parameters are invalid or missing.
 * @throws {NotFoundError} If no artists are found matching the criteria.
 * @throws {AuthenticationError} If the API key is invalid.
 * @throws {SetlistFMAPIError} For other API errors.
 *
 * @example
 * ```ts
 * // Search by artist name
 * const results = await searchArtists(httpClient, { artistName: "The Beatles" });
 * console.log(results.total); // Total number of matching artists
 * console.log(results.artist.length); // Number of artists on this page
 *
 * // Search by MBID
 * const artist = await searchArtists(httpClient, {
 *   artistMbid: "b10bbbfc-cf9e-42e0-be17-e2c3e1d2600d"
 * });
 *
 * // Search with pagination and sorting
 * const page2 = await searchArtists(httpClient, {
 *   artistName: "Beatles",
 *   p: 2,
 *   sort: "relevance"
 * });
 * ```
 */
export async function searchArtists(
  httpClient: HttpClient,
  params: SearchArtistsParams,
): Promise<Artists> {
  // Validate search parameters using Zod schema
  const validatedParams = validateWithSchema(SearchArtistsParamsSchema, params, "search parameters");

  try {
    const endpoint = "/search/artists";
    const response = await httpClient.get<Artists>(endpoint, validatedParams);
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
      error.message || "Failed to search artists",
      "/search/artists",
      error.response,
    );
  }
}
