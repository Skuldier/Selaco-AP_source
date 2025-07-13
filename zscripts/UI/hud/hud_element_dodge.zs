class HUDElementDodge : HUDElementStartup {
    UITexture dashTexture[3];

    const DISPLAY_TIME = 0.45;

    override HUDElement init() {
        Super.init();
        
        dashTexture[0] = UITexture.Get("DODGELEF");
        dashTexture[1] = dashTexture[0];
        dashTexture[2] = UITexture.Get("DODGEBAC");

        return self;
    }

    override void onAttached(HUD owner, Dawn player) {
        Super.onAttached(owner, player);
    }

    override int getOrder() { return SORT_UNDERLAY; }

    /*override bool tick() {
       

        return Super.tick();
    }*/

    override void draw(double fracTic, float alpha, Vector2 shake, Vector2 momentum)  {
        if(!player || player.dodgeDirection < 0 || player.dodgeDirection > 2 || player.dodgeTime == 0) return;

        double time = (level.totalTime - player.dodgeTime + fracTic) * ITICKRATE;

        if(time > DISPLAY_TIME) return;
        
        // Determine direction and pick texture
        UITexture tex = dashTexture[player.dodgeDirection];
        
        if(!makeTexReady(tex.texID)) return;

        double tm = 1.0 - clamp(UIMath.EaseInQuartF(time / DISPLAY_TIME), 0, 1.0);
        double a = tm;  // Ignore incoming alpha
        // Add a tiny in-fade
        a *= clamp(UIMath.EaseOutQuadF(time / (DISPLAY_TIME * 0.33)), 0, 1);
 
        double scWidth = Screen.GetWidth();
        double scHeight = Screen.GetHeight();

        // Draw
        switch(player.dodgeDirection) {
            case 0:
                Screen.DrawTexture(tex.texID, false, 0, 0, 
                    DTA_DestHeightF, scHeight,
                    DTA_DestWidthF, scWidth * 0.4,
                    DTA_ALPHA, a,
                    DTA_Filtering, true,
                    DTA_LegacyRenderStyle, STYLE_Add
                );
                break;
            case 1: 
                Screen.DrawTexture(tex.texID, false, scWidth - (scWidth * 0.4), 0, 
                    DTA_DestHeightF, scHeight,
                    DTA_DestWidthF, scWidth * 0.4,
                    DTA_ALPHA, a,
                    DTA_Filtering, true,
                    DTA_FLIPX, true,
                    DTA_LegacyRenderStyle, STYLE_Add
                );
                break;
            case 2:
                Screen.DrawTexture(tex.texID, false, 0, scHeight * 0.66, 
                    DTA_DestHeightF, scHeight * 0.34,
                    DTA_DestWidthF, scWidth,
                    DTA_ALPHA, a,
                    DTA_Filtering, true,
                    DTA_LegacyRenderStyle, STYLE_Add
                );
                break;
        }
    }
}