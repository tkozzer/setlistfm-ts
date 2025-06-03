/**
 * @file getVenueSetlists.ts
 * @description Retrieves setlists for a venue by its unique venue ID.
 * @author tkozzer
 * @module venues
 */

import type { Setlists } from "@endpoints/artists/types";

import type { HttpClient } from "@utils/http";
import type { GetVenueSetlistsParams } from "./types";
import { createErrorFromResponse } from "@shared/error";

import { validateWithSchema } from "@shared/validation";
import { GetVenueSetlistsParamsSchema, VenueIdParamSchema } from "./validation";

/**
 * Retrieves setlists for a venue by its unique venue ID.
 *
 * @param {HttpClient} httpClient - The HTTP client instance.
 * @param {string} venueId - The venue's unique identifier.
 * @param {GetVenueSetlistsParams} [params] - Optional pagination parameters.
 * @returns {Promise<Setlists>} A promise that resolves to the setlists response object.
 * @throws {ValidationError} If the venueId or parameters are invalid.
 * @throws {NotFoundError} If the venue with the given venueId is not found.
 * @throws {AuthenticationError} If the API key is invalid.
 * @throws {SetlistFMAPIError} For other API errors.
 *
 * @example
 * ```ts
 * // Get first page of setlists for a venue
 * const setlists = await getVenueSetlists(httpClient, "6bd6ca6e");
 * console.log(setlists.total); // Total number of setlists
 * console.log(setlists.setlist.length); // Number of setlists on this page
 *
 * // Get specific page
 * const page2 = await getVenueSetlists(httpClient, "6bd6ca6e", { p: 2 });
 * ```
 */
export async function getVenueSetlists(
  httpClient: HttpClient,
  venueId: string,
  params: GetVenueSetlistsParams = {},
): Promise<Setlists> {
  // Validate venueId parameter using Zod schema
  const validatedVenueId = validateWithSchema(VenueIdParamSchema, venueId, "venue ID");

  // Validate pagination parameters
  const validatedParams = validateWithSchema(GetVenueSetlistsParamsSchema, params, "pagination parameters");

  try {
    const endpoint = `/venue/${validatedVenueId}/setlists`;
    const response = await httpClient.get<Setlists>(endpoint, validatedParams);
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
      error.message || "Failed to retrieve venue setlists",
      `/venue/${validatedVenueId}/setlists`,
      error.response,
    );
  }
}
