/**
 * @file countriesAnalysis.ts
 * @description Comprehensive analysis of countries and their integration with cities data.
 * @author tkozzer
 */

import { createSetlistFMClient } from "../../src/client";
import "dotenv/config";

/**
 * Example: Comprehensive countries analysis
 *
 * This example demonstrates advanced usage of the countries endpoint
 * and its integration with other API endpoints for data analysis.
 */
async function countriesAnalysis(): Promise<void> {
  // Create SetlistFM client with automatic STANDARD rate limiting
  const client = createSetlistFMClient({
    apiKey: process.env.SETLISTFM_API_KEY!,
    userAgent: "setlistfm-ts-examples (github.com/tkozzer/setlistfm-ts)",
  });

  try {
    console.log("📊 Countries Analysis with Rate Limiting");
    console.log("========================================\n");

    // Display rate limiting information
    const rateLimitStatus = client.getRateLimitStatus();
    console.log(`📊 Rate Limiting: ${rateLimitStatus.profile.toUpperCase()} profile`);
    console.log(`📈 Requests: ${rateLimitStatus.requestsThisSecond}/${rateLimitStatus.secondLimit} this second, ${rateLimitStatus.requestsThisDay}/${rateLimitStatus.dayLimit} today\n`);

    // Phase 1: Get all countries
    console.log("🔍 Phase 1: Retrieving all supported countries");
    console.log("=".repeat(50));

    const countriesResult = await client.searchCountries();
    console.log(`✅ Retrieved ${countriesResult.total} countries\n`);

    // Display rate limiting status after first request
    const afterPhase1 = client.getRateLimitStatus();
    console.log(`📊 Rate Limiting Status: ${afterPhase1.requestsThisSecond}/${afterPhase1.secondLimit} requests this second\n`);

    // Phase 2: Country analysis
    console.log("📊 Phase 2: Country data analysis");
    console.log("=".repeat(50));

    // Analyze country name lengths
    const nameLengths = countriesResult.country.map(c => c.name.length);
    const avgNameLength = nameLengths.reduce((a, b) => a + b, 0) / nameLengths.length;
    const shortestCountry = countriesResult.country.reduce((a, b) => a.name.length < b.name.length ? a : b);
    const longestCountry = countriesResult.country.reduce((a, b) => a.name.length > b.name.length ? a : b);

    console.log(`📏 Country name statistics:`);
    console.log(`   Average name length: ${avgNameLength.toFixed(1)} characters`);
    console.log(`   Shortest: "${shortestCountry.name}" (${shortestCountry.code}) - ${shortestCountry.name.length} chars`);
    console.log(`   Longest: "${longestCountry.name}" (${longestCountry.code}) - ${longestCountry.name.length} chars\n`);

    // Analyze country codes
    console.log(`🏷️  Country code analysis:`);
    const codePattern = /^[A-Z]{2}$/;
    const validCodes = countriesResult.country.filter(c => codePattern.test(c.code));
    console.log(`   All codes follow ISO 3166-1 alpha-2 format: ${validCodes.length === countriesResult.country.length ? "✅ Yes" : "❌ No"}`);
    console.log(`   Code examples: ${countriesResult.country.slice(0, 10).map(c => c.code).join(", ")}\n`);

    // Phase 3: Regional groupings
    console.log("🌍 Phase 3: Regional country groupings");
    console.log("=".repeat(50));

    const regions = {
      "🇪🇺 Europe": ["AD", "AL", "AT", "BA", "BE", "BG", "BY", "CH", "CZ", "DE", "DK", "EE", "ES", "FI", "FR", "GB", "GR", "HR", "HU", "IE", "IS", "IT", "LT", "LU", "LV", "MC", "MD", "ME", "MK", "MT", "NL", "NO", "PL", "PT", "RO", "RS", "RU", "SE", "SI", "SK", "SM", "UA", "VA"],
      "🌎 North America": ["CA", "US", "MX", "GT", "BZ", "SV", "HN", "NI", "CR", "PA"],
      "🌏 Asia": ["CN", "JP", "KR", "IN", "ID", "TH", "VN", "PH", "MY", "SG", "BD", "PK", "LK", "MM", "KH", "LA", "BN", "TL", "MN", "AF"],
      "🌍 Africa": ["ZA", "EG", "NG", "KE", "MA", "GH", "TN", "UG", "DZ", "SD", "MZ", "MG", "CM", "CI", "NE", "BF", "ML", "MW", "ZM", "SN"],
      "🌴 Oceania": ["AU", "NZ", "FJ", "PG", "NC", "SB", "VU", "WS", "TO", "PW", "FM", "MH", "KI", "NR", "TV"],
      "🌎 South America": ["BR", "AR", "CL", "PE", "CO", "VE", "EC", "BO", "PY", "UY", "GY", "SR", "GF"],
    };

    for (const [regionName, codes] of Object.entries(regions)) {
      const regionCountries = countriesResult.country.filter(c => codes.includes(c.code));
      const foundCodes = regionCountries.map(c => c.code);
      const coverage = (foundCodes.length / codes.length * 100).toFixed(1);

      console.log(`${regionName}:`);
      console.log(`   Expected countries: ${codes.length}`);
      console.log(`   Found countries: ${foundCodes.length} (${coverage}% coverage)`);

      if (regionCountries.length > 0) {
        console.log(`   Sample countries: ${regionCountries.slice(0, 5).map(c => `${c.name} (${c.code})`).join(", ")}`);
        if (regionCountries.length > 5) {
          console.log(`   ... and ${regionCountries.length - 5} more`);
        }
      }
      console.log();
    }

    // Phase 4: Integration with cities endpoint
    console.log("🏙️  Phase 4: Integration with cities data");
    console.log("=".repeat(50));

    // Test a few major countries to see their city data
    const majorCountries = ["US", "GB", "DE", "FR", "CA", "AU", "JP"];
    const countryStats: Array<{ country: string; name: string; totalCities: number }> = [];

    for (const countryCode of majorCountries) {
      const country = countriesResult.country.find(c => c.code === countryCode);
      if (country) {
        try {
          console.log(`🔍 Checking cities in ${country.name} (${countryCode})...`);

          // Search for cities in this country
          const citiesResult = await client.searchCities({
            country: countryCode,
            p: 1, // Just get first page for analysis
          });

          countryStats.push({
            country: countryCode,
            name: country.name,
            totalCities: citiesResult.total,
          });

          console.log(`   ✅ Found ${citiesResult.total} cities total`);
          console.log(`   📄 ${citiesResult.cities.length} cities on first page`);

          if (citiesResult.cities.length > 0) {
            const sampleCities = citiesResult.cities.slice(0, 3);
            console.log(`   🏙️  Sample cities: ${sampleCities.map(c => c.name).join(", ")}`);
          }

          // Display rate limiting status during integration testing
          const duringIntegration = client.getRateLimitStatus();
          console.log(`   📊 Rate Limiting: ${duringIntegration.requestsThisSecond}/${duringIntegration.secondLimit} requests this second`);

          // Small delay to be respectful to the API
          await new Promise(resolve => setTimeout(resolve, 500));
        }
        catch (error) {
          console.log(`   ❌ Error fetching cities for ${country.name}: ${error}`);
        }
      }
      console.log();
    }

    // Phase 5: Countries with most cities analysis
    console.log("📈 Phase 5: Countries with most cities");
    console.log("=".repeat(50));

    // Sort countries by city count
    const sortedByCities = countryStats
      .sort((a, b) => b.totalCities - a.totalCities);

    console.log("Top countries by number of cities:");
    sortedByCities.forEach((stat, index) => {
      console.log(`${index + 1}. ${stat.name} (${stat.country}): ${stat.totalCities.toLocaleString()} cities`);
    });

    // Calculate total cities across all tested countries
    const totalCitiesCount = sortedByCities.reduce((sum, stat) => sum + stat.totalCities, 0);
    console.log(`\n📊 Total cities across ${sortedByCities.length} major countries: ${totalCitiesCount.toLocaleString()}`);

    // Phase 6: Localization examples
    console.log("\n🌐 Phase 6: Country name localization examples");
    console.log("=".repeat(50));

    console.log("Countries that might have localized names in different languages:");
    const localizationExamples = [
      { code: "DE", englishName: "Germany", possibleLocal: "Deutschland" },
      { code: "ES", englishName: "Spain", possibleLocal: "España" },
      { code: "FR", englishName: "France", possibleLocal: "France" },
      { code: "IT", englishName: "Italy", possibleLocal: "Italia" },
      { code: "CN", englishName: "China", possibleLocal: "中国" },
      { code: "JP", englishName: "Japan", possibleLocal: "日本" },
      { code: "RU", englishName: "Russia", possibleLocal: "Россия" },
      { code: "GR", englishName: "Greece", possibleLocal: "Ελλάδα" },
    ];

    localizationExamples.forEach((example) => {
      const country = countriesResult.country.find(c => c.code === example.code);
      if (country) {
        const isLocalized = country.name !== example.englishName;
        console.log(`${example.code}: ${country.name} ${isLocalized ? "🌐 (localized)" : "🇺🇸 (English)"}`);
      }
    });

    // Final rate limiting status
    const finalStatus = client.getRateLimitStatus();
    console.log(`\n📊 Final Rate Limiting Status:`);
    console.log(`Profile: ${finalStatus.profile.toUpperCase()}`);
    console.log(`Requests this second: ${finalStatus.requestsThisSecond}/${finalStatus.secondLimit}`);
    console.log(`Requests today: ${finalStatus.requestsThisDay}/${finalStatus.dayLimit}`);

    // Final summary
    console.log("\n📋 Final Summary");
    console.log("=".repeat(50));
    console.log(`✅ Total countries available: ${countriesResult.total}`);
    console.log(`📊 Countries analyzed: ${countriesResult.country.length}`);
    console.log(`🏙️  Cities integration tested: ${countryStats.length} countries`);
    console.log(`🌍 Regional coverage: ${Object.keys(regions).length} regions analyzed`);
    console.log(`📏 Name length range: ${shortestCountry.name.length}-${longestCountry.name.length} characters`);
    console.log(`🔤 All country codes valid: ${validCodes.length === countriesResult.country.length ? "Yes" : "No"}`);

    if (countryStats.length > 0) {
      const topCountry = sortedByCities[0];
      console.log(`🏆 Country with most cities: ${topCountry.name} (${topCountry.totalCities.toLocaleString()} cities)`);
    }

    console.log("\n✅ Countries analysis completed successfully with rate limiting protection!");
  }
  catch (error) {
    console.error("❌ Error during countries analysis:", error);

    if (error instanceof Error) {
      console.error(`Error message: ${error.message}`);
      console.error(`Error stack: ${error.stack}`);
    }
  }
}

// Run the example if this script is executed directly
if (require.main === module) {
  countriesAnalysis();
}

export { countriesAnalysis };
