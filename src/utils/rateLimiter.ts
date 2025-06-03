/**
 * @file rateLimiter.ts
 * @description Rate limiting utilities for managing API request throttling.
 * @author tkozzer
 * @module rateLimiter
 */

/**
 * Rate limit profile configurations for setlist.fm API.
 */
export enum RateLimitProfile {
  /** Standard profile: 2 requests/second, 1440 requests/day */
  STANDARD = "standard",
  /** Premium profile: 16 requests/second, 50,000 requests/day */
  PREMIUM = "premium",
  /** No rate limiting (advanced users) */
  DISABLED = "disabled",
}

/**
 * Rate limit configuration.
 */
export type RateLimitConfig = {
  /** Rate limit profile to use */
  profile: RateLimitProfile;
  /** Requests per second (overrides profile if specified) */
  requestsPerSecond?: number;
  /** Requests per day (overrides profile if specified) */
  requestsPerDay?: number;
  /** Whether to queue requests when rate limited */
  queueRequests?: boolean;
  /** Maximum queue size for requests */
  maxQueueSize?: number;
  /** Callback for when rate limit is approached */
  onRateLimitApproached?: (remaining: number, resetTime: number) => void;
  /** Callback for when rate limit is exceeded */
  onRateLimitExceeded?: (retryAfter: number) => void;
};

/**
 * Rate limit state tracking.
 */
type RateLimitState = {
  /** Requests made in current second */
  requestsThisSecond: number;
  /** Timestamp of current second window */
  currentSecondWindow: number;
  /** Requests made in current day */
  requestsThisDay: number;
  /** Timestamp of current day window */
  currentDayWindow: number;
  /** Queue of pending requests */
  requestQueue: Array<() => void>;
  /** Whether currently processing queue */
  processingQueue: boolean;
};

/**
 * Rate limit status information.
 */
export type RateLimitStatus = {
  /** Current rate limit profile */
  profile: RateLimitProfile;
  /** Whether a request can be made immediately */
  canMakeRequest: boolean;
  /** Requests made in current second */
  requestsThisSecond: number;
  /** Maximum requests per second */
  secondLimit?: number;
  /** Requests made in current day */
  requestsThisDay: number;
  /** Maximum requests per day */
  dayLimit?: number;
  /** Current queue size */
  queueSize: number;
  /** Milliseconds until next request can be made */
  retryAfter?: number;
};

/**
 * Gets the predefined rate limit settings for a profile.
 *
 * @param {RateLimitProfile} profile - The rate limit profile.
 * @returns {Pick<RateLimitConfig, 'requestsPerSecond' | 'requestsPerDay'>} Rate limit settings.
 */
export function getProfileSettings(profile: RateLimitProfile): Pick<RateLimitConfig, "requestsPerSecond" | "requestsPerDay"> {
  switch (profile) {
    case RateLimitProfile.STANDARD:
      return {
        requestsPerSecond: 2,
        requestsPerDay: 1440,
      };
    case RateLimitProfile.PREMIUM:
      return {
        requestsPerSecond: 16,
        requestsPerDay: 50000,
      };
    case RateLimitProfile.DISABLED:
      return {
        requestsPerSecond: undefined,
        requestsPerDay: undefined,
      };
    default:
      throw new Error(`Unknown rate limit profile: ${profile}`);
  }
}

/**
 * Rate limiter for managing API request throttling.
 */
export class RateLimiter {
  private readonly config: Required<Omit<RateLimitConfig, "requestsPerSecond" | "requestsPerDay" | "onRateLimitApproached" | "onRateLimitExceeded">> & Pick<RateLimitConfig, "requestsPerSecond" | "requestsPerDay" | "onRateLimitApproached" | "onRateLimitExceeded">;
  private readonly state: RateLimitState;

  constructor(config: RateLimitConfig) {
    const profileSettings = getProfileSettings(config.profile);

    this.config = {
      profile: config.profile,
      requestsPerSecond: config.requestsPerSecond ?? profileSettings.requestsPerSecond,
      requestsPerDay: config.requestsPerDay ?? profileSettings.requestsPerDay,
      queueRequests: config.queueRequests ?? true,
      maxQueueSize: config.maxQueueSize ?? 100,
      onRateLimitApproached: config.onRateLimitApproached,
      onRateLimitExceeded: config.onRateLimitExceeded,
    };

    this.state = {
      requestsThisSecond: 0,
      currentSecondWindow: Math.floor(Date.now() / 1000),
      requestsThisDay: 0,
      currentDayWindow: Math.floor(Date.now() / (1000 * 60 * 60 * 24)),
      requestQueue: [],
      processingQueue: false,
    };
  }

  /**
   * Checks if a request can be made immediately.
   *
   * @returns {boolean} True if request can be made immediately.
   */
  canMakeRequest(): boolean {
    if (this.config.profile === RateLimitProfile.DISABLED) {
      return true;
    }

    this.updateWindows();

    const withinSecondLimit = !this.config.requestsPerSecond || this.state.requestsThisSecond < this.config.requestsPerSecond;
    const withinDayLimit = !this.config.requestsPerDay || this.state.requestsThisDay < this.config.requestsPerDay;

    return withinSecondLimit && withinDayLimit;
  }

  /**
   * Records a request being made.
   */
  recordRequest(): void {
    if (this.config.profile === RateLimitProfile.DISABLED) {
      return;
    }

    this.updateWindows();
    this.state.requestsThisSecond++;
    this.state.requestsThisDay++;

    // Check if approaching limits and call callback
    if (this.config.onRateLimitApproached) {
      const secondsRemaining = this.config.requestsPerSecond! - this.state.requestsThisSecond;
      const dayRemaining = this.config.requestsPerDay! - this.state.requestsThisDay;
      const remaining = Math.min(secondsRemaining, dayRemaining);

      if (remaining <= 2) { // Approaching limit
        const resetTime = this.getNextResetTime();
        this.config.onRateLimitApproached(remaining, resetTime);
      }
    }
  }

  /**
   * Waits for the next available request slot.
   *
   * @returns {Promise<void>} Promise that resolves when request can be made.
   */
  async waitForNextSlot(): Promise<void> {
    if (this.config.profile === RateLimitProfile.DISABLED) {
      return Promise.resolve();
    }

    if (this.canMakeRequest()) {
      return Promise.resolve();
    }

    if (!this.config.queueRequests) {
      const retryAfter = this.getRetryAfter();
      if (this.config.onRateLimitExceeded) {
        this.config.onRateLimitExceeded(retryAfter);
      }
      throw new Error(`Rate limit exceeded. Retry after ${retryAfter}ms`);
    }

    return new Promise((resolve, reject) => {
      if (this.state.requestQueue.length >= this.config.maxQueueSize) {
        reject(new Error("Request queue is full"));
        return;
      }

      this.state.requestQueue.push(() => resolve());
      this.processQueue();
    });
  }

  /**
   * Gets the time until the next request can be made.
   *
   * @returns {number} Milliseconds until next request slot.
   */
  getRetryAfter(): number {
    if (this.config.profile === RateLimitProfile.DISABLED) {
      return 0;
    }

    this.updateWindows();

    const secondLimitHit = this.config.requestsPerSecond && this.state.requestsThisSecond >= this.config.requestsPerSecond;
    const dayLimitHit = this.config.requestsPerDay && this.state.requestsThisDay >= this.config.requestsPerDay;

    if (dayLimitHit) {
      // Wait until next day
      const nextDay = (this.state.currentDayWindow + 1) * (1000 * 60 * 60 * 24);
      return nextDay - Date.now();
    }

    if (secondLimitHit) {
      // Wait until next second
      const nextSecond = (this.state.currentSecondWindow + 1) * 1000;
      return nextSecond - Date.now();
    }

    return 0;
  }

  /**
   * Gets the next reset time for rate limits.
   *
   * @returns {number} Timestamp when rate limits reset.
   */
  getNextResetTime(): number {
    if (this.config.profile === RateLimitProfile.DISABLED) {
      return 0;
    }

    const nextSecond = (this.state.currentSecondWindow + 1) * 1000;
    const nextDay = (this.state.currentDayWindow + 1) * (1000 * 60 * 60 * 24);

    return Math.min(nextSecond, nextDay);
  }

  /**
   * Gets current rate limit status.
   *
   * @returns {RateLimitStatus} Current rate limit status.
   */
  getStatus(): RateLimitStatus {
    if (this.config.profile === RateLimitProfile.DISABLED) {
      return {
        profile: this.config.profile,
        canMakeRequest: true,
        requestsThisSecond: 0,
        requestsThisDay: 0,
        queueSize: 0,
      };
    }

    this.updateWindows();

    return {
      profile: this.config.profile,
      canMakeRequest: this.canMakeRequest(),
      requestsThisSecond: this.state.requestsThisSecond,
      secondLimit: this.config.requestsPerSecond,
      requestsThisDay: this.state.requestsThisDay,
      dayLimit: this.config.requestsPerDay,
      queueSize: this.state.requestQueue.length,
      retryAfter: this.getRetryAfter(),
    };
  }

  /**
   * Updates the time windows and resets counters if needed.
   */
  private updateWindows(): void {
    const now = Date.now();
    const currentSecond = Math.floor(now / 1000);
    const currentDay = Math.floor(now / (1000 * 60 * 60 * 24));

    // Reset second counter if in new second
    if (currentSecond > this.state.currentSecondWindow) {
      this.state.requestsThisSecond = 0;
      this.state.currentSecondWindow = currentSecond;
    }

    // Reset day counter if in new day
    if (currentDay > this.state.currentDayWindow) {
      this.state.requestsThisDay = 0;
      this.state.currentDayWindow = currentDay;
    }
  }

  /**
   * Processes the request queue when slots become available.
   */
  private async processQueue(): Promise<void> {
    if (this.state.processingQueue || this.state.requestQueue.length === 0) {
      return;
    }

    this.state.processingQueue = true;

    while (this.state.requestQueue.length > 0) {
      if (this.canMakeRequest()) {
        const resolve = this.state.requestQueue.shift();
        if (resolve) {
          resolve();
        }
      }
      else {
        // Wait for next available slot
        const retryAfter = this.getRetryAfter();
        await new Promise(resolve => setTimeout(resolve, retryAfter));
      }
    }

    this.state.processingQueue = false;
  }
}
