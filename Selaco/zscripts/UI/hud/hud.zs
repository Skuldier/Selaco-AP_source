#include "ZScripts/UI/hud/hud_extension.zsc"
#include "ZScripts/UI/hud/lookat.zs"
#include "ZScripts/UI/hud/cockbar.zs"
#include "ZScripts/UI/hud/weaponbar/weaponbar.zs"
#include "ZScripts/UI/hud/pie_drawer.zs"
#include "ZScripts/UI/hud/hud_saving.zs"
#include "ZScripts/UI/hud/hud_access.zs"
#include "ZScripts/UI/hud/minimap_overlay.zs"
#include "ZScripts/UI/hud/hud_element.zs"
#include "ZScripts/UI/hud/hud_element_ammowarning.zs"
#include "ZScripts/UI/hud/hud_element_keycards.zs"
#include "ZScripts/UI/hud/hud_element_meters.zs"
#include "ZScripts/UI/hud/hud_element_aol.zs"
#include "ZScripts/UI/hud/hud_element_gl.zs"
#include "ZScripts/UI/hud/hud_element_crosshair.zs"
#include "ZScripts/UI/hud/hud_gasmask.zs"
#include "ZScripts/UI/hud/hud_element_shootingrange.zs"
#include "ZScripts/UI/hud/hud_element_countdown.zs"
#include "ZScripts/UI/hud/hud_element_reflection.zs"
#include "ZScripts/UI/hud/hud_element_pickups.zs"
#include "ZScripts/UI/hud/hud_element_predraw.zs"
#include "ZScripts/UI/hud/hud_element_currency.zs"
#include "ZScripts/UI/hud/hud_element_dodge.zs"

#include "ZScripts/UI/hud/utils/randomizer_utils.zs"

// Debug
#include "ZScripts/UI/hud/hud_element_squad_debug.zs"

// TODO: There are so many elements now I should be splitting these into bite size pieces
class HUD : Cockbar {
	//mixin MinimapOverlay;

	uint ticks, deathTicks;
	float textOpacity, frameAlpha;
    //HUDFont bigNumFont, numFont;
	Font bigNumFont, numFont, tinyFont;
	int bigNumFontHeight, numFontHeight;
	float halfBigNumFontHeight, halfNumFontHeight;

	double globalPulse, shakeAmp, shakeFreq, momentAmp, flashTime, lowAmmoStart;
	double changeWeaponTime;
	double crosshairScale;
	SelacoWeapon curWeapon;
	float healthRegen;
	
	int hasGasMask;
	uint pulseStart, healthRegenFadeStart;
	Ammo ammotype1, ammotype2;				// Referenced for weapon type usage, always for current weapon
	int primaryAmmoAmount, secondaryAmmoAmount;

	double deltaMZ;
	Vector2 shake, momentum, deltaMomentum;
	Vector2 selfShakeFactor;					// Shake added by this class and not externally calculated
	Vector2 currentOffset;						// Current calculated shake offset, used for overlays/shaders

	PerlinNoise noise;
	HUDOverlay overlay;
	Weaponbar wpbar;
	PieDrawer healthRegenDrawer;
	NotificationDrawer notifDrawer;
	MinimapOverlay mapOverlay;
	SavingAnimation saveAnim;

	UIPadding screenPadding;	// Padding used to keep elements away from edges of the screen

	bool wasAutomapActive;
	bool hasLowAmmo, showLowAmmo;
	bool noDawnArmor, isHardcore, isXmas, chamberEmpty;
	bool isMuted, isInCamera;	// Don't render anything at all
	bool shouldRender, isLosingHealth, isLosingArmor, healthRegenActive;
	bool showNametags;
	bool noHudMode;
	int deltaArmor, deltaHealth, deltaSplats;
	int deltaAmmo;
	int bigHealth, bigArmor, bigAmmo;

	class<Ammo> reserveAmmoType;

	string healthFullText;

	// Armor vals
	string armorReductionString;
	bool isHeavyArmor;

	Array<HUDElement> elements;

	TextureID armorTex[6], noHealTex;

	enum ArmorTexID {
		Armor_GasMask 	= 0,
		Armor_Minimal 	= 1,
		Armor_Standard 	= 2,
		Armor_Decrement = 3,
		Armor_StandardB = 4,
		Armor_GasMaskB 	= 5
	};

	const BOTTOM_ALIGN = DI_SCREEN_LEFT_BOTTOM | DI_ITEM_LEFT_TOP;
	const BOTTOM_ALIGN_R = DI_SCREEN_RIGHT_BOTTOM | DI_ITEM_LEFT_TOP;
	const BASELINE = -170;			// Bottom row that the icons align with
	//const gasBASELINE = -260;		// Bottom row for gas mask
	const XTRAHALFHEIGHT = 16.5;
	const VISOR_SHAKE_MULT = 0.4;
	const VISOR_MOMENT_MULT = 0.4;
	const WPBAR_SHAKE_MULT = 0.7;
	const WPBAR_MOMENT_MULT = 0.85;
	const MOMENT_MULT = 1.225;		// Multiply momentum by this number = pixel change 
	const MOMENT_MAX = 60.0;		// Max momentum to use
	const MOMENT_DAMP = 0.4;		// Momentum damping
	const BIGHEALTHTICKS = 8;
	const BIGHEALTHSCALE = 0.18;
	const LOWAMMOTICKS = 10;		// Swap red-white every X ticks
	const WEAPON_DISPLAYTIME = 3.0;

	const TICKRATE = double(35.0);
    const ITICKRATE = double(1.0/35.0);


	override void Init() {
		Super.Init();

		mapOverlay = new("MinimapOverlay").init();
		noise = new("PerlinNoise");
		overlay = new("HUDOverlay");
		overlay.Init(scale, hasGasMask);
		wpbar = new("Weaponbar");
		wpbar.Init();

		//Font fnt = "SEFNT100";
		tinyFont = "PDA13FONT";
		bigNumFont = "SEFNT100";//HUDFont.Create(fnt, fnt.GetCharWidth("0"), Mono_CellCenter);
		bigNumFontHeight = bigNumFont.GetHeight();
		halfBigNumFontHeight = float(bigNumFontHeight) / 2.0;

		//fnt = "SELACOFONT";
		numFont = "SELACOFONT";//HUDFont.Create(fnt, fnt.GetCharWidth("0"), Mono_CellCenter);
		numFontHeight = 18; 	// I cannot figure out why the font is small but GetHeight returns 28. fnt.GetHeight();	
		halfNumFontHeight = 8; 	// I cannot figure out things so I am hardcoding for now. float(numFontHeight) / 2.0;

		textOpacity = 0.8;
		frameAlpha = 1.0;
		globalPulse = 1.0;
		pulseStart = MSTime();

		shakeAmp = 1.0;
		shakeFreq = 1.0;

		momentAmp = 1.0;

		deltaArmor = -1;
		deltaHealth = -1;

		healthRegenDrawer = new("PieDrawer");
		healthRegenDrawer.Init("RADIAL1");
		healthRegen = 1;

		notifDrawer = new("NotificationDrawer");
		notifDrawer.setUIScale(scale);

		wpbar.setVirtualScreenSize(virtualScreenSize);

		healthFullText = StringTable.Localize("$HEALTH_FULL");

		// Check textures
		armorTex[Armor_GasMask] 	= TexMan.CheckforTexture("HARMORG");
		armorTex[Armor_Minimal] 	= TexMan.CheckforTexture("HARMORZ");
		armorTex[Armor_Standard] 	= TexMan.CheckforTexture("HARMOR");
		armorTex[Armor_Decrement]	= TexMan.CheckforTexture("HDECRE");
		armorTex[Armor_StandardB] 	= TexMan.CheckforTexture("HARMORB");
		armorTex[Armor_GasMaskB]	= TexMan.CheckforTexture("HARMORGB");
		noHealTex = TexMan.CheckforTexture("NOHEAL");


		// Init all HUD element classes and add them to the list in sort order
		for(int x = 0; x < AllClasses.Size(); x++) {
			if( AllClasses[x] is 'HUDElementStartup' && !AllClasses[x].isAbstract() ) {
				let element = HUDElement(new(Allclasses[x])).init();
				
				if(!element) {
					Console.Printf("\c[RED]Tried to create HUD element [%s] but it could not be created!", AllClasses[x].getClassName());
					continue;
				}

				if(elements.size() == 0) {
					elements.push(element);
				} else {
					for(int y = 0; y < elements.size(); y++) {
						if(elements[y].getOrder() > element.getOrder()) {
							elements.Insert(y, element);
							break;
						} else if(y + 1 == elements.size()) {
							elements.Push(element);
							break;
						}
					}
				}
			}
		}
	}


	override void AttachToPlayer(PlayerInfo CPlayer) {
		Super.AttachToPlayer(CPlayer);

		scale = calcScreenScale(screenSize, virtualScreenSize, screenInsets);
		calcTightScreen();
        calcUltrawide();

		deathTicks = 0;

		pulseStart = MSTime();

		noDawnArmor = CPlayer.mo ? InvCount("NoDawnArmor") : false;

		wpbar.player = CPlayer;
		curWeapon = SelacoWeapon(CPlayer.readyWeapon);
		primaryAmmoAmount = secondaryAmmoAmount = -1;

		healthRegenFadeStart = -999999;
		healthRegenActive = false;
		healthRegen = 0;		

		let dplayer = Dawn(CPlayer.mo);
		if(dplayer) {
			deltaSplats = dplayer.splatCounter;
			notifDrawer.notifItem = dplayer.notifItem;
			notifDrawer.setUIScale(scale);

			let armItem = Inv("SelacoArmor");
			if(armItem) { deltaArmor = armItem.amount; }
			else { deltaArmor = 0; }
			
			deltaHealth = dplayer.health;
		}

		wpbar.setVirtualScreenSize(virtualScreenSize);
		if(saveAnim) {
			saveAnim.destroy();
			saveAnim = null;
		}

		crosshairScale = fGetCVar('crosshairscale', 1.0);
		showNametags = iGetCVar("g_displaynametags") > 0;

		GasMask mask = CPlayer.mo ? GasMask(inv('GasMask')) : null;
		hasGasMask = mask ? mask.timeEquipped : 0;
		
		if(hasGasMask > 0) {
			overlay.switchToGasMask(true, hasGasMask);
			GasHUDFrameDrawer(overlay.drawers[HUDOverlay.OV_GASMASK]).numCracks = InvCount('GasmaskCrackStage');
			HUD.AddElement('HUDElementReflection');

			// Remove insets for gas mask only
			screenInsets = (0,0);
		} else if(hasGasMask <= 0) {
			overlay.switchToGasMask(false, hasGasMask);
			HUD.RemoveElement('HUDElementReflection');
		}

		isXmas = iGetCVar("g_playChristmasEvent", 0);
		
		updatePadding();

		for(int x = 0; x < elements.size(); x++) {
			elements[x].onScreenSizeChanged(screenSize, virtualScreenSize, screenInsets);
			elements[x].onAttached(self, Dawn(CPlayer.mo));
		}

		mapOverlay.screenSizeChanged();

		// Do some preloading
		makeReady("HAMMOG");
		makeReady("HAMMOZ");
		makeReady("HAMMOE");
		makeReady("HAMMO");
		makeReady("HAMWARN");
		makeReady("HNADE");
		makeReady("HFLARE");
		makeReady("HTURRET");
		makeReady("HMINE");
		makeReady("HCAB");
		makeReady("HHPACZ");
		makeReady("HHPACU");
		makeReady("HHPACE");
		makeReady("HHPAC");
		makeReady("HRDCORE");
		makeReady("HDECRE");
		makeReady("CHEALTH");
		makeReady("BHEALTH");
		makeReady("SHEALTH");
		makeReady("PHEALTH");
		makeReady("HHEALTH");
		makeReady("GADGET");
	}


	void updatePadding() {
		let hudScale = cvHudScale > 0 ? cvHudScale : HUD_SCALING_DEFAULT;
		
		if(hasGasMask > 0) {
			// Special case for ultrawide or > 16:9 we want to limit the size of the frame stretch
			// So we need special screen padding for that situation
			if(virtualScreenSize.x > virtualScreenSize.y / GasHUDFrameDrawer.uwRatio) {
				screenPadding.left = (220.0 / hudScale) + ((virtualScreenSize.x - (virtualScreenSize.y / GasHUDFrameDrawer.uwRatio)) * 0.5);
			} else {
				screenPadding.left = 220.0 / hudScale;
			}

			//screenPadding.zero();
			screenPadding.bottom = 140.0 / hudScale;
			screenPadding.right = screenPadding.left;
			screenPadding.top = screenPadding.bottom;
		} else {
			//screenPadding.zero();
			screenPadding.bottom = 60.0 / hudScale;
			screenPadding.left = 80.0 / hudScale;
			screenPadding.right = screenPadding.left;
			screenPadding.top = screenPadding.bottom;
		}

		
	}

	override void ScreenSizeChanged() {
		Super.ScreenSizeChanged();
		calcTightScreen();
        calcUltrawide();

		updatePadding();

		int scWidth = Screen.GetWidth();
		int scHeight = Screen.GetHeight();
		
		// TODO: Unify these methods of setting scale
		overlay.ScreenSizeChanged(scale);
		notifDrawer.setUIScale(scale);
		if(saveAnim) saveAnim.setUIScale(scale);
		wpbar.SetVirtualScreenSize(virtualScreenSize);

		for(int x = 0; x < elements.size(); x++) {
			elements[x].onScreenSizeChanged(screenSize, virtualScreenSize, screenInsets);
		}

		mapOverlay.screenSizeChanged();
	}

	// 0 = left, 1 = right, 2 = back
	void dash(int direction = 2) {
		direction = CLAMP(direction, 0, 2);
		overlay.drawers[HUDOverlay.OV_DASHL + direction].SetAlpha(0.2);
		overlay.drawers[HUDOverlay.OV_DASHL + direction].SetFade(0.2);
	}

	override void Tick() {
		Super.Tick();

		bool dead = CPlayer.mo.health <= 0;

		if(automapactive) {
			// If we died, close automap
			// This can only be done from UI so it seems an appropriate place to do it
			if(dead) {
				Screen.CloseAutomap();
			} else {
				if(ticks % 70 == 0) {
					mapOverlay.loadMinimapControls();	// Check for keybind changes every so often
				}

				if(!wasAutomapActive) {
					mapOverlay.updateMinimapLegend();
				}

				mapOverlay.tick();
			}
		}
		
		wasAutomapActive = automapactive;

		let player = Dawn(CPlayer.mo);
		let readyWeapon = SelacoWeapon(CPlayer.readyWeapon);

		isInCamera = CPlayer.camera is 'CameraNew' && Level.levelnum != 99;

		// Always tick overlays FIRST. If we tick them after making changes to overlay timing (SetFade()) it could result in flicker! @cockatrice
		overlay.Tick();	
		wpbar.Tick(ticks);

		// Get ammo
		if(curWeapon) {
			ammoType1 = curWeapon.Ammo1;
			ammoType2 = curWeapon.Ammo2;

			let sWeapon = SelacoWeapon(curWeapon);
			if((!sWeapon || !sWeapon.default.hideAmmo)) {
				let primaryType = ammoType2 ? ammoType2 : ammoType1;
				let secondaryType = primaryType == ammoType1 ? NULL : ammoType1;
				primaryAmmoAmount = primaryType.Amount;

				if(player && (player.hasBottomLessMags || (sWeapon && sWeapon.hasUpgradeClass("BottomlessTrait"))) && secondaryType) {
					primaryAmmoAmount += secondaryType.Amount;
					secondaryAmmoAmount = -1;
				} else if(secondaryType) {
					secondaryAmmoAmount = secondaryType.Amount;
				} else {
					secondaryAmmoAmount = -1;
				}
			} else {
				primaryAmmoAmount = secondaryAmmoAmount = -1;
			}
		}

		if(!player) { return; }
		
		double time = MSTime() / 1000.0;

		// Check for gas Mask
		// TODO: Don't bother with inventory check Dawn.gasmaskTicks > 0
		{
			bool hadGasMask = hasGasMask > 0;
			GasMask mask = GasMask(inv('GasMask'));
			bool gotit = !!mask;

			// Swap overlay if changes are made
			if(!hadGasMask && gotIt) {
				hasGasMask = mask.timeEquipped;

				// Remove screen insets for gasmask
				scale = calcScreenScale(screenSize, virtualScreenSize, screenInsets);
				screenInsets = (0,0);
				for(int x = 0; x < elements.size(); x++) {
					elements[x].onScreenSizeChanged(screenSize, virtualScreenSize, screenInsets);
					elements[x].onAttached(self, Dawn(CPlayer.mo));
				}
				
				updatePadding();
				overlay.switchToGasMask(true, hasGasMask);
				GasHUDFrameDrawer(overlay.drawers[HUDOverlay.OV_GASMASK]).numCracks = InvCount('GasmaskCrackStage');
				HUD.AddElement('HUDElementReflection');
			} else if(hadGasMask && !gotIt) {
				hasGasMask = -level.TotalTime;

				// Restore insets after removing gasmask
				scale = calcScreenScale(screenSize, virtualScreenSize, screenInsets);
				for(int x = 0; x < elements.size(); x++) {
					elements[x].onScreenSizeChanged(screenSize, virtualScreenSize, screenInsets);
					elements[x].onAttached(self, Dawn(CPlayer.mo));
				}
				
				updatePadding();
				overlay.switchToGasMask(false, level.totalTime);
				HUD.RemoveElement('HUDElementReflection');
			} else if(hadGasMask) {
				GasHUDFrameDrawer(overlay.drawers[HUDOverlay.OV_GASMASK]).numCracks = dead ? 3 : InvCount('GasmaskCrackStage');
			}
		}
		

		if(ticks % 15 == 0) {
			noDawnArmor = InvCount("NoDawnArmor") > 0;
			isHardcore = InvCount("HardcoreMode") > 0;

			crosshairScale = fGetCVar('crosshairscale', 1.0);
			shakeAmp = fGetCVar("hud_shakefactor", 1.0);
			momentAmp = fGetCVar("hud_momentum", 1.0);
			frameAlpha = fGetCVar("g_hudopacity", 1.0);
		}

		// Check if weapon has changed
		if(CPlayer.readyWeapon != curWeapon) {
			let oldWeapon = curWeapon;
			curWeapon = SelacoWeapon(CPlayer.readyWeapon);
			changeWeaponTime = time;
			chamberEmpty = curWeapon is 'Shot_Gun' && Shot_Gun(curWeapon).ShotsLeft == 0;
			showNametags = iGetCVar("g_displaynametags") > 0;
			ammoType1 = curWeapon.Ammo1;
			ammoType2 = curWeapon.Ammo2;

			for(int x = 0; x < elements.size(); x++) {
				elements[x].onWeaponChanged(oldWeapon, curWeapon);
			}
			
		} else if(chamberEmpty && time - changeWeaponTime > 0 && curWeapon is 'Shot_Gun' && Shot_Gun(curWeapon).ShotsLeft > 0) {
			chamberEmpty = false;	// un-toggle chamber-empty warning, we only want to see it when the gun is first pulled out
		}

		// Check saving anim 
		if(saveAnim && saveAnim.hasCompleted(tmTime(0))) {
			saveAnim.destroy();
			saveAnim = null;
		}


		// Only check cvars every so often, no reason to check them every single frame
		bool isPlaying = InvCount("isPlaying") > 0;
		bool hudEnabled = iGetCVar("hud_enabled") > 0;

		shouldRender = isPlaying && hudEnabled;
		noHudMode = isPlaying && !hudEnabled;

		// Check for low ammo status
		bool hadLowAmmo = hasLowAmmo;
        hasLowAmmo = curWeapon && ammoType2 && ammoType2.amount <= curWeapon.lowAmmoThreshold && invCount("hasLowAmmo");
		if(!hadLowAmmo && hasLowAmmo) { lowAmmoStart = time; }
		showLowAmmo = hasLowAmmo ? (ticks % LOWAMMOTICKS == 0 ? !showLowAmmo : showLowAmmo) : false;

		// Calc momentum movement
		float m = CPlayer.mo.vel.z;
		deltaMomentum = momentum;
		momentum += (0.0, m);	// Add momentum from player force
		momentum *= MOMENT_DAMP;		// Dampen
		
		selfShakeFactor = (
			MAX(0.0, selfShakeFactor.x - 1.0),
			MAX(0.0, selfShakeFactor.y - 1.0)
		);	// Reduce shake factor linearly, curves looked weird

		// Check for floor impact and do a little shake
		bool onGround = CPlayer.mo.pos.Z <= CPlayer.mo.floorz;
		if(onGround && m - deltaMZ > 1.0) {
			selfShakeFactor += (frandom(-5.0, 5.0), min((m - deltaMZ), 15.0)) * 0.5 * fGetCVar("hud_impactshake");
		}
		deltaMZ = m;

		
		// Config health regen
		bool healthRegenWasActive = healthRegenActive;
		healthRegenActive = InvCount("RegenActive") > 0;
		Inventory regenItem = Inv("RegenTics");
		if(regenItem) {
			healthRegen = float(regenItem.amount) / float(regenItem.maxamount);
			if(healthRegenWasActive && !healthRegenActive) {
				healthRegenFadeStart = ticks;
			}
		}

		// Add or continue health effects if necessary
		if(player && player.health > 0 && (player.medkitHealingActive || player.healing > 0 || player.FindInventory("MedKitUsing") != null)) {
			overlay.drawers[HUDOverlay.OV_HEAL].SetAlpha(1.0);
			overlay.drawers[HUDOverlay.OV_HEAL].SetFade(1.5);
		}

		if(deltaHealth < CPlayer.health) {
			// Embiggen health
			bigHealth = BIGHEALTHTICKS;
		}

		// Check ammo to embiggen
		if(readyWeapon) {
			if(reserveAmmoType != readyWeapon.ammoType1) {
				reserveAmmoType = readyWeapon.ammoType1;
				deltaAmmo = InvCount(reserveAmmoType);
			} else {
				let curAmmo = InvCount(reserveAmmoType);
				if(deltaAmmo < curAmmo) {
					bigAmmo = BIGHEALTHTICKS;
				}
				deltaAmmo = curAmmo;
			}
		}
		

		// Update dirt and steam overlays
		if(player) {
			int dirt = MIN(3, ceil((player.dirty / float(Dawn.maxDirty)) * Dawn.dirtyLevels));
			for(int x = 1; x <= dirt; x++) {
				overlay.drawers[HUDOverlay.OV_DIRT + x - 1].SetFade(1.5);
			}

			if(player.steamy > 0) {
				double steam = double(player.steamy - 1) / double(player.maxSteamy);
				overlay.drawers[HUDOverlay.OV_STEAM].SetTargetAlpha(steam);
			}

			if(player.icy > 0) {
				overlay.drawers[HUDOverlay.OV_FROZEN].SetAlpha(1.0);
				overlay.drawers[HUDOverlay.OV_FROZEN].SetFade(2.5);
			}
		}

		// Update isZoomed vignette
		if(readyWeapon && readyWeapon.isZooming) {
			overlay.drawers[HUDOverlay.OV_ZOOM].SetAlpha(1.0);
			overlay.drawers[HUDOverlay.OV_ZOOM].SetFade(0.25);
		}

		// Activate low HP overlay
		if(player && player.isDangerState && iGetCVar("g_dangervignette") > 0) {
			overlay.drawers[HUDOverlay.OV_PAIN].SetAlpha(Inv("HardcoreMode") ? 0.35 : 1.0);
			overlay.drawers[HUDOverlay.OV_PAIN].SetFade(1.85);
		}

		// Check SPLAT overlay
		int splats = player.splatCounter;
		int numSplats = splats - deltaSplats;
		if(numSplats > 0) {
			SplatHUDDrawer(overlay.drawers[HUDOverlay.OV_SPLATS]).addSplat(min(4, numSplats));
		} else if(numSplats < 0) {
			SplatHUDDrawer(overlay.drawers[HUDOverlay.OV_SPLATS]).clearSplats();
		}
		deltaSplats = splats;

		// Dash overlay
		if(player.dash >= 0) {
			dash(player.dash);
		}
		
		// health data
		isLosingHealth = CPlayer.health < deltaHealth;
		deltaHealth = CPlayer.health;

		// If this is the first frame that our armor ran out, activate the armor break overlay
		let armItem = SelacoArmor(CPlayer.mo.FindInventory('SelacoArmor'));
		isLosingArmor = armItem && armItem.amount < deltaArmor;

		if((!armItem || armItem.amount <= 0) && deltaArmor > 0 && !dead && level.mapTime > 2) {
			deltaArmor = -1;
			overlay.drawers[HUDOverlay.OV_ARMOR].SetAlpha(1.0);
			overlay.drawers[HUDOverlay.OV_ARMOR].SetFade(1.5);
			selfShakeFactor += (frandom(13, 18), frandom(13, 18));
		} else {
			if(armItem) {
				if(deltaArmor < armItem.amount) {
					// Embiggen armor
					bigArmor = BIGHEALTHTICKS;
				}

				deltaArmor = armItem.amount;
				isHeavyArmor = armItem.amount >= armItem.heavyArmorThreshold;
				int armorValue = isHeavyArmor ? armItem.HeavyArmorAbsorption : armItem.LightArmorAbsorption;
				armorReductionString = String.Format("%d%%", armorValue);
			} else {
				deltaArmor = -1;
				isHeavyArmor = false;
			}
		}

		// Death
		if(dead && level.mapTime > 2) {
			deathTicks++;

			if(isLosingHealth) {
				overlay.drawers[HUDOverlay.OV_PAIN].SetAlpha(1.0);
				overlay.drawers[HUDOverlay.OV_PAIN].SetFade(1.5);

				// Remove armor break overlay if present
				overlay.drawers[HUDOverlay.OV_ARMOR].SetAlpha(0);
				overlay.drawers[HUDOverlay.OV_ARMOR].SetFade(0);
			}
			
			overlay.drawers[HUDOverlay.OV_DEATH].SetAlpha(1.0);
			overlay.drawers[HUDOverlay.OV_DEATH].SetFade(100);
		}


		bigHealth = MAX(bigHealth - 1, 0);
		bigArmor = MAX(bigArmor - 1, 0);
		bigAmmo = MAX(bigAmmo - 1, 0);

		
		notifDrawer.tick();
		
		for(int x = 0; x < elements.size(); x++) {
			if(elements[x].tick()) {
				elements.delete(x);
				x--;
			}
		}

		ticks++;
	}


	double calcCrosshairHeight() {
		let element = HUDElementCrosshair(FindElement('HUDElementCrosshair'));
		if(element) return element.getCrosshairHeight();

		return 0;
	}


	protected void ResetPulse() {
		pulseStart = MSTime();
	}

	double tmTime(double tm) {
		return (tm + double(ticks)) * ITICKRATE;
	}

	// TODO: Stop using MSTime and start using tm time
	double getTime() {
		return (System.GetTimeFrac() + double(ticks)) * ITICKRATE;
	}

	override void Draw (int state, double tm) {
		//Super.Draw (state, tm);

		if(automapactive) {
			mapOverlay.drawMinimapOverlay();
			return;
		}

		if(isMuted || isInCamera) { return; }

		let player = Dawn(CPlayer.mo);
		let time = tmTime(tm);

		// Calc pulse
		globalPulse = UIMath.EaseInOutCubicF(abs(sin((MSTime() - pulseStart) * 0.25)));
		
		// Calc shake
		// TODO: Remove Noise3D and replace with Noise2D or 1D and just offset by time to avoid patterns
		float shakeX = player ? player.shakeForceX : 0;
		float shakeY = player ? player.shakeForceY : 0;
		shakeX += selfShakeFactor.x;
		shakeY += selfShakeFactor.y;

		double ff = double(MSTime()) / 100.0;
		double xx = noise.noise3D(ff * 2, 1.0, 1.0) * MIN(shakeX, 5.0);
		double yy = noise.noise3D(1.0, ff * 2, 1.0) * MIN(shakeY, 5.0);

		shake = (xx, yy) * 4.3 * shakeAmp;

		// Calc camera momentum (Vertical only for now)
		Vector2 fmoment = UIMath.LerpV(deltaMomentum, momentum, tm) * MOMENT_MULT;
		fmoment.y = clamp(fmoment.y, -MOMENT_MAX, MOMENT_MAX);
		
		currentOffset = ((shake * VISOR_SHAKE_MULT) + (fmoment * VISOR_MOMENT_MULT * momentAmp)) * scale;

		
		if(noHudMode && !Menu.GetCurrentMenu()) {
			BeginHUD();
			
			overlay.drawers[HUDOverlay.OV_HUD].alpha = (CPlayer.health <= 0 || noDawnArmor || noHudMode) ? 0 : frameAlpha;
			overlay.Draw(tm, ((shake * VISOR_SHAKE_MULT) + (fmoment * VISOR_MOMENT_MULT * momentAmp)) * scale);

			//player.drawHitmarker(scale, crosshairScale);
			DrawNoHudHudHudHud(tm);
		} else if(shouldRender && (state == HUD_StatusBar || state == HUD_Fullscreen) && !Menu.GetCurrentMenu() && CPlayer.health > 0) {
			BeginHUD();

			Vector2 hudMoment = fmoment * 1.2 * momentAmp;

			// Draw elements that belong under the overlays
			for(int x = 0; x < elements.size(); x++) {
				if(elements[x].order < 0) elements[x].draw(tm, 1.0, hudMoment, shake);
				else break;	// Should be in order, so nothing below 0 should be left
			}

			overlay.drawers[HUDOverlay.OV_HUD].alpha = (noDawnArmor || noHudMode) ? 0 : frameAlpha;
			overlay.Draw(tm, ((shake * VISOR_SHAKE_MULT) + (fmoment * VISOR_MOMENT_MULT * momentAmp)) * scale);

			double flickerTM = 1;
			if(hasGasMask != 0) {
				let time = max(((level.totalTime - abs(hasGasMask)) * ITICKRATE) - 1.65, 0);
				flickerTM = time / 0.3;
			}

			// Add flicker to elements from putting gasmask on
			if(flickerTM >= 1.0 || frandom(0, 100) <= flickerTM * 100.0) {
				player.drawHitmarker(scale, crosshairScale);
				DrawFullScreen(tm, hudMoment);

				wpbar.Draw(ticks, tm, alpha, (shake * WPBAR_SHAKE_MULT) + (fmoment * momentAmp * WPBAR_MOMENT_MULT));
			}
			
			// Slowly transitioning elements to be unique classes
			double elementAlpha = 1.0;
			for(int x = 0; x < elements.size(); x++) {
				if(elements[x].order >= 0) {
					if(flickerTM < 1.0) elementAlpha = frandom(0, 100) <= flickerTM * 100.0 ? 1.0 : 0;
					elements[x].draw(tm, elementAlpha, hudMoment, shake);
				}
			}

			if(saveAnim) saveAnim.draw(time);
			notifDrawer.draw(tm, (shake * 0.4) + (fmoment * momentAmp * 0.5), saveAnim != null);
		} else if(CPlayer.health <= 0) {
			DrawDeathHud(tm, fmoment * 1.2 * momentAmp);

			overlay.drawers[HUDOverlay.OV_HUD].alpha = 0;
			overlay.Draw(tm, ((shake * VISOR_SHAKE_MULT) + (fmoment * VISOR_MOMENT_MULT * momentAmp)) * scale);
		}

		// WIP
		DrawImgAdvanced("HWIP", (0, 7), DR_SCREEN_HCENTER | DR_IMG_HCENTER);
	}

	protected void DrawDeathHud(double tm, Vector2 fmoment) {
		double fade = UIMath.EaseOutCubicf(MIN(1.0, (deathTicks + tm) / 10.0));
		Dim(0xFF88000000, fade * 0.38, 0, 0, ceil(virtualScreenSize.x), ceil(virtualScreenSize.y), DR_IGNORE_INSETS);
	}

	protected int DrawXtraCount(string inv, string img, int count, Vector2 pos, bool force = false, bool selected = false, bool drawSelFrame = false) {
		let i = CPlayer.mo.FindInventory(inv); // TODO: I don't like doing this multiple times per frame, cache these
		if(force || i) {
			int numAmmo = i ? i.Amount : count;
			if(selected) {
				if(hasGasMask > 0) DrawImgCol(img, pos, 0xFFFFFFFF, DR_SCREEN_BOTTOM|DR_SCREEN_RIGHT, desaturate: 255);
				else DrawImgCol(img, pos, 0xFF898989, DR_SCREEN_BOTTOM|DR_SCREEN_RIGHT, desaturate: 255);

				if(drawSelFrame) DrawImgCol("GADGET", pos, 0xFFFFFFFF, DR_SCREEN_BOTTOM|DR_SCREEN_RIGHT, 1.0, desaturate: 255);
			} else if(hasGasMask > 0) {
				DrawImgCol(img, pos, 0xFF00D786, DR_SCREEN_BOTTOM|DR_SCREEN_RIGHT, desaturate: 255);
			} else {
				DrawImg(img, pos, DR_SCREEN_BOTTOM|DR_SCREEN_RIGHT);
			}
			
			DrawStr(numFont, FormatNumber(numAmmo, 1), (pos.x + 16, pos.y + XTRAHALFHEIGHT - halfNumFontHeight), DR_SCREEN_BOTTOM|DR_SCREEN_RIGHT , selected ? Font.CR_WHITE : (hasGasMask > 0 ? 0xFF00D786 : 0xFF3C4559), textOpacity * 0.9 * alpha);
			return 1;
		}
		return 0;
	}

	// How many times can you put hud in a function name?
	protected void DrawNoHudHudHudHud(double tm) {
		// Draw hardcore indicator
		if(isHardcore) {
			DrawImg("HRDCORE", (isTightScreen ? -80 : -115, 50), DR_SCREEN_RIGHT, 1.0);
		}

		if(isXmas) {
			DrawImg("XMASBDGE", (-115 - (isHardcore ? 64 : 0), 50), DR_SCREEN_RIGHT, 1.0);
		}
	}

	protected void DrawFullScreen(double tm, Vector2 fmoment) {
		double time = MSTime() / 1000.0;
		double atm = 1.0 - tm;
		double timeFrac = System.GetTimeFrac();

		let player = Dawn(CPlayer.mo);

		if(!player) return;
		
		let hudScale = cvHudScale > 0 ? cvHudScale : HUD_SCALING_DEFAULT;
		

		double BASELINE = -(screenPadding.bottom + (hasGasMask > 0 ? 90 : 105.0));
		double hPadding = screenPadding.left + (hasGasMask > 0 ? 60 : 90);

		Vector2 tmoment = (
			clamp(fmoment.x * 1.05, fmoment.x - 2.0, fmoment.x + 2.0), 
			clamp(fmoment.y * 1.05, fmoment.y - 2.0, fmoment.y + 2.0)
		);

		Vector2 shfm = fmoment + shake;	// Frame shake + momentum
		Vector2 shtm = tmoment + shake;	// Text shake + momentum

		double healthOffset = hPadding;
		double medkitNoUsePct = 0.0;

		// Draw health
		{
			float sc = bigHealth > 0 ? 1.0 + (((bigHealth + atm) / BIGHEALTHTICKS) * BIGHEALTHSCALE) : 1.0;
			float soff = (bigNumFontHeight - (bigNumFontHeight * sc)) * 0.5;
			
			// Only draw health frame if we have DawnArmor
			string healthImage;

			if(hasGasMask > 0) healthImage = "HHEALTHG";
			else healthImage = noDawnArmor ? "HHEALTHZ" : (player.medkitHealingActive ? (CPlayer.health < 35 ? "CHEALTH" : "BHEALTH") : (CPlayer.health > CPlayer.mo.GetMaxHealth(true) ? "SHEALTH" : (CPlayer.health < 35 ? "PHEALTH" : "HHEALTH")));

			if(hasGasMask) DrawImgCol(healthImage, (healthOffset, BASELINE) + shfm, isLosingArmor ? 0xAAFF2222 : 0, DR_SCREEN_BOTTOM);
			else DrawImg(healthImage, (healthOffset, BASELINE) + shfm, DR_SCREEN_BOTTOM);
			DrawStr(bigNumFont, 
					FormatNumber(CPlayer.health, 3), 
					(healthOffset + 110, BASELINE + 22 + soff) + shtm, 
					DR_SCREEN_BOTTOM | DR_TEXT_RIGHT, 
					!healthRegenActive && player.isDangerState && floor(ticks / 15) % 2 == 0 ? 0xFFD72828 : Font.CR_WHITE, 
					textOpacity, 
					scale: (sc, sc)
			);

			// Draw medkit healing amount if medkit is active
			if(player.medkitHealingActive) {
				let hkPos = (healthOffset + 6, BASELINE - 33 + 11 - 33);

				DrawStr(numFont, 
						String.Format("+%dHP", player.healingAmountTarget), 
						(hkPos.x, hkPos.y + XTRAHALFHEIGHT - halfNumFontHeight) + shfm, 
						DR_SCREEN_BOTTOM,
						Font.CR_GREEN,
						textOpacity * 0.9 * alpha
				);
			}

			// Draw medkit no-use graphic
			if(!player.medkitHealingActive && player.medkitLastFailure != 0 && Level.totalTime - player.medkitLastFailure < 35) {
				double a = UIMath.EaseOutCubicf( clamp(1.0 - ((double(Level.totalTime - player.medkitLastFailure) + timeFrac) / 30.0), 0.0, 1.0) );
				medkitNoUsePct = a;
				
				if(player.medkitFailureType == Dawn.Medkit_FullHealth) {
					let hkPos = (healthOffset + 6, BASELINE - 33 + 11 - 33);
					
					DrawStr(numFont, 
							healthFullText, 
							(hkPos.x, hkPos.y + halfNumFontHeight) + shfm, 
							DR_SCREEN_BOTTOM,
							hasGasMask > 0 ? 0xFF00D786 : Font.CR_GREEN,
							textOpacity * 0.9 * alpha * a
					);
				} else {
					let crosshairHeight = calcCrosshairHeight();
					let vpos = /*curWeapon && curWeapon.activeCrosshair ? (curWeapon.activeCrosshair.getHeight() / (screenSize.y / virtualScreenSize.y))*/ crosshairHeight != 0 ? crosshairHeight + 45 : 125;
					DrawTexAdvanced(noHealTex, (0, vpos) + shfm, DR_SCREEN_HCENTER | DR_SCREEN_VCENTER | DR_IMG_HCENTER, a: a);
				}
			}

			// Draw red over health if we are being hit
			if(!noDawnArmor && isLosingHealth && hasGasMask <= 0) DrawImg("HDECRE", (healthOffset, BASELINE) + shfm, DR_SCREEN_BOTTOM);

			// Draw health regen
			// TODO: Use CVAR to control wether or not this rebuilds at framerate or at tickrate (optimization)
			uint ute = ticks - healthRegenFadeStart;
			if(TexMan.MakeReady(healthRegenDrawer.tex) && !noDawnArmor && hasGasMask <= 0 && (healthRegenActive || ute < 15 || (healthRegen > 0.001 && healthRegen < 0.999))) {
				int col = 0xFF2828D7;
				float alpha = 1.0;
				healthRegenDrawer.degreesStart = 50 + ((310 - 50) * healthRegen + tm);
				
				if(ute < 15 || healthRegenActive) {
					alpha = healthRegenActive ? 1.0 : (1.0 - MIN((float(ute) + tm) / 15.0, 1.0));
					col = 0xFF50EA6E;
					healthRegenDrawer.degreesStart = 50;
				}

				let regenPos = (healthOffset + 102 + shfm.x, BASELINE - 10 + shfm.y);
				adjustXY(regenPos.x, regenPos.y, DR_SCREEN_BOTTOM);
				regenPos *= scale;
				//((healthOffset + 102 + shfm.x) * scale, screenSize.y + ((BASELINE - 10 + shfm.y) * scale))

				healthRegenDrawer.degreesEnd = 310;
				healthRegenDrawer.Build();
				healthRegenDrawer.Draw(regenPos, (110, 110) * scale, 180, alpha, col);
			}
		}

		// Weapon offset pos 
		double weaponOffset = -(hPadding + 223);

		// Draw weapon info
		if(showNametags && !isTightScreen && curWeapon && time - changeWeaponTime < WEAPON_DISPLAYTIME + 1.0) {
			Font fnt = "PDA13FONT";
			double wTime = time - changeWeaponTime;
			double alpha = wTime <= WEAPON_DISPLAYTIME ? 1 : 1.0 - ((wTime - WEAPON_DISPLAYTIME) / 1.0);
			string n = curWeapon.getTag();
			double vLine = 23 - (max(0, curWeapon.activeUpgrades.size() - 3) * fnt.getHeight());
			
			//n = n.filter();
			DrawStr("SEL16FONT", n, (weaponOffset - 20, BASELINE + vline) + shtm, DR_SCREEN_BOTTOM | DR_SCREEN_RIGHT | DR_TEXT_RIGHT, hasGasMask > 0 ? 0xFF00D786 : 0xFFb0c6f7, textOpacity * alpha, monoSpace: false);
			
			if(!(curWeapon is "Fists") && !(curWeapon is "Fire_Extinguisher")) {
				// This is a mess, but it's what is necessary for now
				bool upgradesFound;
				vline += 20;

				if(curWeapon.activeUpgrades.size() > 0) {
					for(int x = 0; x < curWeapon.activeUpgrades.size(); x++) {
						if(curWeapon.activeUpgrades[x] && !(curWeapon.activeUpgrades[x] is 'WeaponStats')) {
							DrawStr(fnt, StringTable.Localize(curWeapon.activeUpgrades[x].upgradeNameShort) .. " •", (weaponOffset - 20, BASELINE + vLine) + shtm, DR_SCREEN_BOTTOM | DR_SCREEN_RIGHT | DR_TEXT_RIGHT, Font.CR_WHITE, textOpacity * alpha, monoSpace: false);
							vline += fnt.getHeight();
							upgradesFound = true;
						}
					}
				} else {
					DrawStr(fnt, "No upgrades installed •", (weaponOffset - 20, BASELINE + 43) + shtm, DR_SCREEN_BOTTOM | DR_SCREEN_RIGHT | DR_TEXT_RIGHT, Font.CR_WHITE, textOpacity * alpha, monoSpace: false);
				}
			}
		}

		// Only draw ammo counts if the weapon supports it
		let sWeapon = SelacoWeapon(curWeapon);
		if(curWeapon && (!sWeapon || !sWeapon.default.hideAmmo)) {
			// Draw ammo frame if there is any ammo at all
			if(primaryAmmoAmount > -1 || secondaryAmmoAmount >= -1) {
				DrawImg(hasGasMask > 0 ? "HAMMOG" : (noDawnArmor ? "HAMMOZ" : (hasLowAmmo ? "HAMMOE" : "HAMMO")), (weaponOffset, BASELINE) + shfm, DR_SCREEN_BOTTOM|DR_SCREEN_RIGHT);
			}

			/*let primaryType = ammoType2 ? ammoType2 : ammoType1;
			let secondaryType = primaryType == ammoType1 ? NULL : ammoType1;
			let primaryAmount = primaryType.Amount;

			// Draw current clip
			if(primaryType) {
				DrawStr(bigNumFont, FormatNumber(primaryType.Amount, 2), (weaponOffset + 82, BASELINE + 22) + shtm, DR_SCREEN_BOTTOM | DR_SCREEN_RIGHT | DR_TEXT_RIGHT, hasLowAmmo ? 0xFFD72828 : Font.CR_WHITE, textOpacity * alpha);
			}
			
			// Draw reserve ammo
			if(secondaryType) {
				float sc = bigAmmo > 0 ? 1.0 + (((bigAmmo + atm) / BIGHEALTHTICKS) * BIGHEALTHSCALE) : 1.0;
				float soff = bigAmmo == 1.0 ? 0 : (numFontHeight - (numFontHeight * sc)) * 0.5;
				DrawStr(numFont, FormatNumber(secondaryType.Amount, 2), (weaponOffset + 132, BASELINE + 49 + soff) + shtm, DR_SCREEN_BOTTOM | DR_SCREEN_RIGHT | DR_TEXT_RIGHT, hasLowAmmo ? 0xFFD72828 : Font.CR_DARKGRAY, textOpacity * 0.9 * alpha, scale: (sc * (secondaryType.Amount > 99 ? 0.91 : 1), sc));
			}

			// Draw ammo warning
			if(!noDawnArmor && showLowAmmo && time - lowAmmoStart < 8) {
				double a = 1.0;
				if(time - lowAmmoStart >= 5.0) { a *= 1.0 - ((time - lowAmmoStart - 5.0) / 1.55); }	// Fade out...
				DrawImg("HAMWARN", (weaponOffset + 185, BASELINE - 11) + shtm, DR_SCREEN_BOTTOM | DR_SCREEN_RIGHT, a: 0.9 * a * alpha);
			}*/

			if(primaryAmmoAmount > -1) {
				DrawStr(bigNumFont, FormatNumber(primaryAmmoAmount, 2), (secondaryAmmoAmount < 0 ? weaponOffset + 120 : weaponOffset + 82, BASELINE + 22) + shtm, DR_SCREEN_BOTTOM | DR_SCREEN_RIGHT | DR_TEXT_RIGHT, hasLowAmmo ? 0xFFD72828 : Font.CR_WHITE, textOpacity * alpha);
			}

			if(secondaryAmmoAmount > -1) {
				float sc = bigAmmo > 0 ? 1.0 + (((bigAmmo + atm) / BIGHEALTHTICKS) * BIGHEALTHSCALE) : 1.0;
				float soff = bigAmmo == 1.0 ? 0 : (numFontHeight - (numFontHeight * sc)) * 0.5;
				DrawStr(numFont, FormatNumber(secondaryAmmoAmount, 2), (weaponOffset + 132, BASELINE + 49 + soff) + shtm, DR_SCREEN_BOTTOM | DR_SCREEN_RIGHT | DR_TEXT_RIGHT, hasLowAmmo ? 0xFFD72828 : Font.CR_DARKGRAY, textOpacity * 0.9 * alpha, scale: (sc * (secondaryAmmoAmount > 99 ? 0.91 : 1), sc));
			}

			// Draw ammo warning
			if(!noDawnArmor && showLowAmmo && time - lowAmmoStart < 8) {
				double a = 1.0;
				if(time - lowAmmoStart >= 5.0) { a *= 1.0 - ((time - lowAmmoStart - 5.0) / 1.55); }	// Fade out...
				DrawImg("HAMWARN", (weaponOffset + 185, BASELINE - 11) + shtm, DR_SCREEN_BOTTOM | DR_SCREEN_RIGHT, a: 0.9 * a * alpha);
			}
		}


		// Draw Cabinet cards and grenades
		if(!noDawnArmor) {
			// Draw Cabinet Cards
			DrawXtraCount("CabinetCardCount", "HCAB", 0, (weaponOffset, BASELINE - 33 + 11) + shfm);

			let dplayer = Dawn(CPlayer.mo);
			int selectedGrenade = dplayer.equippedthrowable.grenadeOrder;

			// Draw grenade counts
			int grenadeLeft = weaponOffset + 70;

			double vLevel = 33;
			vLevel += DrawXtraCount("HandGrenadeAmmo",	"HNADE", 	0, (grenadeLeft, BASELINE - vLevel + 11) + shfm, true,  selectedGrenade == 0, true)  * 35;
			vLevel += DrawXtraCount("IceGrenadeAmmo", 	"HFLARE", 	0, (grenadeLeft, BASELINE - vLevel + 11) + shfm, false, selectedGrenade == 1, true) * 35;
			vLevel += DrawXtraCount("MineAmmo", 		"HMINE", 	0, (grenadeLeft, BASELINE - vLevel + 11) + shfm, false, selectedGrenade == 2, true) * 35;
			//Vector2 selPos = (-grenadeLeft, BASELINE - 33 + 11 - double(35 * selectedGrenade)) + shfm;

			// Draw selection frame for grenade
			//DrawImgCol("GADGET", selPos, 0xFFFFFFFF, DR_SCREEN_BOTTOM|DR_SCREEN_RIGHT, 1.0, desaturate: 255);
		}
		

		// Draw health kit count
		let hk = CPlayer.mo.FindInventory("MedkitCount");
		if(hk && hk.Amount > 0) {
			let hkPos = (healthOffset + 6, BASELINE - 33 + 11);
			bool isEmpty = hk.Amount == 0;	// This won't happen anymore

			let txtcol = hasGasMask > 0 ? 0xFFFFFFFF : (player.medkitHealingActive || medkitNoUsePct > 0.35 ? Font.CR_GREEN : (isEmpty  ? Font.CR_RED : Font.CR_DARKGRAY));

			if(hasGasMask > 0) DrawImgCol(noDawnArmor ? "HHPACZ" : (player.medkitHealingActive ? "HHPACU" : (isEmpty ? "HHPACE" : "HHPAC")), hkPos + shfm, 0xFF00D786, DR_SCREEN_BOTTOM, desaturate: 255);
			else DrawImg(noDawnArmor ? "HHPACZ" : (player.medkitHealingActive || medkitNoUsePct > 0.35 ? "HHPACU" : (isEmpty ? "HHPACE" : "HHPAC")), hkPos + shfm, DR_SCREEN_BOTTOM);
			
			DrawStr(numFont, FormatNumber(hk.Amount, 1), (hkPos.x + 36, hkPos.y + XTRAHALFHEIGHT - halfNumFontHeight) + shfm, DR_SCREEN_BOTTOM, txtCol, textOpacity * 0.9 * alpha);
		}
		

		// Draw armor
		let armor = SelacoArmor(CPlayer.mo.FindInventory("SelacoArmor"));
		if (armor != null && armor.Amount > 0) {
			float armorOffset = healthOffset + (hasGasMask > 0 ? 220 : 280);
			float sc = bigArmor > 0 ? 1.0 + (((bigArmor + atm) / BIGHEALTHTICKS) * BIGHEALTHSCALE) : 1.0;
			float soff = (bigNumFontHeight - (bigNumFontHeight * sc)) / 2.0;
			
			TextureID armorImage;
			if(hasGasMask > 0) armorImage = isHeavyArmor ? armorTex[Armor_GasMaskB] : armorTex[Armor_GasMask];
			else armorImage = noDawnArmor ? armorTex[Armor_Minimal] : (isHeavyArmor ? armorTex[Armor_StandardB] : armorTex[Armor_Standard]);
			if(hasGasMask) DrawTexCol(armorImage, (armorOffset, BASELINE) + shfm, isLosingArmor ? 0xAAFF2222 : 0, DR_SCREEN_BOTTOM);
			else DrawTex(armorImage, (armorOffset, BASELINE) + shfm, DR_SCREEN_BOTTOM);
			if(!noDawnArmor && isLosingArmor && hasGasMask <= 0) { DrawTex(armorTex[Armor_Decrement], (armorOffset, BASELINE) + shfm, DR_SCREEN_BOTTOM); }
			
			DrawStr(bigNumFont, FormatNumber(armor.amount, 3), (armorOffset + 110, BASELINE + 22 + soff) + shtm, DR_SCREEN_BOTTOM | DR_TEXT_RIGHT, Font.CR_WHITE, textOpacity, scale: (sc, sc));
			
			// Draw absorption amount
			if(!noDawnArmor) DrawStr(tinyFont, armorReductionString, (armorOffset + 95, BASELINE + 84) + shtm, DR_SCREEN_BOTTOM | DR_TEXT_VCENTER, hasGasMask > 0 ? 0xFF00895A : 0xFF3C4559, textOpacity, monoSpace: false, scale: (0.8, 0.8));
		}


		// Draw timer
		let showtime = iGetCVar("hud_showtime");
		if(showtime > 0) {
			uint totalTime = player.ticks;

			if(totalTime > 0) {
				string stime = CommonUI.getTimeString(totalTime);
				DrawStr(numFont, stime, (0, 130) + shtm, DR_SCREEN_HCENTER | DR_TEXT_HCENTER, Font.CR_WHITE, textOpacity);
			}
		}

		// Draw hardcore indicator
		if(isHardcore) {
			DrawImg("HRDCORE", (isTightScreen ? -80 : -115, 50) + (shfm * 0.65), DR_SCREEN_RIGHT, 1.0);
		}

		if(isXmas) {
			DrawImg("XMASBDGE", ((isTightScreen ? -80 : -115) - (isHardcore ? 64 : 0), 50)  + (shfm * 0.65), DR_SCREEN_RIGHT, 1.0);
		}
	}
}