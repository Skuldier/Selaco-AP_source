"""
Selaco Archipelago Multiworld Integration

SOURCE: Game files from Skuldier/Selaco-ipk3 repository
VERIFIED: 2024-01-01 through source code analysis
"""

import typing
from typing import Dict, Any, Set, List
from BaseClasses import ItemClassification, MultiWorld, Region, Location, Item, Tutorial, LocationProgressType
from worlds.AutoWorld import WebWorld, World
from .Items import SelAcoItemData, get_item_names_per_category
from .Locations import SelAcoLocationData, get_location_names_per_category  
from .Rules import create_regions, set_rules
from .Options import SelAcoOptions


class SelAcoWeb(WebWorld):
    theme = "partyTime"
    game = "Selaco"
    
    # TODO: VERIFY - Add official documentation links when available
    tutorials = [
        Tutorial(
            "Multiworld Setup Guide",
            "A guide to setting up Selaco for Archipelago multiworld.",
            "English",
            "setup_en.md",
            "setup/en",
            ["Skuldier"]  # TODO: Add actual contributors
        )
    ]


class SelAcoWorld(World):
    """
    Selaco is a GZDoom-based first-person shooter featuring Dawn, a former UEDF Marine 
    exploring the Selaco facility while fighting hostile forces.
    
    SOURCE: Game description inferred from game files and Steam App ID 1966350
    """
    
    game = "Selaco"
    web = SelAcoWeb()
    options_dataclass = SelAcoOptions
    options: SelAcoOptions
    
    # CONFIRMED from source code analysis
    item_name_to_id = {name: data.code for name, data in SelAcoItemData.items()}
    location_name_to_id = {name: data.code for name, data in SelAcoLocationData.items()}
    
    def __init__(self, multiworld: MultiWorld, player: int):
        super().__init__(multiworld, player)
        
    def create_regions(self) -> None:
        """Create game regions based on map structure."""
        create_regions(self)
        
    def create_items(self) -> None:
        """Create items for the world."""
        # Get total locations to determine how many filler items we need
        total_locations = len(self.multiworld.get_locations(self.player))
        
        # Create progression items (CONFIRMED from source code)
        progression_items = get_item_names_per_category()["progression"]
        for item_name in progression_items:
            self.multiworld.itempool.append(self.create_item(item_name))
            
        # Create useful items (CONFIRMED from source code) 
        useful_items = get_item_names_per_category()["useful"]
        for item_name in useful_items:
            self.multiworld.itempool.append(self.create_item(item_name))
            
        # Fill remainder with filler items
        current_items = len(self.multiworld.itempool)
        filler_needed = total_locations - current_items
        
        if filler_needed > 0:
            filler_items = get_item_names_per_category()["filler"]
            for _ in range(filler_needed):
                filler_item = self.random.choice(filler_items)
                self.multiworld.itempool.append(self.create_item(filler_item))
                
    def create_item(self, name: str) -> Item:
        """Create an item instance."""
        item_data = SelAcoItemData[name]
        return Item(name, item_data.classification, item_data.code, self.player)
        
    def set_rules(self) -> None:
        """Set logic rules for accessing locations."""
        set_rules(self)
        
    def fill_slot_data(self) -> Dict[str, Any]:
        """Generate slot data for the client."""
        return {
            # TODO: VERIFY - Add actual game settings when confirmed
            "death_link": getattr(self.options, "death_link", False),
            # "difficulty": self.options.difficulty.value,
        }
        
    def get_filler_item_name(self) -> str:
        """Get a random filler item."""
        filler_items = get_item_names_per_category()["filler"]
        return self.random.choice(filler_items)


# TODO: VERIFY - Victory condition needs confirmation
def create_victory_location(world: SelAcoWorld) -> None:
    """Create the victory location."""
    # This is a placeholder - actual victory condition needs verification
    victory_location = Location(
        world.player,
        "Victory",  # TODO: VERIFY actual victory condition
        None,  # No location ID for events
        world.multiworld.get_region("Menu", world.player)
    )
    victory_location.place_locked_item(Item("Victory", ItemClassification.progression, None, world.player))
    world.multiworld.get_region("Menu", world.player).locations.append(victory_location)