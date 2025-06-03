/* eslint-disable no-console */
/**
 * @file getVenueSetlists.ts
 * @description Example of getting setlists for venues with analysis.
 * @author tkozzer
 */

import { getVenue, getVenueSetlists, searchVenues } from "../../src/endpoints/venues";

import { HttpClient } from "../../src/utils/http";
import "dotenv/config";

/**
 * Example: Getting setlists for venues
 *
 * This example demonstrates how to retrieve setlists for venues
 * and analyze the data.
 */
async function getVenueSetlistsExample(): Promise<void> {
  // Create HTTP client with API key from environment

  const httpClient = new HttpClient({
    // eslint-disable-next-line node/no-process-env
    apiKey: process.env.SETLISTFM_API_KEY!,
    userAgent: "setlistfm-ts-examples (github.com/tkozzer/setlistfm-ts)",
  });

  try {
    // Example 1: Find and analyze setlists for Madison Square Garden
    console.log("🔍 Example 1: Madison Square Garden setlists");
    console.log("Finding Madison Square Garden...\n");

    const msgSearch = await searchVenues(httpClient, {
      name: "Madison Square Garden",
    });

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
      const setlists = await getVenueSetlists(httpClient, msg.id, { p: 1 });

      console.log(`✅ Found ${setlists.total} total setlists for ${msg.name}`);
      console.log(`📄 Page ${setlists.page}: ${setlists.setlist.length} setlists`);

      if (setlists.setlist.length > 0) {
        console.log("\n🎤 Recent concerts:");
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
        const search = await searchVenues(httpClient, venueInfo.search);

        if (search.venue.length > 0) {
          const venue = search.venue[0];
          const setlists = await getVenueSetlists(httpClient, venue.id, { p: 1 });

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

    // Example 3: Analyze setlists with pagination
    console.log("\n🔍 Example 3: Multi-page setlist analysis");
    console.log("Analyzing venue with many setlists...\n");

    // Find a venue with lots of setlists
    const venueSearch = await searchVenues(httpClient, {
      name: "Theater",
      p: 1,
    });

    if (venueSearch.venue.length > 0) {
      // Pick a venue that likely has many shows
      const venue = venueSearch.venue[0];
      const venueDetails = await getVenue(httpClient, venue.id);

      console.log(`🎭 Analyzing: ${venueDetails.name}`);
      if (venueDetails.city) {
        console.log(`📍 Location: ${venueDetails.city.name}, ${venueDetails.city.country.name}`);
      }

      // Get multiple pages
      const allSetlists: any[] = [];
      const maxPages = 3; // Limit to avoid too many requests

      for (let page = 1; page <= maxPages; page++) {
        try {
          const pageSetlists = await getVenueSetlists(httpClient, venue.id, { p: page });

          if (pageSetlists.setlist.length === 0)
            break;

          allSetlists.push(...pageSetlists.setlist);
          console.log(`📄 Page ${page}: ${pageSetlists.setlist.length} setlists`);

          if (page === 1) {
            console.log(`📊 Total setlists available: ${pageSetlists.total}`);
          }

          // Stop if we've reached the end
          if (pageSetlists.setlist.length < pageSetlists.itemsPerPage)
            break;
        }
        catch {
          console.log(`❌ Error getting page ${page}`);
          break;
        }
      }

      if (allSetlists.length > 0) {
        console.log(`\n📈 Analysis of ${allSetlists.length} setlists:`);

        // Year analysis
        const yearCounts = new Map<string, number>();
        allSetlists.forEach((setlist) => {
          if (setlist.eventDate) {
            const year = setlist.eventDate.split("-")[2] || "Unknown";
            yearCounts.set(year, (yearCounts.get(year) || 0) + 1);
          }
        });

        console.log("\n📅 Shows by year:");
        Array.from(yearCounts.entries())
          .sort(([a], [b]) => b.localeCompare(a))
          .slice(0, 5)
          .forEach(([year, count]) => {
            console.log(`- ${year}: ${count} show(s)`);
          });

        // Artist analysis
        const artistCounts = new Map<string, number>();
        allSetlists.forEach((setlist) => {
          const artistName = setlist.artist.name;
          artistCounts.set(artistName, (artistCounts.get(artistName) || 0) + 1);
        });

        console.log("\n🎤 Top artists:");
        Array.from(artistCounts.entries())
          .sort(([, a], [, b]) => b - a)
          .slice(0, 5)
          .forEach(([artist, count]) => {
            console.log(`- ${artist}: ${count} show(s)`);
          });

        // Song count analysis
        const setlistsWithSongs = allSetlists.filter(setlist =>
          setlist.sets?.set && setlist.sets.set.length > 0);

        if (setlistsWithSongs.length > 0) {
          const songCounts = setlistsWithSongs.map((setlist) => {
            return setlist.sets!.set.reduce((total, set) =>
              total + (set.song?.length || 0), 0);
          });

          const avgSongs = songCounts.reduce((a, b) => a + b, 0) / songCounts.length;
          const maxSongs = Math.max(...songCounts);

          console.log(`\n🎵 Song statistics:`);
          console.log(`- Average songs per show: ${Math.round(avgSongs)}`);
          console.log(`- Longest show: ${maxSongs} songs`);
          console.log(`- Shows with song data: ${setlistsWithSongs.length}/${allSetlists.length}`);
        }
      }
    }

    // Example 4: Find venues with recent activity
    console.log("\n🔍 Example 4: Recent venue activity");
    console.log("Finding venues with recent shows...\n");

    const recentVenues: Array<{
      venue: string;
      location: string;
      totalShows: number;
      latestArtist: string;
      latestDate: string;
    }> = [];
    const venueTypes = ["Club", "Hall", "Center"];

    for (const venueType of venueTypes) {
      try {
        const search = await searchVenues(httpClient, {
          name: venueType,
          p: 1,
        });

        if (search.venue.length > 0) {
          // Check first few venues for recent activity
          for (const venue of search.venue.slice(0, 2)) {
            try {
              const setlists = await getVenueSetlists(httpClient, venue.id, { p: 1 });

              if (setlists.total > 0 && setlists.setlist.length > 0) {
                const latestShow = setlists.setlist[0];
                recentVenues.push({
                  venue: venue.name,
                  location: venue.city ? `${venue.city.name}, ${venue.city.country.code}` : "Unknown",
                  totalShows: setlists.total,
                  latestArtist: latestShow.artist.name,
                  latestDate: latestShow.eventDate,
                });
              }
            }
            catch {
              // Skip venues that cause errors
            }
          }
        }
      }
      catch {
        console.log(`❌ Error searching for ${venueType} venues`);
      }
    }

    if (recentVenues.length > 0) {
      console.log("🎪 Active venues found:");
      recentVenues
        .sort((a, b) => b.totalShows - a.totalShows)
        .slice(0, 5)
        .forEach((venue, index) => {
          console.log(`${index + 1}. ${venue.venue} (${venue.location})`);
          console.log(`   📊 ${venue.totalShows} total shows`);
          console.log(`   🎤 Latest: ${venue.latestArtist} (${venue.latestDate})`);
        });
    }
  }
  catch (error) {
    console.error("❌ Error getting venue setlists:", error);

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
