class HUDElementShootingRange : HUDElement {
    TextureID underlineID, bgID;
    ShootingRangeHandler range;
    float accuracy;
    string gameMode, targetMode;
    int fadeOutTime;

    override HUDElement init() {
        Super.init();

        underlineID = TexMan.CheckForTexture("HUDRNGLN");
        bgID = TexMan.CheckForTexture("HUDRANGE");
        gameMode = "Unknown";
        targetMode = "Unknown";

        return self;
    }

    void startFadeOut() {
        fadeOutTime = level.totalTime;
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
            gameMode = range.getGameMode();
            targetMode = range.getDistanceMode();
            accuracy = range.getAccuracy();
        }

        if(fadeOutTime > 0 && level.totalTime >= fadeOutTime + 35) return true; // Remove after fade out

        return level.levelnum != ShootingRangeHandler.SHOOTINGRANGE_LEVEL_NUM || Super.tick();
    }

    const spacing = 30;
    const baseline = 155;

    override void draw(double fracTic, float alpha, Vector2 shake, Vector2 momentum)  {
        if(!range) return;

        double time = (ticks + fracTic) * ITICKRATE;
        //double ctime = time - (changeTicks * ITICKRATE);
        
        Font titleFnt = "SEL46FONT";
        Font txtFnt = "PDA18FONT";

        double alpha = 1;
        Vector2 tl = (83, 114);

        // Calc fade out
        if(fadeOutTime > 0) {
            alpha *= 1.0 - ((double(level.totalTime - fadeOutTime) + fracTic) / 35.0 );
        }

        // Draw background
        DrawTexAdvanced(bgID, tl, 0, a: alpha);

        // Draw title
        DrawStr(
            titleFnt, 
            StringTable.Localize("$SHOOTINRANGE"), 
            tl + (128,  65), 
            DR_TEXT_BOTTOM, 
            Font.CR_UNTRANSLATED, 
            alpha,
            false,
            scale: (0.75, 0.65)
        );

        // Draw time
        DrawStr(
            titleFnt, 
            String.Format("\c[HI2]%02d:%02d", range.minutes, range.seconds), 
            tl + (130,  130), 
            DR_TEXT_BOTTOM, 
            Font.CR_UNTRANSLATED, 
            alpha,
            true,
            scale: (0.78, 0.79)
        );

        // Draw game mode
        float titleWidth = 140 + DrawStr(
            titleFnt, 
            gameMode, 
            tl + (250,  130), 
            DR_TEXT_BOTTOM, 
            Font.CR_UNTRANSLATED, 
            alpha,
            false,
            scale: (0.78, 0.79)
        );

        // Draw underline
        DrawTexAdvanced(underlineID, tl + (125, 130), DR_SCALE_IS_SIZE, a: alpha, scale: (titleWidth, 12));

        // Draw stats
        /*DrawStr(txtFnt, "Game Mode:",           tl + (100,  160), 0, Font.CR_UNTRANSLATED, alpha, false);
        DrawStr(txtFnt, gameMode,               tl + (330,  160), 0, Font.CR_UNTRANSLATED, alpha, false);*/
        DrawStr(txtFnt, String.Format("\c[HI2]%s:", StringTable.Localize("$SHOOTINGRANGE_TARGETDISTANCE")),      tl + (100,  baseline), 0, Font.CR_UNTRANSLATED, alpha, false);
        DrawStr(txtFnt, targetMode,             tl + (330,  baseline), 0, Font.CR_UNTRANSLATED, alpha, false);

        DrawStr(txtFnt, String.Format("\c[HI2]%s:", StringTable.Localize("$SHOOTINGRANGE_TARGETHITS")),         tl + (100,    baseline + (spacing * 1)), 0, Font.CR_UNTRANSLATED, alpha, false);
        DrawStr(txtFnt, String.Format("%d (%d %s)", range.shotsFired, range.shotsFired - range.targetHits, StringTable.Localize("$SHOOTINGRANGE_MISSED")), tl + (330,  baseline + (spacing * 1)), 0, Font.CR_UNTRANSLATED, alpha, false);

        DrawStr(txtFnt, String.Format("\c[HI2]%s:", StringTable.Localize("$SHOOTINGRANGE_ACCURACY")),            tl + (100,    baseline + (spacing * 2)), 0, Font.CR_UNTRANSLATED, alpha, false);
        DrawStr(txtFnt, String.Format("%0.2f%%", accuracy), tl + (330,  baseline + (spacing * 2)), 0, Font.CR_UNTRANSLATED, alpha, false);

        DrawStr(txtFnt, String.Format("\c[HI2]%s:", StringTable.Localize("$SHOOTINGRANGE_HEADSHOTS")),           tl + (100,    baseline + (spacing * 3)), 0, Font.CR_UNTRANSLATED, alpha, false);
        DrawStr(txtFnt, String.Format("%d", range.targetHeadshots), tl + (330,  baseline + (spacing * 3)), 0, Font.CR_UNTRANSLATED, alpha, false);

        if(range.gameModeID != range.RANGE_MODE_PUNCHINGBAG)
        {
            DrawStr(txtFnt, String.Format("\c[HI2]%s:", StringTable.Localize("$SHOOTINGRANGE_TARGETSKILLED")),           tl + (100,    baseline + (spacing * 4)), 0, Font.CR_UNTRANSLATED, alpha, false);
            DrawStr(txtFnt, String.Format("%d / %d", range.targetsKilled - range.targetsMissed, range.targetsKilled), tl + (330,  baseline + (spacing * 4)), 0, Font.CR_UNTRANSLATED, alpha, false);
        }

        DrawStr(txtFnt, String.Format("\c[HI2]%s:", StringTable.Localize("$SHOOTINGRANGE_LASTSHOT")),           tl + (100,    baseline + (spacing * 5)), 0, Font.CR_UNTRANSLATED, alpha, false);
        DrawStr(txtFnt, String.Format("%d %s", range.shotDamage, StringTable.Localize("$SHOOTINGRANGE_DAMAGE")), tl + (330,  baseline + (spacing * 5)), 0, Font.CR_UNTRANSLATED, alpha, false);

        DrawStr(txtFnt, String.Format("\c[HI2]%s:", StringTable.Localize("$SHOOTINGRANGE_DPS")),                 tl + (100,    baseline + (spacing * 6)), 0, Font.CR_UNTRANSLATED, alpha, false);
        DrawStr(txtFnt, String.Format("%d", range.highestRecentDPS), tl + (330,  baseline + (spacing * 6)), 0, Font.CR_UNTRANSLATED, alpha, false);

        if(range.gameModeID != range.RANGE_MODE_PUNCHINGBAG)
        {
            DrawStr(txtFnt, String.Format("\c[WHITE]%s:", StringTable.Localize("$SHOOTINGRANGE_SCORE")),                 tl + (100,    baseline + (spacing * 8)), 0, Font.CR_UNTRANSLATED, alpha, false);
            DrawStr(txtFnt, String.Format("%d", range.score), tl + (330,  baseline + (spacing * 8)), 0, Font.CR_UNTRANSLATED, alpha, false);
        }
    }
}