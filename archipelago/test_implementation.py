"""
Test validation for Selaco Archipelago Integration

Basic tests to ensure the implementation structure is sound.
"""

import sys
import os

# Add the archipelago directory to path for testing
sys.path.insert(0, os.path.join(os.path.dirname(__file__)))

def test_basic_imports():
    """Test that all modules can be imported without errors."""
    try:
        import Items
        import Locations  
        import Rules
        import Options
        import research_tools
        import data_validator
        print("✓ All modules import successfully")
        return True
    except Exception as e:
        print(f"✗ Import error: {e}")
        return False

def test_item_data_integrity():
    """Test that item data is properly structured."""
    try:
        from Items import SelAcoItemData, get_item_names_per_category
        
        # Check that all items have valid data
        for name, data in SelAcoItemData.items():
            assert isinstance(data.code, int), f"Item {name} has invalid code type"
            assert data.code > 0, f"Item {name} has invalid code value"
            assert hasattr(data, 'classification'), f"Item {name} missing classification"
            
        # Check categorization
        categories = get_item_names_per_category()
        total_categorized = sum(len(items) for items in categories.values())
        assert total_categorized == len(SelAcoItemData), "Item categorization mismatch"
        
        print(f"✓ {len(SelAcoItemData)} items validated successfully")
        return True
    except Exception as e:
        print(f"✗ Item data error: {e}")
        return False

def test_location_data_integrity():
    """Test that location data is properly structured."""
    try:
        from Locations import SelAcoLocationData, get_locations_by_region
        
        # Check that all locations have valid data
        for name, data in SelAcoLocationData.items():
            assert isinstance(data.code, int), f"Location {name} has invalid code type"
            assert data.code > 0, f"Location {name} has invalid code value"
            assert isinstance(data.region, str), f"Location {name} has invalid region type"
            
        # Check region distribution
        regions = get_locations_by_region()
        assert len(regions) > 0, "No regions found"
        
        print(f"✓ {len(SelAcoLocationData)} locations validated successfully")
        return True
    except Exception as e:
        print(f"✗ Location data error: {e}")
        return False

def test_no_id_conflicts():
    """Test that item and location IDs don't conflict."""
    try:
        from Items import SelAcoItemData
        from Locations import SelAcoLocationData
        
        item_ids = set(data.code for data in SelAcoItemData.values())
        location_ids = set(data.code for data in SelAcoLocationData.values())
        
        conflicts = item_ids.intersection(location_ids)
        assert len(conflicts) == 0, f"ID conflicts found: {conflicts}"
        
        print("✓ No ID conflicts between items and locations")
        return True
    except Exception as e:
        print(f"✗ ID conflict check error: {e}")
        return False

def test_data_completeness():
    """Test that we have reasonable data coverage."""
    try:
        from Items import SelAcoItemData
        from Locations import SelAcoLocationData
        
        # Basic completeness checks
        assert len(SelAcoItemData) >= 20, "Too few items defined"
        assert len(SelAcoLocationData) >= 50, "Too few locations defined"
        
        # Check we have progression items
        from Items import get_item_names_per_category
        categories = get_item_names_per_category()
        assert len(categories["progression"]) >= 10, "Too few progression items"
        
        print("✓ Data completeness checks passed")
        return True
    except Exception as e:
        print(f"✗ Data completeness error: {e}")
        return False

def test_research_tools():
    """Test that research tools generate properly."""
    try:
        from research_tools import generate_research_report
        
        report = generate_research_report()
        assert len(report) > 100, "Research report too short"
        assert "HIGH CONFIDENCE" in report, "Research report missing confidence levels"
        
        print("✓ Research tools working correctly")
        return True
    except Exception as e:
        print(f"✗ Research tools error: {e}")
        return False

def test_data_validator():
    """Test that data validator works."""
    try:
        from data_validator import DataValidator
        
        validator = DataValidator()
        item_results = validator.validate_items()
        location_results = validator.validate_locations()
        
        assert "confirmed_items" in item_results, "Item validation missing expected keys"
        assert "total_locations" in location_results, "Location validation missing expected keys"
        
        print("✓ Data validator working correctly")
        return True
    except Exception as e:
        print(f"✗ Data validator error: {e}")
        return False

def run_all_tests():
    """Run all validation tests."""
    print("Running Selaco Archipelago Implementation Tests")
    print("=" * 50)
    
    tests = [
        test_basic_imports,
        test_item_data_integrity,
        test_location_data_integrity,
        test_no_id_conflicts,
        test_data_completeness,
        test_research_tools,
        test_data_validator
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
            print(f"✗ Test {test.__name__} crashed: {e}")
            failed += 1
    
    print("\n" + "=" * 50)
    print(f"Test Results: {passed} passed, {failed} failed")
    
    if failed == 0:
        print("🎉 All tests passed! Implementation structure is sound.")
    else:
        print("⚠️  Some tests failed. Review errors above.")
        
    return failed == 0

if __name__ == "__main__":
    success = run_all_tests()
    sys.exit(0 if success else 1)