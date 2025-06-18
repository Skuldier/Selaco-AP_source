extend class Dawn {
    uint    reflectionFlashTime;
    int     reflectionStrength;
    
    // Strength = 0-10
    void flashReflection(int strength = 5) {
        reflectionFlashTime = level.totalTime;
        reflectionStrength = clamp(strength, 0, 10);
    }
}


class HUDElementReflection : HUDElement {
    TextureID reflectTex;
    Vector2 reflectTexSize;
    double reflectTexRatio;

    uint flashTicks;

    const FLASH_TIME = 0.24;

    override HUDElement init() {
        Super.init();

        reflectTex = TexMan.CheckForTexture("DAWNGLOW");
        reflectTexSize = TexMan.GetScaledSize(reflectTex);
        reflectTexRatio = reflectTexSize.x / reflectTexSize.y;
        flashTicks = uint.max;

        makeTexReady(reflectTex);

        return self;
    }

    override void onAttached(HUD owner, Dawn player) {
        Super.onAttached(owner, player);
    }

    // 0-10
    void flash(int amount = 5) {
        amount = clamp(amount, 0, 10);
        flashTicks = max(ticks - (10 - amount), flashTicks);
    }

    override bool tick() {
        if(player.reflectionFlashTime == level.totalTime - 1) {
            flash(player.reflectionStrength);
        }

        return Super.tick();
    }

    override void draw(double fracTic, float alpha, Vector2 shake, Vector2 momentum)  {
        double time = (ticks + fracTic) * ITICKRATE;
        double ctime = time - (flashTicks * ITICKRATE);
        
        if(flashTicks > ticks || ctime > FLASH_TIME) return;
        if(!makeTexReady(reflectTex)) return;

        Vector2 hudShake = (shake + momentum) * -1.0;
        double tm = 1.0 - clamp(UIMath.EaseInCubicF(ctime / FLASH_TIME), 0, 1.0);
        double a = tm;  // Ignore incoming alpha

        //DrawTexAdvanced(reflectTex, hudShake, DR_SCREEN_HCENTER | DR_SCREEN_VCENTER | DR_IMG_HCENTER | DR_IMG_VCENTER, a: a, scale: (1, 1));
            
        double scWidth = Screen.GetWidth();
        double scHeight = Screen.GetHeight();
        hudShake *= scHeight / 1080.0;

        double tWidth = (scHeight * reflectTexRatio);

        double sc = UIMath.EaseOutXYA(1.035, 1.0, clamp(sin(MSTIME() * 0.005), 0, 1)) * 1.25;

        double x = (scWidth / 2.0) - ((tWidth * sc) / 2.0) +
                    (sin(MSTime() * 0.05)) + hudShake.x;
        double y = (scHeight / 2.0) - ((scHeight * sc) / 2.0) + 
                    (sin(MSTime() * 0.06)) + hudShake.y + (scHeight * 0.03);

        // Draw
        Screen.DrawTexture(reflectTex, false, x, y, 
            DTA_DestWidthF, (scHeight * reflectTexRatio) * sc,
            DTA_DestHeightF, scHeight * sc,
            DTA_ALPHA, 0.13 * a,
            DTA_Filtering, true,
            DTA_LegacyRenderStyle, STYLE_Shaded
        );
    }
}