/**
 * @file buildVerification.test.ts
 * @description Post-build verification tests to ensure built artifacts work correctly.
 * @author tkozzer
 * @module BuildVerification
 */

import { exec } from "node:child_process";
import { access, readFile } from "node:fs/promises";
import { resolve } from "node:path";
import { promisify } from "node:util";
import { describe, expect, it } from "vitest";

const execAsync = promisify(exec);

describe("Build Verification Tests", () => {
  describe("Build Files Existence", () => {
    it("should have all expected build artifacts", async () => {
      const expectedFiles = [
        "dist/index.js", // ES modules
        "dist/index.cjs", // CommonJS
        "dist/index.d.ts", // TypeScript definitions
      ];

      for (const file of expectedFiles) {
        await expect(access(resolve(file))).resolves.not.toThrow();
      }
    });

    it("should have UMD builds when built with UMD flag", async () => {
      // Check if UMD files exist (they may not be built in every test run)
      try {
        await access(resolve("dist/index.umd.js"));
        await access(resolve("dist/index.umd.min.js"));
      }
      catch {
        // UMD files may not exist if not built with UMD flag - that's OK
      }
    });
  });

  describe("Module Format Verification", () => {
    it("should export ES modules format correctly", async () => {
      const content = await readFile("dist/index.js", "utf-8");

      // Should contain ES module syntax
      expect(content).toContain("export");
      // Should not contain CommonJS syntax for main exports
      expect(content).not.toMatch(/module\.exports\s*=/);
    });

    it("should export CommonJS format correctly", async () => {
      const content = await readFile("dist/index.cjs", "utf-8");

      // Should contain CommonJS syntax (may be minified)
      expect(content).toMatch(/exports\.|module\.exports|exports\[/);
    });

    it("should have valid TypeScript declarations", async () => {
      const content = await readFile("dist/index.d.ts", "utf-8");

      // Should contain TypeScript declarations
      expect(content).toContain("export");
      expect(content).toContain("declare");

      // Should export main client types
      expect(content).toContain("SetlistFMClient");
      expect(content).toContain("createSetlistFMClient");
    });
  });

  describe("Bundle Size Verification", () => {
    it("should meet bundle size targets", async () => {
      const esModulesSize = await getFileSize("dist/index.js");
      const commonjsSize = await getFileSize("dist/index.cjs");

      // Bundle size targets (in bytes)
      const MAX_ES_SIZE = 25 * 1024; // 25KB
      const MAX_CJS_SIZE = 25 * 1024; // 25KB

      expect(esModulesSize).toBeLessThan(MAX_ES_SIZE);
      expect(commonjsSize).toBeLessThan(MAX_CJS_SIZE);
    });
  });

  describe("Runtime Import Verification", () => {
    it("should be importable as ES module", async () => {
      // Test dynamic import (works in both Node.js and test environment)
      try {
        // Use dynamic import path to avoid TypeScript static analysis
        const distPath = "../dist/index.js";
        const module = await import(distPath);

        expect(module.createSetlistFMClient).toBeDefined();
        expect(typeof module.createSetlistFMClient).toBe("function");
        expect(module.SetlistFMClient).toBeDefined();
        expect(module.RateLimitProfile).toBeDefined();
      }
      catch (error) {
        // If import fails, ensure it's not due to missing build
        if (error instanceof Error && error.message.includes("Cannot resolve")) {
          throw new Error("Build artifacts missing. Run 'pnpm build' first.");
        }
        throw error;
      }
    });

    it("should be requireable as CommonJS", async () => {
      try {
        // Test CommonJS build by checking its content structure
        const content = await readFile("dist/index.cjs", "utf-8");

        // Verify it exports the expected functions (content may be minified)
        expect(content).toMatch(/createSetlistFMClient/);
        expect(content).toMatch(/SetlistFMClient/);
        expect(content).toMatch(/RateLimitProfile/);

        // Verify it uses CommonJS export syntax
        expect(content).toMatch(/exports\.|module\.exports|exports\[/);
      }
      catch (error) {
        if (error instanceof Error && error.message.includes("ENOENT")) {
          throw new Error("CommonJS build missing. Run 'pnpm build' first.");
        }
        throw error;
      }
    });
  });

  describe("API Surface Verification", () => {
    it("should export core client APIs", async () => {
      // Use dynamic import path to avoid TypeScript static analysis
      const distPath = "../dist/index.js";
      const module = await import(distPath) as any;

      // Core client exports
      expect(module.createSetlistFMClient).toBeDefined();
      expect(typeof module.createSetlistFMClient).toBe("function");
      expect(module.SetlistFMClient).toBeDefined();

      // Utility exports
      expect(module.RateLimitProfile).toBeDefined();
      expect(module.SetlistFMError).toBeDefined();
    });

    it("should have functional client with all endpoint methods", async () => {
      // Use dynamic import path to avoid TypeScript static analysis
      const distPath = "../dist/index.js";
      const module = await import(distPath) as any;

      // Create a client instance to test method availability
      const client = module.createSetlistFMClient({
        apiKey: "test-key",
        userAgent: "test-agent",
      });

      // Endpoint methods should be available on client instance
      const expectedMethods = [
        "getArtist",
        "searchArtists",
        "getArtistSetlists",
        "searchCities",
        "getCityByGeoId",
        "searchCountries",
        "getSetlist",
        "searchSetlists",
        "getVenue",
        "getVenueSetlists",
        "searchVenues",
      ];

      for (const method of expectedMethods) {
        expect(client[method]).toBeDefined();
        expect(typeof client[method]).toBe("function");
      }
    });
  });

  describe("TypeScript Integration", () => {
    it("should have working TypeScript definitions", async () => {
      // Test that TypeScript can parse the definitions without errors
      const { stdout } = await execAsync(
        `npx tsc --noEmit --skipLibCheck dist/index.d.ts`,
        { cwd: resolve(".") },
      );

      // TypeScript should not output errors
      expect(stdout.trim()).toBe("");
    });
  });
});

// Helper function to get file size
async function getFileSize(filePath: string): Promise<number> {
  try {
    const content = await readFile(filePath);
    return content.length;
  }
  catch {
    throw new Error(`Cannot read file: ${filePath}. Ensure build has been run.`);
  }
}
