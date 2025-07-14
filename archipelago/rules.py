"""
Selaco rules for Archipelago
"""
from typing import TYPE_CHECKING
from BaseClasses import CollectionState
from worlds.generic.Rules import add_rule, set_rule

if TYPE_CHECKING:
    from . import SelacoPatchWorld


def _has_weapon(state: CollectionState, player: int) -> bool:
    """Check if player has any weapon"""
    weapons = [
        "G19 Handgun", "UC-11 Exon SMG", "Riot Shotgun", 
        "S-8 Marksman Rifle", "Roaring Cricket", "Grenade Launcher",
        "Pulse Cannon", "Railgun", "Plasma Rifle"
    ]
    return any(state.has(weapon, player) for weapon in weapons)


def _has_keycard_access(state: CollectionState, player: int, level: str) -> bool:
    """Check if player has appropriate keycard access for a level"""
    if level == "basic":
        return state.has_any(["Red Keycard", "Blue Keycard", "Yellow Keycard", "Green Keycard"], player)
    elif level == "security":
        return state.has("Security Access Card", player) or state.has_any(["Red Keycard", "Blue Keycard"], player)
    elif level == "medical":
        return state.has("Medical Access Card", player) or state.has("Blue Keycard", player)
    elif level == "science":
        return state.has("Science Access Card", player) or state.has("Yellow Keycard", player)
    elif level == "engineering":
        return state.has("Engineering Access Card", player) or state.has("Green Keycard", player)
    elif level == "command":
        return (state.has("Security Access Card", player) and 
                state.has("Engineering Access Card", player) and
                state.has("Red Keycard", player))
    return False


def _has_basic_equipment(state: CollectionState, player: int) -> bool:
    """Check if player has basic survival equipment"""
    return (state.has("Flashlight", player) and 
            _has_weapon(state, player))


def _has_exploration_gear(state: CollectionState, player: int) -> bool:
    """Check if player has gear for exploration"""
    return (state.has("Gravity Manipulator", player) and
            state.has("Flashlight", player) and
            state.has_any(["Thermal Goggles", "Motion Sensor", "Detector"], player))


def _can_handle_combat(state: CollectionState, player: int, difficulty: str = "normal") -> bool:
    """Check if player can handle combat encounters"""
    has_weapon = _has_weapon(state, player)
    
    if difficulty == "easy":
        return has_weapon
    elif difficulty == "normal":
        return (has_weapon and 
                state.has_any(["Health Kit", "Medical Injector", "First Aid Supplies"], player))
    elif difficulty == "hard":
        return (has_weapon and 
                state.has_any(["Health Kit", "Medical Injector"], player) and
                state.has_any(["Armor Vest", "Shield Generator"], player) and
                state.has_any(["Frag Grenade", "Flash Grenade", "Remote Mine"], player))
    return False


def _has_environmental_protection(state: CollectionState, player: int) -> bool:
    """Check if player has protection for hazardous environments"""
    return (state.has("Environmental Suit", player) and
            state.has_any(["Oxygen Tank", "Radiation Shield"], player))


def set_rules(world: "SelacoPatchWorld") -> None:
    """Set all the rules for Selaco locations"""
    player = world.player
    multiworld = world.multiworld
    
    # Helper function to get location
    def get_location(name: str):
        return multiworld.get_location(name, player)
    
    # Chapter 1 - Hospital (Starting area, minimal requirements)
    # Basic progression locations require flashlight and weapon
    for location in [
        "Chapter 1 - Emergency Room Keycard",
        "Chapter 1 - Surgery Ward Clear", 
        "Chapter 1 - Patient Records Terminal",
        "Chapter 1 - Morgue Investigation"
    ]:
        add_rule(get_location(location), 
                lambda state: _has_basic_equipment(state, player))
    
    # Advanced Chapter 1 locations require medical access
    for location in [
        "Chapter 1 - Security Office Raid",
        "Chapter 1 - Hospital Director's Office",
        "Chapter 1 - Emergency Exit Unlocked"
    ]:
        add_rule(get_location(location), 
                lambda state: (_has_basic_equipment(state, player) and
                             _has_keycard_access(state, player, "medical")))
    
    # Chapter 1 secrets require exploration gear
    chapter1_secrets = [
        "Chapter 1 - Hidden Medical Cache",
        "Chapter 1 - Doctor's Hidden Safe",
        "Chapter 1 - Janitor's Closet Secret",
        "Chapter 1 - Roof Ventilation Secret"
    ]
    for location in chapter1_secrets:
        add_rule(get_location(location),
                lambda state: _has_exploration_gear(state, player))
    
    # Chapter 2 - Security (Requires security access and combat capability)
    add_rule(get_location("Chapter 2 - Security Checkpoint"),
            lambda state: (_has_basic_equipment(state, player) and
                          _has_keycard_access(state, player, "security")))
    
    # Security area combat locations
    for location in [
        "Chapter 2 - Armory Access",
        "Chapter 2 - Guard Station Override",
        "Chapter 2 - Security Chief's Office",
        "Chapter 2 - Control Room Takeover"
    ]:
        add_rule(get_location(location),
                lambda state: (_can_handle_combat(state, player, "normal") and
                             _has_keycard_access(state, player, "security")))
    
    # High-security locations require advanced access
    for location in [
        "Chapter 2 - Evidence Locker Raid",
        "Chapter 2 - Surveillance Hub",
        "Chapter 2 - Security Breach Exit"
    ]:
        add_rule(get_location(location),
                lambda state: (_can_handle_combat(state, player, "hard") and
                             _has_keycard_access(state, player, "security") and
                             state.has("Security Access Card", player)))
    
    # Chapter 3 - Research Labs (Requires science access and environmental protection)
    add_rule(get_location("Chapter 3 - Lab Entry Point"),
            lambda state: (_has_basic_equipment(state, player) and
                          _has_keycard_access(state, player, "science")))
    
    # Research locations with hazards
    for location in [
        "Chapter 3 - Chemical Storage",
        "Chapter 3 - Specimen Containment",
        "Chapter 3 - Clean Room Breach"
    ]:
        add_rule(get_location(location),
                lambda state: (_has_environmental_protection(state, player) and
                             _has_keycard_access(state, player, "science")))
    
    # Advanced research locations
    for location in [
        "Chapter 3 - Prototype Weapon Lab",
        "Chapter 3 - Data Core Recovery",
        "Chapter 3 - Research Director's Lab"
    ]:
        add_rule(get_location(location),
                lambda state: (_can_handle_combat(state, player, "hard") and
                             _has_environmental_protection(state, player) and
                             state.has("Science Access Card", player)))
    
    # Chapter 4 - Engineering (Requires engineering access and tools)
    add_rule(get_location("Chapter 4 - Engineering Entry"),
            lambda state: (_has_basic_equipment(state, player) and
                          _has_keycard_access(state, player, "engineering")))
    
    # Engineering locations require technical equipment
    for location in [
        "Chapter 4 - Power Grid Access",
        "Chapter 4 - Reactor Room Clear",
        "Chapter 4 - Chief Engineer's Terminal"
    ]:
        add_rule(get_location(location),
                lambda state: (_can_handle_combat(state, player, "normal") and
                             _has_keycard_access(state, player, "engineering") and
                             state.has_any(["Tool Kit", "Hacking Device"], player)))
    
    # Critical engineering systems
    for location in [
        "Chapter 4 - Generator Core Access",
        "Chapter 4 - Systems Control Room",
        "Chapter 4 - Emergency Shutdown"
    ]:
        add_rule(get_location(location),
                lambda state: (_can_handle_combat(state, player, "hard") and
                             state.has("Engineering Access Card", player) and
                             state.has("Tool Kit", player) and
                             state.has("Power Cell", player)))
    
    # Chapter 5 - Residential (Requires moderate access and social navigation)
    add_rule(get_location("Chapter 5 - Quarters Entry"),
            lambda state: (_has_basic_equipment(state, player) and
                          _has_keycard_access(state, player, "basic")))
    
    # Residential locations are generally accessible but may require keys
    for location in [
        "Chapter 5 - Community Center",
        "Chapter 5 - Recreation Area", 
        "Chapter 5 - Market District"
    ]:
        add_rule(get_location(location),
                lambda state: (_can_handle_combat(state, player, "easy") and
                             _has_keycard_access(state, player, "basic")))
    
    # Administrative areas require higher access
    for location in [
        "Chapter 5 - Housing Administrator",
        "Chapter 5 - Social Services"
    ]:
        add_rule(get_location(location),
                lambda state: (_can_handle_combat(state, player, "normal") and
                             state.has_any(["Security Access Card", "Medical Access Card"], player)))
    
    # Chapter 6 - Command Center (Requires highest level access)
    add_rule(get_location("Chapter 6 - Command Entry"),
            lambda state: (_can_handle_combat(state, player, "hard") and
                          _has_keycard_access(state, player, "command")))
    
    # Command center requires full access and advanced equipment
    for location in [
        "Chapter 6 - Communications Hub",
        "Chapter 6 - Tactical Operations",
        "Chapter 6 - Strategy Room"
    ]:
        add_rule(get_location(location),
                lambda state: (_can_handle_combat(state, player, "hard") and
                             _has_keycard_access(state, player, "command") and
                             state.has("Communication Device", player)))
    
    # Final areas require story progression items
    for location in [
        "Chapter 6 - Computer Core Access",
        "Chapter 6 - Command Bridge",
        "Chapter 6 - Admiral's Office"
    ]:
        add_rule(get_location(location),
                lambda state: (_can_handle_combat(state, player, "hard") and
                             _has_keycard_access(state, player, "command") and
                             state.has("Dawn's Badge", player) and
                             state.has("Emergency Override", player)))
    
    # Final confrontation requires all story items
    add_rule(get_location("Chapter 6 - Final Confrontation"),
            lambda state: (_can_handle_combat(state, player, "hard") and
                         state.has("Station Core Access", player) and
                         state.has("Emergency Shutdown Override", player) and
                         state.has("Evacuation Pod Key", player)))
    
    # Special station-wide locations require advanced exploration
    for location in [
        "Station-wide - Hidden Armory",
        "Station-wide - Secret Laboratory",
        "Station-wide - Central Computer Core"
    ]:
        add_rule(get_location(location),
                lambda state: (_has_exploration_gear(state, player) and
                             state.has_any(["Security Access Card", "Science Access Card", "Engineering Access Card"], player)))
    
    # Victory condition locations
    add_rule(get_location("Station-wide - Station Core Access"),
            lambda state: (_can_handle_combat(state, player, "hard") and
                         state.has("Emergency Override", player) and
                         state.has_group("keycards", player, 4)))  # Need multiple keycards
    
    # Achievement locations have specific requirements
    add_rule(get_location("Achievement - First Weapon Upgrade"),
            lambda state: (state.has("Weapon Upgrade Kit", player) and
                         _has_weapon(state, player)))
    
    add_rule(get_location("Achievement - Collect 10 Keycards"),
            lambda state: state.has_group("keycards", player, 6))  # Need most keycards
    
    add_rule(get_location("Achievement - Use All Weapon Types"),
            lambda state: (state.has("G19 Handgun", player) and
                         state.has("UC-11 Exon SMG", player) and
                         state.has("Riot Shotgun", player) and
                         state.has("S-8 Marksman Rifle", player) and
                         state.has("Roaring Cricket", player)))
    
    # Challenge locations require specific builds/equipment
    add_rule(get_location("Challenge - Survival Mode Wave 10"),
            lambda state: (_can_handle_combat(state, player, "hard") and
                         state.has("Health Kit", player, 3) and
                         state.has("Armor Repair Kit", player, 2)))
    
    add_rule(get_location("Challenge - Shooting Range Gold"),
            lambda state: (state.has_any(["S-8 Marksman Rifle", "Railgun"], player) and
                         state.has("Scope Attachment", player)))
    
    add_rule(get_location("Challenge - Perfect Accuracy"),
            lambda state: (state.has("Accuracy Boost", player) and
                         state.has_any(["Scope Attachment", "Thermal Goggles"], player)))
    
    # Set up item groups for easier rule checking
    multiworld.item_groups[player] = {
        "keycards": {
            "Red Keycard", "Blue Keycard", "Yellow Keycard", "Green Keycard",
            "Security Access Card", "Medical Access Card", "Science Access Card", "Engineering Access Card"
        },
        "weapons": {
            "G19 Handgun", "UC-11 Exon SMG", "Riot Shotgun", "S-8 Marksman Rifle", 
            "Roaring Cricket", "Grenade Launcher", "Pulse Cannon", "Railgun", "Plasma Rifle"
        },
        "health_items": {
            "Health Kit", "Medical Injector", "First Aid Supplies", "Emergency Stimpack"
        },
        "armor_items": {
            "Armor Vest", "Combat Helmet", "Shield Generator", "Armor Repair Kit"
        }
    }