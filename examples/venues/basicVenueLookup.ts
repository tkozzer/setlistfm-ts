/**
 * @file basicVenueLookup.ts
 * @description Basic example of looking up a venue by venue ID.
 * @author tkozzer
 */

import { createSetlistFMClient } from "../../src/client";
import "dotenv/config";

/**
 * Example: Basic venue lookup by venue ID
 *
 * This example demonstrates how to retrieve venue information
 * using their unique venue identifier with the type-safe client.
 */
async function basicVenueLookup(): Promise<void> {
  // Create SetlistFM client with automatic STANDARD rate limiting
  const client = createSetlistFMClient({
    apiKey: process.env.SETLISTFM_API_KEY!,
    userAgent: "setlistfm-ts-examples (github.com/tkozzer/setlistfm-ts)",
  });

  try {
    console.log("🎪 Basic Venue Lookup Examples");
    console.log("==============================\n");

    // Display rate limiting information
    const rateLimitStatus = client.getRateLimitStatus();
    console.log(`📊 Rate Limiting: ${rateLimitStatus.profile.toUpperCase()} profile`);
    console.log(`📈 Requests: ${rateLimitStatus.requestsThisSecond}/${rateLimitStatus.secondLimit} this second, ${rateLimitStatus.requestsThisDay}/${rateLimitStatus.dayLimit} today\n`);

    // Example 1: Search for Madison Square Garden and then lookup details
    console.log("🔍 Example 1: Search and lookup workflow");
    console.log("Searching for venues named 'Madison Square Garden'...\n");

    const msgSearch = await client.searchVenues({
      name: "Madison Square Garden",
    });

    console.log(`✅ Found ${msgSearch.total} venues matching "Madison Square Garden"`);

    // Display rate limiting status after first request
    const afterFirstRequest = client.getRateLimitStatus();
    console.log(`📊 Rate Limiting Status: ${afterFirstRequest.requestsThisSecond}/${afterFirstRequest.secondLimit} requests this second\n`);

    if (msgSearch.venue.length > 0) {
      // Find the actual MSG in New York
      const msg = msgSearch.venue.find(venue =>
        venue.city?.country.code === "US" && venue.city?.stateCode === "NY",
      ) || msgSearch.venue[0]; // Fallback to first result

      console.log(`📋 Using venue from search results:`);
      console.log(`Name: ${msg.name}`);
      if (msg.city) {
        console.log(`City: ${msg.city.name}, ${msg.city.state} (${msg.city.stateCode})`);
        console.log(`Country: ${msg.city.country.name}`);
      }
      console.log(`Venue ID: ${msg.id}`);

      // Get detailed venue information
      console.log("\n🔍 Looking up detailed venue information...");
      const msgDetails = await client.getVenue(msg.id);

      console.log("\n✅ Venue details found!");
      console.log(`Name: ${msgDetails.name}`);
      if (msgDetails.city) {
        console.log(`City: ${msgDetails.city.name}, ${msgDetails.city.state}`);
        console.log(`Country: ${msgDetails.city.country.name} (${msgDetails.city.country.code})`);
        console.log(`Coordinates: ${msgDetails.city.coords.lat}, ${msgDetails.city.coords.long}`);
      }
      console.log(`Setlist.fm URL: ${msgDetails.url}`);

      // Display rate limiting status after second request
      const afterSecondRequest = client.getRateLimitStatus();
      console.log(`\n📊 Rate Limiting Status: ${afterSecondRequest.requestsThisSecond}/${afterSecondRequest.secondLimit} requests this second`);
    }

    // Example 2: Search for Wembley Stadium
    console.log("\n🔍 Example 2: Finding Wembley Stadium");
    console.log("Searching for venues named 'Wembley'...\n");

    const wembleySearch = await client.searchVenues({
      name: "Wembley",
    });

    console.log(`✅ Found ${wembleySearch.total} venues matching "Wembley"`);

    if (wembleySearch.venue.length > 0) {
      // Try to find Wembley Stadium in London
      const wembley = wembleySearch.venue.find(venue =>
        venue.city?.country.code === "GB"
        && venue.city?.name?.includes("London")
        && venue.name.includes("Stadium"),
      ) || wembleySearch.venue[0];

      console.log(`\n📋 Found Wembley venue:`);
      console.log(`Name: ${wembley.name}`);
      if (wembley.city) {
        console.log(`City: ${wembley.city.name}, ${wembley.city.state}`);
        console.log(`Country: ${wembley.city.country.name}`);
      }
      console.log(`Venue ID: ${wembley.id}`);

      // Get detailed information
      const wembleyDetails = await client.getVenue(wembley.id);
      console.log(`\n✅ Wembley details:`);
      if (wembleyDetails.city) {
        console.log(`Coordinates: ${wembleyDetails.city.coords.lat}°N, ${Math.abs(wembleyDetails.city.coords.long)}°W`);
      }
      console.log(`Setlist.fm URL: ${wembleyDetails.url}`);
    }

    // Example 3: Search for Red Rocks Amphitheatre
    console.log("\n🔍 Example 3: Finding Red Rocks Amphitheatre");
    console.log("Searching for venues with 'Red Rocks'...\n");

    const redRocksSearch = await client.searchVenues({
      name: "Red Rocks",
    });

    console.log(`✅ Found ${redRocksSearch.total} venues matching "Red Rocks"`);

    if (redRocksSearch.venue.length > 0) {
      // Find Red Rocks in Colorado
      const redRocks = redRocksSearch.venue.find(venue =>
        venue.city?.country.code === "US"
        && venue.city?.stateCode === "CO",
      ) || redRocksSearch.venue[0];

      console.log(`\n📋 Found Red Rocks venue:`);
      console.log(`Name: ${redRocks.name}`);
      if (redRocks.city) {
        console.log(`City: ${redRocks.city.name}, ${redRocks.city.state}`);
        console.log(`Country: ${redRocks.city.country.name}`);
      }
      console.log(`Venue ID: ${redRocks.id}`);

      // Get detailed information
      const redRocksDetails = await client.getVenue(redRocks.id);
      console.log(`\n✅ Red Rocks details:`);
      if (redRocksDetails.city) {
        console.log(`Coordinates: ${redRocksDetails.city.coords.lat}°N, ${Math.abs(redRocksDetails.city.coords.long)}°W`);
      }
      console.log(`Setlist.fm URL: ${redRocksDetails.url}`);
    }

    // Example 4: Search for venues in Nashville
    console.log("\n🔍 Example 4: Finding venues in Nashville");
    console.log("Searching for venues in Nashville, TN...\n");

    const nashvilleSearch = await client.searchVenues({
      cityName: "Nashville",
      stateCode: "TN",
      country: "US",
    });

    console.log(`✅ Found ${nashvilleSearch.total} venues in Nashville, TN`);

    if (nashvilleSearch.venue.length > 0) {
      // Filter venues with valid names and IDs (8-character hexadecimal)
      const validVenues = nashvilleSearch.venue.filter(venue =>
        venue.name
        && venue.name.trim() !== ""
        && venue.id
        && /^[0-9a-f]{8}$/i.test(venue.id),
      );

      if (validVenues.length > 0) {
        // Show the first few valid Nashville venues
        const topVenues = validVenues.slice(0, 3);

        console.log(`\n📋 Top Nashville venues (${validVenues.length} valid out of ${nashvilleSearch.venue.length} total):`);
        for (const venue of topVenues) {
          console.log(`- ${venue.name} (ID: ${venue.id})`);
          if (venue.city) {
            console.log(`  Location: ${venue.city.name}, ${venue.city.state}`);
          }
        }

        // Get detailed info for the first valid venue
        console.log(`\n🔍 Getting details for: ${topVenues[0].name}`);
        const venueDetails = await client.getVenue(topVenues[0].id);

        console.log(`\n✅ Venue details:`);
        console.log(`Name: ${venueDetails.name}`);
        if (venueDetails.city) {
          console.log(`Full address: ${venueDetails.city.name}, ${venueDetails.city.state} ${venueDetails.city.stateCode}`);
          console.log(`Coordinates: ${venueDetails.city.coords.lat}°N, ${Math.abs(venueDetails.city.coords.long)}°W`);
        }
        console.log(`Setlist.fm URL: ${venueDetails.url}`);
      }
      else {
        console.log(`\n⚠️  No valid venues found in Nashville (found ${nashvilleSearch.venue.length} venues but none had valid names and IDs)`);
        console.log("This may indicate data quality issues with some venue records.");
      }
    }

    // Final rate limiting status
    const finalStatus = client.getRateLimitStatus();
    console.log(`\n📊 Final Rate Limiting Status:`);
    console.log(`Profile: ${finalStatus.profile.toUpperCase()}`);
    console.log(`Requests this second: ${finalStatus.requestsThisSecond}/${finalStatus.secondLimit}`);
    console.log(`Requests today: ${finalStatus.requestsThisDay}/${finalStatus.dayLimit}`);

    console.log("\n✅ Basic venue lookup examples completed successfully!");
  }
  catch (error) {
    console.error("❌ Error looking up venue:", error);

    if (error instanceof Error) {
      console.error(`Error message: ${error.message}`);
    }
  }
}

// Run the example if this script is executed directly
if (require.main === module) {
  basicVenueLookup();
}

export { basicVenueLookup };
