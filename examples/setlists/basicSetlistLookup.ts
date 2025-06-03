/**
 * @file basicSetlistLookup.ts
 * @description Basic example of looking up a setlist by ID.
 * @author tkozzer
 */

import { createSetlistFMClient } from "../../src/client";
import { getSetlist } from "../../src/endpoints/setlists";
import "dotenv/config";

/**
 * Example: Basic setlist lookup by ID
 *
 * This example demonstrates how to retrieve a specific setlist
 * using its unique identifier.
 */
async function basicSetlistLookup(): Promise<void> {
  // Create SetlistFM client with API key from environment
  // The client automatically uses STANDARD rate limiting (2 req/sec, 1440 req/day)
  const client = createSetlistFMClient({
    apiKey: process.env.SETLISTFM_API_KEY!,
    userAgent: "setlistfm-ts-examples (github.com/tkozzer/setlistfm-ts)",
  });

  // Get the HTTP client for making requests
  const httpClient = client.getHttpClient();

  try {
    // Example: Get The Beatles setlist from Hollywood Bowl (1964)
    console.log("🔍 Example: Setlist lookup");
    const setlistId = "63de4613";
    console.log(`Looking up setlist (ID: ${setlistId})...\n`);

    const setlist = await getSetlist(httpClient, setlistId);

    console.log("✅ Setlist found!");
    console.log(`Artist: ${setlist.artist.name}`);
    console.log(`Venue: ${setlist.venue.name}`);
    if (setlist.venue.city) {
      console.log(`Location: ${setlist.venue.city.name}, ${setlist.venue.city.state || setlist.venue.city.country?.name}`);
    }
    console.log(`Date: ${setlist.eventDate}`);
    if (setlist.tour) {
      console.log(`Tour: ${setlist.tour.name}`);
    }
    console.log(`Last Updated: ${setlist.lastUpdated}`);

    // Show sets and songs
    console.log(`\n🎵 Setlist (${setlist.sets.set.length} set${setlist.sets.set.length === 1 ? "" : "s"}):`);

    setlist.sets.set.forEach((set, setIndex) => {
      if (set.encore) {
        console.log(`\n  Encore ${set.encore}:`);
      }
      else if (set.name) {
        console.log(`\n  ${set.name}:`);
      }
      else {
        console.log(`\n  Set ${setIndex + 1}:`);
      }

      set.song.forEach((song, songIndex) => {
        let songInfo = `    ${songIndex + 1}. ${song.name}`;

        if (song.with) {
          songInfo += ` (with ${song.with.name})`;
        }
        if (song.cover) {
          songInfo += ` (${song.cover.name} cover)`;
        }
        if (song.tape) {
          songInfo += " [TAPE]";
        }
        if (song.info) {
          songInfo += ` - ${song.info}`;
        }

        console.log(songInfo);
      });
    });

    // Additional setlist information
    if (setlist.info) {
      console.log(`\n📝 Additional Info: ${setlist.info}`);
    }

    console.log(`\n🔗 Setlist URL: ${setlist.url}`);

    // Example: Check rate limit status
    console.log("\n📊 Rate limiting information:");
    const rateLimitStatus = client.getRateLimitStatus();
    console.log(`Profile: ${rateLimitStatus.profile}`);
    console.log(`Requests this second: ${rateLimitStatus.requestsThisSecond}/${rateLimitStatus.secondLimit}`);
    console.log(`Requests this day: ${rateLimitStatus.requestsThisDay}/${rateLimitStatus.dayLimit}`);
  }
  catch (error) {
    console.error("❌ Error looking up setlist:", error);

    if (error instanceof Error) {
      console.error(`Error message: ${error.message}`);
    }
  }
}

// Run the example if this script is executed directly
if (require.main === module) {
  basicSetlistLookup();
}

export { basicSetlistLookup };
