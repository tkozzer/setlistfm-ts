/**
 * @file basicCountriesLookup.ts
 * @description Basic example of retrieving all supported countries.
 * @author tkozzer
 */

import { createSetlistFMClient } from "../../src/client";
import "dotenv/config";

/**
 * Example: Basic countries lookup
 *
 * This example demonstrates how to retrieve the complete list
 * of countries supported by the setlist.fm API.
 */
async function basicCountriesLookup(): Promise<void> {
  // Create SetlistFM client with automatic STANDARD rate limiting
  const client = createSetlistFMClient({
    apiKey: process.env.SETLISTFM_API_KEY!,
    userAgent: "setlistfm-ts-examples (github.com/tkozzer/setlistfm-ts)",
  });

  try {
    console.log("🌍 Basic Countries Lookup Examples");
    console.log("=================================\n");

    // Display rate limiting information
    const rateLimitStatus = client.getRateLimitStatus();
    console.log(`📊 Rate Limiting: ${rateLimitStatus.profile.toUpperCase()} profile`);
    console.log(`📈 Requests: ${rateLimitStatus.requestsThisSecond}/${rateLimitStatus.secondLimit} this second, ${rateLimitStatus.requestsThisDay}/${rateLimitStatus.dayLimit} today\n`);

    // Example 1: Get all supported countries
    console.log("🔍 Example 1: Getting all supported countries");
    console.log("Fetching complete countries list...\n");

    const countriesResult = await client.searchCountries();

    console.log(`✅ Retrieved ${countriesResult.total} countries total`);
    console.log(`📄 Page ${countriesResult.page} of results`);
    console.log(`📋 ${countriesResult.country.length} countries on this page`);
    console.log(`🔢 ${countriesResult.itemsPerPage} items per page\n`);

    // Display rate limiting status after first request
    const afterFirstRequest = client.getRateLimitStatus();
    console.log(`📊 Rate Limiting Status: ${afterFirstRequest.requestsThisSecond}/${afterFirstRequest.secondLimit} requests this second\n`);

    // Example 2: Display first 10 countries
    console.log("🌍 Example 2: First 10 countries");
    const firstTen = countriesResult.country.slice(0, 10);
    firstTen.forEach((country, index) => {
      console.log(`${index + 1}. ${country.code}: ${country.name}`);
    });

    // Example 3: Find specific countries
    console.log("\n🔍 Example 3: Finding specific countries");

    // Find United States
    const unitedStates = countriesResult.country.find(c => c.code === "US");
    if (unitedStates) {
      console.log(`✅ Found: ${unitedStates.name} (${unitedStates.code})`);
    }
    else {
      console.log("❌ United States not found");
    }

    // Find United Kingdom
    const unitedKingdom = countriesResult.country.find(c => c.code === "GB");
    if (unitedKingdom) {
      console.log(`✅ Found: ${unitedKingdom.name} (${unitedKingdom.code})`);
    }
    else {
      console.log("❌ United Kingdom not found");
    }

    // Find Germany
    const germany = countriesResult.country.find(c => c.code === "DE");
    if (germany) {
      console.log(`✅ Found: ${germany.name} (${germany.code})`);
    }
    else {
      console.log("❌ Germany not found");
    }

    // Find France
    const france = countriesResult.country.find(c => c.code === "FR");
    if (france) {
      console.log(`✅ Found: ${france.name} (${france.code})`);
    }
    else {
      console.log("❌ France not found");
    }

    // Example 4: Display countries by continent/region
    console.log("\n🌍 Example 4: Countries by region");

    // European countries (sample)
    const europeanCodes = ["GB", "DE", "FR", "IT", "ES", "NL", "BE", "AT", "CH", "SE", "NO", "DK", "FI"];
    const europeanCountries = countriesResult.country.filter(c => europeanCodes.includes(c.code));

    if (europeanCountries.length > 0) {
      console.log("\n🇪🇺 European countries found:");
      europeanCountries.forEach((country) => {
        console.log(`  ${country.code}: ${country.name}`);
      });
    }

    // North American countries (sample)
    const northAmericanCodes = ["US", "CA", "MX"];
    const northAmericanCountries = countriesResult.country.filter(c => northAmericanCodes.includes(c.code));

    if (northAmericanCountries.length > 0) {
      console.log("\n🌎 North American countries found:");
      northAmericanCountries.forEach((country) => {
        console.log(`  ${country.code}: ${country.name}`);
      });
    }

    // Asian countries (sample)
    const asianCodes = ["JP", "CN", "KR", "IN", "TH", "SG", "MY", "ID", "PH", "VN"];
    const asianCountries = countriesResult.country.filter(c => asianCodes.includes(c.code));

    if (asianCountries.length > 0) {
      console.log("\n🌏 Asian countries found:");
      asianCountries.forEach((country) => {
        console.log(`  ${country.code}: ${country.name}`);
      });
    }

    // Example 5: Alphabetical sorting
    console.log("\n📝 Example 5: Countries in alphabetical order (first 15)");
    const sortedCountries = [...countriesResult.country]
      .sort((a, b) => a.name.localeCompare(b.name))
      .slice(0, 15);

    sortedCountries.forEach((country, index) => {
      console.log(`${index + 1}. ${country.name} (${country.code})`);
    });

    // Example 6: Countries with special characters
    console.log("\n🌐 Example 6: Countries with special characters in names");
    const specialCharCountries = countriesResult.country.filter(c =>
      /[àáâãäåæçèéêëìíîïñòóôõöøùúûüýÿß]/i.test(c.name),
    );

    if (specialCharCountries.length > 0) {
      console.log(`Found ${specialCharCountries.length} countries with special characters:`);
      specialCharCountries.slice(0, 10).forEach((country) => {
        console.log(`  ${country.code}: ${country.name}`);
      });
      if (specialCharCountries.length > 10) {
        console.log(`  ... and ${specialCharCountries.length - 10} more`);
      }
    }

    // Summary
    console.log("\n📊 Summary:");
    console.log(`Total countries available: ${countriesResult.total}`);
    console.log(`Countries retrieved: ${countriesResult.country.length}`);
    console.log(`Shortest country name: "${countriesResult.country.reduce((a, b) => a.name.length < b.name.length ? a : b).name}"`);
    console.log(`Longest country name: "${countriesResult.country.reduce((a, b) => a.name.length > b.name.length ? a : b).name}"`);

    // Final rate limiting status
    const finalStatus = client.getRateLimitStatus();
    console.log(`\n📊 Final Rate Limiting Status:`);
    console.log(`Profile: ${finalStatus.profile.toUpperCase()}`);
    console.log(`Requests this second: ${finalStatus.requestsThisSecond}/${finalStatus.secondLimit}`);
    console.log(`Requests today: ${finalStatus.requestsThisDay}/${finalStatus.dayLimit}`);

    console.log("\n✅ Basic countries lookup examples completed successfully!");
  }
  catch (error) {
    console.error("❌ Error retrieving countries:", error);

    if (error instanceof Error) {
      console.error(`Error message: ${error.message}`);
    }
  }
}

// Run the example if this script is executed directly
if (require.main === module) {
  basicCountriesLookup();
}

export { basicCountriesLookup };
