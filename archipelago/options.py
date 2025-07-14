"""
Selaco options for Archipelago
"""
from dataclasses import dataclass
from typing import Dict, Any
from Options import (
    Toggle, DefaultOnToggle, Choice, Range, PercentageOption,
    OptionSet, ItemSet, LocationSet, DeathLink, StartInventoryPool
)


class Goal(Choice):
    """What is required to complete the game?
    
    Escape Station: Reach the evacuation pods and escape Selaco Station
    Retake Station: Eliminate all threats and regain control of the station
    Destroy Station: Activate the station's self-destruct sequence
    Save Everyone: Rescue all survivors and evacuate the station
    """
    display_name = "Goal"
    option_escape_station = 0
    option_retake_station = 1
    option_destroy_station = 2
    option_save_everyone = 3
    default = 0


class StartingWeapon(Choice):
    """Which weapon does Dawn start with?
    
    None: Start with no weapon (hardcore mode)
    Handgun: Start with G19 Handgun and some ammo
    SMG: Start with UC-11 Exon SMG and some ammo
    Random: Start with a random weapon
    """
    display_name = "Starting Weapon"
    option_none = 0
    option_handgun = 1
    option_smg = 2
    option_random = 3
    default = 1


class StartingEquipment(OptionSet):
    """What equipment does Dawn start with?"""
    display_name = "Starting Equipment"
    valid_keys = {
        "flashlight", "detector", "communication_device", "medical_injector",
        "armor_vest", "oxygen_tank", "tool_kit", "power_cell"
    }
    default = {"flashlight"}


class DifficultyLevel(Choice):
    """Overall difficulty level of the randomizer
    
    Normal: Balanced difficulty for most players
    Hard: Increased enemy health and damage, fewer resources
    Nightmare: Maximum difficulty with limited resources
    Casual: Reduced difficulty for a more relaxed experience
    """
    display_name = "Difficulty Level"
    option_casual = 0
    option_normal = 1
    option_hard = 2
    option_nightmare = 3
    default = 1


class EnemyRandomization(Choice):
    """How should enemies be randomized?
    
    Vanilla: Enemies appear in their original locations
    Shuffled: Enemy types are shuffled between encounters
    Random: Completely random enemy spawns
    Scaled: Enemies scale with location progression
    """
    display_name = "Enemy Randomization"
    option_vanilla = 0
    option_shuffled = 1
    option_random = 2
    option_scaled = 3
    default = 1


class WeaponProgression(Choice):
    """How are weapons distributed throughout the game?
    
    Early: Most weapons available early in the game
    Balanced: Weapons distributed evenly throughout progression
    Late: Advanced weapons only available late in the game
    Random: Completely random weapon distribution
    """
    display_name = "Weapon Progression"
    option_early = 0
    option_balanced = 1
    option_late = 2
    option_random = 3
    default = 1


class KeycardDistribution(Choice):
    """How are keycards distributed?
    
    Logical: Keycards appear in logical locations for their use
    Shuffled: Keycards are shuffled throughout all locations
    Random: Keycards can appear anywhere, including other worlds
    """
    display_name = "Keycard Distribution"
    option_logical = 0
    option_shuffled = 1
    option_random = 2
    default = 0


class SecretDifficulty(Range):
    """How difficult are secret locations to access?
    
    Higher values require more advanced items and exploration skills.
    """
    display_name = "Secret Difficulty"
    range_start = 1
    range_end = 5
    default = 3


class ItemDensity(PercentageOption):
    """What percentage of potential item locations should have items?
    
    Lower values mean fewer items overall, higher values mean more items.
    """
    display_name = "Item Density"
    default = 75


class HealthItemFrequency(Range):
    """How frequently should health items appear?
    
    1 = Very Rare, 5 = Very Common
    """
    display_name = "Health Item Frequency"
    range_start = 1
    range_end = 5
    default = 3


class AmmoScarcity(Range):
    """How scarce should ammunition be?
    
    1 = Abundant ammo, 5 = Very scarce ammo
    """
    display_name = "Ammo Scarcity"
    range_start = 1
    range_end = 5
    default = 2


class IncludeAchievements(DefaultOnToggle):
    """Include achievement-based locations in the randomizer?
    
    These are optional challenges that provide additional items.
    """
    display_name = "Include Achievements"


class IncludeChallenges(Toggle):
    """Include challenge-based locations in the randomizer?
    
    These are difficult optional challenges for advanced players.
    """
    display_name = "Include Challenges"


class ShuffleChapters(Toggle):
    """Shuffle the order in which chapters must be completed?
    
    This can significantly change the flow of the game.
    """
    display_name = "Shuffle Chapters"


class RandomizeEnemyStats(Toggle):
    """Randomize enemy health, damage, and other stats?
    
    This adds unpredictability to combat encounters.
    """
    display_name = "Randomize Enemy Stats"


class RandomizeWeaponStats(Toggle):
    """Randomize weapon damage, rate of fire, and other stats?
    
    This makes each weapon feel unique in every playthrough.
    """
    display_name = "Randomize Weapon Stats"


class EnvironmentalHazards(Choice):
    """How dangerous should environmental hazards be?
    
    None: No environmental damage
    Normal: Standard hazard damage
    Extreme: High environmental damage
    """
    display_name = "Environmental Hazards"
    option_none = 0
    option_normal = 1
    option_extreme = 2
    default = 1


class StartingHealth(Range):
    """What percentage of maximum health should Dawn start with?"""
    display_name = "Starting Health"
    range_start = 25
    range_end = 100
    default = 100


class ProgressiveKeycards(DefaultOnToggle):
    """Should keycards be progressive?
    
    Progressive keycards unlock increasingly secure areas.
    """
    display_name = "Progressive Keycards"


class ProgressiveWeapons(Toggle):
    """Should weapons be progressive?
    
    Progressive weapons unlock improved versions of the same weapon type.
    """
    display_name = "Progressive Weapons"


class ShuffleMusic(Toggle):
    """Shuffle the background music tracks?
    
    This can create interesting atmospheric combinations.
    """
    display_name = "Shuffle Music"


class FastElevators(DefaultOnToggle):
    """Make elevators move faster?
    
    Reduces time spent waiting for elevators.
    """
    display_name = "Fast Elevators"


class SkipCutscenes(DefaultOnToggle):
    """Automatically skip cutscenes?
    
    Speeds up gameplay for randomizer runs.
    """
    display_name = "Skip Cutscenes"


class RandomizerMode(Choice):
    """What type of randomizer experience?
    
    Standard: Normal item and location randomization
    Chaos: Maximum randomization of all elements
    Race: Optimized for racing and speedrunning
    Exploration: Emphasis on exploration and secrets
    """
    display_name = "Randomizer Mode"
    option_standard = 0
    option_chaos = 1
    option_race = 2
    option_exploration = 3
    default = 0


@dataclass
class SelacoPatchOptions:
    """All options for Selaco Archipelago world generation"""
    
    # Core gameplay options
    goal: Goal
    starting_weapon: StartingWeapon
    starting_equipment: StartingEquipment
    difficulty_level: DifficultyLevel
    
    # Randomization options
    enemy_randomization: EnemyRandomization
    weapon_progression: WeaponProgression
    keycard_distribution: KeycardDistribution
    randomizer_mode: RandomizerMode
    
    # Content inclusion
    include_achievements: IncludeAchievements
    include_challenges: IncludeChallenges
    shuffle_chapters: ShuffleChapters
    
    # Item and resource options
    item_density: ItemDensity
    health_item_frequency: HealthItemFrequency
    ammo_scarcity: AmmoScarcity
    starting_health: StartingHealth
    
    # Progressive options
    progressive_keycards: ProgressiveKeycards
    progressive_weapons: ProgressiveWeapons
    
    # Randomization features
    randomize_enemy_stats: RandomizeEnemyStats
    randomize_weapon_stats: RandomizeWeaponStats
    environmental_hazards: EnvironmentalHazards
    
    # Quality of life
    fast_elevators: FastElevators
    skip_cutscenes: SkipCutscenes
    shuffle_music: ShuffleMusic
    
    # Difficulty modifiers
    secret_difficulty: SecretDifficulty
    
    # Standard archipelago options
    death_link: DeathLink
    start_inventory_pool: StartInventoryPool


# Option groups for easier organization
gameplay_options = {
    "goal", "starting_weapon", "starting_equipment", "difficulty_level",
    "starting_health", "environmental_hazards"
}

randomization_options = {
    "enemy_randomization", "weapon_progression", "keycard_distribution",
    "randomizer_mode", "randomize_enemy_stats", "randomize_weapon_stats"
}

content_options = {
    "include_achievements", "include_challenges", "shuffle_chapters",
    "item_density", "health_item_frequency", "ammo_scarcity"
}

progression_options = {
    "progressive_keycards", "progressive_weapons", "secret_difficulty"
}

quality_of_life_options = {
    "fast_elevators", "skip_cutscenes", "shuffle_music"
}

# Preset configurations
presets = {
    "beginner": {
        "difficulty_level": DifficultyLevel.option_casual,
        "starting_weapon": StartingWeapon.option_smg,
        "health_item_frequency": 5,
        "ammo_scarcity": 1,
        "include_achievements": False,
        "include_challenges": False,
    },
    "standard": {
        "difficulty_level": DifficultyLevel.option_normal,
        "starting_weapon": StartingWeapon.option_handgun,
        "health_item_frequency": 3,
        "ammo_scarcity": 2,
        "include_achievements": True,
        "include_challenges": False,
    },
    "expert": {
        "difficulty_level": DifficultyLevel.option_hard,
        "starting_weapon": StartingWeapon.option_none,
        "health_item_frequency": 2,
        "ammo_scarcity": 4,
        "include_achievements": True,
        "include_challenges": True,
    },
    "chaos": {
        "randomizer_mode": RandomizerMode.option_chaos,
        "enemy_randomization": EnemyRandomization.option_random,
        "weapon_progression": WeaponProgression.option_random,
        "shuffle_chapters": True,
        "randomize_enemy_stats": True,
        "randomize_weapon_stats": True,
    }
}