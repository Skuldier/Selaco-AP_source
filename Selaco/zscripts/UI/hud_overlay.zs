#include "zscripts/UI/hud/overlay_drawer.zs"
#include "zscripts/UI/hud/hud_frame_drawer.zs"
#include "zscripts/UI/hud/hud_health_drawer.zs"
#include "zscripts/UI/hud/hud_armor_drawer.zs"
#include "zscripts/UI/hud/hud_splat_drawer.zs"

class HUDOverlay ui {
    mixin CVARBuddy;

    double lastScale;

    enum OverlayType {
        OV_VIGNETTE = 0,
        OV_ZOOM,
        OV_PAIN,
        OV_HEAL,
        OV_FROZEN,
        OV_ARMOR,
        OV_DIRT,
        OV_DIRT2,
        OV_DIRT3,
        OV_STEAM,
        OV_WATER,
        OV_DASHL,
        OV_DASHR,
        OV_DASHB,
        OV_SPLATS,
        OV_DEATH,
        OV_HUD,         // Make sure HUD is always drawn last! 
        OV_GASMASK,     // Gonna combine the two HUDs now
        OV_LASTITEM
    };

    static const string overlayImages[] = {
        "vignet2",
        "V_ZOOM",
        "V_OUCHIE",
        "V_HEAL",
        "V_ICY",
        "V_ARMO6",
        "DIRTOVER",
        "DIRTOVE2",
        "DIRTOVE3",
        "V_STEAM1",
        "V_STEAM1", // TODO: Make basic water thingy
        "DODLEFT",
        "DODRIGHT",
        "DODBACK",
        "HUDSPLA1",
        "V_BLOODY",
        "HUD00",
        "HUDMASK1"
    };

    uint ticks;
    OverlayDrawer drawers[OV_LASTITEM];

	void Init(double scale, bool hasGasMask = false) {
        int scWidth = Screen.GetWidth();
        int scHeight = Screen.GetHeight();
        lastScale = scale;

        // Set up individual overlays
        for(int x = 0; x < OV_LASTITEM; x++) {
            switch(x) {
                case OV_HUD: {
                    HUDFrameDrawer hd = new("HUDFrameDrawer");
                    hd.Init(overlayImages[x], (scale, scale));
                    drawers[x] = hd;
                    break;
                }
                case OV_GASMASK: {
                    HUDFrameDrawer hd = new("GasHUDFrameDrawer");
                    hd.Init("HUDMASK1", (scale, scale));
                    drawers[x] = hd;
                    break;
                }
                case OV_HEAL:
                    drawers[x] = new("HealthHudDrawer").Init(overlayImages[x], (scale, scale));
                    break;
                case OV_PAIN:
                    drawers[x] = new("PainHudDrawer").Init(overlayImages[x], (scale, scale));
                    break;
                case OV_ARMOR:
                    drawers[x] = new("ArmorHudDrawer").Init(overlayImages[x], (scale, scale));
                    break;
                case OV_SPLATS:
                    drawers[x] = new("SplatHUDDrawer").Init(overlayImages[x], (scale, scale));
                    break;
                default:
                    drawers[x] = new("OverlayDrawer").Init(overlayImages[x], (scale, scale));
                    break;
            }
            
        }

        let cv = CVar.GetCVar("g_vignetting");
        drawers[OV_VIGNETTE].setAlpha(cv ? cv.GetFloat() : 0.65);   // Base vignette always active (unless settings prevent it)
        drawers[OV_VIGNETTE].fade = -1;    // Never fade out the base vignette
        drawers[OV_HUD].setAlpha(1);
        drawers[OV_HUD].fade = 0;

        drawers[OV_GASMASK].setAlpha(1);
        drawers[OV_GASMASK].fade = 0;

        drawers[OV_ZOOM].introTime = 0.14;
        drawers[OV_SPLATS].setAlpha(1);
        drawers[OV_FROZEN].introTime = 0.14;
        drawers[OV_STEAM].fade = -1;
        drawers[OV_STEAM].alpha = drawers[OV_STEAM].lastAlpha = 0;
        drawers[OV_STEAM].targetAlphaFactor = 0.1;

        drawers[OV_SPLATS].padding = scWidth * 0.015625;
        drawers[OV_DIRT].padding = scWidth * 0.015625;
        drawers[OV_DIRT2].padding = scWidth * 0.015625;
        drawers[OV_DIRT3].padding = scWidth * 0.015625;
        drawers[OV_STEAM].padding = scWidth * 0.015625;
        drawers[OV_FROZEN].padding = scWidth * 0.015625;
        drawers[OV_DEATH].padding = scWidth * 0.015625;
	}

    void switchToGasMask(bool hasGasMask = true, int time = 0) {
        HUDFrameDrawer(drawers[OV_HUD]).awayTick = hasGasMask ? time : (time == 0 ? 0 : -(time + 35));
        GasHUDFrameDrawer(drawers[OV_GASMASK]).setStartTime(hasGasMask ? time : -time);
    }

	void Tick() { 
        // Check for disabled options. 
        if(ticks % 16 == 0) {
            drawers[OV_VIGNETTE].setAlpha(fGetCVAR('g_vignetting', 0.6));
            drawers[OV_FROZEN].disabled = !iGetCVAR('g_overlay_frozen');
            drawers[OV_HEAL].disabled = !iGetCVAR('g_overlay_healing');
            drawers[OV_ARMOR].disabled = !iGetCVAR('g_overlay_armor');
        }

        // GZDoom needs an event hook for these instead of having to check all the time
        if((ticks + 5) % 13 == 0) {
            drawers[OV_DIRT].disabled = drawers[OV_DIRT2].disabled = drawers[OV_DIRT3].disabled = !iGetCVAR('g_overlay_dirt');
            drawers[OV_STEAM].disabled = !iGetCVAR('g_overlay_steam');
            drawers[OV_DASHB].disabled = drawers[OV_DASHL].disabled = drawers[OV_DASHR].disabled = !iGetCVAR('g_overlay_dash');
        }

        // Tick Drawers
        // TODO: Don't tick when disabled, this requires additional cleanup work
        for(int x = 0; x < OV_LASTITEM; x++) {
            drawers[x].tick();
        }

        ticks++;
	}

    void ScreenSizeChanged(double scale) {
        lastScale = scale;
        int scWidth = Screen.GetWidth();
		int scHeight = Screen.GetHeight();
        
        for(int x = 0; x < OV_LASTITEM; x++) {
            drawers[x].ScreenSizeChanged(scWidth, scHeight, scale);
        }

        drawers[OV_DIRT].padding = scWidth * 0.015625;
        drawers[OV_DIRT2].padding = scWidth * 0.015625;
        drawers[OV_DIRT3].padding = scWidth * 0.015625;
        drawers[OV_STEAM].padding = scWidth * 0.015625;
        drawers[OV_FROZEN].padding = scWidth * 0.015625;
        drawers[OV_DEATH].padding = scWidth * 0.015625;
    }

    
    // Per-frame render!
	void Draw(double tm, Vector2 offset) {
        int scWidth = Screen.GetWidth();
		int scHeight = Screen.GetHeight();

        for(int x = 0; x < OV_LASTITEM; x++) {
            drawers[x].Draw(scWidth, scHeight, tm, offset);
        }
    }
}