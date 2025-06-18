// Shows a warning when low on ammo in the crosshair area
class HUDAmmoWarning : HUDElementStartup {
    bool hasLowAmmo, hasNoAmmo, chamberEmpty, reloadIndicator;
    uint lowAmmoTicks, noAmmoTicks;
    uint reservesTime;

    double crosshairHeight;

    HUDElementCrosshair crosshairElement;

    const WARNINGLEN_TIME = double(4.0);
    const WARNING_FADE_TIME = double(0.45);
    const WARNINGLEN_TICKS = int(ceil((WARNINGLEN_TIME + WARNING_FADE_TIME) * TICRATE));
    const RESERVE_TIME = double(2.8);
    const RESERVE_FADE_TIME = double(0.45);
    const RESERVE_TICKS = int(ceil((RESERVE_TIME + RESERVE_FADE_TIME) * TICRATE));

    override HUDElement init() {
        reloadIndicator = true;
        crosshairHeight = 60;

        return Super.init();
    }

    void checkAmmoState() {
        if(ticks % 37 == 0) {
            reloadIndicator = iGetCVar("g_reloadindicator", 1);
        }
        
        if(reloadIndicator && owner.curWeapon && !owner.curWeapon.hideAmmo) {
            Dawn p = Dawn(players[consolePlayer].mo);
            if(p) reservesTime = p.reservesTime;

            int ammoCount = owner.ammoType2 ? owner.ammoType2.amount : (owner.ammoType1 ? owner.ammoType1.amount : 0);
            bool noReserve = (!owner.ammoType1 || owner.ammoType1.amount == 0);
            bool noPrimary = ammoCount == 0;
            bool noAmmoAtAll = noReserve && noPrimary;

			if(!chamberEmpty) {
                chamberEmpty = (owner.CPlayer.weaponState & WF_WEAPONREADY) && owner.curWeapon is 'Shot_Gun' && Shot_Gun(owner.curWeapon).shotsLeft < 0 && !noAmmoAtAll;
            } else {
                chamberEmpty = owner.curWeapon is 'Shot_Gun' && Shot_Gun(owner.curWeapon).shotsLeft < 0 && !noAmmoAtAll;
            }


            if(!chamberEmpty) {
                bool hadLowAmmo = hasLowAmmo;
                bool hadNoAmmo = hasNoAmmo;
                
                hasLowAmmo = ammoCount <= owner.curWeapon.lowAmmoThreshold && invCount("hasLowAmmo");
                hasNoAmmo = noPrimary && noReserve;

                if(!hadLowAmmo && hasLowAmmo ) { lowAmmoTicks = 0; }
                if(!hadNoAmmo && hasNoAmmo) { noAmmoTicks = 0; }
            } else {
                hasLowAmmo = false;
                hasNoAmmo = false;
            }
		} else {
			hasLowAmmo = false;
			hasNoAmmo = false;
            chamberEmpty = false;
            reservesTime = 0;
		}
    }

    override void onWeaponChanged(SelacoWeapon oldWeapon, SelacoWeapon newWeapon) {
        Super.onWeaponChanged(oldWeapon, newWeapon);

        hasLowAmmo = false;
        hasNoAmmo = false;
        chamberEmpty = false;
        reservesTime = 0;
    }

    override bool tick() {
        if(level.levelnum == 100) 
        {
            return false;
        }
        if(hasNoAmmo) noAmmoTicks++;
        if(hasLowAmmo) lowAmmoTicks++;

        checkAmmoState();

        if(!crosshairElement) crosshairElement = HUDElementCrosshair(owner.FindElement('HUDElementCrosshair'));

        if(crosshairElement) {
            crosshairHeight = crosshairElement.getCrosshairHeight();
        }
        
        return false;
    }

    override void draw(double fracTic, float alpha, Vector2 shake, Vector2 momentum)  {
        if(!hasNoAmmo && !hasLowAmmo && !chamberEmpty && level.totalTime - reservesTime > RESERVE_TICKS) return;
        if(!players[consolePlayer].mo || Dawn(players[consolePlayer].mo).weaponWheelUp) return;

        Vector2 hudShake = shake + momentum;

        if(!hasNoAmmo && chamberEmpty) {
            // Special case for the shotgun, if we need to pump it show that here
            DrawStr(
                "SELOFONT", 
                "$CHAMBEREMPTY", 
                (0,  crosshairHeight) + (hudShake * 0.5), 
                DR_SCREEN_HCENTER | DR_SCREEN_VCENTER | DR_TEXT_HCENTER, 0xFFb0c6f7, 
                0.8 * alpha * (1.0 - (owner.globalPulse * 0.35)), 
                false
            );
        } else if(reservesTime != 0 && level.totalTime - reservesTime < RESERVE_TICKS) {
            // Draw OUT OF RESERVES warning
            double time = ((level.totalTime - reservesTime) + fracTic) * ITICKRATE;
            double a = time < RESERVE_TIME ? MIN(1.0, time / 0.17) : MAX(0, 1.0 - ((time - RESERVE_TIME) / RESERVE_FADE_TIME));

            DrawStr(
                "SELOFONT", 
                "$OUTOFRESERVES",
                (0,  crosshairHeight) + (hudShake * 0.5), 
                DR_SCREEN_HCENTER | DR_SCREEN_VCENTER | DR_TEXT_HCENTER, 0xFFb0c6f7, 
                0.8 * alpha * (1.0 - (owner.globalPulse * 0.35)) * a, 
                false
            );
        } else if(!hasNoAmmo && hasLowAmmo && lowAmmoTicks < WARNINGLEN_TICKS) {
            // Draw low ammo warning
            double time = (lowAmmoTicks + fracTic) * ITICKRATE;
            double a = time < WARNINGLEN_TIME ? MIN(1.0, time / 0.17) : MAX(0, 1.0 - ((time - WARNINGLEN_TIME) / WARNING_FADE_TIME));	// Fade in or out...
            
            DrawStr(
                "SELOFONT", 
                owner.ammoType1 && owner.ammoType1.amount > 0 ? "$RELOAD" : "$LOWAMMO",
                (0,  crosshairHeight) + (hudShake * 0.5), 
                DR_SCREEN_HCENTER | DR_SCREEN_VCENTER | DR_TEXT_HCENTER, 0xFFb0c6f7, 
                0.8 * alpha * (1.0 - (owner.globalPulse * 0.35)) * a, 
                false
            );
        } else if(hasNoAmmo) {
            // Draw no ammo warning
            double time = (noAmmoTicks + fracTic) * ITICKRATE;
            double a = MIN(1.0, time / 0.17);	// Fade in..

            DrawStr(
                "SELOFONT", 
                "$NOAMMO", 
                (0,  crosshairHeight) + (hudShake * 0.5), 
                DR_SCREEN_HCENTER | DR_SCREEN_VCENTER | DR_TEXT_HCENTER, 0xFFb0c6f7, 
                0.8 * alpha * (1.0 - (owner.globalPulse * 0.35)) * a, 
                false
            );
        }
    }
}