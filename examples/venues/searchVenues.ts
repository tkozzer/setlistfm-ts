/* eslint-disable no-console */
/**
 * @file searchVenues.ts
 * @description Comprehensive example of searching venues with various parameters.
 * @author tkozzer
 */

import { searchVenues } from "../../src/endpoints/venues";

import { HttpClient } from "../../src/utils/http";
import "dotenv/config";

/**
 * Example: Comprehensive venue search functionality
 *
 * This example demonstrates how to search for venues using
 * various parameters and combinations.
 */
async function searchVenuesExample(): Promise<void> {
  // Create HTTP client with API key from environment

  const httpClient = new HttpClient({
    // eslint-disable-next-line node/no-process-env
    apiKey: process.env.SETLISTFM_API_KEY!,
    userAgent: "setlistfm-ts-examples (github.com/tkozzer/setlistfm-ts)",
  });

  try {
    // Example 1: Search by venue name
    console.log("🔍 Example 1: Search by venue name");
    console.log("Searching for venues named 'Arena'...\n");

    const arenaSearch = await searchVenues(httpClient, {
      name: "Arena",
      p: 1,
    });

    console.log(`✅ Found ${arenaSearch.total} venues with "Arena" in the name`);
    console.log(`📄 Page ${arenaSearch.page} of ${Math.ceil(arenaSearch.total / arenaSearch.itemsPerPage)} (${arenaSearch.itemsPerPage} per page)`);

    if (arenaSearch.venue.length > 0) {
      console.log("\n📋 First 5 Arena venues:");
      arenaSearch.venue.slice(0, 5).forEach((venue, index) => {
        console.log(`${index + 1}. ${venue.name}`);
        if (venue.city) {
          console.log(`   📍 ${venue.city.name}, ${venue.city.state || venue.city.country.name}`);
        }
        console.log(`   🔗 ${venue.url}`);
      });
    }

    // Example 2: Search by city and country
    console.log("\n🔍 Example 2: Search by city and country");
    console.log("Searching for venues in London, UK...\n");

    const londonSearch = await searchVenues(httpClient, {
      cityName: "London",
      country: "GB",
    });

    console.log(`✅ Found ${londonSearch.total} venues in London, UK`);

    if (londonSearch.venue.length > 0) {
      console.log("\n📋 London venues:");
      londonSearch.venue.slice(0, 5).forEach((venue, index) => {
        console.log(`${index + 1}. ${venue.name}`);
        if (venue.city) {
          console.log(`   📍 ${venue.city.name}, ${venue.city.state || venue.city.country.name}`);
          console.log(`   🌐 ${venue.city.coords.lat}°N, ${Math.abs(venue.city.coords.long)}°W`);
        }
      });
    }

    // Example 3: Search by state
    console.log("\n🔍 Example 3: Search by state");
    console.log("Searching for venues in California...\n");

    const californiaSearch = await searchVenues(httpClient, {
      state: "California",
      stateCode: "CA",
      country: "US",
    });

    console.log(`✅ Found ${californiaSearch.total} venues in California`);

    if (californiaSearch.venue.length > 0) {
      // Group venues by city
      const venuesByCity = new Map<string, any[]>();
      californiaSearch.venue.forEach((venue) => {
        const cityName = venue.city?.name || "Unknown City";
        if (!venuesByCity.has(cityName)) {
          venuesByCity.set(cityName, []);
        }
        venuesByCity.get(cityName)!.push(venue);
      });

      console.log("\n📋 California venues by city:");
      Array.from(venuesByCity.entries())
        .sort(([, a], [, b]) => b.length - a.length)
        .slice(0, 10)
        .forEach(([city, venues]) => {
          console.log(`📍 ${city}: ${venues.length} venue(s)`);
          venues.slice(0, 2).forEach((venue) => {
            console.log(`   - ${venue.name}`);
          });
          if (venues.length > 2) {
            console.log(`   ... and ${venues.length - 2} more`);
          }
        });
    }

    // Example 4: Search with pagination
    console.log("\n🔍 Example 4: Search with pagination");
    console.log("Getting multiple pages of Stadium venues...\n");

    const stadiumSearch1 = await searchVenues(httpClient, {
      name: "Stadium",
      p: 1,
    });

    console.log(`✅ Found ${stadiumSearch1.total} venues with "Stadium" in the name`);
    console.log(`📄 Page 1: ${stadiumSearch1.venue.length} venues`);

    if (stadiumSearch1.total > stadiumSearch1.itemsPerPage) {
      const stadiumSearch2 = await searchVenues(httpClient, {
        name: "Stadium",
        p: 2,
      });

      console.log(`📄 Page 2: ${stadiumSearch2.venue.length} venues`);

      // Show venues from both pages
      console.log("\n📋 Stadium venues (pages 1-2):");
      [...stadiumSearch1.venue.slice(0, 3), ...stadiumSearch2.venue.slice(0, 2)].forEach((venue, index) => {
        console.log(`${index + 1}. ${venue.name}`);
        if (venue.city) {
          console.log(`   📍 ${venue.city.name}, ${venue.city.country.name}`);
        }
      });
    }

    // Example 5: Search by city geoId
    console.log("\n🔍 Example 5: Search by city geoId");
    console.log("Searching for venues in New York City (geoId: 5128581)...\n");

    const nycSearch = await searchVenues(httpClient, {
      cityId: "5128581", // New York City geoId
    });

    console.log(`✅ Found ${nycSearch.total} venues in New York City (by geoId)`);

    if (nycSearch.venue.length > 0) {
      console.log("\n📋 NYC venues:");
      nycSearch.venue.slice(0, 5).forEach((venue, index) => {
        console.log(`${index + 1}. ${venue.name}`);
        if (venue.city) {
          console.log(`   📍 ${venue.city.name}, ${venue.city.state}`);
        }
      });
    }

    // Example 6: Complex search with multiple parameters
    console.log("\n🔍 Example 6: Complex search");
    console.log("Searching for 'Theater' venues in New York state...\n");

    const theaterSearch = await searchVenues(httpClient, {
      name: "Theater",
      state: "New York",
      stateCode: "NY",
      country: "US",
    });

    console.log(`✅ Found ${theaterSearch.total} theaters in New York state`);

    if (theaterSearch.venue.length > 0) {
      console.log("\n📋 New York theaters:");
      theaterSearch.venue.slice(0, 5).forEach((venue, index) => {
        console.log(`${index + 1}. ${venue.name}`);
        if (venue.city) {
          console.log(`   📍 ${venue.city.name}, NY`);
        }
      });
    }

    // Example 7: Search for venues without cities
    console.log("\n🔍 Example 7: Handling venues without cities");
    console.log("Searching for 'Festival' venues...\n");

    const festivalSearch = await searchVenues(httpClient, {
      name: "Festival",
    });

    console.log(`✅ Found ${festivalSearch.total} venues with "Festival" in the name`);

    if (festivalSearch.venue.length > 0) {
      console.log("\n📋 Festival venues (showing variety):");
      festivalSearch.venue.slice(0, 5).forEach((venue, index) => {
        console.log(`${index + 1}. ${venue.name}`);
        if (venue.city) {
          console.log(`   📍 ${venue.city.name}, ${venue.city.country.name}`);
        }
        else {
          console.log("   📍 City information not available");
        }
      });
    }

    // Example 8: Search comparison across countries
    console.log("\n🔍 Example 8: International venue comparison");
    console.log("Comparing 'Garden' venues across countries...\n");

    const countries = [
      { code: "US", name: "United States" },
      { code: "GB", name: "United Kingdom" },
      { code: "DE", name: "Germany" },
      { code: "CA", name: "Canada" },
    ];

    for (const country of countries) {
      const countrySearch = await searchVenues(httpClient, {
        name: "Garden",
        country: country.code,
      });

      console.log(`🇺🇸 ${country.name}: ${countrySearch.total} venues with "Garden"`);

      if (countrySearch.venue.length > 0) {
        const topVenue = countrySearch.venue[0];
        console.log(`   Top result: ${topVenue.name}`);
        if (topVenue.city) {
          console.log(`   Location: ${topVenue.city.name}`);
        }
      }
    }

    // Summary statistics
    console.log("\n📊 Search Summary:");
    console.log(`- Arena venues: ${arenaSearch.total}`);
    console.log(`- London venues: ${londonSearch.total}`);
    console.log(`- California venues: ${californiaSearch.total}`);
    console.log(`- Stadium venues: ${stadiumSearch1.total}`);
    console.log(`- NYC venues (by geoId): ${nycSearch.total}`);
    console.log(`- NY state theaters: ${theaterSearch.total}`);
    console.log(`- Festival venues: ${festivalSearch.total}`);
  }
  catch (error) {
    console.error("❌ Error searching venues:", error);

    if (error instanceof Error) {
      console.error(`Error message: ${error.message}`);
    }
  }
}

// Run the example if this script is executed directly
if (require.main === module) {
  searchVenuesExample();
}

export { searchVenuesExample };
