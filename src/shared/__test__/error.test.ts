/**
 * @file error.test.ts
 * @description Tests for error handling utilities.
 * @author tkozzer
 * @module shared/error
 */

import { describe, expect, it } from "vitest";

import {
  AuthenticationError,
  createErrorFromResponse,
  NotFoundError,
  RateLimitError,
  ServerError,
  SetlistFMAPIError,
  ValidationError,
} from "../error";

describe("Error Utilities", () => {
  describe("SetlistFMAPIError", () => {
    it("should create base API error with message only", () => {
      const error = new SetlistFMAPIError("Test error");

      expect(error).toBeInstanceOf(Error);
      expect(error).toBeInstanceOf(SetlistFMAPIError);
      expect(error.message).toBe("Test error");
      expect(error.name).toBe("SetlistFMAPIError");
      expect(error.statusCode).toBeUndefined();
      expect(error.endpoint).toBeUndefined();
      expect(error.response).toBeUndefined();
    });

    it("should create base API error with all parameters", () => {
      const response = { error: "Server error" };
      const error = new SetlistFMAPIError("Test error", 500, "/test", response);

      expect(error.message).toBe("Test error");
      expect(error.statusCode).toBe(500);
      expect(error.endpoint).toBe("/test");
      expect(error.response).toEqual(response);
    });
  });

  describe("AuthenticationError", () => {
    it("should create authentication error with default message", () => {
      const error = new AuthenticationError();

      expect(error).toBeInstanceOf(SetlistFMAPIError);
      expect(error.message).toBe("Invalid or missing API key");
      expect(error.name).toBe("AuthenticationError");
      expect(error.statusCode).toBe(401);
    });

    it("should create authentication error with custom message", () => {
      const error = new AuthenticationError("Custom auth error");

      expect(error.message).toBe("Custom auth error");
      expect(error.statusCode).toBe(401);
    });
  });

  describe("NotFoundError", () => {
    it("should create not found error with resource and identifier", () => {
      const error = new NotFoundError("Artist", "abc123");

      expect(error).toBeInstanceOf(SetlistFMAPIError);
      expect(error.message).toBe("Artist with identifier 'abc123' not found");
      expect(error.name).toBe("NotFoundError");
      expect(error.statusCode).toBe(404);
    });
  });

  describe("RateLimitError", () => {
    it("should create rate limit error with default message", () => {
      const error = new RateLimitError();

      expect(error).toBeInstanceOf(SetlistFMAPIError);
      expect(error.message).toBe("Rate limit exceeded");
      expect(error.name).toBe("RateLimitError");
      expect(error.statusCode).toBe(429);
    });

    it("should create rate limit error with custom message", () => {
      const error = new RateLimitError("Custom rate limit message");

      expect(error.message).toBe("Custom rate limit message");
      expect(error.statusCode).toBe(429);
    });
  });

  describe("ValidationError", () => {
    it("should create validation error with message", () => {
      const error = new ValidationError("Invalid input");

      expect(error).toBeInstanceOf(SetlistFMAPIError);
      expect(error.message).toBe("Invalid input");
      expect(error.name).toBe("ValidationError");
      expect(error.statusCode).toBe(400);
      expect(error.field).toBeUndefined();
    });

    it("should create validation error with field", () => {
      const error = new ValidationError("Invalid email format", "email");

      expect(error.message).toBe("Invalid email format");
      expect(error.field).toBe("email");
    });
  });

  describe("ServerError", () => {
    it("should create server error with default message", () => {
      const error = new ServerError();

      expect(error).toBeInstanceOf(SetlistFMAPIError);
      expect(error.message).toBe("Internal server error");
      expect(error.name).toBe("ServerError");
      expect(error.statusCode).toBe(500);
    });

    it("should create server error with custom message", () => {
      const error = new ServerError("Database connection failed");

      expect(error.message).toBe("Database connection failed");
      expect(error.statusCode).toBe(500);
    });
  });

  describe("createErrorFromResponse", () => {
    it("should create AuthenticationError for 401 status", () => {
      const error = createErrorFromResponse(401, "Unauthorized");

      expect(error).toBeInstanceOf(AuthenticationError);
      expect(error.message).toBe("Unauthorized");
    });

    it("should create AuthenticationError for 403 status", () => {
      const error = createErrorFromResponse(403, "Forbidden");

      expect(error).toBeInstanceOf(AuthenticationError);
      expect(error.message).toBe("Forbidden");
    });

    it("should create NotFoundError for 404 status", () => {
      const error = createErrorFromResponse(404, "Not found", "/artist/abc123");

      expect(error).toBeInstanceOf(NotFoundError);
      expect(error.message).toBe("artist with identifier 'abc123' not found");
    });

    it("should create NotFoundError for 404 with fallback values", () => {
      const error = createErrorFromResponse(404, "Not found");

      expect(error).toBeInstanceOf(NotFoundError);
      expect(error.message).toBe("Resource with identifier 'unknown' not found");
    });

    it("should create RateLimitError for 429 status", () => {
      const error = createErrorFromResponse(429, "Too many requests");

      expect(error).toBeInstanceOf(RateLimitError);
      expect(error.message).toBe("Too many requests");
    });

    it("should create ValidationError for 400 status", () => {
      const error = createErrorFromResponse(400, "Bad request");

      expect(error).toBeInstanceOf(ValidationError);
      expect(error.message).toBe("Bad request");
    });

    it("should create ServerError for 500 status", () => {
      const error = createErrorFromResponse(500, "Internal error");

      expect(error).toBeInstanceOf(ServerError);
      expect(error.message).toBe("Internal error");
    });

    it("should create ServerError for 502 status", () => {
      const error = createErrorFromResponse(502, "Bad gateway");

      expect(error).toBeInstanceOf(ServerError);
      expect(error.message).toBe("Bad gateway");
    });

    it("should create ServerError for 503 status", () => {
      const error = createErrorFromResponse(503, "Service unavailable");

      expect(error).toBeInstanceOf(ServerError);
      expect(error.message).toBe("Service unavailable");
    });

    it("should create ServerError for 504 status", () => {
      const error = createErrorFromResponse(504, "Gateway timeout");

      expect(error).toBeInstanceOf(ServerError);
      expect(error.message).toBe("Gateway timeout");
    });

    it("should create generic SetlistFMAPIError for unknown status", () => {
      const response = { data: "test" };
      const error = createErrorFromResponse(418, "Teapot error", "/test", response);

      expect(error).toBeInstanceOf(SetlistFMAPIError);
      expect(error).not.toBeInstanceOf(AuthenticationError);
      expect(error.message).toBe("Teapot error");
      expect(error.statusCode).toBe(418);
      expect(error.endpoint).toBe("/test");
      expect(error.response).toEqual(response);
    });
  });
});
