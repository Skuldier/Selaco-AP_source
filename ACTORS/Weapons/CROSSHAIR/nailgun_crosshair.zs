class NailgunCrosshair : CustomCrosshair {
    ui TextureID dotTex;

    const ZOOM_TIME = 0.21;
    const INNER_UV = 201. / 256.;
    const OUTER_UV = 213. / 256.;

    const FIRE_TIME = 0.15;

    ui CircleShape32 circle;
    
    override void init() {
        Super.init();
    }

    override void uiInit() {
        Super.uiInit();

        dotTex  = getReady("XH_DOT1");
        circle.init("XH_CIRC9", 120, 12, INNER_UV, OUTER_UV);
        makeTexReady(circle.tex.texID);
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
        return virtualScreenSize.y ? (screenSize.y / virtualScreenSize.y) * (spread > 3 ? 140.0 : 100) : 0;
    }

    override void draw(double fracTic, double alpha, Vector2 offset) { 
        if(!weapon) return;

        if(!isReady && !(
            TexMan.MakeReady(dotTex) &&
            TexMan.MakeReady(circle.tex.texID)
        )) return;
        isReady = true;
        
        Color crosscolor = crosshaircolor;
        Color col   = Color(255, crosscolor.r, crosscolor.g, crosscolor.b);
        Color col2  = Color(255, crosscolor.b, crosscolor.g, crosscolor.r);
        Vector2 scScale = getVirtualScreenScale();
        Vector2 center = (screenSize * 0.5) + offset;

        double time = (double(level.TotalTime) + fracTic) * ITICKRATE;
        //double zoomTime = (double(level.TotalTime - zoomTick) + fracTic) * ITICKRATE;
        //double zoomFactor = CLAMP(zoomTime / ZOOM_TIME, 0.0, 1.0);
        double fireDelta = 1.0 - CLAMP( ((double(level.TotalTime - fireTick) + fracTic) * ITICKRATE) / FIRE_TIME, 0.0, 1.0);
        //if(!zooming) zoomFactor = 1.0 - zoomFactor;

        //double spreadVal = UIMath.EaseInQuadF( UIMath.Lerpd(deltaSpread, spread, fracTic) / 4.0 );
        double spreadVal = UIMath.EaseInQuadF((UIMath.Lerpd(deltaSpread, spread, fracTic) - 0.9) / (4.0 - 0.9));
        spreadVal += spreadVal * (0.35 * stunnedFactor);
        spreadVal -= spreadVal * (0.45 * (hoppingFactor));
        double circleRadius = UIMath.Lerpd(40, 120, spreadVal);// * (1.  + (zoomFactor * 0.5));
        

        circle.setRadius(circleRadius + (fireDelta * 5.), 12);
        circle.draw(center, scScale, col2, alpha);

        // Draw dot
        DrawXTex(dotTex, (0,0), 0, a: alpha, color: col, center: (0.5, 0.5));
    }

    override void uiTick() {
        Super.uiTick();


    }
}