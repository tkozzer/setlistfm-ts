/* eslint-disable no-console */
/**
 * @file searchArtists.ts
 * @description Example of searching for artists using various criteria.
 * @author tkozzer
 */

import { searchArtists } from "../../src/endpoints/artists";

import { HttpClient } from "../../src/utils/http";
import "dotenv/config";

/**
 * Example: Search for artists using different criteria
 *
 * This example demonstrates various ways to search for artists
 * including by name, MBID, pagination, and sorting.
 */
async function searchArtistsExample(): Promise<void> {
  const httpClient = new HttpClient({
    // eslint-disable-next-line node/no-process-env
    apiKey: process.env.SETLISTFM_API_KEY!,
    userAgent: "setlistfm-ts-examples (github.com/tkozzer/setlistfm-ts)",
  });

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

    const emptySearch = await searchArtists(httpClient, {
      artistName: "ThisArtistDoesNotExistForSure123456",
    });

    if (emptySearch.total === 0) {
      console.log("❌ No artists found matching the search criteria");
      console.log(`📊 Total results: ${emptySearch.total}`);
    }
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
