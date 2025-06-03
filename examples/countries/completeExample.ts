/* eslint-disable no-console */
/**
 * @file completeExample.ts
 * @description Complete workflow example demonstrating countries endpoint usage and integration.
 * @author tkozzer
 */

import { searchCities } from "../../src/endpoints/cities";
import { searchCountries } from "../../src/endpoints/countries";

import { HttpClient } from "../../src/utils/http";
import "dotenv/config";

/**
 * Complete example demonstrating the full countries workflow
 *
 * This comprehensive example shows:
 * - Basic countries retrieval
 * - Data filtering and analysis
 * - Integration with cities endpoint
 * - Practical use cases
 * - Error handling and best practices
 */
async function completeExample(): Promise<void> {
  console.log("🌍 setlist.fm Countries API - Complete Example");
  console.log("=".repeat(60));
  console.log("This example demonstrates comprehensive usage of the countries endpoint\n");

  // Create HTTP client with API key from environment
  const httpClient = new HttpClient({
    // eslint-disable-next-line node/no-process-env
    apiKey: process.env.SETLISTFM_API_KEY!,
    userAgent: "setlistfm-ts-examples (github.com/tkozzer/setlistfm-ts)",
    timeout: 10000, // 10 second timeout
  });

  try {
    // Step 1: Retrieve all countries
    console.log("🔍 Step 1: Retrieving complete countries list");
    console.log("-".repeat(40));

    const startTime = Date.now();
    const countriesResult = await searchCountries(httpClient);
    const fetchTime = Date.now() - startTime;

    console.log(`✅ Successfully retrieved ${countriesResult.total} countries`);
    console.log(`⏱️  Fetch time: ${fetchTime}ms`);
    console.log(`📄 Page ${countriesResult.page} of results`);
    console.log(`📦 ${countriesResult.country.length} countries in response`);
    console.log(`🔢 ${countriesResult.itemsPerPage} items per page\n`);

    // Step 2: Data quality validation
    console.log("✅ Step 2: Data quality validation");
    console.log("-".repeat(40));

    // Validate all country codes follow ISO 3166-1 alpha-2 format
    const invalidCodes = countriesResult.country.filter(c => !/^[A-Z]{2}$/.test(c.code));
    console.log(`🏷️  Country code validation: ${invalidCodes.length === 0 ? "✅ All valid" : `❌ ${invalidCodes.length} invalid`}`);

    // Validate all countries have names
    const countriesWithoutNames = countriesResult.country.filter(c => !c.name || c.name.trim().length === 0);
    console.log(`📝 Country name validation: ${countriesWithoutNames.length === 0 ? "✅ All have names" : `❌ ${countriesWithoutNames.length} missing names`}`);

    // Check for duplicates
    const uniqueCodes = new Set(countriesResult.country.map(c => c.code));
    const hasDuplicates = uniqueCodes.size !== countriesResult.country.length;
    console.log(`🔄 Duplicate check: ${hasDuplicates ? "❌ Duplicates found" : "✅ No duplicates"}`);

    console.log(`📊 Data quality: ${invalidCodes.length === 0 && countriesWithoutNames.length === 0 && !hasDuplicates ? "✅ Excellent" : "⚠️  Issues detected"}\n`);

    // Step 3: Basic data analysis
    console.log("📊 Step 3: Data analysis and insights");
    console.log("-".repeat(40));

    // Name length analysis
    const nameLengths = countriesResult.country.map(c => c.name.length);
    const avgNameLength = nameLengths.reduce((a, b) => a + b, 0) / nameLengths.length;
    const minNameLength = Math.min(...nameLengths);
    const maxNameLength = Math.max(...nameLengths);
    const shortestCountry = countriesResult.country.find(c => c.name.length === minNameLength)!;
    const longestCountry = countriesResult.country.find(c => c.name.length === maxNameLength)!;

    console.log(`📏 Name length statistics:`);
    console.log(`   Average: ${avgNameLength.toFixed(1)} characters`);
    console.log(`   Range: ${minNameLength} - ${maxNameLength} characters`);
    console.log(`   Shortest: "${shortestCountry.name}" (${shortestCountry.code})`);
    console.log(`   Longest: "${longestCountry.name}" (${longestCountry.code})`);

    // Character analysis
    // eslint-disable-next-line no-control-regex
    const unicodeCountries = countriesResult.country.filter(c => /[^\x00-\x7F]/.test(c.name));
    console.log(`\n🌐 Unicode/special characters:`);
    console.log(`   Countries with non-ASCII names: ${unicodeCountries.length}`);
    if (unicodeCountries.length > 0) {
      console.log(`   Examples: ${unicodeCountries.slice(0, 3).map(c => `${c.name} (${c.code})`).join(", ")}`);
    }

    // Alphabetical distribution
    const letterDistribution: Record<string, number> = {};
    countriesResult.country.forEach((c) => {
      const firstLetter = c.name.charAt(0).toUpperCase();
      letterDistribution[firstLetter] = (letterDistribution[firstLetter] || 0) + 1;
    });

    const mostCommonLetter = Object.entries(letterDistribution).reduce((a, b) => a[1] > b[1] ? a : b);
    console.log(`\n🔤 Alphabetical distribution:`);
    console.log(`   Most common starting letter: "${mostCommonLetter[0]}" (${mostCommonLetter[1]} countries)`);
    console.log(`   Letters represented: ${Object.keys(letterDistribution).length}/26\n`);

    // Step 4: Geographic analysis
    console.log("🌍 Step 4: Geographic and regional analysis");
    console.log("-".repeat(40));

    // Define major regions and their expected countries
    const majorRegions = {
      "European Union": ["AT", "BE", "BG", "HR", "CY", "CZ", "DK", "EE", "FI", "FR", "DE", "GR", "HU", "IE", "IT", "LV", "LT", "LU", "MT", "NL", "PL", "PT", "RO", "SK", "SI", "ES", "SE"],
      "G7 Countries": ["CA", "FR", "DE", "IT", "JP", "GB", "US"],
      "G20 Countries": ["AR", "AU", "BR", "CA", "CN", "FR", "DE", "IN", "ID", "IT", "JP", "KR", "MX", "RU", "SA", "ZA", "TR", "GB", "US"],
      "NATO Members": ["AL", "BE", "BG", "CA", "HR", "CZ", "DK", "EE", "FR", "DE", "GR", "HU", "IS", "IT", "LV", "LT", "LU", "ME", "NL", "MK", "NO", "PL", "PT", "RO", "SK", "SI", "ES", "TR", "GB", "US"],
      "BRICS": ["BR", "RU", "IN", "CN", "ZA"],
    };

    for (const [groupName, codes] of Object.entries(majorRegions)) {
      const foundCountries = codes.filter(code => countriesResult.country.some(c => c.code === code));
      const coverage = (foundCountries.length / codes.length * 100).toFixed(1);

      console.log(`${groupName}:`);
      console.log(`   Expected: ${codes.length} countries`);
      console.log(`   Found: ${foundCountries.length} countries (${coverage}% coverage)`);

      if (foundCountries.length < codes.length) {
        const missing = codes.filter(code => !countriesResult.country.some(c => c.code === code));
        console.log(`   Missing: ${missing.join(", ")}`);
      }
      console.log();
    }

    // Step 5: Integration testing with cities
    console.log("🏙️  Step 5: Integration testing with cities endpoint");
    console.log("-".repeat(40));

    const testCountries = ["US", "GB", "DE", "FR", "JP"];
    const integrationResults: Array<{ code: string; name: string; cities: number; tested: boolean }> = [];

    for (const countryCode of testCountries) {
      const country = countriesResult.country.find(c => c.code === countryCode);
      if (country) {
        try {
          console.log(`🔍 Testing integration: ${country.name} (${countryCode})`);

          const citiesResult = await searchCities(httpClient, {
            country: countryCode,
            p: 1,
          });

          integrationResults.push({
            code: countryCode,
            name: country.name,
            cities: citiesResult.total,
            tested: true,
          });

          console.log(`   ✅ Success: ${citiesResult.total} cities found`);

          if (citiesResult.cities.length > 0) {
            const topCities = citiesResult.cities.slice(0, 2);
            console.log(`   🏙️  Top cities: ${topCities.map(c => c.name).join(", ")}`);
          }

          // Respectful delay
          await new Promise(resolve => setTimeout(resolve, 300));
        }
        catch (error) {
          console.log(`   ❌ Integration failed: ${error}`);
          integrationResults.push({
            code: countryCode,
            name: country.name,
            cities: 0,
            tested: false,
          });
        }
      }
      else {
        console.log(`   ⚠️  Country ${countryCode} not found in countries list`);
      }
    }

    console.log("\n📊 Integration test summary:");
    const successfulTests = integrationResults.filter(r => r.tested);
    console.log(`   Successful integrations: ${successfulTests.length}/${testCountries.length}`);

    if (successfulTests.length > 0) {
      const totalCities = successfulTests.reduce((sum, r) => sum + r.cities, 0);
      const avgCities = totalCities / successfulTests.length;
      console.log(`   Average cities per country: ${avgCities.toFixed(0)}`);

      const topCountry = successfulTests.reduce((a, b) => a.cities > b.cities ? a : b);
      console.log(`   Country with most cities: ${topCountry.name} (${topCountry.cities.toLocaleString()})`);
    }

    // Step 6: Practical use cases
    console.log("\n🎯 Step 6: Practical use cases demonstration");
    console.log("-".repeat(40));

    // Use case 1: Country code lookup
    console.log("Use case 1: Country code to name mapping");
    const lookupCodes = ["US", "GB", "DE", "FR", "CA", "AU", "JP", "XX"];
    const countryMap = new Map(countriesResult.country.map(c => [c.code, c.name]));

    lookupCodes.forEach((code) => {
      const name = countryMap.get(code);
      console.log(`   ${code} → ${name || "Unknown country"}`);
    });

    // Use case 2: Name search (case-insensitive)
    console.log("\nUse case 2: Country name search");
    const searchTerms = ["united", "kingdom", "states", "germany"];

    searchTerms.forEach((term) => {
      const matches = countriesResult.country.filter(c =>
        c.name.toLowerCase().includes(term.toLowerCase()),
      );
      console.log(`   "${term}" → ${matches.length} matches: ${matches.slice(0, 3).map(c => `${c.name} (${c.code})`).join(", ")}${matches.length > 3 ? "..." : ""}`);
    });

    // Use case 3: Validation helper
    console.log("\nUse case 3: Country code validation");
    const testCodes = ["US", "GB", "XX", "123", "usa", "DE"];
    const validCodes = new Set(countriesResult.country.map(c => c.code));

    testCodes.forEach((code) => {
      const isValid = validCodes.has(code);
      console.log(`   ${code} → ${isValid ? "✅ Valid" : "❌ Invalid"}`);
    });

    // Step 7: Performance and optimization insights
    console.log("\n⚡ Step 7: Performance and optimization insights");
    console.log("-".repeat(40));

    console.log(`📊 API Response Characteristics:`);
    console.log(`   Response size: ~${JSON.stringify(countriesResult).length} bytes`);
    console.log(`   Fetch time: ${fetchTime}ms`);
    console.log(`   Items per request: ${countriesResult.country.length}`);
    console.log(`   Pagination: ${countriesResult.total > countriesResult.country.length ? "Required" : "Not required"}`);

    console.log(`\n💡 Optimization recommendations:`);
    console.log(`   ✅ Cache results: Countries list changes infrequently`);
    console.log(`   ✅ Use Map for O(1) lookups: Code → Name mapping`);
    console.log(`   ✅ Precompute validations: Build validation sets once`);
    console.log(`   ✅ Consider CDN: Static-like data benefits from caching`);

    // Final summary
    console.log("\n🎉 Step 8: Complete example summary");
    console.log("-".repeat(40));
    console.log(`✅ Successfully demonstrated countries endpoint usage`);
    console.log(`📊 Countries analyzed: ${countriesResult.country.length}`);
    console.log(`🌍 Regional groups tested: ${Object.keys(majorRegions).length}`);
    console.log(`🏙️  Cities integration tests: ${integrationResults.filter(r => r.tested).length}/${testCountries.length} successful`);
    console.log(`🔍 Use cases demonstrated: 3`);
    console.log(`⚡ Performance insights: Provided`);
    console.log(`🛡️  Error handling: Implemented`);

    console.log(`\n🎯 This example demonstrates production-ready patterns for:`);
    console.log(`   • Data retrieval and validation`);
    console.log(`   • Error handling and resilience`);
    console.log(`   • API integration testing`);
    console.log(`   • Practical use case implementation`);
    console.log(`   • Performance optimization strategies`);
  }
  catch (error) {
    console.error("\n❌ Error in complete example:", error);

    if (error instanceof Error) {
      console.error(`Error type: ${error.constructor.name}`);
      console.error(`Error message: ${error.message}`);

      // Specific error handling suggestions
      if (error.message.includes("API key")) {
        console.error("\n💡 Suggestion: Check your SETLISTFM_API_KEY environment variable");
      }
      else if (error.message.includes("timeout")) {
        console.error("\n💡 Suggestion: Increase timeout or check network connection");
      }
      else if (error.message.includes("rate limit")) {
        console.error("\n💡 Suggestion: Implement retry logic with exponential backoff");
      }
    }

    console.error("\n🔧 Troubleshooting steps:");
    console.error("   1. Verify API key is set in .env file");
    console.error("   2. Check internet connection");
    console.error("   3. Ensure setlist.fm API is accessible");
    console.error("   4. Review rate limiting guidelines");
  }
}

// Run the example if this script is executed directly
if (require.main === module) {
  completeExample().then(() => {
    console.log("\n🏁 Complete example finished successfully!");
  }).catch((error) => {
    console.error("\n💥 Complete example failed:", error);
    process.exit(1);
  });
}

export { completeExample };
