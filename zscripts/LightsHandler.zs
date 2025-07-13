const LIGHT_SHADOW_LIMIT = 4;

class LightsHandler : EventHandler {	
	mixin CVARBuddy;    // Make this global you dummy
	Array<SelacoLightBase> lights;

	bool flickerAllowed;
	int oldLightQualitySetting;
	int lightQualitySetting;

	const FLICKER_CV = "g_photosensitivitymode2";
	const LIGHTQUALITY_CV = "lightingquality";

	override void OnRegister() {
		flickerAllowed = iGetCVar(FLICKER_CV) == 0;
		lightQualitySetting = igetCvar(LIGHTQUALITY_CV);
	}

	override void ConsoleProcess(ConsoleEvent e) {
		// Debug print the lights we are tracking
		if(e.Name.MakeLower() == "printlights") {
			Console.Printf("Point Lights\n--------------------");
			for(int x = 0; x < lights.size(); x++) {
				let l = lights[x];
				Console.Printf("%s: (%f, %f, %f) Type [%d] Original: [%d]", l.GetClassName(), l.pos.x, l.pos.y, l.pos.z, l.getLightType(), l.getOriginalType());
			}
		}
	}

	override void WorldTick() {
		if(Level.time % 35 == 0) {
			// If our flickersetting var has changed, adjust all of the flicker lights
			adjustFlickerSetting();

			// If our lighting quality var has changed, adjust all lights that fall under the criteria
			adjustLights();
		}
	}

	void adjustFlickerSetting()
	{
		// Flicker Setting
		let faDelta = flickerAllowed;
		flickerAllowed = iGetCVar(FLICKER_CV) == 0;

		if(faDelta != flickerAllowed) {
			for(int x = 0; x < lights.size(); x++) {
				if(lights[x])
				{
					lights[x].SetFlickerEnabled(flickerAllowed);
				}
			}
		} 
	}

	void adjustLights()
	{
		lightQualitySetting = igetCvar(LIGHTQUALITY_CV);
		if(lightQualitySetting != oldLightQualitySetting)
		{
			// Light quality has changed. Adjust lights.
			oldLightQualitySetting = lightQualitySetting;

			// Find lights
			for(int x = 0; x < lights.size(); x++) 
			{
				if(lights[x])
				{
					lights[x].checkLights(lightQualitySetting);
				}
			}
		}
	}

    static clearscope LightsHandler Instance() {
        return LightsHandler(EventHandler.Find("LightsHandler"));
    }

}



// This is a bastard class that lets us replace PointLightFlicker(s) to disable flickering for Photosensitivity mode
class SelacoLightBase : DynamicLight {
	bool user_noshadowmap;
	bool user_lightquality_high;
	bool user_lightquality_ultra;

	protected int originalType;
	protected int originalRadius;
	protected int originalRadiusSecondary;
	// TODO: Add support for spot lights
	virtual void SetFlickerEnabled(bool enabled = true) {
		if(!enabled) {
			// Disable flickering by converting to a point light
			if(lightType != PointLight) {
				originalType = lightType;
				lightType = PointLight;
				ResetLight();
			}
		} else {
			// Enable flickering by converting back
			if(lightType != originalType) {
				lightType = originalType;
				ResetLight();
			}
		}
	}

	void checkLights(int lightQualitySetting)
	{

		// Kills small lights on the lowest setting
		if (lightQualitySetting <= 1 && args[LIGHT_INTENSITY] <= 40 && tid == 0) {
			TurnOffLight();
		} else {
			TurnOnLight();
		}

		// Kill lights with Tag 8888 so we can manually kill lights that aren't important on Medium and below
		if(lightQualitySetting <= 2 && tid == 8888)
		{
			TurnOffLight();
		}

		// Kill lights if the required quality isn't met. Doing it here for the sake of readability
		if ((user_lightquality_high && lightQualitySetting <= 2) || (user_lightquality_ultra && lightQualitySetting <= 3 && !user_lightquality_high)) {
			TurnOffLight();
		} else {
			TurnOnLight();
		}

	}

	virtual void TurnOffLight()
	{
		args[LIGHT_INTENSITY] = 0;
		args[LIGHT_SECONDARY_INTENSITY] = 0;
	}

	virtual void TurnOnLight()
	{
		args[LIGHT_INTENSITY] = originalRadius;
		args[LIGHT_SECONDARY_INTENSITY] = originalRadiusSecondary;
	}


	// Keep track of scene lights so we can disable flickering when necessary
	// This is done in the event handler because it's wasteful for every light to do it's own check
	void handleLights()
	{
		LightsHandler lh = LightsHandler.instance();
		lh.lights.push(SelacoPointLightBase(self));
	}

	override void PostBeginPlay() {

		handleLights();

		originalType = lightType;
		originalRadius = args[LIGHT_INTENSITY];
		originalRadiusSecondary = args[LIGHT_SECONDARY_INTENSITY];
		// Check noshadowmap custom property
		if(user_noshadowmap || args[LIGHT_INTENSITY] <= 48) { 
			lightflags |= LF_NOSHADOWMAP;
		}

		checkLights(getCvar("lightingquality"));
		Super.PostBeginPlay();
	}

	void AttachExternalLight() {
		// We use colors above 256 sometimes, so let's calculate an intensity
		int r, g, b;
		double i = 1;
		int flags = lightflags;
		int m = MAX(args[LIGHT_RED], args[LIGHT_GREEN], args[LIGHT_BLUE]);
		if(m > 256) {
			i = m  / 256.0;
			r = floor(args[LIGHT_RED] / i);
			g = floor(args[LIGHT_GREEN] / i);
			b = floor(args[LIGHT_BLUE] / i);
		} else {
			r = args[LIGHT_RED];
			g = args[LIGHT_GREEN];
			b = args[LIGHT_BLUE];
		}

		// Check noshadowmap custom property again
		if(user_noshadowmap || args[LIGHT_INTENSITY] <= 48) { 
			flags |= LF_NOSHADOWMAP;
		}

		A_AttachLightEx("main",
			Color(lightType, r, g, b),
			i,
			args[LIGHT_INTENSITY], args[LIGHT_SECONDARY_INTENSITY],
			lightflags, (0,0,0),
			SpawnAngle / 360.0,
			SpotInnerAngle,
			SpotOuterAngle
		);
	}

	void DetachExternalLight() {
		A_RemoveLight("main");
	}

	void ResetExternalLight() {
		// Remove And attach the light
		DetachExternalLight();
		if(!bDormant) AttachExternalLight();
	}

	clearscope int getOriginalType() {
		return originalType;
	}

	// Must be used after the light type is changed
	void ResetLight() {
		DeleteAttachedLights();
		AttachLight();

		if(bDormant) { DeactivateLight(); } else { ActivateLight(); }
	}

	override void tick() {
		Super.tick();

		SleepIndefinite();
	}
}

class SelacoPointLightBase : SelacoLightBase {

}

class SelacoPointLight : SelacoPointLightBase  replaces PointLight
{
	Default
	{
		DynamicLight.Type "Point";
	}
}

class SelacoPointLightPulse : SelacoPointLight  replaces PointLightPulse
{
	Default
	{
		DynamicLight.Type "Pulse";
	}
}

class SelacoPointLightFlicker : SelacoPointLight  replaces PointLightFlicker
{
	Default
	{
		DynamicLight.Type "Flicker";
	}
}

class SelacoSectorPointLight : SelacoPointLight replaces SectorPointLight
{
	Default
	{
		DynamicLight.Type "Sector";
	}
}

class SelacoPointLightFlickerRandom : SelacoPointLight replaces PointLightFlickerRandom
{
	Default
	{
		DynamicLight.Type "RandomFlicker";
	}
}

class SelacoPointLightAdditive : SelacoPointLight replaces PointLightAdditive
{
	Default
	{
		+DYNAMICLIGHT.ADDITIVE
	}
}

class SelacoPointLightPulseAdditive : SelacoPointLight replaces PointLightPulseAdditive
{
	Default
	{
		+DYNAMICLIGHT.ADDITIVE
	}
}

class SelacoPointLightFlickerAdditive : SelacoPointLight replaces PointLightFlickerAdditive
{
	Default
	{
		+DYNAMICLIGHT.ADDITIVE
	}
}

class SelacoSectorPointLightAdditive : SelacoPointLight replaces SectorPointLightAdditive
{
	Default
	{
		+DYNAMICLIGHT.ADDITIVE
	}
}

class SelacoPointLightFlickerRandomAdditive : SelacoSectorPointLightAdditive replaces PointLightFlickerRandomAdditive
{
	Default
	{
		+DYNAMICLIGHT.ADDITIVE
	}
}

class SelacoPointLightSubtractive : SelacoPointLight replaces PointLightSubtractive
{
	Default
	{
		+DYNAMICLIGHT.SUBTRACTIVE
	}
}

class SelacoPointLightPulseSubtractive : SelacoPointLightPulse replaces PointLightPulseSubtractive
{
	Default
	{
		+DYNAMICLIGHT.SUBTRACTIVE
	}
}

class SelacoPointLightFlickerSubtractive : SelacoPointLightFlicker replaces PointLightFlickerSubtractive
{
	Default
	{
		+DYNAMICLIGHT.SUBTRACTIVE
	}
}

class SelacoSectorPointLightSubtractive : SelacoSectorPointLight replaces SectorPointLightSubtractive
{
	Default
	{
		+DYNAMICLIGHT.SUBTRACTIVE
	}
}

class SelacoPointLightFlickerRandomSubtractive : SelacoPointLightFlickerRandom replaces PointLightFlickerRandomSubtractive
{
	Default
	{
		+DYNAMICLIGHT.SUBTRACTIVE
	}
}

class SelacoPointLightAttenuated : SelacoPointLight replaces PointLightAttenuated
{
	Default
	{
		+DYNAMICLIGHT.ATTENUATE
	}
}

class SelacoPointLightPulseAttenuated : SelacoPointLightPulse replaces PointLightPulseAttenuated
{
	Default
	{
		+DYNAMICLIGHT.ATTENUATE
	}
}

class SelacoPointLightFlickerAttenuated : SelacoPointLightFlicker replaces PointLightFlickerAttenuated
{
	Default
	{
		+DYNAMICLIGHT.ATTENUATE
	}
}

class SelacoSectorPointLightAttenuated : SelacoPointLight replaces SectorPointLightAttenuated
{
	Default
	{
		+DYNAMICLIGHT.ATTENUATE
	}
}

class SelacoPointLightFlickerRandomAttenuated : SelacoPointLightFlickerRandom replaces PointLightFlickerRandomAttenuated
{
	Default
	{
		+DYNAMICLIGHT.ATTENUATE
	}
}



// Controls Light Effect stuff (e.g Muzzle Flash lights, spark lights)
// TO-DO: We need to keep track of the amount of shadow casters!
class LightEffectHandler : EventHandler
{
	int activeLights;
	int activeShadows;
	int currentLightSetting;
	int currentShadowSetting;
	int currentMuzzleFlashSetting;
	int currentFlickerSetting;
    Array<SelacoLightEffect> oldLights;
    class<SelacoLightEffect> spRef;

    // Kill oldest light effect when the current effect light count is higher than this
    static const int lightLimits[] = { 
        2,    // Low
        5,    // Med
        9,   // High
		12 // ULTRA
    };

    override void OnRegister() {
        spRef = 'SelacoLightEffect';
        currentLightSetting = clamp(CVar.FindCVar("lightingQuality").GetInt() - 1, 0, 2);
		currentShadowSetting = CVar.FindCVar("r_shadowquality").GetInt();
		currentMuzzleFlashSetting = CVar.FindCVar("g_dimMuzzleFlashes").GetInt();
		currentFlickerSetting = CVar.FindCVar("g_photosensitivitymode2").GetInt();
	}

    // Kill old light when limit is exceeded
    void cleanupLights() {
        int toRemove = activeLights - lightLimits[currentLightSetting];
        int toDelete = 0;

        for(int x = 0; x < oldLights.size() && toRemove > 0; x++) {

			// Only kill lights without the alwaysShow parameter
            if(oldLights[x] && !SelacoLightEffect(oldLights[x]).alwaysShow) {
                SelacoLightEffect(oldLights[x]).die(oldLights[x], oldLights[x]);
                toRemove--;
            }
            toDelete++;
        }
        oldLights.delete(0, toDelete);
    }

	void destroyLight(SelacoLightEffect light)
	{
        activeLights--;
		if(light.bNoshadowmap == false)
		{
			activeShadows--;
		}
	}

	// Frequently update the CVAR
    override void WorldTick() {
        if(level.time % 36 == 0) {
        	currentLightSetting = clamp(CVar.FindCVar("lightingQuality").GetInt() - 1, 0, 3);
			currentShadowSetting = clamp(CVar.FindCVar("r_shadowquality").GetInt() - 1, 0, 3);
			currentMuzzleFlashSetting = CVar.FindCVar("g_dimMuzzleFlashes").GetInt();
			currentFlickerSetting = CVar.FindCVar("g_photosensitivitymode2").GetInt();
        } else if(level.time % 6) {
            cleanupLights();
        }
    }

    static clearscope LightEffectHandler Instance() {
        return LightEffectHandler(EventHandler.Find("LightEffectHandler"));
    }
}

// Light Effects are Dynamic Lights that only exist for a short duration of time.
mixin class LightEmitter {

    int rColor, gColor, bColor, fadeoutSpeed, lightIntensity;
	float divisionSpeed;
	int alwaysShow, lightQuality, shadowQuality, weaponFlash, flickerSetting, shadowRequirement;
	int followMode;
	int followSelf;
	int overBright;
    property rColor : rColor;
    property gColor : gColor;
    property bColor : bColor;
    property FadeoutSpeed : fadeoutSpeed;
	property lightIntensity	: LightIntensity;

	array<SelacoLightEffect> lightEffects;
	actor lightActor;
	bool lightSuccess;	
	int isOverbright;
	int activeLights;

	// Shadow Requirement is the minimum shadow setting required (r_shadowquality) in order to turn it into a shadow caster. Expensive effects are often used for `2`
	// Followmaster makes the light follow the caller
	// Overbright stacks the light twice. This is demanding, but pretty. Exclusive to 'Ultra' Light Quality setting only.
	void spawnLight(int rColor = 0, int gColor = 0, int bColor = 0, int lightRadius = 120, int fadeoutSpeed = 0, int shadowRequirement = 2, int followMaster = 0, int xOffset = 0, int overBright = 0, float divisionSpeed = 0, int alwaysShow = 0, int weaponFlash = 0, actor followActor = null, bool ignoreLightLimit = 0, int zOffset = 0, int lightSettingRequirement = 0, bool attenuatedLight = 0, bool flickerLight = false) {
		bool allowSpawning = true;

		// Spawn lights and check for properties;
		if(allowSpawning) {
			[lightSuccess, lightActor] = A_SpawnItemEx("SelacoLightEffect", xOffset, 0, zOffset, flags: SXF_SETMASTER);
			SelacoLightEffect lightEffectInstance = SelacoLightEffect(lightActor);
			if(lightEffectInstance) {
				lightEffectInstance.flickerLight = flickerLight;
				lightEffectInstance.bAttenuate = attenuatedLight;
				lightEffectInstance.rColor= rColor;
				lightEffectInstance.gColor= gColor;
				lightEffectInstance.bColor= bColor;
				lightEffectInstance.givenLightIntensity= lightRadius;
				lightEffectInstance.givenFadeoutSpeed = fadeOutSpeed;
				lightEffectInstance.divisionSpeed = divisionSpeed;
				lightEffectInstance.alwaysShow = alwaysShow;
				lightEffectInstance.followActor = followActor;
				lightEffectInstance.weaponFlash = weaponFlash;
				lightEffectInstance.followMode = followMaster;
				lightEffectInstance.ignoreLightLimit = ignoreLightLimit;
				lightEffectInstance.shadowRequirement = shadowRequirement;
				lightEffectInstance.lightSettingRequirement = lightSettingRequirement;
			}
		}
	}

	// Kills all the attached light effects of this actor
	void killAllLightEffects()
	{
		for(int x=0;x<lightEffects.size();x++)
		{
			let lightEffect = lightEffects[x];
			if(lightEffect)
			{
				lightEffect.die(self, self);
			}
		}
	}

	// Check if the current actor has any lights in his possession
	bool checkIfLight()
	{
		if(lightEffects.size())
		{
			return true;
		}
		return false;
	}

}


class SelacoLightEffect : DynamicLight {	
	int rColor, gColor, bColor, lightIntensity, alwaysShow, followMode, shadowRequirement, weaponFlash, lightQuality, shadowQuality, muzzleflashSetting, flickersetting, givenFadeoutSpeed, givenLightIntensity;
	float fadeoutSpeed, divisionSpeed;
	int lightSettingRequirement;
	actor followActor;
	bool hasFollowActor;
	bool ignoreLightLimit;
	bool flickerLight;
	
	property RColor : rColor;
	property GColor : gColor;
	property BColor : bColor;
	property lightIntensity : lightIntensity;
	property fadeoutSpeed : fadeoutSpeed;

	default
	{
		+DYNAMICLIGHT.noshadowmap
	}

	// Set up lights using the handler.
	override void BeginPlay()
	{
		LightEffectHandler leh = LightEffectHandler.instance();

		lightQuality = leh.currentLightSetting;
		shadowQuality = leh.currentShadowSetting;
		muzzleflashSetting = leh.currentMuzzleFlashSetting;
		flickerSetting = leh.currentFlickerSetting;
		//SelacoLightEffect(e.thing).ActualBeginPlay();

		// Check shadows. If maximum reached, this shadow should not work.
		if(!bNoShadowmap)
		{
			leh.activeShadows++;
			if(leh.activeShadows > LIGHT_SHADOW_LIMIT)
			{
				leh.activeShadows--;
				bNoShadowmap = true;	
			}
		}

		// Check if we exceed the current limit
        if(leh.lightLimits[leh.currentLightSetting]) 
		{
            leh.cleanupLights();
        } 

		super.BeginPlay();
	}

	override void OnDestroy()
	{
		LightEffectHandler leh = LightEffectHandler.instance();
		if(leh)
		{
			leh.destroyLight(self);
		}
		super.OnDestroy();
	}

	override void PostBeginPlay()
	{
		super.Postbeginplay();
		if(followActor)
		{
			hasFollowActor = true;
		}
	}

	void ActualBeginPlay()
	{
		LightEffectHandler handler = LightEffectHandler.Instance();
		if(lightQuality < lightSettingRequirement)
		{
			return;
		}
		
		if(!ignoreLightLimit) {
			handler.activeLights++;
			handler.oldLights.push(SelacoLightEffect(self));
		}


		if(shadowRequirement != -1 && handler.currentShadowSetting >= shadowRequirement)
		{
			bNoShadowmap = false;
		}

		if(givenFadeoutSpeed)
		{
			fadeoutSpeed = givenFadeoutSpeed;
		}
		if(givenLightIntensity)
		{
			lightIntensity = givenLightIntensity;
		}

		// Smaller lights for Medium
		if(lightQuality == 1) {
			lightIntensity = lightIntensity*0.80;
		}

		if(lightQuality == 0) {
			lightIntensity = lightIntensity*0.6;
		}


		// Accessbility:
		// If a light is not a muzzle flash and the flicker setting is disabled, we should not spawn a light at all
		if(!weaponFlash && flickerSetting)
		{
			die(self, self);
		}

		// Accessbility:
		// Less light when photo sensitivity is on
		if(weaponFlash && muzzleflashSetting) {
			rColor = rColor*0.3;
			bColor = bColor*0.3;
			gColor = gColor*0.3;
			args[3] *=0.75;
		}

		if(weaponFlash && lightQuality <= 3) {
			lightIntensity*=0.75;
		}

		args[0] = rColor;
		args[1] = gColor;
		args[2] = bColor;
		args[3] = lightIntensity;	

	}

	int aliveticks;
	// Keep light alive until 0. This might need changing once we have a 'weird' effect
    override void tick() {
        super.tick();
		if(isFrozen()) { return; }
		
		if(aliveticks == 0 && getClassName() == "SelacoLightEffect")
		{
			SetstateLabel("Spawn");
		}

		for(int x=0;x<=2;x++) 
		{
			if(args[x] > 0) 
			{
				if(divisionSpeed > 0) 
				{
					args[x]=args[x] / divisionSpeed;
				}
				if(fadeOutSpeed > 0)
				{
					args[x]=args[x] - fadeoutSpeed;
				}
			}			
		}

        if(aliveticks > 0 && args[0] <= 2 && args[1] <= 2 && args[2] <= 2) 
		{
            die(self, self);
        }

		if(followMode) 
		{
			if(master) 
			{
				A_WARP(AAPTR_Master, 0, 0, 10, 0, WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
			}
			if(!master) 
			{
				die(self, self);
			}
		}

		if(hasFollowActor)
		{
			if(followActor)
			{
				warp(followActor, 2, 2, 10, 0, WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
			}
			else
			{
				die(self, self);
			}
		}
		if(aliveticks > 2 && flickerLight && random(0,99) <= 50)
		{
			args[3] = random(lightIntensity*0.75, lightIntensity);	
		}

		aliveticks++;
    }

    states {
	    Spawn:
		    TNT1 A 0;
			TNT1 A 0
			{
				ActualBeginPlay();
			}
		    TNT1 A 180;
		    stop;
    }
}

class SelacoLightEffectOverbright : SelacoLightEffect
{
	
}

// Yo that's a big explosion
class GiganticFireballLight : actor
{
	mixin lightEmitter;
	default
	{
		+NOINTERACTION;
	}
	states
	{
		Spawn:
			TNT1 A 0;
			TNT1 A 0
			{
				Spawnlight(rColor:355, gColor:145, bcolor:55, lightRadius:600, 0, 3, overBright: 2, divisionSpeed:1.03, alwaysShow:1);
			}
			stop;
	}
}