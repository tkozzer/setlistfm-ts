/**
 * @file getCityByGeoId.ts
 * @description Retrieves a city by its unique GeoNames geoId.
 * @author tkozzer
 * @module cities
 */

import type { HttpClient } from "@utils/http";

import type { City } from "./types";
import { createErrorFromResponse } from "@shared/error";

import { validateWithSchema } from "@shared/validation";
import { CityGeoIdParamSchema } from "./validation";

/**
 * Retrieves a city by its unique GeoNames geoId.
 *
 * @param {HttpClient} httpClient - The HTTP client instance.
 * @param {string} geoId - The city's GeoNames geoId.
 * @returns {Promise<City>} A promise that resolves to the city object.
 * @throws {ValidationError} If the geoId is invalid or missing.
 * @throws {NotFoundError} If the city with the given geoId is not found.
 * @throws {AuthenticationError} If the API key is invalid.
 * @throws {SetlistFMAPIError} For other API errors.
 *
 * @example
 * ```ts
 * const city = await getCityByGeoId(httpClient, "5357527");
 * console.log(city.name); // "Hollywood"
 * console.log(city.state); // "California"
 * console.log(city.country.name); // "United States"
 * ```
 */
export async function getCityByGeoId(httpClient: HttpClient, geoId: string): Promise<City> {
  // Validate geoId parameter using Zod schema
  const validatedGeoId = validateWithSchema(CityGeoIdParamSchema, geoId, "city geoId");

  try {
    const endpoint = `/city/${validatedGeoId}`;
    const response = await httpClient.get<City>(endpoint);
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
      error.message || "Failed to retrieve city",
      `/city/${validatedGeoId}`,
      error.response,
    );
  }
}
