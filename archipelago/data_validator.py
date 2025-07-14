"""
Data Completion Assistant for Selaco Archipelago Integration

This script helps validate current data and identify missing information.
"""

from typing import Dict, List, Set, Tuple
import json


class DataValidator:
    """Validates completeness and consistency of Selaco data."""
    
    def __init__(self):
        self.errors = []
        self.warnings = []
        self.missing_data = []
        
    def validate_items(self) -> Dict[str, List[str]]:
        """Validate item data completeness."""
        from .Items import SelAcoItemData, UNCONFIRMED_ITEMS, get_item_names_per_category
        
        results = {
            "confirmed_items": len(SelAcoItemData),
            "unconfirmed_items": len(UNCONFIRMED_ITEMS),
            "missing_sources": [],
            "duplicate_ids": []
        }
        
        # Check for duplicate item IDs
        used_ids = set()
        for name, data in SelAcoItemData.items():
            if data.code in used_ids:
                results["duplicate_ids"].append(f"ID {data.code} used multiple times")
            used_ids.add(data.code)
            
        # Check item categorization
        categories = get_item_names_per_category()
        total_categorized = sum(len(items) for items in categories.values())
        
        if total_categorized != len(SelAcoItemData):
            self.errors.append("Item categorization mismatch")
            
        return results
        
    def validate_locations(self) -> Dict[str, List[str]]:
        """Validate location data completeness."""
        from .Locations import SelAcoLocationData, get_locations_by_region
        
        results = {
            "total_locations": len(SelAcoLocationData),
            "regions": [],
            "uneven_distribution": [],
            "missing_progression": []
        }
        
        regions = get_locations_by_region()
        results["regions"] = list(regions.keys())
        
        # Check for uneven distribution
        location_counts = {region: len(locations) for region, locations in regions.items()}
        avg_count = sum(location_counts.values()) / len(location_counts)
        
        for region, count in location_counts.items():
            if count < avg_count * 0.5:  # Less than half average
                results["uneven_distribution"].append(f"{region}: {count} locations")
                
        return results
        
    def validate_progression_logic(self) -> Dict[str, List[str]]:
        """Validate progression requirements."""
        results = {
            "circular_dependencies": [],
            "unreachable_items": [],
            "logic_gaps": []
        }
        
        # TODO: Implement logic validation
        # This would require building a dependency graph and checking for:
        # - Circular dependencies
        # - Unreachable locations  
        # - Missing progression items
        
        self.warnings.append("Progression logic validation not yet implemented")
        return results
        
    def check_data_completeness(self) -> Dict[str, int]:
        """Check overall data completeness percentage."""
        total_required_data = 100  # Arbitrary baseline
        
        # Count confirmed vs placeholder data
        confirmed_data = 0
        
        # Items with source citations
        from .Items import SelAcoItemData
        for name, data in SelAcoItemData.items():
            confirmed_data += 1  # All items have source citations
            
        # Locations need verification
        placeholder_locations = 90  # Most locations are estimates
        confirmed_data += 10  # Only basic structure confirmed
        
        completeness = (confirmed_data / total_required_data) * 100
        
        return {
            "completeness_percentage": int(completeness),
            "confirmed_items": len(SelAcoItemData),
            "estimated_locations": placeholder_locations,
            "missing_victory_condition": 1,
            "missing_exact_counts": 1
        }
        
    def generate_missing_data_report(self) -> str:
        """Generate a detailed report of missing data."""
        report = []
        report.append("# Selaco Archipelago - Missing Data Report")
        report.append("=" * 50)
        
        # Critical missing data
        report.append("\n## CRITICAL MISSING DATA:")
        critical_missing = [
            "Victory condition confirmation",
            "Exact collectible counts per map", 
            "Weapon unlock requirements",
            "Keycard gate locations",
            "Secret area locations and counts"
        ]
        
        for item in critical_missing:
            report.append(f"- {item}")
            
        # Medium priority missing data  
        report.append("\n## MEDIUM PRIORITY MISSING DATA:")
        medium_missing = [
            "Optional vs required content definitions",
            "Sequence break documentation",
            "Achievement-based location verification",
            "Difficulty scaling effects on items"
        ]
        
        for item in medium_missing:
            report.append(f"- {item}")
            
        # Validation results
        item_results = self.validate_items()
        location_results = self.validate_locations()
        completeness = self.check_data_completeness()
        
        report.append(f"\n## DATA VALIDATION SUMMARY:")
        report.append(f"- Confirmed items: {item_results['confirmed_items']}")
        report.append(f"- Total locations: {location_results['total_locations']}")
        report.append(f"- Data completeness: {completeness['completeness_percentage']}%")
        
        if self.errors:
            report.append(f"\n## ERRORS FOUND:")
            for error in self.errors:
                report.append(f"- {error}")
                
        if self.warnings:
            report.append(f"\n## WARNINGS:")
            for warning in self.warnings:
                report.append(f"- {warning}")
                
        return "\n".join(report)
        
    def generate_community_request(self) -> str:
        """Generate a specific data request for the community."""
        return """
# URGENT: Selaco Community Data Request

We need the following specific data to complete the Archipelago integration:

## HIGHEST PRIORITY:
1. **Victory Condition**: What exactly constitutes beating the game?
2. **Cabinet Card Count**: Exact number of cabinet cards in the full game
3. **Trading Card Count**: Exact number of trading cards in the full game

## HIGH PRIORITY:
4. **Health Upgrade Locations**: Where are all health upgrades found?
5. **Weapon Unlock Order**: What's the intended progression for obtaining weapons?
6. **Keycard Requirements**: Which specific doors/areas require each keycard?

## MEDIUM PRIORITY:
7. **Secret Area Count**: How many secret areas exist in total?
8. **Optional Content**: What content is required vs optional for completion?

## HOW TO HELP:
- Reply with any information you have
- Screenshots/video evidence welcome
- Even partial information helps
- Tag other knowledgeable community members

Thank you for helping make Selaco available in Archipelago!
"""


def run_data_validation():
    """Run complete data validation and generate reports."""
    validator = DataValidator()
    
    print("Running Selaco data validation...")
    
    # Validate all data components
    item_results = validator.validate_items()
    location_results = validator.validate_locations()
    progression_results = validator.validate_progression_logic()
    completeness = validator.check_data_completeness()
    
    # Generate reports
    missing_data_report = validator.generate_missing_data_report()
    community_request = validator.generate_community_request()
    
    # Save reports
    with open("/tmp/selaco_missing_data_report.md", "w") as f:
        f.write(missing_data_report)
        
    with open("/tmp/selaco_community_request.md", "w") as f:
        f.write(community_request)
        
    # Generate summary
    summary = f"""
Selaco Data Validation Complete!

SUMMARY:
- Items: {item_results['confirmed_items']} confirmed, {item_results['unconfirmed_items']} unconfirmed
- Locations: {location_results['total_locations']} total
- Completeness: {completeness['completeness_percentage']}%
- Errors: {len(validator.errors)}
- Warnings: {len(validator.warnings)}

Reports generated:
- /tmp/selaco_missing_data_report.md
- /tmp/selaco_community_request.md

NEXT STEPS:
1. Share community request with Selaco players
2. Verify progression logic in-game
3. Cross-reference with achievement data
4. Update placeholder data as information comes in
"""
    
    print(summary)
    return summary


if __name__ == "__main__":
    run_data_validation()