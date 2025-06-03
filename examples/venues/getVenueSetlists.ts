/**
 * @file getVenueSetlists.ts
 * @description Example of getting setlists for venues with analysis.
 * @author tkozzer
 */

import { createSetlistFMClient } from "../../src/client";
import "dotenv/config";

/**
 * Example: Getting setlists for venues
 *
 * This example demonstrates how to retrieve setlists for venues
 * and analyze the data using the type-safe client.
 */
async function getVenueSetlistsExample(): Promise<void> {
  // Create SetlistFM client with automatic STANDARD rate limiting
  const client = createSetlistFMClient({
    apiKey: process.env.SETLISTFM_API_KEY!,
    userAgent: "setlistfm-ts-examples (github.com/tkozzer/setlistfm-ts)",
  });

  try {
    console.log("🎵 Venue Setlists Examples with Rate Limiting");
    console.log("=============================================\n");

    // Display rate limiting information
    const rateLimitStatus = client.getRateLimitStatus();
    console.log(`📊 Rate Limiting: ${rateLimitStatus.profile.toUpperCase()} profile`);
    console.log(`📈 Requests: ${rateLimitStatus.requestsThisSecond}/${rateLimitStatus.secondLimit} this second, ${rateLimitStatus.requestsThisDay}/${rateLimitStatus.dayLimit} today\n`);

    // Example 1: Find and analyze setlists for Madison Square Garden
    console.log("🔍 Example 1: Madison Square Garden setlists");
    console.log("Finding Madison Square Garden...\n");

    const msgSearch = await client.searchVenues({
      name: "Madison Square Garden",
    });

    // Display rate limiting status after first request
    const afterSearch = client.getRateLimitStatus();
    console.log(`📊 After venue search: ${afterSearch.requestsThisSecond}/${afterSearch.secondLimit} requests this second\n`);

    if (msgSearch.venue.length > 0) {
      // Find the actual MSG in New York
      const msg = msgSearch.venue.find(venue =>
        venue.city?.country.code === "US" && venue.city?.stateCode === "NY",
      ) || msgSearch.venue[0];

      console.log(`✅ Found venue: ${msg.name}`);
      if (msg.city) {
        console.log(`📍 Location: ${msg.city.name}, ${msg.city.state}`);
      }

      // Get first page of setlists
      console.log("\n🎵 Getting setlists...");
      const setlists = await client.getVenueSetlists(msg.id);

      console.log(`✅ Found ${setlists.total} total setlists for ${msg.name}`);
      console.log(`📄 Page ${setlists.page}: ${setlists.setlist.length} setlists`);

      // Display rate limiting status after getting setlists
      const afterSetlists = client.getRateLimitStatus();
      console.log(`📊 After setlists fetch: ${afterSetlists.requestsThisSecond}/${afterSetlists.secondLimit} requests this second\n`);

      if (setlists.setlist.length > 0) {
        console.log("🎤 Recent concerts:");
        setlists.setlist.slice(0, 5).forEach((setlist, index) => {
          console.log(`${index + 1}. ${setlist.artist.name}`);
          console.log(`   📅 Date: ${setlist.eventDate}`);
          if (setlist.tour?.name) {
            console.log(`   🎪 Tour: ${setlist.tour.name}`);
          }
          if (setlist.sets?.set && setlist.sets.set.length > 0) {
            const totalSongs = setlist.sets.set.reduce((total, set) =>
              total + (set.song?.length || 0), 0);
            console.log(`   🎵 Songs: ${totalSongs}`);
          }
          console.log(`   🔗 ${setlist.url}`);
        });

        // Analyze artists
        const artistCounts = new Map<string, number>();
        setlists.setlist.forEach((setlist) => {
          const artistName = setlist.artist.name;
          artistCounts.set(artistName, (artistCounts.get(artistName) || 0) + 1);
        });

        console.log("\n📊 Most frequent artists (this page):");
        Array.from(artistCounts.entries())
          .sort(([, a], [, b]) => b - a)
          .slice(0, 5)
          .forEach(([artist, count]) => {
            console.log(`- ${artist}: ${count} show(s)`);
          });
      }
    }

    // Example 2: Compare setlists between venues
    console.log("\n🔍 Example 2: Venue setlist comparison");
    console.log("Comparing famous venues...\n");

    const famousVenues = [
      { name: "Wembley Stadium", search: { name: "Wembley Stadium" } },
      { name: "Red Rocks", search: { name: "Red Rocks" } },
      { name: "Royal Albert Hall", search: { name: "Royal Albert Hall" } },
    ];

    const venueStats: Array<{
      name: string;
      location: string;
      totalSetlists: number;
      recentShows: number;
    }> = [];

    for (const venueInfo of famousVenues) {
      try {
        const search = await client.searchVenues(venueInfo.search);

        if (search.venue.length > 0) {
          const venue = search.venue[0];
          const setlists = await client.getVenueSetlists(venue.id);

          venueStats.push({
            name: venue.name,
            location: venue.city ? `${venue.city.name}, ${venue.city.country.name}` : "Unknown",
            totalSetlists: setlists.total,
            recentShows: setlists.setlist.length,
          });

          console.log(`✅ ${venue.name}: ${setlists.total} total setlists`);
          if (venue.city) {
            console.log(`   📍 ${venue.city.name}, ${venue.city.country.name}`);
          }

          if (setlists.setlist.length > 0) {
            const latestShow = setlists.setlist[0];
            console.log(`   🎤 Latest: ${latestShow.artist.name} (${latestShow.eventDate})`);
          }

          // Display rate limiting status during comparison
          const duringComparison = client.getRateLimitStatus();
          console.log(`   📊 Rate Limiting: ${duringComparison.requestsThisSecond}/${duringComparison.secondLimit} requests this second`);

          // Check if we're hitting the rate limit
          if (duringComparison.requestsThisSecond >= (duringComparison.secondLimit || 2)) {
            console.log(`   ⚠️  Rate limit reached, subsequent requests will be queued`);
          }
        }
      }
      catch {
        console.log(`❌ Could not get data for ${venueInfo.name}`);
      }
    }

    // Summary comparison
    if (venueStats.length > 0) {
      console.log("\n📊 Venue comparison:");
      venueStats
        .sort((a, b) => b.totalSetlists - a.totalSetlists)
        .forEach((venue, index) => {
          console.log(`${index + 1}. ${venue.name} (${venue.location}): ${venue.totalSetlists} setlists`);
        });
    }

    // Example 3: Analyze setlists for a theater venue
    console.log("\n🔍 Example 3: Theater venue setlist analysis");
    console.log("Analyzing venue setlists...\n");

    // Find a venue with lots of setlists
    const venueSearch = await client.searchVenues({
      name: "Theater",
      p: 1,
    });

    if (venueSearch.venue.length > 0) {
      // Pick a venue that likely has many shows
      const venue = venueSearch.venue[0];
      const venueDetails = await client.getVenue(venue.id);

      console.log(`🎭 Analyzing: ${venueDetails.name}`);
      if (venueDetails.city) {
        console.log(`📍 Location: ${venueDetails.city.name}, ${venueDetails.city.country.name}`);
      }

      // Get multiple pages
      const allSetlists: any[] = [];
      console.log("Getting venue setlists...");

      try {
        const pageSetlists = await client.getVenueSetlists(venue.id);

        if (pageSetlists.setlist.length === 0) {
          console.log("No setlists found for this venue.");
        }
        else {
          allSetlists.push(...pageSetlists.setlist);
          console.log(`📄 Retrieved ${pageSetlists.setlist.length} setlists (showing first page of ${pageSetlists.total} total)`);

          // Display rate limiting status
          const duringPagination = client.getRateLimitStatus();
          console.log(`📊 Rate Limiting: ${duringPagination.requestsThisSecond}/${duringPagination.secondLimit} requests this second`);
        }
      }
      catch (error) {
        console.log(`❌ Error fetching setlists: ${error}`);
      }

      if (allSetlists.length > 0) {
        // Analyze collected data
        const analysis = {
          totalShows: allSetlists.length,
          uniqueArtists: new Set<string>(),
          yearCounts: new Map<number, number>(),
          monthCounts: new Map<number, number>(),
        };

        allSetlists.forEach((setlist) => {
          analysis.uniqueArtists.add(setlist.artist.name);

          // Parse date (dd-MM-yyyy format)
          const [, month, year] = setlist.eventDate.split("-").map(Number);
          if (year) {
            analysis.yearCounts.set(year, (analysis.yearCounts.get(year) || 0) + 1);
          }
          if (month) {
            analysis.monthCounts.set(month, (analysis.monthCounts.get(month) || 0) + 1);
          }
        });

        console.log(`\n📊 Venue analysis (${analysis.totalShows} shows):`);
        console.log(`- Unique artists: ${analysis.uniqueArtists.size}`);
        console.log(`- Shows per artist: ${(analysis.totalShows / analysis.uniqueArtists.size).toFixed(1)} average`);

        // Year breakdown
        if (analysis.yearCounts.size > 0) {
          console.log("\n📅 Shows by year:");
          Array.from(analysis.yearCounts.entries())
            .sort(([a], [b]) => b - a)
            .slice(0, 5)
            .forEach(([year, count]) => {
              console.log(`   ${year}: ${count} shows`);
            });
        }

        // Month breakdown
        if (analysis.monthCounts.size > 0) {
          const monthNames = ["", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
          console.log("\n📊 Busiest months:");
          Array.from(analysis.monthCounts.entries())
            .sort(([, a], [, b]) => b - a)
            .slice(0, 3)
            .forEach(([month, count]) => {
              console.log(`   ${monthNames[month]}: ${count} shows`);
            });
        }

        // Top artists
        const artistFrequency = new Map<string, number>();
        allSetlists.forEach((setlist) => {
          const artist = setlist.artist.name;
          artistFrequency.set(artist, (artistFrequency.get(artist) || 0) + 1);
        });

        console.log("\n🎤 Most frequent artists:");
        Array.from(artistFrequency.entries())
          .sort(([, a], [, b]) => b - a)
          .slice(0, 5)
          .forEach(([artist, count]) => {
            console.log(`   ${artist}: ${count} show(s)`);
          });
      }
    }

    // Example 4: Find venue with recent activity
    console.log("\n🔍 Example 4: Recently active venues");
    console.log("Finding venues with recent concerts...\n");

    const recentVenueSearch = await client.searchVenues({
      name: "Arena",
      p: 1,
    });

    if (recentVenueSearch.venue.length > 0) {
      console.log("📊 Recent activity analysis:");

      const recentActivity: Array<{
        venue: string;
        location: string;
        recentShows: number;
        latestShow?: string;
        latestArtist?: string;
      }> = [];

      // Check first few venues for recent activity
      const venuesToCheck = recentVenueSearch.venue.slice(0, 3);

      for (const venue of venuesToCheck) {
        try {
          const setlists = await client.getVenueSetlists(venue.id);

          const activity = {
            venue: venue.name,
            location: venue.city ? `${venue.city.name}, ${venue.city.country.name}` : "Unknown",
            recentShows: setlists.setlist.length,
            latestShow: setlists.setlist[0]?.eventDate,
            latestArtist: setlists.setlist[0]?.artist.name,
          };

          recentActivity.push(activity);

          console.log(`✅ ${venue.name}:`);
          console.log(`   📍 ${activity.location}`);
          console.log(`   🎵 ${setlists.total} total setlists`);
          if (activity.latestShow && activity.latestArtist) {
            console.log(`   🎤 Latest: ${activity.latestArtist} (${activity.latestShow})`);
          }

          // Display rate limiting status
          const duringActivity = client.getRateLimitStatus();
          console.log(`   📊 Rate Limiting: ${duringActivity.requestsThisSecond}/${duringActivity.secondLimit} requests this second`);
        }
        catch (error) {
          console.log(`❌ Could not get setlists for ${venue.name}: ${error}`);
        }
      }

      // Summary of recent activity
      if (recentActivity.length > 0) {
        console.log("\n📊 Recent activity summary:");
        recentActivity
          .sort((a, b) => b.recentShows - a.recentShows)
          .forEach((activity, index) => {
            console.log(`${index + 1}. ${activity.venue} (${activity.location}): ${activity.recentShows} recent shows`);
          });
      }
    }

    // Final rate limiting status
    const finalStatus = client.getRateLimitStatus();
    console.log(`\n📊 Final Rate Limiting Status:`);
    console.log(`Profile: ${finalStatus.profile.toUpperCase()}`);
    console.log(`Requests this second: ${finalStatus.requestsThisSecond}/${finalStatus.secondLimit}`);
    console.log(`Requests today: ${finalStatus.requestsThisDay}/${finalStatus.dayLimit}`);

    console.log("\n✅ Venue setlists examples completed successfully!");
  }
  catch (error) {
    console.error("❌ Error in venue setlists example:", error);

    if (error instanceof Error) {
      console.error(`Error message: ${error.message}`);
    }
  }
}

// Run the example if this script is executed directly
if (require.main === module) {
  getVenueSetlistsExample();
}

export { getVenueSetlistsExample };
