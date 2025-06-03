/**
 * @file getArtistSetlists.ts
 * @description Retrieves setlists for an artist by their MusicBrainz MBID.
 * @author tkozzer
 * @module artists
 */

import type { MBID } from "@shared/types";
import type { HttpClient } from "@utils/http";

import type { GetArtistSetlistsParams, Setlists } from "./types";
import { createErrorFromResponse } from "@shared/error";

import { validateWithSchema } from "@shared/validation";

import { ArtistMbidParamSchema, GetArtistSetlistsParamsSchema } from "./validation";

/**
 * Retrieves setlists for an artist by their MusicBrainz MBID.
 *
 * @param {HttpClient} httpClient - The HTTP client instance.
 * @param {MBID} mbid - MusicBrainz MBID of the artist.
 * @param {GetArtistSetlistsParams} [params] - Optional pagination parameters.
 * @returns {Promise<Setlists>} A promise that resolves to the setlists response object.
 * @throws {ValidationError} If the MBID or parameters are invalid.
 * @throws {NotFoundError} If the artist with the given MBID is not found.
 * @throws {AuthenticationError} If the API key is invalid.
 * @throws {SetlistFMAPIError} For other API errors.
 *
 * @example
 * ```ts
 * // Get first page of setlists
 * const setlists = await getArtistSetlists(httpClient, "b10bbbfc-cf9e-42e0-be17-e2c3e1d2600d");
 * console.log(setlists.total); // Total number of setlists
 * console.log(setlists.setlist.length); // Number of setlists on this page
 *
 * // Get specific page
 * const page2 = await getArtistSetlists(httpClient, "b10bbbfc-cf9e-42e0-be17-e2c3e1d2600d", { p: 2 });
 * ```
 */
export async function getArtistSetlists(
  httpClient: HttpClient,
  mbid: MBID,
  params: GetArtistSetlistsParams = {},
): Promise<Setlists> {
  // Validate MBID parameter using Zod schema
  const validatedMbid = validateWithSchema(ArtistMbidParamSchema, mbid, "artist MBID");

  // Validate pagination parameters
  const validatedParams = validateWithSchema(GetArtistSetlistsParamsSchema, params, "pagination parameters");

  try {
    const endpoint = `/artist/${validatedMbid}/setlists`;
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
      error.message || "Failed to retrieve artist setlists",
      `/artist/${validatedMbid}/setlists`,
      error.response,
    );
  }
}
