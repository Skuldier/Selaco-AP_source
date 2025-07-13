class HUDElementCountdown : HUDElement {
    ShootingRangeHandler range;

    uint countdownTime;
    int countDown;
    bool countdownStarted;

    override HUDElement init() {
        Super.init();
        countdown = 0;

        return self;
    }


    override void onAttached(HUD owner, Dawn player) {
        Super.onAttached(owner, player);

        if(!range) range = ShootingRangeHandler(EventHandler.Find("ShootingRangeHandler"));
    }


    override void onWeaponChanged(SelacoWeapon oldWeapon, SelacoWeapon newWeapon) {
        Super.onWeaponChanged(oldWeapon, newWeapon);
    }


    override bool tick() {
        // Update stats
        if(!range) range = ShootingRangeHandler(EventHandler.Find("ShootingRangeHandler"));
        if(range) {
            let lastCountdown = countDown;
            countDown = (range.countDown / TICRATE) + 1;
            if(countdown != lastCountdown) {
                countdownTime = ticks;
                countdownStarted = true;
            }

            // We have fully counted down! 
            if(countdown == 1 && ticks - lastCountdown >= TICRATE - 1) {
                return true;
            }
        }

        return level.levelnum != ShootingRangeHandler.SHOOTINGRANGE_LEVEL_NUM || Super.tick();
    }


    override void draw(double fracTic, float alpha, Vector2 shake, Vector2 momentum)  {
        if(!range) return;

        double time = (ticks + fracTic) * ITICKRATE;
        Font titleFnt = "SEL52FONT";

        // Draw countdown
        if(countdown > 0 && countdown < 4) {
            double time = (ticks - countdownTime + fracTic) * ITICKRATE;

            if(time >= 0.16) {
                double tm2 = clamp((time - 0.16) / 0.16, 0.0, 1.1);
                double a2 = 1.0 - UIMath.EaseOutCubicf(tm2);
                double scale2 = 2.0 + (UIMath.EaseOutCubicf(tm2) * 1.5);

                if(tm2 <= 1.0) {
                    DrawStr(
                        titleFnt, 
                        String.Format("%d", countdown), 
                        (0, -300),
                        DR_SCREEN_CENTER | DR_TEXT_CENTER, 
                        Font.CR_UNTRANSLATED, 
                        a2 * 0.5,
                        false,
                        scale: (scale2, scale2)
                    );
                }
            }

            double tm = clamp(time / 0.16, 0.0, 1.0);
            double a = UIMath.EaseOutCubicf(tm);
            double scale = 2.0 + ((1.0 - UIMath.EaseOutCubicf(tm)) * 3.5);

            DrawStr(
                titleFnt, 
                String.Format("%d", countdown), 
                (0, -300),
                DR_SCREEN_CENTER | DR_TEXT_CENTER, 
                Font.CR_UNTRANSLATED, 
                a,
                false,
                scale: (scale, scale)
            );
        }
    }
}