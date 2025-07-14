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
        """Create all items for the world"""
        from .items import item_table, progression_items, useful_items, filler_items
        
        # Get the goal type for conditional item creation
        goal = self.options.goal.value
        
        # Create basic item pool
        pool = []
        
        # Add progression items
        for item_name in progression_items:
            # Skip victory items that don't match the current goal
            if item_name == "Escape Route Access" and goal != 0:
                continue
            elif item_name == "Final Boss Defeated" and goal != 1:
                continue
            elif item_name == "All Keycards Collected" and goal != 2:
                continue
            elif item_name == "All Areas Completed" and goal != 3:
                continue
                
            if item_name in item_table:
                classification = item_table[item_name].classification
                pool.append(self.create_item(item_name, classification))
        
        # Add useful items
        for item_name in useful_items:
            if item_name in item_table:
                classification = item_table[item_name].classification
                max_quantity = item_table[item_name].max_quantity
                
                # Add multiple copies for items that support it
                quantity = min(max_quantity, 3) if max_quantity > 1 else 1
                for _ in range(quantity):
                    pool.append(self.create_item(item_name, classification))
        
        # Calculate remaining locations and fill with filler items
        total_locations = len(self.location_name_to_id)
        
        # For keycard collection goal, we need to ensure all keycards are included
        if goal == 2:  # Collect All Keycards
            all_keycards = [
                "Red Keycard", "Blue Keycard", "Yellow Keycard", "Green Keycard",
                "Hospital Access Card", "Security Access Card", "Engineering Access Card",
                "Research Access Card", "Administration Access Card",
                "Starlight Access Card", "Exodus Plaza Key", "Plant Facility Key"
            ]
            for keycard in all_keycards:
                if keycard not in [item.name for item in pool]:
                    pool.append(self.create_item(keycard, ItemClassification.progression))
        
        # Fill remaining spots with filler items
        while len(pool) < total_locations:
            filler_name = self.random.choice(filler_items)
            if filler_name in item_table:
                classification = item_table[filler_name].classification
                pool.append(self.create_item(filler_name, classification))
        
        # Remove excess items if we have too many
        if len(pool) > total_locations:
            # Remove filler items first
            filler_pool = [item for item in pool if item.classification == ItemClassification.filler]
            excess = len(pool) - total_locations
            for _ in range(min(excess, len(filler_pool))):
                pool.remove(filler_pool.pop())
        
        self.multiworld.itempool += pool


    def set_rules(self) -> None:
        """Set access rules for locations"""
        from .rules import set_rules
        set_rules(self)


    def create_regions(self) -> None:
        """Create all regions and locations"""
        from .locations import location_table
        
        # Create regions based on actual game level groups
        regions = {
            "Menu": Region("Menu", self.player, self.multiworld),
            "Pathfinder Hospital": Region("Pathfinder Hospital", self.player, self.multiworld),
            "Pathfinder Blue Wing": Region("Pathfinder Blue Wing", self.player, self.multiworld),
            "Pathfinder Labs": Region("Pathfinder Labs", self.player, self.multiworld),
            "Pathfinder Orange Wing": Region("Pathfinder Orange Wing", self.player, self.multiworld),
            "Utility Area": Region("Utility Area", self.player, self.multiworld),
            "Utility Area B": Region("Utility Area B", self.player, self.multiworld),
            "Water Treatment": Region("Water Treatment", self.player, self.multiworld),
            "Parking Garage": Region("Parking Garage", self.player, self.multiworld),
            "Parking Garage Alt": Region("Parking Garage Alt", self.player, self.multiworld),
            "Selaco Streets": Region("Selaco Streets", self.player, self.multiworld),
            "Selaco Streets Safe": Region("Selaco Streets Safe", self.player, self.multiworld),
            "Sal's Bar": Region("Sal's Bar", self.player, self.multiworld),
            "Sal's Lair": Region("Sal's Lair", self.player, self.multiworld),
            "Office Complex": Region("Office Complex", self.player, self.multiworld),
            "Administration": Region("Administration", self.player, self.multiworld),
            "Courtyard": Region("Courtyard", self.player, self.multiworld),
            "Exodus Plaza": Region("Exodus Plaza", self.player, self.multiworld),
            "Exodus Plaza North": Region("Exodus Plaza North", self.player, self.multiworld),
            "Exodus Plaza South": Region("Exodus Plaza South", self.player, self.multiworld),
            "Exodus Plaza Entrance": Region("Exodus Plaza Entrance", self.player, self.multiworld),
            "Plant Facility Offices": Region("Plant Facility Offices", self.player, self.multiworld),
            "Plant Facility Elevator": Region("Plant Facility Elevator", self.player, self.multiworld),
            "Plant Research Labs": Region("Plant Research Labs", self.player, self.multiworld),
            "Plant Cloning": Region("Plant Cloning", self.player, self.multiworld),
            "Starlight Exterior": Region("Starlight Exterior", self.player, self.multiworld),
            "Starlight Lobby": Region("Starlight Lobby", self.player, self.multiworld),
            "Starlight Green": Region("Starlight Green", self.player, self.multiworld),
            "Starlight Red": Region("Starlight Red", self.player, self.multiworld),
            "Starlight Blue": Region("Starlight Blue", self.player, self.multiworld),
            "Starlight Purple": Region("Starlight Purple", self.player, self.multiworld),
            "Starlight Final": Region("Starlight Final", self.player, self.multiworld),
            "Endgame": Region("Endgame", self.player, self.multiworld),
            "Selaco Station": Region("Selaco Station", self.player, self.multiworld),  # For general/achievement locations
        }
        
        # Add locations to their appropriate regions
        goal = self.options.goal.value
        
        for location_name, location_data in location_table.items():
            # Skip victory locations that don't match the current goal
            if location_name == "Endgame - Escape Route" and goal != 0:
                continue
            elif location_name == "Endgame - Final Boss" and goal != 1:
                continue
                
            region_name = location_data.region
            if region_name in regions:
                location = SelacoPatchLocation(
                    self.player, location_name, location_data.code, regions[region_name]
                )
                regions[region_name].locations.append(location)
                self.location_name_to_id[location_name] = location_data.code
        
        # Add special victory event locations for goals 2 and 3
        if goal == 2:  # Collect All Keycards
            victory_location = SelacoPatchLocation(
                self.player, "Victory - All Keycards Collected", None, regions["Selaco Station"]
            )
            regions["Selaco Station"].locations.append(victory_location)
            
        elif goal == 3:  # Complete All Areas
            victory_location = SelacoPatchLocation(
                self.player, "Victory - All Areas Completed", None, regions["Selaco Station"]
            )
            regions["Selaco Station"].locations.append(victory_location)
        
        # Connect regions (simplified connection structure)
        # Menu connects to starting area
        regions["Menu"].connect(regions["Pathfinder Hospital"])
        
        # Hospital area connections
        regions["Pathfinder Hospital"].connect(regions["Pathfinder Blue Wing"])
        regions["Pathfinder Hospital"].connect(regions["Pathfinder Labs"])
        regions["Pathfinder Hospital"].connect(regions["Utility Area"])
        
        # Utility area connections
        regions["Utility Area"].connect(regions["Pathfinder Orange Wing"])
        regions["Utility Area"].connect(regions["Utility Area B"])
        regions["Utility Area B"].connect(regions["Water Treatment"])
        regions["Water Treatment"].connect(regions["Parking Garage"])
        
        # Streets area connections
        regions["Parking Garage"].connect(regions["Parking Garage Alt"])
        regions["Parking Garage"].connect(regions["Selaco Streets"])
        regions["Selaco Streets"].connect(regions["Selaco Streets Safe"])
        regions["Selaco Streets"].connect(regions["Sal's Bar"])
        regions["Sal's Bar"].connect(regions["Sal's Lair"])
        
        # Office area connections
        regions["Selaco Streets"].connect(regions["Office Complex"])
        regions["Office Complex"].connect(regions["Administration"])
        regions["Administration"].connect(regions["Courtyard"])
        
        # Plaza area connections
        regions["Courtyard"].connect(regions["Exodus Plaza"])
        regions["Exodus Plaza"].connect(regions["Exodus Plaza North"])
        regions["Exodus Plaza"].connect(regions["Exodus Plaza South"])
        regions["Exodus Plaza"].connect(regions["Exodus Plaza Entrance"])
        
        # Plant facility connections
        regions["Exodus Plaza"].connect(regions["Plant Facility Offices"])
        regions["Plant Facility Offices"].connect(regions["Plant Facility Elevator"])
        regions["Plant Facility Elevator"].connect(regions["Plant Research Labs"])
        regions["Plant Research Labs"].connect(regions["Plant Cloning"])
        
        # Starlight area connections
        regions["Plant Cloning"].connect(regions["Starlight Exterior"])
        regions["Starlight Exterior"].connect(regions["Starlight Lobby"])
        regions["Starlight Lobby"].connect(regions["Starlight Green"])
        regions["Starlight Lobby"].connect(regions["Starlight Red"])
        regions["Starlight Lobby"].connect(regions["Starlight Blue"])
        regions["Starlight Lobby"].connect(regions["Starlight Purple"])
        regions["Starlight Purple"].connect(regions["Starlight Final"])
        
        # Endgame connection
        regions["Starlight Final"].connect(regions["Endgame"])
        
        # Add all regions to multiworld
        for region in regions.values():
            self.multiworld.regions.append(region)


    def create_item(self, name: str, classification: ItemClassification) -> Item:
        """Create an item with the given name"""
        data = item_table[name]
        return SelacoPatchItem(name, classification, data.code, self.player)

    def get_filler_item_name(self) -> str:
        """Get a random filler item"""
        return self.random.choice(list(filler_table.keys()))

    def fill_slot_data(self) -> Dict[str, Any]:
        """Create slot data for the client"""
        return {
            "goal": self.options.goal.value,
            "starting_weapon": self.options.starting_weapon.value,
            "starting_difficulty": self.options.starting_difficulty.value,
            "weapon_progression": self.options.weapon_progression.value,
            "keycard_shuffle": self.options.keycard_shuffle.value,
            "special_campaign_mode": self.options.special_campaign_mode.value,
            "randomizer_intensity": self.options.randomizer_intensity.value,
            "death_link": self.options.death_link.value,
        }

    def generate_basic(self) -> None:
        """Called after items and locations are created but before rules"""
        pass

    def generate_output(self, output_directory: str) -> None:
        """Generate any additional output files needed"""
        pass