/**
 * @file error.ts
 * @description Error handling utilities for the setlist.fm API.
 * @author tkozzer
 * @module error
 */

/**
 * Base error class for setlist.fm API errors.
 */
export class SetlistFMAPIError extends Error {
  constructor(
    message: string,
    public readonly statusCode?: number,
    public readonly endpoint?: string,
    public readonly response?: any,
  ) {
    super(message);
    this.name = "SetlistFMAPIError";
  }
}

/**
 * Error thrown when authentication fails (invalid API key).
 */
export class AuthenticationError extends SetlistFMAPIError {
  constructor(message = "Invalid or missing API key") {
    super(message, 401);
    this.name = "AuthenticationError";
  }
}

/**
 * Error thrown when a resource is not found (404).
 */
export class NotFoundError extends SetlistFMAPIError {
  constructor(resource: string, identifier: string) {
    super(`${resource} with identifier '${identifier}' not found`, 404);
    this.name = "NotFoundError";
  }
}

/**
 * Error thrown when rate limits are exceeded (429).
 */
export class RateLimitError extends SetlistFMAPIError {
  constructor(message = "Rate limit exceeded") {
    super(message, 429);
    this.name = "RateLimitError";
  }
}

/**
 * Error thrown when validation fails (400).
 */
export class ValidationError extends SetlistFMAPIError {
  constructor(message: string, public readonly field?: string) {
    super(message, 400);
    this.name = "ValidationError";
  }
}

/**
 * Error thrown when the server encounters an internal error (500).
 */
export class ServerError extends SetlistFMAPIError {
  constructor(message = "Internal server error") {
    super(message, 500);
    this.name = "ServerError";
  }
}

/**
 * Creates an appropriate error instance based on the HTTP status code.
 *
 * @param {number} statusCode - HTTP status code.
 * @param {string} message - Error message.
 * @param {string} endpoint - API endpoint that caused the error.
 * @param {any} response - Raw response data.
 * @returns {SetlistFMAPIError} An appropriate error instance.
 */
export function createErrorFromResponse(
  statusCode: number,
  message: string,
  endpoint?: string,
  response?: any,
): SetlistFMAPIError {
  switch (statusCode) {
    case 401:
    case 403:
      return new AuthenticationError(message);
    case 404: {
      // Try to extract resource and identifier from endpoint
      const parts = endpoint?.split("/") || [];
      const resource = parts[parts.length - 2] || "Resource";
      const identifier = parts[parts.length - 1] || "unknown";
      return new NotFoundError(resource, identifier);
    }
    case 429:
      return new RateLimitError(message);
    case 400:
      return new ValidationError(message);
    case 500:
    case 502:
    case 503:
    case 504:
      return new ServerError(message);
    default:
      return new SetlistFMAPIError(message, statusCode, endpoint, response);
  }
}
