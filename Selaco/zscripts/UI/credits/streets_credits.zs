class HUDDrawEventHandler : EventHandler {
    uint worldTicks;
    ui uint uiTicks;

    mixin ScreenSizeChecker;
	mixin UIDrawer;
	mixin HudDrawer;
    mixin HUDScaleChecker;

    override void WorldLoaded(WorldEvent e) {
        worldTicks = 0;
    }

    override void WorldTick() {
        worldTicks++;
    }

    override void UITick() {
        if(worldTicks == 0 || screenSizeChanged() || hudScaleChanged()) {
            adjustScreenScale();
            calcTightScreen();
            calcUltrawide();
        }

        uiTicks++;
    }

    ui virtual void adjustScreenScale() {
        calcScreenScale(lastScreenSize, virtualScreenSize, screenInsets);
    }
}


class CreditsHandler : HUDDrawEventHandler {
    Objectives obj;
    int timeStarted;
    int currentCredit, currentCreditTime, currentCreditTimer;
    bool doDestroy;

    const CREDIT_TIME = 6 * TICRATE;
    const CREDIT_DELAY = 3 * TICRATE;
    const CREDIT_START_DELAY = 10 * TICRATE;
    const FADE_IN_TIME = 65;
    const FADE_OUT_TIME = TICRATE * 3;

    static const string credits[] = {
        "\c[DARKGRAY]Lead Designer\c\n    Wesley de Waart",
        "\c[DARKGRAY]Level Design\c\n    Brendan Batchelor\n    Wesley de Waart",
        "\c[DARKGRAY]Story\c\n    Ken Coghlan III",
        "\c[DARKGRAY]Code\c\n    Matthew Hayward\n    Nick London\n    Wesley de Waart",
        "\c[DARKGRAY]Artists\c\n    Max Raffa\n    Michal Borowski\n    Silvia Merconchini\n    Arturo Pahua",
        "\c[DARKGRAY]Additional Art\c\n    Yijian Fong\n    Ryan Thaesler\n    John Lloyd Claro\n    Isabel Alonso Meijias",
        "\c[DARKGRAY]Sound Design\c\n    Lawrence Steele\n    Wesley de Waart",
        "\c[DARKGRAY]Soundtrack\c\n    Lawrence Steele",
        "\c[DARKGRAY]Voicework\c\n    Melissa Medina as \c[hi]Dawn\c-\n    Ariel Hack as \c[hi]AOS\n\c-    Luis Bermudez as \c[hi]Enemy Soldiers",
        "\c[DARKGRAY]Additional Voicework\c-\n    Gianni Matragrano\n    Tom Schalk\n    Eli Diaz Idris\n    Luis Bermudez"
    };

/*     TextItem "Dawn", "", "Melissa Medina"
    TextItem "AOS", "", "Ariel Hack"
    TextItem "Gwyn", "", "Erica Muse"
    TextItem "Enemy Soldiers", "", "Luis Bermudez"
    TextItem "Juggernaut", "", "Gianni Matragrano"
    TextItem "Enforcers", "", "Tom Schalk"
    TextItem "Misc voices", "", "Eli Diaz Idris"
    TextItem "Misc voices", "", "Luis Bermudez" */

    override void OnRegister() {
        if(level.levelnum != 9) {
            doDestroy = true;
            return;
        }

        SetOrder(500);
    }

    override void WorldTick() {
        if(doDestroy && !bDestroyed) Destroy();

        Super.WorldTick();
        

        if(timeStarted > 0) {
            if(level.mapTime > timeStarted + CREDIT_START_DELAY) {
                if(--currentCreditTimer <= -CREDIT_DELAY) {
                    currentCredit++;

                    if(currentCredit < credits.size()) {
                        setCredTime();
                    } else {
                        if(!bDestroyed) {
                            doDestroy = true;
                            Destroy();
                            return;
                        }
                    }
                }
            }
            
            return;
        }

        if(!obj) {
            obj = Objectives.FindObjectives(consolePlayer);
        }

        // Start playing credits after we are given the correct objective
        // Kind of a hack, but we don't want to change the map just to start credits rolling
        if(obj) {
            if(obj.find(300)) {
                timeStarted = level.mapTime;
                currentCredit = -1;
            }
        }
    }


    void setCredTime() {
        currentCreditTime = CREDIT_TIME; //max(6 * TICRATE, credits[currentCredit].length() * 7);
        currentCreditTimer = currentCreditTime;
    }

    
    /*override void UITick() {
        Super.UITick();
    }*/


    override void RenderOverlay(RenderEvent e) {
        if(currentCredit >= credits.size() || currentCredit < 0 || currentCreditTimer <= 0) return;
        
        double a = 0.8;

        // Check for notifications, dim text if overlapping with bottom-left notification
        let i = Notification.GetItem();
        if(i && i.notifs[NotificationItem.SLOT_BOT_LEFT] != null) {
            a = 0.1;
        }

        double ticks = (-(currentCreditTimer - currentCreditTime) + e.FracTic);
        double tm = ticks <= FADE_IN_TIME ? 
                    UIMath.EaseInOutCubicF(UIMath.EaseOutCubicf(clamp(ticks / FADE_IN_TIME, 0, 1))) : 
                    UIMath.EaseInOutCubicF(1.0 - clamp((ticks - (currentCreditTime - FADE_OUT_TIME)) / FADE_OUT_TIME, 0, 1));

        // Draw credit
        //if(credits[currentCredit].length() < 90)
            DrawStrMultiline('PDA35OFONT', credits[currentCredit], (isTightScreen ? 150 : (isUltrawide ? 400 : 270), -280), 800, DR_SCREEN_BOTTOM | DR_TEXT_BOTTOM,  a: tm * a, scale: (0.62, 0.62));
        //else
        //    DrawStrMultiline('PDA35OFONT', credits[currentCredit], (isTightScreen ? 150 : (isUltrawide ? 400 : 270), -220), 800, DR_SCREEN_BOTTOM | DR_TEXT_BOTTOM,  a: tm * a, scale: (0.5, 0.5));
    }
}