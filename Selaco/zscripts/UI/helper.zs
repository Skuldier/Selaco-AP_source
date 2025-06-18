class UIHelper {
    mixin SCVARBuddy;

    static const int KIDtoUI[] = {
        -1, // 0 = 
        27, // 1 = escape
        49, // 2 = 1
        50, // 3 = 2
        51, // 4 = 3
        52, // 5 = 4
        53, // 6 = 5
        54, // 7 = 6
        55, // 8 = 7
        56, // 9 = 8
        57, // 10 = 9
        48, // 11 = 0
        45, // 12 = -
        61, // 13 = =
        8, // 14 = backspace
        9, // 15 = tab
        81, // 16 = q
        87, // 17 = w
        69, // 18 = e
        82, // 19 = r
        84, // 20 = t
        89, // 21 = y
        85, // 22 = u
        73, // 23 = i
        79, // 24 = o
        80, // 25 = p
        91, // 26 = [
        93, // 27 = ]
        13, // 28 = enter
        7,  // 29 = ctrl (Key_CTRL)
        65, // 30 = a
        83, // 31 = s
        68, // 32 = d
        70, // 33 = f
        71, // 34 = g
        72, // 35 = h
        74, // 36 = j
        75, // 37 = k
        76, // 38 = l
        59, // 39 = ;
        39, // 40 = '
        96, // 41 = `
        29, // 42 = shift (Key_Shift)
        92, // 43 = \
        90, // 44 = z
        88, // 45 = x
        67, // 46 = c
        86, // 47 = v
        66, // 48 = b
        78, // 49 = n
        77, // 50 = m
        44, // 51 = ,
        46, // 52 = .
        47, // 53 = /
        29, // 54 = rshift (Key_Shift)
        42, // 55 = kp*
        12, // 56 = alt (Key_Menu)
        32, // 57 = space
        28, // 58 = capslock (Key_CapsLock)
        14, // 59 = f1
        15, // 60 = f2
        16, // 61 = f3
        17, // 62 = f4
        18, // 63 = f5
        19, // 64 = f6
        20, // 65 = f7
        21, // 66 = f8
        22, // 67 = f9
        23, // 68 = f10
        -1, // 69 = numlock
        -1, // 70 = scroll
        55, // 71 = kp7
        56, // 72 = kp8
        57, // 73 = kp9
        45, // 74 = kp-
        52, // 75 = kp4
        53, // 76 = kp5
        54, // 77 = kp6
        43, // 78 = kp+
        49, // 79 = kp1
        50, // 80 = kp2
        51, // 81 = kp3
        48, // 82 = kp0
        46, // 83 = kp.
        -1, // 84 = key_
        -1, // 85 = key_
        -1, // 86 = oem102
        24, // 87 = f11
        25, // 88 = f12
        -1, // 89 = key_
        -1, // 90 = key_
        -1, // 91 = key_
        -1, // 92 = key_
        -1, // 93 = key_
        -1, // 94 = key_
        -1, // 95 = key_
        -1, // 96 = key_
        -1, // 97 = key_
        -1, // 98 = key_
        -1, // 99 = key_
        -1, // 100 = f13
        -1, // 101 = f14
        -1, // 102 = f15
        -1  // 103 = f16
    };

    const FontIconLookupPadStart = 0x1AC;    // Keyscan lookup start (Gamepad)
    const FontIconLookupPadEnd = 0x1C3;      // Keyscan lookup end (Gamepad)
    const FontIconLookupPadCodeStart = 0x80; // Unicode lookup start (Gamepad)

    static const int FontIconLookupPad[] = {    // Default Gamepad Unicode lookup
        0x8B, // Key_Pad_LThumb_Right = 0x1AC,
        0x8C, // Key_Pad_LThumb_Left = 0x1AD,
        0x8D, // Key_Pad_LThumb_Down = 0x1AE,
        0x8E, // Key_Pad_LThumb_Up = 0x1AF,

        0x8F, // Key_Pad_RThumb_Right = 0x1B0,
        0x90, // Key_Pad_RThumb_Left = 0x1B1,
        0x91, // Key_Pad_RThumb_Down = 0x1B2,
        0x92, // Key_Pad_RThumb_Up = 0x1B3,

        0x96, // Key_Pad_DPad_Up = 0x1B4,
        0x95, // Key_Pad_DPad_Down = 0x1B5,
        0x93, // Key_Pad_DPad_Left = 0x1B6,
        0x94, // Key_Pad_DPad_Right = 0x1B7,

        0x8A, // Key_Pad_Start = 0x1B8,
        0x9B, // Key_Pad_Back = 0x1B9,

        0x84, // Key_Pad_LThumb = 0x1BA,
        0x85, // Key_Pad_RThumb = 0x1BB,
        0x86, // Key_Pad_LShoulder = 0x1BC,
        0x87, // Key_Pad_RShoulder = 0x1BD,
        0x88, // Key_Pad_LTrigger = 0x1BE,
        0x89, // Key_Pad_RTrigger = 0x1BF,

        0x80, //Key_Pad_A = 0x1C0,
        0x81, //Key_Pad_B = 0x1C1,
        0x82, //Key_Pad_X = 0x1C2,
        0x83, //Key_Pad_Y = 0x1C3,

        // The following is only used when offsetting pad buttons for the PS versions

        0x97, //Key_Pad_A (Playstation)
        0x98, //Key_Pad_B (Playstation)
        0x99, //Key_Pad_X (Playstation)
        0x9A  //Key_Pad_Y (Playstation)
    };

    enum FontIcons {
        ICON_PAD_A = 0x80,
        ICON_PAD_B = 0x81,
        ICON_PAD_X = 0x82,
        ICON_PAD_Y = 0x83
    }

    const DestructiveColor = 0xFFE34646;
    const HighlightColor = 0xFFB0C6F7;
    const GoldColor = 0xFFFBC200;

    static int GetUIKey(int kid) {
        if(kid >= UIHelper.KIDtoUI.Size() || kid < 0) {
            return -1;
        }

        return UIHelper.KIDtoUI[kid];
    }

    static bool IsGamepadKey(int kid) {
        return kid >= InputEvent.Key_Pad_LThumb_Right && kid < InputEvent.Num_Keys;
    }

    static string FilterKeybinds(string txt, string col = "", bool shortMode = false, bool forceGamepad = false) {
        // Use format: $<[OMNIBLUE],+use>$
        // Use format: $<+use>$
        // Use format: $[[OMNIBLUE],+use]$
        // Use format: $[+use]$
        let ih = InputHandler.Instance();
        let show_gamepad_keys = iGetCVar('g_show_gamepad_keys');
        bool usingGamepad = (ih.isUsingGamepad || forceGamepad || show_gamepad_keys == 2) && show_gamepad_keys != 0;

        // Do necessary text replacement
        // Find keybinds in the format of $<+use>$
        int rep = txt.indexOf("$<");
        while(rep > -1) {
            int rap = txt.indexOf(">$", rep + 2);
            if(rap > -1) {
                string subColor = col;
                string substr = txt.mid(rep, rap - rep + 2);

                // First, find the color if it exists by checking for a comma
                int comPos = substr.indexOf(",", 2);
                if(comPos > -1) {
                    subColor = substr.mid(2, comPos - 2);
                }

                // Do a replacement
                array<int> keys;
                string keyName = comPos > -1 ? substr.mid(comPos + 1, substr.length() - 3 - comPos) : substr.mid(2, substr.length() - 4);
                
                Bindings.GetAllKeysForCommand(keys, keyName);
                if(keys.size() == 0) AutomapBindings.GetAllKeysForCommand(keys, keyName);

                string keysText = subColor != "" ? NamesForKeysColor(keys, subColor, false, shortMode, usingGamepad) : NamesForKeys(keys, false, shortMode, usingGamepad);
                if(keysText.length() == 0) {
                    keysText = (subColor != "" ? ("\c" .. subColor) : "") .. "UNBOUND"; // TODO: Get this from LANGUAGE
                }

                if(subColor != "") keysText = String.Format("%s\cl", keysText);

                txt.replace(substr, keysText);
            } else { break; }   // If there is no matching ]$ then we cannot continue to parse

            rep = txt.indexOf("$<");
        }

        // Find keybinds in the format of $[+use]$
        rep = txt.indexOf("$[");
        while(rep > -1) {
            int rap = txt.indexOf("]$", rep + 2);
            if(rap > -1) {
                string subColor = col;
                string substr = txt.mid(rep, rap - rep + 2);

                // First, find the color if it exists by checking for a comma
                int comPos = substr.indexOf(",", 2);
                if(comPos > -1) {
                    subColor = substr.mid(2, comPos - 2);
                }

                // Do a replacement
                array<int> keys, tempKeys;
                array<string> keyNames;
                string keyName = comPos > -1 ? substr.mid(comPos + 1, substr.length() - 3 - comPos) : substr.mid(2, substr.length() - 4);
                
                // Find all keys in the list (usually just one)
                keyName.split(keyNames, ",");
                for(int x = 0; x < keyNames.size(); x++) {
                    // Special case here, show the usereload key as well for use actions
                    if(keyNames[x].makeLower() == "+use") keyNames.push("+usereload");
                    if(keyNames[x].makeLower() == "+reload") keyNames.push("+usereload");
                    Bindings.GetAllKeysForCommand(tempKeys, keyNames[x]);
                    if(tempKeys.size() == 0) AutomapBindings.GetAllKeysForCommand(tempKeys, keyNames[x]);
                    keys.append(tempKeys);
                }
                
                // Get text for keys/buttons
                string keysText;
                bool isGamepadOnly;
                if(subColor != "") [keysText, isGamepadOnly] = NamesForKeysColor(keys, subColor, false, shortMode, usingGamepad);
                else [keysText, isGamepadOnly] = NamesForKeys(keys, false, shortMode, usingGamepad);

                if(keysText.length() == 0) {
                    keysText = (subColor != "" ? ("\c" .. subColor) : "") .. "UNBOUND"; // TODO: Get this from LANGUAGE
                }
                
                if(isGamepadOnly) {
                    if(subColor != "") {
                        subColor = "\c" .. subColor;
                        keysText = String.Format("%s%s%s\cl", subColor, keysText, subColor);
                    } else {
                        keysText = keysText;
                    }
                } else {
                    if(subColor != "") {
                        subColor = "\c" .. subColor;
                        keysText = String.Format("%s[%s%s]\cl", subColor, keysText, subColor);
                    } else {
                        keysText = String.Format("[%s]", keysText);
                    }
                }
                

                txt.replace(substr, keysText);
            } else { break; }   // If there is no matching ]$ then we cannot continue to parse

            rep = txt.indexOf("$[");
        }

        return txt;
    }

    // Returns names and boolean if only gamepad keys are shown
    static string, bool NamesForKeys(array<int> keys, bool forceOr = false, bool shortMode = false, bool usingGamepad = false) {
        string nmk;
        bool useOr = forceOr || keys.size() <= 2;
        bool hasNonGamepadKey = false;
        bool hasGamepadKey = false;

        // Figure out what kind of keys we are dealing with
        for(int x = 0; x < keys.size(); x++) {
            if(keys[x] < FontIconLookupPadStart || keys[x] > FontIconLookupPadEnd) {
                hasNonGamepadKey = true;
            } else {
                hasGamepadKey = true;
            }
        }

        for(int x =0; x < keys.size(); x++) {
            if(x > 0 && shortMode && nmk != "") break; 

            // Check key for Gamepad
            int key = keys[x];
            if(key >= FontIconLookupPadStart && key <= FontIconLookupPadEnd) {
                if(shortMode && !usingGamepad && hasNonGamepadKey) continue;    // Skip this key if there are others, because we aren't using a gamepad

                // Modify the key if PS buttons are desired
                if(key >= FontIconLookupPadEnd - 3 && iGetCVar("g_gamepad_use_psx")) key += 4;

                // Add the icon as UNICODE
                if(nmk != "")  { nmk = nmk .. (useOr ? " or " : ", "); }
                nmk = String.Format("%s%c", nmk, UIHelper.FontIconLookupPad[key - FontIconLookupPadStart]);
            } else {
                if(shortMode && usingGamepad && hasGamepadKey) continue;        // Skip this key for the gamepad one
                
                // Add standard text description of key
                if(nmk != "")  { nmk = nmk .. (useOr ? " or " : ", "); }
                string keyName = KeyBindings.NameKeys(key, 0);
                keyName.replace("Arrow", "");
                nmk = String.Format("%s%s", nmk, keyName);
            }
        }

        return nmk, hasGamepadKey && usingGamepad;
    }

    // Returns names and boolean if only gamepad keys are returned
    static string, bool NamesForKeysColor(array<int> keys, string colorCode = "[HI]", bool forceOr = false, bool shortMode = false, bool usingGamepad = false) {
        string nmk;
        bool useOr = forceOr || keys.size() <= 2;
        bool hasNonGamepadKey = false;
        bool hasGamepadKey = false;

        // Figure out what kind of keys we are dealing with
        for(int x = 0; x < keys.size(); x++) {
            if(keys[x] < FontIconLookupPadStart || keys[x] > FontIconLookupPadEnd) {
                hasNonGamepadKey = true;
            } else {
                hasGamepadKey = true;
            }
        }
        
        colorCode = "\c" .. colorCode;

        for(int x =0; x < keys.size(); x++) {
            if(x > 0 && shortMode && nmk != "") break; 
            
            // Check key for Gamepad
            int key = keys[x];
            if(key >= FontIconLookupPadStart && key <= FontIconLookupPadEnd) {
                if(!usingGamepad && hasNonGamepadKey) continue;    // Skip this key if there are others, because we aren't using a gamepad

                // Modify the key if PS buttons are desired
                if(key >= FontIconLookupPadEnd - 3 && iGetCVar("g_gamepad_use_psx")) key += 4;

                // Add the icon as UNICODE
                if(nmk != "") { nmk = nmk .. colorCode .. (useOr ? " or " : ", "); }
                nmk = String.Format("%s%s%c", nmk, "\c-", UIHelper.FontIconLookupPad[key - FontIconLookupPadStart]);
            } else {
                if(usingGamepad && hasGamepadKey) continue;        // Skip this key for the gamepad one

                // Add standard text description of key
                if(nmk != "") { nmk = nmk .. colorCode .. (useOr ? " or " : ", "); }
                string keyName = KeyBindings.NameKeys(key, 0);
                keyName.replace("Arrow", "");
                nmk = String.Format("%s%s%s", nmk, colorCode, keyName);
            }
        }

        return nmk, hasGamepadKey && usingGamepad;
    }


    static string NameForKeybind(string bind) {
        bind = bind.makeLower();

        // This is a bit extreme but :ascii_shrug:
        Dictionary dict = Dictionary.Create();
        dict.Insert("+forward", "$CNTRLMNU_FORWARD");
        dict.Insert("+back", "$CNTRLMNU_BACK");
        dict.Insert("+moveleft", "$CNTRLMNU_MOVELEFT");
        dict.Insert("+moveright", "$CNTRLMNU_MOVERIGHT");
        dict.Insert("+dashMode", "$CNTRLMNU_DASHES");
        dict.Insert("+attack", "$CNTRLMNU_ATTACK");
        dict.Insert("+altattack", "$CNTRLMNU_ALTATTACK");
        dict.Insert("meleeButton", "$CNTRLMNU_MELEE");
        dict.Insert("+use", "$CNTRLMNU_USE");
        dict.Insert("+reload", "$CNTRLMNU_RELOAD");
        dict.Insert("+usereload", "$CNTRLMNU_USE_RELOAD");
        dict.Insert("usemeds", "$CNTRLMNU_MEDKIT");
        dict.Insert("useGadget", "$CNTRLMNU_THROWABLE");
        dict.Insert("switchGadget", "$CNTRLMNU_SWITCHTHROWABLE");
        dict.Insert("Toggle_Flashlight", "$CNTRLMNU_FLASHLIGHT");
        dict.Insert("Place_Marker", "$CNTRLMNU_PLACEMARKER");
        dict.Insert("+jump", "$CNTRLMNU_JUMP");
        dict.Insert("+crouch", "$CNTRLMNU_CROUCH");
        dict.Insert("crouch", "$CNTRLMNU_TOGGLECROUCH");
        dict.Insert("+mlook", "$CNTRLMNU_MOUSELOOK");
        dict.Insert("+klook", "$CNTRLMNU_KEYBOARDLOOK");
        dict.Insert("+lookup", "$CNTRLMNU_LOOKUP");
        dict.Insert("+lookdown", "$CNTRLMNU_LOOKDOWN");
        dict.Insert("centerview", "$CNTRLMNU_CENTERVIEW");
        dict.Insert("weapnext", "$CNTRLMNU_NEXTWEAPON");
        dict.Insert("weapprev", "$CNTRLMNU_PREVIOUSWEAPON");
        dict.Insert("weaponWheel", "$CNTRLMNU_WEAPONWHEEL");
        dict.Insert("slot 0", "$CNTRLMNU_SLOT0");
        dict.Insert("slot 1", "$CNTRLMNU_SLOT1");
        dict.Insert("slot 2", "$CNTRLMNU_SLOT2");
        dict.Insert("slot 3", "$CNTRLMNU_SLOT3");
        dict.Insert("slot 4", "$CNTRLMNU_SLOT4");
        dict.Insert("slot 5", "$CNTRLMNU_SLOT5");
        dict.Insert("slot 6", "$CNTRLMNU_SLOT6");
        dict.Insert("slot 7", "$CNTRLMNU_SLOT7");
        dict.Insert("slot 8", "$CNTRLMNU_SLOT8");
        dict.Insert("slot 9", "$CNTRLMNU_SLOT9");
        dict.Insert("printObjectives", "$CNTRLMNU_OBJECTIVES");
        dict.Insert("togglemap", "$CNTRLMNU_AUTOMAP");
        dict.Insert("codex", "$CNTRLMNU_OPENCODEX");
        dict.Insert("+left", "$CNTRLMNU_TURNLEFT");
        dict.Insert("+right", "$CNTRLMNU_TURNRIGHT");
        dict.Insert("turn180", "$CNTRLMNU_TURN180");
        dict.Insert("+speed", "$CONTROLS_SPEED");
        dict.Insert("toggle cl_run", "$CONTROLS_WALKMODE");
        dict.Insert("chase", "$CNTRLMNU_CHASECAM");
        dict.Insert("+moveup", "$CNTRLMNU_MOVEUP");
        dict.Insert("+movedown", "$CNTRLMNU_MOVEDOWN");
        dict.Insert("screenshot", "$CNTRLMNU_SCREENSHOT");
        dict.Insert("toggleconsole", "$CNTRLMNU_CONSOLE");
        dict.Insert("toggle_HUD", "$CNTRLMNU_TOGGLEHUD");
        dict.Insert("quicksaveselaco", "$CNTRLMNU_QUICKSAVE");
        dict.Insert("quickload", "$CNTRLMNU_QUICKLOAD");
        dict.Insert("+am_panleft", "$MAPCNTRLMNU_PANLEFT");
        dict.Insert("+am_panright", "$MAPCNTRLMNU_PANRIGHT");
        dict.Insert("+am_panup", "$MAPCNTRLMNU_PANUP");
        dict.Insert("+am_pandown", "$MAPCNTRLMNU_PANDOWN");
        dict.Insert("+am_zoomin", "$MAPCNTRLMNU_ZOOMIN");
        dict.Insert("+am_zoomout", "$MAPCNTRLMNU_ZOOMOUT");
        dict.Insert("am_gobig", "$MAPCNTRLMNU_TOGGLEZOOM");
        dict.Insert("am_togglefollow", "$MAPCNTRLMNU_TOGGLEFOLLOW");
        dict.Insert("am_togglelegend", "$MAPCNTRLMNU_TOGGLELEGEND");
        dict.Insert("am_center", "$MAPCNTRLMNU_CENTER");

        let ret = dict.at(bind);
        if(ret == "") return bind;
        return StringTable.Localize(ret);
    }


    static bool CheckForUsermaps() {
        let wi = Wads.GetLumpWadNum(Z_CONTAINER);
		for(int y = 0; y < LevelInfo.GetLevelInfoCount(); y++) {
			let info = LevelInfo.GetLevelInfo(y);
			int c2 = Wads.CheckNumForFullName("maps/" .. info.MapName .. ".wad");
			int wadnum = Wads.GetLumpWadNum(c2);

			if((info.cluster < 1 || info.cluster > 3) && wadnum > wi) return true;
		}
		return false;
	}


    static bool GetModList(Array<string> output, bool useModName = true, bool stripPath = true) {
        let wi = Wads.GetLumpWadNum(Z_CONTAINER);
        Array<int> menudefs;
        Array<int> lumps;
        bool found = false;

        // See if we can find menudef headers
        for(int lump = 1; lump < Wads.GetNumLumps() && lump > 0; lump++) {
            lump = Wads.FindLump("MENUDEF", lump, 0);
            if(lump < 0) break;
            if(developer) Console.Printf("Lump: %d %s", lump, Wads.GetLumpFullName(lump));

            if(lump > 0) {
                int wadnum = Wads.GetLumpWadNum(lump);
                if(wadnum > wi) {
                    if(developer) Console.Printf("Wad num: %d", wadnum);
                    menudefs.push(wadnum);
                    lumps.push(lump);
                    if(developer) Console.Printf("Mod name: %s", UIHelper.ReadModNameFromMenuDef(lump));
                }
            }
        }

        for(int y = wi + 1; y < Wads.GetNumWads(); y++) {
            let wadName = Wads.GetWadName(y);
            if(stripPath) {
                int modFolder = wadName.makeLower().rightIndexOf("/");
                if(modFolder < int(wadName.length())) wadName = wadName.mid(modFolder + 1);
            }
            

            // Check to see if we have a menudef name for this
            if(useModName) {
                for(int x = 0; x < menudefs.size(); x++) {
                    if(menudefs[x] == y) {
                        // Try to get mod name
                        string wadNameTemp = ReadModNameFromMenuDef(lumps[x]);
                        if(wadNameTemp != "") {
                            wadName = wadNameTemp;
                            break;
                        }
                    }
                }
            }
            
            if(wadName.length() > 0) {
                output.push(wadName);
                found = true;
            }
        }

        return found;
    }


    // This is inneficient and stupid, but we have no other way to get a mod name
    static string ReadModNameFromMenuDef(int lump) {
        if(lump <= 0) return "";

        string text = Wads.ReadLump(lump);
        if(text == "") return "";

        string text2 = text.MakeLower();

        // Find the first ModHeader
        int pos = text2.indexOf("modheader ");
        if(pos == -1) pos = text.indexOf("modheader\t");

        if(pos >= 0) {
            pos = text2.indexOf("\"", pos);
            if(pos >= 0) {
                int endPos = text2.indexOf("\"", pos + 1);

                if(endPos > 0 && endPos - pos > 1 && endPos - pos < 128) {
                    string ret = text.mid(pos + 1, endPos - pos - 1);
                    ret.stripRight();
                    return ret;
                }
            }
        }

        return "";
    }


    static string GetGamepadString(int key) {
        let keyString = "";

        if(!(key < UIHelper.FontIconLookupPadStart || key > UIHelper.FontIconLookupPadEnd)) {
            if(key >= UIHelper.FontIconLookupPadEnd - 3 && iGetCVar("g_gamepad_use_psx")) key += 4;
            keyString = String.Format("%c", UIHelper.FontIconLookupPad[key - UIHelper.FontIconLookupPadStart]);
        }

        return keyString;
    }

    // Remove unnecessary info in level name
    // Remove anything after -
    // Remove anything in ()
    static string GetShortLevelName(string levelName) {
        string newName = levelName;
        int dash = newName.indexOf(" - ");
        if(dash != -1) newName = newName.left(dash);

        for(int noinfiniteloopsplease = 0; noinfiniteloopsplease < 10; noinfiniteloopsplease++) {
            int s = newName.indexOf("(");
            int s2 = newName.indexOf(")");

            if(s >= 0 && s2 >= 0 && s2 > s) newName = newName.left(s) .. newName.mid(s2 + 1);
            else break;
        }

        return newName;
    }

    static void SetSteamdeckPresets() {
        // Set the menu scale
        let uicv = CVar.FindCVar("ui_scaling");
        if(uicv) uicv.setFloat(1.2);
        else Console.Printf("\crCouldn't set UI_SCALING");

        // Set subtitles to large
        uicv = CVar.FindCVar("snd_subtitlesize");
        if(uicv) uicv.setInt(4);
        else Console.Printf("\crCouldn't set snd_subtitlesize");

        // Set HUD Scaling to large
        uicv = CVar.FindCVar("hud_scaling");
        if(uicv) uicv.setFloat(1.2);
        else Console.Printf("\crCouldn't set hud_scaling");

        // Set HUD Border opacity
        uicv = CVar.FindCVar("g_hudopacity");
        if(uicv) uicv.setFloat(0);
        else Console.Printf("\crCouldn't set g_hudopacity");

        uicv = CVar.FindCVar("hud_meter_scaling");
        if(uicv) uicv.setFloat(1.0);
        else Console.Printf("\crCouldn't set hud_meter_scaling");

        uicv = CVar.FindCVar("snd_subtitlebg");
        if(uicv) uicv.setInt(1);
        else Console.Printf("\crCouldn't set snd_subtitlebg");


        // Turn on aim assist
        uicv = CVar.FindCVar("AIMASSIST_ENABLE");
        if(uicv) uicv.setInt(1);
        else Console.Printf("\crCouldn't set AIMASSIST_ENABLE");

        uicv = CVar.FindCVar("AIMASSIST_STYLE");
        if(uicv) uicv.setInt(1);
        else Console.Printf("\crCouldn't set AIMASSIST_STYLE");

        // Set aim strength
        uicv = CVar.FindCVar("AIMASSIST_STRENGTH");
        if(uicv) uicv.setFloat(0.15);
        else Console.Printf("\crCouldn't set AIMASSIST_STRENGTH");
    }


    static play  void ResetTutorials() {
        Array<String> gKeys;
        Globals.GetKeys(gKeys);

        for(int x = 0; x < gKeys.size(); x++) {
            if(gKeys[x].indexOf("TUTORIAL_") == 0) {
                if(developer) Console.Printf("Resetting Global: %s", gKeys[x]);
                Globals.SetInt(gKeys[x], 0);
            }
        }
    }


    static ui bool TestForSteamDeck() {
        if(g_steamdeck) return true;
        
        if(!TestForLinux()) return false;
        
        // Test screen size
        if((Screen.GetWidth() == 1280 && Screen.GetHeight() == 800) || (Screen.GetWindowWidth() == 1280 && Screen.GetWindowHeight() == 800)) {
            // Test Joysticks
            if(JoystickConfig.NumJoysticks() > 0) {
                return true;
            }
        }

        return false;
    }


    static ui bool TestForLinux() {
        let menuDescriptor = OptionMenuDescriptor(MenuDescriptor.GetDescriptor("TestForLinux"));
        if(menuDescriptor && menuDescriptor.mItems.size() > 0) {
            return true;
        }
        return false;
    }


    static ui bool TestForWindows() {
        let menuDescriptor = OptionMenuDescriptor(MenuDescriptor.GetDescriptor("TestForWindows"));
        if(menuDescriptor && menuDescriptor.mItems.size() > 0) {
            return true;
        }
        return false;
    }


    static ui int, SavegameManager FindLastSavedGame() {
        let saveMan = SavegameManager.GetManager();
        saveMan.ReadSaveStrings();
        if(saveMan.SavegameCount()) saveMan.RemoveNewSaveNode();
        if(saveMan.SavegameCount() <= 0) return -1, saveMan;

        // Find newest node that we can load
        SaveGameNode mostRecentNode = null;
        int mostRecentNodeIndex = -1;

        for(int x = 0; x < saveMan.SavegameCount(); x++) {
            let node = saveMan.GetSavegame(x);
            if(!node.bOldVersion && !node.bMissingWads) {
                mostRecentNode = node;
                mostRecentNodeIndex = x;
                break;
            }
        }

        return mostRecentNodeIndex, saveMan;
    }


    // Call during an event only
    static ui void ResetNewGameOptions() {
        let menuDescriptor = OptionMenuDescriptor(MenuDescriptor.GetDescriptor("NewGameSettings"));
        if(menuDescriptor) {
            UIButton lastButt = null;
            for(int x = 0; x < menuDescriptor.mItems.size(); x++) {
                iSetCVAR(menuDescriptor.mItems[x].GetAction(), 0);
                let o = OptionMenuItemTooltipOption(menuDescriptor.mItems[x]);
                if(o) {
                    o.setSelection(0);
                } else {
                    let o = OptionMenuItemTooltipSlider(menuDescriptor.mItems[x]);
                    if(o) {
                        o.setSliderValue(0);
                    }
                }
                if(developer) Console.Printf("Reset: %s", menuDescriptor.mItems[x].GetAction());
            }
        }

        // Manually set randomizer, since its not in the NewGameSettings list anymore
        iSetCVAR('g_randomizer', 0);
    }
}


class Math {
    clearscope static Vector2 pointOnLine(Vector2 p1, Vector2 p2, Vector2 pt, bool restrict = false) {
        Vector2 r = (0,0);
        if (p1.x == p2.x && p1.y == p2.y) p1.x -= 0.00001;

        let U = ((pt.x - p1.x) * (p2.x - p1.x)) + ((pt.y - p1.y) * (p2.y - p1.y));
        let Udenom = (p2.x - p1.x)**2 + (p2.y - p1.y)**2;

        U /= Udenom;

        r.x = p1.x + (U * (p2.x - p1.x));
        r.y = p1.y + (U * (p2.y - p1.y));

        if(restrict) {
            let minx = min(p1.x, p2.x);
            let maxx = max(p1.x, p2.x);

            let miny = min(p1.y, p2.y);
            let maxy = max(p1.y, p2.y);

            r.x = clamp(r.x, minx, maxx);
            r.y = clamp(r.y, miny, maxy);
        }

        return r;
    }
}


class CommonUI ui {
    const STANDARD_SCROLL_AMOUNT = 35.0;
    
    static String getTimeString(uint tics) {
        int totalSecs = tics / TICRATE;
        int hours = int(double(totalSecs) / 60.0 / 60.0);
        int minutes = int((double(totalSecs) - (hours * 60 * 60)) / 60.0);
        totalSecs = totalSecs - (hours * 60 * 60) - (minutes * 60);

        return String.format("%.2d:%.2d:%.2d", hours, minutes, totalSecs);
    }

    static String getTimeStringForSeconds(uint totalSecs) {
        int hours = int(double(totalSecs) / 60.0 / 60.0);
        int minutes = int((double(totalSecs) - (hours * 60 * 60)) / 60.0);
        totalSecs = totalSecs - (hours * 60 * 60) - (minutes * 60);

        return String.format("%.2d:%.2d:%.2d", hours, minutes, totalSecs);
    }

    static UIButtonState barBackgroundState() { return UIButtonState.CreateSlices("STDBARB1", (8,2), (245,8), textColor: Font.CR_UNTRANSLATED); }
    
    static StandardBackgroundContainer, UILabel makeStandardBackgroundContainer(double defaultWidth = 1920, string image = "", string title = "") {
        let bg = new("StandardBackgroundContainer").init(defaultWidth, image, title);

        return bg, bg.titleLabel;
    }

    static UIScrollBarConfig makeDropScrollConfig() {
        return UIScrollBarConfig.Create(
            30, 30,
            NineSlice.Create("graphics/options_menu/slider_bg_vertical.png", (14, 6), (16, 24)),
            null,
            UIButtonState.CreateSlices("graphics/options_menu/slider_bg_vertical_full.png", (14, 6), (16, 24)),
            UIButtonState.CreateSlices("graphics/options_menu/slider_bg_vertical_full.png", (14, 6), (16, 24)),
            UIButtonState.CreateSlices("graphics/options_menu/slider_bg_vertical_full_down.png", (14, 6), (16, 24)),
            insetA: 10,
            insetB: 10
        );
    }

    static UIOSKTemplate MakeDefaultOSKTemplate() {
        UIOSKTemplate template = new("UIOSKTemplate");
        template.buttonSound = "menu/OSKPress";
        template.deleteSound = "menu/OSKBackspace";
        template.errorSound = "ui/buy/error";
        template.okSound = "menu/OSKSave";

        return template;
    }

    static void MakeStandardButtonEffects(UIButton btn) {
        btn.buttStates[UIButton.State_Normal].blendColor = 0;
        if(btn.buttStates[UIButton.State_Hover]) btn.buttStates[UIButton.State_Hover].blendColor = 0x11FFFFFF;
        if(btn.buttStates[UIButton.State_Pressed]) btn.buttStates[UIButton.State_Pressed].blendColor = 0x66FFFFFF;
    }


    static UIButton MakeStandardButton(string text = "Button", Font fnt = "PDA16FONT", bool sound = false, bool negative = false) {
        let btn = new("UIButton").init((0,0), (100, 30), text, fnt,
            UIButtonState.CreateSlices("graphics/options_menu/op_butt.png", (8,8), (14, 14), textColor: negative ? UIHelper.DestructiveColor : 0xFFFFFFFF),
            UIButtonState.CreateSlices("graphics/options_menu/op_dropdown_norm.png", (9,9), (13,13), textColor: 0xFFFFFFFF, sound: sound ? "ui/cursor2" : "", soundVolume: sound ? 0.45 : 1.0),
            UIButtonState.CreateSlices("graphics/options_menu/op_dropdown_down.png", (9,9), (13,13), textColor: 0xFFFFFFFF),
            UIButtonState.CreateSlices("graphics/options_menu/op_butt.png", (8,8), (14, 14), textColor: 0xFF999999),
            UIButtonState.CreateSlices("graphics/options_menu/op_butt_select.png", (9,9), (13,13), textColor: 0xFFFFFFFF),
            UIButtonState.CreateSlices("graphics/options_menu/op_butt_select.png", (9,9), (13,13), textColor: 0xFFFFFFFF),
            UIButtonState.CreateSlices("graphics/options_menu/op_butt_select.png", (9,9), (13,13), textColor: 0xFFFFFFFF)
        );

        btn.setTextPadding(8,4,8,4);
        btn.label.multiline = true;

        if(negative) {
            btn.blendColor = UIHelper.DestructiveColor;
            btn.desaturation = 1.0;
        }

        return btn;
    }
}


class StandardBackgroundContainer : UIImage {
    mixin CVARBuddy;

    UILabel titleLabel;
    UIHorizontalLayout headerLayout, footerLayout;
    Array<UILabel> headerLabels;
    Array<UIButton> footerButtons;

    StandardBackgroundContainer init(double defaultWidth = 1920, string image = "", string title = "") {
        super.init((0,0), (1,1), image);
        pinWidth(1.0, offset: -160, isFactor: true);
        pin(UIPin.Pin_HCenter, value: 1.0, isFactor: true);
        pin(UIPin.Pin_Top, offset: 180);
        pin(UIPin.Pin_Bottom, offset: -70);
        clipsSubviews = false;
        maxSize = (1760, 99999);

        headerLayout = new("UIHorizontalLayout").init((0,0), (500, 100));
        headerLayout.pin(UIPin.Pin_Left);
        headerLayout.pin(UIPin.Pin_Bottom, UIPin.Pin_Top, offset: -20);
        headerLayout.pin(UIPin.Pin_Right);
        headerLayout.pinHeight(100);
        headerLayout.itemSpacing = 10;
        add(headerLayout);

        footerLayout = new("UIHorizontalLayout").init((0,0), (500, 100));
        footerLayout.pin(UIPin.Pin_Top, UIPin.Pin_Bottom, offset: 10);
        footerLayout.pin(UIPin.Pin_Right);
        footerLayout.pinHeight(100);
        footerLayout.itemSpacing = 20;
        footerLayout.layoutMode = UIViewManager.Content_SizeParent;
        add(footerLayout);

        if(title != "") {
            titleLabel = new("UILabel").init((0, 0), (1, 1), title, 'SEL46FONT');
            titleLabel.pin(UIPin.Pin_Bottom);
            titleLabel.pinHeight(UIView.Size_Min);
            titleLabel.pinWidth(UIView.Size_Min);
            headerLayout.addManaged(titleLabel);
        }

        return self;
    }


    UILabel addHeaderLabel(string label, bool animate = true) {
        // Add separator alone
        let lab = new("UILabel").init((0,0), (500, 10), "/", "SEL46FONT", fontScale: (0.6, 0.6));
        lab.pin(UIPin.Pin_Bottom);
        lab.pinHeight(UIView.Size_Min);
        lab.pinWidth(UIView.Size_Min);
        headerLayout.addManaged(lab);
        headerLabels.push(lab);

        // Add header label
        lab = new("UILabel").init((0,0), (500, 10), label, "SEL46FONT", fontScale: (0.6, 0.6));
        lab.pin(UIPin.Pin_Bottom);
        lab.pinHeight(UIView.Size_Min);
        lab.pinWidth(UIView.Size_Min);
        headerLayout.addManaged(lab);
        headerLabels.push(lab);

        // Animate
        if(animate) {
             // Layout now so we know where to animate from
            headerLayout.layout();

            lab.animateFrame(
                0.18,
                fromPos: lab.frame.pos + (50, 0),
                toPos: lab.frame.pos,
                fromAlpha: 0,
                toAlpha: 1,
                ease: Ease_Out
            );

            lab.animateLabel(
                0.18,
                fromScale: (1.0, 0.6),
                toScale: lab.fontScale,
                ease: Ease_Out
            );
        }
        
        return lab;
    }


    void popHeaderLabel() {
        // Remove label and separator
        if(headerLabels.size()) {
            let l = headerLabels[headerLabels.size() - 1];
            headerLabels.pop();
            headerLayout.removeManaged(l);
        }
        
        if(headerLabels.size()) {
            let l = headerLabels[headerLabels.size() - 1];
            headerLabels.pop();
            headerLayout.removeManaged(l);
        }
    }


    UIButton addGamepadFooter(int key, string text, int index = -1) {
        let keyString = "";
        let okey = key;

        if(!(key < UIHelper.FontIconLookupPadStart || key > UIHelper.FontIconLookupPadEnd)) {
            if(key >= UIHelper.FontIconLookupPadEnd - 3 && iGetCVar("g_gamepad_use_psx")) key += 4;
            keyString = String.Format("%c ", UIHelper.FontIconLookupPad[key - UIHelper.FontIconLookupPadStart]);
        }
        
        let btn = new("UIButton").init(
            (0,0), (100, 40),
            keyString .. text, "SEL21OFONT",
            UIButtonState.Create("")
        );
        btn.raycastTarget = false;
        btn.rejectHoverSelection = true;
        btn.controlID = okey;
        btn.label.multiline = false;
        btn.pinWidth(UIView.Size_Min);

        footerButtons.push(btn);
        footerLayout.insertManaged(btn, index >= 0 ? index : footerLayout.numManaged());

        return btn;
    }


    void removeGamepadFooterKey(int key) {
        for(int x = footerButtons.size() - 1; x >= 0; x--) {
            if(footerButtons[x].controlID == key) {
                footerLayout.removeManaged(footerButtons[x]);
                footerButtons.delete(x);
            }
        }
    }


    void removeGamepadFooter(UIButton btn) {
        for(int x = footerButtons.size() - 1; x >= 0; x--) {
            if(footerButtons[x] == btn) {
                footerLayout.removeManaged(footerButtons[x]);
                footerButtons.delete(x);
            }
        }
    }
}



class RevealImage : UIImage {
    double startReveal;
    double revealTime;

    RevealImage init(Vector2 pos, Vector2 size, string image, ImageStyle imgStyle = Image_Scale, Vector2 imgScale = (1,1), ImageAnchor imgAnchor = ImageAnchor_Middle) {
        Super.init(pos, size, image, null, imgStyle, imgScale, imgAnchor);
        raycastTarget = false;
        revealtime = 0.18;

        return self;
    }

    void startAnim(double delay = 0) {
        startReveal = getTime() + delay;
    }

    override void draw() {
        if(hidden) { return; }
        
        double reveal = UIMath.EaseInQuadF( CLAMP((getTime() - startReveal) / revealTime, 0, 1) );
        
        UIView.draw();

        UIBox b;
        boundingBoxToScreen(b);
        Vector2 pos, size;
        [pos, size] = getImgPos(b);

        if(reveal > 0 && tex) {
            UIBox clipRect;
            UIBox revealRect;
            revealRect.pos = pos;
            revealRect.size.y = size.y;
            revealRect.size.x = size.x * reveal;
            getScreenClip(clipRect);
            revealRect.intersect(revealRect, clipRect);

            Screen.setClipRect(int(revealRect.pos.x), int(revealRect.pos.y), int(revealRect.size.x), int(revealRect.size.y));

            Screen.DrawTexture(
                tex.texID, 
                true, 
                floor(pos.x),
                floor(pos.y),
                DTA_DestWidthF, size.x,
                DTA_DestHeightF, size.y,
                DTA_Alpha, cAlpha,
                DTA_ColorOverlay, blendColor,
                DTA_Filtering, !noFilter,
                DTA_Desaturate, int(255.0 * desaturation)
            );

            Screen.ClearClipRect();
        }
        
    }
}


class StandardCheckbox : UIButton {
    UIImage checkImage;
    bool animated;

    StandardCheckbox init(Vector2 pos, Vector2 size, bool animated = true) {
        Super.init(pos, size, "", null, 
            UIButtonState.CreateSlices("graphics/options_menu/checkbox.png", (9, 9), (21, 21)),
            UIButtonState.CreateSlices("graphics/options_menu/checkbox_high.png", (9, 9), (21, 21), sound: "menu/cursor", soundVolume: 0.45),
            UIButtonState.CreateSlices("graphics/options_menu/checkbox_down.png", (9, 9), (21, 21)),
            UIButtonState.CreateSlices("graphics/options_menu/checkbox_disabled.png", (9, 9), (21, 21)),
            UIButtonState.CreateSlices("graphics/options_menu/checkbox_filled.png", (9, 9), (21, 21)),
            UIButtonState.CreateSlices("graphics/options_menu/checkbox_filled_high.png", (9, 9), (21, 21), sound: "menu/cursor", soundVolume: 0.45),
            UIButtonState.CreateSlices("graphics/options_menu/checkbox_filled_down.png", (9, 9), (21, 21))
        );

        checkImage = new("UIImage").init((0,0), (1, 1), "graphics/options_menu/checkbox_check.png");
        checkImage.pinToParent();
        checkImage.alpha = 0;
        checkImage.imgScale = (0.8, 0.8);
        add(checkImage);

        self.animated = animated;

        return self;
    }


    override void transitionToState(int idx, bool sound, bool mouseSelection) {
        int oldidx = currentState;
        Super.transitionToState(idx, sound, mouseSelection);

        if((oldidx < State_Selected || oldidx == State_Disabled) && currentState >= State_Selected && currentState != State_Disabled) {
            if(getAnimator()) {
                getAnimator().clear(checkImage);

                // Animate to checked
                checkImage.animateFrame(
                    0.08,
                    toAlpha: 1,
                    ease: Ease_Out
                );

                checkImage.animateImage(
                    0.1,
                    toScale: (1, 1),
                    ease: Ease_Out_Back_More
                );
            } else {
                checkImage.setAlpha(1);
                checkImage.imgScale = (1,1);
            }
        } else if(oldidx >= State_Selected && (currentState == State_Disabled || currentState < State_Selected)) {
            if(getAnimator()) {
                getAnimator().clear(checkImage);

                // Animate away selected
                checkImage.animateFrame(
                    0.08,
                    toAlpha: 0,
                    ease: Ease_In
                );

                checkImage.animateImage(
                    0.08,
                    toScale: (0.8, 0.8),
                    ease: Ease_Out
                );
            } else {
                checkImage.setAlpha(0);
                checkImage.imgScale = (0.8, 0.8);
            }
        }
    }
}