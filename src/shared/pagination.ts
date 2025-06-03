/**
 * @file pagination.ts
 * @description Pagination utilities for setlist.fm API responses.
 * @author tkozzer
 * @module pagination
 */

import type { PaginatedResponse, PaginationParams } from "./types";

/**
 * Extended pagination parameters with additional options.
 */
export type ExtendedPaginationParams = PaginationParams & {
  /** Maximum number of pages to fetch (for auto-pagination) */
  maxPages?: number;
  /** Delay between requests in milliseconds (for auto-pagination) */
  delay?: number;
};

/**
 * Metadata about pagination state.
 */
export type PaginationInfo = {
  /** Current page number */
  currentPage: number;
  /** Total number of items across all pages */
  totalItems: number;
  /** Items per page */
  itemsPerPage: number;
  /** Total number of pages */
  totalPages: number;
  /** Whether there are more pages available */
  hasNextPage: boolean;
  /** Whether there are previous pages */
  hasPrevPage: boolean;
};

/**
 * Extracts pagination information from an API response.
 *
 * @param {PaginatedResponse<any>} response - The paginated API response.
 * @returns {PaginationInfo} Pagination metadata.
 */
export function extractPaginationInfo(response: PaginatedResponse<any>): PaginationInfo {
  const totalPages = Math.ceil(response.total / response.itemsPerPage);

  return {
    currentPage: response.page,
    totalItems: response.total,
    itemsPerPage: response.itemsPerPage,
    totalPages,
    hasNextPage: response.page < totalPages,
    hasPrevPage: response.page > 1,
  };
}

/**
 * Creates pagination parameters for the next page.
 *
 * @param {PaginationInfo} info - Current pagination info.
 * @returns {PaginationParams | null} Parameters for next page, or null if no next page.
 */
export function getNextPageParams(info: PaginationInfo): PaginationParams | null {
  if (!info.hasNextPage) {
    return null;
  }

  return {
    p: info.currentPage + 1,
  };
}

/**
 * Creates pagination parameters for the previous page.
 *
 * @param {PaginationInfo} info - Current pagination info.
 * @returns {PaginationParams | null} Parameters for previous page, or null if no previous page.
 */
export function getPrevPageParams(info: PaginationInfo): PaginationParams | null {
  if (!info.hasPrevPage) {
    return null;
  }

  return {
    p: info.currentPage - 1,
  };
}

/**
 * Utility function to create a delay between requests.
 *
 * @param {number} ms - Milliseconds to delay.
 * @returns {Promise<void>} Promise that resolves after the delay.
 */
export function delay(ms: number): Promise<void> {
  return new Promise(resolve => setTimeout(resolve, ms));
}

/**
 * Validates pagination parameters.
 *
 * @param {PaginationParams} params - Pagination parameters to validate.
 * @throws {Error} If parameters are invalid.
 */
export function validatePaginationParams(params: PaginationParams): void {
  if (params.p !== undefined) {
    if (params.p < 1) {
      throw new Error("Page number must be greater than 0");
    }
    if (!Number.isInteger(params.p)) {
      throw new TypeError("Page number must be an integer");
    }
  }
}
