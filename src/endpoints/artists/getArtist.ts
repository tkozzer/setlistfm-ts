/**
 * @file getArtist.ts
 * @description Retrieves an artist by their MusicBrainz MBID.
 * @author tkozzer
 * @module artists
 */

import type { Artist, MBID } from "@shared/types";
import type { HttpClient } from "@utils/http";

import { createErrorFromResponse } from "@shared/error";
import { validateWithSchema } from "@shared/validation";

import { ArtistMbidParamSchema } from "./validation";

/**
 * Retrieves an artist for a given MusicBrainz MBID.
 *
 * @param {HttpClient} httpClient - The HTTP client instance.
 * @param {MBID} mbid - MusicBrainz MBID of the artist.
 * @returns {Promise<Artist>} A promise that resolves to the artist object.
 * @throws {ValidationError} If the MBID is invalid or missing.
 * @throws {NotFoundError} If the artist with the given MBID is not found.
 * @throws {AuthenticationError} If the API key is invalid.
 * @throws {SetlistFMAPIError} For other API errors.
 *
 * @example
 * ```ts
 * const artist = await getArtist(httpClient, "b10bbbfc-cf9e-42e0-be17-e2c3e1d2600d");
 * console.log(artist.name); // "The Beatles"
 * console.log(artist.sortName); // "Beatles, The"
 * ```
 */
export async function getArtist(httpClient: HttpClient, mbid: MBID): Promise<Artist> {
  // Validate MBID parameter using Zod schema
  const validatedMbid = validateWithSchema(ArtistMbidParamSchema, mbid, "artist MBID");

  try {
    const endpoint = `/artist/${validatedMbid}`;
    const response = await httpClient.get<Artist>(endpoint);
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
      error.message || "Failed to retrieve artist",
      `/artist/${validatedMbid}`,
      error.response,
    );
  }
}
