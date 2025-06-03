/**
 * @file searchArtists.ts
 * @description Example of searching for artists using various criteria.
 * @author tkozzer
 */

import { createSetlistFMClient } from "../../src/client";
import { searchArtists } from "../../src/endpoints/artists";
import "dotenv/config";

/**
 * Example: Search for artists using different criteria
 *
 * This example demonstrates various ways to search for artists
 * including by name, MBID, pagination, and sorting.
 */
async function searchArtistsExample(): Promise<void> {
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
    console.log("Searching for 'Radiohead'...\n");

    const nameSearch = await searchArtists(httpClient, {
      artistName: "Radiohead",
    });

    console.log(`✅ Found ${nameSearch.total} artists matching "Radiohead"`);
    console.log(`📄 Page ${nameSearch.page}, showing ${nameSearch.artist.length} results\n`);

    nameSearch.artist.slice(0, 3).forEach((artist, index) => {
      console.log(`${index + 1}. ${artist.name} (${artist.sortName})`);
      console.log(`   MBID: ${artist.mbid}`);
      if (artist.disambiguation) {
        console.log(`   Disambiguation: ${artist.disambiguation}`);
      }
      console.log("");
    });

    // Example 2: Search with pagination and sorting
    console.log("🔍 Example 2: Search with pagination and sorting");
    console.log("Searching for 'Beatles' with relevance sorting...\n");

    const paginatedSearch = await searchArtists(httpClient, {
      artistName: "Beatles",
      p: 1,
      sort: "relevance",
    });

    console.log(`✅ Found ${paginatedSearch.total} artists matching "Beatles"`);
    console.log(`📄 Page ${paginatedSearch.page}, ${paginatedSearch.itemsPerPage} items per page\n`);

    paginatedSearch.artist.slice(0, 5).forEach((artist, index) => {
      console.log(`${index + 1}. ${artist.name}`);
      console.log(`   Sort Name: ${artist.sortName}`);
      console.log(`   MBID: ${artist.mbid}`);
      console.log("");
    });

    // Example 3: Search by MBID (useful for validation)
    console.log("🔍 Example 3: Search by MBID");
    const beatlesMbid = "b10bbbfc-cf9e-42e0-be17-e2c3e1d2600d";
    console.log(`Searching by MBID: ${beatlesMbid}...\n`);

    const mbidSearch = await searchArtists(httpClient, {
      artistMbid: beatlesMbid,
    });

    if (mbidSearch.artist.length > 0) {
      const artist = mbidSearch.artist[0];
      console.log(`✅ Found artist: ${artist.name}`);
      console.log(`   Sort Name: ${artist.sortName}`);
      console.log(`   MBID: ${artist.mbid}`);
      if (artist.url) {
        console.log(`   URL: ${artist.url}`);
      }
    }

    // Example 4: Handle empty results
    console.log("\n🔍 Example 4: Handle empty search results");
    console.log("Searching for a non-existent artist...\n");

    try {
      const emptySearch = await searchArtists(httpClient, {
        artistName: "ThisArtistDoesNotExistForSure123456",
      });

      if (emptySearch.total === 0) {
        console.log("❌ No artists found matching the search criteria");
        console.log(`📊 Total results: ${emptySearch.total}`);
      }
    }
    catch (searchError: any) {
      // Handle expected 404 when no results are found
      if (searchError.statusCode === 404) {
        console.log("❌ No artists found matching the search criteria (404 response)");
        console.log("   This is expected when searching for non-existent artists");
      }
      else {
        // Re-throw unexpected errors
        throw searchError;
      }
    }

    // Show rate limiting information
    console.log("\n📊 Rate limiting information:");
    const rateLimitStatus = client.getRateLimitStatus();
    console.log(`Profile: ${rateLimitStatus.profile}`);
    console.log(`Requests this second: ${rateLimitStatus.requestsThisSecond}/${rateLimitStatus.secondLimit}`);
    console.log(`Requests this day: ${rateLimitStatus.requestsThisDay}/${rateLimitStatus.dayLimit}`);
  }
  catch (error) {
    console.error("❌ Error searching for artists:", error);

    if (error instanceof Error) {
      console.error(`Error message: ${error.message}`);
    }
  }
}

// Run the example if this script is executed directly
if (require.main === module) {
  searchArtistsExample();
}

export { searchArtistsExample };
