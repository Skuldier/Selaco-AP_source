class Weaponbar ui {
    mixin UIDrawer;

    enum BarState {
        BAR_HIDDEN = 0,
        BAR_APPEARING,
        BAR_SHOWING,
        BAR_DISAPPEARING
    }
    
    // Drawing
    Font fnt;
    PlayerInfo player;
    double alpha;
    BarState bstate;
    double stateTime;
    bool show, isWaiting;
    bool isSuppressed;           // Is currently being hidden because of a new weapon cooldown

    // Selected weapon
    bool curWeaponFound;
    int wSlot, wIndex;
    int cooldown;

    // Weapon selection animation
    double wChangeTime;
    int wOutSlot, wOutIndex;

    TextureID selTex, wepEmpty;

    const bottomOffset = 305;   // Bar starts at bottomOffset above the bottom of the screen
    const spacing = 20;         // Space between weapons
    const vertSpacing = 105;
    const iconSize = 64;        // Size of each icon slot (squared)
    const selIconSizeX = 72;    // Size of selection icon
    const selIconSizeY = 72;    // Y
    const numScale = 1.1;       // number font scale
    const numLowerScale = 0.85; // number (lower) font scale
    const numVertSpacing = 7;   // Number vertical padding above icon
    const numLowerVertSpacing = 10;  // Number vertical padding below icon

    const selInTime = 0.11;     // Time to animate selection frame in
    const selOutTime = 0.11;    // Ditto Out
    const appearTime = 0.06;    // Fade in time for whole bar (roughly 2 ticks)
    const disappearTime = 0.2;  // Time to fade out after being on screen too long
    const appearLength = 2;   // Stay on for this long before fading out

    const ITICKRATE = double(1.0/35.0);

    void Init() {
        fnt = "SEL21OFONT";
        alpha = 1;
        curWeaponFound = false;
        bstate = BAR_HIDDEN;

        selTex = TexMan.CheckForTexture("ZSEL", TexMan.Type_Any);
        wepEmpty = TexMan.CheckForTexture("WPNEMPTY", TexMan.Type_Any);
        TexMan.MakeReady(selTex);
        TexMan.MakeReady(wepEmpty);

        wSlot = -1;
    }

    void SetVirtualScreenSize(Vector2 newVirtualSize) {
        screenSize = (Screen.GetWidth(), Screen.GetHeight());
        virtualScreenSize = newVirtualSize;
        calcTightScreen();
        calcUltrawide();
    }

    void Tick(uint ticks) {
        if(player) {
            double time = double(ticks) * ITICKRATE;
            int deltaSlot = wSlot;
            int deltaIndex = wIndex;
            bool oldWeapon = curWeaponFound;

            if(cooldown) cooldown--;
            
            if(player.ReadyWeapon) {
                [curWeaponFound, wSlot, wIndex] = player.weapons.LocateWeapon(player.PendingWeapon && player.PendingWeapon != WP_NOCHANGE ? player.PendingWeapon.GetClass() : player.ReadyWeapon.GetClass());
            } else if(player.PendingWeapon) {
                [curWeaponFound, wSlot, wIndex] = player.weapons.LocateWeapon(player.PendingWeapon.GetClass());
            } else {
                curWeaponFound = false;
            }
            
            // If there have been changes to the currently selected weapon, signal animation start
            // Don't trigger on the first weapon; you spawn with that.
            if(deltaSlot >= 0 && curWeaponFound && (deltaSlot != wSlot || deltaIndex != wIndex)) {
                wOutSlot = deltaSlot;
                wOutIndex = deltaIndex;
                wChangeTime = time;

                // If we are cooling down, don't respond to this event
                if(!cooldown) {
                    // If we aren't showing wait 1 frame to check for the timeout
                    isWaiting = bstate != BAR_SHOWING;
                    if(!isWaiting) {
                        stateTime = time;   // Refresh timeout when we are already showing
                    }
                }
            } else if(bstate == BAR_APPEARING && time - stateTime >= appearTime) {
                bstate = BAR_SHOWING;
                stateTime = time;
            } else if(bstate == BAR_DISAPPEARING && time - stateTime >= disappearTime) {
                bstate = BAR_HIDDEN;
                stateTime = time;
            } else if(bstate == BAR_SHOWING && time - stateTime >= appearLength) {
                bstate = BAR_DISAPPEARING;
                stateTime = time;
            } else if(isWaiting) {
                if(InvCount("newweaponcooldown") || cooldown) {
                    bstate = BAR_HIDDEN;
                    isSuppressed = true;
                } else {
                    bstate = bstate == BAR_HIDDEN ? BAR_APPEARING : BAR_SHOWING;
                }

                stateTime = time;
                isWaiting = false;
            } else if(bstate == BAR_SHOWING && InvCount("newweaponcooldown")) {
                // Hide the bar if a new weapon cooldown is started
                bstate = BAR_DISAPPEARING;
                stateTime = time;
                isSuppressed = true;
            } else if(isSuppressed) {
                // If we are suppressed due to a cooldown, when the cooldown ends show the bar
                if(!InvCount("newweaponcooldown") && !cooldown) {
                    isSuppressed = false;

                    if(bstate == BAR_HIDDEN) {
                        bstate = BAR_APPEARING;
                        stateTime = time;
                        isWaiting = false;
                    }
                }
            }
            
        } else {
            bstate = BAR_HIDDEN;
        }
    }

    protected int InvCount(class<Inventory> inv, int defValue = 0) {
		let i = player ? player.mo.FindInventory(inv) : null;
		return i ? (i.Amount < 0 ? 1 : i.Amount) : defValue;
	}

    void Draw(uint ticks, double tm, double a = 1.0, Vector2 offset = (0,0)) {
        if(bstate == BAR_HIDDEN) { return; }

        int slotCount;
        int slots[10];
        Dawn d = Dawn(player.mo);

        double time = (double(ticks) * ITICKRATE) + (tm * ITICKRATE);
        double stateTM = bstate == BAR_APPEARING ?  (time - stateTime) / appearTime : (time - stateTime) / disappearTime;    // State TM is only used for these two states

        if(bstate != BAR_SHOWING) {
            a *= bstate == BAR_APPEARING ? stateTM : 1.0 - stateTM;
        }

        Vector2 fntSize = (fnt.GetCharWidth("0"), fnt.GetHeight()) * numScale;
        Vector2 size = virtualScreenSize;
        float scHalfWidth = size.x / 2.0;

        // Find occupied weapon slots
        for(int x =0; x < 10; x++) {
            for(int y = 0; y < player.weapons.SlotSize(x); y++) {
                if(player.mo.FindInventory(player.weapons.GetWeapon(x, y))) {
                    slots[slotCount++] = x;
                    break;
                }
            }
        }

        // Draw occupied weapon slots
        float xStart = scHalfWidth - ((slotCount * (iconSize + spacing)) / 2.0);
        for(int x =0; x < slotCount; x++) {
            int ycount = 0;
            for(int y = 0; y < player.weapons.SlotSize(slots[x]); y++) {
                float yStart = size.y - bottomOffset + (vertSpacing * ycount);
                Vector2 pos = (xStart + ((iconSize + spacing) * x), yStart) + offset;

                // Draw Slot #
                if(ycount == 0) {
                    Screen.DrawText(fnt, Font.CR_WHITE, (pos.x + (iconSize / 2.0) - (fntSize.x / 2.0)) / numScale, (pos.y - fntSize.y - numVertSpacing) / numScale, 
                        "" .. (slots[x]),
                        DTA_VirtualWidthF, size.x / numScale, DTA_VirtualHeightF, size.y / numScale,
                        DTA_KeepRatio, true,
                        DTA_Alpha, a * alpha,
                        DTA_Monospace,
                        MONO_CellCenter,
                        DTA_Spacing, int(fntSize.x / numScale),
                        DTA_Filtering, true);
                }
                
                // Draw weapon icon or placeholder
                let type = player.weapons.GetWeapon(slots[x], y);
                WeaponBase wep = WeaponBase(player.mo.FindInventory(type));
                SelacoWeapon sWeapon = SelacoWeapon(wep);
                if(wep) {
                    int a1 = InvCount(wep.AmmoType2, -1);
                    int a2 = InvCount(wep.AmmoType1, -1);
                    bool usesAmmo = a1 + a2 >= -1;
                    bool hasAmmo = max(0, a1) + max(0, a2) > 0;
                    bool noAmmo = usesAmmo && !hasAmmo;
                    double thisAlpha = a * alpha * (noAmmo ? 0.5 : 1.0);

                    TextureID icon = wep.icon.isValid() ? wep.icon : wepEmpty;
                    if(TexMan.MakeReady(icon)) {
                        screen.DrawTexture(icon, true, pos.x, pos.y,
                            DTA_KeepRatio, true,
                            DTA_DestWidth, iconSize,
                            DTA_DestHeight, iconSize,
                            DTA_VirtualWidthF, size.x, DTA_VirtualHeightF, size.y, 
                            DTA_Alpha, thisAlpha,
                            DTA_Filtering, true,
                            DTA_Desaturate, noAmmo ? 255 : 0
                        );
                    }

                    ycount++;

                    // Draw selection frame
                    if(curWeaponFound && wSlot == slots[x] && wIndex == y) {
                        // Animate? 
                        double te = time - wChangeTime;
                        double etm = te / selInTime;
                        // center on icon
                        double posx = pos.x + (iconSize / 2.0);
                        
                        if(TexMan.MakeReady(selTex)) {
                            if(te < selInTime) {
                                Vector2 isize = (selIconSizeX, selIconSizeY) * UIMath.Lerpf(1.25, 1.0, etm);
                                float offsetY = UIMath.Lerpf(selIconSizeY / 4.0, 0.0, etm);
                                screen.DrawTexture(selTex, true, posx - (isize.x / 2.0), pos.y - ((isize.y - selIconSizeY) / 2.0) + offsetY - 2,
                                    DTA_KeepRatio, true,
                                    DTA_DestWidthF, isize.x,
                                    DTA_DestHeightF, isize.y,
                                    DTA_VirtualWidthF, size.x, DTA_VirtualHeightF, size.y, 
                                    DTA_Alpha, a * alpha * etm,
                                    DTA_Filtering, true);
                            } else {
                                screen.DrawTexture(selTex, true, posx - (selIconSizeX / 2.0), pos.y - 2,
                                    DTA_KeepRatio, true,
                                    DTA_DestWidth, selIconSizeX,
                                    DTA_DestHeight, selIconSizeY,
                                    DTA_VirtualWidthF, size.x, DTA_VirtualHeightF, size.y, 
                                    DTA_Alpha, a * alpha,
                                    DTA_Filtering, true);
                            }
                        }
                    }

                    // Draw ammo count
                    if(usesAmmo) {
                        string ammoCount;
                        
                        if(d && (d.hasBottomLessMags || (sWeapon && sWeapon.hasUpgradeClass("BottomlessTrait")))) {
                            a1 = max(0, a1) + max(0, a2);
                            ammoCount = String.Format("%d", a1);
                        } else {
                            ammoCount = String.Format("%s%s%s", 
                                a1 >= 0 ? ""..a1 : "",
                                a1 >= 0 && a2 >= 0 ? "/" : "",
                                a2 >= 0 ? ""..a2 : ""
                            );
                        }
                        int ammoCountWidth = fnt.StringWidth(ammoCount) * numLowerScale;
                        Screen.DrawText(fnt, Font.CR_WHITE, (pos.x + (iconSize / 2.0) - (ammoCountWidth / 2.0)) / numLowerScale, (pos.y + iconSize + numLowerVertSpacing) / numLowerScale, 
                            ammoCount,
                            DTA_VirtualWidthF, size.x / numLowerScale, DTA_VirtualHeightF, size.y / numLowerScale,
                            DTA_KeepRatio, true,
                            DTA_Alpha, thisAlpha,
                            DTA_Filtering, true);
                    }
                }
            }
        }
    }
}