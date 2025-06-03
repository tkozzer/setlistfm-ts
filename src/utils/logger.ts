/**
 * @file logger.ts
 * @description Simple logging utility for development and debugging.
 * @author tkozzer
 * @module logger
 */

/** Log levels for the logger */
export enum LogLevel {
  /** No logging output */
  SILENT = -1,
  ERROR = 0,
  WARN = 1,
  INFO = 2,
  DEBUG = 3,
}

/**
 * Configuration options for the logger.
 */
export type LoggerConfig = {
  /** Minimum log level to output */
  level: LogLevel;
  /** Whether to include timestamps in log output */
  includeTimestamp?: boolean;
  /** Whether to include file and line location in log output */
  includeLocation?: boolean;
  /** Custom prefix for log messages */
  prefix?: string;
};

/**
 * Simple logger for debugging and development.
 */
export class Logger {
  private readonly config: Required<LoggerConfig>;

  constructor(config: LoggerConfig) {
    this.config = {
      level: config.level,
      includeTimestamp: config.includeTimestamp ?? true,
      includeLocation: config.includeLocation ?? false,
      prefix: config.prefix ?? "[SetlistFM]",
    };
  }

  /**
   * Logs an error message.
   *
   * @param {string} message - The message to log.
   * @param {...any} args - Additional arguments to log.
   */
  error(message: string, ...args: any[]): void {
    if (this.config.level >= LogLevel.ERROR) {
      this.log("ERROR", message, ...args);
    }
  }

  /**
   * Logs a warning message.
   *
   * @param {string} message - The message to log.
   * @param {...any} args - Additional arguments to log.
   */
  warn(message: string, ...args: any[]): void {
    if (this.config.level >= LogLevel.WARN) {
      this.log("WARN", message, ...args);
    }
  }

  /**
   * Logs an info message.
   *
   * @param {string} message - The message to log.
   * @param {...any} args - Additional arguments to log.
   */
  info(message: string, ...args: any[]): void {
    if (this.config.level >= LogLevel.INFO) {
      this.log("INFO", message, ...args);
    }
  }

  /**
   * Logs a debug message.
   *
   * @param {string} message - The message to log.
   * @param {...any} args - Additional arguments to log.
   */
  debug(message: string, ...args: any[]): void {
    if (this.config.level >= LogLevel.DEBUG) {
      this.log("DEBUG", message, ...args);
    }
  }

  /**
   * Extracts the caller's file and line information from the stack trace.
   *
   * @returns {string | null} The caller location or null if not available.
   */
  private getCallerLocation(): string | null {
    if (!this.config.includeLocation) {
      return null;
    }

    try {
      const stack = new Error("Stack trace for logging").stack;
      if (!stack)
        return null;

      const lines = stack.split("\n");
      // Skip the first few lines which are internal to the logger
      // Line 0: "Error"
      // Line 1: getCallerLocation
      // Line 2: log method
      // Line 3: error/warn/info/debug method
      // Line 4: actual caller (what we want)
      const callerLine = lines[4];

      if (!callerLine)
        return null;

      // Extract file and line number from stack trace
      // Format varies by environment but typically: "at functionName (file:line:column)"
      const match = callerLine.match(/\(([^)]+):(\d+):\d+\)/)
        || callerLine.match(/at ([^:]+):(\d+):\d+/);

      if (match) {
        const [, filePath, lineNumber] = match;
        const fileName = filePath.split("/").pop() || filePath;
        return `${fileName}:${lineNumber}`;
      }

      return null;
    }
    catch {
      return null;
    }
  }

  /**
   * Internal logging method that formats and outputs messages.
   *
   * @param {string} level - The log level string.
   * @param {string} message - The message to log.
   * @param {...any} args - Additional arguments to log.
   */
  private log(level: string, message: string, ...args: any[]): void {
    const timestamp = this.config.includeTimestamp
      ? new Date().toISOString()
      : null;

    const location = this.getCallerLocation();

    const parts = [
      timestamp && `[${timestamp}]`,
      location && `[${location}]`,
      this.config.prefix,
      `[${level}]`,
      message,
    ].filter(Boolean);

    // eslint-disable-next-line no-console
    console.log(parts.join(" "), ...args);
  }
}

/**
 * Creates a new logger instance.
 *
 * @param {LoggerConfig} config - Configuration for the logger.
 * @returns {Logger} A new logger instance.
 *
 * @example
 * ```ts
 * const logger = createLogger({
 *   level: LogLevel.INFO,
 *   includeTimestamp: true,
 *   includeLocation: true
 * });
 * logger.info('Client initialized');
 * // Output: [2023-01-01T12:00:00.000Z] [client.ts:15] [SetlistFM] [INFO] Client initialized
 * ```
 */
export function createLogger(config: LoggerConfig): Logger {
  return new Logger(config);
}

/**
 * Creates a silent logger that produces no output.
 *
 * @returns {Logger} A silent logger instance.
 *
 * @example
 * ```ts
 * const logger = createSilentLogger();
 * logger.error('This will not be logged');
 * ```
 */
export function createSilentLogger(): Logger {
  return new Logger({ level: LogLevel.SILENT });
}

/** Default logger instance for the library */
export const defaultLogger = createLogger({
  level: LogLevel.WARN,
  includeTimestamp: true,
  prefix: "[SetlistFM]",
});
