# Selaco Archipelago World

## Overview

This is an Archipelago world for **Selaco**, the retro-style first-person shooter inspired by classics like F.E.A.R. and DOOM. Selaco takes place aboard a massive space station where you play as Dawn, a Security Captain fighting to survive and uncover the truth behind the station's crisis.

## What is Archipelago?

Archipelago is a multi-world randomizer that allows you to play multiple games simultaneously with other players. Items from one game can appear in another player's game, creating a unique cooperative experience where players must work together to complete their individual games.

## How does Selaco fit into Archipelago?

In this randomized version of Selaco:

- **Items** (weapons, keycards, equipment, upgrades) are shuffled between locations
- **Locations** include story progression points, secret areas, achievements, and challenges
- **Progression** is gated by having the right items (weapons, keycards, tools)
- **Victory** requires collecting specific endgame items and reaching the final confrontation

## Features

### Items (150+ items)
- **Weapons**: G19 Handgun, UC-11 Exon SMG, Riot Shotgun, S-8 Marksman Rifle, Roaring Cricket, Grenade Launcher, Pulse Cannon, Railgun, Plasma Rifle
- **Equipment**: Gravity Manipulator, Thermal Goggles, Flashlight, Detector, Environmental Suit
- **Keycards**: Red, Blue, Yellow, Green keycards plus specialized access cards for different station areas
- **Upgrades**: Weapon modifications, armor pieces, stat boosts
- **Consumables**: Health items, ammo, grenades, utility items
- **Story Items**: Dawn's Badge, Communication Device, Emergency Override, Victory items

### Locations (200+ locations)
- **Chapter Progression**: 6 main chapters with 10 progression locations each
- **Secrets**: Hidden caches, safes, and stashes throughout the station (60+ secret locations)
- **Achievements**: Optional challenges that reward exploration and skill (10 achievement locations)
- **Challenges**: Difficult optional content for advanced players (10 challenge locations)
- **Station-wide**: Special cross-chapter locations and victory conditions

### Game Logic
- **Chapter-based progression** with increasing access requirements
- **Keycard gates** that require specific access levels for different station areas
- **Combat difficulty scaling** based on available weapons and equipment
- **Environmental hazards** requiring protective equipment
- **Exploration requirements** for secret and hidden locations

## Installation and Setup

### Prerequisites
- Selaco game (available on Steam)
- Archipelago client (download from [archipelago.gg](https://archipelago.gg))
- Python 3.8+ (for generating and hosting worlds)

### Installation Steps

1. **Install Archipelago**: Download and install the latest Archipelago release

2. **Add Selaco World**: Copy this `archipelago` folder to your Archipelago `worlds` directory

3. **Configure Settings**: Copy `Selaco.yaml` to your Archipelago folder and edit with your preferences

4. **Generate World**: Run the Archipelago generator with your YAML file

5. **Install Game Mod**: Install the generated Selaco mod file in your Selaco installation

6. **Connect and Play**: Launch Selaco and connect to your Archipelago server

## Configuration Options

### Core Gameplay
- **Goal**: Choose between escaping, retaking, destroying, or saving the station
- **Starting Weapon**: Begin with no weapon, handgun, SMG, or random weapon
- **Difficulty Level**: Casual, Normal, Hard, or Nightmare
- **Starting Health**: 25-100% health at game start

### Randomization
- **Enemy Randomization**: Vanilla, shuffled, random, or scaled enemy placement
- **Weapon Progression**: Early, balanced, late, or random weapon distribution
- **Keycard Distribution**: Logical, shuffled, or completely random keycard placement
- **Randomizer Mode**: Standard, chaos, race, or exploration focus

### Content Inclusion
- **Include Achievements**: Optional achievement-based locations (default: on)
- **Include Challenges**: Difficult challenge locations (default: off)
- **Shuffle Chapters**: Randomize chapter completion order (default: off)

### Item Balance
- **Item Density**: Percentage of locations that have items (default: 75%)
- **Health Item Frequency**: How often health items appear (1-5 scale)
- **Ammo Scarcity**: How scarce ammunition is (1-5 scale)

### Quality of Life
- **Fast Elevators**: Speed up elevator travel time
- **Skip Cutscenes**: Automatically skip story cutscenes
- **Progressive Items**: Make keycards and weapons progressive

## Victory Conditions

To complete your Selaco world, you must:

1. **Collect Victory Items**: Station Core Access, Emergency Shutdown Override, Evacuation Pod Key
2. **Reach Final Location**: Chapter 6 - Final Confrontation
3. **Meet Goal Requirements**: Depends on your selected goal option

The final confrontation requires advanced combat capability and all story progression items.

## Tips for Playing

### For Beginners
- Start with **Casual** difficulty and **Handgun** starting weapon
- Enable **Include Achievements** but disable challenges
- Use **Logical** keycard distribution for a more predictable experience
- Set **Health Item Frequency** to 4-5 for more forgiving gameplay

### For Veterans
- Try **Hard** or **Nightmare** difficulty with **No starting weapon**
- Enable both achievements and challenges for maximum content
- Use **Random** keycard distribution for more unpredictable routing
- Enable **Shuffle Chapters** for a completely different experience

### For Archipelago Veterans
- Use **Chaos** randomizer mode for maximum chaos
- Enable **Randomize Enemy Stats** and **Randomize Weapon Stats**
- Set **Item Density** lower (50-60%) for more routing decisions
- Try different **Goals** for varied victory conditions

## Known Issues and Limitations

- This is a conceptual implementation - actual integration with Selaco would require game engine modifications
- Some locations may require specific combinations of items that could create difficult progression scenarios
- Challenge locations are designed to be very difficult and may not be completable by all players
- Randomized enemy/weapon stats may create balance issues in extreme cases

## Contributing

This Archipelago world implementation is open for community contributions:

- **Bug Reports**: Report issues with logic or impossible generation scenarios
- **Balance Suggestions**: Propose changes to item/location balance
- **New Content**: Suggest additional items, locations, or features
- **Code Improvements**: Optimize the generation logic or add new features

## Credits

- **Selaco**: Created by Altered Orbit Studios
- **Archipelago**: Multi-world randomizer system by the Archipelago community
- **Integration**: Created for the Archipelago community

## Disclaimer

This is a fan-created integration for educational and entertainment purposes. Selaco is the property of Altered Orbit Studios. This mod requires owning the original game and is not affiliated with or endorsed by the developers.

## Version History

### v1.0.0 (Initial Release)
- Complete item and location database (150+ items, 200+ locations)
- Comprehensive rule logic for all 6 chapters
- Multiple victory conditions and game modes
- Extensive configuration options
- Achievement and challenge location support
- Progressive item systems
- Quality of life improvements