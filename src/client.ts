/**
 * @file client.ts
 * @description Main SetlistFM client for accessing the setlist.fm API.
 * @author tkozzer
 * @module client
 */

import type { HttpClientConfig } from "./utils/http";
import type { RateLimitConfig } from "./utils/rateLimiter";

import { HttpClient } from "./utils/http";

/**
 * Configuration options for the SetlistFM client.
 */
export type SetlistFMClientConfig = {
  /** API key for authentication with setlist.fm */
  apiKey: string;
  /** User agent string for identifying your application */
  userAgent: string;
  /** Request timeout in milliseconds */
  timeout?: number;
  /** Language code for internationalization (e.g., 'en', 'es', 'fr', 'de', 'pt', 'tr', 'it', 'pl') */
  language?: string;
  /** Rate limiting configuration */
  rateLimit?: RateLimitConfig;
};

/**
 * Main client for interacting with the setlist.fm API.
 *
 * Provides access to all API endpoints through organized modules for artists,
 * setlists, venues, cities, countries, and users.
 */
export class SetlistFMClient {
  private readonly httpClient: HttpClient;

  constructor(config: SetlistFMClientConfig) {
    const httpConfig: HttpClientConfig = {
      apiKey: config.apiKey,
      userAgent: config.userAgent,
      timeout: config.timeout,
      language: config.language,
      rateLimit: config.rateLimit,
    };

    this.httpClient = new HttpClient(httpConfig);
  }

  /**
   * Updates the language for subsequent API requests.
   *
   * @param {string} language - Language code for internationalization.
   *
   * @example
   * ```ts
   * client.setLanguage('es'); // Switch to Spanish
   * ```
   */
  setLanguage(language: string): void {
    this.httpClient.setLanguage(language);
  }

  /**
   * Gets the base URL being used for API requests.
   *
   * @returns {string} The base URL of the setlist.fm API.
   */
  getBaseUrl(): string {
    return this.httpClient.getBaseUrl();
  }

  /**
   * Gets the underlying HTTP client for advanced usage.
   *
   * @returns {HttpClient} The HTTP client instance.
   */
  getHttpClient(): HttpClient {
    return this.httpClient;
  }

  /**
   * Gets the current rate limit status.
   *
   * @returns {object | null} Rate limit status or null if rate limiting is disabled.
   */
  getRateLimitStatus(): ReturnType<HttpClient["getRateLimitStatus"]> {
    return this.httpClient.getRateLimitStatus();
  }
}

/**
 * Creates a new SetlistFM client instance.
 *
 * @param {SetlistFMClientConfig} config - Configuration options for the client.
 * @returns {SetlistFMClient} A new SetlistFM client instance.
 * @throws {Error} If required configuration is missing or invalid.
 *
 * @example
 * ```ts
 * const client = createSetlistFMClient({
 *   apiKey: 'your-api-key-here',
 *   userAgent: 'your-app-name (your-email@example.com)',
 *   language: 'en'
 * });
 * ```
 */
export function createSetlistFMClient(config: SetlistFMClientConfig): SetlistFMClient {
  if (!config.apiKey) {
    throw new Error("API key is required");
  }
  if (!config.userAgent) {
    throw new Error("User agent is required");
  }

  return new SetlistFMClient(config);
}
