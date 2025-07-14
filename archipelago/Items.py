"""
Selaco Item Definitions

SOURCE: Analysis of ACTORS/Items/ directory in Selaco source code
VERIFIED: Item classes extracted from *.zsc files
"""

from typing import Dict, NamedTuple, Set
from BaseClasses import ItemClassification


class ItemData(NamedTuple):
    code: int
    classification: ItemClassification
    quantity: int = 1


# CONFIRMED ITEMS FROM SOURCE CODE ANALYSIS
# SOURCE: ACTORS/Items/Pickups.zsc - Card system
SelAcoItemData: Dict[str, ItemData] = {
    # PROGRESSION ITEMS - CONFIRMED from source code
    # SOURCE: ACTORS/Items/Pickups.zsc lines 2-94
    "Purple Keycard": ItemData(1001, ItemClassification.progression),
    "Yellow Keycard": ItemData(1002, ItemClassification.progression), 
    "Blue Keycard": ItemData(1003, ItemClassification.progression),
    
    # SOURCE: ACTORS/Items/MiscPickups.zsc lines 82-156 - Security clearance system
    "Security Card Level 1": ItemData(1010, ItemClassification.progression),
    "Security Card Level 2": ItemData(1011, ItemClassification.progression),
    "Security Card Level 3": ItemData(1012, ItemClassification.progression),
    "Security Card Level 4": ItemData(1013, ItemClassification.progression),
    "Security Card Level 5": ItemData(1014, ItemClassification.progression),
    "Security Card Level 6": ItemData(1015, ItemClassification.progression),
    "Security Card Level 7": ItemData(1016, ItemClassification.progression),
    
    # SOURCE: ACTORS/Items/MiscPickups.zsc lines 560-581, 158-186
    "Gas Mask": ItemData(1020, ItemClassification.progression),
    "Demolition Charges": ItemData(1021, ItemClassification.progression),
    
    # WEAPONS - CONFIRMED from source code
    # SOURCE: ACTORS/Weapons/ directory analysis
    "Roaring Cricket": ItemData(2001, ItemClassification.progression),  # Pistol
    "Shotgun": ItemData(2002, ItemClassification.progression),
    "Assault Rifle": ItemData(2003, ItemClassification.progression),  # UC36
    "Nailgun": ItemData(2004, ItemClassification.progression),  # Penetrator
    "Plasma Rifle": ItemData(2005, ItemClassification.progression),
    "Grenade Launcher": ItemData(2006, ItemClassification.progression),
    "DMR": ItemData(2007, ItemClassification.progression),  # Designated Marksman Rifle
    "Railgun": ItemData(2008, ItemClassification.progression),
    
    # USEFUL UPGRADES - CONFIRMED from source code
    # SOURCE: ACTORS/Items/MiscPickups.zsc lines 51-79
    "Health Upgrade": ItemData(3001, ItemClassification.useful),
    
    # SOURCE: ACTORS/Items/MiscPickups.zsc lines 415-558 - Equipment capacity upgrade
    "Equipment Bandolier": ItemData(3002, ItemClassification.useful),
    
    # SOURCE: ACTORS/Items/Pickups.zsc lines 162-288 - Weapon capacity upgrades
    "Weapon Capacity Kit - Pistol": ItemData(3010, ItemClassification.useful),
    "Weapon Capacity Kit - Shotgun": ItemData(3011, ItemClassification.useful), 
    "Weapon Capacity Kit - Assault Rifle": ItemData(3012, ItemClassification.useful),
    
    # SOURCE: ACTORS/Items/Pickups.zsc lines 129-160 - Protein shake for mega powder
    "Protein Shake": ItemData(3020, ItemClassification.useful),
    
    # COLLECTIBLES - CONFIRMED from source code
    # SOURCE: ACTORS/Items/Pickups.zsc lines 95-128 - Cabinet card system
    "Cabinet Card": ItemData(4001, ItemClassification.filler),
    
    # SOURCE: ACTORS/Items/MiscPickups.zsc lines 2-49 - Trading card system  
    "Trading Card": ItemData(4002, ItemClassification.filler),
    
    # FILLER ITEMS - CONFIRMED from source code
    # SOURCE: ACTORS/Items/Pickups.zsc lines 289-412 - Credit system
    "Credits (Small)": ItemData(5001, ItemClassification.filler),    # 50 credits
    "Credits (Medium)": ItemData(5002, ItemClassification.filler),   # 100 credits
    "Credits (Large)": ItemData(5003, ItemClassification.filler),    # 250 credits
    "Loose Credits": ItemData(5004, ItemClassification.filler),      # 5 credits
}

# TODO: VERIFY - These items were referenced in code but need confirmation
# Mark as placeholders until verified through community sources
UNCONFIRMED_ITEMS = {
    # These appeared in randomizer code but exact implementation unclear
    # "Ammo Pickup": ItemData(6001, ItemClassification.filler),
    # "Health Pickup": ItemData(6002, ItemClassification.filler), 
    # "Armor Pickup": ItemData(6003, ItemClassification.filler),
}


def get_item_names_per_category() -> Dict[str, Set[str]]:
    """Return item names organized by category."""
    progression_items = set()
    useful_items = set()
    filler_items = set()
    
    for name, data in SelAcoItemData.items():
        if data.classification == ItemClassification.progression:
            progression_items.add(name)
        elif data.classification == ItemClassification.useful:
            useful_items.add(name)
        elif data.classification == ItemClassification.filler:
            filler_items.add(name)
            
    return {
        "progression": progression_items,
        "useful": useful_items, 
        "filler": filler_items
    }


# RESEARCH NOTES:
"""
MISSING INFORMATION REQUIRING VERIFICATION:

1. Exact weapon unlock progression
   - SEARCHED: Weapon class definitions in ACTORS/Weapons/
   - FOUND: Weapon names and basic structure
   - NEEDS: Confirmation of which weapons are progression vs optional

2. Ammo and equipment counts
   - SEARCHED: Ammo types in ACTORS/Items/AmmoTypes.zsc
   - NEEDS: Verification of whether ammo pickups should be locations

3. Collectible counts per map
   - SEARCHED: Stats system shows tracking for various collectibles
   - NEEDS: Community data on exact counts per level

NEXT STEPS:
- Verify weapon progression requirements through community sources
- Confirm collectible counts and locations
- Validate progression item requirements
"""