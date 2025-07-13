#include "ZScripts/UI/hud/meters.zs"

// Draws all meters in the bottom middle of the screen
class HUDMeters : HUDElementStartup {
	mixin CVARBuddy;

    HUDMeter flashMeter, slideMeter, o2Meter, taserMeter, dashMeter, stunMeter, powderMeter, bunnyHopMeter, medkitMeter, bipodMeter, fireMeter, shockDartMeter;
    Array<HUDMeter> meters;
	double meterScale;
	int maxStun;
	bool playerHasArmor;
	bool playerIsDrowning;
    
    override HUDElement init() {
		meterScale = 1.0;

        return Super.init();
    }

    void removeMeter(HUDMeter m) {
		for(int x = 0; x < meters.size(); x++) {
			if(meters[x] == m) {
				meters.delete(x);
				return;
			}
		}
	}

    // Making love out of nothing at all..
    double getAirSupply(Dawn player) {
        return MIN(1.0, double(player.player.air_finished - Level.maptime) / double(int(Level.airsupply * player.AirCapacity)));
    }

    override bool tick() {
        double time = ticks * ITICKRATE;

        // Flashlight Meter
		let flashInv = Inv("FlashlightMeter");
		int maxFlashlight = flashInv ? flashInv.maxamount : 0;
		int flashlightMeter = flashInv ? flashInv.amount : 0;
		bool flashlightOn = InvCount("FlashlightMode") == 1;
		bool showFlashMeter = flashlightOn || (flashlightMeter > 0 && flashlightMeter < maxFlashLight);

		if(showFlashMeter && !flashMeter) {
			flashMeter = new("HUDMeter").init("HFLASH", "HMETER", 0xDDCACE4B, maxValue: maxFlashLight);
			meters.push(flashMeter);
		} else if(!showFlashMeter && flashMeter) {
			if(flashMeter.fadeTime == 0) {
				flashMeter.fadeTime = time;
				flashMeter.value = flashMeter.value > 5 ? maxFlashLight : 0;
			} else if(time - flashMeter.fadeTime > flashMeter.fadeTotalTime){
				removeMeter(flashMeter);
				flashMeter.destroy();
				flashMeter = null;
			}
		} else if(flashMeter) {
			flashMeter.value = flashlightMeter;
			flashMeter.pieColor = flashlightMeter > (maxFlashLight / 12.0) * 3 ? 0xDDCACE4B : 0xDD2211CC;

			if(showFlashMeter && flashMeter.fadeTime > 0) {
				flashMeter.fadeTime = 0;
			}
		}

		// Slide Meter
		let slideInv = Inv("CooldownSliding");
		int slide = slideInv && !Inv("SlideScriptActive") ? slideInv.amount : -1;
		if(slide > 0) {
			if(!slideMeter) {
				slideMeter = new("HUDMeter").init2("STATUS01", "STSLIDE1", "STATUS09", 0xFF000000, size: 80, maxValue: slideInv.maxAmount);
				meters.push(slideMeter);
			}
			slideMeter.value = slide;

			// Fix for when the meter is fading out but you use Slide again
			if(slideMeter.fadeTime > 0) {
				slideMeter.setImage("STATUS01");
				slideMeter.fadeTime = 0;
			}
		} else if(slideMeter) {
			if(slideMeter.fadeTime == 0) {
				slideMeter.fadeTime = time;
				slideMeter.value = 0;
				slideMeter.setImage("STATUS02");
				S_StartSound("ability/tempready", CHAN_VOICE, CHANF_UI, snd_menuvolume);
			} else if(time - slideMeter.fadeTime > slideMeter.fadeTotalTime){
				removeMeter(slideMeter);
				slideMeter.destroy();
				slideMeter = null;
			}
		}

		// Dash Meter
		let dashInv = Inv("CooldownDashing");
		int dashing = dashInv ? dashInv.amount : -1;
		if(dashing > 0) {
			if(!dashMeter) {
				dashMeter = new("HUDMeter").init2("STATUS01", "STDASH01", "STATUS09", 0xFF000000, /*0xDD2211CC*//*0xDDCACE4B*/ size: 80, maxValue: dashInv.maxAmount);
				meters.push(dashMeter);
			}
			dashMeter.value = dashing;

			// Fix for when the meter is fading out but you use Dash again
			if(dashMeter.fadeTime > 0) {
				dashMeter.setImage("STATUS01");
				dashMeter.fadeTime = 0;
			}
		} else if(dashMeter) {
			if(dashMeter.fadeTime == 0) {
				dashMeter.fadeTime = time;
				dashMeter.value = 0;
				dashMeter.setImage("STATUS02");
				S_StartSound("ability/tempready", CHAN_VOICE, CHANF_UI, snd_menuvolume);
			} else if(time - dashMeter.fadeTime > dashMeter.fadeTotalTime){
				removeMeter(dashMeter);
				dashMeter.destroy();
				dashMeter = null;
			}
		}

		// Stun Meter
		let stunInv = Inv("CooldownStunned");
		int stunned = stunInv ? stunInv.amount : -1;
		if(stunned > 0) {
			maxStun = max(maxStun, stunned);

			if(!stunMeter) {
				stunMeter = new("HUDMeter").init2("STATUS01", "STSTUN01", "STATUS09", 0xFF000000, size: 80, maxValue: maxStun);
				meters.push(stunMeter);
			} else if(stunned >= stunInv.maxAmount - 1) {
				stunMeter.setImage("STATUS01");
			}

			stunMeter.maxValue = maxStun;
			stunMeter.value = stunned;

			if(stunMeter.fadeTime > 0) {
				stunMeter.setImage("STATUS01");
				stunMeter.fadeTime = 0;
			}
		} else if(stunMeter) {
			if(stunMeter.fadeTime == 0) {
				stunMeter.fadeTime = time;
				stunMeter.value = 0;
				stunMeter.setImage("STATUS02");
				maxStun = 1;
			} else if(time - stunMeter.fadeTime > stunMeter.fadeTotalTime){
				removeMeter(stunMeter);
				stunMeter.destroy();
				stunMeter = null;
			}
		}

		// Bunny Hop
		let bunnyHopInv = Inv("BunnyHopDuration");
		int bunnyHopping = bunnyHopInv ? bunnyHopInv.amount : -1;
		if(bunnyHopping > 0) {
			if(!bunnyHopMeter) {
				bunnyHopMeter = new("HUDMeter").init2("STATUS02", "STFAST01", "STATUS09", 0xFF000000, size: 80, maxValue: bunnyHopInv.maxamount);
				bunnyHopMeter.hideMode = true;	// Slowly cover the icon instead of revealing it
				meters.push(bunnyHopMeter);
			}
			bunnyHopMeter.value = bunnyHopping;

			if(bunnyHopMeter.fadeTime > 0) {
				bunnyHopMeter.setImage("STATUS02");
				bunnyHopMeter.fadeTime = 0;
			}
		} else if(bunnyHopMeter) {
			if(bunnyHopMeter.fadeTime == 0) {
				bunnyHopMeter.fadeTime = time;
				bunnyHopMeter.value = 0;
				bunnyHopMeter.setImage("STATUS01");
			} else if(time - bunnyHopMeter.fadeTime > bunnyHopMeter.fadeTotalTime){
				removeMeter(bunnyHopMeter);
				bunnyHopMeter.destroy();
				bunnyHopMeter = null;
			}
		}

		// Protein Powder
		let powderInv = Inv("MegaPowderAmount");
		int powder = powderInv ? powderInv.amount : -1;
		if(powder > 0) {
			if(!powderMeter) {
				powderMeter = new("HUDMeter").init2("STATUS02", "STRONK01", "STATUS09", 0xFF000000, size: 80, maxValue: powderInv.maxamount);
				powderMeter.hideMode = true;
				meters.push(powderMeter);
			}
			powderMeter.value = powder;

			if(powderMeter.fadeTime > 0) {
				powderMeter.setImage("STATUS02");
				powderMeter.fadeTime = 0;
			}
		} else if(powderMeter) {
			if(powderMeter.fadeTime == 0) {
				powderMeter.fadeTime = time;
				powderMeter.value = 0;
				powderMeter.setImage("STATUS02");
			} else if(time - powderMeter.fadeTime > powderMeter.fadeTotalTime){
				removeMeter(powderMeter);
				powderMeter.destroy();
				powderMeter = null;
			}
		}

		if (DMR(Dawn(player).player.readyWeapon) && DMR(Dawn(player).player.readyWeapon).bipodMode) {
			if(!bipodMeter) {
				bipodMeter = new("HUDMeter").init2("STATUS02", "STAACCUR", "STATUS09", 0xFF000000, size: 80, maxValue: 1);
				bipodMeter.hideMode = true;
				meters.push(bipodMeter);
			}
			bipodMeter.value = 1;

			if(bipodMeter.fadeTime > 0) {
				bipodMeter.setImage("STATUS02");
				bipodMeter.fadeTime = 0;
			}
		} else if(bipodMeter) {
			if(bipodMeter.fadeTime == 0) {
				bipodMeter.fadeTime = time;
				bipodMeter.value = 0;
				bipodMeter.setImage("STATUS02");
			} else if(time - bipodMeter.fadeTime > bipodMeter.fadeTotalTime){
				removeMeter(bipodMeter);
				bipodMeter.destroy();
				bipodMeter = null;
			}
		}

		// Woman on Fire
		let fireTime = Dawn(player).burnTimer;
		if(fireTime > 0) {
			if(!fireMeter) {
				fireMeter = new("HUDMeter").init2("STATUS01", "STFIRE", "STATUS09", 0xFF000000, size: 80, maxValue: Dawn(player).BURN_DAMAGE_DURATION);
				fireMeter.hideMode = true;
				meters.push(fireMeter);
			}
			fireMeter.value = fireTime;

			if(fireMeter.fadeTime > 0) {
				fireMeter.setImage("STATUS01");
				fireMeter.fadeTime = 0;
			}
		} else if(fireMeter) {
			if(fireMeter.fadeTime == 0) {
				fireMeter.fadeTime = time;
				fireMeter.value = 0;
				fireMeter.setImage("STATUS02");
			} else if(time - fireMeter.fadeTime > fireMeter.fadeTotalTime){
				removeMeter(fireMeter);
				fireMeter.destroy();
				fireMeter = null;
			}
		}

		// Oxygen meter
		bool isUnderWater = player && player.isUnderWater;
		double airsupply = player ? GetAirSupply(player) : 0;
		if(isUnderWater || (airsupply > 0 && airsupply < 0.97)) {
			if(!o2Meter) {
				o2Meter = new("HUDMeter").init2("STATUS02", "STOXYGEN", "STATUS09", 0xFF000000, size: 80, maxValue: 1000);
				o2Meter.hideMode = true;
				meters.push(o2Meter);
			}

			// Player is drowning, keep the icon red
			if (airSupply < 0.0) {
				o2Meter.setImage("STATUS01");
			}

			// Flicker when we're reaching low oxygen
			else if (airSupply <= 0.25) {
				int blinkIndex = int((0.25 - airSupply) / 0.025) % 2;
				if (blinkIndex == 0)
					o2Meter.setImage("STATUS03");
				else
					o2Meter.setImage("STATUS02");
			}

			// Stick with green if not in imminent danger
			else {
				o2Meter.setImage("STATUS02");
			}

			o2Meter.fadeTime = 0;
			if (airSupply <= 0.25 && level.time % 35 == 0 && airSupply > 0) {
				float beepPitch = 1.0 - (airSupply * 0.15); 
				if (beepPitch > 1.0) {
					beepPitch = 1.0;
				}
				S_StartSound("UI/OXYGENWARNING", CHANF_UI, volume:0.74, pitch:beepPitch);
			}
			if(airSupply <= 0 && !playerIsDrowning) {
				playerIsDrowning = true;
				S_StartSound("UI/OXYGENPAIN", CHANF_UI, pitch:1.0);
			}

		} else if(o2Meter) {
			if(o2Meter.fadeTime == 0) {
				o2Meter.fadeTime = time;
			} else if(time - o2Meter.fadeTime > o2Meter.fadeTotalTime) {
				playerIsDrowning = false;
				removeMeter(o2Meter);
				o2Meter.destroy();
				o2Meter = null;
			}
		}

		if(o2Meter) {
			o2Meter.value = airsupply <= 0 ? 1 : airsupply * 1000;
		}


		// SMG-Taser meter
		let taseInv = Inv("SmgTaserCharge");
		int tase = taseInv ? taseInv.amount : -1;
		if(tase > 0) {
			if(!taserMeter) {
				taserMeter = new("HUDMeter").init2("STATUS01", "STTASE01", "STATUS09", 0xFF000000, size: 80, maxValue: taseInv.maxamount);
				meters.push(taserMeter);
			}
			taserMeter.value = tase;

			if(taserMeter.fadeTime > 0) {
				taserMeter.fadeTime = 0;
				taserMeter.setImage("STATUS01");
			}
		} else if(taserMeter) {
			if(taserMeter.fadeTime == 0) {
				taserMeter.fadeTime = time;
				taserMeter.value = 0;
				taserMeter.setImage("STATUS02");
				S_StartSound("smg/taserready", CHAN_VOICE, CHANF_UI, snd_menuvolume);
			} else if(time - taserMeter.fadeTime > taserMeter.fadeTotalTime){
				removeMeter(taserMeter);
				taserMeter.destroy();
				taserMeter = null;
			}
		}

		// Shock Dart
		let shockInv = Inv("ShockChargeCooldown");
		int shockDart = shockInv ? shockInv.amount : -1;
		if(shockDart > 0) {
			if(!shockDartMeter) {
				shockDartMeter = new("HUDMeter").init2("STATUS01", "STSHOCK", "STATUS09", 0xFF000000, size: 80, maxValue: shockInv.maxamount);
				meters.push(shockDartMeter);
			}
			shockDartMeter.value = shockDart;

			if(shockDartMeter.fadeTime > 0) {
				shockDartMeter.fadeTime = 0;
				shockDartMeter.setImage("STATUS01");
			}
		} else if(shockDartMeter) {
			if(shockDartMeter.fadeTime == 0) {
				shockDartMeter.fadeTime = time;
				shockDartMeter.value = 0;
				shockDartMeter.setImage("STATUS02");
				S_StartSound("smg/taserready", CHAN_VOICE, CHANF_UI, snd_menuvolume);
			} else if(time - shockDartMeter.fadeTime > shockDartMeter.fadeTotalTime){
				removeMeter(shockDartMeter);
				shockDartMeter.destroy();
				shockDartMeter = null;
			}
		}


		// Medkit heal meter
		let kitInv = Inv("PortableMedkitHealAmount");
		int kit = kitInv ? kitInv.amount : -1;
		if(kit > 0) {
			if(!medkitMeter) {
				medkitMeter = new("HUDMeter").init2("STATUS02", "STHEAL01", "STATUS09", 0xFF000000, size: 80, maxValue: kitInv.maxamount);
				medkitMeter.hideMode = true;
				meters.push(medkitMeter);
			}
			medkitMeter.value = kit;

			if(medkitMeter.fadeTime > 0) {
				medkitMeter.fadeTime = 0;
			}
		} else if(medkitMeter) {
			if(medkitMeter.fadeTime == 0) {
				medkitMeter.fadeTime = time;
				medkitMeter.value = 0;
			} else if(time - medkitMeter.fadeTime > medkitMeter.fadeTotalTime){
				removeMeter(medkitMeter);
				medkitMeter.destroy();
				medkitMeter = null;
			}
		}

		let armor = player ? SelacoArmor(player.FindInventory("SelacoArmor")) : null;
		playerHasArmor = armor != null && armor.Amount > 0;

		// Check meter scale every so often
		if(ticks % 7 == 0) meterScale = fGetCVar("hud_meter_scaling", 1.0) * (owner.hasGasMask > 0 ? 0.8 : 1);
        
        if(meters.size() == 0) ticks = 0;
        return Super.tick();
    }

    override void draw(double fracTic, float alpha, Vector2 shake, Vector2 momentum)  {
		if(owner.hasGasMask > 0) {
			let wpbar = HUD(StatusBar).wpbar;
			if(wpbar && wpbar.bstate != WeaponBar.BAR_HIDDEN) {
				return;
			}
		}

		// Don't draw if there is a notification in the bottom slot
		if(isTightScreen) {
            // Don't render if there is a notification in the bottom middle
            let i = Notification.GetItem();
            if(i && i.notifs[NotificationItem.SLOT_BOT_MID] != null) {
                return;
            }
        }

	    Vector2 scale = getVirtualScreenScale();
        double time = tmTime(fracTic);

        // Draw meters
		// TODO: Animate list of meters getting smaller or larger when items are added/removed (instead of snapping)
		float vw = 85 * meterScale;
		float vh = (owner.hasGasMask > 0 ? (isTightScreen ? 55 : 90.0) * (Screen.GetHeight() / 1080.0) : 0);
		int numMeters = meters.size();
		int mStart = -(numMeters * vw / 2.0);

		double hCenter = virtualScreenSize.x * 0.5;
		if(isTightScreen && playerHasArmor) {
			// Move screen center over if we have armor showing
			if(owner.hasGasMask > 0) 
				hCenter += 115;
			else
				hCenter += 125;
		}

		for(int x = 0; x < numMeters; x++) {
			Vector2 pos = GetPos(DR_SCREEN_BOTTOM) + (hCenter, owner.baseline + 85 - vw) + ((shake + momentum) * 1.25);
			pos.x += (mStart + (vw * x));
			pos.x *= scale.x;
            pos.y *= scale.y;
			pos.y -= vh;
			meters[x].draw(time, pos, scale * meterScale, alpha);
		}
    }
}