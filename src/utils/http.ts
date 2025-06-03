/**
 * @file http.ts
 * @description HTTP client utilities for making requests to the setlist.fm API.
 * @author tkozzer
 * @module http
 */

import type { AxiosInstance, AxiosRequestConfig, AxiosResponse } from "axios";

import axios from "axios";

import type { RateLimitConfig } from "./rateLimiter";

import { RateLimiter } from "./rateLimiter";

/** Base URL for the setlist.fm API */
export const API_BASE_URL = "https://api.setlist.fm/1.0";

/** Default timeout for API requests in milliseconds */
export const DEFAULT_TIMEOUT = 10000;

/**
 * Configuration options for the HTTP client.
 */
export type HttpClientConfig = {
  /** API key for authentication */
  apiKey: string;
  /** User agent string for identifying your application */
  userAgent: string;
  /** Request timeout in milliseconds */
  timeout?: number;
  /** Language code for internationalization (e.g., 'en', 'es', 'fr') */
  language?: string;
  /** Rate limiting configuration */
  rateLimit?: RateLimitConfig;
};

/**
 * Error thrown when API requests fail.
 */
export class SetlistFMError extends Error {
  constructor(
    message: string,
    public statusCode?: number,
    public response?: any,
  ) {
    super(message);
    this.name = "SetlistFMError";
  }
}

/**
 * HTTP client for the setlist.fm API with built-in authentication and error handling.
 */
export class HttpClient {
  private readonly client: AxiosInstance;
  private readonly rateLimiter?: RateLimiter;

  constructor(config: HttpClientConfig) {
    this.client = axios.create({
      baseURL: API_BASE_URL,
      timeout: config.timeout || DEFAULT_TIMEOUT,
      headers: {
        "x-api-key": config.apiKey,
        "Accept": "application/json",
        "User-Agent": config.userAgent,
        ...(config.language && { "Accept-Language": config.language }),
      },
    });

    // Initialize rate limiter if configuration provided
    if (config.rateLimit) {
      this.rateLimiter = new RateLimiter(config.rateLimit);
    }

    this.setupResponseInterceptor();
  }

  /**
   * Sets up response interceptor for error handling.
   */
  private setupResponseInterceptor(): void {
    this.client.interceptors.response.use(
      (response: AxiosResponse) => response,
      (error) => {
        if (error.response) {
          // API returned an error response
          const errorMessage = error.response.data?.error || error.message;
          throw new SetlistFMError(
            errorMessage,
            error.response.status,
            error.response.data,
          );
        }
        else if (error.request) {
          // Request was made but no response received
          throw new SetlistFMError("No response received from API");
        }
        else {
          // Something else happened
          throw new SetlistFMError(error.message);
        }
      },
    );
  }

  /**
   * Makes a GET request to the specified endpoint.
   *
   * @param {string} endpoint - The API endpoint to request (without base URL).
   * @param {Record<string, any>} params - Query parameters to include in the request.
   * @returns {Promise<T>} A promise that resolves to the response data.
   * @throws {SetlistFMError} If the request fails or returns an error response.
   *
   * @example
   * ```ts
   * const data = await httpClient.get('/artist/1234-abcd', { p: 1 });
   * ```
   */
  async get<T = any>(endpoint: string, params?: Record<string, any>): Promise<T> {
    // Apply rate limiting if configured
    if (this.rateLimiter) {
      await this.rateLimiter.waitForNextSlot();
    }

    const config: AxiosRequestConfig = {};
    if (params) {
      config.params = params;
    }

    const response = await this.client.get<T>(endpoint, config);

    // Record the request for rate limiting
    if (this.rateLimiter) {
      this.rateLimiter.recordRequest();
    }

    return response.data;
  }

  /**
   * Updates the language for subsequent requests.
   *
   * @param {string} language - Language code (e.g., 'en', 'es', 'fr').
   */
  setLanguage(language: string): void {
    this.client.defaults.headers["Accept-Language"] = language;
  }

  /**
   * Gets the current base URL being used by the client.
   *
   * @returns {string} The base URL.
   */
  getBaseUrl(): string {
    return this.client.defaults.baseURL || API_BASE_URL;
  }

  /**
   * Gets the rate limiter instance if configured.
   *
   * @returns {RateLimiter | undefined} The rate limiter instance.
   */
  getRateLimiter(): RateLimiter | undefined {
    return this.rateLimiter;
  }

  /**
   * Gets the current rate limit status.
   *
   * @returns {object | null} Rate limit status or null if not configured.
   */
  getRateLimitStatus(): ReturnType<RateLimiter["getStatus"]> | null {
    return this.rateLimiter ? this.rateLimiter.getStatus() : null;
  }
}
