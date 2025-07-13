const HUD_SCALING_DEFAULT = 0.89;

mixin class HudDrawer {    
    clearscope double makeScreenScale(Vector2 baselineResolution = (1920, 1080), bool useHUDScaling = true) {
        let size = (Screen.GetWidth(), Screen.GetHeight());
        double cvScale = 1.0;

        if(useHUDScaling) {
            CVar cv = CVar.FindCVar('hud_scaling');  // Can't use CVARBUDDY here
            cvScale = cv ? cv.GetFloat() : HUD_SCALING_DEFAULT;
            if(cvScale < 0) cvScale = HUD_SCALING_DEFAULT;
        }
        
        double newScale = MAX(0.5, size.y / baselineResolution.y) * cvScale;

        // If we are close enough to 1.0.. 
        if(abs(newScale - 1.0) < 0.08) {
            newScale = 1.0;
        } else if(abs(newScale - 2.0) < 0.08) {
            newScale = 2.0;
        }

        return newScale;
    }

    ui double calcScreenScale(out Vector2 screenSize, out Vector2 virtualScreenSize, out Vector2 screenInsets) {
        double newScale = makeScreenScale(useHUDScaling: true);
        screenSize = (Screen.GetWidth(), Screen.GetHeight());
        virtualScreenSize = screenSize / newScale;

        // Set insets as a percentage of the screen width/height
        CVar ix = CVar.FindCVar('hud_inset_x');
        CVar iy = CVar.FindCVar('hud_inset_y');
        double ixx = ix ? clamp(ix.getFloat(), 0.0, 1.0) : 0;
        double iyy = iy ? clamp(iy.getFloat(), 0.0, 1.0) : 0;
        screenInsets.x = clamp(virtualScreenSize.x * 0.5 * ixx, 0, max(0, (virtualScreenSize.x * 0.5) - 1078));
        screenInsets.y = virtualScreenSize.y * 0.5 * iyy;

        return newScale;
    }

    ui double getScreenScale(out Vector2 screenSize, out Vector2 virtualScreenSize) {
        double newScale = makeScreenScale(useHUDScaling: false);
        screenSize = (Screen.GetWidth(), Screen.GetHeight());
        virtualScreenSize = screenSize / newScale;
        screenInsets = (0,0);

        return newScale;
    }
}

mixin class HUDScaleChecker {
    ui double cvHudScale;
    ui vector2 cvHudInsets;

    ui bool hudScaleChanged() {
        CVar cv = CVar.FindCVar('hud_scaling');
        CVar ix = CVar.FindCVar('hud_inset_x');
        CVar iy = CVar.FindCVar('hud_inset_y');
        let s = cv ? cv.GetFloat() : -1;
        Vector2 insets = (ix ? clamp(ix.getFloat(), 0.0, 1.0) : 0, iy ? clamp(iy.getFloat(), 0.0, 1.0) : 0);

        if(cvHudScale != s || cvHudInsets != insets) {
            cvHudScale = s;
            cvHudInsets = insets;
            return true;
        }

        return false;
    }
}