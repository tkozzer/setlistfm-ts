/**
 * @file http.test.ts
 * @description Tests for HTTP client utilities.
 * @author tkozzer
 * @module utils/http
 */

import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";

import { API_BASE_URL, DEFAULT_TIMEOUT, HttpClient, SetlistFMError } from "../http";
import { RateLimitProfile } from "../rateLimiter";

// Create mock functions that we'll reuse
const mockGet = vi.fn();
const mockInterceptorsUse = vi.fn();
const mockAxiosInstance = {
  get: mockGet,
  defaults: {
    headers: {} as Record<string, any>,
    baseURL: API_BASE_URL,
  },
  interceptors: {
    response: {
      use: mockInterceptorsUse,
    },
  },
};

// Mock axios with proper create method
vi.mock("axios", () => ({
  default: {
    create: vi.fn(() => mockAxiosInstance),
  },
}));

describe("HTTP Client", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    // Reset the mock headers object
    mockAxiosInstance.defaults.headers = {};
    // Reset baseURL for each test
    mockAxiosInstance.defaults.baseURL = API_BASE_URL;
  });

  afterEach(() => {
    vi.restoreAllMocks();
  });

  describe("Constants", () => {
    it("should export correct API base URL", () => {
      expect(API_BASE_URL).toBe("https://api.setlist.fm/rest/1.0");
    });

    it("should export correct default timeout", () => {
      expect(DEFAULT_TIMEOUT).toBe(10000);
    });
  });

  describe("SetlistFMError", () => {
    it("should create error with message only", () => {
      const error = new SetlistFMError("Test error");

      expect(error).toBeInstanceOf(Error);
      expect(error.name).toBe("SetlistFMError");
      expect(error.message).toBe("Test error");
      expect(error.statusCode).toBeUndefined();
      expect(error.response).toBeUndefined();
    });

    it("should create error with status code", () => {
      const error = new SetlistFMError("Test error", 404);

      expect(error.message).toBe("Test error");
      expect(error.statusCode).toBe(404);
      expect(error.response).toBeUndefined();
    });

    it("should create error with all parameters", () => {
      const response = { error: "Server error" };
      const error = new SetlistFMError("Test error", 500, response);

      expect(error.message).toBe("Test error");
      expect(error.statusCode).toBe(500);
      expect(error.response).toEqual(response);
    });
  });

  describe("HttpClient Configuration", () => {
    it("should create client with minimal config", () => {
      const config = {
        apiKey: "test-key",
        userAgent: "test-app",
      };

      const client = new HttpClient(config);

      expect(client).toBeInstanceOf(HttpClient);
      expect(client.getBaseUrl()).toBe(API_BASE_URL);
    });

    it("should create client with all config options", () => {
      const config = {
        apiKey: "test-key",
        userAgent: "test-app",
        timeout: 5000,
        language: "es",
      };

      const client = new HttpClient(config);

      expect(client).toBeInstanceOf(HttpClient);
      expect(client.getBaseUrl()).toBe(API_BASE_URL);
    });

    it("should create client with rate limiting", () => {
      const config = {
        apiKey: "test-key",
        userAgent: "test-app",
        rateLimit: {
          profile: RateLimitProfile.STANDARD,
        },
      };

      const client = new HttpClient(config);

      expect(client.getRateLimiter()).toBeDefined();
      expect(client.getRateLimitStatus()).toBeDefined();
    });

    it("should create client without rate limiting", () => {
      const config = {
        apiKey: "test-key",
        userAgent: "test-app",
      };

      const client = new HttpClient(config);

      expect(client.getRateLimiter()).toBeUndefined();
      expect(client.getRateLimitStatus()).toBeNull();
    });
  });

  describe("HttpClient Methods", () => {
    const config = {
      apiKey: "test-key",
      userAgent: "test-app",
    };

    it("should have get method", () => {
      const client = new HttpClient(config);

      expect(typeof client.get).toBe("function");
    });

    it("should have setLanguage method and properly set language header", () => {
      const client = new HttpClient(config);

      expect(typeof client.setLanguage).toBe("function");

      // Test that setLanguage actually sets the Accept-Language header
      client.setLanguage("fr");
      expect(mockAxiosInstance.defaults.headers["Accept-Language"]).toBe("fr");

      // Test with another language
      client.setLanguage("de");
      expect(mockAxiosInstance.defaults.headers["Accept-Language"]).toBe("de");
    });

    it("should have getBaseUrl method", () => {
      const client = new HttpClient(config);

      expect(typeof client.getBaseUrl).toBe("function");
      expect(client.getBaseUrl()).toBe(API_BASE_URL);
    });

    it("should handle baseURL fallback correctly when baseURL is undefined", () => {
      // Set baseURL to undefined to test the fallback
      (mockAxiosInstance.defaults as any).baseURL = undefined;

      const client = new HttpClient(config);

      // This tests the fallback logic: || API_BASE_URL
      const baseUrl = client.getBaseUrl();
      expect(baseUrl).toBe(API_BASE_URL);
    });

    it("should handle baseURL fallback correctly when baseURL is null", () => {
      // Set baseURL to null to test the fallback
      (mockAxiosInstance.defaults as any).baseURL = null;

      const client = new HttpClient(config);

      // This tests the fallback logic: || API_BASE_URL
      const baseUrl = client.getBaseUrl();
      expect(baseUrl).toBe(API_BASE_URL);
    });

    it("should handle baseURL fallback correctly when baseURL is empty string", () => {
      // Set baseURL to empty string to test the fallback
      mockAxiosInstance.defaults.baseURL = "";

      const client = new HttpClient(config);

      // This tests the fallback logic: || API_BASE_URL
      const baseUrl = client.getBaseUrl();
      expect(baseUrl).toBe(API_BASE_URL);
    });

    it("should return actual baseURL when it exists", () => {
      // Set a custom baseURL
      const customBaseURL = "https://custom.api.com";
      mockAxiosInstance.defaults.baseURL = customBaseURL;

      const client = new HttpClient(config);

      // Should return the actual baseURL, not the fallback
      const baseUrl = client.getBaseUrl();
      expect(baseUrl).toBe(customBaseURL);
    });

    it("should have rate limiter methods", () => {
      const client = new HttpClient(config);

      expect(typeof client.getRateLimiter).toBe("function");
      expect(typeof client.getRateLimitStatus).toBe("function");
    });

    it("should call setupResponseInterceptor during construction", () => {
      // This test ensures the setupResponseInterceptor method is called
      const client = new HttpClient(config);

      // Verify that the interceptor was set up
      expect(mockInterceptorsUse).toHaveBeenCalledTimes(1);
      expect(client).toBeInstanceOf(HttpClient);
    });

    it("should test response interceptor success handler", () => {
      const _client = new HttpClient(config);

      // Get the success handler that was passed to interceptors.response.use
      const successHandler = mockInterceptorsUse.mock.calls[0][0];

      // Create a mock response
      const mockResponse = {
        data: { test: "data" },
        status: 200,
        statusText: "OK",
        headers: {},
        config: {},
      };

      // Test that the success handler returns the response unchanged
      const result = successHandler(mockResponse);
      expect(result).toBe(mockResponse);
    });
  });

  describe("HttpClient with Rate Limiting", () => {
    it("should properly initialize with STANDARD profile", () => {
      const config = {
        apiKey: "test-key",
        userAgent: "test-app",
        rateLimit: {
          profile: RateLimitProfile.STANDARD,
        },
      };

      const client = new HttpClient(config);
      const rateLimiter = client.getRateLimiter();
      const status = client.getRateLimitStatus();

      expect(rateLimiter).toBeDefined();
      expect(status).toBeDefined();
      expect(status?.secondLimit).toBe(2);
      expect(status?.dayLimit).toBe(1440);
    });

    it("should properly initialize with PREMIUM profile", () => {
      const config = {
        apiKey: "test-key",
        userAgent: "test-app",
        rateLimit: {
          profile: RateLimitProfile.PREMIUM,
        },
      };

      const client = new HttpClient(config);
      const status = client.getRateLimitStatus();

      expect(status?.secondLimit).toBe(16);
      expect(status?.dayLimit).toBe(50000);
    });

    it("should properly initialize with custom rate limits", () => {
      const config = {
        apiKey: "test-key",
        userAgent: "test-app",
        rateLimit: {
          profile: RateLimitProfile.STANDARD,
          requestsPerSecond: 5,
          requestsPerDay: 5000,
        },
      };

      const client = new HttpClient(config);
      const status = client.getRateLimitStatus();

      expect(status?.secondLimit).toBe(5);
      expect(status?.dayLimit).toBe(5000);
    });
  });

  describe("HttpClient GET method and Error Handling - Full Coverage", () => {
    it("should handle successful GET request without rate limiting", async () => {
      mockGet.mockResolvedValue({ data: { success: true } });

      const config = {
        apiKey: "test-key",
        userAgent: "test-app",
      };

      const client = new HttpClient(config);
      const result = await client.get("/test");

      expect(result).toEqual({ success: true });
      expect(mockGet).toHaveBeenCalledWith("/test", {});
    });

    it("should handle successful GET request with parameters", async () => {
      mockGet.mockResolvedValue({ data: { results: [] } });

      const config = {
        apiKey: "test-key",
        userAgent: "test-app",
      };

      const client = new HttpClient(config);
      const params = { page: 1, limit: 10 };
      const result = await client.get("/search", params);

      expect(result).toEqual({ results: [] });
      expect(mockGet).toHaveBeenCalledWith("/search", { params });
    });

    it("should handle successful GET request without parameters", async () => {
      mockGet.mockResolvedValue({ data: { data: "test" } });

      const config = {
        apiKey: "test-key",
        userAgent: "test-app",
      };

      const client = new HttpClient(config);
      const result = await client.get("/test");

      expect(result).toEqual({ data: "test" });
      expect(mockGet).toHaveBeenCalledWith("/test", {});
    });

    it("should handle successful GET request with rate limiting and record request", async () => {
      mockGet.mockResolvedValue({ data: { data: "test" } });

      const config = {
        apiKey: "test-key",
        userAgent: "test-app",
        rateLimit: {
          profile: RateLimitProfile.STANDARD,
        },
      };

      const client = new HttpClient(config);
      const rateLimiter = client.getRateLimiter()!;

      // Mock the rate limiter methods
      const waitSpy = vi.spyOn(rateLimiter, "waitForNextSlot").mockResolvedValue(undefined);
      const recordSpy = vi.spyOn(rateLimiter, "recordRequest").mockImplementation(() => {});

      const result = await client.get("/test");

      expect(result).toEqual({ data: "test" });
      expect(waitSpy).toHaveBeenCalled();
      expect(recordSpy).toHaveBeenCalled(); // This covers lines 134-138
      expect(mockGet).toHaveBeenCalledWith("/test", {});

      waitSpy.mockRestore();
      recordSpy.mockRestore();
    });

    it("should handle error with response data.error", async () => {
      const config = {
        apiKey: "test-key",
        userAgent: "test-app",
      };

      const _client = new HttpClient(config);

      // Get the error handler that was passed to interceptors.response.use
      const errorHandler = mockInterceptorsUse.mock.calls[0][1];

      // Simulate axios error with response
      const axiosError = {
        response: {
          status: 404,
          data: { error: "Resource not found" },
        },
        message: "Request failed",
      };

      expect(() => errorHandler(axiosError)).toThrow(SetlistFMError);
      try {
        errorHandler(axiosError);
      }
      catch (error: any) {
        expect(error.message).toBe("Resource not found");
        expect(error.statusCode).toBe(404);
      }
    });

    it("should handle error with response but no data.error (fallback to error.message)", async () => {
      const config = {
        apiKey: "test-key",
        userAgent: "test-app",
      };

      const _client = new HttpClient(config);

      // Get the error handler that was passed to interceptors.response.use
      const errorHandler = mockInterceptorsUse.mock.calls[0][1];

      // Simulate axios error with response but no data.error
      const axiosError = {
        response: {
          status: 500,
          data: {},
        },
        message: "Internal Server Error",
      };

      expect(() => errorHandler(axiosError)).toThrow(SetlistFMError);
      try {
        errorHandler(axiosError);
      }
      catch (error: any) {
        expect(error.message).toBe("Internal Server Error");
        expect(error.statusCode).toBe(500);
      }
    });

    it("should handle request error (no response received)", async () => {
      const config = {
        apiKey: "test-key",
        userAgent: "test-app",
      };

      const _client = new HttpClient(config);

      // Get the error handler that was passed to interceptors.response.use
      const errorHandler = mockInterceptorsUse.mock.calls[0][1];

      // Simulate axios timeout error (request made but no response)
      const axiosError = {
        request: { timeout: true },
        message: "timeout of 10000ms exceeded",
      };

      expect(() => errorHandler(axiosError)).toThrow(SetlistFMError);
      try {
        errorHandler(axiosError);
      }
      catch (error: any) {
        expect(error.message).toBe("No response received from API");
      }
    });

    it("should handle generic network error", async () => {
      const config = {
        apiKey: "test-key",
        userAgent: "test-app",
      };

      const _client = new HttpClient(config);

      // Get the error handler that was passed to interceptors.response.use
      const errorHandler = mockInterceptorsUse.mock.calls[0][1];

      // Simulate generic axios error (neither response nor request)
      const axiosError = {
        message: "Network Error",
      };

      expect(() => errorHandler(axiosError)).toThrow(SetlistFMError);
      try {
        errorHandler(axiosError);
      }
      catch (error: any) {
        expect(error.message).toBe("Network Error");
      }
    });

    it("should configure axios instance correctly with all options", () => {
      const config = {
        apiKey: "test-api-key",
        userAgent: "test-app (test@example.com)",
        timeout: 5000,
        language: "es",
      };

      const _client = new HttpClient(config);

      // We can't directly test axios.create call params with our current mock setup
      // But we can test that the client was created successfully
      expect(_client).toBeInstanceOf(HttpClient);
    });

    it("should configure axios instance with default timeout when not provided", () => {
      const config = {
        apiKey: "test-key",
        userAgent: "test-app",
      };

      const _client = new HttpClient(config);

      // We can't directly test axios.create call params with our current mock setup
      // But we can test that the client was created successfully
      expect(_client).toBeInstanceOf(HttpClient);
    });
  });
});
