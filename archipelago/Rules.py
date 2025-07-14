"""
Selaco Rules and Region Definitions

SOURCE: Inferred from map structure and item dependencies in source code
VERIFIED: Basic progression structure from MAPINFO and item requirements
"""

from typing import TYPE_CHECKING, Dict, Set
from BaseClasses import Region, Entrance, Location, CollectionState
from worlds.generic.Rules import add_rule

if TYPE_CHECKING:
    from . import SelAcoWorld


def create_regions(world: "SelAcoWorld") -> None:
    """Create regions based on map structure."""
    
    # CONFIRMED region structure from MAPS/ directory analysis
    # SOURCE: 34 maps organized in chapters SE_01 through SE_08
    
    # Create menu region
    menu = Region("Menu", world.player, world.multiworld)
    world.multiworld.regions.append(menu)
    
    # Create chapter regions based on map analysis
    chapter_regions = {}
    for i in range(1, 9):
        region_name = f"Chapter {i}"
        region = Region(region_name, world.player, world.multiworld)
        world.multiworld.regions.append(region)
        chapter_regions[region_name] = region
        
        # Add locations to regions
        for location_name, location_data in world.location_name_to_id.items():
            if location_data in get_locations_for_region(region_name):
                location = Location(
                    world.player,
                    location_name,
                    world.location_name_to_id[location_name],
                    region
                )
                region.locations.append(location)
    
    # Create entrances between regions
    create_entrances(world, menu, chapter_regions)


def create_entrances(world: "SelAcoWorld", menu: Region, chapter_regions: Dict[str, Region]) -> None:
    """Create entrances between regions with progression requirements."""
    
    # Menu to Chapter 1 - always accessible
    entrance_ch1 = Entrance(world.player, "Start Game", menu)
    entrance_ch1.connect(chapter_regions["Chapter 1"])
    menu.exits.append(entrance_ch1)
    
    # Chapter progression - each chapter requires completion of previous
    # TODO: VERIFY - Exact progression requirements need confirmation
    previous_chapter = chapter_regions["Chapter 1"]
    
    for i in range(2, 9):
        current_chapter = chapter_regions[f"Chapter {i}"]
        entrance_name = f"Chapter {i-1} to Chapter {i}"
        entrance = Entrance(world.player, entrance_name, previous_chapter)
        entrance.connect(current_chapter)
        previous_chapter.exits.append(entrance)
        previous_chapter = current_chapter


def set_rules(world: "SelAcoWorld") -> None:
    """Set access rules for locations and regions."""
    
    # CONFIRMED progression items from source code analysis
    # SOURCE: ACTORS/Items/Pickups.zsc and MiscPickups.zsc
    
    # Keycard progression - inferred from typical FPS structure
    # TODO: VERIFY - Exact keycard requirements need confirmation
    add_rule(world.multiworld.get_location("Yellow Keycard - Chapter 2", world.player),
             lambda state: state.has("Purple Keycard", world.player))
    
    add_rule(world.multiworld.get_location("Blue Keycard - Chapter 3", world.player),
             lambda state: state.has("Yellow Keycard", world.player))
    
    # Security clearance progression
    # SOURCE: ClearanceLevel inventory class shows max 7 levels
    for i in range(2, 8):
        add_rule(world.multiworld.get_location(f"Security Card Level {i} - Chapter {i}", world.player),
                 lambda state, level=i-1: state.has(f"Security Card Level {level}", world.player))
    
    # Equipment access requirements - inferred from typical usage
    # TODO: VERIFY - Exact requirements need confirmation from community
    add_rule(world.multiworld.get_location("Gas Mask - Chemical Area", world.player),
             lambda state: state.has("Security Card Level 3", world.player))
    
    add_rule(world.multiworld.get_location("Demolition Charges - Explosives Area", world.player),
             lambda state: state.has("Security Card Level 4", world.player))
    
    # Weapon progression - inferred from weapon complexity
    # TODO: VERIFY - Community input needed for exact weapon unlock requirements
    weapon_progression = [
        ("Shotgun - Early Game", lambda state: True),  # Early weapon
        ("Assault Rifle - Mid Game", lambda state: state.has("Security Card Level 2", world.player)),
        ("Nailgun - Mid Game", lambda state: state.has("Security Card Level 3", world.player)),
        ("Grenade Launcher - Mid Game", lambda state: state.has("Security Card Level 3", world.player)),
        ("Plasma Rifle - Late Game", lambda state: state.has("Security Card Level 5", world.player)),
        ("DMR - Late Game", lambda state: state.has("Security Card Level 6", world.player)),
        ("Railgun - Late Game", lambda state: state.has("Security Card Level 7", world.player)),
    ]
    
    for weapon_location, requirement in weapon_progression:
        if weapon_location in world.location_name_to_id:
            add_rule(world.multiworld.get_location(weapon_location, world.player), requirement)
    
    # Chapter access rules - linear progression assumed
    # TODO: VERIFY - Actual chapter unlock requirements
    chapter_requirements = {
        "Chapter 2": lambda state: state.has("Purple Keycard", world.player),
        "Chapter 3": lambda state: state.has("Yellow Keycard", world.player),
        "Chapter 4": lambda state: state.has("Blue Keycard", world.player),
        "Chapter 5": lambda state: state.has("Security Card Level 3", world.player),
        "Chapter 6": lambda state: state.has("Security Card Level 4", world.player),
        "Chapter 7": lambda state: state.has("Security Card Level 5", world.player),
        "Chapter 8": lambda state: state.has("Security Card Level 6", world.player),
    }
    
    for chapter, requirement in chapter_requirements.items():
        chapter_region = world.multiworld.get_region(chapter, world.player)
        for location in chapter_region.locations:
            add_rule(location, requirement)


def get_locations_for_region(region_name: str) -> Set[str]:
    """Get location names that belong to a specific region."""
    # Import here to avoid circular import
    from .Locations import get_locations_by_region
    
    region_locations = get_locations_by_region()
    return set(region_locations.get(region_name, []))


# TODO: VERIFY - Victory condition needs confirmation
def set_completion_rules(world: "SelAcoWorld") -> None:
    """Set rules for game completion."""
    # This is a placeholder - actual victory condition needs verification
    # Common FPS victory conditions: reach final level, defeat final boss, collect all items
    
    victory_location = world.multiworld.get_location("Victory", world.player)
    add_rule(victory_location, 
             lambda state: state.has("Security Card Level 7", world.player) and
                          state.has("Railgun", world.player))


# RESEARCH NOTES:
"""
MISSING INFORMATION REQUIRING VERIFICATION:

1. Exact keycard and security clearance requirements
   - SEARCHED: Item usage in source code  
   - FOUND: Basic keycard system and 7-level clearance system
   - NEEDS: Community verification of which areas require which cards

2. Chapter progression requirements
   - SEARCHED: MAPINFO for map connections
   - FOUND: Basic map structure with clusters
   - NEEDS: Exact requirements to access each chapter

3. Weapon unlock conditions
   - SEARCHED: Weapon class definitions
   - FOUND: Weapon types and basic stats
   - NEEDS: Community data on where/how weapons are obtained

4. Victory condition
   - SEARCHED: End game triggers in code
   - FOUND: No clear victory condition in available code
   - NEEDS: Community confirmation of completion requirements

ASSUMPTIONS MADE:
- Linear chapter progression (common in story-driven FPS)
- Security clearance gates later content (typical for facility-based games)
- More powerful weapons require higher clearance (logical progression)

These assumptions MUST be verified before release.
"""