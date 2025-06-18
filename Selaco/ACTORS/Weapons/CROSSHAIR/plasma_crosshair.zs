class PlasmaCrosshair : CustomCrosshair {
    ui TextureID lineTex, dotTex, dot2Tex;

    const ZOOM_TIME = 0.21;
    const FIRE_TIME = 0.45;

    override void init() {
        Super.init();
    }

    override void uiInit() {
        Super.uiInit();
        
        lineTex     = getReady("XH_PLAS1");
        dotTex      = getReady("XH_DOT5");
        dot2Tex     = getReady("XH_PLAS2");
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

    override void uiTick() {
        Super.uiTick();
    }

    override void draw(double fracTic, double alpha, Vector2 offset) { 
        if(!weapon) return;

        if(!isReady && !(
            TexMan.MakeReady(dotTex) &&
            TexMan.MakeReady(lineTex) &&
            TexMan.MakeReady(dot2Tex)
        )) return;
        isReady = true;

        Color crosscolor = crosshaircolor;
        Color col   = Color(255, crosscolor.r, crosscolor.g, crosscolor.b);
        Vector2 scScale = getVirtualScreenScale();
        //Vector2 center = (screenSize * 0.5) + offset;

        if(dryFireTick != 0 && level.TotalTime - dryFireTick < 20) {
            // Make the crosshair red when dryfired
            double tp = double(level.TotalTime + fracTic) - double(dryFireTick);
            col = UIMath.LerpC(col, 0xFFFF0000, abs(sin(tp * 30.0)) * UIMath.EaseOutQuadF(1.0 - tp / 20.0) * 0.5);
        }

        //double spreadVal = UIMath.Lerpd(deltaSpread, spread, fracTic) / 2.75;
        double time = (double(level.TotalTime) + fracTic) * ITICKRATE;
        double zoomTime = (double(level.TotalTime - zoomTick) + fracTic) * ITICKRATE;
        double zoomFactor = CLAMP(zoomTime / ZOOM_TIME, 0.0, 1.0);
        if(!zooming) zoomFactor = 1.0 - zoomFactor;
        
        double fireDelta = 1.0 - CLAMP( ((double(level.TotalTime - fireTick) + fracTic) * ITICKRATE) / FIRE_TIME, 0.0, 1.0);
        double fireOffset = fireDelta * (zooming ? 40.0 : 32.0);
        fireOffset += 20.0 * (0.35 * stunnedFactor);
        fireOffset -= 25.0 * (0.35 * hoppingFactor);

        double lo = (20. * UIMath.EaseOutCubicf(zoomFactor)) + fireOffset;
        double lo2 = (10. * UIMath.EaseOutCubicf(zoomFactor)) + (fireOffset * 0.4);

        // Draw lines
        DrawXTex(lineTex, (0, -15) + (0, -lo2) + offset, 0, a: alpha*0.2, color: col, center: (0.5, 1));
        DrawXTex(lineTex, (0,  15) + (0,  lo2) + offset, 0, a: alpha*0.2, color: col, rotation: 180, center: (0.5, 1));

        // Draw dots
        DrawXTex(dotTex, offset, 0, a: alpha, color: col, center: (0.5, 0.5));
        DrawXTex(dot2Tex, offset + (-1 - lo, 0), 0, a: alpha, color: col, center: (1, 0.5));
        DrawXTex(dot2Tex, offset + (1 + lo, 0), 0, a: alpha, color: col, rotation: 180, center: (1, 0.5));
    }
}