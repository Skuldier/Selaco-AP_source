"""
Research Assistant Tools for Selaco Archipelago Integration

This file contains tools and templates to help gather missing data
and complete the implementation with community input.
"""

# COMMUNITY QUESTIONNAIRE TEMPLATE
COMMUNITY_QUESTIONS = """
# Selaco Archipelago Integration - Community Data Request

We are creating an Archipelago multiworld integration for Selaco and need community help 
to verify exact game data. Please answer as many questions as possible:

## ITEM COUNTS

### Collectibles (per map or total):
1. How many Cabinet Cards are in the full game? ___
2. How many Trading Cards are in the full game? ___  
3. How many Secret Areas are there? ___
4. How many Health Upgrades are available? ___
5. How many Weapon Capacity Kits exist? ___

### Weapons:
6. Which weapons are required for progression vs optional? 
   - Roaring Cricket: Required / Optional
   - Shotgun: Required / Optional  
   - Assault Rifle: Required / Optional
   - Nailgun: Required / Optional
   - Plasma Rifle: Required / Optional
   - Grenade Launcher: Required / Optional
   - DMR: Required / Optional
   - Railgun: Required / Optional

## PROGRESSION REQUIREMENTS

### Keycards:
7. Which areas require the Purple Keycard? ___
8. Which areas require the Yellow Keycard? ___
9. Which areas require the Blue Keycard? ___

### Security Clearance:
10. What areas require Security Level 1? ___
11. What areas require Security Level 2? ___
12. What areas require Security Level 3? ___
13. What areas require Security Level 4? ___
14. What areas require Security Level 5? ___
15. What areas require Security Level 6? ___
16. What areas require Security Level 7? ___

### Equipment:
17. Where is the Gas Mask required? ___
18. Where are Demolition Charges required? ___

## VICTORY CONDITION

19. What constitutes completing the game?
    [ ] Reach the final level
    [ ] Defeat the final boss
    [ ] Collect all items
    [ ] Other: ___

20. Are there multiple endings? If so, describe: ___

## MAP STRUCTURE

21. Do maps have to be completed in order? Y/N ___
22. Are there optional/secret maps? List: ___
23. Can you return to previous maps? Y/N ___

## ADDITIONAL INFORMATION

24. Any other important progression items we missed? ___
25. Are there any sequence breaks or alternate routes? ___
26. Additional comments: ___

Thank you for your help!
"""


# SEARCH STRATEGY TEMPLATE
SEARCH_STRATEGIES = """
# Search Strategies for Missing Selaco Data

## Priority 1: Official Sources
- [ ] Official Selaco wiki (if exists)
- [ ] Steam store page and community guides  
- [ ] Developer Discord/forum posts
- [ ] Official strategy guide or manual

## Priority 2: Community Sources  
- [ ] GameFAQs walkthrough/guides
- [ ] Steam achievement guides
- [ ] YouTube 100% completion guides
- [ ] Speedrun.com resources and guides
- [ ] Reddit r/Selaco or r/GZDoom posts

## Priority 3: Data Mining
- [ ] Analyze save files for item counts
- [ ] Use GZDoom debugging features
- [ ] Community-created item/map spreadsheets
- [ ] Modding community resources

## Search Queries to Try:
- "Selaco collectibles locations guide"
- "Selaco 100% completion walkthrough"  
- "Selaco all weapons locations"
- "Selaco keycard progression guide"
- "Selaco secret areas complete list"
- "Selaco achievement guide all items"

## Data Verification Steps:
1. Cross-reference between multiple sources
2. Test in-game when possible
3. Check with speedrun community for accuracy
4. Verify with other randomizer communities
"""


# DATA VALIDATION SCRIPT TEMPLATE
DATA_VALIDATION_TEMPLATE = """
# Selaco Data Validation Checklist

Run this checklist before releasing the Archipelago integration:

## Core Data Verification
- [ ] All progression items have confirmed sources
- [ ] All location counts are verified by community
- [ ] Victory condition is confirmed by multiple players  
- [ ] No placeholder data remains in production code

## Logic Verification  
- [ ] All progression requirements tested in-game
- [ ] No impossible item combinations
- [ ] Sequence breaks documented and handled
- [ ] Softlock prevention verified

## Community Testing
- [ ] Beta tested by Selaco community members
- [ ] Tested with different game options/difficulties
- [ ] Tested with different Archipelago settings
- [ ] Performance impact assessed

## Code Quality
- [ ] All TODO comments resolved
- [ ] Source citations complete and accurate
- [ ] No hardcoded estimates remain
- [ ] Error handling for missing data
"""


# DEVELOPMENT PHASES
DEVELOPMENT_PHASES = """
# Selaco Archipelago Development Roadmap

## Phase 1: Research and Data Gathering (CURRENT)
- [x] Source code analysis complete
- [x] Basic structure identified
- [ ] Community data collection
- [ ] Official source verification
- [ ] Complete item/location database

## Phase 2: Core Implementation  
- [ ] Basic randomizer integration
- [ ] Progression logic implementation
- [ ] Client-side mod development
- [ ] Basic testing framework

## Phase 3: Advanced Features
- [ ] Option system implementation
- [ ] Quality of life improvements  
- [ ] Advanced randomization modes
- [ ] Performance optimization

## Phase 4: Testing and Release
- [ ] Community beta testing
- [ ] Bug fixes and refinements
- [ ] Documentation completion
- [ ] Official release

## Estimated Timeline:
- Phase 1: 2-4 weeks (depends on community response)
- Phase 2: 4-6 weeks (depends on game modification complexity)
- Phase 3: 2-3 weeks
- Phase 4: 2-3 weeks

Total: 10-16 weeks for full implementation
"""


def generate_research_report():
    """Generate a comprehensive research status report."""
    return f"""
# Selaco Archipelago Research Status Report

## Data Confidence Levels:

### HIGH CONFIDENCE (Source Code Verified):
- Item class structure and names
- Basic weapon list
- Map naming convention  
- Difficulty system
- Security clearance levels (1-7)

### MEDIUM CONFIDENCE (Inferred from Code):
- Chapter progression structure
- Basic item categories
- Collectible tracking system
- Stat system integration

### LOW CONFIDENCE (Logical Assumptions):
- Exact item counts per map
- Specific progression requirements  
- Weapon unlock conditions
- Victory conditions

### NO CONFIDENCE (Missing Data):
- Community-verified item counts
- Tested progression routes
- Optional vs required content
- Sequence break possibilities

## Next Steps:
1. Deploy community questionnaire
2. Verify with speedrun community
3. Test progression assumptions in-game
4. Cross-reference with achievement data

## Risk Assessment:
- HIGH RISK: Victory condition unclear
- MEDIUM RISK: Item count estimates may be wrong
- LOW RISK: Basic progression structure is sound
"""


if __name__ == "__main__":
    print("Selaco Research Assistant Tools")
    print("=" * 50)
    print("Available tools:")
    print("1. Community questionnaire template")
    print("2. Search strategy guide") 
    print("3. Data validation checklist")
    print("4. Development roadmap")
    print("5. Research status report")
    
    # Generate all templates for easy access
    with open("/tmp/selaco_community_questions.md", "w") as f:
        f.write(COMMUNITY_QUESTIONS)
    
    with open("/tmp/selaco_search_strategies.md", "w") as f:
        f.write(SEARCH_STRATEGIES)
        
    with open("/tmp/selaco_validation_checklist.md", "w") as f:
        f.write(DATA_VALIDATION_TEMPLATE)
        
    with open("/tmp/selaco_development_roadmap.md", "w") as f:
        f.write(DEVELOPMENT_PHASES)
        
    with open("/tmp/selaco_research_report.md", "w") as f:
        f.write(generate_research_report())
        
    print("\nAll templates generated in /tmp/")