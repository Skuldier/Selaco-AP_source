struct WheelEntry {
    String name, description;
    TextureID texID;
    Color col;
    bool empty, hasSome;
    int count1, count2, index;
    double size;
    Actor sourceActor;
    bool disabled;
}


class WeaponWheelHandler : EventHandler {
    mixin ScreenSizeChecker;
	mixin UIDrawer;
	mixin HudDrawer;
    mixin CVARBuddy;
    mixin UIInputHandlerAccess;


    enum WheelIndex {
        CONTEXT_WHEEL   = 0,
        WEAPON_WHEEL    = 1,
        GRENADE_WHEEL   = 2
    };

    //TextureID bgTex;
    
    Array<int> wheelKeys;
    Array<int> fireKeys, altFireKeys;
    Array<int> cancelKeys;
    bool wheelIsShowing, hideWheelLatch, lastWeaponSwapEnabled;
    int wheelTime;
   
    //ui Array<SelacoWeapon> items;
    //ui WeaponWheelEntry items[20];
    //ui int numItems;
    ui bool openedWithGamepad;
    ui int fireCooldown;

    ui bool wheelShowing, grenadesAvailable, playedOpeningSound;
    ui double screenScale;
    ui int tix, selectedTick, soundTick;
    ui int selectedItem;
    ui Vector2 deltaSelPos, selPos, mouseSelPos, virtualMasterSize;
    //ui Shape2D segShape;
    //ui Shape2DTransform segShapeTransform;
    
    ui WWheelDrawer wheels[3];
    ui int activeWheel, lastWheel;
    ui uint transitionTicks;
    ui String grenadeSwapText, markerSwapText, weaponSwapText, weaponSwapTextR;

    static clearscope WeaponWheelHandler Instance() {
        return WeaponWheelHandler(EventHandler.Find("WeaponWheelHandler"));
    }

    override void OnRegister() {
        SetOrder(99999);
    }

    override bool UIProcess(UIEvent e) {
        return false;
    }

    override void NewGame() {
        forceClosed();
    }

    ui bool isShowing() {
        if(wheelIsShowing) {
            if(lastWeaponSwapEnabled && openedWithGamepad && level.totalTime - wheelTime < 5) return false;
            return true;
        }

        return false;
    }

    ui bool isSwapPossible() {
        return openedWithGamepad && lastWeaponSwapEnabled;
    }

    ui bool isInsideSwapWindow() {
        return !(!openedWithGamepad || !lastWeaponSwapEnabled || level.totalTime - wheelTime >= 5);
    }

    void forceClosed() {
        wheelIsShowing = false;
        hideWheelLatch = true;
    }

    override void WorldLoaded(WorldEvent e) {
        wheelIsShowing = false;

        // Make sure Dawn's input returns to normal when crossing world barriers
        let d = Dawn(players[consolePlayer].mo);
        if(d) d.weaponWheelUp = false;


        wheelKeys.clear();
        fireKeys.clear();
        altFireKeys.clear();
        cancelKeys.clear();

        Bindings.GetAllKeysForCommand(wheelKeys, "weaponWheel");
        Bindings.GetAllKeysForCommand(fireKeys, "+attack");
        //Bindings.GetAllKeysForCommand(cancelKeys, "-attack");
        Bindings.GetAllKeysForCommand(altFireKeys, "+altattack");
    }

    override void WorldUnloaded(WorldEvent e) {
        forceClosed();

        let d = Dawn(players[consolePlayer].mo);
        if(d) d.weaponWheelUp = false;
    }


    override void WorldTick() {
        if(level.totalTime % 40 == 0) {
            wheelKeys.clear();
            fireKeys.clear();
            cancelKeys.clear();
            Bindings.GetAllKeysForCommand(wheelKeys, "weaponWheel");
            Bindings.GetAllKeysForCommand(fireKeys, "+attack");
            Bindings.GetAllKeysForCommand(cancelKeys, "-attack");
            lastWeaponSwapEnabled = iGetCVAR("g_wheel_action") == 1;
        }

        if(hideWheelLatch) {
            hideWheelLatch = false;
        }

        let d = Dawn(players[consolePlayer].mo);

        if(menuActive) {
            // This will only happen if a menu opens that does not pause the game
            if(d) {
                d.weaponWheelUp = SelacoWeapon.WEAPON_WHEEL_COOLDOWN;
                wheelIsShowing = false;
            }
        } else {
            if(d && lastWeaponSwapEnabled && wheelIsShowing && level.totalTime - wheelTime >= 5) {
                d.weaponWheelUp = SelacoWeapon.WEAPON_WHEEL_COOLDOWN + 1;
            }
        }
    }


    override void UITick() {
        if(wheelShowing) {
            if(hideWheelLatch) {
                wheelShowing = false;
                fireCooldown = 0;
                return;
            }

            if(level.levelnum == 9999) {
                wheelShowing = false;
                return;
            }

            if(!playedOpeningSound && level.totalTime - wheelTime == 5 && openedWithGamepad && lastWeaponSwapEnabled) {
                S_StartSound ("weaponwheel/open", CHAN_VOICE, CHANF_UI, snd_sfxvolume * 0.75);
                playedOpeningSound = true;
            }

            if(screenSizeChanged()) {
                screenScale = calcScreenScale(screenSize, virtualScreenSize, screenInsets);
                
                // Limit the scale so the wheel does not appear larger than the screen
                if(virtualScreenSize.x < 1600) {
                    virtualScreenSize *= 1600.0 / virtualScreenSize.x;
                } if(virtualScreenSize.y < 900) {
                    virtualScreenSize *= 900.0 / virtualScreenSize.y;
                }

                virtualMasterSize = virtualScreenSize;
                calcTightScreen();
                calcUltrawide();

                for(int x = 0; x < 3; x++)  {
                    wheels[x].markDirty();
                    wheels[x].screenSize = screenSize;
                    wheels[x].virtualScreenSize = virtualScreenSize;
                    wheels[x].isTightScreen = isTightScreen;
                    wheels[x].isUltrawide = isUltrawide;
                }
            }
                
            if(!lastWeaponSwapEnabled || !openedWithGamepad || level.totalTime - wheelTime >= 5) {
                Vector2 con;

                // Check every joystick for look axis and add values to con
                for(int x = 0; x < JoystickConfig.NumJoysticks(); x++) {
                    let joy = JoystickConfig.GetJoystick(x);
                    
                    for(int y = 0; y < joy.GetNumAxes(); y++) {
                        if(joy.GetAxisMap(y) == JoystickConfig.JOYAXIS_Pitch) {
                            con.y += joy.GetRawAxis(y);
                        } else if(joy.GetAxisMap(y) == JoystickConfig.JOYAXIS_Yaw) {
                            con.x += joy.GetRawAxis(y);
                        }
                    }
                }

                // Check for gamepad changes
                if(con.length() > 0.15) {
                    mouseSelPos = (0,0);
                    deltaSelPos = selPos;
                    selPos = con * 100.0;
                    if(selPos.length() > 100.0) selPos = selPos.unit() * 100.0;

                    if(wheels[activeWheel].selectFromPos(selPos)) {
                        if(tix - soundTick >= 2) {
                            bool disabled = wheels[activeWheel].items[wheels[activeWheel].selectedItem].disabled;
                            S_StartSound ("weaponwheel/hover", CHAN_VOICE, CHANF_UI, 
                                disabled ? snd_sfxvolume * 0.3 : snd_sfxvolume * 0.65,
                                pitch: disabled ? 0.9 : 1.0
                            );
                            soundTick = tix;
                        }

                        selectedTick = tix;
                        
                    }
                } else {
                    deltaSelPos = selPos;
                    selPos = (0,0);
                }
            }
            

            // Check for grenade status
            if(tix % 5 == 0) {
                let d = Dawn(players[consolePlayer].mo);
                if(d) {
                    // Check if more than one throwable is unlocked
                    int unlockCnt = 0;
                    let handler = EquipmentHandler.Instance();
                    for(int x = 0; x < handler.allThrowables.size(); x++) {
                        unlockCnt += d.hasUnlockedGrenade(handler.allThrowables[x]);
                    }
                    grenadesAvailable = unlockCnt > 1;
                } else { grenadesAvailable = false; }
            }
            // Update all wheels
            for(int x = 0; x < 3; x++) wheels[x].tick();

            tix++;
        } else {
            tix = 0;
            soundTick = 0;
            playedOpeningSound = false;
        }

        if(fireCooldown) fireCooldown--;
    }


    clearscope static double normA(double value, double start = 0, double end = 360) {
        double width       = end - start;
        double offsetValue = value - start;

        return ( offsetValue - ( floor( offsetValue / width ) * width ) ) + start;
    }


    ui bool startShowingWheel(int id) {
        if(wheels[CONTEXT_WHEEL]    == NULL)   wheels[CONTEXT_WHEEL]    = new("ContextWheelDrawer").init();
        if(wheels[WEAPON_WHEEL]     == NULL)   wheels[WEAPON_WHEEL]     = new("WeaponWheelDrawer").init();
        if(wheels[GRENADE_WHEEL]    == NULL)   wheels[GRENADE_WHEEL]    = new("GrenadeWheelDrawer").init();
        
        activeWheel = id;
        lastWheel = -1;
        wheels[activeWheel].selectedItem = -1;
        wheels[activeWheel].update();

        // Don't show wheel with only one item
        if(wheels[activeWheel].numItems <= 1) {
            wheels[activeWheel].numItems = 0;
            return false;
        }

        EventHandler.SendNetworkEvent("wheel+", openedWithGamepad ? 1 : 0);
        wheelShowing = true;

        // Cache active weapons
        selPos = (0,0);
        mouseSelPos = (0,0);
        selectedItem = -1;

        wheels[activeWheel].buildSegment();

        // Get text
        if(openedWithGamepad) {
            grenadeSwapText = String.Format("\c[HI]%c\n\c-%s", UIHelper.FontIconLookupPad[InputEvent.Key_Pad_DPad_Left - UIHelper.FontIconLookupPadStart], StringTable.Localize("$WWHEEL_THROWABLES"));
            markerSwapText = String.Format("\c[HI]%c\n\c-%s", UIHelper.FontIconLookupPad[InputEvent.Key_Pad_DPad_Right - UIHelper.FontIconLookupPadStart], StringTable.Localize("$WWHEEL_MARKERS"));
            weaponSwapText = String.Format("\c[HI]%c\n\c-%s", UIHelper.FontIconLookupPad[InputEvent.Key_Pad_DPad_Left - UIHelper.FontIconLookupPadStart], StringTable.Localize("$WWHEEL_WEAPONS"));
            weaponSwapTextR = String.Format("\c[HI]%c\n\c-%s", UIHelper.FontIconLookupPad[InputEvent.Key_Pad_DPad_Right - UIHelper.FontIconLookupPadStart],  StringTable.Localize("$WWHEEL_WEAPONS"));
        } else {
            grenadeSwapText = UIHelper.FilterKeybinds("$[[HI],+attack]$\n\c-" .. StringTable.Localize("$WWHEEL_THROWABLES"), shortMode: false, forceGamepad: openedWithGamepad);
            markerSwapText = UIHelper.FilterKeybinds("$[[HI],+altattack]$\n\c-" .. StringTable.Localize("$WWHEEL_MARKERS"), shortMode: false, forceGamepad: openedWithGamepad);
            weaponSwapText = UIHelper.FilterKeybinds("$[[HI],+attack]$\n\c-" .. StringTable.Localize("$WWHEEL_WEAPONS"), shortMode: false, forceGamepad: openedWithGamepad);
            weaponSwapTextR = UIHelper.FilterKeybinds("$[[HI],+altattack]$\n\c-" .. StringTable.Localize("$WWHEEL_WEAPONS"), shortMode: false, forceGamepad: openedWithGamepad);
        }

        if(!isSwapPossible()) {
            S_StartSound ("weaponwheel/open", CHAN_VOICE, CHANF_UI, snd_sfxvolume * 0.75);
            playedOpeningSound = true;
        } else {
            tix = -5;
        }

        return true;
    }


    override bool InputProcess (InputEvent e) {
        //Console.Printf("Input event: %d   Key: %d   %s", e.type, e.KeyScan, e.KeyString);

        if(wheelShowing && e.type == InputEvent.Type_Mouse && selPos ~== (0,0)) {
            mouseSelPos = (
                mouseSelPos.x + (double(e.MouseX) / m_sensitivity_x),
                mouseSelPos.y - (double(e.MouseY) / m_sensitivity_y)
            );

            // Limit to range of the wheel
            double mspLen = mouseSelPos.length();
            if(mspLen > 450) {
                mouseSelPos = mouseSelPos.unit() * 450.0;
                mspLen = 450;
            }

            // Determine selected item
            if(mspLen < 70) {
                wheels[activeWheel].selectedItem = -1;
                return true;
            }

            if(wheels[activeWheel].selectFromPos(mouseSelPos)) {
                if(tix - soundTick >= 2) {
                    bool disabled = wheels[activeWheel].items[wheels[activeWheel].selectedItem].disabled;
                    S_StartSound ("weaponwheel/hover", CHAN_VOICE, CHANF_UI, 
                        disabled ? snd_sfxvolume * 0.3 : snd_sfxvolume * 0.65,
                        pitch: disabled ? 0.9 : 1.0
                    );
                    soundTick = tix;
                }

                selectedTick = tix;
            }

            return true;
        }

        if(e.type == InputEvent.Type_KeyDown && !wheelShowing) {
            let d = Dawn(players[consolePlayer].mo);
            if(!d || d.health <= 0) return false;
            if(automapactive || level.mapName ~== "TITLEMAP") return false;

            for(int x = wheelKeys.size() - 1; x >= 0; x--) {
                if(e.KeyScan == wheelKeys[x]) {
                    openedWithGamepad = UIHelper.IsGamepadKey(e.KeyScan);
                    startShowingWheel(WEAPON_WHEEL);

                    return true;
                }
            }
        } else if(e.type == InputEvent.Type_KeyUp && wheelShowing) {
            for(int x = wheelKeys.size() - 1; x >= 0; x--) {
                if(e.KeyScan == wheelKeys[x]) {
                    int slot = -1;
                    int index = -1;

                    [slot, index] = wheels[activeWheel].findSelectedItem();
                    bool closedWithGamepad = UIHelper.IsGamepadKey(e.KeyScan);
                    
                    if(!isInsideSwapWindow()) {
                        if(slot >= 0) {
                            S_StartSound ("weaponwheel/select", CHAN_VOICE, CHANF_UI, snd_sfxvolume * 0.6);
                            HUD.WeaponBarTimeout(15);
                        } else {
                            S_StartSound ("weaponwheel/close", CHAN_VOICE, CHANF_UI, snd_sfxvolume * 0.6);
                        }
                    }

                    // TODO: Play swap sound?

                    // Send slot as -2 to indicate that we closed the wheel with the gamepad
                    EventHandler.SendNetworkEvent("wheel-", activeWheel, slot == -1 && closedWithGamepad ? -2 : slot, index);

                    wheelShowing = false;

                    return true;
                }
            }
        } 
        
        if(e.type == InputEvent.Type_KeyDown && wheelShowing) {
            if(e.KeyScan == InputEvent.Key_Pad_DPad_Left) {
                transitionWheel(1);
                return true;
            } else if(e.KeyScan == InputEvent.Key_Pad_DPad_Right) {
                transitionWheel(-1);
                return true;
            }

            for(int x = fireKeys.size() - 1; x >= 0; x--) {
                if(e.KeyScan == fireKeys[x]) {
                    transitionWheel(UIHelper.IsGamepadKey(e.KeyScan) ? -1 : 1);
                    
                    return true;
                }
            }

            for(int x = altFireKeys.size() - 1; x >= 0; x--) {
                if(e.KeyScan == altFireKeys[x]) {
                    transitionWheel(UIHelper.IsGamepadKey(e.KeyScan) ? 1 : -1);

                    return true;
                }
            }

            for(int x = cancelKeys.size() - 1; x >= 0; x--) {
                if(e.KeyScan == cancelKeys[x]) {
                    return true;
                }
            }


            // Cancel the wheel
            if(e.KeyScan == InputEvent.Key_Pad_B || e.KeyScan == InputEvent.Key_Escape) {
                bool closedWithGamepad = UIHelper.IsGamepadKey(e.KeyScan);
                S_StartSound ("weaponwheel/close", CHAN_VOICE, CHANF_UI, snd_sfxvolume * 0.5);
                EventHandler.SendNetworkEvent("wheel-", activeWheel, closedWithGamepad ? -2 : -1, -1);
                wheelShowing = false;
                return true;
            }
        }
        
        if(fireCooldown > 0 && (e.type == InputEvent.Type_KeyDown || e.type == InputEvent.Type_KeyUp)) {
            for(int x = fireKeys.size() - 1; x >= 0; x--) {
                if(e.KeyScan == fireKeys[x]) {
                    return true;
                }
            }

            for(int x = cancelKeys.size() - 1; x >= 0; x--) {
                if(e.KeyScan == cancelKeys[x]) {
                    return true;
                }
            }
        }

        return false;
    }


    ui void transitionWheel(int offset) {
        let lwheel = activeWheel;
        activeWheel = clamp(activeWheel + offset, 0, 2);

        if(lwheel != activeWheel) {
            if(activeWheel == GRENADE_WHEEL) {
                let d = Dawn(players[consolePlayer].mo);
                if(d) {
                    // Make sure we have some grenade inventory to show the grenade wheel
                    if(!grenadesAvailable) {
                        activeWheel = lwheel;
                        return;
                    }
                }
            }

            wheels[lwheel].selectedItem = -1;
            lastWheel = lwheel;
            transitionTicks = tix;
            
            if(!(mouseSelPos ~== (0,0))) {
                wheels[activeWheel].selectFromPos(mouseSelPos);
            } else if(!(selPos ~== (0,0))) {
                wheels[activeWheel].selectFromPos(selPos);
            } else {
                wheels[activeWheel].selectedItem = -1;
            }
            
            wheels[activeWheel].update();

            S_StartSound ("weaponwheel/cycle", CHAN_VOICE, CHANF_UI, snd_sfxvolume * 0.75);
        }
    }


    override void NetworkProcess (ConsoleEvent e) {
        if(e.name == "wheel+") {
            if(!wheelIsShowing) wheelTime = level.totalTime;
            wheelIsShowing = true;
            lastWeaponSwapEnabled = iGetCVAR("g_wheel_action") == 1;

            let d = Dawn(players[consolePlayer].mo);
            if(d && !(lastWeaponSwapEnabled && e.args[0] == 1)) {
                d.weaponWheelUp = SelacoWeapon.WEAPON_WHEEL_COOLDOWN + 1;
            }
        } else if(e.name == "wheel-") {
            let d = Dawn(players[consolePlayer].mo);
            if(d) {
                
                // Check for quick last-weapon swap
                let timeSinceWheel = level.totalTime - wheelTime;
                
                if(e.args[1] == -2 && iGetCVAR("g_wheel_action") == 1 && timeSinceWheel > 1 && timeSinceWheel < 5) {
                    d.switchToLastWeapon();
                    d.weaponWheelUp = 0;
                } else {
                    d.weaponWheelUp = SelacoWeapon.WEAPON_WHEEL_COOLDOWN;
                }

                 if(e.args[1] >= 0) {
                    switch(e.args[0]) {
                        case WEAPON_WHEEL:
                            let inv = d.FindInventory(d.player.weapons.GetWeapon(e.args[1], e.args[2]));
                            if(inv) {
                                inv.use(false);
                            } else {
                                let c = d.player.weapons.GetWeapon(e.args[1], e.args[2]);
                                Console.Printf("\cWEAPON WHEEL: Somehow couldn't find weapon %d - %d (%s)", e.args[1], e.args[2], c ? c.getClassName() : 'None');
                            }
                            break;
                        case GRENADE_WHEEL:
                            // select grenade
                            let handler = EquipmentHandler.Instance();
                            if(e.args[2] < 0 || e.args[2] >= handler.allThrowables.size()) break;
                            let grenadeClass = handler.allThrowables[e.args[2]];
                            if(d.player && d.player.readyWeapon) {
                                let w = SelacoWeapon(d.player.readyWeapon);
                                if(w) w.setThrowable(grenadeClass);
                            }
                            break;
                        case CONTEXT_WHEEL:
                            // select context option
                            // Currently just place markers
                            if(e.args[2] >= 0) d.placeMarker(e.args[2]);
                            break;
                        default:
                            break;
                    }
                }
            }

            wheelIsShowing = false;
        }
    }

    protected clearscope int invCount(Actor a, class<Inventory> inv, int defValue = 0) {
		let i = a.FindInventory(inv);
		return i ? i.Amount : defValue; 
	}

    override void RenderOverlay(RenderEvent e) {
        if(wheelShowing && !menuActive && !(virtualScreenSize ~== (0,0))) {
            let d = Dawn(players[consolePlayer].mo);
            if(!d) return;

            if(tix < 0) return;

            let tix = double(tix);
            double time = (tix + e.fracTic) * ITICKRATE;
            double subTime = (tix - double(transitionTicks) + e.fracTic) * ITICKRATE;

            Vector2 slideOffset = (0,0);

            //let timeSinceWheel = level.totalTime - wheelTime;
            Screen.Dim(0xFF000000, UIMath.EaseOutCubicf(min(time / 0.5, 1.0)) * 0.38, 0, 0, Screen.GetWidth(), Screen.GetHeight());
            

            double alpha = UIMath.EaseOutCubicf(min(time / 0.2, 1.0));

            if(alpha < 1) {
                virtualScreenSize = virtualMasterSize / (0.8 + (alpha * 0.2));
            } else {
                virtualScreenSize = virtualMasterSize;
            }

            
            // Draw swap indicators
            switch(activeWheel) {
                case GRENADE_WHEEL:
                    //Vector2 pos, int flags = 0, double a = 1.0, Vector2 scale = (1, 1), int desaturate = 0, bool filter = true, int color = 0xFFFFFFFF
                    DrawStrMultiline('SEL27OFONT', weaponSwapTextR, (600, 0), 400, DR_SCREEN_CENTER | DR_TEXT_VCENTER,  a: alpha);
                    break;
                case CONTEXT_WHEEL:
                    DrawStrMultiline('SEL27OFONT', weaponSwapText, (-600, 0), 400, DR_SCREEN_CENTER | DR_TEXT_RIGHT | DR_TEXT_VCENTER,  a: alpha);
                    break;
                default:
                    //DrawImgAdvanced("WHELSEG3", (-580, 0), DR_SCREEN_CENTER | DR_IMG_VCENTER | DR_IMG_RIGHT | DR_SCALE_IS_SIZE, alpha * 0.25, scale: (500, 95));
                    //DrawImgAdvanced("WHELSEG3", (580, 0), DR_SCREEN_CENTER | DR_IMG_VCENTER | DR_FLIP_X | DR_SCALE_IS_SIZE, alpha * 0.25, scale: (500, 95));
                    DrawStrMultiline('SEL27OFONT', grenadeSwapText, (-600, 0), 400, DR_SCREEN_CENTER | DR_TEXT_RIGHT | DR_TEXT_VCENTER,  a: alpha * (grenadesAvailable ? 1 : 0.2), desaturate: (grenadesAvailable ? 0 : 255));
                    DrawStrMultiline('SEL27OFONT', markerSwapText, (600, 0), 400, DR_SCREEN_CENTER | DR_TEXT_VCENTER,  a: alpha);
                    break;
            }

            // Draw wheels
            if(subTime <= 0.3 && activeWheel != lastWheel && lastWheel != -1) {
                let slideTE = UIMath.EaseOutCubicf(subTime / 0.3);
                double dir = activeWheel > lastWheel ? 1.0 : -1.0;
                slideOffset.x = (-200.0 + (200.0 * slideTE)) * dir;

                wheels[lastWheel].draw(e.fracTic, (200, 0) * slideTE * dir, (1.0 - slideTE) * (1.0 - slideTE), selPos, screenSize, virtualScreenSize);

                alpha *= slideTE;
            }

            wheels[activeWheel].draw(e.fracTic, (0,0) + slideOffset, alpha, UIMath.Lerpv(deltaSelPos, selPos, e.fracTic), screenSize, virtualScreenSize);

           
            // Mouse pointer
            if(!(mouseSelPos ~== (0,0))) {
                DrawXImg("MOUSE", mouseSelPos, DR_WAIT_READY);
            }
        }
    }
}


class WWheelDrawer ui {
    mixin UIDrawer;
    mixin RandomizerWeaponDrawer;

    int numItems, selectedItem;
    uint tix, selectedTick;
    WheelEntry items[20];
    PieDrawer innerSegDrawer;

    transient TextureID bgTex, segTex, segTexSelected, wheelSepTex;
    Shape2D segShape;
    Shape2DTransform segShapeTransform;
    transient bool dirty;
    

    WWheelDrawer init() {
        bgTex = Texman.CheckForTexture("WHEELBG1");
        segTex = TexMan.CheckForTexture("WHELSEG2");
        segTexSelected = TexMan.CheckForTexture("WHEELSEG");
        wheelSepTex = TexMan.CheckForTexture("WHEELSEP");
        selectedItem = -1;

        return self;
    }

    virtual void tick() {
        tix++;
    }

    void markDirty() {
        dirty = true;
    }

    virtual void update() {

    }


    bool selectFromPos(Vector2 selPos) {
        int divisions = numItems;

        // Determine selected item
        if(divisions != 0 && selPos.length() >= 30) {
            double divSize = 360.0 / double(divisions);
            Vector2 sp = selPos.unit();
            double angle = WeaponWheelHandler.norma(atan2(sp.y, sp.x) + 90 + (divSize * 0.5));
            
            let oldItem = selectedItem;
            selectedItem = int(floor(angle / divSize)) % divisions;
            
            if(oldItem != selectedItem) {
                /*if(items[selectedItem].disabled) {
                    selectedItem = oldItem;
                    return false;
                }*/
                selectedTick = tix;
                return true;
            }
        }

        return false;
    }


    virtual int, int findselectedItem() {
        return 0, selectedItem;
    }


    protected clearscope int invCount(Actor a, class<Inventory> inv, int defValue = 0) {
		let i = a.FindInventory(inv);
		return i ? i.Amount : defValue; 
	}


    const NUM_INNER_VERTS = 40;
    const N_NUM_INNER_VERTS = (1.0 / double(NUM_INNER_VERTS));
    const CIRCLE_SIZE = 160.0;
    const OUTER_CIRCLE_SIZE = 450.0 + 7.0;
    const CIRCLE_CIRC = OUTER_CIRCLE_SIZE - CIRCLE_SIZE;
    const ITEM_DIST_FROM_CENTER = CIRCLE_SIZE + ((OUTER_CIRCLE_SIZE - CIRCLE_SIZE) / 2.0) - 10.0;
    const INNER_SEG_DIST = 380.0;
    const CENTER_CIRC_SIZE = 330.0;

    // Build the Shape2D for the background of each segment
    void buildSegment() {
        double divisions = numItems;
        double divSize = (360.0 / divisions);

        if(!segShape) segShape = new("Shape2D");
        else segShape.clear();
        if(!segShapeTransform) segShapeTransform = new("Shape2DTransform");

        double divSegSize = divSize / double(NUM_INNER_VERTS);
        for(int x = 0; x <= NUM_INNER_VERTS; x++) {
            double ds = -90.0 + (x * divSegSize) - (divSize * 0.5);
            double c = cos(ds), s = sin(ds);
            segShape.pushVertex((CIRCLE_SIZE * c, CIRCLE_SIZE * s));
            segShape.pushCoord((x * N_NUM_INNER_VERTS, 0.999));
            segShape.pushVertex((OUTER_CIRCLE_SIZE * c, OUTER_CIRCLE_SIZE * s));
            segShape.pushCoord((x * N_NUM_INNER_VERTS, 0.001));
        }

        int tcount = (NUM_INNER_VERTS * 2);
        for(int x = 0; x < tcount; x += 2) {
            segShape.pushTriangle(x, x + 1, x + 2);
            segShape.pushTriangle(x + 2, x + 1, x + 3);
        }

        divSize = min( 50, divSize - 10.0);
        if(!innerSegDrawer) innerSegDrawer = new("PieDrawer").init("WHEELBG2");
        innerSegDrawer.degreesStart = -(divSize * 0.5);
        innerSegDrawer.degreesEnd = divSize * 0.5;
        innerSegDrawer.build();
    }


    virtual void draw(double fracTic, Vector2 offset, double alpha, Vector2 selPos, Vector2 ssize, Vector2 vsize) {
        if(screenSize != ssize || virtualScreenSize != vsize) markDirty();
        screenSize = ssize;
        virtualScreenSize = vsize;
        
        if(dirty || !bgTex.isValid()) {
            bgTex = Texman.CheckForTexture("WHEELBG1");
            segTex = TexMan.CheckForTexture("WHELSEG2");
            segTexSelected = TexMan.CheckForTexture("WHEELSEG");
            wheelSepTex = TexMan.CheckForTexture("WHEELSEP");
            buildSegment();
        }

        if( !(innerSegDrawer.makeReady() && TexMan.MakeReady(segTex) && TexMan.MakeReady(segTexSelected) && TexMan.MakeReady(bgTex) && TexMan.MakeReady(wheelSepTex)) ) return;

        Color crosshaircolor = crosshaircolor;
        crosshaircolor = Color(255, crosshaircolor.r, crosshaircolor.g, crosshaircolor.b);

        // Draw segments
        int divisions = numItems;
        double divSize = 360.0 / double(divisions);
        Vector2 scScale = getVirtualScreenScale();
        Vector2 pxScreenCenter = (screenSize * 0.5) + (offset.x * scScale.x, offset.y * scScale.y);

        // Draw background for all items except selectedItem
        for(int x = 0; x < numItems; x++) {
            segShapeTransform.clear();
            segShapeTransform.scale(scScale);
            segShapeTransform.rotate(x * divSize);
            segShapeTransform.translate(pxScreenCenter);
            segShape.setTransform(segShapeTransform);

            Screen.drawShape(
                segtex, 
                false,
                segShape,
                DTA_Alpha, alpha,
                DTA_Filtering, true
                //DTA_Color, 0xFF000000
            );
        }

        // Draw background
        if(selectedItem >= 0) {
            double selTime = (double(tix - selectedTick) + fracTic) * ITICKRATE;
            double balpha = UIMath.EaseOutCubicf(min(selTime / 0.2, 1.0));

            Color glowCol = 0xFFb0c6f7;//items[selectedItem].col > 0 ? items[selectedItem].col : 0xFFFFFFFF;
            glowCol = Color(255, glowCol.b, glowCol.g, glowCol.r);      // Swap r/b as usual

            if(!segShape || !segShapeTransform) buildSegment();
            
            segShapeTransform.clear();
            segShapeTransform.scale(scScale);
            segShapeTransform.rotate(selectedItem * divSize);
            segShapeTransform.translate(pxScreenCenter);
            segShape.setTransform(segShapeTransform);

            Screen.drawShape(
                segTexSelected, 
                false,
                segShape,
                DTA_Alpha, 0.5 * alpha * balpha,
                DTA_Filtering, true,
                DTA_Color, glowCol,
                DTA_LegacyRenderStyle, STYLE_Add
            );
        }


        // Draw color indicators
        for(int x = 0; x < divisions; x++) {
            Color glowCol = items[x].col > 0 ? items[x].col : 0xFFFFFFFF;
            glowCol = Color(items[x].disabled ? 50 : 255, glowCol.b, glowCol.g, glowCol.r);      // Swap r/b as usual

            // Draw the inner seg
            let sizer = (INNER_SEG_DIST * scScale.x, INNER_SEG_DIST * scScale.y);
            innerSegDrawer.Draw(pxScreenCenter - (sizer * 0.5), sizer, (x * divSize) - 90.0, alpha, glowCol);
        }
        
        // Draw icons
        Font fnt = 'SEL21OFONT';
        Font fnt2 = 'SEL27OFONT';
        double ammoScale = divisions > 8 ? 1 : 1.1;
        double titleScale = 0.85;
        bool selectedItemIsempty = false;
        

        for(int x = 0; x < divisions; x++) {
            Vector2 pos;
            Vector2 iconSize = items[x].size > 0 ? (items[x].size, items[x].size) : (divisions > 8 ? (64, 64) : (80, 80));
            Vector2 iconSize2 = iconSize * 0.5;

            //if(items[x].sourceActor)  {
                bool hasSome = items[x].hasSome;
                bool empty = items[x].empty;
                Color col = empty ? 0xFF888888 : 0xFFFFFFFF;

                pos = Actor.RotateVector((0, -ITEM_DIST_FROM_CENTER), (divSize * x));
                DrawTexAdvanced(items[x].texID, pos + offset, DR_NO_SPRITE_OFFSET | DR_SCALE_IS_SIZE | DR_IMG_ASPECT_FIT | DR_SCREEN_HCENTER | DR_SCREEN_VCENTER | DR_IMG_HCENTER | DR_IMG_VCENTER | DR_WAIT_READY, a: alpha, scale: iconSize, desaturate: empty ? 255 : 0, color: col);

                if(hasSome) {
                    int a1 = items[x].count1;
                    int a2 = items[x].count2;
                    string ammoCount = String.Format("%s%s%s", 
                                            a1 >= 0 ? ""..a1 : "",
                                            a1 >= 0 && a2 >= 0 ? "/" : "",
                                            a2 >= 0 ? ""..a2 : ""
                                    );
                    
                    DrawStr(fnt, ammoCount, pos - (0, iconSize2.y + 3) + offset, DR_SCREEN_CENTER | DR_TEXT_HCENTER | DR_TEXT_BOTTOM, col, a: alpha, scale: (ammoScale, ammoScale));                       
                }
            //}

            pos = Actor.RotateVector((0, -(CIRCLE_SIZE + 2)), (x * divSize) + (divSize * 0.5));
            DrawXTex(wheelSepTex, pos + offset, a: alpha, color: crosshaircolor, rotation: 90.0 - ((double(x) * divSize) + (divSize * 0.5)), center: (0, 0.5));
        }

        // Draw center circle 
        DrawTexAdvanced(bgTex, offset, DR_SCREEN_HCENTER | DR_SCREEN_VCENTER | DR_IMG_HCENTER | DR_IMG_VCENTER | DR_SCALE_IS_SIZE, a: alpha, scale: (CENTER_CIRC_SIZE, CENTER_CIRC_SIZE), color: crosshaircolor);

        // Draw title
        if(selectedItem >= 0) {
            DrawStrMultiline(fnt2, stringtable.localize(items[selectedItem].name), offset, 195 , DR_SCREEN_CENTER | DR_TEXT_CENTER, a: alpha, scale: (titleScale, titleScale)); 
        }
        
        // Gamepad pointer
        let spLen = selPos.length();
        if(spLen > 5) {
            //let selPos = UIMath.Lerpv(deltaSelPos, selPos, fracTic);
            //spLen = selPos.length();
            let dir = selPos.unit();
            double rot = atan2(-dir.y, dir.x);
            
            double amount = UIMath.EaseOutCubicf((spLen - 5.0) / 95.0);
            double a = UIMath.EaseInCubicf(min(1.0, (spLen - 5.0) / 30.0)) * alpha;
            spLen = (amount * 30) + CIRCLE_SIZE - 15;
            let pos = dir * spLen;
            DrawXImg("WHEELAR1", pos + offset, DR_WAIT_READY, a: a, rotation: rot, center: (0.5, 0.5));
        }

        // Draw selected pointer
        if(selectedItem >= 0 && spLen <= 5) {
            let rot = selectedItem * divSize;
            let pos = Actor.RotateVector((0, -CIRCLE_SIZE), rot);
            DrawXImg("WHEELAR1", pos + offset, DR_WAIT_READY, a: alpha, rotation: 90 - rot, center: (0.5, 0.5));
        }
    }
}



class ContextWheelDrawer : WWheelDrawer {
    
    static const string names[] = {
        "$MARKER_RED",
        "$MARKER_BLUE",
        "$MARKER_YELLOW",
        "$MARKER_GREEN",
        "$MARKER_PURPLE"
    };

    static const int colors[] = {
        0xFF4351,
        0x00D2FF,
        0xFFF500,
        0x01FE53,
        0xAC4FFF
    };
    
    ContextWheelDrawer init() {
        super.init();
        
        numItems = 5;
        update();

        return self;
    }


    override void tick() {
        Super.tick();
        
        // Update context options, if there are any
    }


    override void update() {
        numItems = 5;
        
        for(int x = 0; x < numItems; x++) {
            items[x].sourceActor = null;
            items[x].count1 = -1;
            items[x].count2 = -1;
            items[x].hasSome = true;
            items[x].empty = false;
            items[x].texID = TexMan.CheckForTexture(String.Format("2CON%c0", x + 65), TexMan.Type_Any);
            items[x].col = colors[x];
            items[x].size = 96;
            items[x].name = String.Format("\c[HI]%s\c-\n%s", StringTable.Localize("$MARKER_ACTION"), StringTable.Localize(names[x]));
        }
    }
}



class GrenadeWheelDrawer : WWheelDrawer {
    GrenadeWheelDrawer init() {
        super.init();
        update();
        
        return self;
    }


    override void tick() {
        Super.tick();

        // Update grenade counts
        if(level.totalTime % 17 == 0 || numItems == 0) {
            update();
        }
    }

    override void update() {
        numItems = 0;

        PlayerInfo player = players[consolePlayer];
        Dawn d = Dawn(players[consolePlayer].mo);
        if(!d) {
            return;
        }

        let handler = EquipmentHandler.Instance();

        for(int x = 0; x < handler.allThrowables.size(); x++) {
            if(!d.hasUnlockedGrenade(handler.allThrowables[x])) continue;
            let inv = SelacoAmmo(player.mo.FindInventory(handler.allThrowables[x]));
            let def = GetDefaultByType(handler.allThrowables[x]);
            if(!inv || !def) continue;
            items[numItems].sourceActor = inv;
            items[numItems].count1 = inv ? inv.Amount : 0;
            items[numItems].count2 = inv ? inv.MaxAmount : -1;
            items[numItems].hasSome = items[numItems].count1 > 0;
            items[numItems].empty = !items[numItems].hasSome;
            items[numItems].texID = def.icon && def.icon.isValid() ? def.icon : TexMan.CheckForTexture("WPNEMPTY", TexMan.Type_Any);
            items[numItems].col = def.ammoColor != 0 ? def.ammoColor : 0xFF0000;
            items[numItems].size = 96;
            items[numItems].name = StringTable.Localize(def.AmmoName);
            items[numItems].index = x;
            numItems++;
        }
    }


    override int, int findselectedItem() {
        int slot = -1;
        int index = -1;

        if(selectedItem < 0) return -1,-1;
        return 0, items[selectedItem].index;
    }
}



class WeaponWheelDrawer : WWheelDrawer {
    int weaponCount;

    WeaponWheelDrawer init() {
        super.init();
        
        getWeapons();

        return self;
    }

    override void tick() {
        Super.tick();

        // Update ammo counts
        Dawn d = Dawn(players[consolePlayer].mo);
        if(d) {
            if(level.totalTime % 15 == 0) {
                int oldCount = weaponCount;
                weaponCount = getWeapons();
                if(oldCount != weaponCount) {
                    buildSegment();
                }
            } else {
                for(int x = 0; x < numItems; x++) {
                    let weapon = SelacoWeapon(items[x].sourceActor);

                    if(!weapon) {
                        if(items[x].name != "") {
                            items[x].sourceActor = null;
                            items[x].count1 = 0;
                            items[x].count2 = 0;
                            items[x].hasSome = 0;
                            items[x].empty = true;
                            items[x].texID.SetInvalid();
                            items[x].col = 0xFF333333;
                            items[x].name = "";
                            items[x].disabled = true;
                        }
                        continue;
                    }

                    items[x].count1 = d.hasBottomLessMags || weapon.hasUpgradeClass("BottomlessTrait") ? InvCount(d, weapon.AmmoType1, 0) + InvCount(d, weapon.AmmoType2, 0) : InvCount(d, weapon.AmmoType2, -1);
                    items[x].count2 = d.hasBottomLessMags || weapon.hasUpgradeClass("BottomlessTrait") ? -1 : InvCount(d, weapon.AmmoType1, -1);
                    items[x].hasSome = items[x].count1 + items[x].count2 >= -1;
                    items[x].empty = items[x].hasSome && (items[x].count1 + items[x].count2 == 0);
                }
            }
        }
    }


    int getWeapons() {
        numItems = 10;
        int itemCount = 0;
        
        PlayerInfo player = players[consolePlayer];
        let d = Dawn(players[consolePlayer].mo);
        if(!d) return 0;
        
        for(int x = 0; x < 10; x++) {
            items[x].sourceActor = null;
            items[x].count1 = 0;
            items[x].count2 = 0;
            items[x].hasSome = false;
            items[x].empty = true;
            items[x].texID.SetInvalid();
            items[x].col = 0xFF333333;
            items[x].name = "";
            items[x].disabled = true;
            
            for(int y = 0; y < player.weapons.SlotSize(x); y++) {
                let wClass = player.weapons.GetWeapon(x, y);
                let inv = SelacoWeapon(player.mo.FindInventory(wClass));
                if(inv) {
                    items[x].sourceActor = inv;
                    items[x].count1 = d.hasBottomLessMags || inv.hasUpgradeClass("BottomlessTrait") ? InvCount(d, inv.AmmoType1, 0) + InvCount(d, inv.AmmoType2, 0) : InvCount(d, inv.AmmoType2, -1);
                    items[x].count2 = d.hasBottomLessMags || inv.hasUpgradeClass("BottomlessTrait") ? -1 : InvCount(d, inv.AmmoType1, -1);
                    items[x].hasSome = items[x].count1 + items[x].count2 >= -1;
                    items[x].empty = items[x].hasSome && (items[x].count1 + items[x].count2 == 0);
                    items[x].texID = inv.icon.isValid() ? inv.icon : TexMan.CheckForTexture("WPNEMPTY", TexMan.Type_Any);
                    items[x].size = 87;
                    items[x].col = inv.ammoColor > 0 ? inv.ammoColor : 0xFFFFFFFF;
                    items[x].name = inv.getTag();
                    items[x].disabled = false;
                    itemCount++;
                    break;
                }
            }
        }

        return itemCount;
    }


    override void update() {
        Super.update();
        getWeapons();
    }


    override int, int findselectedItem() {
        int slot = -1;
        int index = -1;

        if(selectedItem < 0) return -1,-1;

        PlayerInfo player = players[consolePlayer];

        for(int x = 0; x < 10; x++) {
            for(int y = 0; y < player.weapons.SlotSize(x); y++) {
                let wClass = player.weapons.GetWeapon(x, y);
                
                if(items[selectedItem].sourceActor && wClass == items[selectedItem].sourceActor.getClass()) {
                    slot = x;
                    index = y;
                    x = 10;
                    break;
                }
            }
        }

        return slot, index;
    }


    override void draw(double fracTic, Vector2 offset, double alpha, Vector2 selPos, Vector2 ssize, Vector2 vsize) {
        Super.draw(fracTic, offset, alpha, selPos, ssize, vsize);

        // If we are in randomizer mode, draw weapon deets for selected weapon
        if(g_randomizer && selectedItem >= 0) {
            SelacoWeapon w = SelacoWeapon(items[selectedItem].sourceActor);

            if(w && !(w is 'Fists')) {
                DrawWeaponInfo(w, (isUltrawide ? -160 : (isTightScreen ? -10 : -80), 80), DR_SCREEN_RIGHT | DR_IMG_RIGHT, alpha);
            }
        }
    }
}