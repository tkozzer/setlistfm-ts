/**
 * @file basicArtistLookup.ts
 * @description Basic example of looking up an artist by MusicBrainz MBID.
 * @author tkozzer
 */

import { createSetlistFMClient } from "../../src/client";
import { getArtist, searchArtists } from "../../src/endpoints/artists";
import "dotenv/config";

/**
 * Example: Basic artist lookup by MBID
 *
 * This example demonstrates how to retrieve artist information
 * using their MusicBrainz identifier (MBID).
 */
async function basicArtistLookup(): Promise<void> {
  // Create SetlistFM client with API key from environment
  // The client automatically uses STANDARD rate limiting (2 req/sec, 1440 req/day)
  const client = createSetlistFMClient({

    apiKey: process.env.SETLISTFM_API_KEY!,
    userAgent: "setlistfm-ts-examples (github.com/tkozzer/setlistfm-ts)",
  });

  // Get the HTTP client for making requests
  const httpClient = client.getHttpClient();

  try {
    // Example 1: Direct artist lookup using The Beatles MBID
    console.log("🔍 Example 1: Direct artist lookup");
    const beatlesMbid = "b10bbbfc-cf9e-42e0-be17-e2c3e1d2600d";
    console.log(`Looking up The Beatles (MBID: ${beatlesMbid})...\n`);

    const beatles = await getArtist(httpClient, beatlesMbid);

    console.log("✅ Artist found!");
    console.log(`Name: ${beatles.name}`);
    console.log(`Sort Name: ${beatles.sortName}`);
    if (beatles.disambiguation) {
      console.log(`Disambiguation: ${beatles.disambiguation}`);
    }
    if (beatles.url) {
      console.log(`Setlist.fm URL: ${beatles.url}`);
    }

    // Example 2: Search for artists and then get details
    console.log("\n🔍 Example 2: Search and lookup");
    console.log("Searching for 'Metallica'...\n");

    const searchResults = await searchArtists(httpClient, {
      artistName: "Metallica",
    });

    console.log(`✅ Search successful! Found ${searchResults.total} artists matching "Metallica"`);

    if (searchResults.artist.length > 0) {
      // Get the first result that looks like the actual Metallica band
      const metallica = searchResults.artist.find(artist =>
        artist.name === "Metallica" || artist.name.includes("Metallica"),
      ) || searchResults.artist[0];

      console.log(`\n📋 Using artist from search results:`);
      console.log(`Name: ${metallica.name}`);
      console.log(`MBID: ${metallica.mbid}`);

      // Get detailed artist information
      console.log("\n🔍 Looking up detailed artist information...");
      const artistDetails = await getArtist(httpClient, metallica.mbid);

      console.log("\n✅ Artist details found!");
      console.log(`Name: ${artistDetails.name}`);
      console.log(`Sort Name: ${artistDetails.sortName}`);
      if (artistDetails.disambiguation) {
        console.log(`Disambiguation: ${artistDetails.disambiguation}`);
      }
      if (artistDetails.url) {
        console.log(`Setlist.fm URL: ${artistDetails.url}`);
      }
    }

    // Example 3: Check rate limit status
    console.log("\n📊 Rate limiting information:");
    const rateLimitStatus = client.getRateLimitStatus();
    console.log(`Profile: ${rateLimitStatus.profile}`);
    console.log(`Requests this second: ${rateLimitStatus.requestsThisSecond}/${rateLimitStatus.secondLimit}`);
    console.log(`Requests this day: ${rateLimitStatus.requestsThisDay}/${rateLimitStatus.dayLimit}`);
  }
  catch (error) {
    console.error("❌ Error looking up artist:", error);

    if (error instanceof Error) {
      console.error(`Error message: ${error.message}`);
    }
  }
}

// Run the example if this script is executed directly
if (require.main === module) {
  basicArtistLookup();
}

export { basicArtistLookup };
