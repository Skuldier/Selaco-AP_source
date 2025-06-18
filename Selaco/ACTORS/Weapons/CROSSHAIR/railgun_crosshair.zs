class RailgunCrosshair : CustomCrosshair {
    ui TextureID lineTex, dotTex;
    ui Font fnt;

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
        
        lineTex     = getReady("XH_RAIL1");
        dotTex      = getReady("XH_DOT4");
        fnt         = "PDA16FONT";
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
        return virtualScreenSize.y ? (screenSize.y / virtualScreenSize.y) * 135.0 : 0;
    }

    const LINE_POS = 80.0;

    override void draw(double fracTic, double alpha, Vector2 offset) { 
        if(!weapon) return;

        if(!isReady && !(
            TexMan.MakeReady(lineTex) &&
            TexMan.MakeReady(dotTex)
        )) return;
        isReady = true;
        
        Color crosscolor = crosshaircolor;
        Color col   = Color(255, crosscolor.r, crosscolor.g, crosscolor.b);

        double time = (double(level.TotalTime) + fracTic) * ITICKRATE;
        
        double fireDelta = UIMath.EaseInQuadF(1.0 - CLAMP( ((double(level.TotalTime - fireTick) + fracTic) * ITICKRATE) / FIRE_TIME, 0.0, 1.0));
        double fireOffset = LINE_POS + (fireDelta * 5.0);

        // Draw lines
        double lineAlpha = alpha * (1.0 - (fireDelta * 0.7));
        DrawXTex(lineTex, offset + (0, fireOffset), 0, a: lineAlpha, color: col, rotation: 0, center: (0.5, 0));

        // Draw ammo
        DrawStr(fnt, String.Format("%d", weapon && weapon.Ammo1 ? weapon.Ammo1.amount : 0), (0, LINE_POS), DR_SCREEN_CENTER | DR_TEXT_HCENTER | DR_TEXT_BOTTOM, a: alpha, monospace: true);

        // Draw dot
        DrawXTex(dotTex, offset, 0, a: alpha, color: col, center: (0.5, 0.5));
    }

    override void uiTick() {
        Super.uiTick();


    }
}