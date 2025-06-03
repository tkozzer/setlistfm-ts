/* eslint-disable no-console */
/**
 * @file completeExample.ts
 * @description Complete workflow using all venues endpoints with advanced analysis.
 * @author tkozzer
 */

import { getVenue, getVenueSetlists, searchVenues } from "../../src/endpoints/venues";

import { HttpClient } from "../../src/utils/http";
import "dotenv/config";

/**
 * Complete example: Advanced venue analysis workflow
 *
 * This example demonstrates a real-world workflow that combines
 * all venue endpoints for comprehensive venue and setlist analysis.
 */
async function completeVenueExample(): Promise<void> {
  // Create HTTP client with API key from environment

  const httpClient = new HttpClient({
    // eslint-disable-next-line node/no-process-env
    apiKey: process.env.SETLISTFM_API_KEY!,
    userAgent: "setlistfm-ts-examples (github.com/tkozzer/setlistfm-ts)",
  });

  try {
    console.log("🎪 Complete Venues Analysis Workflow");
    console.log("=====================================\n");

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

      const venueSearch = await searchVenues(httpClient, {
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
      console.log();
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

      const typeSearch = await searchVenues(httpClient, {
        name: venueType,
        p: 1,
      });

      venueTypeStats.push({
        type: venueType,
        count: typeSearch.total,
        examples: typeSearch.venue.slice(0, 2).map(v => v.name),
      });

      console.log(`   Found ${typeSearch.total} venues`);
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
        const search = await searchVenues(httpClient, {
          name: venueInfo.name,
        });

        if (search.venue.length > 0) {
          // Find the most likely match
          const venue = search.venue[0];

          // Get detailed venue information
          const venueDetails = await getVenue(httpClient, venue.id);
          console.log(`✅ Found: ${venueDetails.name}`);
          if (venueDetails.city) {
            console.log(`   📍 Location: ${venueDetails.city.name}, ${venueDetails.city.country.name}`);
          }

          // Get setlists for analysis
          const setlists = await getVenueSetlists(httpClient, venue.id, { p: 1 });
          console.log(`   🎵 Total setlists: ${setlists.total}`);

          // Analyze recent activity
          const recentArtists: string[] = [];
          const artistCounts = new Map<string, number>();

          // Get multiple pages for better analysis
          const maxPages = Math.min(3, Math.ceil(setlists.total / setlists.itemsPerPage));
          for (let page = 1; page <= maxPages; page++) {
            try {
              const pageSetlists = await getVenueSetlists(httpClient, venue.id, { p: page });

              pageSetlists.setlist.forEach((setlist) => {
                const artistName = setlist.artist.name;
                recentArtists.push(artistName);
                artistCounts.set(artistName, (artistCounts.get(artistName) || 0) + 1);
              });

              if (pageSetlists.setlist.length < pageSetlists.itemsPerPage)
                break;
            }
            catch {
              break;
            }
          }

          // Get top artists
          const topArtists = Array.from(artistCounts.entries())
            .sort(([, a], [, b]) => b - a)
            .slice(0, 5)
            .map(([name, count]) => ({ name, count }));

          venueAnalysis.push({
            name: venueDetails.name,
            details: venueDetails,
            setlistCount: setlists.total,
            recentArtists: recentArtists.slice(0, 5),
            topArtists,
          });

          console.log(`   🎤 Recent artists: ${recentArtists.slice(0, 3).join(", ")}`);
          if (topArtists.length > 0) {
            console.log(`   ⭐ Top artist: ${topArtists[0].name} (${topArtists[0].count} shows)`);
          }
        }
        else {
          console.log(`❌ Could not find: ${venueInfo.name}`);
        }
      }
      catch {
        console.log(`❌ Error analyzing: ${venueInfo.name}`);
      }

      console.log();
    }

    // Phase 4: Geographic and statistical analysis
    console.log("📊 Phase 4: Final analysis and insights");
    console.log("---------------------------------------\n");

    // City venue summary
    console.log("🌍 City venue summary:");
    cityVenueData
      .sort((a, b) => b.totalVenues - a.totalVenues)
      .forEach((cityData, index) => {
        console.log(`${index + 1}. ${cityData.city}: ${cityData.totalVenues} venues`);
      });

    // Famous venue rankings
    console.log("\n🏆 Famous venue setlist rankings:");
    venueAnalysis
      .sort((a, b) => b.setlistCount - a.setlistCount)
      .forEach((venue, index) => {
        console.log(`${index + 1}. ${venue.name}: ${venue.setlistCount} setlists`);
        if (venue.details.city) {
          console.log(`   📍 ${venue.details.city.name}, ${venue.details.city.country.name}`);
        }
        if (venue.topArtists.length > 0) {
          console.log(`   🎤 Top performer: ${venue.topArtists[0].name} (${venue.topArtists[0].count} shows)`);
        }
      });

    // Venue type insights
    console.log("\n🏗️  Venue type insights:");
    console.log(`- Most common type: ${venueTypeStats[0].type} (${venueTypeStats[0].count} venues)`);
    console.log(`- Total venues analyzed: ${venueTypeStats.reduce((sum, stat) => sum + stat.count, 0)}`);
    console.log(`- Types analyzed: ${venueTypeStats.length}`);

    // Geographic insights
    const totalCityVenues = cityVenueData.reduce((sum, city) => sum + city.totalVenues, 0);
    console.log(`\n🌎 Geographic insights:`);
    console.log(`- Major music cities analyzed: ${musicCities.length}`);
    console.log(`- Total venues in major cities: ${totalCityVenues}`);
    console.log(`- Average venues per major city: ${Math.round(totalCityVenues / musicCities.length)}`);

    // Activity insights
    const totalSetlists = venueAnalysis.reduce((sum, venue) => sum + venue.setlistCount, 0);
    console.log(`\n🎵 Activity insights:`);
    console.log(`- Famous venues analyzed: ${venueAnalysis.length}`);
    console.log(`- Total setlists in famous venues: ${totalSetlists}`);
    if (venueAnalysis.length > 0) {
      console.log(`- Average setlists per famous venue: ${Math.round(totalSetlists / venueAnalysis.length)}`);
    }

    // Final summary
    console.log("\n🎯 Summary:");
    console.log("This analysis demonstrates the comprehensive venue data available");
    console.log("in the setlist.fm API, from major music cities to iconic venues,");
    console.log("providing insights into the global live music landscape.");
  }
  catch (error) {
    console.error("❌ Error in complete venue analysis:", error);

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
