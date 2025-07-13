class ShotgunCrosshair : CustomCrosshair {
    ui TextureID lineTex, dotTex, dot2Tex, dot3Tex;

    const ZOOM_TIME = 0.21;
    const FIRE_TIME = 0.45;
    const BASE_OFFSET_X = 117;
    const BASE_OFFSET_Y = 52;
    override void init() {
        Super.init();
    }

    override void uiInit() {
        Super.uiInit();
        
        lineTex     = getReady("XH_DASH2");
        dotTex      = getReady("XH_DOT1");
        dot2Tex     = getReady("XH_DOT2");
        dot3Tex     = getReady("XH_DOT3");
    }

    override void attach(SelacoWeapon weapon) {
        Super.attach(weapon);
    }

    override void detach() {
        Super.detach();
    }

    override void tick() {
        Super.tick();
    }

    override double getHeight() {
        return virtualScreenSize.y ? (screenSize.y / virtualScreenSize.y) * 105.0 : 0;
    }

    override void draw(double fracTic, double alpha, Vector2 offset) { 
        if(!weapon) return;

        if(!isReady && !(
            TexMan.MakeReady(lineTex) &&
            TexMan.MakeReady(dotTex) &&
            TexMan.MakeReady(dot2Tex) &&
            TexMan.MakeReady(dot3Tex)
        )) return;
        isReady = true;

        Color crosscolor = crosshaircolor;
        Color col   = Color(255, crosscolor.r, crosscolor.g, crosscolor.b);
        Vector2 scScale = getVirtualScreenScale();
        bool isSlugShot = (weapon is "Shot_gun" && Shot_gun(weapon).customShellType == "Slug");
        //Vector2 center = (screenSize * 0.5) + offset;

        //double spreadVal = UIMath.Lerpd(deltaSpread, spread, fracTic) / 2.75;
        float lineAlpha = alpha;
        double time = (double(level.TotalTime) + fracTic) * ITICKRATE;
        double zoomTime = (double(level.TotalTime - zoomTick) + fracTic) * ITICKRATE;
        double zoomFactor = CLAMP(zoomTime / ZOOM_TIME, 0.0, 1.0);
        if(!zooming) zoomFactor = 1.0 - zoomFactor;
        
        double fireDelta = 1.0 - CLAMP( ((double(level.TotalTime - fireTick) + fracTic) * ITICKRATE) / FIRE_TIME, 0.0, 1.0);
        double fireOffset = fireDelta * (zooming ? 40.0 : 32.0);
        double lineXOffset = BASE_OFFSET_X;
        double lineYOffset = BASE_OFFSET_Y;
        double lo = (-12. * UIMath.EaseOutCubicf(zoomFactor)) + fireOffset;
        double lo2 = (-3. * UIMath.EaseOutCubicf(zoomFactor)) + (fireOffset * 0.4);
        lo += 18 * (0.35 * stunnedFactor);
        lo2 += 12 * (0.35 * stunnedFactor);


        if(isSlugShot)
        {
            lineXOffset*=0.3;
            lineYOffset*=0.85;
            lineAlpha*=0.5;
            if(zooming) {
                lineAlpha = 0;
            }
        }

        // Draw lines
        DrawXTex(lineTex, (-1*lineXOffset, -1*lineYOffset) + (-lo, -lo2) + offset, 0, a: lineAlpha, color: col, center: (0, 0));
        DrawXTex(lineTex, (-1*lineXOffset,  lineYOffset) + (-lo,  lo2) + offset, 0, a: lineAlpha, color: col, center: (0, 1), flipY: true);
        DrawXTex(lineTex, (lineXOffset,  -1*lineYOffset) + ( lo, -lo2) + offset, 0, a: lineAlpha, color: col, center: (1, 0), flipX: true);
        DrawXTex(lineTex, (lineXOffset,   lineYOffset) + ( lo,  lo2) + offset, 0, a: lineAlpha, color: col, center: (1, 1), flipX: true, flipY: true);

        // Draw dot
        DrawXTex(dotTex, (0,0), 0, a: alpha, color: col, center: (0.5, 0.5));

        // Draw ammo
        if(!isSlugShot && !zooming) {
            double eachSpace = 130. / double(weapon.Ammo2.maxAmount + 1);
            for(int x = 0; x < weapon.Ammo2.maxAmount; x++) {
                DrawXTex(weapon.Ammo2.amount > x ? dot3Tex : dot2Tex, (-65 + (eachSpace * (weapon.Ammo2.maxAmount - x)), 70) + offset, 0, a: alpha * 0.75, color: col, center: (0.5, 0.5));
            }
        }

    }

    override void uiTick() {
        Super.uiTick();


    }
}