"""
Selaco locations for Archipelago
"""
from dataclasses import dataclass
from typing import Dict
from BaseClasses import Location


@dataclass
class LocationData:
    code: int
    region: str = "Selaco Station"


class SelacoPatchLocation(Location):
    game: str = "Selaco"


# Base ID for Selaco locations
BASE_ID = 845000

# Chapter 1 - Pathfinder Memorial Hospital
chapter1_locations: Dict[str, LocationData] = {
    # Main progression locations
    "Chapter 1 - Start Medical Bay": LocationData(BASE_ID + 1000),
    "Chapter 1 - Emergency Room Keycard": LocationData(BASE_ID + 1001),
    "Chapter 1 - Surgery Ward Clear": LocationData(BASE_ID + 1002),
    "Chapter 1 - Patient Records Terminal": LocationData(BASE_ID + 1003),
    "Chapter 1 - Morgue Investigation": LocationData(BASE_ID + 1004),
    "Chapter 1 - Security Office Raid": LocationData(BASE_ID + 1005),
    "Chapter 1 - Pharmacy Supplies": LocationData(BASE_ID + 1006),
    "Chapter 1 - Roof Access Breach": LocationData(BASE_ID + 1007),
    "Chapter 1 - Hospital Director's Office": LocationData(BASE_ID + 1008),
    "Chapter 1 - Emergency Exit Unlocked": LocationData(BASE_ID + 1009),
    
    # Secret locations
    "Chapter 1 - Hidden Medical Cache": LocationData(BASE_ID + 1050),
    "Chapter 1 - Maintenance Tunnel Stash": LocationData(BASE_ID + 1051),
    "Chapter 1 - Doctor's Hidden Safe": LocationData(BASE_ID + 1052),
    "Chapter 1 - Broken Vending Machine": LocationData(BASE_ID + 1053),
    "Chapter 1 - Ceiling Tile Cache": LocationData(BASE_ID + 1054),
    "Chapter 1 - Janitor's Closet Secret": LocationData(BASE_ID + 1055),
    "Chapter 1 - Blood Bank Hideout": LocationData(BASE_ID + 1056),
    "Chapter 1 - Generator Room Supplies": LocationData(BASE_ID + 1057),
    "Chapter 1 - Roof Ventilation Secret": LocationData(BASE_ID + 1058),
    "Chapter 1 - Ambulance Bay Stash": LocationData(BASE_ID + 1059),
}

# Chapter 2 - Security Sector  
chapter2_locations: Dict[str, LocationData] = {
    # Main progression
    "Chapter 2 - Security Checkpoint": LocationData(BASE_ID + 2000),
    "Chapter 2 - Armory Access": LocationData(BASE_ID + 2001),
    "Chapter 2 - Guard Station Override": LocationData(BASE_ID + 2002),
    "Chapter 2 - Prisoner Processing": LocationData(BASE_ID + 2003),
    "Chapter 2 - Security Chief's Office": LocationData(BASE_ID + 2004),
    "Chapter 2 - Cell Block Clearance": LocationData(BASE_ID + 2005),
    "Chapter 2 - Evidence Locker Raid": LocationData(BASE_ID + 2006),
    "Chapter 2 - Control Room Takeover": LocationData(BASE_ID + 2007),
    "Chapter 2 - Surveillance Hub": LocationData(BASE_ID + 2008),
    "Chapter 2 - Security Breach Exit": LocationData(BASE_ID + 2009),
    
    # Secrets
    "Chapter 2 - Hidden Weapons Cache": LocationData(BASE_ID + 2050),
    "Chapter 2 - Guard Locker Stash": LocationData(BASE_ID + 2051),
    "Chapter 2 - Interrogation Room Secret": LocationData(BASE_ID + 2052),
    "Chapter 2 - Ventilation Shaft Cache": LocationData(BASE_ID + 2053),
    "Chapter 2 - Contraband Locker": LocationData(BASE_ID + 2054),
    "Chapter 2 - Warden's Safe": LocationData(BASE_ID + 2055),
    "Chapter 2 - Storage Room Supplies": LocationData(BASE_ID + 2056),
    "Chapter 2 - Watch Tower Stash": LocationData(BASE_ID + 2057),
    "Chapter 2 - Backup Generator Secret": LocationData(BASE_ID + 2058),
    "Chapter 2 - Exercise Yard Cache": LocationData(BASE_ID + 2059),
}

# Chapter 3 - Research Labs
chapter3_locations: Dict[str, LocationData] = {
    # Main progression
    "Chapter 3 - Lab Entry Point": LocationData(BASE_ID + 3000),
    "Chapter 3 - Chemical Storage": LocationData(BASE_ID + 3001),
    "Chapter 3 - Specimen Containment": LocationData(BASE_ID + 3002),
    "Chapter 3 - Research Terminal Access": LocationData(BASE_ID + 3003),
    "Chapter 3 - Prototype Weapon Lab": LocationData(BASE_ID + 3004),
    "Chapter 3 - Clean Room Breach": LocationData(BASE_ID + 3005),
    "Chapter 3 - Data Core Recovery": LocationData(BASE_ID + 3006),
    "Chapter 3 - Experiment Control Room": LocationData(BASE_ID + 3007),
    "Chapter 3 - Research Director's Lab": LocationData(BASE_ID + 3008),
    "Chapter 3 - Emergency Quarantine": LocationData(BASE_ID + 3009),
    
    # Secrets
    "Chapter 3 - Hidden Research Notes": LocationData(BASE_ID + 3050),
    "Chapter 3 - Scientist's Personal Stash": LocationData(BASE_ID + 3051),
    "Chapter 3 - Chemical Spill Cache": LocationData(BASE_ID + 3052),
    "Chapter 3 - Prototype Equipment": LocationData(BASE_ID + 3053),
    "Chapter 3 - Observation Deck Secret": LocationData(BASE_ID + 3054),
    "Chapter 3 - Cooling System Cache": LocationData(BASE_ID + 3055),
    "Chapter 3 - Specimen Storage Secret": LocationData(BASE_ID + 3056),
    "Chapter 3 - Ventilation Lab Stash": LocationData(BASE_ID + 3057),
    "Chapter 3 - Emergency Shower Cache": LocationData(BASE_ID + 3058),
    "Chapter 3 - Waste Disposal Secret": LocationData(BASE_ID + 3059),
}

# Chapter 4 - Engineering Deck
chapter4_locations: Dict[str, LocationData] = {
    # Main progression
    "Chapter 4 - Engineering Entry": LocationData(BASE_ID + 4000),
    "Chapter 4 - Power Grid Access": LocationData(BASE_ID + 4001),
    "Chapter 4 - Reactor Room Clear": LocationData(BASE_ID + 4002),
    "Chapter 4 - Maintenance Override": LocationData(BASE_ID + 4003),
    "Chapter 4 - Chief Engineer's Terminal": LocationData(BASE_ID + 4004),
    "Chapter 4 - Coolant System Repair": LocationData(BASE_ID + 4005),
    "Chapter 4 - Tool Shop Raid": LocationData(BASE_ID + 4006),
    "Chapter 4 - Generator Core Access": LocationData(BASE_ID + 4007),
    "Chapter 4 - Systems Control Room": LocationData(BASE_ID + 4008),
    "Chapter 4 - Emergency Shutdown": LocationData(BASE_ID + 4009),
    
    # Secrets
    "Chapter 4 - Tool Cabinet Stash": LocationData(BASE_ID + 4050),
    "Chapter 4 - Engineer's Locker": LocationData(BASE_ID + 4051),
    "Chapter 4 - Pipe Crawlspace Cache": LocationData(BASE_ID + 4052),
    "Chapter 4 - Reactor Maintenance Secret": LocationData(BASE_ID + 4053),
    "Chapter 4 - Workshop Hidden Storage": LocationData(BASE_ID + 4054),
    "Chapter 4 - Electrical Panel Cache": LocationData(BASE_ID + 4055),
    "Chapter 4 - Steam Tunnel Stash": LocationData(BASE_ID + 4056),
    "Chapter 4 - Control Panel Secret": LocationData(BASE_ID + 4057),
    "Chapter 4 - Utility Shaft Cache": LocationData(BASE_ID + 4058),
    "Chapter 4 - Generator Room Secret": LocationData(BASE_ID + 4059),
}

# Chapter 5 - Residential Quarters
chapter5_locations: Dict[str, LocationData] = {
    # Main progression
    "Chapter 5 - Quarters Entry": LocationData(BASE_ID + 5000),
    "Chapter 5 - Apartment Complex A": LocationData(BASE_ID + 5001),
    "Chapter 5 - Community Center": LocationData(BASE_ID + 5002),
    "Chapter 5 - Apartment Complex B": LocationData(BASE_ID + 5003),
    "Chapter 5 - Recreation Area": LocationData(BASE_ID + 5004),
    "Chapter 5 - Housing Administrator": LocationData(BASE_ID + 5005),
    "Chapter 5 - Market District": LocationData(BASE_ID + 5006),
    "Chapter 5 - Apartment Complex C": LocationData(BASE_ID + 5007),
    "Chapter 5 - Social Services": LocationData(BASE_ID + 5008),
    "Chapter 5 - Quarters Evacuation": LocationData(BASE_ID + 5009),
    
    # Secrets
    "Chapter 5 - Apartment Hidden Safe": LocationData(BASE_ID + 5050),
    "Chapter 5 - Resident's Stash": LocationData(BASE_ID + 5051),
    "Chapter 5 - Recreation Secret": LocationData(BASE_ID + 5052),
    "Chapter 5 - Kitchen Cache": LocationData(BASE_ID + 5053),
    "Chapter 5 - Bedroom Hidden Items": LocationData(BASE_ID + 5054),
    "Chapter 5 - Communal Storage": LocationData(BASE_ID + 5055),
    "Chapter 5 - Rooftop Garden Secret": LocationData(BASE_ID + 5056),
    "Chapter 5 - Laundry Room Cache": LocationData(BASE_ID + 5057),
    "Chapter 5 - Mail Room Stash": LocationData(BASE_ID + 5058),
    "Chapter 5 - Basement Storage": LocationData(BASE_ID + 5059),
}

# Chapter 6 - Command Center
chapter6_locations: Dict[str, LocationData] = {
    # Main progression
    "Chapter 6 - Command Entry": LocationData(BASE_ID + 6000),
    "Chapter 6 - Communications Hub": LocationData(BASE_ID + 6001),
    "Chapter 6 - Tactical Operations": LocationData(BASE_ID + 6002),
    "Chapter 6 - Officer's Quarters": LocationData(BASE_ID + 6003),
    "Chapter 6 - Strategy Room": LocationData(BASE_ID + 6004),
    "Chapter 6 - Computer Core Access": LocationData(BASE_ID + 6005),
    "Chapter 6 - Command Bridge": LocationData(BASE_ID + 6006),
    "Chapter 6 - Admiral's Office": LocationData(BASE_ID + 6007),
    "Chapter 6 - Defense Grid Control": LocationData(BASE_ID + 6008),
    "Chapter 6 - Final Confrontation": LocationData(BASE_ID + 6009),
    
    # Secrets
    "Chapter 6 - Commander's Safe": LocationData(BASE_ID + 6050),
    "Chapter 6 - War Room Secret": LocationData(BASE_ID + 6051),
    "Chapter 6 - Intelligence Cache": LocationData(BASE_ID + 6052),
    "Chapter 6 - Officer's Locker": LocationData(BASE_ID + 6053),
    "Chapter 6 - Strategic Plans Vault": LocationData(BASE_ID + 6054),
    "Chapter 6 - Bridge Console Secret": LocationData(BASE_ID + 6055),
    "Chapter 6 - Admiral's Private Stash": LocationData(BASE_ID + 6056),
    "Chapter 6 - Communications Array": LocationData(BASE_ID + 6057),
    "Chapter 6 - Emergency Protocols": LocationData(BASE_ID + 6058),
    "Chapter 6 - Command Bunker Cache": LocationData(BASE_ID + 6059),
}

# Special/Bonus Locations
special_locations: Dict[str, LocationData] = {
    # Cross-chapter secrets
    "Station-wide - Maintenance Master Key": LocationData(BASE_ID + 7000),
    "Station-wide - Security Override": LocationData(BASE_ID + 7001),
    "Station-wide - Emergency Protocols": LocationData(BASE_ID + 7002),
    "Station-wide - Hidden Armory": LocationData(BASE_ID + 7003),
    "Station-wide - Secret Laboratory": LocationData(BASE_ID + 7004),
    "Station-wide - Central Computer Core": LocationData(BASE_ID + 7005),
    "Station-wide - Evacuation Pod Bay": LocationData(BASE_ID + 7006),
    "Station-wide - Captain's Personal Vault": LocationData(BASE_ID + 7007),
    "Station-wide - Emergency Supply Cache": LocationData(BASE_ID + 7008),
    "Station-wide - Station Core Access": LocationData(BASE_ID + 7009),
    
    # Achievement-based locations
    "Achievement - First Weapon Upgrade": LocationData(BASE_ID + 8000),
    "Achievement - Collect 10 Keycards": LocationData(BASE_ID + 8001),
    "Achievement - Defeat 100 Enemies": LocationData(BASE_ID + 8002),
    "Achievement - Find 25 Secrets": LocationData(BASE_ID + 8003),
    "Achievement - Use All Weapon Types": LocationData(BASE_ID + 8004),
    "Achievement - Perfect Stealth Section": LocationData(BASE_ID + 8005),
    "Achievement - Speedrun Chapter": LocationData(BASE_ID + 8006),
    "Achievement - No Damage Boss Fight": LocationData(BASE_ID + 8007),
    "Achievement - Collect All PDA Logs": LocationData(BASE_ID + 8008),
    "Achievement - Master of Arms": LocationData(BASE_ID + 8009),
    
    # Challenge locations
    "Challenge - Survival Mode Wave 10": LocationData(BASE_ID + 9000),
    "Challenge - Shooting Range Gold": LocationData(BASE_ID + 9001),
    "Challenge - Time Trial Complete": LocationData(BASE_ID + 9002),
    "Challenge - Pacifist Run": LocationData(BASE_ID + 9003),
    "Challenge - Explosives Only": LocationData(BASE_ID + 9004),
    "Challenge - No Healing Items": LocationData(BASE_ID + 9005),
    "Challenge - Minimal Equipment": LocationData(BASE_ID + 9006),
    "Challenge - Perfect Accuracy": LocationData(BASE_ID + 9007),
    "Challenge - Environmental Kills": LocationData(BASE_ID + 9008),
    "Challenge - Ultimate Survivor": LocationData(BASE_ID + 9009),
}

# Combine all location tables
location_table: Dict[str, LocationData] = {
    **chapter1_locations,
    **chapter2_locations,
    **chapter3_locations,
    **chapter4_locations,
    **chapter5_locations,
    **chapter6_locations,
    **special_locations,
}

# Define location groups for easier reference
chapter_locations = {
    1: list(chapter1_locations.keys()),
    2: list(chapter2_locations.keys()),
    3: list(chapter3_locations.keys()),
    4: list(chapter4_locations.keys()),
    5: list(chapter5_locations.keys()),
    6: list(chapter6_locations.keys()),
}

secret_locations = [
    # All locations with "Secret" or "Hidden" in the name
    name for name in location_table.keys() 
    if "Secret" in name or "Hidden" in name or "Cache" in name or "Stash" in name
]

progression_locations = [
    # Main progression locations from each chapter
    name for name in location_table.keys()
    if any(chapter in name for chapter in ["Entry", "Access", "Clear", "Override", "Terminal", "Control", "Exit"])
]

achievement_locations = [
    name for name in location_table.keys() if "Achievement" in name
]

challenge_locations = [
    name for name in location_table.keys() if "Challenge" in name
]