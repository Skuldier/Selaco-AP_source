"""
Selaco items for Archipelago
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

# Weapons - Critical progression items
weapon_table: Dict[str, ItemData] = {
    # Primary Weapons
    "UC-11 Exon SMG": ItemData(BASE_ID + 1, ItemClassification.progression),
    "Riot Shotgun": ItemData(BASE_ID + 2, ItemClassification.progression),
    "S-8 Marksman Rifle": ItemData(BASE_ID + 3, ItemClassification.progression),
    "Roaring Cricket": ItemData(BASE_ID + 4, ItemClassification.progression),
    "G19 Handgun": ItemData(BASE_ID + 5, ItemClassification.progression),
    
    # Secondary/Special Weapons
    "Grenade Launcher": ItemData(BASE_ID + 6, ItemClassification.useful),
    "Pulse Cannon": ItemData(BASE_ID + 7, ItemClassification.useful),
    "Railgun": ItemData(BASE_ID + 8, ItemClassification.useful),
    "Plasma Rifle": ItemData(BASE_ID + 9, ItemClassification.useful),
    
    # Equipment
    "Gravity Manipulator": ItemData(BASE_ID + 10, ItemClassification.progression),
    "Thermal Goggles": ItemData(BASE_ID + 11, ItemClassification.useful),
    "Flashlight": ItemData(BASE_ID + 12, ItemClassification.progression),
    "Detector": ItemData(BASE_ID + 13, ItemClassification.useful),
}

# Key Items - Essential for progression
key_item_table: Dict[str, ItemData] = {
    "Red Keycard": ItemData(BASE_ID + 50, ItemClassification.progression),
    "Blue Keycard": ItemData(BASE_ID + 51, ItemClassification.progression),
    "Yellow Keycard": ItemData(BASE_ID + 52, ItemClassification.progression),
    "Green Keycard": ItemData(BASE_ID + 53, ItemClassification.progression),
    "Security Access Card": ItemData(BASE_ID + 54, ItemClassification.progression),
    "Medical Access Card": ItemData(BASE_ID + 55, ItemClassification.progression),
    "Science Access Card": ItemData(BASE_ID + 56, ItemClassification.progression),
    "Engineering Access Card": ItemData(BASE_ID + 57, ItemClassification.progression),
    
    # Story progression items
    "Dawn's Badge": ItemData(BASE_ID + 60, ItemClassification.progression),
    "Station Map": ItemData(BASE_ID + 61, ItemClassification.useful),
    "Communication Device": ItemData(BASE_ID + 62, ItemClassification.progression),
    "Emergency Override": ItemData(BASE_ID + 63, ItemClassification.progression),
}

# Upgrades and Enhancement Items
upgrade_table: Dict[str, ItemData] = {
    # Weapon Upgrades
    "Weapon Upgrade Kit": ItemData(BASE_ID + 100, ItemClassification.useful, max_quantity=10),
    "Extended Magazine": ItemData(BASE_ID + 101, ItemClassification.useful, max_quantity=5),
    "Scope Attachment": ItemData(BASE_ID + 102, ItemClassification.useful, max_quantity=5),
    "Barrel Stabilizer": ItemData(BASE_ID + 103, ItemClassification.useful, max_quantity=5),
    "Suppressor": ItemData(BASE_ID + 104, ItemClassification.useful, max_quantity=5),
    
    # Armor Upgrades
    "Armor Vest": ItemData(BASE_ID + 110, ItemClassification.useful),
    "Combat Helmet": ItemData(BASE_ID + 111, ItemClassification.useful),
    "Tactical Gloves": ItemData(BASE_ID + 112, ItemClassification.useful),
    "Reinforced Boots": ItemData(BASE_ID + 113, ItemClassification.useful),
    "Shield Generator": ItemData(BASE_ID + 114, ItemClassification.useful),
    
    # Stat Upgrades
    "Health Boost": ItemData(BASE_ID + 120, ItemClassification.useful, max_quantity=10),
    "Stamina Boost": ItemData(BASE_ID + 121, ItemClassification.useful, max_quantity=10),
    "Speed Boost": ItemData(BASE_ID + 122, ItemClassification.useful, max_quantity=5),
    "Damage Boost": ItemData(BASE_ID + 123, ItemClassification.useful, max_quantity=5),
    "Accuracy Boost": ItemData(BASE_ID + 124, ItemClassification.useful, max_quantity=5),
}

# Ammo and Consumables
ammo_table: Dict[str, ItemData] = {
    # Ammo Types
    "SMG Ammo": ItemData(BASE_ID + 200, ItemClassification.filler, max_quantity=20),
    "Shotgun Shells": ItemData(BASE_ID + 201, ItemClassification.filler, max_quantity=20),
    "Rifle Ammo": ItemData(BASE_ID + 202, ItemClassification.filler, max_quantity=20),
    "Handgun Ammo": ItemData(BASE_ID + 203, ItemClassification.filler, max_quantity=20),
    "Grenade Rounds": ItemData(BASE_ID + 204, ItemClassification.useful, max_quantity=10),
    "Energy Cells": ItemData(BASE_ID + 205, ItemClassification.useful, max_quantity=15),
    "Plasma Charges": ItemData(BASE_ID + 206, ItemClassification.useful, max_quantity=15),
    "Rail Slugs": ItemData(BASE_ID + 207, ItemClassification.useful, max_quantity=10),
    
    # Explosives
    "Frag Grenade": ItemData(BASE_ID + 210, ItemClassification.useful, max_quantity=10),
    "Flash Grenade": ItemData(BASE_ID + 211, ItemClassification.useful, max_quantity=10),
    "Smoke Grenade": ItemData(BASE_ID + 212, ItemClassification.useful, max_quantity=10),
    "EMP Grenade": ItemData(BASE_ID + 213, ItemClassification.useful, max_quantity=5),
    "Remote Mine": ItemData(BASE_ID + 214, ItemClassification.useful, max_quantity=5),
    
    # Health Items
    "Health Kit": ItemData(BASE_ID + 220, ItemClassification.useful, max_quantity=20),
    "Medical Injector": ItemData(BASE_ID + 221, ItemClassification.useful, max_quantity=15),
    "First Aid Supplies": ItemData(BASE_ID + 222, ItemClassification.filler, max_quantity=25),
    "Emergency Stimpack": ItemData(BASE_ID + 223, ItemClassification.useful, max_quantity=10),
    "Armor Repair Kit": ItemData(BASE_ID + 224, ItemClassification.useful, max_quantity=15),
}

# Utility and Misc Items
utility_table: Dict[str, ItemData] = {
    "Power Cell": ItemData(BASE_ID + 300, ItemClassification.useful, max_quantity=10),
    "Backup Generator": ItemData(BASE_ID + 301, ItemClassification.useful),
    "Security Scanner": ItemData(BASE_ID + 302, ItemClassification.useful),
    "Hacking Device": ItemData(BASE_ID + 303, ItemClassification.useful),
    "Motion Sensor": ItemData(BASE_ID + 304, ItemClassification.useful),
    "Emergency Beacon": ItemData(BASE_ID + 305, ItemClassification.useful),
    "Environmental Suit": ItemData(BASE_ID + 306, ItemClassification.progression),
    "Oxygen Tank": ItemData(BASE_ID + 307, ItemClassification.useful, max_quantity=5),
    "Radiation Shield": ItemData(BASE_ID + 308, ItemClassification.useful),
    "Tool Kit": ItemData(BASE_ID + 309, ItemClassification.useful),
}

# Victory/Goal Items
victory_table: Dict[str, ItemData] = {
    "Station Core Access": ItemData(BASE_ID + 400, ItemClassification.progression),
    "Emergency Shutdown Override": ItemData(BASE_ID + 401, ItemClassification.progression),
    "Evacuation Pod Key": ItemData(BASE_ID + 402, ItemClassification.progression),
}

# Combine all item tables
item_table: Dict[str, ItemData] = {
    **weapon_table,
    **key_item_table,
    **upgrade_table,
    **ammo_table,
    **utility_table,
    **victory_table,
}

# Define item categories for generation
progression_table = [
    # Essential weapons
    "G19 Handgun", "UC-11 Exon SMG", "Riot Shotgun", "S-8 Marksman Rifle",
    "Gravity Manipulator", "Flashlight", "Environmental Suit",
    
    # Key cards and access items
    "Red Keycard", "Blue Keycard", "Yellow Keycard", "Green Keycard",
    "Security Access Card", "Medical Access Card", "Science Access Card", "Engineering Access Card",
    
    # Story items
    "Dawn's Badge", "Communication Device", "Emergency Override",
    
    # Victory items
    "Station Core Access", "Emergency Shutdown Override", "Evacuation Pod Key",
]

useful_table = [
    # Advanced weapons
    "Roaring Cricket", "Grenade Launcher", "Pulse Cannon", "Railgun", "Plasma Rifle",
    
    # Equipment
    "Thermal Goggles", "Detector", "Station Map",
    
    # Upgrades
    "Weapon Upgrade Kit", "Armor Vest", "Combat Helmet", "Shield Generator",
    "Health Boost", "Stamina Boost", "Speed Boost",
    
    # Utility
    "Power Cell", "Security Scanner", "Hacking Device", "Motion Sensor",
    "Emergency Beacon", "Radiation Shield", "Tool Kit",
    
    # Combat items
    "Frag Grenade", "Flash Grenade", "EMP Grenade", "Remote Mine",
    "Health Kit", "Medical Injector", "Emergency Stimpack", "Armor Repair Kit",
    
    # Special ammo
    "Grenade Rounds", "Energy Cells", "Plasma Charges", "Rail Slugs",
]

filler_table = [
    # Basic ammo
    "SMG Ammo", "Shotgun Shells", "Rifle Ammo", "Handgun Ammo",
    
    # Basic consumables
    "First Aid Supplies", "Smoke Grenade", "Oxygen Tank",
    
    # Minor upgrades
    "Extended Magazine", "Scope Attachment", "Barrel Stabilizer", "Suppressor",
    "Tactical Gloves", "Reinforced Boots", "Damage Boost", "Accuracy Boost",
    
    # Utility
    "Backup Generator", "Environmental Suit",
]

# Create sets for easier lookup
progression_items: Set[str] = set(progression_table)
useful_items: Set[str] = set(useful_table)
filler_items: Set[str] = set(filler_table)