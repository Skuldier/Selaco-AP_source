// Temporary: Shows grenade launcher mode when equipped or changing modes
class HUDElementGL : HUDElementStartup {
    int mode, lastMode;
    GrenadeLauncher gl;
    double rot, deltaRot;
    uint changeTicks;

    static const String grenadeName[] = { 
		"\c[WARNR]FRAG GRENADE\c- SELECTED",
		"\cyICE GRENADE\c- SELECTED",
		"\c[GREEN]ACID GRENADE\c- SELECTED"
	};

    static const String grenadeIcon[] = {
        "P_GRENA4",
        "P_GRENA5",
        "P_GRENA6"
    };

    const WARNINGLEN_TIME = 3.0;
    const WARNING_FADE_TIME = 0.45;
    const WARNING_FADE_START = WARNINGLEN_TIME - WARNING_FADE_TIME;
    const WARNING_FADE_IN = 0.12;
    const WARNINGLEN_TICKS = int(ceil((WARNINGLEN_TIME + WARNING_FADE_TIME) * TICRATE));
    
    const CHANGE_TIME = 0.15;

    TextureID grenadeIconIDs[3];
    TextureID curTexture;
    String curName;
    double crosshairOffset;
    bool noShow;
    class<SelacoAmmo> playerThrowableCurrent;

    override HUDElement init() {
        Super.init();

        gl = GrenadeLauncher(players[consolePlayer].ReadyWeapon);
        mode = gl ? gl.swappingID : -1;
        changeTicks = 0;

        for(int x = 0; x < grenadeIcon.size(); x++) {
            TextureID texID = TexMan.checkForTexture(grenadeIcon[x]);
            grenadeIconIDs[x] = texID;
        }

        return self;
    }

    override void onAttached(HUD owner, Dawn player) {
        Super.onAttached(owner, player);

        gl = GrenadeLauncher(players[consolePlayer].ReadyWeapon);
        mode = gl ? gl.swappingID : -1;
        changeTicks = 0;
    }

    override void onWeaponChanged(SelacoWeapon oldWeapon, SelacoWeapon newWeapon) {
        Super.onWeaponChanged(oldWeapon, newWeapon);

        gl = GrenadeLauncher(newWeapon);
        if(gl) {
            lastMode = mode = gl.swappingID;
        }
    }

    override bool tick() {
        if(gl) {
            lastMode = mode;
            mode = gl.swappingID;

            if(lastMode != mode) {
                curName = grenadeName[mode];
                curTexture = grenadeIconIDs[mode];
                changeTicks = ticks;
            }
        }

        // Check for player grenade swap
        let d = Dawn(players[consolePlayer].mo);
        if(d) {
            if(!playerThrowableCurrent) playerThrowableCurrent = d.equippedThrowable.getClass();
            if(d.equippedThrowable && d.equippedThrowable.getClass() != playerThrowableCurrent) {
                S_STARTSOUND("ui/SWAPTHRO", CHAN_VOICE, CHANF_UI, snd_sfxvolume);
                playerThrowableCurrent = d.equippedThrowable.getClass();
                let def = GetDefaultByType(playerThrowableCurrent);
                curTexture = def.icon;
                curName = String.Format("%s (%d/%d)", StringTable.Localize(def.AmmoName), d.equippedThrowable.Amount, d.equippedThrowable.MaxAmount);
                changeTicks = ticks;
            }
        }
        

        if(changeTicks != 0) {
            noShow = false;

            if(ticks - changeTicks > WARNINGLEN_TICKS) {
                changeTicks = 0;
            } else if(ticks - changeTicks < WARNINGLEN_TICKS) {
                crosshairOffset = owner.calcCrosshairHeight();

                if(Level.totalTime - d.medkitLastFailure < 35) {
                    crosshairOffset += 80;

                    if(owner.wpbar.bstate != Weaponbar.BAR_HIDDEN) {
                        noShow = true;
                    }
                }
            }
        }
        
        return Super.tick();
    }


    const tspacing = 28;
    //const VPOS = -300; //215.0;
    //const HPOS = -320;
    const ICONSIZE = 40.0;
    const VPOS = 65;
    const VPOS_MASK = 65;
    const HPOS = 10;
    const POS_ANCHOR = DR_SCREEN_HCENTER | DR_SCREEN_VCENTER;

    override void draw(double fracTic, float alpha, Vector2 shake, Vector2 momentum)  {
        if(noShow || changeTicks == 0) return;

        Vector2 hudShake = (shake + momentum) * 0.45;

        double time = (ticks + fracTic) * ITICKRATE;
        double ctime = time - (changeTicks * ITICKRATE);

        if(ctime > WARNINGLEN_TIME) return;

        double a = alpha * CLAMP((WARNING_FADE_START - ctime) / WARNING_FADE_TIME, 0.0, 1.0) * CLAMP(ctime / WARNING_FADE_IN, 0.0, 1.0);
        double scale = ((CLAMP(1.0 - (ctime / WARNING_FADE_IN), 0.0, 1.0)) * 0.5) + 1.0;
        double tscale = scale;// * 0.7;
        
        double vpos = crosshairOffset + (owner.hasGasMask ? VPOS_MASK : VPOS);

        Font fnt = "SEL21FONT";
        DrawStr(
            fnt, 
            curName, 
            (HPOS,  VPOS) + hudShake, 
            POS_ANCHOR | DR_TEXT_HCENTER | DR_TEXT_VCENTER, 
            Font.CR_UNTRANSLATED, 
            a,
            false,
            scale: (tscale, tscale)
        );

        double offset = -(fnt.stringWidth(curName) * tscale) * 0.5;
        //double iconSize = 40;

        DrawTexAdvanced(curTexture, (HPOS + offset - 10, VPOS + 1) + hudShake, POS_ANCHOR | DR_IMG_RIGHT | DR_IMG_VCENTER | DR_SCALE_IS_SIZE, a: a, scale: (scale * ICONSIZE, scale * ICONSIZE));
    }
}