/**
 * @file getVenue.ts
 * @description Retrieves a venue by its unique venue ID.
 * @author tkozzer
 * @module venues
 */

import type { HttpClient } from "@utils/http";

import type { Venue } from "./types";
import { createErrorFromResponse } from "@shared/error";

import { validateWithSchema } from "@shared/validation";
import { VenueIdParamSchema } from "./validation";

/**
 * Retrieves a venue by its unique venue ID.
 *
 * @param {HttpClient} httpClient - The HTTP client instance.
 * @param {string} venueId - The venue's unique identifier.
 * @returns {Promise<Venue>} A promise that resolves to the venue object.
 * @throws {ValidationError} If the venueId is invalid or missing.
 * @throws {NotFoundError} If the venue with the given venueId is not found.
 * @throws {AuthenticationError} If the API key is invalid.
 * @throws {SetlistFMAPIError} For other API errors.
 *
 * @example
 * ```ts
 * const venue = await getVenue(httpClient, "6bd6ca6e");
 * console.log(venue.name); // "Compaq Center"
 * console.log(venue.city?.name); // "Hollywood"
 * console.log(venue.city?.country.name); // "United States"
 * ```
 */
export async function getVenue(httpClient: HttpClient, venueId: string): Promise<Venue> {
  // Validate venueId parameter using Zod schema
  const validatedVenueId = validateWithSchema(VenueIdParamSchema, venueId, "venue ID");

  try {
    const endpoint = `/venue/${validatedVenueId}`;
    const response = await httpClient.get<Venue>(endpoint);
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
      error.message || "Failed to retrieve venue",
      `/venue/${validatedVenueId}`,
      error.response,
    );
  }
}
