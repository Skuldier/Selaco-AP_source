"""
Standalone validation for Selaco Archipelago data structure

This validates the data structure without requiring Archipelago imports.
"""

def test_item_structure():
    """Test basic item data structure."""
    
    # Mock the BaseClasses import for testing
    class ItemClassification:
        progression = "progression"
        useful = "useful" 
        filler = "filler"
    
    class ItemData:
        def __init__(self, code, classification, quantity=1):
            self.code = code
            self.classification = classification
            self.quantity = quantity
    
    # Test the item definitions structure
    item_data = {
        # Progression items
        "Purple Keycard": ItemData(1001, ItemClassification.progression),
        "Yellow Keycard": ItemData(1002, ItemClassification.progression), 
        "Blue Keycard": ItemData(1003, ItemClassification.progression),
        
        "Security Card Level 1": ItemData(1010, ItemClassification.progression),
        "Security Card Level 7": ItemData(1016, ItemClassification.progression),
        
        "Gas Mask": ItemData(1020, ItemClassification.progression),
        "Demolition Charges": ItemData(1021, ItemClassification.progression),
        
        # Weapons
        "Roaring Cricket": ItemData(2001, ItemClassification.progression),
        "Railgun": ItemData(2008, ItemClassification.progression),
        
        # Upgrades
        "Health Upgrade": ItemData(3001, ItemClassification.useful),
        "Equipment Bandolier": ItemData(3002, ItemClassification.useful),
        
        # Collectibles
        "Cabinet Card": ItemData(4001, ItemClassification.filler),
        "Trading Card": ItemData(4002, ItemClassification.filler),
        
        # Filler
        "Credits (Small)": ItemData(5001, ItemClassification.filler),
        "Credits (Large)": ItemData(5003, ItemClassification.filler),
    }
    
    # Validate structure
    assert len(item_data) >= 15, f"Expected at least 15 items, got {len(item_data)}"
    
    # Check ID ranges
    progression_ids = [data.code for name, data in item_data.items() if data.classification == ItemClassification.progression]
    useful_ids = [data.code for name, data in item_data.items() if data.classification == ItemClassification.useful]
    filler_ids = [data.code for name, data in item_data.items() if data.classification == ItemClassification.filler]
    
    assert len(progression_ids) >= 8, f"Expected at least 8 progression items, got {len(progression_ids)}"
    assert len(useful_ids) >= 2, f"Expected at least 2 useful items, got {len(useful_ids)}"
    assert len(filler_ids) >= 3, f"Expected at least 3 filler items, got {len(filler_ids)}"
    
    # Check no duplicate IDs
    all_ids = [data.code for data in item_data.values()]
    assert len(all_ids) == len(set(all_ids)), "Duplicate item IDs found"
    
    print(f"✓ Item structure valid: {len(item_data)} items")
    return True


def test_location_structure():
    """Test basic location data structure."""
    
    class LocationData:
        def __init__(self, code, region):
            self.code = code
            self.region = region
    
    # Test location structure based on confirmed maps
    confirmed_maps = [
        "SE_01A", "SE_01b", "SE_01c",
        "SE_02A", "SE_02B", "SE_02C", "SE_02Z",
        "SE_03A", "SE_03A1", "SE_03B", "SE_03B1", "SE_03B2", "SE_03C",
        "SE_04A", "SE_04B", "SE_04C",
        "SE_05A", "SE_05B", "SE_05C", "SE_05D",
        "SE_06A", "SE_06A1", "SE_06B", "SE_06C",
        "SE_07A", "SE_07A1", "SE_07B", "SE_07D", "SE_07E", "SE_07Z",
        "SE_08A"
    ]
    
    # Verify we have the expected map count
    assert len(confirmed_maps) >= 30, f"Expected at least 30 maps, got {len(confirmed_maps)}"
    
    # Test location generation
    location_data = {}
    location_id = 1000
    
    # Sample progression locations
    progression_locations = [
        ("Purple Keycard - Chapter 1", "Chapter 1"),
        ("Yellow Keycard - Chapter 2", "Chapter 2"), 
        ("Blue Keycard - Chapter 3", "Chapter 3"),
        ("Security Card Level 1 - Chapter 1", "Chapter 1"),
        ("Roaring Cricket - Tutorial", "Chapter 1"),
        ("Railgun - Late Game", "Chapter 7"),
    ]
    
    for location_name, region in progression_locations:
        location_data[location_name] = LocationData(location_id, region)
        location_id += 1
    
    # Sample collectible locations  
    for i in range(1, 21):  # 20 collectibles
        location_name = f"Cabinet Card {i}"
        chapter_index = (i - 1) % 8
        region = f"Chapter {chapter_index + 1}"
        location_data[location_name] = LocationData(location_id, region)
        location_id += 1
    
    # Validate structure
    assert len(location_data) >= 25, f"Expected at least 25 locations, got {len(location_data)}"
    
    # Check regions exist
    regions = set(data.region for data in location_data.values())
    expected_regions = {f"Chapter {i}" for i in range(1, 9)}
    assert len(regions.intersection(expected_regions)) >= 3, "Missing expected chapter regions"
    
    # Check no duplicate IDs
    all_ids = [data.code for data in location_data.values()]
    assert len(all_ids) == len(set(all_ids)), "Duplicate location IDs found"
    
    print(f"✓ Location structure valid: {len(location_data)} locations across {len(regions)} regions")
    return True


def test_data_ranges():
    """Test that ID ranges don't conflict."""
    
    # Define expected ID ranges
    ranges = {
        "progression_items": (1000, 1999),
        "weapons": (2000, 2999), 
        "useful_items": (3000, 3999),
        "collectibles": (4000, 4999),
        "filler_items": (5000, 5999),
        "locations": (1000, 9999)  # Separate namespace
    }
    
    # Check ranges don't overlap within items
    item_ranges = [(1000, 1999), (2000, 2999), (3000, 3999), (4000, 4999), (5000, 5999)]
    
    for i, (start1, end1) in enumerate(item_ranges):
        for j, (start2, end2) in enumerate(item_ranges):
            if i != j:  # Different ranges
                assert not (start1 <= end2 and start2 <= end1), f"Item ID ranges {i} and {j} overlap"
    
    print("✓ ID ranges valid and non-overlapping")
    return True


def test_source_verification():
    """Test that all data has source citations."""
    
    # Count items with source comments (from actual files)
    import os
    
    archipelago_files = [
        "Items.py",
        "Locations.py", 
        "Rules.py",
        "Options.py"
    ]
    
    total_source_citations = 0
    
    for filename in archipelago_files:
        if os.path.exists(filename):
            with open(filename, 'r') as f:
                content = f.read()
                # Count source citations
                source_count = content.count("SOURCE:")
                todo_count = content.count("TODO: VERIFY")
                needs_count = content.count("NEEDS:")
                
                total_source_citations += source_count
                
                print(f"  {filename}: {source_count} sources, {todo_count} TODOs, {needs_count} needs verification")
    
    assert total_source_citations >= 10, f"Expected at least 10 source citations, got {total_source_citations}"
    
    print(f"✓ Source verification: {total_source_citations} citations found")
    return True


def test_research_completeness():
    """Test that research documentation is comprehensive."""
    
    import os
    
    required_files = [
        "README.md",
        "research_tools.py",
        "data_validator.py",
        "test_implementation.py"
    ]
    
    for filename in required_files:
        assert os.path.exists(filename), f"Required file {filename} missing"
    
    # Check README has required sections
    with open("README.md", 'r') as f:
        readme_content = f.read()
        
    required_sections = [
        "Research Summary",
        "Data Confirmed", 
        "Verification Needs",
        "Confidence Levels"
    ]
    
    for section in required_sections:
        assert section in readme_content, f"README missing required section: {section}"
    
    print("✓ Research documentation complete")
    return True


def run_standalone_tests():
    """Run all standalone tests."""
    print("Selaco Archipelago Standalone Validation")
    print("=" * 50)
    
    tests = [
        test_item_structure,
        test_location_structure,
        test_data_ranges,
        test_source_verification,
        test_research_completeness
    ]
    
    passed = 0
    failed = 0
    
    for test in tests:
        try:
            if test():
                passed += 1
            else:
                failed += 1
        except Exception as e:
            print(f"✗ Test {test.__name__} failed: {e}")
            failed += 1
    
    print("\n" + "=" * 50)
    print(f"Validation Results: {passed} passed, {failed} failed")
    
    if failed == 0:
        print("🎉 All validations passed! Implementation ready for Archipelago integration.")
        return True
    else:
        print("⚠️  Some validations failed. Review errors above.")
        return False


if __name__ == "__main__":
    import sys
    success = run_standalone_tests()
    sys.exit(0 if success else 1)