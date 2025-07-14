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
        "Fists", "UC-11 Compact SMG", "ESG-24 Shotgun", 
        "UC-36 Assault Rifle", "S-8 Marksman Rifle", "Roaring Cricket", 
        "24mm HW-Penetrator", "MGL-2", "Grav-VI Plasma Rifle", "Prototype Railgun (v0.65)"
    ]
    return any(state.has(weapon, player) for weapon in weapons)


def _has_keycard_access(state: CollectionState, player: int, level: str) -> bool:
    """Check if player has appropriate keycard access for a level"""
    if level == "basic":
        return state.has_any(["Red Keycard", "Blue Keycard", "Yellow Keycard", "Green Keycard"], player)
    elif level == "facility":
        return state.has_any([
            "Hospital Access Card", "Security Access Card", "Engineering Access Card",
            "Research Access Card", "Administration Access Card"
        ], player)
    elif level == "special":
        return state.has_any(["Starlight Access Card", "Exodus Plaza Key", "Plant Facility Key"], player)
    return True


def _has_all_keycards(state: CollectionState, player: int) -> bool:
    """Check if player has collected all keycard items (for keycard collection goal)"""
    all_keycards = [
        "Red Keycard", "Blue Keycard", "Yellow Keycard", "Green Keycard",
        "Hospital Access Card", "Security Access Card", "Engineering Access Card",
        "Research Access Card", "Administration Access Card",
        "Starlight Access Card", "Exodus Plaza Key", "Plant Facility Key"
    ]
    return state.has_all(all_keycards, player)


def _can_complete_level_group(state: CollectionState, player: int, group: int) -> bool:
    """Check if player can complete a specific level group"""
    # Basic requirements for any level group
    if not _has_weapon(state, player) or not state.has("Flashlight", player):
        return False
    
    # Level-specific requirements
    if group >= 2:  # Utility Area and beyond
        if not _has_keycard_access(state, player, "basic"):
            return False
    
    if group >= 4:  # Office Complex and beyond
        if not _has_keycard_access(state, player, "facility"):
            return False
        
    if group >= 6:  # Plant Facility and beyond
        if not state.has("Gravity Manipulator", player):
            return False
            
    if group >= 7:  # Starlight Area
        if not _has_keycard_access(state, player, "special"):
            return False
        if not state.has("Environmental Suit", player):
            return False
    
    return True


def _has_completed_all_areas(state: CollectionState, player: int) -> bool:
    """Check if player has completed all 7 level groups (for complete all areas goal)"""
    return all(_can_complete_level_group(state, player, group) for group in range(1, 8))


def _can_reach_endgame(state: CollectionState, player: int) -> bool:
    """Check if player can reach the endgame area"""
    # Must have story progression items
    story_items = [
        "Dawn's Security Badge", "Emergency Evacuation Orders", "Station Access Codes",
        "Elevator Override Key", "Emergency Communication Device"
    ]
    if not state.has_all(story_items, player):
        return False
    
    # Must be able to complete at least level groups 1-6
    return all(_can_complete_level_group(state, player, group) for group in range(1, 7))


def _can_defeat_final_boss(state: CollectionState, player: int) -> bool:
    """Check if player can defeat the final boss"""
    if not _can_reach_endgame(state, player):
        return False
    
    # Need advanced weapons for boss fight
    advanced_weapons = [
        "S-8 Marksman Rifle", "Roaring Cricket", "24mm HW-Penetrator",
        "MGL-2", "Grav-VI Plasma Rifle", "Prototype Railgun (v0.65)"
    ]
    if not state.has_any(advanced_weapons, player):
        return False
    
    # Need health items for survival
    if not state.has_any(["Health Injector", "Medical Kit", "Emergency Stimpack"], player):
        return False
    
    return True


def set_rules(world: "SelacoPatchWorld") -> None:
    """Set up access rules for all locations and victory conditions"""
    player = world.player
    multiworld = world.multiworld
    
    # Level Group 1 - Pathfinder Hospital (starting area, minimal requirements)
    for location_name in [
        "Pathfinder Hospital - Start Weapons Cache", "Pathfinder Hospital - Emergency Room Keycard",
        "Pathfinder Hospital - Surgery Ward Clear", "Pathfinder Hospital - Patient Records Terminal"
    ]:
        add_rule(multiworld.get_location(location_name, player),
                lambda state: _has_weapon(state, player))
    
    # Level Group 2 - Utility Area (needs basic keycards)
    for location_name in [
        "Utility Area - Power Junction", "Utility Area - Maintenance Tunnel",
        "Water Treatment - Filtration Control", "Water Treatment - Chemical Storage"
    ]:
        add_rule(multiworld.get_location(location_name, player),
                lambda state: _has_weapon(state, player) and _has_keycard_access(state, player, "basic"))
    
    # Level Group 3 - Selaco Streets (outdoor areas, need environmental protection)
    for location_name in [
        "Selaco Streets - Street Patrol Clear", "Selaco Streets - Shop Front Search",
        "Sal's Bar - Bar Counter", "Sal's Lair - Boss Encounter"
    ]:
        add_rule(multiworld.get_location(location_name, player),
                lambda state: _has_weapon(state, player) and state.has("Environmental Suit", player))
    
    # Level Group 4 - Office Complex (needs facility access)
    for location_name in [
        "Office Complex - Reception Desk", "Office Complex - Executive Office",
        "Administration - Main Terminal", "Administration - Records Vault"
    ]:
        add_rule(multiworld.get_location(location_name, player),
                lambda state: _has_weapon(state, player) and _has_keycard_access(state, player, "facility"))
    
    # Level Group 5 - Exodus Plaza (mall area, needs advanced combat capability)
    for location_name in [
        "Exodus Plaza - Main Entrance", "Exodus North - Electronics Store",
        "Exodus South - Bookstore", "Exodus Front - Main Entrance"
    ]:
        add_rule(multiworld.get_location(location_name, player),
                lambda state: _has_weapon(state, player) and _has_keycard_access(state, player, "facility") and
                            state.has_any(["UC-36 Assault Rifle", "S-8 Marksman Rifle", "Roaring Cricket"], player))
    
    # Level Group 6 - Plant Cloning Facility (needs gravity manipulator)
    for location_name in [
        "Plant Facility Offices - Reception", "Plant Research Labs - Main Lab",
        "Plant Cloning - Growth Chambers", "Plant Cloning - Control Center"
    ]:
        add_rule(multiworld.get_location(location_name, player),
                lambda state: _has_weapon(state, player) and state.has("Gravity Manipulator", player) and
                            _has_keycard_access(state, player, "facility"))
    
    # Level Group 7 - Starlight Area (needs special access and advanced equipment)
    for location_name in [
        "Starlight Lobby - Reception Desk", "Starlight Green - Main Area",
        "Starlight Red - Central Chamber", "Starlight Final - Critical Systems"
    ]:
        add_rule(multiworld.get_location(location_name, player),
                lambda state: _has_weapon(state, player) and state.has("Environmental Suit", player) and
                            _has_keycard_access(state, player, "special") and state.has("Gravity Manipulator", player))
    
    # Endgame locations (need story progression)
    for location_name in [
        "Endgame - Final Checkpoint", "Endgame - Critical Decision", "Endgame - Emergency Systems"
    ]:
        add_rule(multiworld.get_location(location_name, player),
                lambda state: _can_reach_endgame(state, player))
    
    # Victory condition rules based on goal
    goal = world.options.goal.value
    
    # Escape Station goal
    add_rule(multiworld.get_location("Endgame - Escape Route", player),
            lambda state: _can_reach_endgame(state, player))
    
    # Defeat Final Boss goal  
    add_rule(multiworld.get_location("Endgame - Final Boss", player),
            lambda state: _can_defeat_final_boss(state, player))
    
    # Victory item rules
    if goal == 0:  # Escape Station
        set_rule(multiworld.get_location("Endgame - Escape Route", player),
                lambda state: _can_reach_endgame(state, player))
    elif goal == 1:  # Defeat Final Boss
        set_rule(multiworld.get_location("Endgame - Final Boss", player),
                lambda state: _can_defeat_final_boss(state, player))
    elif goal == 2:  # Collect All Keycards
        # For keycard collection, victory happens when all keycards are collected
        # This is handled in the world generation logic
        pass
    elif goal == 3:  # Complete All Areas
        # For area completion, victory happens when all areas can be completed
        # This is also handled in world generation logic
        pass
    
    # Secret locations (harder requirements)
    for location_name in [
        "Hospital Secret - Hidden Armory", "Streets Secret - Rooftop Cache",
        "Plaza Secret - VIP Area", "Starlight Secret - Hidden Lab"
    ]:
        add_rule(multiworld.get_location(location_name, player),
                lambda state: _has_weapon(state, player) and state.has("Gravity Manipulator", player) and
                            _has_keycard_access(state, player, "facility"))