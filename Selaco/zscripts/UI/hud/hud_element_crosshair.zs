class HUDElementCrosshair : HUDElementStartup {
    transient CVar hudScaleCVAR;
    transient TextureID dotTex, basicCrosshair;
    transient int basicCrosshairHeight;
    transient LookAt lookAtHandler;
    transient int simpleTimeout;

    PieDrawer throwDrawer;

    override HUDElement init() {
        Super.init();

        hudScaleCVAR = CVar.FindCVar('hud_scaling');
        dotTex = TexMan.CheckForTexture("XH_DOT3");
        lookAtHandler = LookAt(StaticEventHandler.Find("LookAt"));
        simpleTimeout = 0;
        throwDrawer = new("PieDrawer");
		throwDrawer.Init("XH_THROW");
        throwDrawer.degreesStart = 8;
        throwDrawer.degreesEnd = 45;
        basicCrosshair = TexMan.CheckForTexture("XH_DOT3");
        let sz = TexMan.GetScaledSize(basicCrosshair);
        basicCrosshairHeight = sz.x;

        makeTexReady(dotTex);
        makeTexReady(basicCrosshair);
        makeReady("XH_THROW");

        return self;
    }

    override int getOrder() { return SORT_CROSSHAIR; }

    override void onAttached(HUD owner, Dawn player) {
        Super.onAttached(owner, player);
    }

    override void onScreenSizeChanged(Vector2 screenSize, Vector2 virtualScreenSize, Vector2 insets) {
        let hudScale = hudScaleCVAR ? hudScaleCVAR.GetFloat() : HUD_SCALING_DEFAULT;
        if(hudScale < 0) hudScale = HUD_SCALING_DEFAULT;

        // HUD Scaling should not change crosshair size, so factor that out
        Super.onScreenSizeChanged(screenSize, virtualScreenSize * hudScale, (0,0));
    }

    double getCrosshairHeight() {
        if(!crosshairon) return 10 / (screenSize.y / virtualScreenSize.y);
        if(crosshairForce) return ((basicCrosshairHeight + 5) * crosshairScale) / (screenSize.y / virtualScreenSize.y);

        let weapon = SelacoWeapon(players[consolePlayer].ReadyWeapon);
        if(weapon) {
            if(weapon.activeCrosshair) {
                return weapon.activeCrosshair.getHeight() / hudScaleCVAR.GetFloat() / (screenSize.y / virtualScreenSize.y);
            }
        }

        return 0;
    }

    override bool tick() {
        if(crosshairForce) return Super.tick();

        let weapon = SelacoWeapon(players[consolePlayer].ReadyWeapon);
        if(weapon) {
            if(weapon.activeCrosshair) {
                weapon.activeCrosshair.screenSize = screenSize;
                weapon.activeCrosshair.virtualScreenSize = virtualScreenSize / crosshairScale;
                weapon.activeCrosshair.uiTick();
            }
        }

        if(lookAtHandler.lastObject is 'ElevatorButton') simpleTimeout = 10;
        if(simpleTimeout) simpleTimeout--;
        
        return Super.tick();
    }


    void drawThrowMeter(PickupableDecoration ho, Color clr, double fracTic, float alpha) {
        Vector2 scScale = getVirtualScreenScale();

        let deltaTime = (level.totalTime - ho.throwTime) + fracTic;
        double throwForce = double(clamp(deltaTime, 1, PickupableDecoration.MAX_THROW_TICKS)) / double(PickupableDecoration.MAX_THROW_TICKS);
        throwForce = UIMath.EaseOutCirc(throwForce);
        throwDrawer.degreesEnd = (throwForce * 164.0);
        throwDrawer.Build();
        let size = (128 * scScale.x, 128 * scScale.y) * crosshairScale;

        clr = Color(255, clr.b, clr.g, clr.r);  // Swap r and g because GZDoom
        Color col = UIMath.LerpC(clr, 0xFF0036D9, clamp((throwForce - 0.65), 0, 0.65) * 1.538461538461538);
        if(throwForce > 0.9) col = UIMath.LerpC(0xFF0000CC, 0xFF0036D9, sin(deltaTime * 75) * 0.5 + 0.5);
        throwDrawer.Draw((screenSize * 0.5) - (size * 0.5), size, 180, alpha, col);
    }


    // TODO: Time should be passed to these functions instead of just fracTic
    override void draw(double fracTic, float alpha, Vector2 shake, Vector2 momentum)  {
        let d = Dawn(players[consolePlayer].mo);
        let weapon = SelacoWeapon(players[consolePlayer].ReadyWeapon);
        if(!crosshairon || !weapon || !weapon.activeCrosshair) return;

        if(crosshairForce) {
            Color clr = crosshairColor | 0xFF000000;
            DrawXTex(basicCrosshair, (0,0), flags: DR_WAIT_READY, a: alpha, scale: (crosshairScale, crosshairScale), color: clr, center: (0.5, 0.5));
            
            // Draw throw meter
            let ho = PickupableDecoration(d.holdingObject);
            if(ho && ho.throwTime && ho.ThrowVel != ho.maxThrowVel) {
                drawThrowMeter(ho, clr, fracTic, alpha);
            }

            return;
        }

        Vector2 hudShake = ((shake + momentum) * 0.2) / (screenSize.y * crosshairScale * 0.005);
        
        if(d) {
            if(d.curLadder || d.holdingObject || simpleTimeout || lookAtHandler.lastObject || lookAtHandler.lastLine >= 0 || d.WaterLevel == 3) {
                // Draw simple dot
                Color clr = crosshairColor | 0xFF000000;
                DrawXTex(dotTex, (0,0), flags: DR_WAIT_READY, a: alpha, scale: (crosshairScale, crosshairScale), color: clr, center: (0.5, 0.5));
                
                // Draw throw meter if throwing
                let ho = PickupableDecoration(d.holdingObject);
                if(ho && ho.throwTime && ho.ThrowVel != ho.maxThrowVel) {
                    /*Vector2 scScale = getVirtualScreenScale();

                    let deltaTime = (level.totalTime - ho.throwTime) + fracTic;
                    double throwForce = double(clamp(deltaTime, 1, PickupableDecoration.MAX_THROW_TICKS)) / double(PickupableDecoration.MAX_THROW_TICKS);
                    throwForce = UIMath.EaseOutCirc(throwForce);
                    throwDrawer.degreesEnd = (throwForce * 164.0);
                    throwDrawer.Build();
                    let size = (128 * scScale.x, 128 * scScale.y) * crosshairScale;

                    clr = Color(255, clr.b, clr.g, clr.r);  // Swap r and g because GZDoom
                    Color col = UIMath.LerpC(clr, 0xFF0036D9, clamp((throwForce - 0.65), 0, 0.65) * 1.538461538461538);
                    if(throwForce > 0.9) col = UIMath.LerpC(0xFF0000CC, 0xFF0036D9, sin(deltaTime * 75) * 0.5 + 0.5);
                    throwDrawer.Draw((screenSize * 0.5) - (size * 0.5), size, 180, alpha, col);*/
                    drawThrowMeter(ho, clr, fracTic, alpha);
                }

                return;
            }
        }
        
        weapon.activeCrosshair.drawXHair(fracTic, alpha * crosshairalpha, hudShake);
    }
}