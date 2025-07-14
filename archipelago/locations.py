"""
Selaco locations for Archipelago - Based on actual game levels
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

# Level Group 1 - Pathfinder Hospital (SE_01A, SE_01B, SE_01C)
hospital_locations: Dict[str, LocationData] = {
    # SE_01A "Pathfinder Hospital"
    "Pathfinder Hospital - Start Weapons Cache": LocationData(BASE_ID + 1000, "Pathfinder Hospital"),
    "Pathfinder Hospital - Emergency Room Keycard": LocationData(BASE_ID + 1001, "Pathfinder Hospital"),
    "Pathfinder Hospital - Surgery Ward Clear": LocationData(BASE_ID + 1002, "Pathfinder Hospital"),
    "Pathfinder Hospital - Patient Records Terminal": LocationData(BASE_ID + 1003, "Pathfinder Hospital"),
    "Pathfinder Hospital - Medical Supply Room": LocationData(BASE_ID + 1004, "Pathfinder Hospital"),
    "Pathfinder Hospital - Secret Medical Cache": LocationData(BASE_ID + 1005, "Pathfinder Hospital"),
    "Pathfinder Hospital - Cafeteria Search": LocationData(BASE_ID + 1006, "Pathfinder Hospital"),
    "Pathfinder Hospital - First Security Checkpoint": LocationData(BASE_ID + 1007, "Pathfinder Hospital"),
    
    # SE_01B "Pathfinder Hospital (Blue)" - Safe Room Area
    "Pathfinder Blue Wing - Safe Room Upgrade": LocationData(BASE_ID + 1020, "Pathfinder Blue Wing"),
    "Pathfinder Blue Wing - Equipment Cache": LocationData(BASE_ID + 1021, "Pathfinder Blue Wing"),
    "Pathfinder Blue Wing - First Aid Station": LocationData(BASE_ID + 1022, "Pathfinder Blue Wing"),
    "Pathfinder Blue Wing - Security Office": LocationData(BASE_ID + 1023, "Pathfinder Blue Wing"),
    
    # SE_01C "Pathfinder Labs"
    "Pathfinder Labs - Research Terminal": LocationData(BASE_ID + 1040, "Pathfinder Labs"),
    "Pathfinder Labs - Sample Storage": LocationData(BASE_ID + 1041, "Pathfinder Labs"),
    "Pathfinder Labs - Lab Equipment Upgrade": LocationData(BASE_ID + 1042, "Pathfinder Labs"),
    "Pathfinder Labs - Chemical Storage": LocationData(BASE_ID + 1043, "Pathfinder Labs"),
    "Pathfinder Labs - Director's Office": LocationData(BASE_ID + 1044, "Pathfinder Labs"),
}

# Level Group 2 - Utility Area (SE_02A, SE_02Z, SE_02B, SE_02C)
utility_locations: Dict[str, LocationData] = {
    # SE_02A "Utility Area"
    "Utility Area - Power Junction": LocationData(BASE_ID + 2000, "Utility Area"),
    "Utility Area - Maintenance Tunnel": LocationData(BASE_ID + 2001, "Utility Area"),
    "Utility Area - Tool Storage": LocationData(BASE_ID + 2002, "Utility Area"),
    "Utility Area - Generator Room": LocationData(BASE_ID + 2003, "Utility Area"),
    
    # SE_02Z "Pathfinder Hospital (Orange)" - Safe Room
    "Pathfinder Orange Wing - Emergency Cache": LocationData(BASE_ID + 2020, "Pathfinder Orange Wing"),
    "Pathfinder Orange Wing - Medical Station": LocationData(BASE_ID + 2021, "Pathfinder Orange Wing"),
    
    # SE_02B "Utility Area" (Second part)
    "Utility Area B - Pipe Access": LocationData(BASE_ID + 2040, "Utility Area B"),
    "Utility Area B - Emergency Supplies": LocationData(BASE_ID + 2041, "Utility Area B"),
    "Utility Area B - Service Elevator": LocationData(BASE_ID + 2042, "Utility Area B"),
    
    # SE_02C "Water Treatment" - Safe Room
    "Water Treatment - Filtration Control": LocationData(BASE_ID + 2060, "Water Treatment"),
    "Water Treatment - Chemical Storage": LocationData(BASE_ID + 2061, "Water Treatment"),
    "Water Treatment - Engineer's Office": LocationData(BASE_ID + 2062, "Water Treatment"),
}

# Level Group 3 - Streets Area (SE_03A, SE_03A1, SE_03B, SE_03B1, SE_03B2, SE_03C)
streets_locations: Dict[str, LocationData] = {
    # SE_03A "Parking Garage" - Safe Room
    "Parking Garage - Vehicle Search": LocationData(BASE_ID + 3000, "Parking Garage"),
    "Parking Garage - Security Booth": LocationData(BASE_ID + 3001, "Parking Garage"),
    "Parking Garage - Maintenance Area": LocationData(BASE_ID + 3002, "Parking Garage"),
    
    # SE_03A1 "Parking Garage" (Variant)
    "Parking Garage Alt - Hidden Cache": LocationData(BASE_ID + 3020, "Parking Garage Alt"),
    "Parking Garage Alt - Upper Level": LocationData(BASE_ID + 3021, "Parking Garage Alt"),
    
    # SE_03B "Selaco Streets"
    "Selaco Streets - Street Patrol Clear": LocationData(BASE_ID + 3040, "Selaco Streets"),
    "Selaco Streets - Shop Front Search": LocationData(BASE_ID + 3041, "Selaco Streets"),
    "Selaco Streets - Police Station": LocationData(BASE_ID + 3042, "Selaco Streets"),
    "Selaco Streets - Apartment Complex": LocationData(BASE_ID + 3043, "Selaco Streets"),
    "Selaco Streets - Street Barricade": LocationData(BASE_ID + 3044, "Selaco Streets"),
    
    # SE_03B1 "Selaco Streets" (Safe Room)
    "Selaco Streets Safe - Checkpoint": LocationData(BASE_ID + 3060, "Selaco Streets Safe"),
    "Selaco Streets Safe - Supply Drop": LocationData(BASE_ID + 3061, "Selaco Streets Safe"),
    
    # SE_03B2 "Sal's Bar"
    "Sal's Bar - Bar Counter": LocationData(BASE_ID + 3080, "Sal's Bar"),
    "Sal's Bar - Back Room": LocationData(BASE_ID + 3081, "Sal's Bar"),
    "Sal's Bar - Basement Storage": LocationData(BASE_ID + 3082, "Sal's Bar"),
    "Sal's Bar - Owner's Safe": LocationData(BASE_ID + 3083, "Sal's Bar"),
    
    # SE_03C "Sal's Lair"
    "Sal's Lair - Hidden Weapons": LocationData(BASE_ID + 3100, "Sal's Lair"),
    "Sal's Lair - Secret Passage": LocationData(BASE_ID + 3101, "Sal's Lair"),
    "Sal's Lair - Boss Encounter": LocationData(BASE_ID + 3102, "Sal's Lair"),
}

# Level Group 4 - Office Complex (SE_04A, SE_04B, SE_04C)
office_locations: Dict[str, LocationData] = {
    # SE_04A "Office Complex"
    "Office Complex - Reception Desk": LocationData(BASE_ID + 4000, "Office Complex"),
    "Office Complex - Executive Office": LocationData(BASE_ID + 4001, "Office Complex"),
    "Office Complex - Server Room": LocationData(BASE_ID + 4002, "Office Complex"),
    "Office Complex - Conference Room": LocationData(BASE_ID + 4003, "Office Complex"),
    "Office Complex - Security Office": LocationData(BASE_ID + 4004, "Office Complex"),
    "Office Complex - Supply Closet": LocationData(BASE_ID + 4005, "Office Complex"),
    
    # SE_04B "Administration"
    "Administration - Main Terminal": LocationData(BASE_ID + 4020, "Administration"),
    "Administration - Records Vault": LocationData(BASE_ID + 4021, "Administration"),
    "Administration - Manager's Office": LocationData(BASE_ID + 4022, "Administration"),
    "Administration - Staff Lounge": LocationData(BASE_ID + 4023, "Administration"),
    
    # SE_04C "Courtyard" - Safe Room
    "Courtyard - Garden Cache": LocationData(BASE_ID + 4040, "Courtyard"),
    "Courtyard - Fountain Secret": LocationData(BASE_ID + 4041, "Courtyard"),
    "Courtyard - Gazebo Supplies": LocationData(BASE_ID + 4042, "Courtyard"),
}

# Level Group 5 - Exodus Plaza (SE_05A, SE_05B, SE_05C, SE_05D)
plaza_locations: Dict[str, LocationData] = {
    # SE_05A "Exodus Plaza"
    "Exodus Plaza - Main Entrance": LocationData(BASE_ID + 5000, "Exodus Plaza"),
    "Exodus Plaza - Central Kiosk": LocationData(BASE_ID + 5001, "Exodus Plaza"),
    "Exodus Plaza - Information Desk": LocationData(BASE_ID + 5002, "Exodus Plaza"),
    "Exodus Plaza - Security Station": LocationData(BASE_ID + 5003, "Exodus Plaza"),
    
    # SE_05B "Exodus Plaza - North"
    "Exodus North - Electronics Store": LocationData(BASE_ID + 5020, "Exodus Plaza North"),
    "Exodus North - Clothing Store": LocationData(BASE_ID + 5021, "Exodus Plaza North"),
    "Exodus North - Food Court": LocationData(BASE_ID + 5022, "Exodus Plaza North"),
    "Exodus North - Arcade": LocationData(BASE_ID + 5023, "Exodus Plaza North"),
    "Exodus North - Department Store": LocationData(BASE_ID + 5024, "Exodus Plaza North"),
    
    # SE_05C "Exodus Plaza - South"
    "Exodus South - Bookstore": LocationData(BASE_ID + 5040, "Exodus Plaza South"),
    "Exodus South - Pharmacy": LocationData(BASE_ID + 5041, "Exodus Plaza South"),
    "Exodus South - Sports Store": LocationData(BASE_ID + 5042, "Exodus Plaza South"),
    "Exodus South - Music Store": LocationData(BASE_ID + 5043, "Exodus Plaza South"),
    "Exodus South - Jewelry Store": LocationData(BASE_ID + 5044, "Exodus Plaza South"),
    
    # SE_05D "Exodus Plaza - Front Entrance" - Safe Room
    "Exodus Front - Main Entrance": LocationData(BASE_ID + 5060, "Exodus Plaza Entrance"),
    "Exodus Front - Concierge Desk": LocationData(BASE_ID + 5061, "Exodus Plaza Entrance"),
    "Exodus Front - Emergency Station": LocationData(BASE_ID + 5062, "Exodus Plaza Entrance"),
}

# Level Group 6 - Plant Cloning Facility (SE_06A, SE_06A1, SE_06B, SE_06C)
plant_locations: Dict[str, LocationData] = {
    # SE_06A "Plant Cloning Facility - Offices" - Safe Room
    "Plant Facility Offices - Reception": LocationData(BASE_ID + 6000, "Plant Facility Offices"),
    "Plant Facility Offices - Director's Office": LocationData(BASE_ID + 6001, "Plant Facility Offices"),
    "Plant Facility Offices - Conference Room": LocationData(BASE_ID + 6002, "Plant Facility Offices"),
    
    # SE_06A1 "Plant Cloning Facility - Offices" (Elevator area)
    "Plant Facility Elevator - Service Access": LocationData(BASE_ID + 6020, "Plant Facility Elevator"),
    "Plant Facility Elevator - Maintenance Panel": LocationData(BASE_ID + 6021, "Plant Facility Elevator"),
    
    # SE_06B "Plant Cloning Facility - Research Labs"
    "Plant Research Labs - Main Lab": LocationData(BASE_ID + 6040, "Plant Research Labs"),
    "Plant Research Labs - Specimen Storage": LocationData(BASE_ID + 6041, "Plant Research Labs"),
    "Plant Research Labs - Data Terminal": LocationData(BASE_ID + 6042, "Plant Research Labs"),
    "Plant Research Labs - Chemical Lab": LocationData(BASE_ID + 6043, "Plant Research Labs"),
    
    # SE_06C "Plant Cloning Facility - Cloning Plant"
    "Plant Cloning - Growth Chambers": LocationData(BASE_ID + 6060, "Plant Cloning"),
    "Plant Cloning - Control Center": LocationData(BASE_ID + 6061, "Plant Cloning"),
    "Plant Cloning - Nutrient Systems": LocationData(BASE_ID + 6062, "Plant Cloning"),
    "Plant Cloning - Observation Deck": LocationData(BASE_ID + 6063, "Plant Cloning"),
}

# Level Group 7 - Starlight Area (SE_07A1, SE_07A, SE_07B, SE_07C, SE_07D, SE_07E, SE_07Z)
starlight_locations: Dict[str, LocationData] = {
    # SE_07A1 "Starlight Exterior" - Safe Room
    "Starlight Exterior - Entrance Plaza": LocationData(BASE_ID + 7000, "Starlight Exterior"),
    "Starlight Exterior - Guard Post": LocationData(BASE_ID + 7001, "Starlight Exterior"),
    
    # SE_07A "Starlight Lobby" - Safe Room
    "Starlight Lobby - Reception Desk": LocationData(BASE_ID + 7020, "Starlight Lobby"),
    "Starlight Lobby - Information Kiosk": LocationData(BASE_ID + 7021, "Starlight Lobby"),
    "Starlight Lobby - Security Office": LocationData(BASE_ID + 7022, "Starlight Lobby"),
    
    # SE_07B "Starlight Green"
    "Starlight Green - Main Area": LocationData(BASE_ID + 7040, "Starlight Green"),
    "Starlight Green - Side Rooms": LocationData(BASE_ID + 7041, "Starlight Green"),
    "Starlight Green - Control Panel": LocationData(BASE_ID + 7042, "Starlight Green"),
    
    # SE_07C "Starlight Red"
    "Starlight Red - Central Chamber": LocationData(BASE_ID + 7060, "Starlight Red"),
    "Starlight Red - Side Access": LocationData(BASE_ID + 7061, "Starlight Red"),
    "Starlight Red - Emergency Exit": LocationData(BASE_ID + 7062, "Starlight Red"),
    
    # SE_07D "Starlight Blue"
    "Starlight Blue - Primary Area": LocationData(BASE_ID + 7080, "Starlight Blue"),
    "Starlight Blue - Support Systems": LocationData(BASE_ID + 7081, "Starlight Blue"),
    "Starlight Blue - Access Terminal": LocationData(BASE_ID + 7082, "Starlight Blue"),
    
    # SE_07E "Starlight Purple"
    "Starlight Purple - Main Section": LocationData(BASE_ID + 7100, "Starlight Purple"),
    "Starlight Purple - Control Room": LocationData(BASE_ID + 7101, "Starlight Purple"),
    "Starlight Purple - Power Junction": LocationData(BASE_ID + 7102, "Starlight Purple"),
    
    # SE_07Z "Starlight Purple" (Final area)
    "Starlight Final - Critical Systems": LocationData(BASE_ID + 7120, "Starlight Final"),
    "Starlight Final - Master Terminal": LocationData(BASE_ID + 7121, "Starlight Final"),
    "Starlight Final - Emergency Cache": LocationData(BASE_ID + 7122, "Starlight Final"),
}

# Level Group 8 - Endgame (SE_08A)
endgame_locations: Dict[str, LocationData] = {
    "Endgame - Final Checkpoint": LocationData(BASE_ID + 8000, "Endgame"),
    "Endgame - Critical Decision": LocationData(BASE_ID + 8001, "Endgame"),
    "Endgame - Emergency Systems": LocationData(BASE_ID + 8002, "Endgame"),
    "Endgame - Final Boss": LocationData(BASE_ID + 8004, "Endgame"),  # Boss victory location
}

# Secret and Special Locations (based on game references)
secret_locations: Dict[str, LocationData] = {
    # Secrets scattered throughout levels
    "Hospital Secret - Hidden Armory": LocationData(BASE_ID + 9000, "Pathfinder Hospital"),
    "Hospital Secret - Basement Cache": LocationData(BASE_ID + 9001, "Pathfinder Hospital"),
    "Utility Secret - Forgotten Stash": LocationData(BASE_ID + 9002, "Utility Area"),
    "Streets Secret - Rooftop Cache": LocationData(BASE_ID + 9003, "Selaco Streets"),
    "Streets Secret - Sewer Access": LocationData(BASE_ID + 9004, "Selaco Streets"),
    "Office Secret - Executive Safe": LocationData(BASE_ID + 9005, "Office Complex"),
    "Plaza Secret - Maintenance Tunnel": LocationData(BASE_ID + 9006, "Exodus Plaza"),
    "Plaza Secret - VIP Area": LocationData(BASE_ID + 9007, "Exodus Plaza"),
    "Plant Secret - Research Vault": LocationData(BASE_ID + 9008, "Plant Facility"),
    "Starlight Secret - Hidden Lab": LocationData(BASE_ID + 9009, "Starlight"),
    
    # Achievement-based locations
    "Achievement - First Blood": LocationData(BASE_ID + 9100, "Pathfinder Hospital"),
    "Achievement - Weapon Master": LocationData(BASE_ID + 9101, "Selaco Station"),
    "Achievement - Secret Hunter": LocationData(BASE_ID + 9102, "Selaco Station"),
    "Achievement - Survivor": LocationData(BASE_ID + 9103, "Selaco Station"),
    "Achievement - Completionist": LocationData(BASE_ID + 9104, "Selaco Station"),
}

# Weapon Station and Upgrade Locations (based on Gwyn stations)
upgrade_locations: Dict[str, LocationData] = {
    "Gwyn Station - Hospital": LocationData(BASE_ID + 9200, "Pathfinder Hospital"),
    "Gwyn Station - Utility": LocationData(BASE_ID + 9201, "Utility Area"),
    "Gwyn Station - Streets": LocationData(BASE_ID + 9202, "Selaco Streets"),
    "Gwyn Station - Office": LocationData(BASE_ID + 9203, "Office Complex"),
    "Gwyn Station - Plaza": LocationData(BASE_ID + 9204, "Exodus Plaza"),
    "Gwyn Station - Plant Facility": LocationData(BASE_ID + 9205, "Plant Facility"),
    "Gwyn Station - Starlight": LocationData(BASE_ID + 9206, "Starlight"),
    
    "Weapon Station - Blue Wing": LocationData(BASE_ID + 9210, "Pathfinder Blue Wing"),
    "Weapon Station - Water Treatment": LocationData(BASE_ID + 9211, "Water Treatment"),
    "Weapon Station - Courtyard": LocationData(BASE_ID + 9212, "Courtyard"),
    "Weapon Station - Plaza Entrance": LocationData(BASE_ID + 9213, "Exodus Plaza Entrance"),
}

# Combine all location tables
location_table: Dict[str, LocationData] = {
    **hospital_locations,
    **utility_locations,
    **streets_locations,
    **office_locations,
    **plaza_locations,
    **plant_locations,
    **starlight_locations,
    **endgame_locations,
    **secret_locations,
    **upgrade_locations,
}