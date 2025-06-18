class DMRCrosshair : CustomCrosshair {
    transient ui TextureID lineTex, dotTex;
    transient ui Shape2D lineShape;
    transient ui Shape2DTransform lineTransform;
    transient ui HUDElementDMRUnderlay underlay;
    transient ui double lastLineLength;

    const LINE_IDLE_LENGTH = 60.0;
    const LINE_FIRE_LENGTH = 120.0;

    const MAX_SPREAD = 4.0;
    const MIN_SPREAD = 0.15;

    const ZOOM_TIME = 0.22;
    const FIRE_TIME = 0.25;


    override void init() {
        Super.init();
    }

    override void uiInit() {
        Super.uiInit();
        
        lineTex     = TexMan.CheckForTexture("XH_DASH4");
        dotTex      = TexMan.CheckForTexture("XH_DOT4");
        makeTexReady(lineTex);
        makeTexReady(dotTex);

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
        return virtualScreenSize.y ? (screenSize.y / virtualScreenSize.y) * 135.0 : 0;
    }

    ui void buildLineShape(double len = 16) {
        if(lineShape && len ~== lastLineLength) return;

        if(!lineShape) lineShape = new("Shape2D");
        else lineShape.clear();
        if(!lineTransform) lineTransform = new("Shape2DTransform");

        int vertCount;
        Shape2DHelper.AddQuadRawUV(lineShape, (-4,0),        (8, 6),         (0,0),         (1, 0.1875),    vertCount);
        Shape2DHelper.AddQuadRawUV(lineShape, (-4,6),        (8, len - 31),  (0,0.1875),    (1, 0.25),      vertCount);
        Shape2DHelper.AddQuadRawUV(lineShape, (-4,len - 31), (8, 25),        (0,0.25),      (1, 1),         vertCount);

        lastLineLength = len;
    }

    override void draw(double fracTic, double alpha, Vector2 offset) { 
        if(!weapon) return;

        if(!isReady && !(
            TexMan.MakeReady(dotTex) &&
            TexMan.MakeReady(lineTex)
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
        double lineOffset = UIMath.Lerpd(24, 50, zoomFactor) + ((80. * spreadVal) * ((fireDelta * 0.25) + 1.));
        lineOffset += 16.0 * stunnedFactor;
        lineOffset -= 16.0 * hoppingFactor;
        if(weapon is "DMR" && DMR(weapon).bipodMode)
        {
            lineOffset -= 20.0;
        }
        // Draw lines
        buildLineShape(lineLength);
        
        /*if(zoomFactor > 0.001) {
            let scopeSize = ((virtualScreenSize.y * 1.1) / (dmrTex.size.y / dmrTex.size.x), virtualScreenSize.y * 1.1);
            DrawXTex(dmrTex.texID, offset * 2.0, DR_SCALE_IS_SIZE, a: alpha * (zoomFactor * zoomFactor * zoomFactor * zoomFactor * zoomFactor), scale: scopeSize, color: col, center: (0.5, 0.5));
        }*/

        alpha *= 1.0 - UIMath.EaseInCubicF(UIMath.EaseInCubicF(zoomFactor));

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

        if(!underlay) {
            underlay = HUDElementDMRUnderlay(HUD.FindElement('HUDElementDMRUnderlay'));
            if(underlay) underlay.assignCrosshair(self);
        }
    }
}



class HUDElementDMRUnderlay : HUDElementStartup {
    UISTexture dmrTex, dotTex, dotTex2, dotTex3, xhairTex;
    uint zoomTick, magZoomTick;
    bool zooming, enabled, magnifiedZoom, charging;
    DMRCrosshair xhair;
    int chargeTicks;

    Shape2D shape;
    Shape2DTransform shapeTransform;

    const ZOOM_TIME = 0.25 - (ITICKRATE * 2);
    const ZOOM_TIME_TICKS = int(ceil(ZOOM_TIME * 35.0));
    const MAG_ZOOM_TIME = 0.14;
    const FIRE_TIME = 0.7;
    const FIRE_TIME_TICKS = int(ceil(FIRE_TIME * 35.0));

    override int getOrder() { return SORT_UNDERLAY; }

    override HUDElement init() {
        Super.init();

        dmrTex.get("XH_DMR2");
        xhairTex.get("XH_DMR3");
        dotTex.get("XH_DMR4");
        dotTex2.get("XH_DMR5");
        dotTex3.get("XH_DMR6");

        dmrTex.makeReady();
        xhairTex.makeReady();
        dotTex.makeReady();
        dotTex2.makeReady();
        dotTex3.makeReady();

        return self;
    }

    ui void assignCrosshair(DMRCrosshair xhair) {
        self.xhair = xhair;
    }

    ui void removeCrosshair(DMRCrosshair xhair) {
        if(xhair == self.xhair) {
            self.xhair = null;
        }
    }

    override void onScreenSizeChanged(Vector2 screenSize, Vector2 virtualScreenSize, Vector2 insets) { 
        Super.onScreenSizeChanged(screenSize, virtualScreenSize, insets);

        buildShape();
    }

    override void onAttached(HUD owner, Dawn player) {
        Super.onAttached(owner, player);

        buildShape();
    }


    // Extend the edges of the shape to the full screen width
    void buildShape() {
        if(!shape) shape = new("Shape2D");
        else shape.clear();
        if(!shapeTransform) shapeTransform = new("Shape2DTransform");
    
        Vector2 screenSize2 = screenSize * 0.5;
        Vector2 scopeSize = (screenSize.y / (dmrTex.size.y / dmrTex.size.x), screenSize.y);
        Vector2 scopeSize2 = scopeSize * 0.5;
        double stretch = (screenSize.x - scopeSize.x) * 0.75;
        

        int vertCount;

        // Left stretched texture
        Shape2DHelper.AddQuadRawUV(shape, (-scopeSize2.x - stretch, -screenSize2.y), (stretch, screenSize.y), (0, 0), (-0.016, 1), vertCount);

        // Scope center
        Shape2DHelper.AddQuadRawUV(shape, (-scopeSize2.x, -screenSize2.y), (scopeSize.x, screenSize.y), (0,0), (1, 1), vertCount);

        // Right stretched texture
        Shape2DHelper.AddQuadRawUV(shape, (scopeSize2.x, -screenSize2.y), (stretch, screenSize.y), (1, 0), (0.984, 1), vertCount);
    }


    override bool tick() {
        let weapon = SelacoWeapon(players[consolePlayer].ReadyWeapon);
        if(weapon) {
            let deemr = DMR(weapon);

            if(weapon.isZooming != zooming) {
                if(level.TotalTime - zoomTick < ZOOM_TIME_TICKS) zoomTick = level.TotalTime - (level.TotalTime - zoomTick);
                else zoomTick = level.TotalTime;
                
                zooming = weapon.isZooming;

                magnifiedZoom = deemr && deemr.magnifiedZoom;
                magZoomTick = magnifiedZoom ? level.TotalTime : 0;
            } else if(deemr && (deemr.magnifiedZoom != magnifiedZoom)) {
                magnifiedZoom = deemr.magnifiedZoom;
                magZoomTick = level.TotalTime;
            }

            if(deemr) {
                charging = deemr.hasUpgradeClass('AltfireDMRZoomCharger');
                chargeTicks = deemr.chargeTime;
            } else {
                charging = 0;
            }
        }

        enabled = weapon is 'DMR';
        return Super.tick();
    }


    override void draw(double fracTic, float alpha, Vector2 shake, Vector2 momentum)  {
        if(!enabled) return;
        
        double time = (double(level.TotalTime) + fracTic) * ITICKRATE;
        double zoomTime = (double(level.TotalTime - zoomTick) + fracTic) * ITICKRATE;
        double zoomFactor = CLAMP(zoomTime / ZOOM_TIME, 0.0, 1.0);

        if(!zooming) zoomFactor = 1.0 - zoomFactor;
        
        if(zoomFactor > 0.001) {
            if(!shape) buildShape();
            if(dmrTex.makeReady() && dotTex.makeReady() && xhairTex.makeReady() && (!charging || (dotTex2.makeReady() && dotTex3.makeReady()))) {
                double magZoomTime = (double(level.TotalTime - magZoomTick) + fracTic) * ITICKRATE;
                double magZoomFactor = CLAMP(magZoomTime / MAG_ZOOM_TIME, 0.0, 1.0);
                if(!magnifiedZoom) magZoomFactor = 1.0 - magZoomFactor;

                double fireTime = xhair ? (double(level.TotalTime - xhair.fireTick) + fracTic) * ITICKRATE : -9999;
                double fireFactor = clamp(fireTime / FIRE_TIME, 0.0, 1.0);

                Vector2 scScale = getVirtualScreenScale();
                Vector2 offset = (-shake * (magnifiedZoom ? 0.65 : 1.0)) + momentum;
                Vector2 offset2;
                Vector2 scale = (1.1, 1.1);
                alpha = alpha * (zoomFactor * zoomFactor * zoomFactor * zoomFactor * zoomFactor * zoomFactor);

                if(fireFactor > 0) {
                    let ff = UIMath.EaseOutQuartf(fireFactor);
                    double z = sin(ff * 180.0);
                    scale += (z,z) * (magnifiedZoom ? 0.25 : 0.2);

                    ff = UIMath.EaseOutBackF(fireFactor);
                    z = sin(ff * 180.0);
                    double sina = sin((z * z * 90) - 90.0 + (xhair.fireTick % 90 - 45));
                    double cosa = cos((z * z * 90) - 90.0 + (xhair.fireTick % 90 - 45));
                    let off =   ( 45 * cosa - 90 * sina, 
                                45 * sina + 90 * cosa );
                    offset2 = z * off * (magnifiedZoom ? 1.0 : 0.7);
                }

                scale -= (0.13, 0.13) * (1.0 - UIMath.EaseInOutCubicF(zoomFactor));

                if(charging) {
                    double charged = min(1.0, UIMath.EaseInCubicF((chargeTicks + fracTic) / double(DMR.CHARGE_ZOOM_THRESHOLD)));
                    double chargeAlpha = charged >= 0.99 ? 1.0 : charged * 0.5;
                    
                    DrawXTex(dotTex2.texID, (offset * 0.3) + offset2, 0, a: alpha * chargeAlpha, scale: scale * (1.0 + (magZoomFactor * -0.1)) * (2.3 - charged * 1.3), center: (0.5, 0.5));
                    DrawXTex(dotTex3.texID, (offset * 0.3) + offset2, 0, a: alpha,  scale: scale * (0.5 + charged * 0.2), center: (0.5, 0.5));
                } else {
                    DrawXTex(dotTex.texID, (offset * 0.3) + offset2, 0, a: alpha, scale: scale * (1.0 + (magZoomFactor * -0.1)), center: (0.5, 0.5));
                }
                
                DrawXTex(xhairTex.texID, (offset * 0.5) + offset2, 0, a: alpha, scale: scale * (1.0 + (magZoomFactor * -0.1)), center: (0.5, 0.5));

                offset = (offset.x * scScale.x, offset.y * scScale.y);
                shapeTransform.clear();
                shapeTransform.scale(scale * (1.0 + (magZoomFactor * 0.1)));
                shapeTransform.translate((screenSize * 0.5) + offset + offset2);
                shape.setTransform(shapeTransform);
                Screen.drawShape(
                    dmrTex.texID, 
                    false,
                    shape,
                    DTA_Alpha, alpha,
                    DTA_Filtering, true
                );
            }
        }
    }
}