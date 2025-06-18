
enum FootstepFlags {
    FSF_SCRIPTEDFOOTSTEP      	= 0x1,		// Soldier movement is scripted, they dont need to check for speed.
	FSF_PLAYERONLY				= 0x2, 		// More 'expensive' effects should be exclusive to the player, like additional water splashes.
	FSF_ZOMBIESTEP				= 0x3,		// Zombies!
}


const FOOTSTEP_SPEED = 53; 			// Threshold to reach before a footstep sound registers. Lower means more frequent
const SWIMMING_SPEED = 125;			// Threshold to reach before a swimming sound plays. Lower means more frequent
const MAX_ACTOR_DISTANCE = 50; 		// CURRENTLY UNUSED - Actor distance to check for with every footsteps
const FOOTPRINT_LENGTH = 20; 		// How long do we want footprints to last?
const FOOTPRINT_SIDE_OFFSET = 6;	// Left and Right offsets for footprints
const FLOOR_GRACE_DISTANCE = 12; 	// How far should be player be removed from a floor before a footstep is denied? This prevents 'step skipping'
const GEAR_SOUND_CHANCE = 4; 		// Chance to play a Gear Foley sound when walking
const FOOTSLIDE_SOUND_CHANCE = 5; 	// Chance to play a Foot Slide sound when walking
const WATER_SOUND 	= "step/water";	// What sound is used when the player walks on a water surface

mixin class Footsteps
{

    int counter, gearSound, playedSound;
	int zombiePrints;
	int wetPrints, slimePrints, bloodPrints;
	string soundFile, footprintActor;
	float actorSpeed, distanceTraveled, footstepVolume;
	bool onRainWater;
	int gameDetail;
	int passiveStepTick; // Ticks that this footstep is considered valid, used for passive collision actors to play footstep sounds
						 // passive actors will subtract from this when they play a footstep sound to prevent more sounds

    void doFootstep(int flags = 0, double volume = 1.0)
    {
		if(passiveStepTick) passiveStepTick--;

		LevelEventHandler leh = LevelEventHandler.instance();
		gameDetail = leh.gameDetailSetting;

		// Increase based on footstep velocity. Walking faster brings you faster to the required traveling distance.
		soundFile = getDefaultFootstep();
		actorSpeed = sqrt((vel.length() - abs(vel.z))*4);

		// It all matters equally underwater.
		if(waterLevel == 3) {
			actorSpeed = vel.length();

		}
		isStandingOnVehicle();

        // Check if a footstep should be played
        if (shouldSkipFootstep(flags)) {
            return;
        }

		bool shouldPlayFootstep = false;

		if (waterLevel <= 2 && distanceTraveled >= FOOTSTEP_SPEED) {
			shouldPlayFootstep = true;
		}
		else if (waterLevel >= 3 && distanceTraveled >= SWIMMING_SPEED) {
			shouldPlayFootstep = true;
		}
		else if ((flags & FSF_SCRIPTEDFOOTSTEP) != 0) {
			shouldPlayFootstep = true;
		}
		
	    // All conditions have been fullfilled, start the footstep
		if (shouldPlayFootstep) {
			passiveStepTick = 1;

			// Set up parameters for the Playsound
			soundFile = getFootstepSound(flags);
			footstepVolume = getFootstepVolume(flags, actorSpeed);

			doFootstepEffect();

			// if the player *HAS* armor [We have to rename this at some point]
			if(countinv("NoDawnArmor") == 0)
			{
				// check if we should play a gear foley sound or not
				playGearSoundEffect(GEAR_SOUND_CHANCE);

				// check if we should play a 'foot slide' sound effect.
				playFootSlideSoundEffect(FOOTSLIDE_SOUND_CHANCE);
			}

			// If Dawn stands on an object, use Linetrace to confirm.
			if(isStandingOnVehicle())
			{
				FLineTraceData RemoteRay;
				LineTrace(0,30, 90,offsetz: 10,offsetforward:0, data: RemoteRay);
				if (RemoteRay.HitType == TRACE_HitActor && RemoteRay.HitActor is "VehicleHitbox")	{
					soundFile = "step/car";
				}
			}

			if(waterLevel >= 3) {
				DartPlayer();
			}

			// Pedo-meter
			if(FSF_PLAYERONLY)
			{
				Stats.AddStat(STAT_STEP_COUNTER, 1, 0);
			}

			if(flags == FSF_ZOMBIESTEP)
			{
				soundFile = "step/catwalk";
				footstepVolume = 0.3;
				doZombieThings();
			}

			// We now have a sound, play it!
            distanceTraveled = 0;
            A_PLAYSOUND(soundFile, CHAN_AUTO, volume:footstepVolume, 0, 0.85, pitch:frandom(0.95,1.05));
        }
    }


	virtual void DartPlayer() {
		vector3 thrustDir;
		thrustDir.x = cos(pitch) * cos(angle);
		thrustDir.y = cos(pitch) * sin(angle);
		thrustDir.z = -sin(pitch);
		
		float mag = sqrt(thrustDir.x * thrustDir.x + thrustDir.y * thrustDir.y + thrustDir.z * thrustDir.z);
		if (mag > 0.001)
		{
			thrustDir.x /= mag;
			thrustDir.y /= mag;
			thrustDir.z /= mag;
		}
		
		
		// Scale the thrust and apply
		float boostStrength = 2.5; // Amount to boost. I think this amount works well. edit: I already editted this twice so I'm wrong
		vel += thrustDir * boostStrength;

		// Spawn some water
		for(int i=-35; i<=35;i+=3) {
			A_SpawnDefinedParticle("UnderWaterDartParticle", random(5, 8), 0, frandom(5,35), frandom(1.5,2.4), 0, frandom(-0.5,0.5), angle:i);
		}
	}

	// ADDITIONAL FOOTSTEP SOUNDS
	void playGearSoundEffect(int chance)
	{
		if(random(0,100) <= chance)
		{
			A_PlaySound("step/gear", CHAN_AUTO, footstepVolume+0.1);
		}
	}

	void playFootSlideSoundEffect(int chance)
	{
		if(random(0,100) <= chance)
		{
			A_PlaySound("step/footslide", CHAN_AUTO, footstepVolume);
		}
	}

	void playWaterSoundEffect() {
		A_PlaySound("step/footslide", CHAN_AUTO, footstepVolume);
	}

	// We want barefoot sounds when Dawn is barefoot
	string getDefaultFootstep()
	{
		if(countinv("NoDawnArmor") == 1)
		{
			return "step/barefoot";
		}
		return "step/default";
	}

	// Cars produce a sound effect
	bool isStandingOnVehicle()
	{
		if(bOnMobj && pos.z - floorz >= 20 && vel.z == 0)
		{
			return true;
		}

		return false;
	}

	void doZombieThings()
	{
		if(zombiePrints <= 0)
		{
			zombiePrints = 10;
		}
		zombiePrints--;
		A_PLAYSOUND("step/blood", CHAN_AUTO, 0.3, 0, 1.0, pitch:1.2);
		// Zombies always spawn footprints, but they despawn faster.
		spawnFootprintFX("BloodyFootprintZombie", zombiePrints);
	}

	// Spawns footprint sprites
	void spawnFootprintFX(string actorName, int printAmount)
	{
		string leftActor = actorName;
		string rightActor = actorName;

		leftActor.AppendFormat("Left");
		rightActor.AppendFormat("Right");

		bool spawnLeft = printAmount % 2 == 0;
		string footprintType = spawnLeft ? leftActor : rightActor;
		int spawnOffset = spawnLeft ? FOOTPRINT_SIDE_OFFSET : -1*FOOTPRINT_SIDE_OFFSET;

    	A_SpawnItemEx(footprintType, 0, spawnOffset);
	}

	// Conditions to see if the step should proceed or not.
    bool shouldSkipFootstep(int flags) {
        // Scripted footsteps always play
        if ((flags & FSF_SCRIPTEDFOOTSTEP) != 0) {
            return false;
        }

        // Don't play footstep sound when jumping, falling, or Sliding
        if ((!isStandingOnVehicle() && pos.z - floorz > FLOOR_GRACE_DISTANCE && waterLevel <= 2) || (countInv("SlideScriptActive") == 1 || actorSpeed < 1)) {
            distanceTraveled = 0;
            return true; // Deny footstep
        }

        // Only play footstep sound when player is moving fast enough
        distanceTraveled += actorSpeed;
        if (distanceTraveled < FOOTSTEP_SPEED) {
            return true;
        }

        return false;
    }

    string getFootstepSound(int flags) 
	{
		if(waterLevel > 0) {
			handleWaterSteps();
		}

		if(waterLevel == 0) {
			// If the character recently walked over liquids, spawn footprints.
			if(wetPrints > 0)
			{
				spawnFootprintFX("WateryPrint", wetPrints);
				wetprints--;
				if(!onRainWater)
				{
					A_PlaySound("step/wetfoot", CHAN_AUTO, 0.5);
				}
			}
			if(bloodPrints > 0)
			{
				slimePrints = 0;
				spawnFootPrintFX("BloodyFootprint", bloodPrints);
				bloodPrints--;
			}
			if(slimePrints > 0)
			{
				bloodPrints = 0;
				spawnFootPrintFX("SlimeyPrint", slimePrints);
				slimeprints--;
			}
		} else if(waterLevel == 3) {
			return "FOOTSTEP/SWIMMING";
		}

		// Not being suited up plays a barefoot at all times.
		if(countinv("NodawnArmor") == 1)
		{
			return "step/barefoot";
		}

		// Determine sound type based on floorpic
		uint soundType = MaterialIndexer.Instance().getFloorMaterialType(floorpic);
		if(soundType > 0) {
			//console.printf("FLOOR TYPE: %s", footStepSoundList[soundType - 1]);
			return footStepSoundList[soundType - 1];
		}

		// TO-DO: Mechs and Juggernauts should also be here.
        if ((flags & FSF_SCRIPTEDFOOTSTEP) != 0) {
            return "STEP/ENEMYSOLDIER";
        }

        // Use default footstep sound
        return "step/default";
    }

	void doFootstepEffect() {
		if(gameDetail <= GAMEDETAIL_LOW) {
			return;
		}
		
		// If the player is on wood, add a chance to spawn a squeaky sound
		if(soundFile == "step/wood" && random(0,30) == 0)
		{
			A_SPAWNITEMEX("WoodSqueaker", 0, 0, -32);
		}

		// Carpet puffs
		if(soundFile == "step/carpet") {
			EmitDefinition('CarpetPuffDefinition', 1.0, 35,speed:-2,offset:(0,0,5), flags:PE_ABSOLUTE_PITCH);
			A_SPAWNITEMEX("CarpetSmoke",0,0,10,0,0,0.5);
		}

		if(soundFile == "step/grass")
		{
			A_SPAWNITEMEX("PlantImpactEffectFloor");
			EmitDefinition('GrassBladeParticleFootstepDefinition', chance: 0.75, numTries: 30);
		}

		// Play rainy footsteps when walking on a rain texture
        Sector s = CurSector;//Level.PointInSector((pos.x, pos.y));
        if (s)
        {
			string checkString = TexMan.GetName(s.GetTexture(s.floor));
			if(checkString.Left(3) == "RN_")
			{
				wetprints = FOOTPRINT_LENGTH;
				onRainWater = true;
				EmitDefinition('waterSplashParticleFootstepDefinition', chance:1.0, numTries:12);
				A_PlaySound("STEP/rain", CHAN_AUTO, footstepVolume, pitch:frandom(1.1,1.2));
			}
        }
	}

	void handleWaterSteps()
	{
		// Water cleans your boots!
		slimePrints = 0;
		bloodPrints = 0;

		wetPrints = FOOTPRINT_LENGTH;
		A_PLAYSOUND(WATER_SOUND, CHAN_AUTO, 0.8, pitch:frandom(0.95,1.1));

		ShaderHandler.LevelSetRain(amount: 42);

		// Splashes only on settings higher than LOW
		if(gameDetail > GAMEDETAIL_LOW && waterLevel < 3) {
			// Spawn some splashes
			for(int x=0;x<getCvar("r_particleIntensity")*10;x++)
			{
				actor waterSplashActor;
				bool waterSplashSuccess;
				[waterSplashSuccess, waterSplashActor] = A_SpawnItemEx("WaterParticleXSmaller", 3+(frandom(-5,5)), frandom(-5,5),0, frandom(-2,10),frandom(-5,5),frandom(0.4,3));
				if(waterSplashActor)
				{
					SelacoActor(waterSplashActor).moveToWaterSurface();
				}
			}

			// Foam effects
			for(int x=0;x<4;x++)
			{
				actor waterSplashActor;
				bool waterSplashSuccess;
				[waterSplashSuccess, waterSplashActor] = A_SpawnItemEx("WaterFoamSlow", 35, 0, 0, frandom(1,2), frandom(-3,3));
				if(waterSplashActor)
				{
					SelacoActor(waterSplashActor).moveToWaterSurface();
				}
			}
		}
	}

    float getFootstepVolume(int flags, float speed) 
	{	
		float baseVolume = 0.15;		
        if ((flags & FSF_SCRIPTEDFOOTSTEP) != 0) {
            // Lower volume for scripted footsteps
            return 0.70;
        }
		// Make catwalk sounds slightly louder.
		if(soundFile == "step/catwalk")
		{
			baseVolume*=1.5;	
		}
		return speed*baseVolume;
	}
	
	// Each of these sounds maps to an index from FloorMaterialType
	static const String footStepSoundList[] = {
		// BOX
		"step/box",
		// PLASTIC
		"step/plastic",
		// WOOD
		"step/wood",
		// CARPET
		"step/carpet",
		// THIN METAL
		"step/thinmetal",
		// METAL
		"step/metal",
		// GRAVEL
		"step/gravel",
		// DIRT
		"step/dirt",
		// WATER
		"step/water",
		// STONE
		"step/stone",
		// GRASS
		"step/grass",
		// GRATES
		"step/grate",
		// CABLES
		"step/cable",
		// PIPE
		"step/hard",
		// VOID
		"step/hard",
		// CATWALKS
		"step/catwalk",
		// GLASS
		"step/catwalk",
		// VIRTUAL
		""
	};

	/*static const Name footStepList[] =
	{
		// BOX
		"step/box",
		"WODCRT1A",
		"WODCBA1B",
		"WODCRT4C",
		"WODCRT2A",
		"BOX2",
		"BOX2A",
		"BOX3",
		
		// PLASTIC
		"step/plastic",
		"PLASTIC",

		// WOOD
		"step/wood",
		"WOODPLK2",
		"WOODPLK1",
		"WOODVERT",
		"FLAT5_1",
		"FLAT5_2",
		"WOODFLA3",
		"KTWRK2A",
		"WODWHI1C",
		"WODCRT1A",
		"WODTPL1A",
		"WOODPLK3",
		"WOODPLK4",
		"WOODF2",
		"WOODF7",
		"WOODF8",
		"NFPANL01",

		// CARPET
		"step/carpet",
		"SSWTCHB",
		"SSWTCH",
		"CEIL4_3",
		"FLAT5_3",
		"FLAT5_4",
		"FLAT5_5",
		"FLAT14",
		"FLOOR1_1",

		// ROCK
		"step/rock",
		"PNLSF4A",
		"PNLSF4B",
		"FLAT5_6",
		"RROCK10",
		"RROCK11",
		"RROCK12",
		"PNLSO32B",
		"RROCK14",
		"FLDIAM5",
		"STELCWB",
		"PNLSO32B",
		"PNLSF4B",
		"VENT1",
		"PNLSO32B",

		// METAL
		"step/metal",
		"FLDIAMJ",
		"FLAT1_3",
		"SLIME14",
		"LFW27B",
		"FLGH1C",
		"LFW27A",
		"LFW27C",
		"LFW27B",
		"BOX1",
		"BOX12",
		"BOX1A",
		"BOX1D",
		"BOX12",
		"BO21WD",
		"PTHCEI1D",

		// GRAVEL
		"step/gravel",
		"FLOOR6_1",
		"FLOOR6_2",
		"RROCK17",
		"NFMF82GR",

		// DIRT
		"step/dirt",
		"FLAT10",
		"GRASS1",
		"GRASS2",
		"RROCK16",
		"FLAT5_7",
		"RROCK19",
		"RROCK20",
		"MFLR8_4",
		"ASHWALL3",
		"ROCK36",
		"QGRASS",

		// WATER -- Not entirely sure if this needed, since all water sectors should use 3D sectors for the effects to be properly utilized.
		"step/water",
		"FHDW01",
		"FHDW02",
		"FHDW03",
		"FHDW04",
		"FHDW05",
		"FHDW06",
		"FHDW07",
		"FHDW08",
		"FHDW09",
		"FHDW10",
		"FHDW11",
		"FHDW12",
		"FHDW13",
		"FHDW14",
		"FHDW15",
		"FHDW16",
		"FHDW17",
		"FHDW18",
		"FHDW19",
		"FHDW20",
		"FHDW21",
		"FHDW22",
		"FHDW23",
		"FHDW24",
		"FHDW25",
		"FHDW26",
		"FHDW27",
		"FHDW28",
		"FHDW29",
		"FHDW30",
		"FHDW31",
		"FHDW32",
		"FWATER1",
		"FWATER2",
		"FWATER3",
		"FWATER4",

		// STONE
		"step/stone",
		"BTILEBLS",
		"GRAYDIA1",
		"PURCEI2A",
		"BTILEGYS",

		// GRASS
		"step/grass",
		"GROUND04",
		"GROUND05",

		// GRATES
		"step/grate",
		"FSTDMD3",
		"HZWTM1B",
		"PNLGH1",
		"FLS3",
		"STELWF1B",
		"MCTC15B",
		"FLGR",
		"PEXPOF1A",
		"FABRTR1A",
		"FLRCTW1B",

		// CABLES
		"step/cable",
		"WIRE1H",
		"WIRE2H",
		"WIRE3H",
		"WIREHG",
		"WIRE3V"
	};*/
}

// We want the squeak to be positional so it sounds more believable.
class WoodSqueaker : Actor
{
	default
	{
		+NOINTERACTION
	}
	states
	{
		Spawn:
			TNT1 A 0;
			TNT1 A 0 A_PLAYSOUND("WOODSQUEAK", CHAN_AUTO, 0.7, pitch:frandom(0.7,0.9));
			stop;
	}
}


mixin class Steppable {
	int steppableFlags;
	String passiveStepSound;		// Step sound
	class<Actor> steppableSpawns;	// Spawn object when stepped on
	bool steppableDestroys;			// Die() when stepped on
	bool isSlippery;
	flagdef SteppableIsSlimey 	: steppableFlags,	0;	// Adds purple slime footprints to stepper
	flagdef SteppableIsBloody 	: steppableFlags,	1;	// Adds bloody footprints to stepper
	flagdef SteppableIsWet		: steppableFlags,	2;	// Adds wet footprints to stepper
	flagdef SteppableAlerts		: steppableFlags,	3;	// Alert enemies when stepped on, only applies to Dawn as stepper
	flagdef SteppableDestroys	: steppableFlags,	4;	// Die() when stepped on
	flagdef SteppableIgnoresTimeout	: steppableFlags, 5;	// Steppable always happens, regardless of passiveStepTick 

	void becomeSteppable(double radius = -1, double height = -1) {
		bSOLID = false;
		bSPECIAL = true;
		A_SetSize(radius, height);
		bTHRUACTORS = false;
		bTHRUGHOST = false;
		if(bNOBLOCKMAP && !bDestroyed) A_ChangeLinkFlags(0);
	}

	void undoSteppable() {
		bSOLID = Default.bSOLID;
		bSPECIAL = Default.bSPECIAL;
		A_SetSize(Default.radius, Default.height);
		bTHRUACTORS = Default.bTHRUACTORS;
		bTHRUGHOST = Default.bTHRUGHOST;
		if(Default.bNOBLOCKMAP && !bDestroyed) A_ChangeLinkFlags(1);
	}

	virtual void doSlipping(actor toucher) 
	{
        if(pos.z == floorz && toucher is 'SelacoEnemy' && toucher.vel.length() > 0.35) {
            SelacoEnemy(toucher).doBananaSlide();
        }
	}

	void DoAfterSoundGlass()
	{
		if(passiveStepSound == "step/wglas" && random(0,100) <= 20) {
			A_PLAYSOUND("step/aftereffect/glass", CHAN_AUTO);
		}
	}

	override void Touch(Actor toucher) {
        if(toucher is 'Dawn' && (Dawn(toucher).passiveStepTick-- > 0 || bSteppableIgnoresTimeout)) {
			//toucher.A_PrintBold("Passive sound!" .. passiveStepSound);
            toucher.A_PLAYSOUND(passiveStepSound, CHAN_AUTO, Dawn(toucher).footstepVolume);
			if(bSteppableIsBloody)  	Dawn(toucher).bloodPrints = FOOTPRINT_LENGTH;
			if(bSteppableIsSlimey)  	Dawn(toucher).slimePrints = FOOTPRINT_LENGTH;
			if(bSteppableIsWet)  		Dawn(toucher).wetPrints = FOOTPRINT_LENGTH;
			if(steppableSpawns) 		toucher.A_SPAWNITEMEX(steppableSpawns, flags:SXF_SETMASTER);
			if(bSteppableAlerts) 		toucher.SoundAlert(toucher);
			if(bSteppableDestroys) 		{ wake(); die(self,self); };
			if(isSlippery)				{ doSlipping(toucher); }
			DoAfterSoundGlass();
        } else if(toucher is 'EnemySoldier' && (EnemySoldier(toucher).passiveStepTick-- > 0 || bSteppableIgnoresTimeout)) 
		{
            toucher.A_PLAYSOUND(passiveStepSound, CHAN_AUTO, EnemySoldier(toucher).footstepVolume);

			if(bSteppableIsBloody)  	EnemySoldier(toucher).bloodPrints = FOOTPRINT_LENGTH;
			if(bSteppableIsSlimey)  	EnemySoldier(toucher).slimePrints = FOOTPRINT_LENGTH;
			if(bSteppableIsWet)  		EnemySoldier(toucher).wetPrints = FOOTPRINT_LENGTH;
			if(steppableSpawns) 		toucher.A_SPAWNITEMEX(steppableSpawns);
			if(bSteppableDestroys) 		{ wake(); die(self,self); };
			if(isSlippery)				{ doSlipping(toucher); }
			DoAfterSoundGlass();
        }

    }
}