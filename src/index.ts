/**
 * @file index.ts
 * @description Main entry point for the setlistfm-ts library.
 * @author tkozzer
 * @module index
 */

// Main client exports
export { createSetlistFMClient, SetlistFMClient } from "./client";
export type { SetlistFMClientConfig } from "./client";

// Shared types and utilities
export * from "./shared";

// Re-export everything from utils for convenience
export * from "./utils";
// HTTP utilities exports
export { SetlistFMError } from "./utils/http";
export type { HttpClientConfig } from "./utils/http";

// Rate limiting exports
export { RateLimiter, RateLimitProfile } from "./utils/rateLimiter";
export type { RateLimitConfig, RateLimitStatus } from "./utils/rateLimiter";
