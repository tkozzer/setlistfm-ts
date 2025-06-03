/**
 * @file completeExample.ts
 * @description Complete workflow using all setlist endpoints - search, analyze, and lookup.
 * @author tkozzer
 */

import { createSetlistFMClient } from "../../src/client";
import "dotenv/config";

/**
 * Example: Complete setlist workflow
 *
 * This example demonstrates a real-world workflow combining
 * search functionality with detailed setlist analysis using the type-safe client.
 */
async function completeSetlistExample(): Promise<void> {
  // Create SetlistFM client with automatic STANDARD rate limiting
  const client = createSetlistFMClient({
    apiKey: process.env.SETLISTFM_API_KEY!,
    userAgent: "setlistfm-ts-examples (github.com/tkozzer/setlistfm-ts)",
  });

  try {
    // Step 1: Search for setlists by a specific artist and tour
    console.log("🔍 Step 1: Finding Radiohead setlists from recent tours");
    console.log("Searching for Radiohead setlists...\n");

    const radioheadSearch = await client.searchSetlists({
      artistName: "Radiohead",
      year: 2023,
      p: 1,
    });

    console.log(`✅ Found ${radioheadSearch.total} Radiohead setlists from 2023`);
    console.log(`Analyzing first ${Math.min(radioheadSearch.setlist.length, 5)} setlists...\n`);

    // Step 2: Analyze the search results
    const recentSetlists = radioheadSearch.setlist.slice(0, 5);
    const analysis = {
      totalShows: recentSetlists.length,
      countries: new Set<string>(),
      venues: new Set<string>(),
      cities: new Set<string>(),
      tours: new Set<string>(),
      totalSongs: 0,
      averageSongs: 0,
    };

    console.log("📊 Quick Analysis:");
    recentSetlists.forEach((setlist, index) => {
      const songCount = setlist.sets.set.reduce((total, set) => total + set.song.length, 0);
      analysis.totalSongs += songCount;

      if (setlist.venue.city?.country?.name) {
        analysis.countries.add(setlist.venue.city.country.name);
      }
      if (setlist.venue.city?.name) {
        analysis.cities.add(setlist.venue.city.name);
      }
      analysis.venues.add(setlist.venue.name);
      if (setlist.tour?.name) {
        analysis.tours.add(setlist.tour.name);
      }

      console.log(`${index + 1}. ${setlist.eventDate} - ${setlist.venue.name}, ${setlist.venue.city?.name}`);
      console.log(`   Songs: ${songCount}, Tour: ${setlist.tour?.name || "No tour info"}`);
    });

    analysis.averageSongs = Math.round(analysis.totalSongs / analysis.totalShows);

    console.log("\n📈 Summary Statistics:");
    console.log(`• Shows analyzed: ${analysis.totalShows}`);
    console.log(`• Countries visited: ${analysis.countries.size}`);
    console.log(`• Cities visited: ${analysis.cities.size}`);
    console.log(`• Unique venues: ${analysis.venues.size}`);
    console.log(`• Tours: ${analysis.tours.size}`);
    console.log(`• Total songs performed: ${analysis.totalSongs}`);
    console.log(`• Average songs per show: ${analysis.averageSongs}`);

    // Step 3: Get detailed information for the most recent setlist
    if (recentSetlists.length > 0) {
      const latestSetlist = recentSetlists[0];
      console.log(`\n🎵 Step 3: Detailed analysis of most recent show`);
      console.log(`Getting detailed setlist for ${latestSetlist.artist.name} on ${latestSetlist.eventDate}...\n`);

      const detailedSetlist = await client.getSetlist(latestSetlist.id);

      console.log("✅ Detailed setlist retrieved!");
      console.log(`🎤 Artist: ${detailedSetlist.artist.name}`);
      console.log(`📅 Date: ${detailedSetlist.eventDate}`);
      console.log(`🏟️ Venue: ${detailedSetlist.venue.name}`);
      if (detailedSetlist.venue.city) {
        console.log(`📍 Location: ${detailedSetlist.venue.city.name}, ${detailedSetlist.venue.city.state || detailedSetlist.venue.city.country?.name}`);
      }
      if (detailedSetlist.tour) {
        console.log(`🎪 Tour: ${detailedSetlist.tour.name}`);
      }

      // Analyze the setlist structure
      const setAnalysis = {
        totalSets: detailedSetlist.sets.set.length,
        totalSongs: 0,
        encores: 0,
        covers: 0,
        tapeSongs: 0,
        guestAppearances: 0,
        songsWithInfo: 0,
      };

      detailedSetlist.sets.set.forEach((set) => {
        setAnalysis.totalSongs += set.song.length;
        if (set.encore) {
          setAnalysis.encores += 1;
        }

        set.song.forEach((song) => {
          if (song.cover)
            setAnalysis.covers += 1;
          if (song.tape)
            setAnalysis.tapeSongs += 1;
          if (song.with)
            setAnalysis.guestAppearances += 1;
          if (song.info)
            setAnalysis.songsWithInfo += 1;
        });
      });

      console.log(`\n🎼 Setlist Breakdown:`);
      console.log(`• Total sets: ${setAnalysis.totalSets}`);
      console.log(`• Total songs: ${setAnalysis.totalSongs}`);
      console.log(`• Encores: ${setAnalysis.encores}`);
      console.log(`• Cover songs: ${setAnalysis.covers}`);
      console.log(`• Tape/backing tracks: ${setAnalysis.tapeSongs}`);
      console.log(`• Guest appearances: ${setAnalysis.guestAppearances}`);
      console.log(`• Songs with special notes: ${setAnalysis.songsWithInfo}`);

      // Show the actual setlist
      console.log(`\n🎵 Complete Setlist:`);
      detailedSetlist.sets.set.forEach((set, setIndex) => {
        if (set.encore) {
          console.log(`\n  🎆 Encore ${set.encore}:`);
        }
        else if (set.name) {
          console.log(`\n  📀 ${set.name}:`);
        }
        else {
          console.log(`\n  📀 Set ${setIndex + 1}:`);
        }

        set.song.forEach((song, songIndex) => {
          let songInfo = `    ${songIndex + 1}. ${song.name}`;

          if (song.with) {
            songInfo += ` 🤝 (with ${song.with.name})`;
          }
          if (song.cover) {
            songInfo += ` 📀 (${song.cover.name} cover)`;
          }
          if (song.tape) {
            songInfo += " 📼 [TAPE]";
          }
          if (song.info) {
            songInfo += ` ℹ️ (${song.info})`;
          }

          console.log(songInfo);
        });
      });

      if (detailedSetlist.info) {
        console.log(`\n📝 Show Notes: ${detailedSetlist.info}`);
      }

      console.log(`\n🔗 Setlist URL: ${detailedSetlist.url}`);
    }

    // Step 4: Find and compare setlists from different years
    console.log(`\n🔍 Step 4: Comparing Radiohead across different years`);
    console.log("Getting setlists from 2022 for comparison...\n");

    const radiohead2022 = await client.searchSetlists({
      artistName: "Radiohead",
      year: 2022,
      p: 1,
    });

    console.log(`✅ Found ${radiohead2022.total} Radiohead setlists from 2022`);

    if (radiohead2022.setlist.length > 0) {
      const comparison2022 = {
        totalShows: Math.min(radiohead2022.setlist.length, 5),
        totalSongs: 0,
        countries: new Set<string>(),
        venues: new Set<string>(),
      };

      radiohead2022.setlist.slice(0, 5).forEach((setlist) => {
        const songCount = setlist.sets.set.reduce((total, set) => total + set.song.length, 0);
        comparison2022.totalSongs += songCount;

        if (setlist.venue.city?.country?.name) {
          comparison2022.countries.add(setlist.venue.city.country.name);
        }
        comparison2022.venues.add(setlist.venue.name);
      });

      const avg2022 = Math.round(comparison2022.totalSongs / comparison2022.totalShows);

      console.log("📊 Year-over-year comparison (first 5 shows):");
      console.log(`• 2023: ${analysis.averageSongs} avg songs, ${analysis.countries.size} countries, ${analysis.venues.size} venues`);
      console.log(`• 2022: ${avg2022} avg songs, ${comparison2022.countries.size} countries, ${comparison2022.venues.size} venues`);

      const songDifference = analysis.averageSongs - avg2022;
      if (songDifference > 0) {
        console.log(`📈 2023 shows averaged ${songDifference} more songs per show`);
      }
      else if (songDifference < 0) {
        console.log(`📉 2023 shows averaged ${Math.abs(songDifference)} fewer songs per show`);
      }
      else {
        console.log("📊 Average songs per show remained the same");
      }
    }

    // Final rate limit status
    console.log("\n📊 Final Rate Limiting Information:");
    const rateLimitStatus = client.getRateLimitStatus();
    console.log(`Profile: ${rateLimitStatus.profile}`);
    console.log(`Requests this second: ${rateLimitStatus.requestsThisSecond}/${rateLimitStatus.secondLimit}`);
    console.log(`Requests this day: ${rateLimitStatus.requestsThisDay}/${rateLimitStatus.dayLimit}`);
    console.log(`Total API calls made in this example: ${rateLimitStatus.requestsThisDay}`);
  }
  catch (error) {
    console.error("❌ Error in complete setlist example:", error);

    if (error instanceof Error) {
      console.error(`Error message: ${error.message}`);
    }
  }
}

// Run the example if this script is executed directly
if (require.main === module) {
  completeSetlistExample();
}

export { completeSetlistExample };
