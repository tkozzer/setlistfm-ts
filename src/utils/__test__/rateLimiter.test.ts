/**
 * @file rateLimiter.test.ts
 * @description Tests for the rate limiter utility.
 * @author tkozzer
 * @module rateLimiter
 */

import { getProfileSettings, RateLimiter, RateLimitProfile } from "@utils/rateLimiter";

import { beforeEach, describe, expect, it, vi } from "vitest";

describe("Rate Limiter", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  describe("getProfileSettings", () => {
    it("should return correct settings for STANDARD profile", () => {
      const settings = getProfileSettings(RateLimitProfile.STANDARD);
      expect(settings).toEqual({
        requestsPerSecond: 2,
        requestsPerDay: 1440,
      });
    });

    it("should return correct settings for PREMIUM profile", () => {
      const settings = getProfileSettings(RateLimitProfile.PREMIUM);
      expect(settings).toEqual({
        requestsPerSecond: 16,
        requestsPerDay: 50000,
      });
    });

    it("should return undefined limits for DISABLED profile", () => {
      const settings = getProfileSettings(RateLimitProfile.DISABLED);
      expect(settings).toEqual({
        requestsPerSecond: undefined,
        requestsPerDay: undefined,
      });
    });

    it("should throw error for unknown profile", () => {
      // Test the default case in the switch statement
      expect(() => getProfileSettings("unknown" as any)).toThrow("Unknown rate limit profile: unknown");
    });
  });

  describe("RateLimiter", () => {
    describe("Basic Functionality", () => {
      it("should allow requests immediately when disabled", () => {
        const limiter = new RateLimiter({
          profile: RateLimitProfile.DISABLED,
        });

        expect(limiter.canMakeRequest()).toBe(true);

        const status = limiter.getStatus();
        expect(status.canMakeRequest).toBe(true);
        expect(status.profile).toBe(RateLimitProfile.DISABLED);
        expect(status.requestsThisSecond).toBe(0);
        expect(status.requestsThisDay).toBe(0);
        expect(status.queueSize).toBe(0);
      });

      it("should track requests for STANDARD profile", () => {
        const limiter = new RateLimiter({
          profile: RateLimitProfile.STANDARD,
        });

        expect(limiter.canMakeRequest()).toBe(true);

        // Make first request
        limiter.recordRequest();
        expect(limiter.getStatus().requestsThisSecond).toBe(1);
        expect(limiter.canMakeRequest()).toBe(true);

        // Make second request
        limiter.recordRequest();
        expect(limiter.getStatus().requestsThisSecond).toBe(2);
        expect(limiter.canMakeRequest()).toBe(false); // Should hit limit
      });

      it("should track requests for PREMIUM profile", () => {
        const limiter = new RateLimiter({
          profile: RateLimitProfile.PREMIUM,
        });

        expect(limiter.canMakeRequest()).toBe(true);

        // Make multiple requests
        for (let i = 0; i < 16; i++) {
          limiter.recordRequest();
        }

        expect(limiter.getStatus().requestsThisSecond).toBe(16);
        expect(limiter.canMakeRequest()).toBe(false); // Should hit limit
      });

      it("should allow custom rate limits that override profile", () => {
        const limiter = new RateLimiter({
          profile: RateLimitProfile.STANDARD,
          requestsPerSecond: 5, // Override standard limit
        });

        for (let i = 0; i < 5; i++) {
          expect(limiter.canMakeRequest()).toBe(true);
          limiter.recordRequest();
        }

        expect(limiter.canMakeRequest()).toBe(false); // Should hit custom limit
        expect(limiter.getStatus().secondLimit).toBe(5);
      });

      it("should record requests correctly for disabled profile", () => {
        const limiter = new RateLimiter({
          profile: RateLimitProfile.DISABLED,
        });

        // Should not track requests when disabled
        limiter.recordRequest();
        limiter.recordRequest();

        expect(limiter.getStatus().requestsThisSecond).toBe(0);
        expect(limiter.getStatus().requestsThisDay).toBe(0);
      });
    });

    describe("Day Limit Testing", () => {
      it("should handle day limit correctly", () => {
        const limiter = new RateLimiter({
          profile: RateLimitProfile.STANDARD,
          requestsPerDay: 2, // Very low day limit for testing
        });

        // Use up day limit
        limiter.recordRequest();
        limiter.recordRequest();

        expect(limiter.canMakeRequest()).toBe(false);
        expect(limiter.getStatus().requestsThisDay).toBe(2);
      });

      it("should calculate retry after for day limit correctly", () => {
        vi.useFakeTimers();

        const limiter = new RateLimiter({
          profile: RateLimitProfile.STANDARD,
          requestsPerDay: 1, // Very low day limit
        });

        // Hit day limit
        limiter.recordRequest();
        expect(limiter.canMakeRequest()).toBe(false);

        const retryAfter = limiter.getRetryAfter();
        expect(retryAfter).toBeGreaterThan(0);
        // Should be less than 24 hours in milliseconds
        expect(retryAfter).toBeLessThanOrEqual(24 * 60 * 60 * 1000);

        vi.useRealTimers();
      });
    });

    describe("Second Limit Testing", () => {
      it("should calculate retry after for second limit correctly", () => {
        vi.useFakeTimers();

        const limiter = new RateLimiter({
          profile: RateLimitProfile.STANDARD,
        });

        // Hit the rate limit
        limiter.recordRequest();
        limiter.recordRequest();

        const retryAfter = limiter.getRetryAfter();
        expect(retryAfter).toBeGreaterThan(0);
        expect(retryAfter).toBeLessThanOrEqual(1000); // Should be within a second

        vi.useRealTimers();
      });

      it("should return 0 retry after when no limits are hit", () => {
        const limiter = new RateLimiter({
          profile: RateLimitProfile.STANDARD,
        });

        // No requests made yet
        const retryAfter = limiter.getRetryAfter();
        expect(retryAfter).toBe(0);
      });

      it("should return 0 retry after for disabled profile", () => {
        const limiter = new RateLimiter({
          profile: RateLimitProfile.DISABLED,
        });

        const retryAfter = limiter.getRetryAfter();
        expect(retryAfter).toBe(0);
      });
    });

    describe("Next Reset Time", () => {
      it("should return 0 for disabled profile", () => {
        const limiter = new RateLimiter({
          profile: RateLimitProfile.DISABLED,
        });

        const resetTime = limiter.getNextResetTime();
        expect(resetTime).toBe(0);
      });

      it("should return next reset time for enabled profile", () => {
        const limiter = new RateLimiter({
          profile: RateLimitProfile.STANDARD,
        });

        const resetTime = limiter.getNextResetTime();
        expect(resetTime).toBeGreaterThan(Date.now());
      });
    });

    describe("Callback Testing", () => {
      it("should call rate limit callbacks correctly", async () => {
        const onApproached = vi.fn();
        const onExceeded = vi.fn();

        const limiter = new RateLimiter({
          profile: RateLimitProfile.STANDARD,
          queueRequests: false,
          onRateLimitApproached: onApproached,
          onRateLimitExceeded: onExceeded,
        });

        // Make requests to approach limit
        limiter.recordRequest();
        limiter.recordRequest(); // This should trigger onApproached callback

        expect(onApproached).toHaveBeenCalled();
        const [remaining, resetTime] = onApproached.mock.calls[0];
        expect(remaining).toBeLessThanOrEqual(2);
        expect(resetTime).toBeGreaterThan(0);

        // Try to exceed limit
        try {
          await limiter.waitForNextSlot();
        }
        catch (error) {
          expect(onExceeded).toHaveBeenCalled();
          expect(error).toBeInstanceOf(Error);
          expect((error as Error).message).toContain("Rate limit exceeded");
        }
      });

      it("should not call onRateLimitApproached if callback not provided", () => {
        const limiter = new RateLimiter({
          profile: RateLimitProfile.STANDARD,
        });

        // Make requests to approach limit - should not throw
        limiter.recordRequest();
        limiter.recordRequest();

        // Should not throw error when callback is not provided
        expect(() => limiter.recordRequest()).not.toThrow();
      });

      it("should not call onRateLimitExceeded if callback not provided", async () => {
        const limiter = new RateLimiter({
          profile: RateLimitProfile.STANDARD,
          queueRequests: false,
        });

        // Hit rate limit
        limiter.recordRequest();
        limiter.recordRequest();

        // Should throw error but not call callback
        await expect(limiter.waitForNextSlot()).rejects.toThrow("Rate limit exceeded");
      });
    });

    describe("Queue Processing", () => {
      it("should resolve immediately when can make request", async () => {
        const limiter = new RateLimiter({
          profile: RateLimitProfile.STANDARD,
        });

        // Should resolve immediately since no requests made yet
        await expect(limiter.waitForNextSlot()).resolves.toBeUndefined();
      });

      it("should resolve immediately for disabled profile", async () => {
        const limiter = new RateLimiter({
          profile: RateLimitProfile.DISABLED,
        });

        await expect(limiter.waitForNextSlot()).resolves.toBeUndefined();
      });

      it("should reject when queue is full", async () => {
        const limiter = new RateLimiter({
          profile: RateLimitProfile.STANDARD,
          maxQueueSize: 1,
        });

        // Hit rate limit
        limiter.recordRequest();
        limiter.recordRequest();

        // First queued request should be accepted
        const promise1 = limiter.waitForNextSlot();

        // Second queued request should be rejected (queue full)
        await expect(limiter.waitForNextSlot()).rejects.toThrow("Request queue is full");

        // Clean up the first promise
        vi.useFakeTimers();
        vi.advanceTimersByTime(1000);
        await promise1;
        vi.useRealTimers();
      });

      it("should process queue when requests become available", async () => {
        vi.useFakeTimers();

        const limiter = new RateLimiter({
          profile: RateLimitProfile.STANDARD,
          requestsPerSecond: 1, // Very restrictive for testing
        });

        // Hit rate limit
        limiter.recordRequest();

        // Queue a request
        const promise = limiter.waitForNextSlot();

        // Advance time to next second
        vi.advanceTimersByTime(1000);

        // Should resolve after time passes
        await expect(promise).resolves.toBeUndefined();

        vi.useRealTimers();
      });

      it("should handle multiple queued requests", async () => {
        vi.useFakeTimers();

        const limiter = new RateLimiter({
          profile: RateLimitProfile.STANDARD,
          requestsPerSecond: 1,
          maxQueueSize: 3,
        });

        // Hit rate limit
        limiter.recordRequest();

        // Queue multiple requests
        const promises = [
          limiter.waitForNextSlot(),
          limiter.waitForNextSlot(),
        ];

        // Advance time to process queue
        vi.advanceTimersByTime(2000);

        // Both should resolve
        await expect(Promise.all(promises)).resolves.toEqual([undefined, undefined]);

        vi.useRealTimers();
      });
    });

    describe("Time Window Updates", () => {
      it("should reset second counter in new second", async () => {
        vi.useFakeTimers();

        const limiter = new RateLimiter({
          profile: RateLimitProfile.STANDARD,
        });

        // Hit second limit
        limiter.recordRequest();
        limiter.recordRequest();
        expect(limiter.canMakeRequest()).toBe(false);

        // Advance to next second
        vi.advanceTimersByTime(1000);

        // Should be able to make requests again
        expect(limiter.canMakeRequest()).toBe(true);
        expect(limiter.getStatus().requestsThisSecond).toBe(0);

        vi.useRealTimers();
      });

      it("should reset day counter in new day", async () => {
        vi.useFakeTimers();

        const limiter = new RateLimiter({
          profile: RateLimitProfile.STANDARD,
          requestsPerDay: 1,
        });

        // Hit day limit
        limiter.recordRequest();
        expect(limiter.canMakeRequest()).toBe(false);

        // Advance to next day
        vi.advanceTimersByTime(24 * 60 * 60 * 1000);

        // Should be able to make requests again
        expect(limiter.canMakeRequest()).toBe(true);
        expect(limiter.getStatus().requestsThisDay).toBe(0);

        vi.useRealTimers();
      });
    });

    describe("Configuration Options", () => {
      it("should use default configuration values", () => {
        const limiter = new RateLimiter({
          profile: RateLimitProfile.STANDARD,
        });

        const status = limiter.getStatus();
        expect(status.secondLimit).toBe(2);
        expect(status.dayLimit).toBe(1440);
      });

      it("should override configuration values", () => {
        const limiter = new RateLimiter({
          profile: RateLimitProfile.STANDARD,
          requestsPerSecond: 10,
          requestsPerDay: 5000,
          maxQueueSize: 50,
          queueRequests: false,
        });

        const status = limiter.getStatus();
        expect(status.secondLimit).toBe(10);
        expect(status.dayLimit).toBe(5000);
      });

      it("should handle custom day limits", () => {
        const limiter = new RateLimiter({
          profile: RateLimitProfile.PREMIUM,
          requestsPerDay: 100, // Override premium day limit
        });

        const status = limiter.getStatus();
        expect(status.dayLimit).toBe(100);
        expect(status.secondLimit).toBe(16); // Should keep premium second limit
      });
    });

    describe("Edge Cases", () => {
      it("should handle undefined limits correctly", () => {
        const limiter = new RateLimiter({
          profile: RateLimitProfile.DISABLED,
        });

        // Make many requests - should never be limited
        for (let i = 0; i < 1000; i++) {
          expect(limiter.canMakeRequest()).toBe(true);
          limiter.recordRequest();
        }
      });

      it("should handle approaching limit with remaining > 2", () => {
        const onApproached = vi.fn();

        const limiter = new RateLimiter({
          profile: RateLimitProfile.STANDARD,
          requestsPerSecond: 10, // Higher limit so we don't trigger approaching callback
          onRateLimitApproached: onApproached,
        });

        // Make only one request (remaining will be > 2)
        limiter.recordRequest();

        // Callback should not be called
        expect(onApproached).not.toHaveBeenCalled();
      });

      it("should return complete status object", () => {
        const limiter = new RateLimiter({
          profile: RateLimitProfile.STANDARD,
        });

        limiter.recordRequest();

        const status = limiter.getStatus();
        expect(status).toHaveProperty("profile");
        expect(status).toHaveProperty("canMakeRequest");
        expect(status).toHaveProperty("requestsThisSecond");
        expect(status).toHaveProperty("secondLimit");
        expect(status).toHaveProperty("requestsThisDay");
        expect(status).toHaveProperty("dayLimit");
        expect(status).toHaveProperty("queueSize");
        expect(status).toHaveProperty("retryAfter");
      });

      it("should handle approaching limit callback with undefined day limit", () => {
        const onApproached = vi.fn();

        const limiter = new RateLimiter({
          profile: RateLimitProfile.STANDARD,
          requestsPerDay: undefined, // No day limit - will be Infinity in calculation
          requestsPerSecond: 3, // Low second limit
          onRateLimitApproached: onApproached,
        });

        // Make requests to approach second limit (remaining will be <= 2)
        limiter.recordRequest(); // remaining = 2
        expect(onApproached).toHaveBeenCalledTimes(1);

        limiter.recordRequest(); // remaining = 1
        expect(onApproached).toHaveBeenCalledTimes(2);

        // This tests the branch where dayRemaining is Infinity but secondsRemaining is not
        const [remaining] = onApproached.mock.calls[1];
        expect(remaining).toBe(1);
      });

      it("should handle approaching limit callback with undefined second limit", () => {
        const onApproached = vi.fn();

        const limiter = new RateLimiter({
          profile: RateLimitProfile.STANDARD,
          requestsPerSecond: undefined, // No second limit - will be Infinity in calculation
          requestsPerDay: 3, // Set to 3 to trigger callback
          onRateLimitApproached: onApproached,
        });

        // Make requests to approach day limit - this tests the undefined requestsPerSecond branch
        limiter.recordRequest(); // remaining = 2, triggers callback
        limiter.recordRequest(); // remaining = 1, triggers callback

        // Just verify the callback was called - this tests the Infinity branch for secondsRemaining
        expect(onApproached).toHaveBeenCalled();
      });

      it("should test both defined and undefined limit branches in callback calculation", () => {
        const onApproached = vi.fn();

        // Test with both limits defined first
        const limiterDefined = new RateLimiter({
          profile: RateLimitProfile.STANDARD,
          requestsPerSecond: 3,
          requestsPerDay: 3,
          onRateLimitApproached: onApproached,
        });

        limiterDefined.recordRequest(); // Should trigger with both defined
        expect(onApproached).toHaveBeenCalled();

        // Reset the mock
        onApproached.mockReset();

        // Test with one undefined - different path than previous test
        const limiterUndefinedSecond = new RateLimiter({
          profile: RateLimitProfile.STANDARD,
          requestsPerSecond: undefined,
          requestsPerDay: 3,
          onRateLimitApproached: onApproached,
        });

        limiterUndefinedSecond.recordRequest(); // Test undefined requestsPerSecond path
        expect(onApproached).toHaveBeenCalled();
      });
    });
  });
});
