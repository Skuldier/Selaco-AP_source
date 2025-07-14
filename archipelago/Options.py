"""
Selaco Options for Archipelago

SOURCE: Inferred from game difficulty settings in MAPINFO
VERIFIED: Difficulty levels from game source code
"""

from dataclasses import dataclass
from Options import Choice, Range, Toggle, DeathLink, DefaultOnToggle, Option, PerGameCommonOptions


class DifficultyChoice(Choice):
    """
    Set the game difficulty level.
    
    SOURCE: MAPINFO lines 100-180 show difficulty definitions
    """
    display_name = "Difficulty"
    option_lieutenant = 0    # Normal difficulty
    option_commander = 1     # Hard difficulty  
    option_captain = 2       # Very Hard difficulty
    option_admiral = 3       # Ultra Hard difficulty
    option_selaco_must_fall = 4  # Realism difficulty
    default = 0


class IncludeCollectibles(DefaultOnToggle):
    """
    Include collectible items (Cabinet Cards, Trading Cards) as Archipelago locations.
    
    SOURCE: ACTORS/Items/ shows these as tracked collectibles
    """
    display_name = "Include Collectibles"


class IncludeWeaponUpgrades(DefaultOnToggle):
    """
    Include weapon capacity upgrades as Archipelago locations.
    
    SOURCE: ACTORS/Items/Pickups.zsc shows WeaponCapacityKit system
    """
    display_name = "Include Weapon Upgrades"


class IncludeHealthUpgrades(DefaultOnToggle):
    """
    Include health upgrades as Archipelago locations.
    
    SOURCE: ACTORS/Items/MiscPickups.zsc shows HealthUpgrade system
    """
    display_name = "Include Health Upgrades"


class RequiredSecurityCards(Range):
    """
    Number of security clearance cards required to access final areas.
    
    SOURCE: ClearanceLevel inventory shows maximum of 7 levels
    """
    display_name = "Required Security Cards"
    range_start = 1
    range_end = 7
    default = 7


class StartingWeapons(Range):
    """
    Number of weapons to start with (beyond the default Roaring Cricket).
    
    SOURCE: Weapon list from ACTORS/Weapons/ analysis
    """
    display_name = "Starting Weapons"
    range_start = 0
    range_end = 3
    default = 0


# TODO: VERIFY - These options need community input for validation
class RandomizeWeaponLocations(Toggle):
    """
    Randomize the locations where weapons are found.
    
    NOTE: Needs verification of base weapon locations
    """
    display_name = "Randomize Weapon Locations"


class RandomizeKeycards(Toggle):
    """
    Randomize keycard locations while maintaining progression logic.
    
    NOTE: Needs verification of base keycard locations  
    """
    display_name = "Randomize Keycards"


@dataclass
class SelAcoOptions(PerGameCommonOptions):
    # Core gameplay options
    difficulty: DifficultyChoice
    death_link: DeathLink
    
    # Content inclusion options  
    include_collectibles: IncludeCollectibles
    include_weapon_upgrades: IncludeWeaponUpgrades
    include_health_upgrades: IncludeHealthUpgrades
    
    # Progression options
    required_security_cards: RequiredSecurityCards
    starting_weapons: StartingWeapons
    
    # Randomization options - TODO: VERIFY
    randomize_weapon_locations: RandomizeWeaponLocations
    randomize_keycards: RandomizeKeycards


# RESEARCH NOTES:
"""
CONFIRMED OPTIONS FROM SOURCE CODE:

1. Difficulty levels (VERIFIED)
   - SOURCE: MAPINFO lines 100-180
   - FOUND: 6 difficulty levels with specific names and settings
   - CONFIDENCE: HIGH

2. Security clearance system (VERIFIED)
   - SOURCE: ClearanceLevel inventory class 
   - FOUND: Maximum 7 security levels
   - CONFIDENCE: HIGH

3. Collectible tracking (VERIFIED)
   - SOURCE: Stats system in stats.zs
   - FOUND: Tracking for cabinet cards, trading cards, secrets
   - CONFIDENCE: MEDIUM

MISSING INFORMATION:

1. Default weapon locations
   - SEARCHED: Weapon placement in maps
   - NEEDS: Community verification of weapon spawn locations

2. Keycard gate locations
   - SEARCHED: Keycard usage in level scripts
   - NEEDS: Verification of which doors require which cards

3. Optional vs required content
   - NEEDS: Community input on what constitutes 100% completion

4. Balance considerations
   - NEEDS: Testing to determine appropriate option defaults

PLACEHOLDER OPTIONS:
Some options (RandomizeWeaponLocations, RandomizeKeycards) are placeholders
that need verification of base game behavior before implementation.
"""