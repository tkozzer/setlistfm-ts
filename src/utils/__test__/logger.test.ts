/**
 * @file logger.test.ts
 * @description Tests for the logger utility.
 * @author tkozzer
 * @module logger
 */

/* eslint-disable no-console */

import { beforeEach, describe, expect, it, vi } from "vitest";

import { createLogger, createSilentLogger, defaultLogger, Logger, LogLevel } from "../logger";

describe("Logger", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    // Mock console.log to capture output
    vi.spyOn(console, "log").mockImplementation(() => {});
  });

  describe("LogLevel enum", () => {
    it("should have correct numeric values", () => {
      expect(LogLevel.SILENT).toBe(-1);
      expect(LogLevel.ERROR).toBe(0);
      expect(LogLevel.WARN).toBe(1);
      expect(LogLevel.INFO).toBe(2);
      expect(LogLevel.DEBUG).toBe(3);
    });
  });

  describe("Logger class", () => {
    describe("Constructor and Configuration", () => {
      it("should create logger with minimal config", () => {
        const logger = new Logger({ level: LogLevel.INFO });

        // Test that defaults are applied
        logger.info("test message");

        expect(console.log).toHaveBeenCalledWith(
          expect.stringContaining("[SetlistFM] [INFO] test message"),
        );
      });

      it("should create logger with full config", () => {
        const logger = new Logger({
          level: LogLevel.DEBUG,
          includeTimestamp: false,
          prefix: "[CustomPrefix]",
        });

        logger.debug("test message");

        expect(console.log).toHaveBeenCalledWith(
          "[CustomPrefix] [DEBUG] test message",
        );
      });

      it("should handle includeTimestamp: true", () => {
        const logger = new Logger({
          level: LogLevel.INFO,
          includeTimestamp: true,
        });

        logger.info("test message");

        // Should include timestamp in the format [YYYY-MM-DDTHH:mm:ss.sssZ]
        expect(console.log).toHaveBeenCalledWith(
          expect.stringMatching(/^\[\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z\] \[SetlistFM\] \[INFO\] test message$/),
        );
      });

      it("should handle includeTimestamp: false", () => {
        const logger = new Logger({
          level: LogLevel.INFO,
          includeTimestamp: false,
        });

        logger.info("test message");

        expect(console.log).toHaveBeenCalledWith(
          "[SetlistFM] [INFO] test message",
        );
      });

      it("should handle custom prefix", () => {
        const logger = new Logger({
          level: LogLevel.INFO,
          prefix: "[MyApp]",
        });

        logger.info("test message");

        expect(console.log).toHaveBeenCalledWith(
          expect.stringContaining("[MyApp] [INFO] test message"),
        );
      });

      it("should handle includeLocation: true", () => {
        const logger = new Logger({
          level: LogLevel.INFO,
          includeTimestamp: false,
          includeLocation: true,
        });

        logger.info("test message");

        // Should include file and line number in the format [filename:line]
        expect(console.log).toHaveBeenCalledWith(
          expect.stringMatching(/\[.+\.test\.ts:\d+\] \[SetlistFM\] \[INFO\] test message$/),
        );
      });

      it("should handle includeLocation: false", () => {
        const logger = new Logger({
          level: LogLevel.INFO,
          includeTimestamp: false,
          includeLocation: false,
        });

        logger.info("test message");

        expect(console.log).toHaveBeenCalledWith(
          "[SetlistFM] [INFO] test message",
        );
      });

      it("should handle both timestamp and location", () => {
        const logger = new Logger({
          level: LogLevel.INFO,
          includeTimestamp: true,
          includeLocation: true,
        });

        logger.info("test message");

        // Should include both timestamp and location
        expect(console.log).toHaveBeenCalledWith(
          expect.stringMatching(/^\[\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z\] \[.+\.test\.ts:\d+\] \[SetlistFM\] \[INFO\] test message$/),
        );
      });
    });

    describe("Logging Methods", () => {
      it("should log error messages when level allows", () => {
        const logger = new Logger({
          level: LogLevel.ERROR,
          includeTimestamp: false,
        });

        logger.error("error message");

        expect(console.log).toHaveBeenCalledWith(
          "[SetlistFM] [ERROR] error message",
        );
      });

      it("should log warn messages when level allows", () => {
        const logger = new Logger({
          level: LogLevel.WARN,
          includeTimestamp: false,
        });

        logger.warn("warning message");

        expect(console.log).toHaveBeenCalledWith(
          "[SetlistFM] [WARN] warning message",
        );
      });

      it("should log info messages when level allows", () => {
        const logger = new Logger({
          level: LogLevel.INFO,
          includeTimestamp: false,
        });

        logger.info("info message");

        expect(console.log).toHaveBeenCalledWith(
          "[SetlistFM] [INFO] info message",
        );
      });

      it("should log debug messages when level allows", () => {
        const logger = new Logger({
          level: LogLevel.DEBUG,
          includeTimestamp: false,
        });

        logger.debug("debug message");

        expect(console.log).toHaveBeenCalledWith(
          "[SetlistFM] [DEBUG] debug message",
        );
      });

      it("should handle additional arguments", () => {
        const logger = new Logger({
          level: LogLevel.INFO,
          includeTimestamp: false,
        });

        const obj = { key: "value" };
        const num = 42;

        logger.info("message with args", obj, num);

        expect(console.log).toHaveBeenCalledWith(
          "[SetlistFM] [INFO] message with args",
          obj,
          num,
        );
      });
    });

    describe("Level Filtering", () => {
      it("should not log when level is too low - ERROR level", () => {
        const logger = new Logger({ level: LogLevel.ERROR });

        logger.warn("should not log");
        logger.info("should not log");
        logger.debug("should not log");

        expect(console.log).not.toHaveBeenCalled();
      });

      it("should not log when level is too low - WARN level", () => {
        const logger = new Logger({ level: LogLevel.WARN });

        logger.info("should not log");
        logger.debug("should not log");

        expect(console.log).not.toHaveBeenCalled();
      });

      it("should not log when level is too low - INFO level", () => {
        const logger = new Logger({ level: LogLevel.INFO });

        logger.debug("should not log");

        expect(console.log).not.toHaveBeenCalled();
      });

      it("should not log anything when level is SILENT", () => {
        const logger = new Logger({ level: LogLevel.SILENT });

        logger.error("should not log");
        logger.warn("should not log");
        logger.info("should not log");
        logger.debug("should not log");

        expect(console.log).not.toHaveBeenCalled();
      });

      it("should log error at WARN level", () => {
        const logger = new Logger({
          level: LogLevel.WARN,
          includeTimestamp: false,
        });

        logger.error("error message");

        expect(console.log).toHaveBeenCalledWith(
          "[SetlistFM] [ERROR] error message",
        );
      });

      it("should log error and warn at INFO level", () => {
        const logger = new Logger({
          level: LogLevel.INFO,
          includeTimestamp: false,
        });

        logger.error("error message");
        logger.warn("warn message");

        expect(console.log).toHaveBeenCalledTimes(2);
        expect(console.log).toHaveBeenNthCalledWith(1, "[SetlistFM] [ERROR] error message");
        expect(console.log).toHaveBeenNthCalledWith(2, "[SetlistFM] [WARN] warn message");
      });

      it("should log all levels at DEBUG level", () => {
        const logger = new Logger({
          level: LogLevel.DEBUG,
          includeTimestamp: false,
        });

        logger.error("error message");
        logger.warn("warn message");
        logger.info("info message");
        logger.debug("debug message");

        expect(console.log).toHaveBeenCalledTimes(4);
        expect(console.log).toHaveBeenNthCalledWith(1, "[SetlistFM] [ERROR] error message");
        expect(console.log).toHaveBeenNthCalledWith(2, "[SetlistFM] [WARN] warn message");
        expect(console.log).toHaveBeenNthCalledWith(3, "[SetlistFM] [INFO] info message");
        expect(console.log).toHaveBeenNthCalledWith(4, "[SetlistFM] [DEBUG] debug message");
      });
    });

    describe("Timestamp Formatting", () => {
      it("should format timestamp correctly", () => {
        vi.useFakeTimers();
        const mockDate = new Date("2023-01-01T12:00:00.000Z");
        vi.setSystemTime(mockDate);

        const logger = new Logger({
          level: LogLevel.INFO,
          includeTimestamp: true,
        });

        logger.info("test message");

        expect(console.log).toHaveBeenCalledWith(
          "[2023-01-01T12:00:00.000Z] [SetlistFM] [INFO] test message",
        );

        vi.useRealTimers();
      });

      it("should omit timestamp when includeTimestamp is false", () => {
        const logger = new Logger({
          level: LogLevel.INFO,
          includeTimestamp: false,
        });

        logger.info("test message");

        const call = (console.log as any).mock.calls[0][0];
        expect(call).not.toMatch(/^\[\d{4}-\d{2}-\d{2}T/);
        expect(call).toBe("[SetlistFM] [INFO] test message");
      });
    });

    describe("Private log method", () => {
      it("should filter out falsy parts correctly", () => {
        const logger = new Logger({
          level: LogLevel.INFO,
          includeTimestamp: false, // This makes timestamp null
          prefix: "", // Empty prefix should be filtered out
        });

        logger.info("test message");

        // Should only include non-empty parts
        expect(console.log).toHaveBeenCalledWith(
          "[INFO] test message",
        );
      });
    });
  });

  describe("createLogger function", () => {
    it("should create a Logger instance", () => {
      const logger = createLogger({ level: LogLevel.INFO });

      expect(logger).toBeInstanceOf(Logger);
    });

    it("should pass config correctly to Logger constructor", () => {
      const config = {
        level: LogLevel.DEBUG,
        includeTimestamp: false,
        prefix: "[Test]",
      };

      const logger = createLogger(config);
      logger.debug("test");

      expect(console.log).toHaveBeenCalledWith(
        "[Test] [DEBUG] test",
      );
    });
  });

  describe("createSilentLogger function", () => {
    it("should create a Logger instance", () => {
      const logger = createSilentLogger();

      expect(logger).toBeInstanceOf(Logger);
    });

    it("should create a logger that produces no output", () => {
      const logger = createSilentLogger();

      logger.error("error message");
      logger.warn("warn message");
      logger.info("info message");
      logger.debug("debug message");

      expect(console.log).not.toHaveBeenCalled();
    });

    it("should have SILENT level behavior", () => {
      const logger = createSilentLogger();

      // Verify that even ERROR level messages don't get logged
      logger.error("test");
      expect(console.log).not.toHaveBeenCalled();
    });
  });

  describe("defaultLogger", () => {
    it("should be a Logger instance", () => {
      expect(defaultLogger).toBeInstanceOf(Logger);
    });

    it("should have WARN level by default", () => {
      // Test that it logs warn but not info
      defaultLogger.warn("warn message");
      defaultLogger.info("info message");

      // Should only log the warn message
      expect(console.log).toHaveBeenCalledTimes(1);
      expect(console.log).toHaveBeenCalledWith(
        expect.stringContaining("[SetlistFM] [WARN] warn message"),
      );
    });

    it("should include timestamp by default", () => {
      defaultLogger.warn("test message");

      expect(console.log).toHaveBeenCalledWith(
        expect.stringMatching(/^\[\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z\] \[SetlistFM\] \[WARN\] test message$/),
      );
    });

    it("should use [SetlistFM] prefix by default", () => {
      defaultLogger.error("test message");

      expect(console.log).toHaveBeenCalledWith(
        expect.stringContaining("[SetlistFM] [ERROR] test message"),
      );
    });
  });

  describe("Edge Cases", () => {
    it("should handle empty message", () => {
      const logger = new Logger({
        level: LogLevel.INFO,
        includeTimestamp: false,
      });

      logger.info("");

      expect(console.log).toHaveBeenCalledWith(
        "[SetlistFM] [INFO]",
      );
    });

    it("should handle message with special characters", () => {
      const logger = new Logger({
        level: LogLevel.INFO,
        includeTimestamp: false,
      });

      logger.info("Message with %s and %d placeholders");

      expect(console.log).toHaveBeenCalledWith(
        "[SetlistFM] [INFO] Message with %s and %d placeholders",
      );
    });

    it("should handle complex objects as additional arguments", () => {
      const logger = new Logger({
        level: LogLevel.INFO,
        includeTimestamp: false,
      });

      const complexObj = {
        nested: { value: 42 },
        array: [1, 2, 3],
        func: () => "test",
      };

      logger.info("Complex object:", complexObj);

      expect(console.log).toHaveBeenCalledWith(
        "[SetlistFM] [INFO] Complex object:",
        complexObj,
      );
    });
  });

  describe("Location Detection", () => {
    it("should gracefully handle when stack trace is not available", () => {
      const logger = new Logger({
        level: LogLevel.INFO,
        includeTimestamp: false,
        includeLocation: true,
      });

      // Mock Error to return undefined stack
      const originalError = globalThis.Error;
      globalThis.Error = class MockError extends originalError {
        constructor(message?: string) {
          super(message);
          this.stack = undefined;
        }
      } as any;

      logger.info("test message");

      // Should still log without location
      expect(console.log).toHaveBeenCalledWith(
        "[SetlistFM] [INFO] test message",
      );

      // Restore original Error
      globalThis.Error = originalError;
    });

    it("should handle different stack trace formats", () => {
      const logger = new Logger({
        level: LogLevel.INFO,
        includeTimestamp: false,
        includeLocation: true,
      });

      logger.info("test message");

      // Should include some location information
      const call = (console.log as any).mock.calls[0][0];
      if (call.includes("[") && call.includes("]")) {
        // If location is included, it should have the right format
        expect(call).toMatch(/\[.+\.test\.ts:\d+\]/);
      }
    });

    it("should not include location when includeLocation is false", () => {
      const logger = new Logger({
        level: LogLevel.INFO,
        includeTimestamp: false,
        includeLocation: false,
      });

      logger.info("test message");

      const call = (console.log as any).mock.calls[0][0];
      // Should not contain any file:line pattern
      expect(call).not.toMatch(/\[.+:\d+\]/);
      expect(call).toBe("[SetlistFM] [INFO] test message");
    });

    it("should handle malformed stack traces", () => {
      const logger = new Logger({
        level: LogLevel.INFO,
        includeTimestamp: false,
        includeLocation: true,
      });

      // Mock Error to return a malformed stack trace
      const originalError = globalThis.Error;
      globalThis.Error = class MockError extends originalError {
        constructor(message?: string) {
          super(message);
          this.stack = "Error\n    at malformed stack line\n    at another line\n    at third line\n    at malformed:caller:info";
        }
      } as any;

      logger.info("test message");

      // Should still log without location when stack trace can't be parsed
      expect(console.log).toHaveBeenCalledWith(
        "[SetlistFM] [INFO] test message",
      );

      // Restore original Error
      globalThis.Error = originalError;
    });

    it("should handle missing caller line in stack", () => {
      const logger = new Logger({
        level: LogLevel.INFO,
        includeTimestamp: false,
        includeLocation: true,
      });

      // Mock Error to return short stack trace
      const originalError = globalThis.Error;
      globalThis.Error = class MockError extends originalError {
        constructor(message?: string) {
          super(message);
          this.stack = "Error\n    at getCallerLocation\n    at log";
        }
      } as any;

      logger.info("test message");

      // Should still log without location when caller line is missing
      expect(console.log).toHaveBeenCalledWith(
        "[SetlistFM] [INFO] test message",
      );

      // Restore original Error
      globalThis.Error = originalError;
    });

    it("should handle exceptions during stack parsing", () => {
      const logger = new Logger({
        level: LogLevel.INFO,
        includeTimestamp: false,
        includeLocation: true,
      });

      // Mock Error to throw during stack access
      const originalError = globalThis.Error;
      globalThis.Error = class MockError extends originalError {
        constructor(message?: string) {
          super(message);
          Object.defineProperty(this, "stack", {
            get() {
              throw new Error("Stack access failed");
            },
          });
        }
      } as any;

      logger.info("test message");

      // Should still log without location when exception occurs
      expect(console.log).toHaveBeenCalledWith(
        "[SetlistFM] [INFO] test message",
      );

      // Restore original Error
      globalThis.Error = originalError;
    });

    it("should handle empty filepath in stack trace (fallback to full path)", () => {
      const logger = new Logger({
        level: LogLevel.INFO,
        includeTimestamp: false,
        includeLocation: true,
      });

      // Mock Error to return stack trace with filepath ending in slash
      const originalError = globalThis.Error;
      globalThis.Error = class MockError extends originalError {
        constructor(message?: string) {
          super(message);
          // This stack trace line has a filepath that ends with "/"
          // When "path/".split("/").pop() is called, it returns "" (empty string)
          this.stack = "Error\n    at getCallerLocation\n    at log\n    at info\n    at function (path/:123:45)";
        }
      } as any;

      logger.info("test message");

      // The regex extracts filePath="path/" and lineNumber="123"
      // "path/".split("/").pop() returns "" (empty string is falsy)
      // So it falls back to the original filePath which is "path/"
      // Final location becomes "path/:123"
      expect(console.log).toHaveBeenCalledWith(
        "[path/:123] [SetlistFM] [INFO] test message",
      );

      // Restore original Error
      globalThis.Error = originalError;
    });
  });
});
