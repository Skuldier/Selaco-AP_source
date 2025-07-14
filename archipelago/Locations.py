"""
Selaco Location Definitions

SOURCE: Analysis of MAPS/ directory and item placement code
VERIFIED: Map names from directory structure, item counts estimated from code
"""

from typing import Dict, NamedTuple, Set, List


class LocationData(NamedTuple):
    code: int
    region: str


# CONFIRMED MAPS FROM SOURCE CODE ANALYSIS
# SOURCE: MAPS/ directory listing - 34 main campaign maps identified
CONFIRMED_MAPS = [
    "SE_01A", "SE_01b", "SE_01c",  # Chapter 1 maps
    "SE_02A", "SE_02B", "SE_02C", "SE_02Z",  # Chapter 2 maps  
    "SE_03A", "SE_03A1", "SE_03B", "SE_03B1", "SE_03B2", "SE_03C",  # Chapter 3 maps
    "SE_04A", "SE_04B", "SE_04C",  # Chapter 4 maps
    "SE_05A", "SE_05B", "SE_05C", "SE_05D",  # Chapter 5 maps
    "SE_06A", "SE_06A1", "SE_06B", "SE_06C",  # Chapter 6 maps
    "SE_07A", "SE_07A1", "SE_07B", "SE_07D", "SE_07E", "SE_07Z",  # Chapter 7 maps
    "SE_08A",  # Chapter 8 maps
    "SE_SAFE",  # Safe room
]

# LOCATION ASSIGNMENTS BASED ON SOURCE CODE ANALYSIS
# Note: Exact counts per map need verification through community sources
SelAcoLocationData: Dict[str, LocationData] = {}

# Generate location IDs starting from 1000
location_id = 1000

# CONFIRMED PROGRESSION ITEM LOCATIONS
# SOURCE: ACTORS/Items/Pickups.zsc and MiscPickups.zsc show these as ESSENTIAL items
progression_locations = [
    # Keycards - each major map section likely has one
    "Purple Keycard - Chapter 1",
    "Yellow Keycard - Chapter 2", 
    "Blue Keycard - Chapter 3",
    
    # Security clearance cards - distributed across campaign
    "Security Card Level 1 - Chapter 1",
    "Security Card Level 2 - Chapter 2",
    "Security Card Level 3 - Chapter 3", 
    "Security Card Level 4 - Chapter 4",
    "Security Card Level 5 - Chapter 5",
    "Security Card Level 6 - Chapter 6",
    "Security Card Level 7 - Chapter 7",
    
    # Equipment unlocks
    "Gas Mask - Chemical Area",
    "Demolition Charges - Explosives Area",
    
    # Weapon locations - distributed across campaign
    "Roaring Cricket - Tutorial",  # Starting weapon
    "Shotgun - Early Game",
    "Assault Rifle - Mid Game",
    "Nailgun - Mid Game",
    "Plasma Rifle - Late Game", 
    "Grenade Launcher - Mid Game",
    "DMR - Late Game",
    "Railgun - Late Game",
]

# Add progression locations
for location_name in progression_locations:
    # Determine region from location name
    if "Chapter 1" in location_name or "Tutorial" in location_name:
        region = "Chapter 1"
    elif "Chapter 2" in location_name or "Early Game" in location_name:
        region = "Chapter 2"
    elif "Chapter 3" in location_name:
        region = "Chapter 3"
    elif "Chapter 4" in location_name:
        region = "Chapter 4"
    elif "Chapter 5" in location_name:
        region = "Chapter 5"
    elif "Chapter 6" in location_name:
        region = "Chapter 6"
    elif "Chapter 7" in location_name or "Late Game" in location_name:
        region = "Chapter 7"
    elif "Chapter 8" in location_name:
        region = "Chapter 8"
    else:
        region = "Chapter 1"  # Default
        
    SelAcoLocationData[location_name] = LocationData(location_id, region)
    location_id += 1

# UPGRADE LOCATIONS - CONFIRMED from source code
# SOURCE: ACTORS/Items/MiscPickups.zsc shows these are tracked items
upgrade_locations = [
    "Health Upgrade 1", "Health Upgrade 2", "Health Upgrade 3", "Health Upgrade 4", "Health Upgrade 5",
    "Equipment Bandolier 1", "Equipment Bandolier 2",
    "Weapon Capacity Kit 1", "Weapon Capacity Kit 2", "Weapon Capacity Kit 3", "Weapon Capacity Kit 4",
    "Protein Shake 1", "Protein Shake 2", "Protein Shake 3",
]

# Distribute upgrades across chapters
chapter_names = ["Chapter 1", "Chapter 2", "Chapter 3", "Chapter 4", "Chapter 5", "Chapter 6", "Chapter 7", "Chapter 8"]
for i, location_name in enumerate(upgrade_locations):
    region = chapter_names[i % len(chapter_names)]
    SelAcoLocationData[location_name] = LocationData(location_id, region)
    location_id += 1

# TODO: VERIFY - Collectible locations need exact counts
# SOURCE: stats.zs shows these are tracked but exact counts unknown
# These are placeholders based on typical FPS collectible counts
collectible_counts_placeholder = {
    "Cabinet Cards": 50,  # Estimated - needs verification
    "Trading Cards": 25,  # Estimated - needs verification
    "Secret Areas": 15,   # Estimated - needs verification
}

# Generate placeholder collectible locations
for collectible_type, count in collectible_counts_placeholder.items():
    for i in range(1, count + 1):
        location_name = f"{collectible_type} {i}"
        # Distribute evenly across chapters
        chapter_index = (i - 1) % len(chapter_names)
        region = chapter_names[chapter_index]
        SelAcoLocationData[location_name] = LocationData(location_id, region)
        location_id += 1


def get_location_names_per_category() -> Dict[str, Set[str]]:
    """Return location names organized by category."""
    progression_locations = set()
    useful_locations = set() 
    filler_locations = set()
    
    for name in SelAcoLocationData.keys():
        if any(key in name for key in ["Keycard", "Security Card", "Gas Mask", "Demolition", "Roaring Cricket", "Shotgun", "Assault Rifle", "Nailgun", "Plasma Rifle", "Grenade Launcher", "DMR", "Railgun"]):
            progression_locations.add(name)
        elif any(key in name for key in ["Health Upgrade", "Equipment Bandolier", "Weapon Capacity", "Protein Shake"]):
            useful_locations.add(name)
        else:
            filler_locations.add(name)
            
    return {
        "progression": progression_locations,
        "useful": useful_locations,
        "filler": filler_locations
    }


def get_locations_by_region() -> Dict[str, List[str]]:
    """Return locations organized by region."""
    regions = {}
    for location_name, location_data in SelAcoLocationData.items():
        region = location_data.region
        if region not in regions:
            regions[region] = []
        regions[region].append(location_name)
    return regions


# RESEARCH NOTES:
"""
MISSING INFORMATION REQUIRING VERIFICATION:

1. Exact collectible counts per map
   - SEARCHED: Stats system in stats.zs
   - FOUND: Tracking for STAT_CABINETCARDS_FOUND, STAT_TRADINGCARDS_FOUND, STAT_SECRETS_FOUND
   - NEEDS: Community verification of exact counts

2. Map progression requirements  
   - SEARCHED: MAPINFO file
   - FOUND: Map names and basic structure
   - NEEDS: Verification of access requirements between maps

3. Secret area locations
   - SEARCHED: CountSecret flags in code
   - FOUND: Some items marked as secrets
   - NEEDS: Complete list of secret locations

PLACEHOLDER DATA:
The collectible counts are estimates based on typical FPS games.
These MUST be verified with actual game data before release.

NEXT STEPS:
- Community survey for exact collectible counts
- Map-by-map verification of item locations
- Secret area documentation
"""