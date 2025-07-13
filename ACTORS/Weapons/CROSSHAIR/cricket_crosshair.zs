class CricketCrosshair : CustomCrosshair {
    ui TextureID lineTex, dotTex;

    const ZOOM_TIME = 0.21;
    const FIRE_TIME = 0.65;

    const COS_120 = cos(120 + 90);
    const SIN_120 = sin(120 + 90);
    const COS_240 = cos(240 + 90);
    const SIN_240 = sin(240 + 90);

    override void init() {
        Super.init();
    }

    override void uiInit() {
        Super.uiInit();
        
        lineTex     = getReady("XH_DASH3");
        dotTex      = getReady("XH_DOT4");
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

    override void draw(double fracTic, double alpha, Vector2 offset) { 
        if(!weapon) return;
        
        if(!isReady && !(
            TexMan.MakeReady(lineTex) &&
            TexMan.MakeReady(dotTex)
        )) return;
        isReady = true;
        
        Color crosscolor = crosshaircolor;
        Color col   = Color(255, crosscolor.r, crosscolor.g, crosscolor.b);
        //Vector2 scScale = getVirtualScreenScale();
        //Vector2 center = (screenSize * 0.5) + offset;

        //double spreadVal = UIMath.Lerpd(deltaSpread, spread, fracTic) / 2.75;
        double time = (double(level.TotalTime) + fracTic) * ITICKRATE;
        double zoomTime = (double(level.TotalTime - zoomTick) + fracTic) * ITICKRATE;
        double zoomFactor = CLAMP(zoomTime / ZOOM_TIME, 0.0, 1.0);
        if(!zooming) zoomFactor = 1.0 - zoomFactor;
        
        double fireDelta = UIMath.EaseInQuadF(1.0 - CLAMP( ((double(level.TotalTime - fireTick) + fracTic) * ITICKRATE) / FIRE_TIME, 0.0, 1.0));
        double fireOffset = (fireDelta * (zooming ? 20.0 : 16.0)) - (zoomFactor * 10);
        fireOffset += 14 * stunnedFactor;
        fireOffset -= 6 * hoppingFactor;

        // Draw lines
        double lineAlpha = alpha * (1.0 - (zoomFactor * 0.35));
        DrawXTex(lineTex, offset - (0, fireOffset), 0, a: lineAlpha, color: col, rotation: 0, center: (0.5, 1));
        DrawXTex(lineTex, offset - (fireOffset * COS_120, fireOffset * SIN_120), 0, a: lineAlpha, color: col, rotation: -120, center: (0.5, 1));
        DrawXTex(lineTex, offset - (fireOffset * COS_240, fireOffset * SIN_240), 0, a: lineAlpha, color: col, rotation: 120, center: (0.5, 1));

        // Draw dot
        DrawXTex(dotTex, offset, 0, a: alpha, color: col, center: (0.5, 0.5));
    }

    override void uiTick() {
        Super.uiTick();


    }
}