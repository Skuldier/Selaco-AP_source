enum LookAtLineFlags {
    LALF_HIDDEN = 1
}

class LookAt : StaticEventHandler {
    mixin UIDrawer;
    mixin HudDrawer;
    mixin HUDScaleChecker;
    mixin ScreenSizeChecker;
    mixin CVARBuddy;
    mixin RandomizerWeaponDrawer;

    int fireDelay;          // Ticks until the next check
    int ticksFound;         // Amount of ticks we've been looking at objects without finding "nothing"
    LookAtTracer tracer;
    String info, subInfo, notAvailableString, bindString, altBindString, dropString, disabledBindString;
    TextureID dotTex, interactTex, grabTex, pickupTex, pullTex, leverTex, buyTex, openTex, closeTex, keyTex;
    String useText, pikText, drpText, trwText, downText, swapText;
    Color hiColor, maskHiColor;

    bool shouldDraw, hasGasMask, hudEnabled;
    bool isLookingAtPurchase, subExtraInfo, keybindNewLine;

    const gwynScript    = -int('GwynMachine');
    const cabinetScript = -int('openCabinet');
    const cameraScript  = -int('ViewCamera');
    const lockerScript  = -int('BeepBeep');

    TextureID keypadTexture, safeRoomTex, doorLockTex, hatchLockTex, turretButtTex, pur1Tex, pur2Tex, pur3Tex, pur4Tex, pur5Tex, pur6Tex;

    Actor lastObject;
    int lastLine;
    TextureID lineTex;

    int holdTime;      // Time since establishing a hold prompt


    static clearscope LookAt Instance() {
        return LookAt(StaticEventHandler.Find("LookAt"));
    }

    override void OnRegister() {
        tracer = new("LookAtTracer");
        fireDelay = 3;

        // TODO: LANGUAGE THIS SHIT
        notAvailableString = "\c[RED](Unavailable: Holding Object)";

        keypadTexture   = TexMan.CheckForTexture("KEYPADA");
        safeRoomTex     = TexMan.CheckForTexture("SMLLOCKD");
        doorLockTex     = TexMan.CheckForTexture("DRLOCKA");
        hatchLockTex    = TexMan.CheckForTexture("HATCI");
        turretButtTex   = TexMan.CheckForTexture("DEFENSEI");
        pur1Tex         = TexMan.CheckForTexture("PUR_AMMO");
        pur2Tex         = TexMan.CheckForTexture("PUR_MINE");
        pur3Tex         = TexMan.CheckForTexture("PUR_MKIT");
        pur4Tex         = TexMan.CheckForTexture("PUR_SHLD");
        pur5Tex         = TexMan.CheckForTexture("PUR_TURR");
        pur6Tex         = TexMan.CheckForTexture("PUR_GREN");

        useText = StringTable.Localize("$ACT_USE");
        pikText = StringTable.Localize("$ACT_PICKUP");
        swapText = StringTable.Localize("$ACT_SWAP");
        downText = Stringtable.Localize("$ACT_DOWNLOAD");
        drpText = StringTable.Localize("$ACT_DROP");
        trwText = StringTable.Localize("$ACT_THROW");

        hudEnabled = iGetCVar("hud_enabled") > 0;

        grabTex = TexMan.CheckForTexture("XH_GRAB");
        interactTex = TexMan.CheckForTexture("XH_HAND");
        pickupTex = TexMan.CheckForTexture("XH_PICK");
        pullTex = TexMan.CheckForTexture("XH_PULL");
        leverTex = TexMan.CheckForTexture("XH_LEVER");
        buyTex = TexMan.CheckForTexture("XH_BUY");
        openTex = TexMan.CheckForTexture("XH_OPEN");
        closeTex = TexMan.CheckForTexture("XH_CLOSE");
        keyTex = TexMan.CheckForTexture("XH_CARD");

        hiColor = 0xFFb0c6f7;
        maskHiColor = 0xFFE6BA40;
    }

    private int scriptNum(Name script) {
        return -int(script);
    }

    override void WorldTick() {
        if(level.totalTime % 5) {
            hudEnabled = iGetCVar("hud_enabled") > 0;
        }

        if(!hudEnabled || !players[consolePlayer].mo || players[consolePlayer].mo.health <= 0 || players[consolePlayer].camera != players[consolePlayer].mo) { 
            ticksFound = 0;
            shouldDraw = false;
            info = ""; 
            return;
        }

        shouldDraw = !menuActive;
        if(!shouldDraw) {
            ticksFound = 0;
            return;
        }


        if(bindString == "" || Level.time % 34 == 0) {  // Check for a new USE key periodically, just in case it may have changed
            // Check player for gas mask
            hasGasMask = players[consolePlayer].mo.FindInventory("GasMask");

            // Generate bind string from +use input
            bindString = UIHelper.FilterKeybinds(hasGasMask ? "$[[HI3],+use]$" : "$[[HI],+use]$", shortMode: true);
            dropString = UIHelper.FilterKeybinds(hasGasMask ? "$[[HI3],+altattack]$" : "$[[HI],+altattack]$", shortMode: true);
            altBindString = UIHelper.FilterKeybinds(hasGasMask ? "$[[HI3],+attack]$" : "$[[HI],+attack]$", shortMode: true);
            disabledBindString = UIHelper.FilterKeybinds("$[[DARKGRAY],+use]$", shortMode: true);
        }

        if(ticksFound > 0 || fireDelay == 0 || Level.time % fireDelay == 0) {
            let p = players[consolePlayer].mo;
            let girlcaptaindown = Dawn(p);
            bool holdDisable = false;
            let highCol = hasGasMask ? "[HI3]" : "[HI]";

            info = "";
            subInfo = "";

            // First check if the player is holding something, show the drop/throw prompt
            if(girlcaptaindown && girlcaptaindown.holdingObject) {
                tracer.ignoredActor = girlcaptaindown.holdingObject;
                let actionText = "";
                let pd = PickupableDecoration(girlcaptaindown.holdingObject);
                if(pd) actionText = pd.getActionString();
                let cname = SelacoActor(girlcaptaindown.holdingObject).GetCharacterName();
                let fullActionText = actionText != "" ? String.Format("%s\c-", actionText) : String.Format("\c%s%s\c- %s", highCol, trwText, cname);
                info = String.Format("%s %s\c-\n%s \c%s%s\c- %s", altBindString, fullActionText, dropString, highCol, drpText, cname);
                holdDisable = true;
                if(holdTime == 0) holdTime = level.totalTime;

                //return;
            } else {
                tracer.ignoredActor = null;
                holdTime = 0;
            }

            // Do the trace
            Vector3 dir = LookAtTracer.VecFromAngle(p.Angle, p.Pitch);
            Vector3 pos = p.pos;
            pos.z = players[consolePlayer].viewz;
            
            tracer.secondaryHit = null;
            bool hasHit = tracer.Trace(pos, p.CurSector, dir, 64, TRACE_NoSky);

            lastObject = null;
            lastLine = -1;
            isLookingAtPurchase = false;
            subExtraInfo = false;
            keybindNewLine = false; 

            let rw = SelacoWeapon(girlcaptaindown.player.readyWeapon);
            if(rw && rw.isZooming) {
                return;
            }

            // This hack is necessary because P_TRACE does NOT DO CALLBACKS FOR FLOOR/CEILING HITS IN SOME CASES!? What is that shit.
            if((tracer.Results.HitType == TRACE_HitFloor || tracer.Results.HitType == TRACE_HitCeiling) && tracer.secondaryHit) hasHit = false;

            if(hasHit || (!hasHit && tracer.secondaryHit)) {
                if((!hasHit && tracer.secondaryHit) || tracer.Results.HitType == TRACE_HitActor) {
                    let target = hasHit ? tracer.Results.HitActor : tracer.secondaryHit;
                    let interact = SelacoActor(target);
                    let pup = CustomInventory(target);
                    lastObject = target;
                    
                    
                    isLookingAtPurchase = interact is 'Purchasable';
                    
                    if(interact && !pup) {
                        // Notify object they have been selected
                        interact.playerLooked(consolePlayer, tracer.Results.HitPos);

                        if(!interact.user_nouseprompt) {
                            if(holdDisable) {
                                // Don't bother to show subs of pickupables
                                if(!(interact is 'PickupableDecoration')) {
                                    subInfo = String.Format("%s%s %s", interact.bShowInteraction ? bindString .. " " : "", interact.GetUsePrompt(highCol), notAvailableString);
                                }
                            } else {
                                info = String.Format("%s%s", interact.bShowInteraction ? bindString .. "\n" : "", interact.GetUsePrompt(highCol));
                                keybindNewLine = interact.bShowInteraction;
                                if(interact is 'Purchasable' && Purchasable(interact).price > 0) {
                                    info = info .. String.Format("\n\c[darkgrey](Have: \c[SLV]%d\c[darkgrey])\c-", p.countInv('CreditsCount'));
                                }
                            }
                        }
                    } else {
                        if(pup) {
                            let si = SelacoItem(pup);
                            
                            // Notify object they have been selected
                            if(si) {
                                si.playerLooked(consolePlayer, tracer.Results.HitPos);
                            }

                            if(!si.bUsePrompt) { 
                                info = ""; 
                            } else {
                                String texIcon = pikText;

                                // Print swap tag for randomizer mode
                                let wp = WeaponPickup(pup);
                                if(wp && wp.shouldSwap(players[consolePlayer].mo))
                                {
                                    texIcon = swapText;
                                }

                                if(si is "DatapadEntry")
                                {
                                    texIcon = downText;
                                }
                                if(holdDisable) subInfo = String.Format("%s \c%s%s\c- %s %s", bindString, highCol, texIcon, si ? si.GetItemName() : target.GetCharacterName(), notAvailableString);
                                else {
                                    if(si.CheckPickupLimit(p)) {
                                        info = String.Format("%s\n\c%s%s\c- %s", bindString, highCol, texIcon, si ? si.GetItemName() : target.GetCharacterName());
                                    } else {
                                        info = String.Format("%s\n\c[DARKGRAY]%s\c- %s", disabledBindString, texIcon, si ? si.GetItemName() : target.GetCharacterName());
                                    }

                                    keybindNewLine = true;

                                    if(wp) {
                                        subInfo = wp.getExtraLookAtInfo();
                                        subExtraInfo = true;
                                    }
                                }
                            }
                        } else {
                            if(holdDisable) subInfo = String.Format("%s\c%s%s\c- %s %s", bindString, highCol, useText, target.GetCharacterName(), notAvailableString);
                            else {
                                info = String.Format("%s\n\c%s%s\c- %s", bindString, highCol, useText, target.GetCharacterName());
                                keybindNewLine = true;
                            }
                        }
                    }

                    holdTime = 0;
                } else if(tracer.Results.HitType == TRACE_HitWall) {
                    if(tracer.Results.HitLine.Activation & (SPAC_UseThrough | SPAC_Use)) {
                        if(tracer.Results.HitLine.GetUDMFInt("user_nouseprompt") || tracer.Results.HitLine.GetUDMFInt("user_interactionflags") & LALF_HIDDEN) {
                            return;
                        }

                        string actName = tracer.Results.HitLine.GetUDMFString("user_interaction");
                        string title = tracer.Results.HitLine.GetUDMFString("user_title");
                        string linetexName = tracer.Results.HitLine.GetUDMFString("user_useicon");
                        if(linetexName != "") lineTex = TexMan.CheckForTexture(linetexName, TexMan.Type_MiscPatch);
                        else lineTex.SetInvalid();

                        lastLine = tracer.Results.HitLine.Index();

                        // Check for polyobj and assume it's a door if unspecified
                        if(title == "" && tracer.Results.HitLine.sidedef[tracer.Results.Side].Flags & Side.WALLF_POLYOBJ) {
                            title = "$ACT_OBJ_DOOR";
                        } else if(title == "") {
                            // Check line type and make an assumption
                            switch(tracer.Results.HitLine.Special) {
                                case 0:
                                    // We don't want to show 0 action lines unless they are tagged
                                    if(actName == "" && actName == "") {
                                        info = "";
                                        return;
                                    }
                                    break;
                                case 83:
                                case 84:
                                case 85:
                                case 80: // ACS_Execute
                                    switch(tracer.Results.HitLine.args[0]) {
                                        case 774:
                                            actName = "$ACT_ACTIVATE";
                                            title = "$ACT_OBJ_SHUTTER";
                                            break;
                                        case 5: // Light Switches
                                            actName = "$ACT_SWITCH";
                                            title = "$ACT_OBJ_LIGHT";
                                            break;
                                        case cabinetScript:
                                            actName = "$ACT_UNLOCK";
                                            title = "$ACT_OBJ_CABINET";
                                            break;
                                        case cameraScript:
                                            actName = "$ACT_VIEW";
                                            title = "$ACT_OBJ_CAM_MONITOR";
                                            break;
                                        case lockerScript:
                                            actName = "$ACT_UNLOCK";
                                            title = "$ACT_OBJ_LOCKER";
                                            break;
                                        case gwynScript:
                                            actName = "$ACT_OPEN";
                                            //title = "$ACT_OBJ_GWYN";
                                            title = String.Format("%s\n\c[darkgrey](Have: \c[SLV]%d\c[darkgrey])\c-", StringTable.Localize("$ACT_OBJ_GWYN"), p.countInv('CreditsCount'));
                                            isLookingAtPurchase = true;
                                            break;
                                        case 217:
                                            actName = "$ACT_USE";
                                            title = "$OBJECT_HOLOTECH";
                                            break;
                                        default: {
                                                let texID = tracer.Results.HitTexture;
                                                if(texID == keypadTexture) {
                                                    actName = "$ACT_OPEN";
                                                    title = "$ACT_OBJ_KEYPAD";
                                                } else if(texID == safeRoomTex) {
/*                                                     actName = "$ACT_ENTER";
                                                    title = "$ACT_OBJ_SAFEROOM"; */
                                                } else if(texID == doorLockTex) {
                                                    actName = "$ACT_UNLOCK";
                                                    title = "$ACT_OBJ_DOOR";
                                                    if(!lineTex.isValid()) lineTex = keyTex;
                                                } else if(texID == hatchLockTex) {
                                                    actName = "$ACT_UNLOCK";
                                                    title = "$ACT_OBJ_HATCH";
                                                } else if(texID == turretButtTex) {
                                                    actName = "$ACT_ACTIVATE";
                                                    title = "$ACT_OBJ_TURRETS";
                                                } else if(texID == pur1Tex || texID == pur2Tex || texID == pur3Tex || texID == pur4Tex || texID == pur5Tex || texID == pur6Tex) {
                                                    actName = "$INTERACT_PURCHASE";
                                                    //title = " ";
                                                    title = String.Format("\n\c[darkgrey](Have: \c[SLV]%d\c[darkgrey])\c-", p.countInv('CreditsCount'));
                                                    isLookingAtPurchase = true;
                                                    if(!lineTex.isValid()) lineTex = buyTex;
                                                }
                                            }
                                            break;
                                    }
                                    break;
                                
                                case Door_Raise:
                                case Door_LockedRaise:
                                case Door_Open:
                                case Door_WaitRaise:
                                case 202:
                                    actName = "$ACT_OPEN";
                                    title = "Door";
                                    break;
                                case Door_WaitClose:
                                case Door_Close:
                                    actName = "$ACT_CLOSE";
                                    title = "Door";
                                    break;
                                default:
                                    break;
                            }
                        }
                        
                        if(actName == "") actName = "$ACT_USE";

                        if(holdDisable) {
                            subInfo = String.Format("%s \c%s%s\c- %s %s", bindString, highCol, title != "" ? Stringtable.Localize(actName) : Stringtable.Localize("$ACT_GENERIC"), Stringtable.Localize(title), notAvailableString);
                        } else {
                            info = String.Format("%s\n\c%s%s\c- %s", bindString, highCol, title != "" ? Stringtable.Localize(actName) : Stringtable.Localize("$ACT_GENERIC"), Stringtable.Localize(title));
                            keybindNewLine = true;
                        }

                        holdTime = 0;
                    }
                }
            }
        }

        ticksFound = (info == "") ? ticksFound + 1 : 0;
    }

    void resetTimer() {
        ticksFound = 1;
    }
    

    const HOLD_FADE_START = 78;
    const HOLD_FADE_TIMER = 85.0;

    override void RenderOverlay(RenderEvent e) {
        if(shouldDraw && !automapactive) {
            double alpha = 1.0;
            Font fnt = 'SEL21OFONT';
            
            if(holdTime > HOLD_FADE_START) {
                alpha = UIMath.EaseOutCubicF( 1.0 - min(1.0, (double(level.totalTime - holdTime - HOLD_FADE_START) + e.FracTic) / HOLD_FADE_TIMER));
            }
            
            bool skipNormal = false;

            // Draw weapon info for randomizer
            if(g_randomizer) {
                let wp = WeaponPickup(lastObject);
                if(wp && wp.baseStats && wp.randomizer && wp.randomizer.allowTieredWeapons) {
                    SelacoWeapon wpn = SelacoWeapon(players[consolePlayer].mo.FindInventory(wp.weaponName));
                    DrawWeaponPickup(wp, wpn, (60, 0));
                    skipNormal = true;
                }
            }

            if(!skipNormal) {
                let lines = fnt.breakLines(info, 9999);
                let lines2 = fnt.breakLines(subInfo, 9999);
                int numLines = lines.count() + lines2.count();
                int maxBigLine = keybindNewLine ? 2 : 1;
                
                double mainScale = lines.count() > 3 ? 0.85 : 1.0;
                double subScale = numLines > 3 || subExtraInfo ? min(mainScale, 0.75) : 0.85;
                
                double h = 0;
                for(int x = 0; x < lines.count(); x++) {
                    DrawStr(fnt, lines.stringAt(x), (60, h), DR_SCREEN_CENTER, a: alpha, monospace: false, linespacing: 5, scale: x < maxBigLine ? (1,1) : (mainScale, mainScale));
                    h += fnt.getHeight() * (x < maxBigLine ? 1.0 : mainScale) + 5;
                }
                

                if(subInfo != "") {
                    DrawStr(
                        fnt,
                        subInfo, 
                        (60, h + fnt.getHeight()), 
                        flags: DR_SCREEN_CENTER,
                        a: alpha,
                        monospace: false,
                        linespacing: 5,
                        scale: (subScale, subScale),
                        desaturate: subExtraInfo ? 0 : 255
                    );
                }
            }
            

            // Draw interact icon if interacting
            let lob = SelacoActor(lastObject);
            let si = SelacoItem(lastObject);
            let ll = lastLine;
            TextureID interactIcon;

            if((lob || si || ll > -1) && (info.length() > 0 || subInfo.length() > 0 || (si && si.useIcon))) {
                if(lob && lob.useIcon) {
                    interactIcon = lob.useIcon;
                } else if(si && si.useIcon) {
                    interactIcon = si.useIcon;
                } else if (si) { // Pickup Item
                    interactIcon = pickupTex;
                } else if (lob is "pickupableDecoration") { // Grabbable Object
                    interactIcon = grabTex;
                } else if ((lob is "PickupableDecoration" || lob is "Interactable") && Interactable(lob).pullFactor) { // Pullable object
                    interactIcon = pullTex;
                } else if (lob is "switch1") { // Switch
                    interactIcon = leverTex;
                } else if (lob is "Interactable" && Interactable(lob).useTag == " "){ // Show no icon
                    interactIcon = TexMan.CheckForTexture("");
                } else {
                    interactIcon = interactTex;

                    if(ll >= 0) {
                        // Use manually defined texture for lines, unless there is none
                        if(lineTex.isValid()) interactIcon = lineTex;
                        else {
                            switch(level.lines[lastLine].Special) {
                                case 83:
                                case 84:
                                case 85:
                                case 80:
                                {
                                    switch(level.lines[lastLine].args[0]) {
                                        case cabinetScript:
                                        case lockerScript:
                                            interactIcon = openTex;
                                            break;
                                        case gwynScript:
                                            interactIcon = buyTex;
                                            break;
                                    }
                                    break;
                                }
                                case Door_Raise:
                                case Door_LockedRaise:
                                case Door_Open:
                                case Door_WaitRaise:
                                case 202:
                                    interactIcon = openTex;
                                    break;
                                case Door_WaitClose:
                                case Door_Close:
                                    interactIcon = closeTex;
                                    break;
                            }
                        }
                    }
                }
                
                Color clr = hasGasMask ? maskHiColor : hiColor;
                DrawXTex(interactIcon, (5, 5), DR_WAIT_READY, a: alpha, scale: (crosshairScale, crosshairScale), color: clr, center: (0,0));   
            }
        }
    }

    override void UITick() {
        if(screenSizeChanged() || hudScaleChanged()) {
            calcScreenScale(screenSize, virtualScreenSize, screenInsets);
        }
    }

    override void WorldLoaded(WorldEvent e) {
        lastLine = -1;
        lastObject = null;
        lineTex.SetInvalid();
    }

    override void WorldUnloaded(WorldEvent e) {
        lastLine = -1;
        lastObject = null;
        lineTex.SetInvalid();
    }
}