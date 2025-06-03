/**
 * @file advancedAnalysis.ts
 * @description Advanced setlist analysis demonstrating data processing and statistics.
 * @author tkozzer
 */

import type { Setlist } from "../../src/endpoints/setlists";
import { createSetlistFMClient } from "../../src/client";
import { getSetlist, searchSetlists } from "../../src/endpoints/setlists";
import "dotenv/config";

/**
 * Example: Advanced setlist analysis and statistics
 *
 * This example demonstrates advanced data processing techniques
 * for analyzing tour patterns, song frequencies, and venue statistics.
 */
async function advancedSetlistAnalysis(): Promise<void> {
  // Create SetlistFM client with API key from environment
  // The client automatically uses STANDARD rate limiting (2 req/sec, 1440 req/day)
  const client = createSetlistFMClient({
    apiKey: process.env.SETLISTFM_API_KEY!,
    userAgent: "setlistfm-ts-examples (github.com/tkozzer/setlistfm-ts)",
  });

  // Get the HTTP client for making requests
  const httpClient = client.getHttpClient();

  try {
    // Step 1: Collect comprehensive tour data
    console.log("🔍 Step 1: Collecting comprehensive tour data");
    console.log("Gathering Pearl Jam setlists from multiple years...\n");

    const years = [2022, 2023];
    const allSetlists: Setlist[] = [];

    for (const year of years) {
      console.log(`📅 Collecting ${year} data...`);

      const yearSetlists = await searchSetlists(httpClient, {
        artistName: "Pearl Jam",
        year,
        p: 1,
      });

      console.log(`   Found ${yearSetlists.total} setlists for ${year}`);
      allSetlists.push(...yearSetlists.setlist);

      // Get additional pages if there are more results
      if (yearSetlists.total > yearSetlists.itemsPerPage) {
        const totalPages = Math.min(3, Math.ceil(yearSetlists.total / yearSetlists.itemsPerPage));

        for (let page = 2; page <= totalPages; page++) {
          const additionalSetlists = await searchSetlists(httpClient, {
            artistName: "Pearl Jam",
            year,
            p: page,
          });
          allSetlists.push(...additionalSetlists.setlist);
        }
      }
    }

    console.log(`\n✅ Collected ${allSetlists.length} total setlists for analysis\n`);

    // Step 2: Tour and venue analysis
    console.log("🗺️ Step 2: Geographic and venue analysis");

    const geoAnalysis = {
      countries: new Map<string, number>(),
      cities: new Map<string, number>(),
      venues: new Map<string, { count: number; city: string; shows: string[] }>(),
      states: new Map<string, number>(),
    };

    allSetlists.forEach((setlist) => {
      const country = setlist.venue.city?.country?.name || "Unknown";
      const city = setlist.venue.city?.name || "Unknown";
      const state = setlist.venue.city?.state || "";
      const venue = setlist.venue.name;

      // Count by country
      geoAnalysis.countries.set(country, (geoAnalysis.countries.get(country) || 0) + 1);

      // Count by city
      geoAnalysis.cities.set(city, (geoAnalysis.cities.get(city) || 0) + 1);

      // Count by state (if available)
      if (state) {
        geoAnalysis.states.set(state, (geoAnalysis.states.get(state) || 0) + 1);
      }

      // Count by venue
      if (!geoAnalysis.venues.has(venue)) {
        geoAnalysis.venues.set(venue, { count: 0, city, shows: [] });
      }
      const venueData = geoAnalysis.venues.get(venue)!;
      venueData.count += 1;
      venueData.shows.push(setlist.eventDate);
    });

    console.log("🌍 Geographic breakdown:");
    console.log(`Countries visited: ${geoAnalysis.countries.size}`);

    // Top countries
    const topCountries = Array.from(geoAnalysis.countries.entries())
      .sort(([, a], [, b]) => b - a)
      .slice(0, 5);

    topCountries.forEach(([country, count]) => {
      console.log(`   ${country}: ${count} shows`);
    });

    // Venue analysis
    console.log(`\n🏟️ Venue analysis:`);
    console.log(`Unique venues: ${geoAnalysis.venues.size}`);

    const multipleShowVenues = Array.from(geoAnalysis.venues.entries())
      .filter(([, data]) => data.count > 1)
      .sort(([, a], [, b]) => b.count - a.count);

    if (multipleShowVenues.length > 0) {
      console.log("\nVenues with multiple shows:");
      multipleShowVenues.slice(0, 5).forEach(([venue, data]) => {
        console.log(`   ${venue} (${data.city}): ${data.count} shows`);
        console.log(`      Dates: ${data.shows.join(", ")}`);
      });
    }

    // Step 3: Song frequency analysis
    console.log("\n🎵 Step 3: Song frequency and setlist analysis");

    const songAnalysis = {
      allSongs: new Map<string, { count: number; dates: string[] }>(),
      coverSongs: new Map<string, { count: number; originalArtist: string; dates: string[] }>(),
      guestAppearances: new Map<string, { count: number; songs: string[]; dates: string[] }>(),
      totalSongs: 0,
      totalSets: 0,
      totalEncores: 0,
    };

    // Get detailed setlist information for a sample of shows
    const sampleSetlists = allSetlists.slice(0, Math.min(10, allSetlists.length));
    console.log(`Analyzing detailed song data from ${sampleSetlists.length} shows...\n`);

    for (const setlistSummary of sampleSetlists) {
      try {
        const detailedSetlist = await getSetlist(httpClient, setlistSummary.id);

        detailedSetlist.sets.set.forEach((set) => {
          songAnalysis.totalSets += 1;
          if (set.encore) {
            songAnalysis.totalEncores += 1;
          }

          set.song.forEach((song) => {
            songAnalysis.totalSongs += 1;

            // Track all songs
            if (!songAnalysis.allSongs.has(song.name)) {
              songAnalysis.allSongs.set(song.name, { count: 0, dates: [] });
            }
            const songData = songAnalysis.allSongs.get(song.name)!;
            songData.count += 1;
            songData.dates.push(detailedSetlist.eventDate);

            // Track covers
            if (song.cover) {
              const coverKey = `${song.name} (${song.cover.name})`;
              if (!songAnalysis.coverSongs.has(coverKey)) {
                songAnalysis.coverSongs.set(coverKey, {
                  count: 0,
                  originalArtist: song.cover.name,
                  dates: [],
                });
              }
              const coverData = songAnalysis.coverSongs.get(coverKey)!;
              coverData.count += 1;
              coverData.dates.push(detailedSetlist.eventDate);
            }

            // Track guest appearances
            if (song.with) {
              const guestName = song.with.name;
              if (!songAnalysis.guestAppearances.has(guestName)) {
                songAnalysis.guestAppearances.set(guestName, { count: 0, songs: [], dates: [] });
              }
              const guestData = songAnalysis.guestAppearances.get(guestName)!;
              guestData.count += 1;
              guestData.songs.push(song.name);
              guestData.dates.push(detailedSetlist.eventDate);
            }
          });
        });

        console.log(`   ✓ Processed ${detailedSetlist.eventDate} - ${detailedSetlist.venue.name}`);
      }
      catch (error) {
        console.log(`   ❌ Could not process setlist ${setlistSummary.id}: ${error}`);
      }
    }

    // Song statistics
    console.log(`\n📊 Song Statistics:`);
    console.log(`Total songs performed: ${songAnalysis.totalSongs}`);
    console.log(`Unique songs: ${songAnalysis.allSongs.size}`);
    console.log(`Cover songs: ${songAnalysis.coverSongs.size}`);
    console.log(`Guest appearances: ${songAnalysis.guestAppearances.size}`);

    const avgSongsPerShow = Math.round(songAnalysis.totalSongs / sampleSetlists.length);
    const avgSetsPerShow = Math.round(songAnalysis.totalSets / sampleSetlists.length);
    console.log(`Average songs per show: ${avgSongsPerShow}`);
    console.log(`Average sets per show: ${avgSetsPerShow}`);
    console.log(`Total encores: ${songAnalysis.totalEncores}`);

    // Most played songs
    console.log(`\n🎯 Most frequently played songs:`);
    const mostPlayed = Array.from(songAnalysis.allSongs.entries())
      .sort(([, a], [, b]) => b.count - a.count)
      .slice(0, 10);

    mostPlayed.forEach(([song, data], index) => {
      const percentage = Math.round((data.count / sampleSetlists.length) * 100);
      console.log(`${index + 1}. "${song}" - ${data.count}/${sampleSetlists.length} shows (${percentage}%)`);
    });

    // Cover song analysis
    if (songAnalysis.coverSongs.size > 0) {
      console.log(`\n📀 Cover Songs:`);
      const covers = Array.from(songAnalysis.coverSongs.entries())
        .sort(([, a], [, b]) => b.count - a.count)
        .slice(0, 5);

      covers.forEach(([cover, data]) => {
        console.log(`   "${cover}" - ${data.count} time${data.count === 1 ? "" : "s"}`);
        console.log(`      Performed: ${data.dates.join(", ")}`);
      });
    }

    // Guest appearance analysis
    if (songAnalysis.guestAppearances.size > 0) {
      console.log(`\n🤝 Guest Appearances:`);
      const guests = Array.from(songAnalysis.guestAppearances.entries())
        .sort(([, a], [, b]) => b.count - a.count);

      guests.forEach(([guest, data]) => {
        console.log(`   ${guest} - ${data.count} song${data.count === 1 ? "" : "s"}`);
        console.log(`      Songs: ${data.songs.join(", ")}`);
        console.log(`      Dates: ${data.dates.join(", ")}`);
      });
    }

    // Step 4: Temporal analysis
    console.log(`\n📅 Step 4: Temporal patterns`);

    const temporalAnalysis = {
      byMonth: new Map<number, number>(),
      byYear: new Map<number, { shows: number; songs: number }>(),
      showLengths: [] as number[],
    };

    allSetlists.forEach((setlist) => {
      // Parse date (dd-MM-yyyy format)
      const [, month, year] = setlist.eventDate.split("-").map(Number);

      // Count by month
      temporalAnalysis.byMonth.set(month, (temporalAnalysis.byMonth.get(month) || 0) + 1);

      // Count by year
      if (!temporalAnalysis.byYear.has(year)) {
        temporalAnalysis.byYear.set(year, { shows: 0, songs: 0 });
      }
      const yearData = temporalAnalysis.byYear.get(year)!;
      yearData.shows += 1;

      // Track show length
      const songCount = setlist.sets.set.reduce((total, set) => total + set.song.length, 0);
      temporalAnalysis.showLengths.push(songCount);
      yearData.songs += songCount;
    });

    console.log("📊 Touring patterns:");

    // Month analysis
    const monthNames = ["", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    console.log("\nShows by month:");
    Array.from(temporalAnalysis.byMonth.entries())
      .sort(([a], [b]) => a - b)
      .forEach(([month, count]) => {
        console.log(`   ${monthNames[month]}: ${count} shows`);
      });

    // Year comparison
    console.log("\nYear-over-year comparison:");
    Array.from(temporalAnalysis.byYear.entries())
      .sort(([a], [b]) => a - b)
      .forEach(([year, data]) => {
        const avgSongs = Math.round(data.songs / data.shows);
        console.log(`   ${year}: ${data.shows} shows, avg ${avgSongs} songs per show`);
      });

    // Show length statistics
    const totalShows = temporalAnalysis.showLengths.length;
    const avgShowLength = Math.round(
      temporalAnalysis.showLengths.reduce((sum, length) => sum + length, 0) / totalShows,
    );
    const minShowLength = Math.min(...temporalAnalysis.showLengths);
    const maxShowLength = Math.max(...temporalAnalysis.showLengths);

    console.log(`\n🎼 Show length statistics:`);
    console.log(`   Average: ${avgShowLength} songs`);
    console.log(`   Shortest: ${minShowLength} songs`);
    console.log(`   Longest: ${maxShowLength} songs`);

    // Final rate limit status
    console.log("\n📊 Rate Limiting Information:");
    const rateLimitStatus = client.getRateLimitStatus();
    console.log(`Profile: ${rateLimitStatus.profile}`);
    console.log(`Requests this second: ${rateLimitStatus.requestsThisSecond}/${rateLimitStatus.secondLimit}`);
    console.log(`Requests this day: ${rateLimitStatus.requestsThisDay}/${rateLimitStatus.dayLimit}`);
  }
  catch (error) {
    console.error("❌ Error in advanced setlist analysis:", error);

    if (error instanceof Error) {
      console.error(`Error message: ${error.message}`);
    }
  }
}

// Run the example if this script is executed directly
if (require.main === module) {
  advancedSetlistAnalysis();
}

export { advancedSetlistAnalysis };
