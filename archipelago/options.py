"""
Selaco options for Archipelago - Based on actual game content
"""
from dataclasses import dataclass
from typing import Dict, Any
from Options import (
    Toggle, DefaultOnToggle, Choice, Range, PercentageOption,
    OptionSet, ItemSet, LocationSet, DeathLink, StartInventoryPool
)


class Goal(Choice):
    """What is required to complete the game?
    
    Based on the actual game objective: "Escape"
    Reach the evacuation point and escape from Selaco Station during the crisis.
    """
    display_name = "Goal"
    option_escape_station = 0
    default = 0


class StartingWeapon(Choice):
    """Choose which weapon Dawn starts with.
    
    Based on actual weapon progression from the game.
    """
    display_name = "Starting Weapon"
    option_fists = 0  # Standard start
    option_uc11_smg = 1  # Start with SMG
    option_shotgun = 2  # Start with Shotgun
    default = 0


class StartingDifficulty(Choice):
    """The base difficulty level for enemies.
    
    Based on actual Selaco difficulty levels:
    - Ensign: Easy difficulty for FPS newcomers
    - Lieutenant: Normal difficulty with some FPS experience  
    - Commander: Hard difficulty for experienced players
    - Captain: Very hard with relentless enemies
    - Admiral: Extreme difficulty for the best players
    - Selaco Must Fall: Impossible difficulty (unlocked by completing Chapter 1)
    """
    display_name = "Difficulty Level"
    option_ensign = 0
    option_lieutenant = 1
    option_commander = 2
    option_captain = 3
    option_admiral = 4
    option_selaco_must_fall = 5
    default = 1


class WeaponProgression(Choice):
    """How weapons are distributed through the multiworld.
    
    Vanilla: Weapons appear in their normal locations
    Shuffled: Weapons can appear anywhere in the multiworld
    Progressive: Weapons unlock in order of power/complexity
    """
    display_name = "Weapon Progression"
    option_vanilla = 0
    option_shuffled = 1
    option_progressive = 2
    default = 1


class KeycardShuffle(Choice):
    """How keycards and access items are handled.
    
    Vanilla: Keycards stay in original locations
    Level: Keycards shuffle within their level group
    Global: Keycards can be anywhere in the multiworld
    """
    display_name = "Keycard Shuffle"
    option_vanilla = 0
    option_level = 1
    option_global = 2
    default = 1


class IncludeSecrets(Toggle):
    """Include secret locations in the location pool.
    
    These are hidden areas and caches throughout Selaco Station.
    """
    display_name = "Include Secrets"
    default = True


class IncludeGwynStations(Toggle):
    """Include Gwyn vending machines as locations.
    
    These upgrade stations are found throughout the game and cost credits.
    """
    display_name = "Include Gwyn Stations" 
    default = True


class IncludeWeaponStations(Toggle):
    """Include weapon upgrade stations as locations.
    
    These allow weapon modifications and are typically in safe rooms.
    """
    display_name = "Include Weapon Stations"
    default = True


class SpecialCampaignMode(Toggle):
    """Enable Special Campaign randomization features.
    
    This adds randomizer elements like weapon traits, extra enemies,
    and dynamic encounters inspired by Selaco's Special Campaign mode.
    """
    display_name = "Special Campaign Mode"
    default = False


class RandomizerIntensity(Choice):
    """How much randomization to apply if Special Campaign is enabled.
    
    Based on Selaco's randomizer presets:
    - Minimal: Subtle changes, mostly balanced
    - Default: Random but balanced experience
    - Controlled Chaos: High randomization but fair
    - Overkill: Maximum chaos and unpredictability
    """
    display_name = "Randomizer Intensity"
    option_minimal = 0
    option_default = 1  
    option_controlled_chaos = 2
    option_overkill = 3
    default = 1


class StartingEquipment(OptionSet):
    """Additional equipment Dawn starts with.
    
    Based on actual game equipment and tools.
    """
    display_name = "Starting Equipment"
    valid_keys = {
        "Flashlight", "Gravity Manipulator", "Thermal Goggles", 
        "Motion Sensor", "Tool Kit", "Health Injector",
        "Frag Grenade", "Credits (100)", "Credits (300)"
    }
    default = {"Flashlight"}


class StartingLevelGroup(Range):
    """Which level group to start in.
    
    1: Pathfinder Hospital (default)
    2: Utility Area
    3: Selaco Streets  
    4: Office Complex
    5: Exodus Plaza (Mall)
    6: Plant Cloning Facility
    7: Starlight Area
    """
    display_name = "Starting Level Group"
    range_start = 1
    range_end = 7
    default = 1


class RequiredLevelGroups(Range):
    """How many level groups must be completed before accessing Endgame.
    
    This controls progression length and difficulty.
    """
    display_name = "Required Level Groups"
    range_start = 3
    range_end = 7
    default = 7  # All areas required by default


class WeaponUpgradeRate(PercentageOption):
    """Chance for weapon upgrade items to appear.
    
    Higher values mean more weapon upgrades in the item pool.
    """
    display_name = "Weapon Upgrade Rate"
    default = 25


class AmmoScarcity(PercentageOption):
    """How scarce ammo items are in the pool.
    
    Lower values mean less ammo, higher values mean more ammo.
    """
    display_name = "Ammo Scarcity"
    default = 50


class HealthItemRate(PercentageOption):
    """Frequency of health and medical items.
    
    Affects survival difficulty by controlling healing item availability.
    """
    display_name = "Health Item Rate"
    default = 30


class CreditsMultiplier(Range):
    """Multiplier for credit rewards.
    
    Credits are used at Gwyn stations for upgrades and equipment.
    """
    display_name = "Credits Multiplier"
    range_start = 1
    range_end = 5
    default = 1


class EnemyRandomization(Toggle):
    """Enable enemy placement randomization.
    
    Only available if Special Campaign Mode is enabled.
    Changes enemy types and spawn locations.
    """
    display_name = "Enemy Randomization"
    default = False


class WeaponTraits(Toggle):
    """Enable weapon trait randomization.
    
    Only available if Special Campaign Mode is enabled.
    Adds special properties to weapons like damage modifiers.
    """
    display_name = "Weapon Traits"
    default = False


class ExtraSpawns(Toggle):
    """Add extra enemy spawns throughout levels.
    
    Only available if Special Campaign Mode is enabled.
    Increases combat encounters and difficulty.
    """
    display_name = "Extra Spawns"
    default = False


# Death link integration
class DeathLinkEnabled(DeathLink):
    """Enable Death Link integration.
    
    When you die, other players in your Death Link group also die.
    """
    display_name = "Death Link"


@dataclass
class SelacoPatchOptions:
    """All options for Selaco Archipelago world."""
    goal: Goal
    starting_weapon: StartingWeapon
    starting_difficulty: StartingDifficulty
    weapon_progression: WeaponProgression
    keycard_shuffle: KeycardShuffle
    include_secrets: IncludeSecrets
    include_gwyn_stations: IncludeGwynStations
    include_weapon_stations: IncludeWeaponStations
    special_campaign_mode: SpecialCampaignMode
    randomizer_intensity: RandomizerIntensity
    starting_equipment: StartingEquipment
    starting_level_group: StartingLevelGroup
    required_level_groups: RequiredLevelGroups
    weapon_upgrade_rate: WeaponUpgradeRate
    ammo_scarcity: AmmoScarcity
    health_item_rate: HealthItemRate
    credits_multiplier: CreditsMultiplier
    enemy_randomization: EnemyRandomization
    weapon_traits: WeaponTraits
    extra_spawns: ExtraSpawns
    death_link: DeathLinkEnabled