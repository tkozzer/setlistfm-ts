/* eslint-disable no-console */
/**
 * @file basicCityLookup.ts
 * @description Basic example of looking up a city by GeoNames geoId.
 * @author tkozzer
 */

import { getCityByGeoId, searchCities } from "../../src/endpoints/cities";

import { HttpClient } from "../../src/utils/http";
import "dotenv/config";

/**
 * Example: Basic city lookup by GeoNames geoId
 *
 * This example demonstrates how to retrieve city information
 * using their GeoNames identifier (geoId).
 */
async function basicCityLookup(): Promise<void> {
  // Create HTTP client with API key from environment

  const httpClient = new HttpClient({
    // eslint-disable-next-line node/no-process-env
    apiKey: process.env.SETLISTFM_API_KEY!,
    userAgent: "setlistfm-ts-examples (github.com/tkozzer/setlistfm-ts)",
  });

  try {
    // Example 1: Search for Paris and then lookup a specific one
    console.log("🔍 Example 1: Search and lookup workflow");
    console.log("Searching for cities named 'Paris'...\n");

    const parisSearch = await searchCities(httpClient, {
      name: "Paris",
    });

    console.log(`✅ Found ${parisSearch.total} cities named "Paris"`);

    if (parisSearch.cities.length > 0) {
      // Find Paris, France (should be in the results)
      const parisFrance = parisSearch.cities.find(city =>
        city.country.code === "FR" && city.name === "Paris",
      ) || parisSearch.cities[0]; // Fallback to first result

      console.log(`\n📋 Using Paris from search results:`);
      console.log(`Name: ${parisFrance.name}`);
      console.log(`State: ${parisFrance.state} (${parisFrance.stateCode})`);
      console.log(`Country: ${parisFrance.country.name}`);
      console.log(`GeoId: ${parisFrance.id}`);

      // Get detailed city information
      console.log("\n🔍 Looking up detailed city information...");
      const parisDetails = await getCityByGeoId(httpClient, parisFrance.id);

      console.log("\n✅ City details found!");
      console.log(`Name: ${parisDetails.name}`);
      console.log(`State: ${parisDetails.state} (${parisDetails.stateCode})`);
      console.log(`Country: ${parisDetails.country.name} (${parisDetails.country.code})`);
      console.log(`Coordinates: ${parisDetails.coords.lat}, ${parisDetails.coords.long}`);
    }

    // Example 2: Search for London and get the UK one
    console.log("\n🔍 Example 2: Finding London, UK");
    console.log("Searching for cities named 'London'...\n");

    const londonSearch = await searchCities(httpClient, {
      name: "London",
    });

    console.log(`✅ Found ${londonSearch.total} cities named "London"`);

    if (londonSearch.cities.length > 0) {
      // Try to find London, UK specifically
      const londonUK = londonSearch.cities.find(city =>
        city.country.code === "GB"
        && (city.name === "London" || city.name.includes("London")),
      );

      if (londonUK) {
        console.log(`\n📋 Found London, UK:`);
        console.log(`Name: ${londonUK.name}`);
        console.log(`State: ${londonUK.state} (${londonUK.stateCode})`);
        console.log(`Country: ${londonUK.country.name}`);
        console.log(`GeoId: ${londonUK.id}`);

        // Get detailed information
        const londonDetails = await getCityByGeoId(httpClient, londonUK.id);
        console.log(`\n✅ London, UK details:`);
        console.log(`Coordinates: ${londonDetails.coords.lat}°N, ${Math.abs(londonDetails.coords.long)}°W`);
      }
      else {
        console.log("\n📋 London, UK not found, using first London result:");
        const firstLondon = londonSearch.cities[0];
        console.log(`Name: ${firstLondon.name}, ${firstLondon.state}, ${firstLondon.country.name}`);

        const details = await getCityByGeoId(httpClient, firstLondon.id);
        console.log(`Coordinates: ${details.coords.lat}, ${details.coords.long}`);
      }
    }

    // Example 3: Search for New York and lookup
    console.log("\n🔍 Example 3: Finding New York City");
    console.log("Searching for cities named 'New York'...\n");

    const nySearch = await searchCities(httpClient, {
      name: "New York",
    });

    console.log(`✅ Found ${nySearch.total} cities named "New York"`);

    if (nySearch.cities.length > 0) {
      // Find New York City specifically
      const newYorkCity = nySearch.cities.find(city =>
        city.country.code === "US"
        && city.stateCode === "NY"
        && (city.name === "New York" || city.name.includes("New York")),
      ) || nySearch.cities[0]; // Fallback to first result

      console.log(`\n📋 Found New York:`);
      console.log(`Name: ${newYorkCity.name}`);
      console.log(`State: ${newYorkCity.state} (${newYorkCity.stateCode})`);
      console.log(`Country: ${newYorkCity.country.name}`);
      console.log(`GeoId: ${newYorkCity.id}`);

      // Get detailed information
      const nyDetails = await getCityByGeoId(httpClient, newYorkCity.id);
      console.log(`\n✅ New York details:`);
      console.log(`Coordinates: ${nyDetails.coords.lat}°N, ${Math.abs(nyDetails.coords.long)}°W`);
    }

    // Example 4: Search for Los Angeles
    console.log("\n🔍 Example 4: Finding Los Angeles");
    console.log("Searching for cities named 'Los Angeles'...\n");

    const laSearch = await searchCities(httpClient, {
      name: "Los Angeles",
    });

    console.log(`✅ Found ${laSearch.total} cities named "Los Angeles"`);

    if (laSearch.cities.length > 0) {
      const losAngeles = laSearch.cities.find(city =>
        city.country.code === "US"
        && city.stateCode === "CA",
      ) || laSearch.cities[0];

      console.log(`\n📋 Found Los Angeles:`);
      console.log(`Name: ${losAngeles.name}`);
      console.log(`State: ${losAngeles.state} (${losAngeles.stateCode})`);
      console.log(`Country: ${losAngeles.country.name}`);
      console.log(`GeoId: ${losAngeles.id}`);

      // Get detailed information
      const laDetails = await getCityByGeoId(httpClient, losAngeles.id);
      console.log(`\n✅ Los Angeles details:`);
      console.log(`Coordinates: ${laDetails.coords.lat}°N, ${Math.abs(laDetails.coords.long)}°W`);
    }
  }
  catch (error) {
    console.error("❌ Error looking up city:", error);

    if (error instanceof Error) {
      console.error(`Error message: ${error.message}`);
    }
  }
}

// Run the example if this script is executed directly
if (require.main === module) {
  basicCityLookup();
}

export { basicCityLookup };
