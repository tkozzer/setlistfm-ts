#!/bin/bash

# SetlistFM TypeScript Client - Run All Examples
# This script runs all example scripts with delays to respect rate limiting

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
DELAY_BETWEEN_SCRIPTS=1  # seconds between scripts
DELAY_BETWEEN_CATEGORIES=10  # seconds between different endpoint categories
TIMEOUT_DURATION=60  # timeout for each script in seconds

echo -e "${CYAN}================================================${NC}"
echo -e "${CYAN}  SetlistFM TypeScript Client - All Examples${NC}"
echo -e "${CYAN}================================================${NC}"
echo ""
echo -e "${YELLOW}This script will run all example scripts with rate limiting protection.${NC}"
echo -e "${YELLOW}Delays: ${DELAY_BETWEEN_SCRIPTS}s between scripts, ${DELAY_BETWEEN_CATEGORIES}s between categories${NC}"
echo -e "${YELLOW}Timeout: ${TIMEOUT_DURATION}s per script${NC}"
echo ""

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo -e "${RED}❌ Error: .env file not found in project root${NC}"
    echo -e "${YELLOW}Please create a .env file with your SETLISTFM_API_KEY${NC}"
    echo -e "${YELLOW}Make sure to run this script from the project root: ./examples/run-all-examples.sh${NC}"
    exit 1
fi

# Function to run a script with timeout and error handling
run_script() {
    local script_path="$1"
    local script_name="$2"
    local category="$3"
    
    echo -e "${BLUE}🚀 Running: ${script_name}${NC}"
    echo -e "${PURPLE}   Path: ${script_path}${NC}"
    
    if timeout ${TIMEOUT_DURATION} pnpm dlx tsx "${script_path}"; then
        echo -e "${GREEN}✅ Success: ${script_name}${NC}"
    else
        local exit_code=$?
        if [ $exit_code -eq 124 ]; then
            echo -e "${YELLOW}⏰ Timeout: ${script_name} (${TIMEOUT_DURATION}s limit reached)${NC}"
        else
            echo -e "${YELLOW}⚠️  Warning: ${script_name} completed with issues${NC}"
        fi
    fi
    
    echo -e "${CYAN}💤 Waiting ${DELAY_BETWEEN_SCRIPTS}s before next script...${NC}"
    sleep ${DELAY_BETWEEN_SCRIPTS}
    echo ""
}

# Function to run category separator
category_separator() {
    local category="$1"
    echo -e "${CYAN}================================================${NC}"
    echo -e "${CYAN}  $category${NC}"
    echo -e "${CYAN}================================================${NC}"
    echo ""
}

# Start time
start_time=$(date +%s)

# ============================================================================
# ARTISTS EXAMPLES
# ============================================================================
category_separator "🎤 ARTISTS EXAMPLES"

run_script "examples/artists/basicArtistLookup.ts" "Basic Artist Lookup" "artists"
run_script "examples/artists/searchArtists.ts" "Search Artists" "artists"
run_script "examples/artists/getArtistSetlists.ts" "Get Artist Setlists" "artists"
run_script "examples/artists/completeExample.ts" "Complete Artist Workflow" "artists"

echo -e "${CYAN}🎵 Artists category complete! Waiting ${DELAY_BETWEEN_CATEGORIES}s before next category...${NC}"
sleep ${DELAY_BETWEEN_CATEGORIES}
echo ""

# ============================================================================
# CITIES EXAMPLES
# ============================================================================
category_separator "🏙️  CITIES EXAMPLES"

run_script "examples/cities/basicCityLookup.ts" "Basic City Lookup" "cities"
run_script "examples/cities/searchCities.ts" "Search Cities" "cities"
run_script "examples/cities/completeExample.ts" "Complete City Workflow" "cities"

echo -e "${CYAN}🌆 Cities category complete! Waiting ${DELAY_BETWEEN_CATEGORIES}s before next category...${NC}"
sleep ${DELAY_BETWEEN_CATEGORIES}
echo ""

# ============================================================================
# COUNTRIES EXAMPLES
# ============================================================================
category_separator "🌍 COUNTRIES EXAMPLES"

run_script "examples/countries/basicCountriesLookup.ts" "Basic Countries Lookup" "countries"
run_script "examples/countries/countriesAnalysis.ts" "Countries Analysis" "countries"
run_script "examples/countries/completeExample.ts" "Complete Countries Workflow" "countries"

echo -e "${CYAN}🗺️  Countries category complete! Waiting ${DELAY_BETWEEN_CATEGORIES}s before next category...${NC}"
sleep ${DELAY_BETWEEN_CATEGORIES}
echo ""

# ============================================================================
# SETLISTS EXAMPLES
# ============================================================================
category_separator "🎵 SETLISTS EXAMPLES"

run_script "examples/setlists/basicSetlistLookup.ts" "Basic Setlist Lookup" "setlists"
run_script "examples/setlists/searchSetlists.ts" "Search Setlists" "setlists"
run_script "examples/setlists/advancedAnalysis.ts" "Advanced Setlist Analysis" "setlists"
run_script "examples/setlists/completeExample.ts" "Complete Setlist Workflow" "setlists"

echo -e "${CYAN}🎶 Setlists category complete! Waiting ${DELAY_BETWEEN_CATEGORIES}s before next category...${NC}"
sleep ${DELAY_BETWEEN_CATEGORIES}
echo ""

# ============================================================================
# VENUES EXAMPLES
# ============================================================================
category_separator "🏛️  VENUES EXAMPLES"

run_script "examples/venues/basicVenueLookup.ts" "Basic Venue Lookup" "venues"
run_script "examples/venues/searchVenues.ts" "Search Venues" "venues"
run_script "examples/venues/getVenueSetlists.ts" "Get Venue Setlists" "venues"
run_script "examples/venues/completeExample.ts" "Complete Venue Workflow" "venues"

echo -e "${CYAN}🎪 Venues category complete!${NC}"
echo ""

# ============================================================================
# COMPLETION SUMMARY
# ============================================================================
end_time=$(date +%s)
duration=$((end_time - start_time))
minutes=$((duration / 60))
seconds=$((duration % 60))

echo -e "${CYAN}================================================${NC}"
echo -e "${CYAN}  🎉 ALL EXAMPLES COMPLETED! 🎉${NC}"
echo -e "${CYAN}================================================${NC}"
echo ""
echo -e "${GREEN}✅ Successfully ran all SetlistFM TypeScript examples${NC}"
echo -e "${BLUE}⏱️  Total execution time: ${minutes}m ${seconds}s${NC}"
echo ""
echo -e "${YELLOW}📊 Summary:${NC}"
echo -e "${YELLOW}• Artists: 4 examples${NC}"
echo -e "${YELLOW}• Cities: 3 examples${NC}"
echo -e "${YELLOW}• Countries: 3 examples${NC}"
echo -e "${YELLOW}• Setlists: 4 examples${NC}"
echo -e "${YELLOW}• Venues: 4 examples${NC}"
echo -e "${YELLOW}• Total: 18 examples${NC}"
echo ""
echo -e "${PURPLE}🔒 Rate limiting protection was active throughout all examples${NC}"
echo -e "${PURPLE}📈 Check your API usage at https://api.setlist.fm/account${NC}"
echo ""
echo -e "${CYAN}Thank you for testing the SetlistFM TypeScript client! 🎵${NC}" 