/**
 * @file completeExample.ts
 * @description Complete workflow example using all cities endpoints with data analysis.
 * @author tkozzer
 */

import type { City } from "../../src/endpoints/cities";
import { createSetlistFMClient } from "../../src/client";
import { getCityByGeoId, searchCities } from "../../src/endpoints/cities";
import "dotenv/config";

/**
 * Complete cities workflow example
 *
 * This example demonstrates a real-world workflow combining search and lookup
 * operations with data analysis and processing.
 */
async function completeExample(): Promise<void> {
  // Create SetlistFM client with automatic STANDARD rate limiting
  const client = createSetlistFMClient({

    apiKey: process.env.SETLISTFM_API_KEY!,
    userAgent: "setlistfm-ts-examples (github.com/tkozzer/setlistfm-ts)",
  });

  // Get the HTTP client for making requests
  const httpClient = client.getHttpClient();

  try {
    console.log("🌍 Complete Cities Workflow Example");
    console.log("=====================================\n");

    // Display rate limiting information
    const rateLimitStatus = client.getRateLimitStatus();
    console.log(`📊 Rate Limiting: ${rateLimitStatus.profile.toUpperCase()} profile`);
    console.log(`📈 Requests: ${rateLimitStatus.requestsThisSecond}/${rateLimitStatus.secondLimit} this second, ${rateLimitStatus.requestsThisDay}/${rateLimitStatus.dayLimit} today\n`);

    // Step 1: Find all major cities named "London"
    console.log("🔍 Step 1: Finding all cities named 'London'");
    const londonSearch = await searchCities(httpClient, {
      name: "London",
    });

    console.log(`✅ Found ${londonSearch.total} cities named "London" worldwide\n`);

    const londonCities: City[] = [];
    let currentPage = 1;
    let hasMorePages = true;

    // Collect all London cities across multiple pages
    while (hasMorePages && currentPage <= 3) { // Limit to first 3 pages for demo
      const pageResults = await searchCities(httpClient, {
        name: "London",
        p: currentPage,
      });

      londonCities.push(...pageResults.cities);

      hasMorePages = pageResults.cities.length === pageResults.itemsPerPage
        && currentPage * pageResults.itemsPerPage < pageResults.total;
      currentPage++;

      if (hasMorePages) {
        console.log(`📄 Collected page ${currentPage - 1}, getting more...`);

        // Display rate limiting status during pagination
        const pageStatus = client.getRateLimitStatus();
        console.log(`📊 Rate Limiting: ${pageStatus.requestsThisSecond}/${pageStatus.secondLimit} requests this second`);

        // Add a small delay to be respectful to the API
        await new Promise(resolve => setTimeout(resolve, 100));
      }
    }

    console.log(`📊 Collected ${londonCities.length} London cities for analysis\n`);

    // Step 2: Analyze London cities by country
    console.log("📈 Step 2: Analyzing London cities by country");
    const londonssByCountry = londonCities.reduce((acc, city) => {
      const country = city.country.name;
      if (!acc[country]) {
        acc[country] = [];
      }
      acc[country].push(city);
      return acc;
    }, {} as Record<string, City[]>);

    console.log("🌍 Londons around the world:");
    Object.entries(londonssByCountry)
      .sort(([, a], [, b]) => b.length - a.length) // Sort by count descending
      .slice(0, 10) // Top 10 countries
      .forEach(([country, cities]) => {
        console.log(`  ${country}: ${cities.length} cities`);
        cities.slice(0, 2).forEach((city) => {
          console.log(`    - ${city.name}, ${city.state} (${city.stateCode})`);
        });
        if (cities.length > 2) {
          console.log(`    ... and ${cities.length - 2} more`);
        }
      });

    // Step 3: Deep dive into major Londons
    console.log("\n🏙️ Step 3: Detailed analysis of major Londons");

    // Get the most famous London (UK) - look for actual "London" name
    const londonUK = londonCities.find(city =>
      city.country.code === "GB" && city.name === "London",
    );

    if (londonUK) {
      console.log("\n🇬🇧 London, United Kingdom:");
      const ukDetails = await getCityByGeoId(httpClient, londonUK.id);
      console.log(`  Name: ${ukDetails.name}`);
      console.log(`  State: ${ukDetails.state} (${ukDetails.stateCode})`);
      console.log(`  Coordinates: ${ukDetails.coords.lat}°N, ${Math.abs(ukDetails.coords.long)}°W`);
      console.log(`  GeoId: ${ukDetails.id}`);
    }
    else {
      // If we can't find exact "London", try searching specifically for it
      console.log("\n🇬🇧 Searching specifically for London, UK...");
      try {
        const ukLondonSearch = await searchCities(httpClient, {
          name: "London",
          country: "GB",
        });

        if (ukLondonSearch.cities.length > 0) {
          const londonUKResult = ukLondonSearch.cities.find(city => city.name === "London") || ukLondonSearch.cities[0];
          const ukDetails = await getCityByGeoId(httpClient, londonUKResult.id);
          console.log(`  Name: ${ukDetails.name}`);
          console.log(`  State: ${ukDetails.state} (${ukDetails.stateCode})`);
          console.log(`  Coordinates: ${ukDetails.coords.lat}°N, ${Math.abs(ukDetails.coords.long)}°W`);
          console.log(`  GeoId: ${ukDetails.id}`);
        }
      }
      catch (error) {
        console.log(`  ❌ Could not find London, UK: ${error}`);
      }
    }

    // Get London, Ontario, Canada - look for actual "London" name
    const londonCanada = londonCities.find(city =>
      city.country.code === "CA" && city.name === "London",
    );

    if (londonCanada) {
      console.log("\n🇨🇦 London, Ontario, Canada:");
      const canadaDetails = await getCityByGeoId(httpClient, londonCanada.id);
      console.log(`  Name: ${canadaDetails.name}`);
      console.log(`  State: ${canadaDetails.state} (${canadaDetails.stateCode})`);
      console.log(`  Coordinates: ${canadaDetails.coords.lat}°N, ${Math.abs(canadaDetails.coords.long)}°W`);
      console.log(`  GeoId: ${canadaDetails.id}`);
    }
    else {
      // Try searching specifically for London, Ontario
      console.log("\n🇨🇦 Searching specifically for London, Ontario...");
      try {
        const canadaLondonSearch = await searchCities(httpClient, {
          name: "London",
          country: "CA",
        });

        if (canadaLondonSearch.cities.length > 0) {
          const londonOntario = canadaLondonSearch.cities.find(city =>
            city.name === "London" && city.state.includes("Ontario"),
          ) || canadaLondonSearch.cities[0];

          const canadaDetails = await getCityByGeoId(httpClient, londonOntario.id);
          console.log(`  Name: ${canadaDetails.name}`);
          console.log(`  State: ${canadaDetails.state} (${canadaDetails.stateCode})`);
          console.log(`  Coordinates: ${canadaDetails.coords.lat}°N, ${Math.abs(canadaDetails.coords.long)}°W`);
          console.log(`  GeoId: ${canadaDetails.id}`);
        }
      }
      catch (error) {
        console.log(`  ❌ Could not find London, Ontario: ${error}`);
      }
    }

    // Display rate limiting status after major lookups
    const midStatus = client.getRateLimitStatus();
    console.log(`\n📊 Rate Limiting Status: ${midStatus.requestsThisSecond}/${midStatus.secondLimit} requests this second`);

    // Step 4: Compare major music cities
    console.log("\n🎵 Step 4: Comparing major music cities");
    const musicCities = [
      { name: "Nashville", state: "Tennessee", country: "US" },
      { name: "Austin", state: "Texas", country: "US" },
      { name: "Los Angeles", state: "California", country: "US" },
      { name: "New York", state: "New York", country: "US" },
    ];

    console.log("🎼 Major music cities analysis:");

    for (const cityInfo of musicCities) {
      try {
        console.log(`\n🔍 Searching for ${cityInfo.name}, ${cityInfo.state}...`);

        // First try with name and country
        const searchResult = await searchCities(httpClient, {
          name: cityInfo.name,
          country: cityInfo.country,
        });

        let targetCity: City | undefined;

        if (searchResult.cities.length > 0) {
          // Look for the city in the specific state
          targetCity = searchResult.cities.find(city =>
            city.name === cityInfo.name
            && city.state.includes(cityInfo.state),
          );

          // If not found, try to find by state abbreviation or partial match
          if (!targetCity) {
            targetCity = searchResult.cities.find(city =>
              city.name === cityInfo.name
              && (city.stateCode === cityInfo.state.substring(0, 2).toUpperCase()
                || city.state.toLowerCase().includes(cityInfo.state.toLowerCase())),
            );
          }

          // Fallback to first result with the right name
          if (!targetCity) {
            targetCity = searchResult.cities.find(city => city.name === cityInfo.name);
          }
        }

        if (targetCity) {
          const details = await getCityByGeoId(httpClient, targetCity.id);
          console.log(`🏙️ ${details.name}, ${details.state}:`);
          console.log(`   Country: ${details.country.name}`);
          console.log(`   Coordinates: ${details.coords.lat}, ${details.coords.long}`);
          console.log(`   GeoId: ${details.id}`);
        }
        else {
          console.log(`❌ Could not find ${cityInfo.name}, ${cityInfo.state}`);
        }

        // Small delay between requests
        await new Promise(resolve => setTimeout(resolve, 100));
      }
      catch (error) {
        console.log(`   ❌ Error getting ${cityInfo.name}: ${error}`);
      }
    }

    // Step 5: Geographic analysis
    console.log("\n🗺️ Step 5: Geographic coordinate analysis");

    // Find cities at extreme coordinates from our London collection
    const northernmost = londonCities.reduce((max, city) =>
      city.coords.lat > max.coords.lat ? city : max,
    );

    const southernmost = londonCities.reduce((min, city) =>
      city.coords.lat < min.coords.lat ? city : min,
    );

    const easternmost = londonCities.reduce((max, city) =>
      city.coords.long > max.coords.long ? city : max,
    );

    const westernmost = londonCities.reduce((min, city) =>
      city.coords.long < min.coords.long ? city : min,
    );

    console.log("🧭 Geographic extremes among London cities:");
    console.log(`  Northernmost: ${northernmost.name}, ${northernmost.country.name} (${northernmost.coords.lat}°N)`);
    console.log(`  Southernmost: ${southernmost.name}, ${southernmost.country.name} (${southernmost.coords.lat}°N)`);
    console.log(`  Easternmost: ${easternmost.name}, ${easternmost.country.name} (${easternmost.coords.long}°E)`);
    console.log(`  Westernmost: ${westernmost.name}, ${westernmost.country.name} (${westernmost.coords.long}°W)`);

    // Step 6: State/Province analysis
    console.log("\n🏛️ Step 6: State/Province distribution");

    const stateDistribution = londonCities.reduce((acc, city) => {
      const key = `${city.state}, ${city.country.name}`;
      acc[key] = (acc[key] || 0) + 1;
      return acc;
    }, {} as Record<string, number>);

    console.log("📊 States/Provinces with cities named London:");
    Object.entries(stateDistribution)
      .sort(([, a], [, b]) => b - a)
      .slice(0, 10)
      .forEach(([location, count]) => {
        console.log(`  ${location}: ${count} cities`);
      });

    // Summary statistics
    console.log("\n📈 Summary Statistics");
    console.log("====================");
    console.log(`🏙️ Total London cities analyzed: ${londonCities.length}`);
    console.log(`🌍 Countries represented: ${Object.keys(londonssByCountry).length}`);
    console.log(`🏛️ States/Provinces represented: ${Object.keys(stateDistribution).length}`);

    const avgLat = londonCities.reduce((sum, city) => sum + city.coords.lat, 0) / londonCities.length;
    const avgLong = londonCities.reduce((sum, city) => sum + city.coords.long, 0) / londonCities.length;

    console.log(`🗺️ Average coordinates: ${avgLat.toFixed(2)}°N, ${avgLong.toFixed(2)}°${avgLong > 0 ? "E" : "W"}`);

    const latRange = northernmost.coords.lat - southernmost.coords.lat;
    const longRange = easternmost.coords.long - westernmost.coords.long;

    console.log(`📏 Coordinate ranges: ${latRange.toFixed(2)}° latitude, ${longRange.toFixed(2)}° longitude`);

    // Final rate limiting status
    const finalStatus = client.getRateLimitStatus();
    console.log(`\n📊 Final Rate Limiting Status:`);
    console.log(`Profile: ${finalStatus.profile.toUpperCase()}`);
    console.log(`Requests this second: ${finalStatus.requestsThisSecond}/${finalStatus.secondLimit}`);
    console.log(`Requests today: ${finalStatus.requestsThisDay}/${finalStatus.dayLimit}`);

    console.log("\n✅ Complete cities workflow analysis finished!");
  }
  catch (error) {
    console.error("❌ Error in complete cities workflow:", error);

    if (error instanceof Error) {
      console.error(`Error message: ${error.message}`);
    }
  }
}

// Run the example if this script is executed directly
if (require.main === module) {
  completeExample();
}

export { completeExample };
