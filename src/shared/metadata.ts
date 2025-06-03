/**
 * @file metadata.ts
 * @description Metadata utilities for setlist.fm API responses.
 * @author tkozzer
 * @module metadata
 */

/**
 * API response metadata.
 */
export type ResponseMetadata = {
  /** Timestamp when the response was generated */
  timestamp: string;
  /** API version used */
  apiVersion: string;
  /** Request ID for debugging */
  requestId?: string;
};

/**
 * Library version and build information.
 */
export type LibraryInfo = {
  /** Library version */
  version: string;
  /** Library name */
  name: string;
  /** Build timestamp */
  buildTime?: string;
  /** Git commit hash */
  commit?: string;
};

/**
 * Creates response metadata from HTTP headers and other sources.
 *
 * @param {Record<string, string>} headers - HTTP response headers.
 * @param {string} apiVersion - API version used for the request.
 * @returns {ResponseMetadata} Response metadata object.
 */
export function createResponseMetadata(
  headers: Record<string, string>,
  apiVersion = "1.0",
): ResponseMetadata {
  const metadata: ResponseMetadata = {
    timestamp: new Date().toISOString(),
    apiVersion,
  };

  // Extract request ID if available
  if (headers["x-request-id"]) {
    metadata.requestId = headers["x-request-id"];
  }

  return metadata;
}

/**
 * Gets library information.
 *
 * @returns {LibraryInfo} Library version and build information.
 */
export function getLibraryInfo(): LibraryInfo {
  // These would typically be injected at build time
  return {
    name: "setlistfm-ts",
    version: "0.1.0", // This would normally be injected at build time
    buildTime: undefined, // This would normally be injected at build time
    commit: undefined, // This would normally be injected at build time
  };
}
