/* eslint-disable no-console */
/**
 * @file getArtistSetlists.ts
 * @description Example of retrieving setlists for a specific artist.
 * @author tkozzer
 */

import { getArtistSetlists } from "../../src/endpoints/artists";

import { HttpClient } from "../../src/utils/http";
import "dotenv/config";

/**
 * Example: Get setlists for an artist
 *
 * This example demonstrates how to retrieve setlists for a specific artist
 * with pagination support.
 */
async function getArtistSetlistsExample(): Promise<void> {
  const httpClient = new HttpClient({
    // eslint-disable-next-line node/no-process-env
    apiKey: process.env.SETLISTFM_API_KEY!,
    userAgent: "setlistfm-ts-examples (github.com/tkozzer/setlistfm-ts)",
  });

  try {
    // Example 1: Get first page of setlists for The Beatles
    console.log("🎵 Example 1: Get setlists for The Beatles");
    const beatlesMbid = "b10bbbfc-cf9e-42e0-be17-e2c3e1d2600d";
    console.log(`Artist MBID: ${beatlesMbid}\n`);

    const firstPage = await getArtistSetlists(httpClient, beatlesMbid);

    console.log(`✅ Found ${firstPage.total} total setlists for The Beatles`);
    console.log(`📄 Page ${firstPage.page}, showing ${firstPage.setlist.length} setlists\n`);

    // Display first few setlists
    firstPage.setlist.slice(0, 5).forEach((setlist, index) => {
      console.log(`${index + 1}. ${setlist.eventDate} - ${setlist.venue.name}`);
      console.log(`   📍 ${setlist.venue.city.name}, ${setlist.venue.city.country.name}`);
      console.log(`   🆔 Setlist ID: ${setlist.id}`);

      if (setlist.tour) {
        console.log(`   🎤 Tour: ${setlist.tour.name}`);
      }

      if (setlist.info) {
        console.log(`   ℹ️  Info: ${setlist.info}`);
      }

      if (setlist.url) {
        console.log(`   🔗 URL: ${setlist.url}`);
      }

      console.log("");
    });

    // Example 2: Get a specific page of setlists
    if (firstPage.total > firstPage.itemsPerPage) {
      console.log("🎵 Example 2: Get second page of setlists");
      console.log(`Fetching page 2 of setlists...\n`);

      const secondPage = await getArtistSetlists(httpClient, beatlesMbid, { p: 2 });

      console.log(`📄 Page ${secondPage.page}, showing ${secondPage.setlist.length} setlists`);
      console.log(`📊 Total pages available: ${Math.ceil(secondPage.total / secondPage.itemsPerPage)}\n`);

      // Display setlist count by year
      const setlistsByYear = secondPage.setlist.reduce<Record<string, number>>((acc, setlist) => {
        const year = setlist.eventDate.split("-")[0];
        acc[year] = (acc[year] || 0) + 1;
        return acc;
      }, {});

      console.log("📊 Setlists by year on this page:");
      Object.entries(setlistsByYear)
        .sort(([yearA], [yearB]) => yearB.localeCompare(yearA))
        .forEach(([year, count]) => {
          console.log(`   ${year}: ${count} setlist${count === 1 ? "" : "s"}`);
        });
    }

    // Example 3: Analyze setlist data
    console.log("\n🎵 Example 3: Analyze setlist data");
    console.log("Analyzing venue information...\n");

    const uniqueVenues = new Set(firstPage.setlist.map(s => s.venue.name));
    const uniqueCountries = new Set(firstPage.setlist.map(s => s.venue.city.country.name));

    console.log(`🏟️  Unique venues on this page: ${uniqueVenues.size}`);
    console.log(`🌍 Countries performed in: ${uniqueCountries.size}`);

    // Show top countries
    const countryCounts = firstPage.setlist.reduce<Record<string, number>>((acc, setlist) => {
      const country = setlist.venue.city.country.name;
      acc[country] = (acc[country] || 0) + 1;
      return acc;
    }, {});

    console.log("\n🌍 Top countries by setlist count:");
    Object.entries(countryCounts)
      .sort(([, countA], [, countB]) => countB - countA)
      .slice(0, 5)
      .forEach(([country, count]) => {
        console.log(`   ${country}: ${count} setlist${count === 1 ? "" : "s"}`);
      });
  }
  catch (error) {
    console.error("❌ Error getting artist setlists:", error);

    if (error instanceof Error) {
      console.error(`Error message: ${error.message}`);
    }
  }
}

// Run the example if this script is executed directly
if (require.main === module) {
  getArtistSetlistsExample();
}

export { getArtistSetlistsExample };
