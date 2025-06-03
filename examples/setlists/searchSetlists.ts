/**
 * @file searchSetlists.ts
 * @description Comprehensive example of searching for setlists with various criteria.
 * @author tkozzer
 */

import { createSetlistFMClient } from "../../src/client";
import { searchSetlists } from "../../src/endpoints/setlists";
import "dotenv/config";

/**
 * Example: Comprehensive setlist search functionality
 *
 * This example demonstrates how to search for setlists using
 * various search criteria and handle pagination.
 */
async function searchSetlistsExample(): Promise<void> {
  // Create SetlistFM client with API key from environment
  // The client automatically uses STANDARD rate limiting (2 req/sec, 1440 req/day)
  const client = createSetlistFMClient({
    apiKey: process.env.SETLISTFM_API_KEY!,
    userAgent: "setlistfm-ts-examples (github.com/tkozzer/setlistfm-ts)",
  });

  // Get the HTTP client for making requests
  const httpClient = client.getHttpClient();

  try {
    // Example 1: Search by artist name
    console.log("🔍 Example 1: Search by artist name");
    console.log("Searching for The Beatles setlists...\n");

    const beatlesSetlists = await searchSetlists(httpClient, {
      artistMbid: "b10bbbfc-cf9e-42e0-be17-e2c3e1d2600d", // The Beatles MBID
      p: 1,
    });

    console.log(`✅ Search successful! Found ${beatlesSetlists.total} Beatles setlists`);
    console.log(`Page ${beatlesSetlists.page} of ${Math.ceil(beatlesSetlists.total / beatlesSetlists.itemsPerPage)}`);
    console.log(`Showing ${beatlesSetlists.setlist.length} setlists:\n`);

    beatlesSetlists.setlist.slice(0, 3).forEach((setlist, index) => {
      console.log(`${index + 1}. ${setlist.artist.name} - ${setlist.eventDate}`);
      console.log(`   Venue: ${setlist.venue.name}, ${setlist.venue.city?.name}`);
      if (setlist.tour) {
        console.log(`   Tour: ${setlist.tour.name}`);
      }
      console.log(`   Songs: ${setlist.sets.set.reduce((total, set) => total + set.song.length, 0)}`);
      console.log(`   URL: ${setlist.url}\n`);
    });

    // Example 2: Search by venue and year
    console.log("🔍 Example 2: Search by venue and year");
    console.log("Searching for setlists at Madison Square Garden in 2023...\n");

    const msgSetlists = await searchSetlists(httpClient, {
      venueName: "Madison Square Garden",
      year: 2023,
      p: 1,
    });

    console.log(`✅ Search successful! Found ${msgSetlists.total} setlists at Madison Square Garden in 2023`);

    if (msgSetlists.setlist.length > 0) {
      console.log("Recent shows:\n");

      msgSetlists.setlist.slice(0, 5).forEach((setlist, index) => {
        console.log(`${index + 1}. ${setlist.artist.name} - ${setlist.eventDate}`);
        if (setlist.tour) {
          console.log(`   Tour: ${setlist.tour.name}`);
        }
        console.log(`   Songs: ${setlist.sets.set.reduce((total, set) => total + set.song.length, 0)}`);
      });
    }

    // Example 3: Search by city and date range
    console.log("\n🔍 Example 3: Search by city");
    console.log("Searching for setlists in London...\n");

    const londonSetlists = await searchSetlists(httpClient, {
      cityName: "London",
      year: 2023,
      p: 1,
    });

    console.log(`✅ Search successful! Found ${londonSetlists.total} setlists in London for 2023`);

    if (londonSetlists.setlist.length > 0) {
      // Group by venue
      const venueGroups = londonSetlists.setlist.reduce((acc, setlist) => {
        const venueName = setlist.venue.name;
        if (!acc[venueName]) {
          acc[venueName] = [];
        }
        acc[venueName].push(setlist);
        return acc;
      }, {} as Record<string, typeof londonSetlists.setlist>);

      console.log("\nShows by venue:\n");
      Object.entries(venueGroups).slice(0, 3).forEach(([venue, setlists]) => {
        console.log(`📍 ${venue} (${setlists.length} show${setlists.length === 1 ? "" : "s"}):`);
        setlists.slice(0, 2).forEach((setlist) => {
          console.log(`   • ${setlist.artist.name} - ${setlist.eventDate}`);
        });
        if (setlists.length > 2) {
          console.log(`   ... and ${setlists.length - 2} more`);
        }
        console.log();
      });
    }

    // Example 4: Search with pagination
    console.log("🔍 Example 4: Pagination example");
    console.log("Getting multiple pages of Radiohead setlists...\n");

    const page1 = await searchSetlists(httpClient, {
      artistName: "Radiohead",
      p: 1,
    });

    console.log(`✅ Page 1: Found ${page1.total} total Radiohead setlists`);
    console.log(`Items per page: ${page1.itemsPerPage}`);
    console.log(`Total pages: ${Math.ceil(page1.total / page1.itemsPerPage)}`);

    if (page1.total > page1.itemsPerPage) {
      console.log("\n📄 Getting page 2...");

      const page2 = await searchSetlists(httpClient, {
        artistName: "Radiohead",
        p: 2,
      });

      console.log(`✅ Page 2: ${page2.setlist.length} setlists`);
      console.log("Most recent setlists from page 2:\n");

      page2.setlist.slice(0, 3).forEach((setlist, index) => {
        console.log(`${index + 1}. ${setlist.eventDate} - ${setlist.venue.name}, ${setlist.venue.city?.name}`);
      });
    }

    // Example 5: Search by specific date
    console.log("\n🔍 Example 5: Search by specific date");
    const specificDate = "23-08-1964"; // The Beatles at Hollywood Bowl
    console.log(`Searching for setlists on ${specificDate}...\n`);

    const dateSetlists = await searchSetlists(httpClient, {
      date: specificDate,
    });

    console.log(`✅ Search successful! Found ${dateSetlists.total} setlist${dateSetlists.total === 1 ? "" : "s"} on ${specificDate}`);

    dateSetlists.setlist.forEach((setlist, index) => {
      console.log(`${index + 1}. ${setlist.artist.name} at ${setlist.venue.name}`);
      if (setlist.venue.city) {
        console.log(`   Location: ${setlist.venue.city.name}, ${setlist.venue.city.state || setlist.venue.city.country?.name}`);
      }
      if (setlist.tour) {
        console.log(`   Tour: ${setlist.tour.name}`);
      }
    });

    // Example: Check rate limit status
    console.log("\n📊 Rate limiting information:");
    const rateLimitStatus = client.getRateLimitStatus();
    console.log(`Profile: ${rateLimitStatus.profile}`);
    console.log(`Requests this second: ${rateLimitStatus.requestsThisSecond}/${rateLimitStatus.secondLimit}`);
    console.log(`Requests this day: ${rateLimitStatus.requestsThisDay}/${rateLimitStatus.dayLimit}`);
  }
  catch (error) {
    console.error("❌ Error searching setlists:", error);

    if (error instanceof Error) {
      console.error(`Error message: ${error.message}`);
    }
  }
}

// Run the example if this script is executed directly
if (require.main === module) {
  searchSetlistsExample();
}

export { searchSetlistsExample };
