class GrenadeCrosshair : CustomCrosshair {
    ui TextureID xhairTex, dotTex, dot2Tex;
    ui TextureID rocketCircTex, rocketTex;
    ui bool hasRocket;

    const ZOOM_TIME = 0.21;
    const FIRE_TIME = 0.45;

    override void init() {
        Super.init();
    }

    override void uiInit() {
        Super.uiInit();
        
        //circTex     = TexMan.CheckForTexture("XH_GREN2");
        xhairTex        = getReady("XH_GREN1");
        dotTex          = getReady("XH_DOT2");
        dot2Tex         = getReady("XH_DOT3");
        rocketCircTex   = getReady("XH_CIRC2");
        rocketTex       = getReady("XH_GREN3");
        Console.Printf("Grenade Crosshair Init");

        checkRocket();
    }

    override double getHeight() {
        return virtualScreenSize.y ? (screenSize.y / virtualScreenSize.y) * 190.0 : 0;
    }

    ui void checkRocket() {
        hasRocket = weapon ? weapon.hasUpgradeClass('AltfireGrenadeLauncherRocket') : false;
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

        if(level.time % 14 == 0) {
            checkRocket();
        }
    }

    const DOT_SPACE = 102.;
    override void draw(double fracTic, double alpha, Vector2 offset) { 
        if(!weapon) return;

        if(!isReady && !(
            TexMan.MakeReady(xhairTex) &&
            TexMan.MakeReady(dotTex) &&
            TexMan.MakeReady(dot2Tex) &&
            TexMan.MakeReady(rocketCircTex) &&
            TexMan.MakeReady(rocketTex) 
        )) return;
        isReady = true;
        
        Color crosscolor = crosshaircolor;
        Color col   = Color(255, crosscolor.r, crosscolor.g, crosscolor.b);
        Vector2 scScale = getVirtualScreenScale();
        //Vector2 center = (screenSize * 0.5) + offset;

        //double spreadVal = UIMath.Lerpd(deltaSpread, spread, fracTic) / 2.75;
        double time = (double(level.TotalTime) + fracTic) * ITICKRATE;
        double zoomTime = (double(level.TotalTime - zoomTick) + fracTic) * ITICKRATE;
        double zoomFactor = CLAMP(zoomTime / ZOOM_TIME, 0.0, 1.0);
        if(!zooming) zoomFactor = 1.0 - zoomFactor;
        
        double fireDelta = 1.0 - CLAMP( ((double(level.TotalTime - fireTick) + fracTic) * ITICKRATE) / FIRE_TIME, 0.0, 1.0);
        double fireOffset = 1.0 + (UIMath.EaseOutCubicF(fireDelta) * 0.45);
        
        if(hasRocket) {
            // Draw main tex
            DrawXTex(rocketTex, offset, 0, a: alpha, color: col, center: (0.5, 0.5));
            DrawXTex(rocketCircTex,  offset, 0, a: alpha, scale: (fireOffset, fireOffset),  color: col, center: (0.5, 0.5));

            // Draw ammo
            double eachSpace = DOT_SPACE / double(weapon.Ammo2.maxAmount + 1);
            double spaceLeft = -(DOT_SPACE * 0.5);
            for(int x = 0; x < weapon.Ammo2.maxAmount; x++) {
                DrawXTex(weapon.Ammo2.amount > x ? dot2Tex : dotTex, (spaceLeft + (eachSpace * (weapon.Ammo2.maxAmount - x)), 64) + offset, 0, a: alpha, color: col, center: (0.5, 0.5));
            }

        } else {
            // Draw main tex
            DrawXTex(xhairTex, (0, 12) + offset, 0, a: alpha, color: col, center: (0.5, 0));
            //DrawXTex(circTex, (0, 24) + offset, 0, a: alpha, scale: (fireOffset, fireOffset),  color: col, center: (0.5, 1));

            // Draw ammo
            double eachSpace = DOT_SPACE / double(weapon.Ammo2.maxAmount + 1);
            double spaceLeft = -(DOT_SPACE * 0.5);
            for(int x = 0; x < weapon.Ammo2.maxAmount; x++) {
                DrawXTex(weapon.Ammo2.amount > x ? dot2Tex : dotTex, (spaceLeft + (eachSpace * (weapon.Ammo2.maxAmount - x)), 20) + offset, 0, a: alpha, color: col, center: (0.5, 0.5));
            }
        }
    }
}