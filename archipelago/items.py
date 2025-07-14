"""
Selaco items for Archipelago - Based on actual game content
"""
from dataclasses import dataclass
from typing import Dict, Set, Optional
from BaseClasses import Item, ItemClassification


@dataclass
class ItemData:
    code: int
    classification: ItemClassification = ItemClassification.filler
    max_quantity: int = 1


class SelacoPatchItem(Item):
    game: str = "Selaco"


# Base ID for Selaco items - using a unique range
BASE_ID = 845000

# Weapons - Based on actual weapon names from LANGUAGE file
weapon_table: Dict[str, ItemData] = {
    # Primary Weapons (actual names from game)
    "UC-11 Compact SMG": ItemData(BASE_ID + 1, ItemClassification.progression),
    "ESG-24 Shotgun": ItemData(BASE_ID + 2, ItemClassification.progression),
    "UC-36 Assault Rifle": ItemData(BASE_ID + 3, ItemClassification.progression),
    "S-8 Marksman Rifle": ItemData(BASE_ID + 4, ItemClassification.progression),
    "Roaring Cricket": ItemData(BASE_ID + 5, ItemClassification.progression),
    
    # Advanced Weapons
    "24mm HW-Penetrator": ItemData(BASE_ID + 6, ItemClassification.useful),  # Nail Gun
    "MGL-2": ItemData(BASE_ID + 7, ItemClassification.useful),  # Grenade Launcher
    "Grav-VI Plasma Rifle": ItemData(BASE_ID + 8, ItemClassification.useful),
    "Prototype Railgun (v0.65)": ItemData(BASE_ID + 9, ItemClassification.useful),
    
    # Melee/Utility
    "Fists": ItemData(BASE_ID + 10, ItemClassification.progression),
    "Fire Extinguisher": ItemData(BASE_ID + 11, ItemClassification.useful),
}

# Explosives and Grenades (from game files)
explosive_table: Dict[str, ItemData] = {
    "Frag Grenade": ItemData(BASE_ID + 20, ItemClassification.useful, max_quantity=10),
    "Ice Grenade": ItemData(BASE_ID + 21, ItemClassification.useful, max_quantity=5),
    "Landmine": ItemData(BASE_ID + 22, ItemClassification.useful, max_quantity=5),
}

# Equipment and Tools (based on game references)
equipment_table: Dict[str, ItemData] = {
    "Flashlight": ItemData(BASE_ID + 50, ItemClassification.progression),
    "Gravity Manipulator": ItemData(BASE_ID + 51, ItemClassification.progression),
    "Thermal Goggles": ItemData(BASE_ID + 52, ItemClassification.useful),
    "Motion Sensor": ItemData(BASE_ID + 53, ItemClassification.useful),
    "Environmental Suit": ItemData(BASE_ID + 54, ItemClassification.progression),
    "Oxygen Tank": ItemData(BASE_ID + 55, ItemClassification.useful, max_quantity=3),
    "Tool Kit": ItemData(BASE_ID + 56, ItemClassification.useful),
    "Hacking Device": ItemData(BASE_ID + 57, ItemClassification.useful),
}

# Keycards and Access Items (based on actual game areas)
keycard_table: Dict[str, ItemData] = {
    # Basic keycards
    "Red Keycard": ItemData(BASE_ID + 100, ItemClassification.progression),
    "Blue Keycard": ItemData(BASE_ID + 101, ItemClassification.progression),
    "Yellow Keycard": ItemData(BASE_ID + 102, ItemClassification.progression),
    "Green Keycard": ItemData(BASE_ID + 103, ItemClassification.progression),
    
    # Facility access cards
    "Hospital Access Card": ItemData(BASE_ID + 110, ItemClassification.progression),
    "Security Access Card": ItemData(BASE_ID + 111, ItemClassification.progression),
    "Engineering Access Card": ItemData(BASE_ID + 112, ItemClassification.progression),
    "Research Access Card": ItemData(BASE_ID + 113, ItemClassification.progression),
    "Administration Access Card": ItemData(BASE_ID + 114, ItemClassification.progression),
    
    # Special areas (based on actual levels)
    "Starlight Access Card": ItemData(BASE_ID + 120, ItemClassification.progression),
    "Exodus Plaza Key": ItemData(BASE_ID + 121, ItemClassification.progression),
    "Plant Facility Key": ItemData(BASE_ID + 122, ItemClassification.progression),
}

# Weapon Upgrades (based on actual upgrade system)
upgrade_table: Dict[str, ItemData] = {
    # SMG Upgrades (from game files)
    "SMG Damage Upgrade": ItemData(BASE_ID + 200, ItemClassification.useful),
    "SMG Extended Magazine": ItemData(BASE_ID + 201, ItemClassification.useful),
    "SMG Dual Wield": ItemData(BASE_ID + 202, ItemClassification.useful),
    "SMG Controlled Shots": ItemData(BASE_ID + 203, ItemClassification.useful),
    "SMG Shock Dart": ItemData(BASE_ID + 204, ItemClassification.useful),
    
    # Shotgun Upgrades
    "Shotgun Damage Upgrade": ItemData(BASE_ID + 210, ItemClassification.useful),
    "Shotgun Extended Magazine": ItemData(BASE_ID + 211, ItemClassification.useful),
    "Shotgun Choke": ItemData(BASE_ID + 212, ItemClassification.useful),
    
    # Rifle Upgrades
    "Rifle Damage Upgrade": ItemData(BASE_ID + 220, ItemClassification.useful),
    "Rifle Extended Magazine": ItemData(BASE_ID + 221, ItemClassification.useful),
    "Rifle Scope": ItemData(BASE_ID + 222, ItemClassification.useful),
    
    # General Weapon Upgrades
    "Weapon Upgrade Kit": ItemData(BASE_ID + 230, ItemClassification.useful, max_quantity=10),
    "Weapon Parts": ItemData(BASE_ID + 231, ItemClassification.useful, max_quantity=15),
}

# Ammo Types (based on actual ammo system)
ammo_table: Dict[str, ItemData] = {
    # Primary ammo types
    "SMG Ammo": ItemData(BASE_ID + 300, ItemClassification.filler, max_quantity=20),
    "Shotgun Shells": ItemData(BASE_ID + 301, ItemClassification.filler, max_quantity=15),
    "Rifle Ammo": ItemData(BASE_ID + 302, ItemClassification.filler, max_quantity=20),
    "Plasma Charges": ItemData(BASE_ID + 303, ItemClassification.useful, max_quantity=10),
    "Rail Slugs": ItemData(BASE_ID + 304, ItemClassification.useful, max_quantity=8),
    "Nail Gun Ammo": ItemData(BASE_ID + 305, ItemClassification.useful, max_quantity=15),
    "Grenade Rounds": ItemData(BASE_ID + 306, ItemClassification.useful, max_quantity=8),
    
    # Special ammo
    "Magnetic Rounds": ItemData(BASE_ID + 310, ItemClassification.useful, max_quantity=5),
    "Armor Piercing Rounds": ItemData(BASE_ID + 311, ItemClassification.useful, max_quantity=5),
}

# Health and Consumables
consumable_table: Dict[str, ItemData] = {
    # Health items
    "Health Injector": ItemData(BASE_ID + 400, ItemClassification.useful, max_quantity=15),
    "Medical Kit": ItemData(BASE_ID + 401, ItemClassification.useful, max_quantity=10),
    "Emergency Stimpack": ItemData(BASE_ID + 402, ItemClassification.useful, max_quantity=8),
    "Armor Repair Kit": ItemData(BASE_ID + 403, ItemClassification.useful, max_quantity=10),
    
    # Food items (watermelons are apparently important!)
    "Watermelon": ItemData(BASE_ID + 410, ItemClassification.filler, max_quantity=20),
    "Soda Can": ItemData(BASE_ID + 411, ItemClassification.filler, max_quantity=15),
    "Energy Bar": ItemData(BASE_ID + 412, ItemClassification.filler, max_quantity=15),
    
    # Credits and currency
    "Credits (100)": ItemData(BASE_ID + 420, ItemClassification.useful, max_quantity=20),
    "Credits (300)": ItemData(BASE_ID + 421, ItemClassification.useful, max_quantity=10),
    "Credits (600)": ItemData(BASE_ID + 422, ItemClassification.useful, max_quantity=5),
}

# Story and Victory Items (based on actual game objective)
story_table: Dict[str, ItemData] = {
    # The actual objective is "Escape" based on game files
    "Dawn's Security Badge": ItemData(BASE_ID + 500, ItemClassification.progression),
    "Emergency Evacuation Orders": ItemData(BASE_ID + 501, ItemClassification.progression),
    "Station Access Codes": ItemData(BASE_ID + 502, ItemClassification.progression),
    "Elevator Override Key": ItemData(BASE_ID + 503, ItemClassification.progression),
    "Emergency Communication Device": ItemData(BASE_ID + 504, ItemClassification.progression),
    
    # Victory item - the escape
    "Escape Route Access": ItemData(BASE_ID + 510, ItemClassification.progression),
}

# Combine all item tables
item_table: Dict[str, ItemData] = {
    **weapon_table,
    **explosive_table,
    **equipment_table,
    **keycard_table,
    **upgrade_table,
    **ammo_table,
    **consumable_table,
    **story_table,
}

# Define item categories for generation
progression_table = [
    # Essential weapons for combat
    "Fists", "UC-11 Compact SMG", "ESG-24 Shotgun", "UC-36 Assault Rifle",
    
    # Essential equipment
    "Flashlight", "Gravity Manipulator", "Environmental Suit",
    
    # Key progression items
    "Red Keycard", "Blue Keycard", "Yellow Keycard", "Green Keycard",
    "Hospital Access Card", "Security Access Card", "Engineering Access Card",
    "Research Access Card", "Administration Access Card",
    
    # Area access
    "Starlight Access Card", "Exodus Plaza Key", "Plant Facility Key",
    
    # Story progression
    "Dawn's Security Badge", "Emergency Evacuation Orders", "Station Access Codes",
    "Elevator Override Key", "Emergency Communication Device",
    
    # Victory condition
    "Escape Route Access",
]

useful_table = [
    # Advanced weapons
    "S-8 Marksman Rifle", "Roaring Cricket", "24mm HW-Penetrator", 
    "MGL-2", "Grav-VI Plasma Rifle", "Prototype Railgun (v0.65)",
    
    # Equipment and tools
    "Thermal Goggles", "Motion Sensor", "Tool Kit", "Hacking Device",
    
    # Explosives
    "Frag Grenade", "Ice Grenade", "Landmine",
    
    # Weapon upgrades
    "SMG Damage Upgrade", "SMG Dual Wield", "SMG Shock Dart",
    "Shotgun Damage Upgrade", "Rifle Scope", "Weapon Upgrade Kit",
    
    # Health and survival
    "Health Injector", "Medical Kit", "Emergency Stimpack", "Armor Repair Kit",
    
    # Special ammo
    "Plasma Charges", "Rail Slugs", "Grenade Rounds", "Magnetic Rounds",
    
    # Currency
    "Credits (300)", "Credits (600)",
]

filler_table = [
    # Basic ammo
    "SMG Ammo", "Shotgun Shells", "Rifle Ammo", "Nail Gun Ammo",
    
    # Consumables
    "Watermelon", "Soda Can", "Energy Bar", "Oxygen Tank",
    
    # Minor upgrades
    "SMG Extended Magazine", "Shotgun Extended Magazine", "Rifle Extended Magazine",
    "Weapon Parts",
    
    # Basic currency
    "Credits (100)",
    
    # Utility
    "Fire Extinguisher",
]

# Create sets for easier lookup
progression_items: Set[str] = set(progression_table)
useful_items: Set[str] = set(useful_table)
filler_items: Set[str] = set(filler_table)