class SMGCrosshair : CustomCrosshair {
    ui TextureID lineTex, dotTex;
    ui Shape2D lineShape;
    ui Shape2DTransform lineTransform;
    transient ui double lastLineLength;

    const LINE_IDLE_LENGTH = 30.0;
    const LINE_FIRE_LENGTH = 50.0;

    const MAX_SPREAD = 3.4;
    const MIN_SPREAD = 1.0;

    const ZOOM_TIME = 0.18;
    const FIRE_TIME = 0.18;


    override void init() {
        Super.init();
    }

    override void uiInit() {
        Super.uiInit();
        
        lineTex     = getReady("XH_DASH1");
        dotTex      = getReady("XH_DOT4");

        if(!lineShape) lineShape = new("Shape2D");
        if(!lineTransform) lineTransform = new("Shape2DTransform");
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
        return virtualScreenSize.y > 0 ? (screenSize.y / virtualScreenSize.y) * 115 : 0;
    }

    ui void buildLineShape(double len = 16) {
        if(lineShape && len ~== lastLineLength) return;

        if(!lineShape) lineShape = new("Shape2D");
        else lineShape.clear();
        if(!lineTransform) lineTransform = new("Shape2DTransform");

        int vertCount;
        Shape2DHelper.AddQuadRawUV(lineShape, (-4,0),        (8, 6),         (0,0),      (1, 0.375),  vertCount);
        Shape2DHelper.AddQuadRawUV(lineShape, (-4,6),        (8, len - 12),  (0,0.375),  (1, 0.625),  vertCount);
        Shape2DHelper.AddQuadRawUV(lineShape, (-4,len - 6),  (8, 6),         (0,0.625),  (1, 1),      vertCount);

        lastLineLength = len;
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
        Color col2  = Color(255, crosscolor.b, crosscolor.g, crosscolor.r);
        Vector2 scScale = getVirtualScreenScale();
        Vector2 center = (screenSize * 0.5) + offset;

        double spreadVal = (UIMath.Lerpd(deltaSpread, spread, fracTic) - MIN_SPREAD) / (MAX_SPREAD - MIN_SPREAD);
        double time = (double(level.TotalTime) + fracTic) * ITICKRATE;
        double zoomTime = (double(level.TotalTime - zoomTick) + fracTic) * ITICKRATE;
        double zoomFactor = CLAMP(zoomTime / ZOOM_TIME, 0.0, 1.0);
        if(!zooming) zoomFactor = 1.0 - zoomFactor;
        
        double fireDelta = UIMath.EaseOutCubicF(1.0 - CLAMP( ((double(level.TotalTime - fireTick) + fracTic) * ITICKRATE) / FIRE_TIME, 0.0, 1.0));
        //double fireOffset = (fireDelta * (zooming ? 15.0 : 10.0));

        double lineLength = UIMath.Lerpd(LINE_IDLE_LENGTH, LINE_FIRE_LENGTH, (fireDelta * 0.25) + (spreadVal * 0.75));
        double lineOffset = UIMath.Lerpd(13, -4, zoomFactor) + ((40. * spreadVal) * ((fireDelta * 0.35) + 1.));
        lineOffset += 20.0 * (0.35 * stunnedFactor);
        lineOffset -= 50.0 * (0.35 * hoppingFactor);
        
        // Draw lines
        buildLineShape(lineLength);
        
        // Bottom
        lineTransform.clear();
        lineTransform.translate((0, lineOffset));
        lineTransform.scale(scScale);
        lineTransform.translate(center);
        lineShape.setTransform(lineTransform);
        Screen.drawShape(
            lineTex, 
            false,
            lineShape,
            DTA_Alpha, alpha,
            DTA_Filtering, true,
            DTA_Color, col2
        );

        // Left
        lineTransform.clear();
        lineTransform.translate((0, lineOffset));
        lineTransform.rotate(90);
        lineTransform.scale(scScale);
        lineTransform.translate(center);
        lineShape.setTransform(lineTransform);
        Screen.drawShape(
            lineTex, 
            false,
            lineShape,
            DTA_Alpha, alpha,
            DTA_Filtering, true,
            DTA_Color, col2
        );

        // Top
        lineTransform.clear();
        lineTransform.translate((0, lineOffset));
        lineTransform.rotate(180);
        lineTransform.scale(scScale);
        lineTransform.translate(center);
        lineShape.setTransform(lineTransform);
        Screen.drawShape(
            lineTex, 
            false,
            lineShape,
            DTA_Alpha, alpha,
            DTA_Filtering, true,
            DTA_Color, col2
        );

        // Right
        lineTransform.clear();
        lineTransform.translate((0, lineOffset));
        lineTransform.rotate(270);
        lineTransform.scale(scScale);
        lineTransform.translate(center);
        lineShape.setTransform(lineTransform);
        Screen.drawShape(
            lineTex, 
            false,
            lineShape,
            DTA_Alpha, alpha,
            DTA_Filtering, true,
            DTA_Color, col2
        );


        // Draw dot
        DrawXTex(dotTex, offset, 0, a: alpha, color: col, center: (0.5, 0.5));
    }

    override void uiTick() {
        Super.uiTick();


    }
}