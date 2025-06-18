class CustomCrosshair play {
    mixin UIDrawer;
    mixin CVARBuddy;

    ui double stunnedFactor;
    ui double hoppingFactor;

    SelacoWeapon weapon;
    uint zoomTick, fireTick, stunnedTick, hoppingTick, dryFireTick;
    uint pickupTick;
    double deltaSpread, spread;
    bool stunned;
    bool hasBunnyHop;
    bool zooming;
    bool useADS;

    transient ui bool hasUIInit;
    transient ui bool isReady;

    virtual void init() {

    }

    ui virtual void uiInit() {
        
    }

    // Return height of the current crosshair in screen pixels
    ui virtual double getHeight() {
        return virtualScreenSize.y > 0 ? (screenSize.y / virtualScreenSize.y) * 70 : 0;
    }

    virtual void attach(SelacoWeapon weapon) {
        self.weapon = weapon;
        zooming = weapon ? weapon.isZooming : false;
        spread = weapon.adjustedSpread;
        deltaSpread = spread;
    }

    virtual void detach() {
        weapon = null;
        zooming = false;
        zoomTick = 0;
    }

    virtual void tick() {
        if(weapon) {
            if(weapon.isZooming != zooming) {
                zoomTick = level.TotalTime;
                zooming = weapon.isZooming;
            }

            if(weapon.supportsADS && level.totalTime % 36 == 0) {
                useADS = weapon.getCvar("g_ironsights") > 0;
            }

            deltaSpread = spread;
            spread = weapon.adjustedSpread;
            
            bool wasStunned = stunned;
            stunned = weapon.owner.countinv("CooldownStunned") > 0;
            if(stunned != wasStunned) stunnedTick = level.TotalTime;

            bool wasHopping = hasBunnyHop;
            hasBunnyHop = weapon.owner.countinv("BunnyHopDuration") > 0;
            if(hasBunnyHop != wasHopping) hoppingTick = level.TotalTime;
        }
    }

    virtual void weaponFire() {
        fireTick = level.TotalTime;
    }

    virtual void dryFire() {
        dryFireTick = level.TotalTime;
    }

    ui void drawXHair(double fracTic, double alpha, Vector2 offset, double scale = 1.0) {
        let d = Dawn(weapon.owner);
        if(d && d.weaponWheelUp && WeaponWheelHandler.Instance().IsShowing()) {
            return;
        }
        if(virtualScreenSize.x == 0 || virtualScreenSize.y == 0) return;
        
        if(pickupTick != 0 && level.TotalTime - pickupTick < 2) {
            scale *= UIMath.EaseInXYA(1.0, 1.2, (double(level.TotalTime - pickupTick) + fracTic) / 5.0);
        } else if(pickupTick != 0 && level.TotalTime - pickupTick < 8) {
            scale *= UIMath.EaseInXYA(1.2, 1.0, (double(level.TotalTime - pickupTick - 2) + fracTic) / 6.0);
        }

        // Stunned
        if(stunned) {
            stunnedFactor = clamp( UIMath.EaseInQuadF(((double(level.TotalTime - stunnedTick) + fracTic) * ITICKRATE) / 0.25), 0.0, 1.0);
        } else if(stunnedTick != 0) {
            stunnedFactor = clamp( 1.0 - UIMath.EaseInQuadF(((double(level.TotalTime - stunnedTick) + fracTic) * ITICKRATE) / 0.25), 0.0, 1.0);
        }

        // BUNNY HOP
        if(hasBunnyHop) {
            hoppingFactor = clamp( UIMath.EaseInQuadF(((double(level.TotalTime - hoppingTick) + fracTic) * ITICKRATE) / 0.25), 0.0, 1.0);
        } else if(hoppingTick != 0) {
            hoppingFactor = clamp( 1.0 - UIMath.EaseInQuadF(((double(level.TotalTime - hoppingTick) + fracTic) * ITICKRATE) / 0.25), 0.0, 1.0);
        }

        // Calc alpha for ADS zoom
        double adsAlpha = 1.0;
        if(useADS) {
            adsAlpha = ((level.totalTime - double(zoomTick) + fracTic) * ITICKRATE) / 0.13;
            if(zooming) adsAlpha = 1.0 - adsAlpha;
        }

        if(adsAlpha > 0.0) {
            let vs = virtualScreenSize;
            virtualScreenSize /= scale;
            draw(fracTic, alpha * adsAlpha, offset);
            virtualScreenSize = vs;
        }   
    }

    ui protected virtual void draw(double fracTic, double alpha, Vector2 offset) { }

    ui virtual void uiTick() {
        if(!hasUIInit) {
            uiInit();
            hasUIInit = true;
        }
    }

    virtual void onItemPickedUp() {
        if(iGetCVAR("crosshairgrow")) pickupTick = level.TotalTime;
    }
}


#include "Actors/Weapons/CROSSHAIR/plain_crosshair.zs"
#include "Actors/Weapons/CROSSHAIR/circle_draw.zs"
#include "Actors/Weapons/CROSSHAIR/rifle_crosshair.zs"
#include "Actors/Weapons/CROSSHAIR/nailgun_crosshair.zs"
#include "Actors/Weapons/CROSSHAIR/shotgun_crosshair.zs"
#include "Actors/Weapons/CROSSHAIR/cricket_crosshair.zs"
#include "Actors/Weapons/CROSSHAIR/smg_crosshair.zs"
#include "Actors/Weapons/CROSSHAIR/grenade_crosshair.zs"
#include "Actors/Weapons/CROSSHAIR/dmr_crosshair.zs"
#include "Actors/Weapons/CROSSHAIR/plasma_crosshair.zs"
#include "Actors/Weapons/CROSSHAIR/railgun_crosshair.zs"