// Fake weapon classes to represent the grenades and mines etc. 
// These are required because certain items that can be upgraded aren't actually weapons

// @Nexxtic - Jesus Christ this is the fakest shit I've ever seen 

/////////////// -- GRENADE -- ///////////////
class FakeWeapon : SelacoWeapon {
	default {
		WeaponBase.MinSelectionAmmo1 999999;		// Added to prevent auto-switching to fake weapons
		WeaponBase.MinSelectionAmmo2 999999;		// Added to prevent auto-switching to fake weapons
	}
}

class HandGrenadeWeapon : FakeWeapon {
    default {
        Tag "Hand Grenade";
		WeaponBase.AmmoType1 "HandGrenadeAmmo";
		SelacoWeapon.weaponProjectileSpeed 30;
		SelacoWeapon.weaponRecoil 0;
        WeaponBase.SlotNumber 20;
        SelacoWeapon.AlwaysShowInWorkshop true;
        SelacoWeapon.ImagePrefix "grenade";
		SelacoWeapon.AltFireLabel "$ALT_FIRES_B";
		SelacoWeapon.weaponDamage 450;
		SelacoWeapon.weaponAreaOfEffect 295;
		Inventory.Icon "WPGNGRND";
    }
}

class MineWeapon : FakeWeapon {
    default {
        Tag "Mine";
		WeaponBase.AmmoType1 "MineAmmo";
		SelacoWeapon.weaponProjectileSpeed 11;
        WeaponBase.SlotNumber 40;
		SelacoWeapon.weaponDamage 370;
		SelacoWeapon.weaponRecoil 0;
		SelacoWeapon.weaponAreaOfEffect 310;
        SelacoWeapon.AlwaysShowInWorkshop true;
        SelacoWeapon.ImagePrefix "mine";
		SelacoWeapon.AltFireLabel "$ALT_FIRES_B";
		Inventory.Icon "WPNMINEA";
    }
}

class UpgradeGrenadeRadius : WeaponUpgrade {
	default {
		WeaponUpgrade.UpgradeImage 				'UPGRD27';
		Inventory.MaxAmount 					1;
		WeaponUpgrade.areaOfEffectMod 			100;
		WeaponUpgrade.Weapon 					'HandGrenadeWeapon';
		WeaponUpgrade.UpgradeName 				"$UPGRADE_GRENADE_RADIUS", "$UPGRADE_GRENADE_RADIUSH";
		WeaponUpgrade.UpgradeDescription 		"$UPGRADE_GRENADE_RADIUS_DESC";
		WeaponUpgrade.TechModuleRequirement 	3;
		WeaponUpgrade.UpgradePointerPosition 	300, 90;
		WeaponUpgrade.UpgradePosition			440, -20;
		WeaponUpgrade.UpgradeCost          	150;
	}	
}

class UpgradeGrenadeDamage : WeaponUpgrade {
	default {
		WeaponUpgrade.UpgradeImage 				'UPGRD14';
		Inventory.MaxAmount 					1;
		WeaponUpgrade.damageMod 				150;
		WeaponUpgrade.Weapon 					'HandGrenadeWeapon';
		WeaponUpgrade.UpgradeName 				"$UPGRADE_GRENADE_DAMAGE", "$UPGRADE_GRENADE_DAMAGE";
		WeaponUpgrade.UpgradeDescription 		"$UPGRADE_GRENADE_DAMAGE_DESC";
		WeaponUpgrade.TechModuleRequirement 	2;
		WeaponUpgrade.UpgradePointerPosition 	335, 185;
		WeaponUpgrade.UpgradePosition			610, 190;
		WeaponUpgrade.UpgradeCost          	150;
	}	
}

class UpgradeGrenadeSelfDamage : WeaponUpgrade {
	default {
		WeaponUpgrade.UpgradeImage 				'UPGRD34';
		Inventory.MaxAmount 					1;
		WeaponUpgrade.Weapon 					'HandGrenadeWeapon';
		WeaponUpgrade.UpgradeName 				"$UPGRADE_GRENADELAUNCHER_SELFDAMAGE", "$UPGRADE_GRENADELAUNCHER_SELFDAMAGE";
		WeaponUpgrade.UpgradeDescription 		"$UPGRADE_GRENADE_SELFDAMAGE_DESC";
		WeaponUpgrade.TechModuleRequirement 	1;
		WeaponUpgrade.UpgradePointerPosition 	90, 10;
		WeaponUpgrade.UpgradePosition			5, -110;
		WeaponUpgrade.UpgradeCost          	150;
	}	
}

class AltFireGrenadeTraditional: WeaponAltFire {
	default {
		WeaponUpgrade.Weapon 				'HandGrenadeWeapon';
		WeaponUpgrade.UpgradeName 			"$ALTFIRE_GRENADE_TRADITIONAL", "$ALTFIRE_GRENADE_TRADITIONAL";
		WeaponUpgrade.UpgradeDescription 	"$ALTFIRE_GRENADE_TRADITIONAL_DESC";
		WeaponAltFire.WorkshopOrder			-1;		//Traditional Behavior first!
	}	
}

class AltFireGrenadeImpact: WeaponAltFire {
	default {
		WeaponUpgrade.Weapon 				'HandGrenadeWeapon';
		WeaponUpgrade.UpgradeName 			"$ALTFIRE_GRENADE_IMPACT", "$ALTFIRE_GRENADE_IMPACT";
		WeaponUpgrade.UpgradeDescription 	"$ALTFIRE_GRENADE_IMPACT_DESC";
	}	
}

class AltFireGrenadeSticky: WeaponAltFire {
	default {
		WeaponUpgrade.Weapon 				'HandGrenadeWeapon';
		WeaponUpgrade.UpgradeName 			"$ALTFIRE_GRENADE_STICKY", "$ALTFIRE_GRENADE_STICKY";
		WeaponUpgrade.UpgradeDescription 	"$ALTFIRE_GRENADE_STICKY_DESC";
	}	
}

class AltFireGrenadeBalloon: WeaponAltFire {
	default {
		WeaponUpgrade.Weapon 				'HandGrenadeWeapon';
		WeaponUpgrade.UpgradeName 			"$ALTFIRE_GRENADE_BALLOON", "$ALTFIRE_GRENADE_BALLOON";
		WeaponUpgrade.UpgradeDescription 	"$ALTFIRE_GRENADE_BALLOON_DESC";
		WeaponAltFire.WorkshopOrder			99;		// Secrets always at the end!
	}	
}

class UpgradeGrenadeStealth : WeaponUpgrade {
	default {
		WeaponUpgrade.UpgradeImage 'UPGRD28';
		Inventory.MaxAmount						1;
		WeaponUpgrade.Weapon 					'HandGrenadeWeapon';
		WeaponUpgrade.UpgradeName 				"$UPGRADE_GRENADE_STEALTH", "$UPGRADE_GRENADE_STEALTH";
		WeaponUpgrade.UpgradeDescription 		"$UPGRADE_GRENADE_STEALTH_DESC";
		WeaponUpgrade.TechModuleRequirement 	4;
		WeaponUpgrade.UpgradePointerPosition 	152, 326;
		WeaponUpgrade.UpgradePosition			-80, 192;
		WeaponUpgrade.UpgradeCost          	100;
	}	
}

/////////////// -- LAND MINE ///////////////

class UpgradeMineDamage : WeaponUpgrade {
	default {
		WeaponUpgrade.UpgradeImage 				'UPGRD14';
		Inventory.MaxAmount 					1;
		WeaponUpgrade.damageMod 				185;
		WeaponUpgrade.Weapon 					'MineWeapon';
		WeaponUpgrade.UpgradeName 				"$UPGRADE_GRENADE_DAMAGE", "$UPGRADE_GRENADE_DAMAGE";
		WeaponUpgrade.UpgradeDescription 		"$UPGRADE_MINE_DAMAGE_DESC";
		WeaponUpgrade.TechModuleRequirement 	2;
		WeaponUpgrade.UpgradePointerPosition 	20	, 265;
		WeaponUpgrade.UpgradePosition			-140, 150;
		WeaponUpgrade.UpgradeCost          	200;
	}	
}
class UpgradeMineExtractor : WeaponUpgrade {
	default {
		WeaponUpgrade.UpgradeImage 				'UPGRD43';
		Inventory.MaxAmount 					1;
		WeaponUpgrade.Weapon 					'MineWeapon';
		WeaponUpgrade.UpgradeName 				"$UPGRADE_MINE_EXTRACTOR", "$UPGRADE_MINE_EXTRACTOR";
		WeaponUpgrade.UpgradeDescription 		"$UPGRADE_MINE_EXTRACTOR_DESC";
		WeaponUpgrade.TechModuleRequirement 	3;
		WeaponUpgrade.UpgradePointerPosition 	360, 75;
		WeaponUpgrade.UpgradePosition			555, -25;
		WeaponUpgrade.UpgradeCost          		200;
	}	
}

class UpgradeMineRadius : WeaponUpgrade {
	default {
		WeaponUpgrade.UpgradeImage 				'UPGRD27';
		Inventory.MaxAmount 					3;
		WeaponUpgrade.areaOfEffectMod 			60;
		WeaponUpgrade.Weapon 					'MineWeapon';
		WeaponUpgrade.UpgradeName 				"$UPGRADE_GRENADE_RADIUS", "$UPGRADE_GRENADE_RADIUS";
		WeaponUpgrade.UpgradeDescription 		"$UPGRADE_MINE_RADIUS_DESC";
		WeaponUpgrade.TechModuleRequirement 	2;
		WeaponUpgrade.UpgradePointerPosition 	230, 10;
		WeaponUpgrade.UpgradePosition			125, -140;
		WeaponUpgrade.UpgradeCost          	200;
	}	
}
class UpgradeMineFaceHopper : WeaponUpgrade {
	default 
	{	
		WeaponUpgrade.UpgradeImage 				'UPGRD29';
		Inventory.MaxAmount 					4;
		WeaponUpgrade.Weapon 					'MineWeapon';
		WeaponUpgrade.UpgradeName 				"$UPGRADE_MINE_FACEHOPPER", "$UPGRADE_MINE_UPGRADE_MINE_FACEHOPPERSECOND_CHARGE";
		WeaponUpgrade.UpgradeDescription 		"$UPGRADE_MINE_FACEHOPPER_DESC";
		WeaponUpgrade.TechModuleRequirement 	3;
		WeaponUpgrade.UpgradePointerPosition 	430, 300;
		WeaponUpgrade.UpgradePosition			575, 245;
		WeaponUpgrade.UpgradeCost          	200;
	}	
}

class AltFireMineTraditional : WeaponAltFire 
{
	default {
		WeaponUpgrade.Weapon 'MineWeapon';
		WeaponUpgrade.UpgradeName 			"$ALTFIRE_MINE_TRADITIONAL", "$ALTFIRE_MINE_TRADITIONAL";
		WeaponUpgrade.UpgradeDescription 	"$ALTFIRE_MINE_TRADITIONAL_DESC";
		WeaponAltFire.WorkshopOrder			-1;		//Traditional Behavior first!
	}	
}
class AltFireMineSecondCharge : WeaponAltFire 
{
	default {
		WeaponUpgrade.Weapon 'MineWeapon';
		WeaponUpgrade.UpgradeName 			"$ALTFIRE_MINE_SECOND_CHARGE", "$ALTFIRE_MINE_SECOND_CHARGE";
		WeaponUpgrade.UpgradeDescription 	"$ALTFIRE_MINE_SECOND_CHARGE_DESC";
	}	
}
class AltFireMineShock: WeaponAltFire {
	default {
		WeaponUpgrade.Weapon 'MineWeapon';
		WeaponUpgrade.UpgradeName 			"$ALTFIRE_MINE_SHOCK_MINE", "$ALTFIRE_MINE_SHOCK_MINE";
		WeaponUpgrade.UpgradeDescription 	"$ALTFIRE_MINE_SHOCK_MINE_DESC";
	}	
}
class AltFireMineAnnihilation : WeaponAltFire {
	default {
		WeaponUpgrade.Weapon 'MineWeapon';
		WeaponUpgrade.UpgradeName 			"$ALTFIRE_MINE_ANNIHILATION", "$ALTFIRE_MINE_ANNIHILATION";
		WeaponUpgrade.UpgradeDescription 	"$ALTFIRE_MINE_ANNIHILATION_DESC";
	}	
}

