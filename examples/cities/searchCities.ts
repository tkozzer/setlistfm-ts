/* eslint-disable no-console */
/**
 * @file searchCities.ts
 * @description Example of searching for cities using various criteria.
 * @author tkozzer
 */

import { searchCities } from "../../src/endpoints/cities";

import { HttpClient } from "../../src/utils/http";
import "dotenv/config";

/**
 * Example: Search for cities using different criteria
 *
 * This example demonstrates various ways to search for cities
 * including by name, country, state, state code, and pagination.
 */
async function searchCitiesExample(): Promise<void> {
  const httpClient = new HttpClient({
    // eslint-disable-next-line node/no-process-env
    apiKey: process.env.SETLISTFM_API_KEY!,
    userAgent: "setlistfm-ts-examples (github.com/tkozzer/setlistfm-ts)",
  });

  try {
    // Example 1: Search by city name
    console.log("🔍 Example 1: Search by city name");
    console.log("Searching for cities named 'Paris'...\n");

    const nameSearch = await searchCities(httpClient, {
      name: "Paris",
    });

    console.log(`✅ Found ${nameSearch.total} cities named "Paris"`);
    console.log(`📄 Page ${nameSearch.page}, showing ${nameSearch.cities.length} results\n`);

    nameSearch.cities.slice(0, 5).forEach((city, index) => {
      console.log(`${index + 1}. ${city.name}, ${city.state}`);
      console.log(`   Country: ${city.country.name} (${city.country.code})`);
      console.log(`   GeoId: ${city.id}`);
      console.log(`   Coordinates: ${city.coords.lat}, ${city.coords.long}`);
      console.log("");
    });

    // Example 2: Search by country (using country code)
    console.log("🔍 Example 2: Search by country code");
    console.log("Searching for cities in Germany (DE)...\n");

    const countrySearch = await searchCities(httpClient, {
      country: "DE",
      p: 1,
    });

    console.log(`✅ Found ${countrySearch.total} cities in Germany`);
    console.log(`📄 Page ${countrySearch.page}, ${countrySearch.itemsPerPage} items per page\n`);

    countrySearch.cities.slice(0, 3).forEach((city, index) => {
      console.log(`${index + 1}. ${city.name}`);
      console.log(`   State: ${city.state} (${city.stateCode})`);
      console.log(`   GeoId: ${city.id}`);
      console.log("");
    });

    // Example 3: Search by state
    console.log("🔍 Example 3: Search by state name");
    console.log("Searching for cities in California...\n");

    const stateSearch = await searchCities(httpClient, {
      state: "California",
      p: 1,
    });

    console.log(`✅ Found ${stateSearch.total} cities in California`);
    console.log(`📄 Page ${stateSearch.page}, showing ${stateSearch.cities.length} results\n`);

    stateSearch.cities.slice(0, 4).forEach((city, index) => {
      console.log(`${index + 1}. ${city.name}, ${city.state}`);
      console.log(`   Country: ${city.country.name}`);
      console.log(`   Coordinates: ${city.coords.lat}, ${city.coords.long}`);
      console.log("");
    });

    // Example 4: Search by state code
    console.log("🔍 Example 4: Search by state code");
    console.log("Searching for cities with state code 'NY'...\n");

    const stateCodeSearch = await searchCities(httpClient, {
      stateCode: "NY",
      p: 1,
    });

    console.log(`✅ Found ${stateCodeSearch.total} cities with state code NY`);
    console.log(`📄 Page ${stateCodeSearch.page}, showing ${stateCodeSearch.cities.length} results\n`);

    stateCodeSearch.cities.slice(0, 3).forEach((city, index) => {
      console.log(`${index + 1}. ${city.name}, ${city.state}`);
      console.log(`   State Code: ${city.stateCode}`);
      console.log(`   GeoId: ${city.id}`);
      console.log("");
    });

    // Example 5: Combined search parameters
    console.log("🔍 Example 5: Combined search parameters");
    console.log("Searching for cities named 'Springfield' in the United States...\n");

    const combinedSearch = await searchCities(httpClient, {
      name: "Springfield",
      country: "US",
    });

    console.log(`✅ Found ${combinedSearch.total} cities named "Springfield" in the United States`);

    if (combinedSearch.cities.length > 0) {
      console.log("\n📋 Different Springfields in the US:");
      combinedSearch.cities.slice(0, 5).forEach((city, index) => {
        console.log(`${index + 1}. ${city.name}, ${city.state}`);
        console.log(`   State Code: ${city.stateCode}`);
        console.log(`   GeoId: ${city.id}`);
        console.log("");
      });
    }

    // Example 6: Search in the UK
    console.log("🔍 Example 6: Search in the United Kingdom");
    console.log("Searching for cities in the UK (GB)...\n");

    const ukSearch = await searchCities(httpClient, {
      country: "GB",
      p: 1,
    });

    console.log(`✅ Found ${ukSearch.total} cities in the United Kingdom`);
    console.log(`📄 Page ${ukSearch.page}, showing ${ukSearch.cities.length} results\n`);

    ukSearch.cities.slice(0, 4).forEach((city, index) => {
      console.log(`${index + 1}. ${city.name}, ${city.state}`);
      console.log(`   State Code: ${city.stateCode}`);
      console.log(`   GeoId: ${city.id}`);
      console.log("");
    });

    // Example 7: Pagination example
    console.log("🔍 Example 7: Pagination");
    console.log("Getting multiple pages of cities in the United States...\n");

    const page1 = await searchCities(httpClient, {
      country: "US",
      p: 1,
    });

    console.log(`✅ Page 1: Found ${page1.total} total cities in the US`);
    console.log(`📄 Showing ${page1.cities.length} cities on page ${page1.page}`);

    if (page1.total > page1.itemsPerPage) {
      const page2 = await searchCities(httpClient, {
        country: "US",
        p: 2,
      });

      console.log(`📄 Page 2: Showing ${page2.cities.length} cities on page ${page2.page}`);

      const totalPages = Math.ceil(page1.total / page1.itemsPerPage);
      console.log(`📊 Total pages available: ${totalPages}`);
    }

    // Example 8: Handle empty results
    console.log("\n🔍 Example 8: Handle empty search results");
    console.log("Searching for a non-existent city...\n");

    const emptySearch = await searchCities(httpClient, {
      name: "ThisCityDoesNotExistForSure123456",
    });

    if (emptySearch.total === 0) {
      console.log("❌ No cities found matching the search criteria");
      console.log(`📊 Total results: ${emptySearch.total}`);
      console.log(`📄 Page: ${emptySearch.page}`);
    }

    // Example 9: Search with no parameters (get all cities with pagination)
    console.log("\n🔍 Example 9: Search with no parameters");
    console.log("Getting cities without specific search criteria...\n");

    const allCitiesSearch = await searchCities(httpClient, {
      p: 1,
    });

    console.log(`✅ Found ${allCitiesSearch.total} total cities`);
    console.log(`📄 Page ${allCitiesSearch.page}, showing ${allCitiesSearch.cities.length} results\n`);

    console.log("📋 Sample cities from the database:");
    allCitiesSearch.cities.slice(0, 3).forEach((city, index) => {
      console.log(`${index + 1}. ${city.name}, ${city.state}, ${city.country.name}`);
      console.log(`   GeoId: ${city.id}`);
      console.log("");
    });

    // Example 10: Search by country and state combination
    console.log("🔍 Example 10: Search by country and state combination");
    console.log("Searching for cities in Texas, US...\n");

    const texasSearch = await searchCities(httpClient, {
      country: "US",
      state: "Texas",
      p: 1,
    });

    console.log(`✅ Found ${texasSearch.total} cities in Texas, US`);
    console.log(`📄 Page ${texasSearch.page}, showing ${texasSearch.cities.length} results\n`);

    texasSearch.cities.slice(0, 3).forEach((city, index) => {
      console.log(`${index + 1}. ${city.name}, ${city.state}`);
      console.log(`   State Code: ${city.stateCode}`);
      console.log(`   Coordinates: ${city.coords.lat}, ${city.coords.long}`);
      console.log("");
    });
  }
  catch (error) {
    console.error("❌ Error searching for cities:", error);

    if (error instanceof Error) {
      console.error(`Error message: ${error.message}`);
    }
  }
}

// Run the example if this script is executed directly
if (require.main === module) {
  searchCitiesExample();
}

export { searchCitiesExample };
