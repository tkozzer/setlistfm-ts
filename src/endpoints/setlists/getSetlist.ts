/**
 * @file getSetlist.ts
 * @description Retrieves a setlist by its unique setlist ID.
 * @author tkozzer
 * @module setlists
 */

import type { HttpClient } from "@utils/http";

import type { Setlist } from "./types";
import { createErrorFromResponse } from "@shared/error";

import { validateWithSchema } from "@shared/validation";
import { GetSetlistParamsSchema, SetlistSchema } from "./validation";

/**
 * Retrieves the current version of a setlist for the provided setlist ID.
 * If the setlist has been edited since you last accessed it, you'll get the most recent version.
 *
 * @param {HttpClient} httpClient - The HTTP client instance.
 * @param {string} setlistId - The setlist ID (8-character hexadecimal string).
 * @returns {Promise<Setlist>} A promise that resolves to the setlist object.
 * @throws {ValidationError} If the setlist ID is invalid or missing.
 * @throws {NotFoundError} If the setlist with the given ID is not found.
 * @throws {AuthenticationError} If the API key is invalid.
 * @throws {SetlistFMAPIError} For other API errors.
 *
 * @example
 * ```ts
 * const setlist = await getSetlist(httpClient, "63de4613");
 * console.log(setlist.artist.name); // "The Beatles"
 * console.log(setlist.venue.name); // "Hollywood Bowl"
 * console.log(setlist.eventDate); // "23-08-1964"
 * ```
 */
export async function getSetlist(httpClient: HttpClient, setlistId: string): Promise<Setlist> {
  // Validate setlist ID parameter using Zod schema
  const { setlistId: validatedSetlistId } = validateWithSchema(
    GetSetlistParamsSchema,
    { setlistId },
    "setlist ID parameter",
  );

  try {
    const endpoint = `/setlist/${validatedSetlistId}`;
    const response = await httpClient.get<Setlist>(endpoint);

    // Validate the response structure
    const validatedResponse = validateWithSchema(
      SetlistSchema,
      response,
      "setlist response",
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
      error.message || "Failed to retrieve setlist",
      `/setlist/${validatedSetlistId}`,
      error.response,
    );
  }
}
