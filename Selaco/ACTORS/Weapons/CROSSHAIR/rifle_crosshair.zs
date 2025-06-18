class RifleCrosshair : CustomCrosshair {
    ui TextureID circTex, circTex2, lineTex, dotTex;
    ui Shape2D lineShape;
    ui Shape2DTransform lineTransform;

    ui CircleShape16 circle;
    transient ui double lastLineLength;

    uint grenadeStartTicks;
    bool isGrenadeMode, isBurstMode;

    const LINE_IDLE_LENGTH = 19.0;
    const LINE_FIRE_LENGTH = 28.0;
    const ZOOM_TIME = 0.21;
    const FIRE_TIME = 0.25;
    const GRENADE_FIRE_TIME = 0.45;
    const GRENADE_TIME = 0.21;

    const INNER_UV = 104. / 128.;
    const OUTER_UV = 116. / 128.;

    override void init() {
        Super.init();
    }

    override void uiInit() {
        Super.uiInit();
        
        lineTex = getReady("XH_DASH1");
        dotTex  = getReady("XH_DOT1");

        if(!lineShape) lineShape = new("Shape2D");
        if(!lineTransform) lineTransform = new("Shape2DTransform");

        circle.init("XH_CIRC8", 31.5, 12, INNER_UV, OUTER_UV);
        makeTexReady(circle.tex.texID);
    }

    override void attach(SelacoWeapon weapon) {
        Super.attach(weapon);
    }

    override void detach() {
        Super.detach();
    }

    override double getHeight() {
        return virtualScreenSize.y ? (screenSize.y / virtualScreenSize.y) * (60.0 + (spread > 5 ? 15 : 0)) : 0;
    }

    override void tick() {
        //Super.tick(); // Don't tick super anymore, because we want to hijack the zoom code

        Rifle r = Rifle(weapon);
        if(r) {
            if(weapon.isZooming != zooming) {
                zoomTick = level.TotalTime;
                zooming = weapon.isZooming;
            }

            if(weapon.supportsADS && level.totalTime % 36 == 0) {
                useADS = weapon.getCvar("g_ironsights") > 0;
            }

            deltaSpread = spread;
            spread = weapon.adjustedSpread;

            // Check for grenade launcher activation
            if(r.isGrenadeLauncherMode != isGrenadeMode) {
                grenadeStartTicks = level.TotalTime;
                isGrenadeMode = r.isGrenadeLauncherMode;
            }
            
            isBurstMode = r.burstFireModeHipfire;

            bool wasStunned = stunned;
            stunned = weapon.owner.countinv("CooldownStunned") > 0;
            if(stunned != wasStunned) stunnedTick = level.TotalTime;

            bool wasHopping = hasBunnyHop;
            hasBunnyHop = weapon.owner.countinv("BunnyHopDuration") > 0;
            if(hasBunnyHop != wasHopping) hoppingTick = level.TotalTime;

        }
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
            TexMan.MakeReady(dotTex) &&
            TexMan.MakeReady(lineTex) &&
            TexMan.MakeReady(circle.tex.texID)
        )) return;
        isReady = true;

        Color crosscolor = crosshaircolor;
        Color col   = Color(255, crosscolor.r, crosscolor.g, crosscolor.b);
        Color col2  = Color(255, crosscolor.b, crosscolor.g, crosscolor.r);
        Vector2 scScale = getVirtualScreenScale();
        Vector2 center = (screenSize * 0.5) + offset;

        double spreadVal = UIMath.Lerpd(deltaSpread, spread, fracTic) / 2.75;
        //Vector2 circleScale = (1,1) * MAX(1.0, weapon.adjustedSpread);
    
        double time = (double(level.TotalTime) + fracTic) * ITICKRATE;
        double grenadeTime = (double(level.TotalTime - grenadeStartTicks) + fracTic) * ITICKRATE;
        double zoomTime = (double(level.TotalTime - zoomTick) + fracTic) * ITICKRATE;
        double zoomFactor = CLAMP(zoomTime / ZOOM_TIME, 0.0, 1.0);
        double grenadeFactor = CLAMP(grenadeTime / GRENADE_TIME, 0.0, 1.0);
        if(!zooming) zoomFactor = 1.0 - zoomFactor;
        if(!isGrenadeMode) grenadeFactor = 1.0 - grenadeFactor;

        double zoomRotation, lineLength, fireDelta, fireOffset, lineOffset, circAlpha, lineAlpha;

        fireDelta = 1.0 - CLAMP( ((double(level.TotalTime - fireTick) + fracTic) * ITICKRATE) / (isGrenadeMode ? GRENADE_FIRE_TIME : FIRE_TIME), 0.0, 1.0);
        fireOffset = fireDelta * (zooming ? 20.0 : (isGrenadeMode ? 32 : 20.0));

        if(!isBurstMode) {
            zoomRotation = zoomFactor * 90.0;
            lineLength = MAX(grenadeFactor * 32, MAX(zoomFactor * 32, 19));
            lineOffset = (UIMath.Lerpd(spreadVal * 12, spreadVal * 18, UIMath.EaseOutCubicf(1.0 - zoomFactor)) * (1.0 - grenadeFactor)) + fireOffset;
            lineOffset += grenadeFactor * 5.0;
            lineOffset += 18.0 * stunnedFactor;
            lineOffset -= 18.0 * hoppingFactor;
            circAlpha = alpha * (1.0 - (MAX(zoomFactor, grenadeFactor) * 0.9));
            lineAlpha = alpha * (1.0 - MIN(0.5, zoomFactor * 0.5));

            // Draw dot
            if(zoomFactor > 0) DrawXTex(dotTex, (0,0), 0, a: alpha * zoomFactor, color: col, center: (0.5, 0.5));
        } else {
            zoomRotation = 90 + zoomFactor * 90.0;
            lineLength = 32;
            
            lineOffset = (spreadVal * 12) + fireOffset;
            lineOffset += grenadeFactor * 5.0;
            lineOffset += 18.0 * stunnedFactor;
            lineOffset -= 18.0 * hoppingFactor;
            circAlpha = alpha * 0.15;
            lineAlpha = alpha * 0.5;

            // Draw dot
            DrawXTex(dotTex, (0,0), 0, a: alpha, color: col, center: (0.5, 0.5));
        }


        circle.setRadius(spreadVal * 31.5 + (stunnedFactor * 5.0), 12);
        circle.setRadius(spreadVal * 31.5 - (hoppingFactor * 5.0), 12);
        circle.draw(center, scScale, col2, circAlpha, zoomRotation);

        // Draw lines
        buildLineShape(lineLength);
        
        // Top
        lineTransform.clear();
        lineTransform.rotate(180);
        lineTransform.translate((0, -lineOffset));
        lineTransform.rotate(zoomRotation);
        lineTransform.scale(scScale);
        lineTransform.translate(center);
        lineShape.setTransform(lineTransform);
        Screen.drawShape(
            lineTex, 
            false,
            lineShape,
            DTA_Alpha, lineAlpha * (1.0 - grenadeFactor),
            DTA_Filtering, true,
            DTA_Color, col2
        );

        // Right
        lineTransform.clear();
        lineTransform.rotate(-90);
        lineTransform.translate((lineOffset, 0));
        lineTransform.scale(scScale);
        lineTransform.rotate(zoomRotation);
        lineTransform.translate(center);
        lineShape.setTransform(lineTransform);
        Screen.drawShape(
            lineTex, 
            false,
            lineShape,
            DTA_Alpha, lineAlpha,
            DTA_Filtering, true,
            DTA_Color, col2
        );

        // Bottom
        lineTransform.clear();
        lineTransform.translate((0, lineOffset));
        lineTransform.rotate(zoomRotation);
        lineTransform.scale(scScale);
        lineTransform.translate(center);
        lineShape.setTransform(lineTransform);
        Screen.drawShape(
            lineTex, 
            false,
            lineShape,
            DTA_Alpha, lineAlpha,
            DTA_Filtering, true,
            DTA_Color, col2
        );

        // Left
        lineTransform.clear();
        lineTransform.rotate(90);
        lineTransform.translate((-lineOffset, 0));
        lineTransform.rotate(zoomRotation);
        lineTransform.scale(scScale);
        lineTransform.translate(center);
        lineShape.setTransform(lineTransform);
        Screen.drawShape(
            lineTex, 
            false,
            lineShape,
            DTA_Alpha, lineAlpha,
            DTA_Filtering, true,
            DTA_Color, col2
        );

    }

    override void uiTick() {
        Super.uiTick();


    }
}