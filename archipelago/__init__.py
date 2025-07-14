"""
Selaco Archipelago World
"""
from typing import Dict, List, Set, Any
from BaseClasses import Tutorial, ItemClassification, Region, Item, Location, MultiWorld, CollectionState
from worlds.AutoWorld import World, WebWorld
from .items import item_table, SelacoPatchItem, progression_table, useful_table, filler_table
from .locations import location_table, SelacoPatchLocation
from .options import SelacoPatchOptions
from .rules import set_rules

__version__ = "1.0.0"


class SelacoPatchWeb(WebWorld):
    theme = "stone"
    
    setup_en = Tutorial(
        "Multiworld Setup Guide",
        "A guide to setting up Selaco for Archipelago multiworld.",
        "English",
        "setup_en.md",
        "setup/en",
        ["Selaco Team"]
    )

    tutorials = [setup_en]


class SelacoPatchWorld(World):
    """
    Selaco is a brand new original shooter inspired by classics like F.E.A.R. and DOOM, 
    featuring thrilling action set pieces, destructibility, smart enemies and a fleshed out 
    story taking place within an immersive game world.
    """
    game = "Selaco"
    web = SelacoPatchWeb()
    options_dataclass = SelacoPatchOptions
    options: SelacoPatchOptions
    
    item_name_to_id = {name: data.code for name, data in item_table.items()}
    location_name_to_id = {name: data.code for name, data in location_table.items()}
    
    # Game progression items that are required for advancement
    required_client_version = (0, 4, 4)

    def create_items(self) -> None:
        """Create and place all items in the world"""
        itempool = []
        
        # Add progression items
        for item_name in progression_table:
            if item_name in item_table:
                item = self.create_item(item_name)
                itempool.append(item)
        
        # Add useful items
        for item_name in useful_table:
            if item_name in item_table:
                item = self.create_item(item_name)
                itempool.append(item)
        
        # Fill remaining slots with filler items
        total_locations = len(location_table)
        remaining_slots = total_locations - len(itempool)
        
        for _ in range(remaining_slots):
            filler_item = self.get_filler_item_name()
            item = self.create_item(filler_item)
            itempool.append(item)
        
        self.multiworld.itempool += itempool

    def create_regions(self) -> None:
        """Create all regions and locations"""
        # Create menu region
        menu_region = Region("Menu", self.player, self.multiworld)
        self.multiworld.regions.append(menu_region)
        
        # Create main game region
        selaco_region = Region("Selaco Station", self.player, self.multiworld)
        self.multiworld.regions.append(selaco_region)
        
        # Add all locations to the main region
        for location_name, location_data in location_table.items():
            location = SelacoPatchLocation(
                self.player, location_name, location_data.code, selaco_region
            )
            selaco_region.locations.append(location)
        
        # Connect menu to main region
        menu_region.connect(selaco_region)

    def create_item(self, name: str) -> Item:
        """Create an item with the given name"""
        data = item_table[name]
        return SelacoPatchItem(name, data.classification, data.code, self.player)

    def get_filler_item_name(self) -> str:
        """Get a random filler item"""
        return self.random.choice(list(filler_table.keys()))

    def set_rules(self) -> None:
        """Set the rules for accessing locations"""
        set_rules(self)

    def fill_slot_data(self) -> Dict[str, Any]:
        """Data to send to the client"""
        return {
            "world_seed": self.multiworld.seed,
            "seed_name": self.multiworld.seed_name,
            "player_name": self.multiworld.player_name[self.player],
            "player_id": self.player,
            "client_version": __version__,
        }

    def generate_basic(self) -> None:
        """Called after items and locations are created but before rules"""
        pass

    def generate_output(self, output_directory: str) -> None:
        """Generate any additional output files needed"""
        pass