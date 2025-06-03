/**
 * @file completeExample.ts
 * @description Comprehensive example showcasing all artist endpoint functions.
 * @author tkozzer
 */

import { createSetlistFMClient } from "../../src/client";
import "dotenv/config";

/**
 * Comprehensive example showcasing all artist endpoints
 *
 * This example demonstrates a real-world workflow:
 * 1. Search for artists by name
 * 2. Get detailed artist information
 * 3. Retrieve artist's setlists
 * 4. Analyze the data
 */
async function completeArtistExample(): Promise<void> {
  // Create SetlistFM client with API key from environment
  // The client automatically uses STANDARD rate limiting (2 req/sec, 1440 req/day)
  const client = createSetlistFMClient({
    apiKey: process.env.SETLISTFM_API_KEY!,
    userAgent: "setlistfm-ts-examples (github.com/tkozzer/setlistfm-ts)",
  });

  try {
    console.log("🎼 Complete Artist Workflow Example");
    console.log("===================================\n");

    // Step 1: Search for artists
    console.log("🔍 Step 1: Search for artists");
    const searchQuery = "Pink Floyd";
    console.log(`Searching for "${searchQuery}"...\n`);

    const searchResults = await client.searchArtists({
      artistName: searchQuery,
      sort: "relevance",
    });

    console.log(`✅ Found ${searchResults.total} artists matching "${searchQuery}"`);

    if (searchResults.artist.length === 0) {
      console.log("❌ No artists found. Exiting...");
      return;
    }

    // Show search results
    console.log("\n📋 Top search results:");
    searchResults.artist.slice(0, 3).forEach((artist, index) => {
      console.log(`  ${index + 1}. ${artist.name} (${artist.sortName})`);
      console.log(`     MBID: ${artist.mbid}`);
      if (artist.disambiguation) {
        console.log(`     Note: ${artist.disambiguation}`);
      }
    });

    // Step 2: Get detailed artist information
    const selectedArtist = searchResults.artist[0];
    console.log(`\n🎨 Step 2: Get detailed information for "${selectedArtist.name}"`);
    console.log(`Using MBID: ${selectedArtist.mbid}\n`);

    const artistDetails = await client.getArtist(selectedArtist.mbid);

    console.log("✅ Artist details retrieved:");
    console.log(`   Name: ${artistDetails.name}`);
    console.log(`   Sort Name: ${artistDetails.sortName}`);
    console.log(`   MBID: ${artistDetails.mbid}`);

    if (artistDetails.disambiguation) {
      console.log(`   Disambiguation: ${artistDetails.disambiguation}`);
    }

    if (artistDetails.url) {
      console.log(`   Setlist.fm URL: ${artistDetails.url}`);
    }

    // Step 3: Get artist's setlists
    console.log(`\n🎵 Step 3: Get setlists for ${artistDetails.name}`);
    console.log("Fetching first page of setlists...\n");

    const setlists = await client.getArtistSetlists(artistDetails.mbid);

    console.log(`✅ Found ${setlists.total} total setlists`);
    console.log(`📄 Page ${setlists.page}, showing ${setlists.setlist.length} setlists\n`);

    if (setlists.setlist.length === 0) {
      console.log("❌ No setlists found for this artist.");
      return;
    }

    // Step 4: Analyze the data
    console.log("📊 Step 4: Analyze setlist data");
    console.log("==============================\n");

    // Show recent setlists
    console.log("🎤 Recent performances:");
    setlists.setlist
      .sort((a, b) => b.eventDate.localeCompare(a.eventDate))
      .slice(0, 5)
      .forEach((setlist, index) => {
        console.log(`  ${index + 1}. ${setlist.eventDate} - ${setlist.venue.name}`);
        console.log(`     📍 ${setlist.venue.city.name}, ${setlist.venue.city.country.name}`);

        if (setlist.tour) {
          console.log(`     🎤 Tour: ${setlist.tour.name}`);
        }

        if (setlist.sets.set.length > 0) {
          const totalSongs = setlist.sets.set.reduce((sum, set) => sum + set.song.length, 0);
          console.log(`     🎵 Songs performed: ${totalSongs}`);
        }

        console.log("");
      });

    // Performance statistics
    const uniqueVenues = new Set(setlists.setlist.map(s => s.venue.name));
    const uniqueCities = new Set(setlists.setlist.map(s => s.venue.city.name));
    const uniqueCountries = new Set(setlists.setlist.map(s => s.venue.city.country.name));

    console.log("📈 Performance statistics (this page):");
    console.log(`   🏟️  Unique venues: ${uniqueVenues.size}`);
    console.log(`   🏙️  Unique cities: ${uniqueCities.size}`);
    console.log(`   🌍 Unique countries: ${uniqueCountries.size}\n`);

    // Top countries
    const countryCounts = setlists.setlist.reduce<Record<string, number>>((acc, setlist) => {
      const country = setlist.venue.city.country.name;
      acc[country] = (acc[country] || 0) + 1;
      return acc;
    }, {});

    console.log("🌍 Top performance countries:");
    Object.entries(countryCounts)
      .sort(([, countA], [, countB]) => countB - countA)
      .slice(0, 5)
      .forEach(([country, count]) => {
        console.log(`   ${country}: ${count} performance${count === 1 ? "" : "s"}`);
      });

    // Performance years
    const yearCounts = setlists.setlist.reduce<Record<string, number>>((acc, setlist) => {
      const year = setlist.eventDate.split("-")[0];
      acc[year] = (acc[year] || 0) + 1;
      return acc;
    }, {});

    const sortedYears = Object.entries(yearCounts)
      .sort(([yearA], [yearB]) => yearB.localeCompare(yearA));

    if (sortedYears.length > 0) {
      console.log("\n📅 Performance activity by year:");
      sortedYears.slice(0, 10).forEach(([year, count]) => {
        console.log(`   ${year}: ${count} performance${count === 1 ? "" : "s"}`);
      });
    }

    // Summary
    console.log("\n🎯 Summary");
    console.log("===========");
    console.log(`Artist: ${artistDetails.name}`);
    console.log(`Total setlists: ${setlists.total}`);
    console.log(`Years active: ${Math.min(...sortedYears.map(([year]) => Number.parseInt(year)))} - ${Math.max(...sortedYears.map(([year]) => Number.parseInt(year)))}`);
    console.log(`Countries performed in: ${uniqueCountries.size}`);

    if (artistDetails.url) {
      console.log(`\n🔗 View all setlists: ${artistDetails.url}`);
    }

    // Show rate limiting information
    console.log("\n📊 Rate limiting information:");
    const rateLimitStatus = client.getRateLimitStatus();
    console.log(`Profile: ${rateLimitStatus.profile}`);
    console.log(`Requests this second: ${rateLimitStatus.requestsThisSecond}/${rateLimitStatus.secondLimit}`);
    console.log(`Requests this day: ${rateLimitStatus.requestsThisDay}/${rateLimitStatus.dayLimit}`);
  }
  catch (error) {
    console.error("❌ Error in complete artist example:", error);

    if (error instanceof Error) {
      console.error(`Error message: ${error.message}`);
    }
  }
}

// Run the example if this script is executed directly
if (require.main === module) {
  completeArtistExample();
}

export { completeArtistExample };
