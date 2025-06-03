/**
 * @file completeExample.ts
 * @description Complete workflow using all venues endpoints with advanced analysis.
 * @author tkozzer
 */

import { createSetlistFMClient } from "../../src/client";
import "dotenv/config";

/**
 * Complete example: Advanced venue analysis workflow
 *
 * This example demonstrates a real-world workflow that combines
 * all venue endpoints for comprehensive venue and setlist analysis using the type-safe client.
 */
async function completeVenueExample(): Promise<void> {
  // Create SetlistFM client with automatic STANDARD rate limiting
  const client = createSetlistFMClient({
    apiKey: process.env.SETLISTFM_API_KEY!,
    userAgent: "setlistfm-ts-examples (github.com/tkozzer/setlistfm-ts)",
  });

  try {
    console.log("🎪 Complete Venues Analysis Workflow with Rate Limiting");
    console.log("=======================================================\n");

    // Display rate limiting information
    const rateLimitStatus = client.getRateLimitStatus();
    console.log(`📊 Rate Limiting: ${rateLimitStatus.profile.toUpperCase()} profile`);
    console.log(`📈 Requests: ${rateLimitStatus.requestsThisSecond}/${rateLimitStatus.secondLimit} this second, ${rateLimitStatus.requestsThisDay}/${rateLimitStatus.dayLimit} today\n`);

    // Phase 1: Discover venues in major music cities
    console.log("📍 Phase 1: Discovering venues in major music cities");
    console.log("-----------------------------------------------------\n");

    const musicCities = [
      { name: "Nashville", state: "Tennessee", stateCode: "TN", country: "US" },
      { name: "Austin", state: "Texas", stateCode: "TX", country: "US" },
      { name: "New York", state: "New York", stateCode: "NY", country: "US" },
      { name: "Los Angeles", state: "California", stateCode: "CA", country: "US" },
      { name: "London", state: "England", stateCode: "ENG", country: "GB" },
    ];

    const cityVenueData: Array<{
      city: string;
      totalVenues: number;
      sampleVenues: any[];
    }> = [];

    for (const city of musicCities) {
      console.log(`🔍 Searching venues in ${city.name}, ${city.state}...`);

      const venueSearch = await client.searchVenues({
        cityName: city.name,
        stateCode: city.stateCode,
        country: city.country,
        p: 1,
      });

      console.log(`✅ Found ${venueSearch.total} venues in ${city.name}`);

      cityVenueData.push({
        city: `${city.name}, ${city.state}`,
        totalVenues: venueSearch.total,
        sampleVenues: venueSearch.venue.slice(0, 3),
      });

      // Show top venues
      if (venueSearch.venue.length > 0) {
        console.log("🏛️  Top venues:");
        venueSearch.venue.slice(0, 3).forEach((venue, index) => {
          console.log(`   ${index + 1}. ${venue.name}`);
        });
      }

      // Display rate limiting status during city search
      const duringCitySearch = client.getRateLimitStatus();
      console.log(`📊 Rate Limiting: ${duringCitySearch.requestsThisSecond}/${duringCitySearch.secondLimit} requests this second\n`);

      // Check if we're hitting the rate limit
      if (duringCitySearch.requestsThisSecond >= (duringCitySearch.secondLimit || 2)) {
        console.log(`⚠️  Rate limit reached (${duringCitySearch.requestsThisSecond}/${duringCitySearch.secondLimit}), subsequent requests will be queued\n`);
      }
    }

    // Phase 2: Analyze venue types and categories
    console.log("🏗️  Phase 2: Venue type analysis");
    console.log("----------------------------------\n");

    const venueTypes = [
      "Theater",
      "Arena",
      "Stadium",
      "Club",
      "Hall",
      "Center",
      "Amphitheater",
      "Garden",
      "Auditorium",
    ];

    const venueTypeStats: Array<{
      type: string;
      count: number;
      examples: string[];
    }> = [];

    for (const venueType of venueTypes) {
      console.log(`🔍 Analyzing "${venueType}" venues...`);

      const typeSearch = await client.searchVenues({
        name: venueType,
        p: 1,
      });

      venueTypeStats.push({
        type: venueType,
        count: typeSearch.total,
        examples: typeSearch.venue.slice(0, 2).map(v => v.name),
      });

      console.log(`   Found ${typeSearch.total} venues`);

      // Display rate limiting status during type analysis
      const duringTypeAnalysis = client.getRateLimitStatus();
      console.log(`   📊 Rate Limiting: ${duringTypeAnalysis.requestsThisSecond}/${duringTypeAnalysis.secondLimit} requests this second`);
    }

    // Sort and display venue type statistics
    venueTypeStats.sort((a, b) => b.count - a.count);
    console.log("\n📊 Venue type ranking:");
    venueTypeStats.slice(0, 5).forEach((stat, index) => {
      console.log(`${index + 1}. ${stat.type}: ${stat.count} venues`);
      console.log(`   Examples: ${stat.examples.join(", ")}`);
    });

    // Phase 3: Deep dive into famous venues
    console.log("\n🌟 Phase 3: Famous venue deep dive");
    console.log("-----------------------------------\n");

    const famousVenues = [
      { name: "Madison Square Garden", expectedLocation: "New York" },
      { name: "Wembley Stadium", expectedLocation: "London" },
      { name: "Red Rocks", expectedLocation: "Colorado" },
      { name: "Royal Albert Hall", expectedLocation: "London" },
      { name: "Hollywood Bowl", expectedLocation: "Los Angeles" },
    ];

    const venueAnalysis: Array<{
      name: string;
      details: any;
      setlistCount: number;
      recentArtists: string[];
      topArtists: Array<{ name: string; count: number }>;
    }> = [];

    for (const venueInfo of famousVenues) {
      console.log(`🔍 Analyzing: ${venueInfo.name}`);

      try {
        // Search for the venue
        const search = await client.searchVenues({
          name: venueInfo.name,
        });

        if (search.venue.length > 0) {
          // Find the most likely match
          const venue = search.venue[0];

          // Get detailed venue information
          const venueDetails = await client.getVenue(venue.id);
          console.log(`✅ Found: ${venueDetails.name}`);
          if (venueDetails.city) {
            console.log(`   📍 Location: ${venueDetails.city.name}, ${venueDetails.city.country.name}`);
          }

          // Get setlists for analysis
          const setlists = await client.getVenueSetlists(venue.id);
          console.log(`   🎵 Total setlists: ${setlists.total}`);

          // Analyze recent activity
          const recentArtists: string[] = [];
          const artistCounts = new Map<string, number>();

          // Analyze first page of setlists
          setlists.setlist.forEach((setlist) => {
            const artistName = setlist.artist.name;
            recentArtists.push(artistName);
            artistCounts.set(artistName, (artistCounts.get(artistName) || 0) + 1);
          });

          // Get top artists for this venue
          const topArtists = Array.from(artistCounts.entries())
            .sort(([, a], [, b]) => b - a)
            .slice(0, 5)
            .map(([name, count]) => ({ name, count }));

          console.log(`   🎤 Artists on first page: ${recentArtists.slice(0, 5).join(", ")}`);
          console.log(`   ⭐ Top artist: ${topArtists[0]?.name || "None"} (${topArtists[0]?.count || 0} shows)`);

          venueAnalysis.push({
            name: venueDetails.name,
            details: venueDetails,
            setlistCount: setlists.total,
            recentArtists: recentArtists.slice(0, 10),
            topArtists,
          });

          // Display rate limiting status during venue analysis
          const duringVenueAnalysis = client.getRateLimitStatus();
          console.log(`   📊 Rate Limiting: ${duringVenueAnalysis.requestsThisSecond}/${duringVenueAnalysis.secondLimit} requests this second`);

          // Check if we're hitting the rate limit
          if (duringVenueAnalysis.requestsThisSecond >= (duringVenueAnalysis.secondLimit || 2)) {
            console.log(`   ⚠️  Rate limit reached, subsequent requests will be queued`);
          }
        }
        else {
          console.log(`   ❌ No venues found for "${venueInfo.name}"`);
        }
      }
      catch (error) {
        console.log(`   ❌ Error analyzing ${venueInfo.name}: ${error}`);
      }

      console.log(); // Empty line for readability
    }

    // Phase 4: Comparative analysis
    console.log("📊 Phase 4: Comparative analysis");
    console.log("---------------------------------\n");

    // City venue statistics
    console.log("🌆 City venue counts:");
    cityVenueData
      .sort((a, b) => b.totalVenues - a.totalVenues)
      .forEach((cityData, index) => {
        console.log(`${index + 1}. ${cityData.city}: ${cityData.totalVenues} venues`);
      });

    // Famous venue statistics
    if (venueAnalysis.length > 0) {
      console.log("\n🌟 Famous venue analysis:");
      venueAnalysis
        .sort((a, b) => b.setlistCount - a.setlistCount)
        .forEach((venue, index) => {
          console.log(`${index + 1}. ${venue.name}: ${venue.setlistCount} total setlists`);
          if (venue.details.city) {
            console.log(`   📍 ${venue.details.city.name}, ${venue.details.city.country.name}`);
          }
          if (venue.topArtists.length > 0) {
            console.log(`   🎤 Top artist: ${venue.topArtists[0].name} (${venue.topArtists[0].count} shows)`);
          }
        });

      // Most active venue
      const mostActiveVenue = venueAnalysis.reduce((max, venue) =>
        venue.setlistCount > max.setlistCount ? venue : max,
      );

      console.log(`\n🏆 Most active venue: ${mostActiveVenue.name} (${mostActiveVenue.setlistCount} setlists)`);

      // Most diverse venue (most unique artists)
      const mostDiverseVenue = venueAnalysis.reduce((max, venue) =>
        venue.topArtists.length > max.topArtists.length ? venue : max,
      );

      console.log(`🎭 Most diverse venue: ${mostDiverseVenue.name} (${mostDiverseVenue.topArtists.length} unique artists on first page)`);
    }

    // Phase 5: Geographic insights
    console.log("\n🗺️  Phase 5: Geographic insights");
    console.log("----------------------------------\n");

    // Analyze venue distribution by country
    const countryStats = new Map<string, { count: number; cities: Set<string> }>();

    cityVenueData.forEach((cityData) => {
      // Extract country from city data (this is simplified for the example)
      const isUS = cityData.city.includes("Tennessee") || cityData.city.includes("Texas")
        || cityData.city.includes("New York") || cityData.city.includes("California");
      const country = isUS ? "United States" : "United Kingdom";

      if (!countryStats.has(country)) {
        countryStats.set(country, { count: 0, cities: new Set() });
      }

      const stats = countryStats.get(country)!;
      stats.count += cityData.totalVenues;
      stats.cities.add(cityData.city);
    });

    console.log("🌍 Venue distribution by country:");
    Array.from(countryStats.entries()).forEach(([country, stats]) => {
      console.log(`${country}: ${stats.count} venues across ${stats.cities.size} cities`);
      console.log(`   Cities: ${Array.from(stats.cities).join(", ")}`);
    });

    // Phase 6: Final insights and recommendations
    console.log("\n💡 Phase 6: Insights and recommendations");
    console.log("----------------------------------------\n");

    const insights = [
      `Analyzed ${cityVenueData.length} major music cities`,
      `Discovered ${venueTypeStats.length} different venue types`,
      `Deep-dived into ${venueAnalysis.length} famous venues`,
      `Found ${cityVenueData.reduce((sum, city) => sum + city.totalVenues, 0)} total venues across all cities`,
    ];

    console.log("📈 Key insights:");
    insights.forEach((insight, index) => {
      console.log(`${index + 1}. ${insight}`);
    });

    if (venueTypeStats.length > 0) {
      const topVenueType = venueTypeStats[0];
      console.log(`\n🏟️  Most common venue type: "${topVenueType.type}" (${topVenueType.count} venues)`);
    }

    if (cityVenueData.length > 0) {
      const topMusicCity = cityVenueData.reduce((max, city) =>
        city.totalVenues > max.totalVenues ? city : max,
      );
      console.log(`🎵 Top music city: ${topMusicCity.city} (${topMusicCity.totalVenues} venues)`);
    }

    console.log("\n💡 Recommendations for further analysis:");
    console.log("• Analyze seasonal patterns in venue bookings");
    console.log("• Study correlation between venue size and artist popularity");
    console.log("• Investigate genre preferences by venue type");
    console.log("• Compare venue activity across different time periods");
    console.log("• Analyze tour routing patterns between venues");

    // Final rate limiting status
    const finalStatus = client.getRateLimitStatus();
    console.log(`\n📊 Final Rate Limiting Status:`);
    console.log(`Profile: ${finalStatus.profile.toUpperCase()}`);
    console.log(`Requests this second: ${finalStatus.requestsThisSecond}/${finalStatus.secondLimit}`);
    console.log(`Requests today: ${finalStatus.requestsThisDay}/${finalStatus.dayLimit}`);

    console.log("\n✅ Complete venue analysis workflow finished successfully!");
    console.log("This comprehensive analysis demonstrates production-ready patterns for:");
    console.log("• Multi-city venue discovery and comparison");
    console.log("• Venue categorization and type analysis");
    console.log("• Famous venue deep-dive with setlist analysis");
    console.log("• Geographic distribution and insights");
    console.log("• Rate limiting management throughout complex workflows");
  }
  catch (error) {
    console.error("❌ Error in complete venue example:", error);

    if (error instanceof Error) {
      console.error(`Error message: ${error.message}`);
    }
  }
}

// Run the example if this script is executed directly
if (require.main === module) {
  completeVenueExample();
}

export { completeVenueExample };
